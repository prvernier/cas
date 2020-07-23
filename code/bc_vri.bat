REM Running PostgreSQL using psql from Anaconda Prompt

REM Start psql with cas database and user postgres
psql -h localhost -U postgres -d cas
cas=# \h rem help
cas=# \q rem quit
cas=# \i basics.sql rem run script

REM Create spatial database and schema for BC VRI data
createdb -h localhost -U postgres cas
psql -h localhost -U postgres -d cas -c "create extension postgis"
psql -h localhost -U postgres -d cas -c "create schema bc"
rem psql -h localhost -U postgres -d cas -c "create extension postgis schema bc"

REM Import file geodatabases using ogr2ogr (takes about 10-15 minutes)
ogr2ogr -f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" "C:\Users\pvernier\Desktop\GIS Projects\BC\VEG_COMP_LYR_R1_POLY.gdb" -nln bc.vri -overwrite
ogr2ogr -f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" "C:\Users\beacons\Dropbox (BEACONs)\PRV\casfri\code\data\x600.geojson" -nln bc.vri9


REM Create spatial database using Anaconda Prompt

REM Create spatial database and schema
createdb gis_analysis
psql -h localhost -U postgres -d gis_analysis -c "create extension postgis;"
psql -h localhost -U postgres -d gis_analysis -c "create schema ifl3"

REM Import file geodatabases using ogr2ogr
ogr2ogr -f "PostgreSQL" "PG:host=localhost dbname=gis_analysis user=postgres password=postgres" ..\..\cpr\data\cdfmm_tem.gdb -nln bc.cdf -overwrite
ogr2ogr -f "PostgreSQL" "PG:host=localhost dbname=gis_analysis user=postgres password=postgres" ..\..\..\cpr\data\dgtl_road_atlas.gdb TRANSPORT_LINE -nln bc.roads -overwrite

REM Import shapefiles using ogr2ogr
ogr2ogr -f "ESRI Shapefile" "PG:host=localhost dbname=gis_analysis user=postgres password=postgres" "E:\Pierre\Dropbox (BEACONs)\gisdata\intactness\GFW\ifl_2000.shp" -nln ifl2.ifl_2000 -overwrite
ogr2ogr -f "ESRI Shapefile" "PG:host=localhost dbname=gis_analysis user=postgres password=postgres" "E:\Pierre\Dropbox (BEACONs)\gisdata\intactness\GFW\ifl_2013.shp" -nln ifl2.ifl_2013 -overwrite
ogr2ogr -f "ESRI Shapefile" "PG:host=localhost dbname=gis_analysis user=postgres password=postgres" "E:\Pierre\Dropbox (BEACONs)\gisdata\intactness\GFW\ifl_2016.shp" -nln ifl2.ifl_2016 -overwrite

REM Import shapefiles using shp2pgsql
shp2pgsql -c -D -s 4326 -i -I "E:\Pierre\Dropbox (BEACONs)\gisdata\intactness\GFW\ifl_2000.shp" ifl.ifl_2000 | psql -h localhost -U postgres -d gis_analysis
shp2pgsql -c -D -s 4326 -i -I "E:\Pierre\Dropbox (BEACONs)\gisdata\intactness\GFW\ifl_2013.shp" ifl.ifl_2013 | psql -h localhost -U postgres -d gis_analysis
shp2pgsql -c -D -s 4326 -i -I "E:\Pierre\Dropbox (BEACONs)\gisdata\intactness\GFW\ifl_2016.shp" ifl.ifl_2016 | psql -h localhost -U postgres -d gis_analysis

REM Moving tables from one server to another

REM Dumping a table (database: cas, schema: bc, table: vri9)
pg_dump -U postgres -d fri -t bc_0008.vri9 > vri9.sql
pg_restore

REM Restore table with schema into another server
psql -d cas -h localhost -U postgres < vri9.sql
