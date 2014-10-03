import requests
import json
from io import StringIO
server = 'http://localhost:5000'
key = 'tobeadded'


tags = ['Education', 'emergency', 'Telecommunication',
        'nutrition', 'Health', 'Logistics']

base = server + '/api/action/tag_delete'
for tag in tags:
    res = requests.post(base, data=json.dumps({'id': tag}), headers={
        "Authorization": key, 'content-type': 'application/json'}, verify=False)
    print 'finishing delete : ' + res.url + '/' + tag
