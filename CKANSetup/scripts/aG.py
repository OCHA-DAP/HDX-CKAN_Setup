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
    try:
        jsondata = urllib.quote(json.dumps(send_dict))
        response = urllib2.urlopen(request, jsondata)
        assert response.code == 200
        response_dict = json.loads(response.read())
        assert response_dict['success'] is True
    except:
        print "ERROR!!!"
        print '++++++++++++++++++++++'
        pprint.pprint(ckan_url, api_key, action, send_dict)
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
            geojson_obj = { "key":"hr_info_url","value": geojson }
            extras.append(geojson_obj)
        send_dict['extras'] = extras
    else:
        print myname + ' <ckan_url> <ckan_api_key> <action> <group_id> [group_name] [rw_url] [hr_url] [geojson]'
        print sys.argv
        print len(sys.argv)
        sys.exit(1)

    try:
        # comment the next 3 lines to make the script less verbose
        print '++++++++++++++++++++++'
        pprint.pprint(send_dict)
        print '++++++++++++++++++++++'
        # callckan(ckan_url, api_key, action, jsondata)
        callckan(ckan_url, api_key, action, send_dict)
    except:
        print "Function call error!"
        sys.exit(2)


if __name__ == '__main__':
    main()

