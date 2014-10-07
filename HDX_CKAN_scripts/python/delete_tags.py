import requests
import json
from io import StringIO
server = 'http://localhost:5000'
key = 'tobeadded'


topics = ['Education', 'emergency', 'Telecommunication',
          'nutrition', 'Health', 'Logistics']
tags = ['Afghanistan', 'COD', 'Colombia',
        'Conflict', 'Demographics', 'Disasters', 'Displacement', 'FOD',
        'Funding', 'GIS', 'Grants', 'Guinea', 'Homicidios', 'IDPS', 'IDPs',
        'Internally Displaced Persons', 'Liberia', 'Loans', 'Map', 'MAP', 'NGO', 'Population Movements',
        'Refugee', 'Refugees', 'Roads', 'Sierra Leone', 'Technology', 'YEMEN']

base = server + '/api/action/tag_delete'
for tag in tags:
    res = requests.post(base, data=json.dumps({'id': tag}), headers={
        "Authorization": key, 'content-type': 'application/json'}, verify=False)
    print 'finishing delete : ' + res.url + '/' + tag

for tag in topics:
    res = requests.post(base, data=json.dumps({'id': tag}), headers={
        "Authorization": key, 'content-type': 'application/json'}, verify=False)
    print 'finishing delete : ' + res.url + '/' + tag
