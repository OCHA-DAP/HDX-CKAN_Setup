import requests
import json

server = 'http://localhost:5000'
key = 'f19c12a8-4ed6-4f66-9759-3372cddce8ed'
# run it with indicator = 0 to revert to the old page looks.
indicator = 1


# indicators = ["gini_index",
#              "percentage_of_population_with_access_to_electricity",
#              "gni_per_capita_in_ppp_terms_constant_2005_international",
#              "people_killed_in_disasters",
#              "percentage_of_children_less_than_5_wasted_male"]

f = open('indicators.txt')

base = server + '/api/action/hdx_package_update_metadata'

# for name in indicators:
for name in f:
    name = name.strip()
    print name
    r = requests.post(base, data=json.dumps({'id': name, 'indicator': indicator}),
                      headers={"Authorization": key, 'content-type': 'application/json'}, verify=False)
    print r.text
