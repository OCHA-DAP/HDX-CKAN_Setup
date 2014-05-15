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

. ckanSetup.cfg

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
wget -q --no-check-certificate -O $COUNTRIES_FILE 'https://docs.google.com/spreadsheet/ccc?key=0AoSjej3U9V6fdHJzcWNreF8tVDNXTlpaeXl3Z3h3WWc&output=csv&usp=drive_web&gid=15'
wget -q --no-check-certificate -O $HR_INFO_FILE 'https://docs.google.com/spreadsheets/d/1cM6TY9D5-Yebz3NK1rJnxhN89DsUCs6S9lL5MmjDCSw/export?format=csv&id=1cM6TY9D5-Yebz3NK1rJnxhN89DsUCs6S9lL5MmjDCSw&gid=0'
wget -q --no-check-certificate -O $INDICATORS_FILE "${CPS_URL}/api/exporter/indicatorAllMetadata/csv/language/default/AllIndicatorTypes_metadata.csv"


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
tail -n+2 $COUNTRIES_FILE | ./scripts/csv.sh > $TEMP_COUNTRIES_FILE
echo "Processing indicators csv file"
#indicators file has 2 header lines will skip them
tail -n+2 $INDICATORS_FILE | ./scripts/csv.sh > $TEMP_INDICATORS_FILE

echo "Adding organization HDX"
org_id=hdx
org_name=HDX
. scripts/addOrganization.sh

function add_countries(){
  country_name_extension=$1
  dataset_description=$2
  country_file_name_ext=$3
  country_url_ext=$4
  add_tags=$5

  ckan_source="Multiple Sources"
	ckan_methodology=$6

  echo "Adding countries"
  #Iterate over countries list
  cut -d '|' -f2 ${TEMP_COUNTRIES_FILE} > ${TEMP_COUNTRIES_FILE}.column
  while read -r country;
  do
    country_name=`cat ${TEMP_COUNTRIES_FILE} | grep "|${country}|" | cut -d '|' -f1`
    #echo "Inserting category with code "$country" for "$country_name""
    #convert the group id to lowercase and remove spaces so that CKAN is ok with it
    group_id=`echo $country | tr '[:upper:]' '[:lower:]' | tr -d ' '`
    group_id_ext=`echo $country_name_extension | tr '[:upper:]' '[:lower:]' | tr ' ' '_'`
    if [ "$country_file_name_ext" == "Baseline" ]; then
      group_update="true"
    else
      group_update="false"
    fi

    group_name="$country_name"
    relief_url="http://reliefweb.int/country/"$group_id
    geojson=$group_id
    echo "DOING $country_name"
    . scripts/addGroup.sh

    dataset_id=$group_id"_"$group_id_ext
    dataset_name=$country_name" "$country_name_extension
    #add a country tag so that the dataset is searchable, also strip characters that are not letters, numbers, space, minus or dot
    country_tag=`echo $country_name | sed 's/[^A-Za-z0-9 .-]*//g'`
    if [ "$add_tags" ]; then
      tags="[{\"name\":\""$group_id"\"}, {\"name\":\"baseline\"},{\"name\":\"preparedness\"}]"
    fi
    . scripts/addPackage.sh

    country_code_upper=`echo $country | tr -d ' '`

    resource_name=$country"_"$country_file_name_ext".xlsx"
    resource_url="${CPS_URL}/api/exporter/country${country_url_ext}/xlsx/${country_code_upper}/fromYear/1950/toYear/2014/language/EN/${resource_name}"
    resource_description="Same as dataset description"
    resource_format="xlsx"
    . scripts/addResource.sh

    resource_name=$country"_"$country_file_name_ext".csv"
    resource_url="${CPS_URL}/api/exporter/country${country_url_ext}/csv/${country_code_upper}/fromYear/1950/toYear/2014/language/EN/${resource_name}"
    resource_description="Same as dataset description"
    resource_format="csv"
    . scripts/addResource.sh

    resource_name=$country"_Readme.txt"
    resource_url="${CPS_URL}/api/exporter/country${country_url_ext}/readme/${country_code_upper}/language/EN/${resource_name}"
    resource_description="Supporting information for the accompanying CSV file"
    resource_format="txt"
    . scripts/addResource.sh

  done < ${TEMP_COUNTRIES_FILE}.column
  tags=
  ckan_source=
}

#DON'T Change order - Group update will happen just for the first run since it will override existing datasets if it's run afterwards!
add_countries "Baseline Data" "A compilation of time-series data from a variety of sources reported at the national level. Additional information about the sources is available in the file." "Baseline" "" "yes" "Other : Varies, see files"
add_countries "RW indicators" "ReliefWeb indicators reported at the national level." "RW" "RW" '' "The indicators in this dataset were built from data extracted from the ReliefWeb API"
add_countries "FTS indicators" "Selected indicators from the Financial Tracking System reported at the national level." "FTS" "FTS" '' "The indicators in this dataset were built from data provided by the Financial Tracking Service (FTS) run by UNOCHA. FTS compiles the funding data based on information that is self-reported by donors and receiving organizations."

#Create group for indicators
group_id=world
group_name=World
relief_url=   #not using
geojson=   #not using
. scripts/addGroup.sh

function add_new_indicators(){
  file_name=$1
  indicator_file_name_ext=$2
  indicator_url_ext=$3

  echo "Adding indicators"
  #Iterate over indicators list
  #cut -d '|' -f2 $file_name > $file_name.column
  while read -r -u9 line;
  do
    #getting indicator metadata
    indicator_meta=`echo $line | sed "s/\;/ /g" | sed "s/\"/'/g"`

    ckan_source=`echo $indicator_meta | cut -d '|' -f5`
    ckan_license=`echo $indicator_meta | cut -d '|' -f14`
    ckan_date_min=`echo $indicator_meta | cut -d '|' -f11`
    ckan_date_max=`echo $indicator_meta | cut -d '|' -f12`
    ckan_methodology="`echo $indicator_meta | cut -d '|' -f10`"
    ckan_caveats=`echo $indicator_meta | cut -d '|' -f13`
    # echo "Row: "$indicator_meta
    # echo "Source:"$ckan_source
    # echo "Meth:"$ckan_methodology
    # echo "Caveats:"$ckan_caveats

    #convert all upper chars to lower; then convert space into "_"; then remove all characters except a-z,0-9,"-" and "_"; then replace "__" with "_"
    indicator=`echo $line | cut -d '|' -f2`
    dataset_id=`echo $indicator | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | sed 's/[^a-z0-9_-]*//g' | sed "s/__/_/g" | sed 's:_$::'`
    #Theoretically there shouldn't be overlapping indicators from different sources now
    #dataset_id_ext=`echo $indicator_file_name_ext | tr '[:upper:]' '[:lower:]' | tr ' ' '_'`
    #dataset_id=$dataset_id"_"$dataset_id_ext
    dataset_name=`echo $indicator | sed 's/\&/ and /g'`
    echo "Dataset name:"$dataset_name
    dataset_description="" #manually placed
    tags="" #manually placed
    #echo "Inserting indicator with code "$dataset_id" for "$dataset_name""
   . scripts/addPackage.sh

    #preparing to add resources
    indicator_type=`echo $line | cut -d '|' -f1`
    echo "Indicator type is:"$indicator_type" and indicator: |"$indicator"|"
    source_code=`echo $line | cut -d '|' -f3`
    #Adding resources

    # no csv file for now
    # resource_url="${CPS_URL}/api/exporter/indicatorMetadata${indicator_url_ext}/csv/${indicator_type}/language/en/${indicator_type}_baseline.csv"
    # resource_name=$indicator_type"_"$indicator_file_name_ext".csv"
    # resource_description="Same as dataset description"
    # resource_format="csv"
    # . scripts/addResource.sh

    #add readme file
    if [ "$indicator_file_name_ext" == "RW" ]; then
      #RW
      xls_resource_url_start="${CPS_URL}/api/exporter/indicator${indicator_url_ext}/xlsx"
      csv_resource_url_start=""
      rdm_resource_url_start="${CPS_URL}/api/exporter/indicator${indicator_url_ext}/readme"
    else
      if [ "$indicator_file_name_ext" == "FTS" ]; then
        #FTS
        xls_resource_url_start="${CPS_URL}/api/exporter/indicator${indicator_url_ext}/xlsx"
        csv_resource_url_start=""
        rdm_resource_url_start="${CPS_URL}/api/exporter/indicator${indicator_url_ext}/readme"
      else
        if [ "$indicator_file_name_ext" == "UNHCR" ]; then
          #UNHCR
          xls_resource_url_start="${CPS_URL}/api/exporter/indicator${indicator_url_ext}/xlsx"
          csv_resource_url_start=""
          rdm_resource_url_start="${CPS_URL}/api/exporter/indicator${indicator_url_ext}/readme"
        else
          #SW
          xls_resource_url_start="${CPS_URL}/api/exporter/indicator${indicator_url_ext}/xlsx/${indicator_type}/source/${source_code}"
          csv_resource_url_start="${CPS_URL}/api/exporter/indicator${indicator_url_ext}/csv/${indicator_type}/source/${source_code}"
          rdm_resource_url_start="${CPS_URL}/api/exporter/indicator${indicator_url_ext}/readme/${indicator_type}/source/${source_code}"
        fi
      fi
    fi

    if [ "$xls_resource_url_start" ]; then
      resource_name=$indicator_type"_"$indicator_file_name_ext".xlsx"
      resource_url="${xls_resource_url_start}/fromYear/1950/toYear/2014/language/en/${resource_name}"
      resource_description="Same as dataset description"
      resource_format="xlsx"
      . scripts/addResource.sh
    fi
    if [ "$csv_resource_url_start" ]; then
      resource_name=$indicator_type"_"$indicator_file_name_ext".csv"
      resource_url="${csv_resource_url_start}/fromYear/1950/toYear/2014/language/en/${resource_name}"
      resource_description="Same as dataset description"
      resource_format="csv"
      . scripts/addResource.sh
    fi
    if [ "$rdm_resource_url_start" ]; then
			resource_name=$indicator_type"_Readme.txt"
      resource_url="${rdm_resource_url_start}/language/EN/${resource_name}"
      resource_description="Supporting information for the accompanying CSV file"
      resource_format="txt"
      . scripts/addResource.sh
    fi

  done 9<${file_name}

  ckan_source=
  ckan_license=
  ckan_date_min=
  ckan_date_max=
  ckan_methodology=
  ckan_caveats=

}

cat $TEMP_INDICATORS_FILE | grep "|RW|" > $TEMP_INDICATORS_FILE.rw
cat $TEMP_INDICATORS_FILE | grep "|fts|" > $TEMP_INDICATORS_FILE.fts
cat $TEMP_INDICATORS_FILE | grep -v "|RW|\||fts|" > $TEMP_INDICATORS_FILE.other

add_new_indicators "${TEMP_INDICATORS_FILE}.rw" "RW" "RW"
add_new_indicators "${TEMP_INDICATORS_FILE}.fts" "FTS" "FTS"
add_new_indicators "${TEMP_INDICATORS_FILE}.other" "Baseline" ""

echo "Adding package Raw ScraperWiki Input"
dataset_id=raw-scraperwiki-input
dataset_name="Raw ScraperWiki Input"
tags='[]'
. scripts/addPackage.sh
#add a fake resource to it
resource_url="http://test.com"
resource_name="csv.zip"
resource_format="csv"
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
