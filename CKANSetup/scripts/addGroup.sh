#!/bin/bash

#Variables needed by script and example data:
#group_id=afg
#group_name=Afghanistan
#relief_url=http://reliefweb.int/country/afg #(optional)
#geojson=afg #(optional)
#"extras":[ {"key":"geojson","value":"blah"}, {"key":"hr_info_url", "value":"whatever"}]
#error string that's used to check for errors
ERROR_GREP="\"success\": false\|Bad request - JSON Error"

# vars to be sent directly to python
PY_rw_url='NONE'
PY_hr_url='NONE'
PY_geojson='NONE'

if [ "$relief_url" ]; then
    PY_rw_url="$relief_url"
    #if we have the requiest to put in the relief web url then we also need to put in the HR.info link
    hrinfo=`cat $HR_INFO_FILE | ./scripts/csv.sh | grep -i "$group_id|" | cut -d '|' -f10`
    if [ "$hrinfo" ]; then
        PY_hr_url="$hrinfo"
    fi
fi

if [ "$geojson" ]; then
    #getting the geojson for the country id in $geojson
    action=geojson #just for log name
    action_file=$LOG_FOLDER/tmp_$action.$group_id.log
    curl -s -H "Content-Type: application/json" https://exversion.com/api/v1/dataset \
	    --data '{	
		"key":"dbc50657c7",
		"merge":1,
		"query": [{"dataset":"AGMCAZMGC6UF916", "params":{"id":"'$geojson'"}}],
		"_limit": 1
		}' > $action_file
    geojson_result=`cat $action_file`
    substring=""
    start=`echo "$geojson_result" | sed -n "s/\"body\".*//p" | wc -c`
    start=$[start+7]
    end=${#geojson_result}
    end=$[end-start-2]
    geojson_result=${geojson_result:$start:$end}

    secondResult=`echo "$geojson_result" | sed -n "s/},{.*//p" | wc -c`
    if [ $secondResult -gt 0 ]; then
	   geojson_result=${geojson_result:0:$secondResult}
    fi


    #geojson_result=${geojson_result//'"'/'\"'}
    if [ "$geojson_result" ]; then
        PY_geojson="$geojson_result"
    fi
fi

#Check if group exists or we need to create it
action=group_show
action_file=$LOG_FOLDER/tmp_$action.$group_id.log

python scripts/aG.py "$CKAN_INSTANCE" "$CKAN_APIKEY" "$action" "$group_id"

if [ $? -eq 0 ]; then
    echo "Group "$group_id" exists! Updating ..."
    action=group_update
else
    echo "Creating group "$group_id"..."
    action=group_create
fi

python scripts/aG.py "$CKAN_INSTANCE" "$CKAN_APIKEY" "$action" "$group_id" "$group_name" "$PY_rw_url" "$PY_hr_url" "$PY_geojson"

if [ $? -ne 0 ]; then
    echo "Failure."
else
    echo "Completed successfully."
fi

if [ -f $action_file ]; then
    result=`cat $action_file | grep "$ERROR_GREP"`
    if [ "$result" ]; then
        echo "<<<ERROR while executing action "$action" on group "$group_id" with name: "$group_name
    fi    
fi
