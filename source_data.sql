-- Import CSV files into database "deforestation".
-- Select * from information_schema.columns where table_name = 'forest_area';
-- SELECT * FROM pg_indexes WHERE tablename = 'forest_area';
drop table if exists forest_area;

create table forest_area (
	country_code varchar(50),
	country_name varchar(50),
	year int2,
	forest_area_sqkm float8
);

-- \copy forest_area from 'forest_area.csv' delimiter ',' csv header

drop table if exists land_area;

create table land_area (
	country_code varchar(50),
	country_name varchar(50),
	year int2,
	total_area_sq_mi float8
);

-- \copy land_area from 'land_area.csv' delimiter ',' csv header

drop table if exists regions;

create table regions (
	country_name varchar(50),
	country_code varchar(50),
	region varchar(50),
	income_group varchar(50)
);

-- \copy regions from 'regions.csv' delimiter ',' csv header
 
