drop view if exists change_1990_2016;
drop view if exists forestation;
create view forestation as
	select 
		land_area.country_code, 
		land_area.country_name, 
		region, 
		income_group, 
		land_area.year, 
		land_area.total_area_sq_mi * 2.59 as total_area_sqkm, 
		forest_area.forest_area_sqkm, 
		100*forest_area_sqkm/(total_area_sq_mi*2.59) as forest_area_perc  
	from forest_area
	join land_area on land_area.country_code = forest_area.country_code and land_area.year = forest_area.year
	join regions on regions.country_code = land_area.country_code;
	
-- What was the total forest area (in sq km) of the world in 1990?
select country_code, year, forest_area_sqkm from forestation where country_code = 'WLD' and year=1990;

-- What was the total forest area (in sq km) of the world in 2016?
select country_code, year, forest_area_sqkm from forestation where country_code = 'WLD' and year=2016;

-- What was the change (in sq km) in the forest area of the world from 1990 to 2016? 
create view change_1990_2016 as
	select forest_area_sqkm - (select 
			forest_area_sqkm 
			from forestation 
			where country_code = 'WLD' and year=1990) as change
		from forestation where country_code = 'WLD' and year=2016;
select * from change_1990_2016;

-- What was the percent change in forest area of the world between 1990 and 2016?
select 100* change_1990_2016.change / (select 
			forest_area_sqkm 
			from forestation 
			where country_code = 'WLD' and year=1990) as change_perc
		from change_1990_2016;
			
-- If you compare the amount of forest area lost between 1990 and 2016, to which country's total area in 2016 is it closest to?	
with compare_changes as (
	select forestation.country_code, forestation.country_name, abs(abs(change_1990_2016.change) - forestation.total_area_sqkm) as difference 
	from forestation 
	cross join change_1990_2016 
	where forestation.year=2016)
	
select country_code, country_name from compare_changes where compare_changes.difference = (select min(difference) from compare_changes); 
-- select total_area_sqkm from forestation where country_code ='PER';
