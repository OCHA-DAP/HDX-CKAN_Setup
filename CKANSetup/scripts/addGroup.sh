#!/bin/bash

#Variables needed by script and example data:
#group_id=AFG
#group_name=Afghanistan
#relief_url=http://reliefweb.int/country/afg
#geojson=afg

#error string that's used to check for errors
ERROR_GREP="\"success\": false\|Bad request - JSON Error"


#build extra_json if we have data
extra_json=""
if [ "$relief_url" ]; then
	extra_json=$extra_json", \"relief_web_url\":\""$relief_url"\""
fi
if [ "$geojson" ]; then
	#getting the geojson for the country id in $geojson
	action=geojson #just for log name
	action_file=$LOG_FOLDER/tmp_$action.$group_id.log
	curl -s -H "Content-Type: application/json" https://exversion.com/api/v1/dataset \
			--data '{	
				"key":"dbc50657c7",
				"merge":1,
				"query": [{"dataset":"AGMCAZMGC6UF916", "params":{"properties.name":"'"$geojson"'"}}],
				"_limit": 1
				}' > $action_file
	geojson_result=`cat $action_file`
	substring=""
	start=`echo "$geojson_result" | sed -n "s/\"body\".*//p" | wc -c`
	start=$[start+7]
	end=${#geojson_result}
	end=$[end-start-2]
	geojson_result=${geojson_result:$start:$end}
	#geojson_result=${geojson_result//'"'/'\"'}
	if [ "$geojson_result" ]; then
		extra_json=$extra_json", \"geojson\":"$geojson_result
	fi
	#echo $extra_json
fi

#Check if group exists or we need to create it
action=group_show
action_file=$LOG_FOLDER/tmp_$action.$group_id.log
curl -s $CKAN_INSTANCE/api/3/action/$action \
	--data '{	"id":"'$group_id'" }' \
	-H Authorization:$CKAN_APIKEY > $action_file
result=`cat $action_file | grep "$ERROR_GREP"`
if [ -z "$result" ]; then
	echo "Group "$group_id" exists! Updating ..."
	action=group_update
else
	echo "Creating group "$group_id"..."
	action=group_create
fi

echo "$extra_json"
action_file=$LOG_FOLDER/tmp_$action.$group_id.log
curl -s --http1.0 -H  "Content-Type: application/json" $CKAN_INSTANCE/api/3/action/$action \
	--data '{	"id":"'"$group_id"'",
				"name":"'"$group_id"'",
				"title":"'"$group_name"'"
				'"$extra_json"'
			}' \
	-H Authorization:$CKAN_APIKEY > $action_file
result=`cat $action_file | grep "$ERROR_GREP"`
if [ "$result" ]; then
	echo "<<<ERROR while executing action "$action" on group "$group_id" with name: "$group_name
fi
