-- Summarize attributes

-- Create a random subset
select * from fri.bc08 limit 10000;

-- Count number of rows
select count(*) from bc.bc_0008;

-- List 20 rows
select crown_closure, proj_height_1, species_cd_1, species_pct_1, species_cd_2, species_pct_2, species_cd_3, species_pct_3, species_cd_4, species_pct_4, species_cd_5, species_pct_5 from bc.bc_0008 limit 20;

-- Crown closure
select crown_closure, count(*) from bc.bc_0008 group by crown_closure order by crown_closure;

-- proj_height_1
select proj_height_1, count(*) from bc.bc_0008 group by proj_height_1 order by proj_height_1;

-- Species
select species_cd_1, count(*) from bc.bc_0008 group by species_cd_1 order by species_cd_1;

-- Species percent
select species_pct_1, count(*) from bc.bc_0008 group by species_pct_1 order by species_pct_1;

-- Unique combinations of species and percent
select species_cd_1, species_pct_1, count(*) from bc.bc_0008 group by species_cd_1, species_pct_1 order by species_cd_1, species_pct_1;

-- Is feature_id unique?
select feature_id, count(*) from rawfri.bc08 group by feature_id having count(feature_id) > 1 order by count desc
SELECT forest_id_2, count(forest_id_2) FROM rawfri.ab16 GROUP BY forest_id_2 HAVING count(forest_id_2) > 1
