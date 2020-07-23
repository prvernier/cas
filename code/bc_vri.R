library(sf)
library(tidyverse)
library(summarytools)

#x = st_read(dsn="PG:host=localhost dbname=cas user=postgres password=postgres")

# Read sample of BC VRI (5000 polygons)
#BC_VRI = st_read("BC/vri5000.geojson", stringsAsFactors = FALSE, as_tibble=FALSE) %>%
#    select(map_id, reference_year, projected_date,
#        soil_moisture_regime_1, soil_moisture_regime_2, soil_moisture_regime_3,
#        crown_closure, shrub_crown_closure,
#        site_index,
#        species_cd_1, species_pct_1, species_cd_2, species_pct_2, species_cd_3, species_pct_3,
#        species_cd_4, species_pct_4, species_cd_5, species_pct_5, species_cd_6, species_pct_6,
#        proj_age_1, proj_age_2,
#        proj_height_1, proj_height_2)

#dfSummary(x)

x = st_read("../fri/bc_0008/vri1000.geojson", stringsAsFactors = FALSE, as_tibble=FALSE) %>%
    select(inventory_standard_cd,crown_closure,
        species_cd_1, species_pct_1, species_cd_2, species_pct_2, species_cd_3, species_pct_3,
        species_cd_4, species_pct_4, species_cd_5, species_pct_5, species_cd_6, species_pct_6,
        proj_height_1, proj_height_2)

print(dfSummary(BC_VRI, max.distinct.values=10), method="pander", file="translate/bc/bc_vri_data.txt")

# VRI has 4,861,240 records; select 5000 records from across BC
x = st_read(dsn="PG:host=localhost dbname=cas user=postgres password=postgres", layer="bc.vri", 
	query=paste0("SELECT * FROM bc.vri LIMIT 5000"), stringsAsFactors = FALSE, as_tibble=FALSE)

st_write(x, dsn="vri5000.geojson")

bc_attributes = "map_id, species_cd_1, species_pct_1, proj_height_1, species_cd_2, species_pct_2, proj_height_2, crown_closure, wkb_geometry"

# Read VRI (inventory region 9)
#x = st_read(dsn="PG:host=localhost dbname=cas user=postgres password=postgres", layer="bc.vri9", 
#	query=paste0("SELECT ",bc_attributes," FROM bc.vri9 LIMIT 1000"), stringsAsFactors = FALSE, as_tibble=FALSE)

# Read VRI
x = st_read(dsn="PG:host=localhost dbname=cas user=postgres password=postgres", layer="bc.vri", 
	query=paste0("SELECT ",bc_attributes," FROM bc.vri LIMIT 1000"), stringsAsFactors = FALSE, as_tibble=FALSE)

view(dfSummary(x))

#library(rpostgis)
#con <- dbConnect(RPostgreSQL::PostgreSQL(), dbname='fri', host='localhost', port=5432, user='postgres', password='postgres')
#con <- RPostgreSQL::dbConnect("PostgreSQL", host="localhost", dbname="cas", user="postgres", password="postgres")


# Read file geodatabase
x = st_read("C:/Users/beacons/Documents/CASFRI/FRIs/BC/SourceDataset/v.00.04/BCGOV/VEG_COMP_LYR_R1_POLY.gdb")

# Connect to database using SF
#x = st_read(dsn=paste0("PG:host=localhost dbname=",input_dbase," user=",input_user," password=",input_pwd), layer=paste0(input_schema,".",input_table), 
#    query=paste0("SELECT ",attributes," FROM ",input_schema,".",input_table," LIMIT 500"), stringsAsFactors = FALSE, as_tibble=FALSE)
#v = pull(x, input_attrib)
#dfSummary(v, max.distinct.values=100)
