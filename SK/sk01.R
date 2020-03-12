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


# NFL ATTRIBUTES
sk01 = mutate(sk01,
    
    nat_non_veg = case_when(
        type_lnd %in% c('','VF','VN','NU') ~ "NULL_VALUE",
        type_lnd %in% c("NW","NS","NE") & !class %in% c('R','L','RS','E','S','B','RR') ~ "NOT_IN_SET",
        type_lnd %in% c("NW","NS","NE") & landpos=="A" ~ "AP",
        TRUE ~ mapvalues(class,c('R','L','RS','E','S','B','RR'),c('RI','LA','WS','EX','SA','EX','RK'))),

    non_for_anth=case_when(
        !type_lnd=='NU' ~ "NULL_VALUE",
        type_lnd=='NU' & !class %in% c('RD','G','T') ~ "NOT_IN_SET",
        TRUE ~ mapvalues(class, c('RD','G','T'), c('OT','OT','OT'))), # Can we do better than OT?

    non_for_veg=case_when(
        !type_lnd=='VN' ~ "NULL_VALUE",
        type_lnd=='VN' & !class %in% c('S','H','C','M') ~ "NOT_IN_SET",
        type_lnd=='VN' & cl_mod %in% c('TS','TSo','TSc') ~ "ST",
        type_lnd=='VN' & cl_mod=='LS' ~ "SL",
        type_lnd=='VN' & class=='C' ~ "BR",
        type_lnd=='VN' & class %in% c('H','M') ~ "HE",
        TRUE ~ "Something missing?"),

    nfl_soil_moist_reg = case_when(
        (nat_non_veg=="NULL_VALUE" & non_for_anth=="NULL_VALUE" & non_for_veg=="NULL_VALUE") ~ "NULL_VALUE",
        (!nat_non_veg=="NULL_VALUE" | !non_for_anth=="NULL_VALUE" | !non_for_veg=="NULL_VALUE") & smr=="" ~ "EMPTY_STRING", 
        (!nat_non_veg=="NULL_VALUE" | !non_for_anth=="NULL_VALUE" | !non_for_veg=="NULL_VALUE") & !smr %in% c('a','A','d','D','m','M','w','W') ~ "NOT_IN_SET", 
        TRUE ~ mapvalues(smr, c('a','A','d','D','m','M','w','W'), c('A','A','D','D','F','F','W','W'))),

    nfl_structure_per=0,

    nfl_layer="TO_BE_CALCULATED",

    nfl_layer_rank="TO_BE_CALCULATED",

    nfl_crown_closure_upper = case_when(
        (nat_non_veg=="NULL_VALUE" & non_for_anth=="NULL_VALUE" & non_for_veg=="NULL_VALUE") ~ as.numeric(-8888),
        (!nat_non_veg=="NULL_VALUE" | !non_for_anth=="NULL_VALUE" | !non_for_veg=="NULL_VALUE") & (cc<0 | cc>100) ~ as.numeric(-9999), 
        TRUE ~ as.numeric(cc)),

    nfl_crown_closure_lower = case_when(
        (nat_non_veg=="NULL_VALUE" & non_for_anth=="NULL_VALUE" & non_for_veg=="NULL_VALUE") ~ as.numeric(-8888),
        (!nat_non_veg=="NULL_VALUE" | !non_for_anth=="NULL_VALUE" | !non_for_veg=="NULL_VALUE") & (cc<0 | cc>100) ~ as.numeric(-9999), 
        TRUE ~ as.numeric(cc)),

    nfl_height_upper = case_when(
        (nat_non_veg=="NULL_VALUE" & non_for_anth=="NULL_VALUE" & non_for_veg=="NULL_VALUE") ~ as.numeric(-8888),
        (!nat_non_veg=="NULL_VALUE" | !non_for_anth=="NULL_VALUE" | !non_for_veg=="NULL_VALUE") & (avg_ht<0 | avg_ht>100) ~ as.numeric(-9999), 
        TRUE ~ as.numeric(avg_ht)),

    nfl_height_lower = case_when(
        (nat_non_veg=="NULL_VALUE" & non_for_anth=="NULL_VALUE" & non_for_veg=="NULL_VALUE") ~ as.numeric(-8888),
        (!nat_non_veg=="NULL_VALUE" | !non_for_anth=="NULL_VALUE" | !non_for_veg=="NULL_VALUE") & (avg_ht<0 | avg_ht>100) ~ as.numeric(-9999), 
        TRUE ~ as.numeric(avg_ht)),

)

dfSummary(sk01$nat_non_veg, graph.col=F)
dfSummary(sk01$non_for_anth, graph.col=F)
dfSummary(sk01$non_for_veg, graph.col=F)
dfSummary(sk01$nfl_soil_moist_reg, graph.col=F)

#rmarkdown::render("SK/sk01.Rmd", output_dir="sk01")
#browseURL("file://D:/PierreV/CAS/SK/sk01.html", browser="C:/Program Files (x86)/Google/Chrome/Application/chrome.exe")
#shiny::runApp("shiny")
