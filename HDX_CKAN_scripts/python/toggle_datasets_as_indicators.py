import requests
import json

server = 'http://localhost:9221'
key = 'keytochange'
# run it with indicator = 0 to revert to the old page looks.
flag = 1

#indicators = ["gini_index",
#              "percentage_of_population_with_access_to_electricity",
#              "gni_per_capita_in_ppp_terms_constant_2005_international",
#              "people_killed_in_disasters",
#              "percentage_of_children_less_than_5_wasted_male"]

indicators = open('../resources/indicators.txt')
non_indicators = open('../resources/non_indicators.txt')
non_indicators = map(lambda s: s.strip(), non_indicators)
base = server + '/api/action/hdx_package_update_metadata'

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
