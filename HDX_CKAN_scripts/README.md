```
#!/bin/bash
cd python
python create_vocab.py
psql -U ckanuser ckandb -f ../sql/update_tags.sql
psql -U ckanuser ckandb -f ../sql/update_topics.sql
python create_topics.py
python delete_tags.py
psql -U ckanuser ckandb -f ../sql/update_tag_names_to_lowercase.sql
```
and / or

```
#!/bin/bash
cd resources
bash get_indicators_list.sh
cd ../python
python toggle_datasets_as_indicators.py
```


## Creating DataStores
The [create_datastore.py](python/create_datastore.py) script takes two arguments as input: (1) a JSON file with the schema of the DataStore to be created and (2) a CKAN API key. The JSON schema file should take the following form:

```json
[{
  "resource_id": "RESOURCE_ID",
  "schema": {
    "fields": [
        { "id": "month", "type": "text" }, 
        { "id": "num_refugees", "type": "integer" }, 
        { "id": "period", "type": "text" }
    ]
  },
  "indexes": [],
  "primary_key": []
},
...
]
```
Note that the JSON file has to contain an array of JSON objects. This happens in case you would like to create a DataStore for multiple resources instead of one.

The script depends on the `ckanapi` package.