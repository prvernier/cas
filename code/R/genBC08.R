hdr = readr::read_file("inventories/bc08_hdr.Rmd")
cas = readr::read_file("inventories/bc08_cas.Rmd")
lyr = readr::read_file("inventories/bc08_lyr.Rmd")
nfl = readr::read_file("inventories/bc08_nfl.Rmd")
dst = readr::read_file("inventories/bc08_dst.Rmd")
eco = readr::read_file("inventories/bc08_eco.Rmd")

fo = file("bc08_all.Rmd", "w")
cat('---  
title: "Inventory Notes"
output:  
  html_document:  
    code_folding: hide
    toc: true
    toc_float:
      collapsed: false
    css: data/styles.css
---  

```{r echo=FALSE, message=FALSE, warning=FALSE}  
library(sf)
library(plyr)
library(readxl)
library(rpostgis)
library(mapview)
library(tidyverse)
library(summarytools)

# Connect to database# and get geometry and attributes for 9 mapsheets in northeast BC
con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="cas", host="localhost", port=5432, user="postgres", password="1Boreal!")
x = as_tibble(dbGetQuery(con, "SELECT map_id, feature_id, inventory_standard_cd, soil_moisture_regime_1, crown_closure, proj_height_1, layer_id, species_cd_1, species_pct_1, species_cd_2, site_index, est_site_index, est_site_index_source_cd, proj_age_1, non_veg_cover_type_1, non_veg_cover_pct_1, land_cover_class_cd_1, land_cover_class_cd_2, land_cover_class_cd_3, bclcs_level_1, bclcs_level_2, bclcs_level_3, bclcs_level_4, bclcs_level_5, non_forest_descriptor, non_productive_descriptor_cd, non_productive_cd, for_mgmt_land_base_ind, line_5_vegetation_cover, line_6_site_prep_history, line_7b_disturbance_history, line_8_planting_history, reference_year, projected_date, reference_date, shape_length, shape_area, bec_zone_code, bec_subzone, bec_variant, bec_phase, site_position_meso FROM rawfri.bc08"))
dbDisconnect(con)
```\n', file=fo, sep="")

cat('\n####################################################################################################\n\n', file=fo, sep="")
cat(read_lines(hdr, skip=30), file=fo, sep="\n")
cat('\n####################################################################################################\n\n', file=fo, sep="")
cat(read_lines(cas, skip=30), file=fo, sep="\n")
cat('\n####################################################################################################\n\n', file=fo, sep="")
cat(read_lines(lyr, skip=30), file=fo, sep="\n")
cat('\n####################################################################################################\n\n', file=fo, sep="")
cat(read_lines(nfl, skip=36), file=fo, sep="\n")
cat('\n####################################################################################################\n\n', file=fo, sep="")
cat(read_lines(dst, skip=30), file=fo, sep="\n")
cat('\n####################################################################################################\n\n', file=fo, sep="")
cat(read_lines(eco, skip=30), file=fo, sep="\n")

close(fo)
