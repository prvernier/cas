library(sf)
library(rpostgis)
library(tidyverse)

con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="cas", host="localhost", port=5432, user="postgres", password="postgres")

df = dbGetQuery(con, "SELECT map_id FROM rawfri.bc08")
bc08 = unlist(unique(df$map_id))
save(bc08, file = "shiny/bc08.Rdata")

df = dbGetQuery(con, "SELECT trm_1 FROM rawfri.ab06")
ab06 = unlist(unique(df$trm_1))
save(ab06, file = "shiny/ab06.Rdata")

df = dbGetQuery(con, "SELECT src_filename FROM rawfri.ab16")
ab16 = unlist(unique(df$src_filename))
save(ab16, file = "shiny/ab16.Rdata")

df = dbGetQuery(con, "SELECT stdlab FROM rawfri.nb01")
df$mapid = substr(df$stdlab,1,4)
nb01 = unlist(unique(df$mapid))
save(nb01, file = "shiny/nb01.Rdata")

#fri = st_read(con, query="SELECT * from rawfri.bc08 order by random() limit 1;")
#fri = st_read(con, query="SELECT * from rawfri.bc08 where map_id='092F071'")
#fri = st_read("C:/Users/PIVER37/Documents/CASFRI/FRIs/BC/SourceDataset/v.00.06/VEG_COMP_LYR_R1_POLY.gdb", layer="WHSE_FOREST_VEGETATION_2018_VEG_COMP_LYR_R1_POLY")
