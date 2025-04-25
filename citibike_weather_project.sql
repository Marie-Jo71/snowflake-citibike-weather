-- Create the city bike database

create or replace database citibike;

-- Create tables

create or replace table trips
(tripduration integer,
starttime timestamp,
stoptime timestamp,
start_station_id integer,
start_station_name string,
start_station_latitude float,
start_station_longitude float,
end_station_id integer,
end_station_name string,
end_station_latitude float,
end_station_longitude float,
bikeid integer,
membership_type string,
usertype string,
birth_year integer,
gender integer);


select * 
from trips;



-- Create external stage fort csv files

create stage citibike_csv  URL 
='s3://logbrain-datalake/datasets/citibike-trips-csv/';

list @citibike_csv;

-- create file format for trips csv

CREATE or replace FILE FORMAT csv 
TYPE = 'CSV' 
FIELD_DELIMITER = ',' 
RECORD_DELIMITER = '\n' 
SKIP_HEADER = 1
field_optionally_enclosed_by = '\042'
null_if = ('');


show file formats in database citibike;


-- Loads trips csv file into table

copy into trips from @citibike_csv file_format=csv PATTERN = '.*csv.*' ;


select * 
from trips;

select count(*)
from trips;


-- Query to display the number of trips, average trip duration and average 
trip distance for each hour

select  date_trunc('hour', starttime) as "date",
        count(*) as "num trips",
        round(avg(tripduration)/60, 2) as "avg duration (mins)",
        round(avg(haversine(start_station_latitude, 
        start_station_longitude, 
        end_station_latitude,
        end_station_longitude)), 2) as "avg distance (km)"
from trips
group by 1 
order by 1;



-- Query to see which days of the week are busiest

select
    dayname(starttime) as "day of week",
    count(*) as "num trips"
from trips
group by 1 
order by 2 desc;



-- Days of the week in french

select 
case dayname(starttime)
    when 'Mon' then 'Lundi'
    when 'Tue' then 'Mardi'
    when 'Wed' then 'Mercredi'
    when 'Thu' then 'Jeudi'
    when 'Fri' then 'Vendredi'
    when 'Sat' then 'Samedi'
    when 'Sun' then 'Dimanche'
end as "Jour de la semaine",
    count(*) as "num trips"
from trips
group by 1 
order by 2 desc;



Select SNOWFLAKE.CORTEX.TRANSLATE('Hello, my name is Marie', 'en', 'fr') 
as message;



-----------------------------------------------------------------------------------


--Load semi structured data

---------------------------------------------------------------------------------

-- Create weather database
create or replace database weather;

-- Create table with variant column
create table json_weather_data (v variant);

Select * from json_weather_data;

-- Create stage for json weather data
create stage nyc_weather url = 
's3://logbrain-datalake/datasets/weather-nyc-json';

list @nyc_weather;

-- Create faid format: load json files
copy into json_weather_data from @nyc_weather file_format = (type=json);

Select * from json_weather_data;

-- Browse JSON

select   v[1]:country from json_weather_data; 


-- Create json file format
CREATE or REPLACE file format json 
type = 'JSON'
STRIP_OUTER_ARRAY=TRUE;

-- Emptying the table
TRUNCATE json_weather_data;

-- Import the data again by replacing (type=json) with json: this removes 
the square brackets
copy into json_weather_data from @nyc_weather file_format = json;

Select * from json_weather_data;

-- Read data
select   v:country from json_weather_data;

-- Load a few fields
select 
v:country::string as country,
v:latitude::float as latitude,
v:longitude::float as longitude,
v:name::string as city_name,
v:obsTime::timestamp as obs_time,
v:region::string as region_name,
v:weatherCondition::string as weather_condition
from json_weather_data;


-- Create tabular weather data 
Create or replace table weather as 
select 
v:country::string as country,
v:latitude::float as latitude,
v:longitude::float as longitude,
v:name::string as city_name,
v:obsTime::timestamp as obs_time,
v:region::string as region_name,
v:weatherCondition::string as weather_condition
from json_weather_data;

Select * from weather ;

-- We'll now attach the JSON weather data to our CITIBIKE.PUBLIC.TRIPS 
data to determine the answer to the initial question about the impact of 
weather on the number of trips

select weather_condition ,count(*) as num_trips
from citibike.public.trips
left outer join weather.public.weather
on date(obs_time) = date(starttime)
where weather_condition is not null
group by 1 order by 2 desc;

