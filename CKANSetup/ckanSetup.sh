#!/bin/bash

#Import config

#get countries file like this
#   https://docs.google.com/feeds/download/spreadsheets/Export?key=0AoSjej3U9V6fdHJzcWNreF8tVDNXTlpaeXl3Z3h3WWc&exportFormat=csv&gid=15

#get indicator file like this
#	https://docs.google.com/feeds/download/spreadsheets/Export?key=0AoSjej3U9V6fdHJzcWNreF8tVDNXTlpaeXl3Z3h3WWc&usp=sharing&gid=16&exportFormat=csv
# 	(original doc) https://docs.google.com/spreadsheets/d/1cM6TY9D5-Yebz3NK1rJnxhN89DsUCs6S9lL5MmjDCSw/edit#gid=0

#Importer config properties
LOG_FOLDER=log
COUNTRIES_FILE=countries.csv
INDICATORS_FILE=indicators.csv
HR_INFO_FILE=hr-info.csv
RAW_SW_RESOURCE_ID_FILE=raw-sw-resource-id.txt
#CKAN config
#CKAN_INSTANCE=
#CKAN_APIKEY=
#CPS_URL=

#internal config
TEMP_COUNTRIES_FILE=processed_countries.csv
TEMP_INDICATORS_FILE=processed_indicators.csv
 #set internal field separator to new line so that for will behave as expected

#put processed files into the log folder
TEMP_COUNTRIES_FILE=$LOG_FOLDER/$TEMP_COUNTRIES_FILE
TEMP_INDICATORS_FILE=$LOG_FOLDER/$TEMP_INDICATORS_FILE

#checking if the ckan instance is present
if [ ! "$CKAN_INSTANCE" ]; then
	echo "Please edit the script and add the URL to CKAN in the CKAN_INSTANCE variable!"
	exit;
fi

#checking if the api key is present
if [ ! "$CKAN_APIKEY" ]; then
	echo "Please edit the script and add the api key in the CKAN_APIKEY variable!"
	exit;
fi

#download the latest csv files by exporting them from Google Docs
wget -q --no-check-certificate -O countries.csv 'https://docs.google.com/spreadsheet/ccc?key=0AoSjej3U9V6fdHJzcWNreF8tVDNXTlpaeXl3Z3h3WWc&output=csv&usp=drive_web&gid=15'
wget -q --no-check-certificate -O indicators.csv 'https://docs.google.com/spreadsheet/ccc?key=0AoSjej3U9V6fdHJzcWNreF8tVDNXTlpaeXl3Z3h3WWc&output=csv&usp=drive_web&gid=16'
wget -q --no-check-certificate -O hr-info.csv 'https://docs.google.com/spreadsheets/d/1cM6TY9D5-Yebz3NK1rJnxhN89DsUCs6S9lL5MmjDCSw/export?format=csv&id=1cM6TY9D5-Yebz3NK1rJnxhN89DsUCs6S9lL5MmjDCSw&gid=0'

#Test to see if the import files exist
csv_files_not_found=false
if [ ! -f "$COUNTRIES_FILE" ]
then
    echo "Countries file $COUNTRIES_FILE does not exists, please get the latest version using this link: "
    echo "    https://docs.google.com/feeds/download/spreadsheets/Export?key=0AoSjej3U9V6fdHJzcWNreF8tVDNXTlpaeXl3Z3h3WWc&exportFormat=csv&gid=15"
    csv_files_not_found=true
fi
if [ ! -f "$INDICATORS_FILE" ]
then
    echo "Indicators file $INDICATORS_FILE does not exists, please get the latest version using this link: "
    echo "    https://docs.google.com/feeds/download/spreadsheets/Export?key=0AoSjej3U9V6fdHJzcWNreF8tVDNXTlpaeXl3Z3h3WWc&usp=sharing&gid=16&exportFormat=csv"
    csv_files_not_found=true
fi
if [ ! -f "$HR_INFO_FILE" ]
then
    echo "HR.info file $HR_INFO_FILE does not exists, please get the latest version using this link: "
    echo "    https://docs.google.com/feeds/download/spreadsheets/Export?key=1cM6TY9D5-Yebz3NK1rJnxhN89DsUCs6S9lL5MmjDCSw&usp=sharing&gid=0&exportFormat=csv"
    csv_files_not_found=true
fi

if $csv_files_not_found; then
	exit;
fi

#Clear logs
mkdir $LOG_FOLDER
echo "Clearing logs folder, in case it exists..."
rm $LOG_FOLDER/*

#process csv's
echo "Processing countries csv file"
#countries file has 1 header line, skipping it
tail -n+2 $COUNTRIES_FILE | ./scripts/csv.sh | grep "|y|" > $TEMP_COUNTRIES_FILE
echo "Processing indicators csv file"
#indicators file has 2 header lines will skip them
tail -n+2 $INDICATORS_FILE | ./scripts/csv.sh | grep "y|" > $TEMP_INDICATORS_FILE

echo "Adding organization HDX"
org_id=hdx
org_name=HDX
. scripts/addOrganization.sh


echo "Adding countries"
#Iterate over countries list
cut -d '|' -f2 ${TEMP_COUNTRIES_FILE} > ${TEMP_COUNTRIES_FILE}.column
while read -r country;
do
	country_name=`cat ${TEMP_COUNTRIES_FILE} | grep "|${country}|" | cut -d '|' -f1`
	#echo "Inserting category with code "$country" for "$country_name""
	#convert the group id to lowercase and remove spaces so that CKAN is ok with it
	group_id=`echo $country | tr '[:upper:]' '[:lower:]' | tr -d ' '`
	group_name="$country_name"
	relief_url="http://reliefweb.int/country/"$group_id
	geojson=$group_id
	echo "DOING $country_name"
	. scripts/addGroup.sh

	dataset_id=$group_id"_baseline_data"
	dataset_name=$country_name" Baseline Data"
	#add a country tag so that the dataset is searchable, also strip characters that are not letters, numbers, space, minus or dot
	country_tag=`echo $country_name | sed 's/[^A-Za-z0-9 .-]*//g'`
	tags='[{"name":"'"$group_id"'"}, {"name":"'"$country_tag"'"}, {"name":"baseline"},{"name":"preparedness"}]'
	. scripts/addPackage.sh

	country_code_upper=`echo $country | tr -d ' '`
	resource_url="${CPS_URL}/api/exporter/country/xlsx/${country_code_upper}/fromYear/1950/toYear/2014/language/EN/${country_code_upper}_baseline.xlsx"
	resource_name=$country"_Baseline.xlsx"
	. scripts/addResource.sh
done < ${TEMP_COUNTRIES_FILE}.column

#Create group for indicators
group_id=world
group_name=World
relief_url=   #not using
geojson=   #not using
. scripts/addGroup.sh

echo "Adding indicators"
#Iterate over indicators list
cut -d '|' -f2 ${TEMP_INDICATORS_FILE} > ${TEMP_INDICATORS_FILE}.column
while read -r indicator;
do
	#convert all upper chars to lower; then convert space into "_"; then remove all characters except a-z,0-9,"-" and "_"; then replace "__" with "_"
	dataset_id=`echo $indicator | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | sed 's/[^a-z0-9_-]*//g' | sed "s/__/_/g" | sed 's:_$::'`
	dataset_name=$indicator
	tags='[{"name":"baseline"},{"name":"preparedness"}]'
	#echo "Inserting indicator with code "$dataset_id" for "$dataset_name""
	. scripts/addPackage.sh

	indicator_type=`cat ${TEMP_INDICATORS_FILE} | grep "|${indicator}" | cut -d '|' -f3`
  echo "Indicator type is:"$indicator_type" and indicator: |"$indicator"|"
	source_code=`cat ${TEMP_INDICATORS_FILE} | grep "|${indicator}" | cut -d '|' -f4`
	resource_url="${CPS_URL}/api/exporter/indicator/xlsx/${indicator_type}/source/${source_code}/fromYear/1950/toYear/2014/language/en/${indicator_type}_baseline.xlsx"
	resource_name=$indicator_type"_Baseline.xlsx"
	. scripts/addResource.sh
done < ${TEMP_INDICATORS_FILE}.column

echo "Adding package Raw ScraperWiki Input"
dataset_id=raw-scraperwiki-input
dataset_name="Raw ScraperWiki Input"
tags='[]'
. scripts/addPackage.sh
#add a fake resource to it
resource_url="http://test.com"
resource_name="cvs.zip"
. scripts/addResource.sh
new_resource_log=`cat $action_file`
start=`echo "$new_resource_log" | sed -n "s/\"id\":.*//p" | wc -c`
start=$[start+5]
end=38
new_resource_id=${new_resource_log:$start:$end}
echo "New resource id is: "$new_resource_id
echo "$new_resource_id" > $RAW_SW_RESOURCE_ID_FILE


#move processed files in the log folder and force user to reload the csv's on next run
mv $COUNTRIES_FILE $LOG_FOLDER/
mv $INDICATORS_FILE $LOG_FOLDER/
mv $HR_INFO_FILE $LOG_FOLDER/

run_date=`date +'%Y-%m-%d_%H-%M-%S'`
mv $LOG_FOLDER $LOG_FOLDER.$run_date
