#!/bin/bash

cd $(pwd)/python

python create_vocab.py
psql -U ckanuser ckandb -f ../sql/update_tags.sql
psql -U ckanuser ckandb -f ../sql/update_topics.sql
python create_topics.py
python delete_tags.py
psql -U ckanuser ckandb -f ../sql/update_tag_names_to_lowercase.sql

cd ../resources
. get_indicators_list.sh
cd ../python
python toggle_datasets_as_indicators.py

