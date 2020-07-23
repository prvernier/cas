REM Create database and schemas, and import inventories
REM PVernier 2019-01-14

REM Create spatial database
createdb -h localhost -U postgres fri
psql -h localhost -U postgres -d fri -c "create extension postgis"

REM Create a schema for each province
psql -h localhost -U postgres -d fri -c "create schema bc_0008"
psql -h localhost -U postgres -d fri -c "create schema ab_0006"
psql -h localhost -U postgres -d fri -c "create schema ab_0016"
psql -h localhost -U postgres -d fri -c "create schema nb_0001"

REM ############################################################################
REM Import bc_0008
ogr2ogr -f "PostgreSQL" "PG:host=localhost dbname=fri user=postgres password=postgres" "E:\Pierre\Dropbox (BEACONs)\CASFRI\FRI\original\bc_0008\VEG_COMP_LYR_R1_POLY.gdb" -nln bc_0008.vri -t_srs canadaAlbersEqualAreaConic.prj -overwrite

REM Select a random subset of table and save a new table
SELECT * INTO bc_0008.vri10000 FROM bc_0008.vri ORDER BY random() LIMIT 10000;
SELECT * INTO rawfri.bc08_rnd200k FROM rawfri.bc08 ORDER BY random() LIMIT 200000;

REM Select all polygons for a subset of attributes
SELECT INVENTORY_STANDARD_CD,CROWN_CLOSURE,CROWN_CLOSURE_CLASS_CD,SPECIES_CD_1,SPECIES_PCT_1,SPECIES_CD_2,SPECIES_PCT_2,SPECIES_CD_3,SPECIES_PCT_3,SPECIES_CD_4,SPECIES_PCT_4,SPECIES_CD_5,SPECIES_PCT_5,SPECIES_CD_6,SPECIES_PCT_6,PROJ_HEIGHT_1,PROJ_HEIGHT_CLASS_CD_1 INTO bc_0008.vri_subset FROM bc_0008.vri;

# BC_0008 - random selection of 10,000 polygons
library(sf)
library(tidyverse)
x = st_read(dsn="PG:host=localhost dbname=fri user=postgres password=postgres", layer="bc_0008.vri_subset", 
	query=paste0("SELECT * FROM bc_0008.vri_subset"), stringsAsFactors = FALSE, as_tibble=TRUE)
#st_geometry(x) = NULL
write_csv(x, "../fri/bc_0008/cas_05/fri.csv")


REM ############################################################################
REM Import ab_0006
ogr2ogr -f "PostgreSQL" "PG:host=localhost dbname=fri user=postgres password=postgres" "E:\Pierre\Dropbox (BEACONs)\CASFRI\FRI\ab_0006\original\GB_S21_TWP.E00" -nln ab_0006.avi -overwrite

REM ############################################################################
REM Import ab_0016
REM ogr2ogr -f "PostgreSQL" "PG:host=localhost dbname=fri user=postgres password=postgres" "E:\Pierre\Dropbox (BEACONs)\CASFRI\FRI\ab0016\" -nln ab_0016.avi -overwrite

REM ############################################################################
REM Import nb_0001 - Forest.shp
shp2pgsql -c -D -s 4326 -i -I "E:\Pierre\Dropbox (BEACONs)\CASFRI\FRI\nb_0001\original\Forest.shp" nb_0001.forest | psql -h localhost -U postgres -d fri

REM Import nb_0001 - Non Forest.shp
shp2pgsql -c -D -s 4326 -i -I "E:\Pierre\Dropbox (BEACONs)\CASFRI\FRI\nb_0001\original\Non Forest.shp" nb_0001.non_forest | psql -h localhost -U postgres -d fri

REM Import nb_0001 - Waterbody.shp
shp2pgsql -c -D -s 4326 -i -I "E:\Pierre\Dropbox (BEACONs)\CASFRI\FRI\nb_0001\original\Waterbody.shp" nb_0001.waterbody | psql -h localhost -U postgres -d fri

REM Import nb_0001 - Wetland.shp
shp2pgsql -c -D -s 4326 -i -I "E:\Pierre\Dropbox (BEACONs)\CASFRI\FRI\nb_0001\original\Wetland.shp" nb_0001.wetland | psql -h localhost -U postgres -d fri
