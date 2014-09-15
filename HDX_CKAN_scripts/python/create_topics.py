'''
Created on Sep 15, 2014

'''
import requests
import json
from io import StringIO
server = 'http://localhost:5000'
key = 'keytobeadded'
topics = ['Education', 
          'Camp Coordination/Management', 
          'Early Recovery', 
          'Economic', 
          'Emergency Shelter and NFI', 
          'Emergency Telecommunication', 
          'Food Security', 
          'Funding', 
          'Gender-based Violence', 
          'Health', 
          'Housing, Land and Property', 
          'Humanitarian Profile', 
          'Logistics', 
          'Mine Action', 
          'Nutrition', 
          'Population', 
          'Protection', 
          'Water, Sanitation and Hygiene']
    
    
base = server + '/api/action/vocabulary_create'
res = requests.post(base, data=json.dumps({'name': 'Topics'}), headers={"Authorization": key, 'content-type': 'application/json'}, verify=False)
print 'finishing:'+ res.url

base = server + '/api/action/vocabulary_show'
res = requests.get(base, params={'id': 'Topics'}, headers={"Authorization": key, 'content-type': 'application/json'}, verify=False)
print 'finishing:'+ res.url
io = StringIO(res.text)
jRes = json.load(io)
if(res.ok):
    vocabulary_id = jRes['result']['id']
    base = server + '/api/action/tag_create'
    for topic in topics:
        r = requests.post(base, data=json.dumps({'name': topic, 'vocabulary_id': vocabulary_id}), headers={"Authorization": key, 'content-type': 'application/json'}, verify=False)
        print 'finishing:'+ topic+r.url