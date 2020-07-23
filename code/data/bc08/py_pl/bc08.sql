-- Make sure to select the cas database prior to running the following queries

-- Create a new table for inventory region 9 (Vancouver area)
CREATE TABLE bc.vri9 AS
  select * from bc.vri where INVENTORY_REGION=9;

-- View geometry (transform to geographic projection to see other maps)
SELECT ST_Transform(wkb_geometry,4326) FROM bc.vri9;

-- View all forests > 600 years
--SELECT polygon_area, species_cd_1, species_pct_1, proj_age_1, species_cd_2, species_pct_2, proj_age_2, ST_Transform(wkb_geometry,4326) FROM bc.vri9
--  WHERE proj_age_1 > 600;
SELECT polygon_area, species_cd_1, species_pct_1, proj_age_1, species_cd_2, species_pct_2, proj_age_2 FROM bc_0008.vri9
  WHERE proj_age_1 > 500;

-- Select a random subset of table and save a new table
SELECT * INTO bc_0008.vri10000 FROM bc_0008.vri ORDER BY random() LIMIT 10000;

-- How many records
SELECT COUNT(*) FROM rawfri.bc08;

-- Tabulate crown_closure for one inventory standard
SELECT crown_closure, COUNT(crown_closure) AS "count" FROM bc_0008.vri WHERE inventory_standard_cd='V' GROUP BY(crown_closure);

-- Tabulate for_mgmt_land_base_ind (Y=3896224, N=965016)
SELECT for_mgmt_land_base_ind, COUNT(for_mgmt_land_base_ind) AS "count" FROM rawfri.bc08 GROUP BY(for_mgmt_land_base_ind);
SELECT opening_number, COUNT(opening_number) AS "count" FROM rawfri.bc08 GROUP BY(opening_number);
