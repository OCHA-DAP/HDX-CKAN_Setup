'''
Created on Sep 15, 2014

'''
import requests
import json
from io import StringIO
server = 'http://localhost:5000'
key = 'f19c12a8-4ed6-4f66-9759-3372cddce8ed'
vocab = "Topics"

base = server + '/api/action/vocabulary_create'
res = requests.post(base, data=json.dumps({'name': vocab}), headers={
                    "Authorization": key, 'content-type': 'application/json'}, verify=False)
print 'finishing: ' + res.url + " vocabulary Topics"
