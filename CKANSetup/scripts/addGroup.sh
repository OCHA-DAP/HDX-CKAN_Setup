#!/bin/bash

#Variables needed by script and example data:
#group_id=AFG
#group_name=Afghanistan

#error string that's used to check for errors
ERROR_GREP="\"success\": false\|Bad request - JSON Error"

#Check if group exists or we need to create it
action=group_show
action_file=$LOG_FOLDER/tmp_$action.$group_id.log
curl -s $CKAN_INSTANCE/api/3/action/$action \
	--data '{	"id":"'$group_id'" }' \
	-H Authorization:$CKAN_APIKEY > $action_file
result=`cat $action_file | grep "$ERROR_GREP"`
if [ -z "$result" ]; then
	echo "Group "$group_id" exists!"
else
	echo "Creating group "$group_id"..."
	action=group_create
	action_file=$LOG_FOLDER/tmp_$action.$group_id.log
	curl -s $CKAN_INSTANCE/api/3/action/$action \
		--data '{	"id":"'"$group_id"'",
					"name":"'"$group_id"'",
					"title":"'"$group_name"'" 
				}' \
		-H Authorization:$CKAN_APIKEY > $action_file
	result=`cat $action_file | grep "$ERROR_GREP"`
	if [ "$result" ]; then
		echo "<<<ERROR while executing action "$action" on group "$group_id" with name: "$group_name
	fi
fi