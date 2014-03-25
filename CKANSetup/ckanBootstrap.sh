#!/bin/bash

current_path=$(pwd);

function prepare_for_paster() {
	cd /usr/lib/ckan/default;
	. bin/activate
	cd src/ckan;	
}

function clean_ckan_db() {
	paster db clean -c /etc/ckan/default/production.ini
}

function initialize_ckan_db() {
	paster db clean -c /etc/ckan/default/production.ini	
}

function create_ckan__users() {
	for user in user1 user2: do
		paster user add $user password="123456" email="me@me.me" -c /etc/ckan/default/production.ini
		paster sysadmin add $user
	done
}

function assign_ckan_users_as_admins() {
	for user in user1 user2: do
		paster sysadmin add $user
	done
}

# clean ckan db and reinitialize it.
prepare_for_paster;
clean_ckan_db;
initialize_ckan_db;
create_ckan__users;
assign_ckan_users_as_admins;

# run arti's scripts
cd $current_path
./ckanSetup.sh
