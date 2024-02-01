CREATE DATABASE "demo2"
GO

USE "demo2"
GO

CREATE TABLE "LOCATION"
( 
  station_ID VARCHAR (10),
  Longitude FLOAT ,
  Latitude FLOAT ,
  Cluster varchar ,
  Cluster_level2 varchar ,
  PRIMARY KEY (station_ID)
);
GO

CREATE TABLE "TimeTree"
(
  time_ID VARCHAR(10) ,
  "year" int,
  "month" int,
  "day" int,
  "hour" int, 
  PRIMARY KEY (time_ID)
);
GO

CREATE TABLE MEASUREMENTS
(
  weather_ID VARCHAR (10) ,
  airTemperature_value float ,
  dewPoint_value float ,
  pressure_value float ,
  wind_direction_angle float ,
  wind_type VARCHAR (10),
  wind_speed_rate float ,
  visibility_distance_value float ,
  precipitationEstimatedObservation_estimatedWaterDepth float ,
  skyCondition_ceilingHeight_value float ,
  time_ID VARCHAR (10) ,
  station_ID VARCHAR (10),
  PRIMARY KEY (weather_ID),
  FOREIGN KEY (time_ID) REFERENCES "TimeTree" (time_ID),
  FOREIGN KEY (station_ID) REFERENCES "LOCATION" (station_ID)
);