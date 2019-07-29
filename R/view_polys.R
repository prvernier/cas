# View VRI mapsheets

library(sf)
library(mapview)
library(tidyverse)

folder = "C:/Users/PIVER37/Documents/casfri/data/FRIs/BC/SourceDataset/v.00.05/"
v = st_read(dsn=paste0(folder,"VEG_COMP_LYR_R1_POLY.gdb"), lyr="VEG_COMP_LYR_R1_POLY")
map_id = pull(v, MAP_ID)
rnd_map_id = sample(map_id, 1)
