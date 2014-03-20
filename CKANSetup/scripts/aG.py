#!/usr/bin/python
import sys
import urllib2
import urllib
import json
import pprint
import ast

def callckan(action, jsonu):
    #ckanurl = 'http://ocha4.drill.atman.ro:5000'
    ckanurl = 'http://localhost:5000'
    ckanapi = '8974daa4-ab91-4343-b3d3-9ad56c102cf4'
    print '++++++++++++++++++++++'
    pprint.pprint(jsonu)
    print '++++++++++++++++++++++'

    data_string = urllib.quote(json.dumps(ast.literal_eval(jsonu)))

    request = urllib2.Request(ckanurl + '/api/3/action/' + action)

    request.add_header('Authorization', ckanapi)

    #pprint.pprint(data_string)
    #pprint.pprint(request)

    # Make the HTTP request.
    response = urllib2.urlopen(request, data_string)
    assert response.code == 200

    # Use the json module to load CKAN's response into a dictionary.
    response_dict = json.loads(response.read())
    assert response_dict['success'] is True

    # package_create returns the created package as its result.
    #created_package = response_dict['result']
    #pprint.pprint(created_package)

def main():
    #if len(sys.argv) != 2:
    #    print 'usage: ' + sys.argv[0] + ' bl;ah blah'
    #    sys.exit(1)

    #glob_vars()
    action = sys.argv[1]
    jsonu = sys.argv[2]
    callckan(action, jsonu)

if __name__ == '__main__':
    main()

