#!/usr/bin/python
import sys
import urllib2
import urllib
import json
import pprint

def callckan(ckan_url, api_key, action, send_dict):
    thisurl = ckan_url + '/api/3/action/' + action
    request = urllib2.Request(thisurl)
    request.add_header('Authorization', api_key)
    # uncomment the next 5 lines below to make the output verbose
    # print '++++++++++++++++++++++'
    # print 'trying:'
    # print(ckan_url, api_key, action)
    # pprint.pprint(send_dict)
    # print '++++++++++++++++++++++'
    try:
        jsondata = urllib.quote(json.dumps(send_dict))
        response = urllib2.urlopen(request, jsondata)
        assert response.code == 200
        response_dict = json.loads(response.read())
        assert response_dict['success'] is True
    except:
        print "ERROR!!!"
        print '++++++++++++++++++++++'
        pprint.pprint(ckan_url, api_key, action)
        pprint.pprint(send_dict)
        print '++++++++++++++++++++++'
        sys.exit(1)


def main():
    myname = sys.argv.pop(0)
    if len(sys.argv) == 4:
        ckan_url, api_key, action, group_id = sys.argv
        send_dict = {
            "id": group_id,
            "name": group_id
         }
    elif len(sys.argv) == 8:
        ckan_url, api_key, action, group_id, group_name, rw_url, hr_url, geojson = sys.argv
        send_dict = {
            "id": group_id,
            "name": group_id,
            "title": group_name
        }
        extras = []
        if rw_url != "NONE":
            rw_obj = { "key":"relief_web_url","value": rw_url }
            extras.append(rw_obj)
        if hr_url != "NONE":
            hr_obj = { "key":"hr_info_url","value": hr_url }
            extras.append(hr_obj)
        if geojson != "NONE":
            geojson_json = json.loads(geojson)
            geojson_json['properties']['url']="/group/"+group_id
            geojson_obj = { "key":"geojson","value": json.dumps(geojson_json) }
            extras.append(geojson_obj)
        if len(extras) == 0 and action == 'group_update':
            print 'No additional info to update... Skipping...'
            sys.exit(0)
        send_dict['extras'] = extras
    else:
        print myname + ' <ckan_url> <ckan_api_key> <action> <group_id> [group_name] [rw_url] [hr_url] [geojson]'
        print sys.argv
        print len(sys.argv)
        sys.exit(1)
    callckan(ckan_url, api_key, action, send_dict)


if __name__ == '__main__':
    main()

