#!/bin/bash

#CKAN_INSTANCE=
#CKAN_APIKEY=
FILENAME=csv.zip
PACKAGE_ID=raw-scraperwiki-input
RAW_SW_RESOURCE_ID_FILE=raw-sw-resource-id.txt

RESOURCE_ID=`cat $RAW_SW_RESOURCE_ID_FILE | tr -d '"'`

DIRECTORY=`date +'%Y-%m-%d_%H-%M-%S'`
FORMAT=csv
DATE=`date`
DESCRIPTION="Automatic_file_upload_at_"`date | tr ' ' _`

echo $DESCRIPTION

wget --no-check-certificate https://ds-ec2.scraperwiki.com/enf6nmy/8ab0038b6f524ae/http/v1.1/csv.zip -O $FILENAME

curl $CKAN_INSTANCE/api/storage/auth/form/$DIRECTORY/$FILENAME -H Authorization:$CKAN_APIKEY > phase1
curl $CKAN_INSTANCE/storage/upload_handle -H Authorization:$CKAN_APIKEY --form file=@$FILENAME --form "key=$DIRECTORY/$FILENAME" > phase2
curl $CKAN_INSTANCE/api/3/action/resource_update \
	--data '{	"package_id":"'$PACKAGE_ID'",
				"id":"'$RESOURCE_ID'",
				"url":"'$CKAN_INSTANCE'/storage/f/'$DIRECTORY'/'$FILENAME'",
				"format":"'$FORMAT'",
				"name":"'$FILENAME'",
				"description":"'$DESCRIPTION'"}' \
	-H Authorization:$CKAN_APIKEY > phase3
