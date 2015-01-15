#!/bin/bash

psql -U ckanuser ckandb -tc "select p.name from package as p, resource as r, resource_group as rg where 
        r.url like '%manage.hdx.rwlabs.org/hdx/api/exporter/indicator%csv' and r.state='active'
    and
        r.resource_group_id=rg.id
    and
        rg.package_id=p.id
    and
        p.private='no'
    order by p.name asc;" \
    | grep -vE "^(\s+)*$" | sed -e 's/^ //' > indicators.txt
