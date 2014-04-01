#!/bin/bash

#Variables needed by script and example data:
#org_id=
#org_name=...

#error string that's used to check for errors
ERROR_GREP="\"success\": false\|Bad request - JSON Error"

#No need to check if resource exits, will be deleted by ckan on update

#create resource
action=organization_create
action_file=$LOG_FOLDER/tmp_$action.$org_id.log
curl -s $CKAN_INSTANCE/api/3/action/$action \
	--data '{
				"id":"'"$org_id"'",
				"name":"'"$org_id"'",
				"title":"'"$org_name"'"
			}' \
	-H Authorization:$CKAN_APIKEY > $action_file
result=`cat $action_file | grep "$ERROR_GREP"`
if [ "$result" ]; then
	echo "<<<ERROR while executing action "$action" on dataset "$org_id" with name: "$org_name
fi
