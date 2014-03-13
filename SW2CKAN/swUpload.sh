#!/bin/bash

CKAN_INSTANCE=http://ckan.megginson.com
CKAN_APIKEY=7ff5802e-b5ca-4b64-8b7f-a74138a28cd4
FILENAME=csv.zip
PACKAGE_ID=the-big-scrape
RESOURCE_ID=eb67a56d-971a-46eb-8027-4aa16e14d3d6

DIRECTORY=`date +'%Y-%m-%d_%H-%M-%S'`
FORMAT=csv
DATE=`date`
DESCRIPTION="Automatic_file_upload_at_"`date | tr ' ' _`

echo $DESCRIPTION

wget --no-check-certificate https://ds-ec2.scraperwiki.com/enf6nmy/8ab0038b6f524ae/http/v1.1/csv.zip -O $FILENAME

curl $CKAN_INSTANCE/api/storage/auth/form/$DIRECTORY/$FILENAME -H Authorization:$CKAN_APIKEY > phase1
curl $CKAN_INSTANCE/storage/upload_handle -H Authorization:$CKAN_APIKEY --form file=@$FILENAME --form "key=$DIRECTORY/$FILENAME" > phase2
curl http://ckan.megginson.com/api/3/action/resource_update \
	--data '{	"package_id":"'$PACKAGE_ID'", 
				"id":"'$RESOURCE_ID'", 
				"url":"'$CKAN_INSTANCE'/storage/f/'$DIRECTORY'/'$FILENAME'", 
				"format":"'$FORMAT'", 
				"name":"'$FILENAME'",
				"description":"'$DESCRIPTION'"}' \
	-H Authorization:$CKAN_APIKEY > phase3