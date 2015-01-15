import requests
import json

server = 'http://localhost:5000'
key = 'f19c12a8-4ed6-4f66-9759-3372cddce8ed'
# run it with indicator = 0 to revert to the old page looks.
<<<<<<< HEAD
indicator = 1


# indicators = ["gini_index",
=======
flag = 1

#indicators = ["gini_index",
>>>>>>> branch 'master' of https://github.com/OCHA-DAP/HDX-CKAN_Setup.git
#              "percentage_of_population_with_access_to_electricity",
#              "gni_per_capita_in_ppp_terms_constant_2005_international",
#              "people_killed_in_disasters",
#              "percentage_of_children_less_than_5_wasted_male"]

indicators = open('../resources/indicators.txt')
non_indicators = open('../resources/non_indicators.txt')
non_indicators = map(lambda s: s.strip(), non_indicators)
base = server + '/api/action/hdx_package_update_metadata'

<<<<<<< HEAD
# for name in indicators:
for name in f:
    name = name.strip()
    print name
    r = requests.post(base, data=json.dumps({'id': name, 'indicator': indicator}),
                      headers={"Authorization": key, 'content-type': 'application/json'}, verify=False)
    print r.text
=======
#for name in indicators:
for indicator in indicators:
    indicator = indicator.strip()
    # print indicator
    if indicator in non_indicators:
        flag = 0
    else:
        flag = 1
    # r = requests.post(base, data=json.dumps({'id': indicator, 'indicator': flag}),
    #                   headers={"Authorization": key, 'content-type': 'application/json'}, verify=False)
    # print r.text
    print flag, indicator
>>>>>>> branch 'master' of https://github.com/OCHA-DAP/HDX-CKAN_Setup.git
