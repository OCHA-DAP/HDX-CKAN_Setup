#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import csv
import sys
import json
import ckanapi
import requests


def FetchSystemArguments():
  '''Fetch arguments from command line.'''

  arguments = {
    'json_path': sys.argv[1],
    'apikey': sys.argv[2],
    'csv_path': os.path.join(os.getcwd(), 'temp.csv')
  }

  return arguments


def ConfigureCKANInstance(apikey):
  '''Configuring the remote CKAN instance.'''

  ckan = ckanapi.RemoteCKAN('https://data.hdx.rwlabs.org', apikey=apikey)

  return ckan


def LoadSchema(j):
  '''Loading resources from a local json file.'''

  try:
    with open(j) as json_file:    
      resources = json.load(json_file)

    if len(resources) < 1:
      print "Resouces look odd! Please revise."
      return

    return resources

  except Exception as e:
    print e
    return


def DownloadResource(resource_id, csv_path, apikey):
  '''Downloading a resource from CKAN based on its id.'''

  header = { 'Authorization': apikey }

  # querying
  try:
    url = 'https://data.hdx.rwlabs.org/api/action/resource_show?id=' + resource_id
    doc = requests.get(url, headers=header).json()
    resource_file_url = doc["result"]["url"]
  
  except Exception as e:
    print doc
    print e
    return

  # downloading
  with open(csv_path, 'wb') as handle:

    response = requests.get(resource_file_url, stream=True, headers=header)

    if not response.ok:
      print "Error: attempt to download resource failed."
      return

    for block in response.iter_content(1024):
      if not block:
        break

      handle.write(block)


def CreateDatastore(resource, csv_path, apikey):
  '''Creating a DataStore from scratch -- even if one already exists.'''

  ckan = ConfigureCKANInstance(apikey)
  
  try:
    ckan.action.datastore_delete(resource_id=resource['resource_id'], force=True)

  except Exception as e:
    print "ERROR: \n %s" % e
    return

  ckan.action.datastore_create(
        resource_id=resource['resource_id'],
        force=True,
        fields=resource['schema']['fields'],
        primary_key=resource['schema'].get('primary_key'))

  reader = csv.DictReader(open(csv_path))
  rows = [ row for row in reader ]
  chunksize = 1000
  offset = 0

  print 'Creating DataStore for %s' % resource['resource_id']
  while offset < len(rows):
    rowset = rows[offset:offset+chunksize]
    ckan.action.datastore_upsert(
      resource_id=resource['resource_id'],
      force=True,
      method='insert',
      records=rowset)
    offset += chunksize

    print 'Added rows: %s/%s.' % (offset, len(rows))

def RemoveTempFile(file):
    print "Removing temp file %s" % file
    os.remove(file)

def Main():
  '''Wrapper.'''

  try: 
    arguments = FetchSystemArguments()
    resources = LoadSchema(arguments['json_path'])
    ckan = ConfigureCKANInstance(apikey=arguments['apikey'])

  except Exception as e:
    print e


  for resource in resources:
    DownloadResource(resource['resource_id'], arguments['csv_path'], arguments['apikey'])
    CreateDatastore(resource, arguments['csv_path'], arguments['apikey'])
    RemoveTempFile(arguments["csv_path"])



if __name__ == '__main__':
  Main()