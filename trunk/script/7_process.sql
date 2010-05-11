use roy;

/* merge frequency */
/*
update utah_by_zip_final set aprn = (select utah_by_zip.freq from utah_by_zip where utah_by_zip_final.zip=utah_by_zip.zip and utah_by_zip_final.year=utah_by_zip.year and type='APRN');

update utah_by_zip_final set pa = (select utah_by_zip.freq from utah_by_zip where utah_by_zip_final.zip=utah_by_zip.zip and utah_by_zip_final.year=utah_by_zip.year and type='PA');

update utah_by_zip_final set ph = (select utah_by_zip.freq from utah_by_zip where utah_by_zip_final.zip=utah_by_zip.zip and utah_by_zip_final.year=utah_by_zip.year and type='PH');
*/

/* set NULL to 0 */
/*
update utah_by_zip_final set aprn = 0 where aprn is NULL;
update utah_by_zip_final set pa = 0 where pa is NULL;
update utah_by_zip_final set ph = 0 where ph is NULL;
*/

/* compute panp = aprn + pa */
/*
alter table utah_by_zip_final add panp int;
update utah_by_zip_final set panp = pa + aprn;
*/

/* compute change */
/*
alter table utah_by_zip_final add change_ph int;
alter table utah_by_zip_final add change_panp int;
update utah_by_zip_final set change_panp = 0, change_ph = 0 where year = 1998;
update utah_by_zip_final set change_panp = 0, change_ph = 0;
*/
/* !! the change is to be done in excel !! */


/* output to file */
select * from utah_by_zip_final where year=1998 into outfile '~/Documents/Adobe Flash Builder 4/Utah/dat/utah_by_zip_1998.csv' fields terminated by ',';

select * from utah_by_zip_final where year=2003 into outfile '~/Documents/Adobe Flash Builder 4/Utah/dat/utah_by_zip_2003.csv' fields terminated by ',';

