drop view if exists regions_forestation;
drop view if exists comparison;
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
-- -----------------------------------------------------------------------------------------------
create view comparison as (select
	f1.country_code, 
	f1.country_name, 
	f1.region, 
	f1.income_group, 
	f1.forest_area_sqkm as forest_area_sqkm_1990, 
	f2.forest_area_sqkm  as forest_area_sqkm_2016, 
	f1.forest_area_perc as forest_area_perc_1990, 
	f2.forest_area_perc  as forest_area_perc_2016, 
	f1.forest_area_sqkm - f2.forest_area_sqkm as decrease_sqkm,
	f1.forest_area_perc - f2.forest_area_perc as decrease_perc
	from forestation f1
	left join forestation f2 using (country_code)
	where f1.year=1990 and f2.year=2016 and f1.country_code !='WLD');
	
-- Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? What was the difference in forest area for each?
select country_code, country_name, decrease_sqkm 
	from comparison
	where decrease_sqkm is not null
	order by decrease_sqkm desc 
	limit 5;

-- Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? What was the percent change to 2 decimal places for each?
select country_code, country_name, round(decrease_perc::numeric, 2) 
	from comparison
	where decrease_perc is not null
	order by decrease_perc desc 
	limit 5;
	
-- -----------------------------------------------------------------------------------------------
-- What was the percent forest of the entire world in 2016? Which region had the HIGHEST percent forest in 2016, and which had the LOWEST, to 2 decimal places

select forest_area_perc, year from forestation where country_code = 'WLD' and year in (1990, 2016);

select country_code, country_name, round(forest_area_perc::numeric, 2) as rounded 
	from forestation 
where forest_area_perc is not null and year = 2016
order by forest_area_perc desc
limit 1;

select country_code, country_name, round(forest_area_perc::numeric, 2) as rounded 
	from forestation 
where forest_area_perc is not null and year = 2016
order by forest_area_perc
limit 1;

-- Create a table that shows the Regions and their percent forest area (sum of forest area divided by sum of land area) in 1990 and 2016. (Note that 1 sq mi = 2.59 sq km).

create view regions_forestation as (
	select region, year, 100*sum(forest_area_sqkm)/sum(total_area_sqkm) as forest_area_perc
		from forestation 
		group by region, year
		having year in (1990, 2016)
		order by region, year);

	select * from regions_forestation;

-- What was the percent forest of the entire world in 2016? Which region had the HIGHEST percent forest in 2016, and which had the LOWEST, to 2 decimal places?
select region, forest_area_perc from regions_forestation where year=2016 and region='World';

select region, round(forest_area_perc::numeric, 2) 
	from regions_forestation 
	where year=2016 
	order by forest_area_perc desc
	limit 1;

select region, round(forest_area_perc::numeric, 2) 
	from regions_forestation 
	where year=2016 
	order by forest_area_perc asc
	limit 1;

-- What was the percent forest of the entire world in 1990? Which region had the HIGHEST percent forest in 1990, and which had the LOWEST, to 2 decimal places?
select region, forest_area_perc from regions_forestation where year=1990 and region='World';

select region, round(forest_area_perc::numeric, 2) 
	from regions_forestation 
	where year=1990
	order by forest_area_perc desc
	limit 1;

select region, round(forest_area_perc::numeric, 2) 
	from regions_forestation 
	where year=1990 
	order by forest_area_perc asc
	limit 1;

-- Based on the table you created, which regions of the world DECREASED in forest area from 1990 to 2016?
	select rf1990.region
	from regions_forestation as rf1990
	join regions_forestation as rf2016 
	using (region)
	where rf1990.year = 1990 and rf2016.year = 2016 and rf1990.forest_area_perc > rf2016.forest_area_perc and region != 'World';


