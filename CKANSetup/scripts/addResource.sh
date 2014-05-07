#!/bin/bash

#Variables needed by script and example data:
#dataset_id=AFG
#resource_url=http://.....
#resource_name=...
#resource_format=xlsx
#resource_description=...

#error string that's used to check for errors
ERROR_GREP="\"success\": false\|Bad request - JSON Error"

#No need to check if resource exits, will be deleted by ckan on update

#create resource
action=resource_create
action_file=$LOG_FOLDER/tmp_$action.$dataset_id.log
curl -s $CKAN_INSTANCE/api/3/action/$action \
	--data '{	'"$extra_json"'
				"package_id":"'"$dataset_id"'",
				"url":"'"$resource_url"'",
				"name":"'"$resource_name"'",
				"format":"'"$resource_format"'",
				"description":"'"$resource_description"'",
				"id":"'"$resource_name"'"
			}' \
	-H Authorization:$CKAN_APIKEY > $action_file
result=`cat $action_file | grep "$ERROR_GREP"`
if [ "$result" ]; then
	echo "<<<ERROR while executing action "$action" on dataset "$dataset_id" with name: "$dataset_name
fi
