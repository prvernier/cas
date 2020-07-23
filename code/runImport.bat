:: Create database, extension, and schema
createdb -h localhost -U postgres cas
psql -h localhost -U postgres -d cas -c "create extension postgis"
psql -h localhost -U postgres -d cas -c "create schema rawfri"

:: Import AB inventories
"C:\Program Files\GDAL\ogr2ogr" -f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" "C:\Users\PIVER37\Documents\casfri\FRIs\AB\SourceDataset\v00.04\CROWNFMA\GordonBuchananTolko\S21_Gordon_Buchanan_Tolko\GB_S21_TWP\gdb\GB_S21_TWP.gdb" -nln rawfri.ab06 -t_srs canadaAlbersEqualAreaConic.prj -progress -overwrite
psql -h localhost -U postgres -d cas -c "alter table rawfri.ab06 add column src_filename text default 'GB_S21_TWP';"

:: Import BC inventories
"C:\Program Files\GDAL\ogr2ogr" -f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" "C:\Users\PIVER37\Documents\casfri\FRIs\BC\SourceDataset\v.00.05\VEG_COMP_LYR_R1_POLY\VEG_COMP_LYR_R1_POLY.gdb" -nln fri.bc08 -t_srs canadaAlbersEqualAreaConic.prj -progress -overwrite
psql -h localhost -U postgres -d cas -c alter table fri.bc08 add column src_filename text default 'VEG_COMP_LYR_R1_POLY';"

:: Import NB inventories (assumes we are in the same directory as nb*.sql)
psql -h localhost -U postgres -d cas -c "create schema nb"
load_nb_0001.bat
psql -h localhost -U postgres -d cas < C:\Users\beacons\Dropbox (BEACONs)\CASFRI\inventories\nb_0001.sql

