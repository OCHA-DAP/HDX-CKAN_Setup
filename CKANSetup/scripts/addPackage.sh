#!/bin/bash

#Variables needed by script and example data:
#dataset_id=AFG 
#dataset_name=AFG Baseline Data
#tags='[{"name":"AFG"}, {"name":"Afghanistan"}, {"name":"baseline"},{"name":"preparedness"}]'
#group_id=AFG

#error string that's used to check for errors
ERROR_GREP="\"success\": false\|Bad request - JSON Error"

#Check if package exists or we need to create it
action=package_show
action_file=$LOG_FOLDER/tmp_$action.$dataset_id.log
#see if the package already exists
curl -s $CKAN_INSTANCE/api/3/action/$action \
	--data '{	"id":"'$dataset_id'" }' \
	-H Authorization:$CKAN_APIKEY > $action_file
result=`cat $action_file | grep "$ERROR_GREP"`
if [ -z "$result" ]; then
	echo "Dataset "$dataset_id" exists! Updating ..."
    action=package_update
    extra_json="\"id\":\"$dataset_id\","
else
	echo "Not found dataset "$dataset_id"! Creating ..."
	action=package_create
	extra_json=""
fi

#create package
#action is set in the previous step
action_file=$LOG_FOLDER/tmp_$action.$dataset_id.log
curl -s $CKAN_INSTANCE/api/3/action/$action \
	--data '{	'"$extra_json"'
				"name":"'"$dataset_id"'",
				"title":"'"$dataset_name"'", 
				"state":"active",
				"tags":'"$tags"',
				"groups":[{"id":"'"$group_id"'"}]				 
			}' \
	-H Authorization:$CKAN_APIKEY > $action_file
result=`cat $action_file | grep "$ERROR_GREP"`
if [ "$result" ]; then
	echo "<<<ERROR while executing action "$action" on dataset "$dataset_id" with name: "$dataset_name
fi

echo "Done adding/updating dataset "$dataset_id" with title: "$dataset_name
