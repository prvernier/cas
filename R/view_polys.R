# View VRI mapsheets

library(sf)
library(mapview)
library(tidyverse)
library(rpostgis)

folder = "C:/Users/PIVER37/Documents/casfri/FRIs/BC/SourceDataset/v.00.06/"
v = st_read(dsn=paste0(folder,"VEG_COMP_LYR_R1_POLY.gdb"), lyr="VEG_COMP_LYR_R1_POLY", query="SELECT * limit 1")
map_id = pull(v, MAP_ID)
rnd_map_id = sample(map_id, 1)

con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="cas", host="localhost", port=5432, user="postgres", password="postgres")
w = st_read(con, query="SELECT * from rawfri.bc08_rnd10k limit 1;")
mapview(w)
