update tag set vocabulary_id = (select id from vocabulary where name = 'Topics') where name = 'economy';

update package_tag set tag_id = (select id from tag where name = 'education') where tag_id = (select id from tag where name = 'Education');
update package_tag_revision set tag_id = (select id from tag where name = 'education') where tag_id = (select id from tag where name = 'Education');
update tag set vocabulary_id = (select id from vocabulary where name = 'Topics') where name = 'education';


update package_tag set tag_id = (select id from tag where name = 'telecommunication') where tag_id = (select id from tag where name = 'emergency');
update package_tag_revision set tag_id = (select id from tag where name = 'telecommunication') where tag_id = (select id from tag where name = 'emergency');
update package_tag set tag_id = (select id from tag where name = 'telecommunication') where tag_id = (select id from tag where name = 'Telecommunication');
update package_tag_revision set tag_id = (select id from tag where name = 'telecommunication') where tag_id = (select id from tag where name = 'Telecommunication');	
update tag set vocabulary_id = (select id from vocabulary where name = 'Topics') where name = 'telecommunication';
update tag set name = 'emergency telecommunications' where name = 'telecommunication';

update package_tag set tag_id = (select id from tag where name = 'food') where tag_id = (select id from tag where name = 'nutrition');
update package_tag_revision set tag_id = (select id from tag where name = 'food') where tag_id = (select id from tag where name = 'nutrition');
update tag set vocabulary_id = (select id from vocabulary where name = 'Topics') where name = 'food';
update tag set name = 'food and nutrition' where name = 'food';

update tag set vocabulary_id = (select id from vocabulary where name = 'Topics') where name = 'gender';

update package_tag set tag_id = (select id from tag where name = 'health') where tag_id = (select id from tag where name = 'Health');
update package_tag_revision set tag_id = (select id from tag where name = 'health') where tag_id = (select id from tag where name = 'Health');
update tag set vocabulary_id = (select id from vocabulary where name = 'Topics') where name = 'health';

update tag set vocabulary_id = (select id from vocabulary where name = 'Topics') where name = 'humanitarian finance';
	update tag set name = 'humanitarian funding' where name = 'humanitarian finance';

update package_tag set tag_id = (select id from tag where name = 'logistics') where tag_id = (select id from tag where name = 'Logistics');
update package_tag_revision set tag_id = (select id from tag where name = 'logistics') where tag_id = (select id from tag where name = 'Logistics');
update tag set vocabulary_id = (select id from vocabulary where name = 'Topics') where name = 'logistics';

update tag set vocabulary_id = (select id from vocabulary where name = 'Topics') where name = 'population';

update tag set vocabulary_id = (select id from vocabulary where name = 'Topics') where name = 'Water Sanitation and Hygiene';
update tag set name = 'water sanitation and hygiene' where name = 'Water Sanitation and Hygiene';