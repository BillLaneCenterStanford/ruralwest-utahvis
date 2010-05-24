use roy;

/*
select utah_pop_98.zip, utah_by_zip_final.year, utah_pop_98.pop, utah_by_zip_final.ph, utah_by_zip_final.panp
from utah_pop_98, utah_by_zip_final
where utah_pop_98.zip=utah_by_zip_final.zip and (utah_by_zip_final.ph>0 or utah_by_zip_final.panp>0) order by utah_by_zip_final.year;
*/


select count(*), utah_by_zip_final.year from utah_by_zip_final where (utah_by_zip_final.ph>0 or utah_by_zip_final.panp>0) and utah_by_zip_final.year=1998;
select count(*), utah_by_zip_final.year from utah_by_zip_final, utah_pop_98 where utah_by_zip_final.zip = utah_pop_98.zip and (utah_by_zip_final.ph>0 or utah_by_zip_final.panp>0) and utah_by_zip_final.year=1998;

select count(*), utah_by_zip_final.year from utah_by_zip_final where (utah_by_zip_final.ph>0 or utah_by_zip_final.panp>0) and utah_by_zip_final.year=2003;
select count(*), utah_by_zip_final.year from utah_by_zip_final, utah_pop_98 where utah_by_zip_final.zip = utah_pop_98.zip and (utah_by_zip_final.ph>0 or utah_by_zip_final.panp>0) and utah_by_zip_final.year=2003;
