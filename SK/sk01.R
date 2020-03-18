# sk01 Inventory
# PV 2020-03-10

library(sf)
library(DT)
library(plyr)
library(shiny)
library(leaflet)
library(mapview)
library(rpostgis)
library(tidyverse)
library(summarytools)
library(shinydashboard)

mapviewOptions(basemaps=c("Esri.WorldImagery","Esri.NatGeoWorldMap"), layers.control.pos="topright")

friVars = c('ref_year', 'landpos', 'smr', 'type_lnd', 'class', 'cl_mod', 'sp1', 'sp1_per', 'avg_ht', 'cc', 'age', 'dist_code1', 'dist_code2', 'dist_year1', 'dist_year2', 'site_index', 'site_class', 'stratum', 'type_for')
casVars = c("stand_structure", "num_of_layers", "structure_per", "layer", "layer_rank", "soil_moist_reg", "crown_closure_upper", "crown_closure_lower", "height_upper", "productive_for", "species_1", "species_per_1", "origin_upper", "height_lower", "origin_upper", "origin_lower", "site_index", "non_for_veg", "nat_non_veg", "non_for_anth", "nfl_soil_moist_reg", "nfl_structure_per", "nfl_layer", "nfl_layer_rank", "nfl_crown_closure_upper", "nfl_crown_closure_lower", "nfl_height_upper", "nfl_height_lower", "dist_type_1", "dist_year_1", "dist_ext_upper_1", "dist_ext_lower_1", "wetland_type", "wet_veg_cover", "wet_landform_mod", "wet_local_mod","eco_site")

sppList = read_csv("../CASFRI/translation/tables/lookup/sk01_yvi01_species.csv")

if (!exists("sk01")) {
    con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")
    sk01 = st_read(con, query="SELECT * FROM rawfri.sk01 ORDER BY random() LIMIT 10000;")
    sink("SK/sk01.txt")
    cat("sk01 - FRI Attributes\n---------------------\n")
    for (i in names(sk01)) {
        cat("\n\n", toupper(i),"\n\n", sep="")
        print(dfSummary(sk01[[i]], graph.col=FALSE))
    }
    sink()
    dbDisconnect(con)
}

# Soil moisture regime