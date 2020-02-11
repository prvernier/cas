# ON02 Inventory
# PV 2020-02-06

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

casVars = c("stand_structure", "num_of_layers", "structure_per", "layer", "layer_rank", "soil_moist_reg", "crown_closure_upper", "crown_closure_lower", "height_upper", "productive_for", "species_1", "species_per_1", "origin_upper", "height_lower", "origin_upper", "origin_lower", "site_index", "non_for_veg", "nat_non_veg", "non_for_anth", "nfl_soil_moist_reg", "nfl_structure_per", "nfl_layer", "nfl_layer_rank", "nfl_crown_closure_upper", "nfl_crown_closure_lower", "nfl_height_upper", "nfl_height_lower", "dist_type_1", "dist_year_1", "dist_ext_upper_1", "dist_ext_lower_1", "wetland_type", "wet_veg_cover", "wet_landform_mod", "wet_local_mod","eco_site")

sppList = read_csv("../CASFRI/translation/tables/lookup/on_fim02_species.csv")

if (!exists("on02")) {
    con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")
    on02 = st_read(con, query="SELECT * FROM rawfri.on02 ORDER BY random() LIMIT 10000;")
    sink("on02/on02.txt")
    dfSummary(on02, graph.col=FALSE)
    sink()
    dbDisconnect(con)
}

on02 = mutate(on02,
    
    # CAS ATTRIBUTES

    orig_stand_id = polyid,

    stand_structure = case_when(
        is.na(vert) ~ "NULL_VALUE",
        !vert %in% c("SI","SV","TT","TV","CX") ~ "NOT_IN_SET",
        TRUE ~ mapvalues(vert, c("SI","SV","TT","TV","CX"), c("S","S","M","M","C"))),

    num_of_layers = "TO_BE_CALCULATED",

    identification_id = "NOT_SURE",

    map_sheet_id = "NOT_APPLICABLE",

    gis_area = round(area/10000,1),
    
    gis_perimeter = round(perimeter,0),

    inventory_area = round(area/10000,1),
    
    photo_year = "TO_BE_CALCULATED",


    # LYR ATTRIBUTES

    soil_moist_reg = "NOT_APPLICABLE",

    structure_per=0,

    layer = "TO_BE_CALCULATED",

    layer_rank = "TO_BE_CALCULATED",

    crown_closure_upper=case_when(
        is.na(occlo) ~ as.integer(-8888),
        occlo < 0 | occlo > 100 ~ as.integer(-9999),
        TRUE ~ occlo),
    crown_closure_lower=crown_closure_upper,
    
    height_upper=case_when(
        is.na(oht) ~ -8888,
        oht < 0.1 | oht > 100 ~ -9999,
        TRUE ~ oht),
    height_lower=height_upper,

    productive_for = case_when(
        is.na(polytype) ~ "NULL_VALUE",
        !polytype %in% c('BSH','DAL','FOR','GRS','ISL','OMS','RCK','TMS','UCL','WAT') ~ "NOT_IN_SET",
        TRUE ~ mapvalues(polytype, c('BSH','DAL','FOR','GRS','ISL','OMS','RCK','TMS','UCL','WAT'), c('PP','PP','PF','PP','PP','PP','PP','PP','PP','PP'))),

    species_1="TO_BE_CALCULATED",

    species_per_1="TO_BE_CALCULATED",

    origin_upper=case_when(
        is.na(oyrorg) ~ as.integer(-8888),
        oyrorg==0 ~ as.integer(-9999),
        TRUE ~ oyrorg),
    origin_lower=origin_upper,

    site_class= case_when(
        is.na(osc) ~ "NULL_VALUE",
        !osc %in% c(0,1,2,3,4) ~ "NOT_IN_SET",
        TRUE ~ mapvalues(osc, c(0,1,2,3,4), c("G","G","M","P","U"))),

    site_index=case_when(
        is.na(osi) ~ -8888,
        osi < 0.1 | osi > 40.0 ~ -9999,
        TRUE ~ osi),

    # NFL ATTRIBUTES

    non_for_veg=case_when(
        is.na(polytype) ~ "NULL_VALUE",
        !polytype %in% c('BSH','GRS','OMS') ~ "NOT_IN_SET",
        TRUE ~ mapvalues(polytype, c('BSH','GRS','OMS'), c('HG','HG','OM'))),

    nat_non_veg=case_when(
        is.na(polytype) ~ "NULL_VALUE",
        !polytype %in% c('DAL','UCL') ~ "NOT_IN_SET",
        TRUE ~ mapvalues(polytype, c('DAL','UCL'), c('CL','OT'))),

    non_for_anth=case_when(
        is.na(polytype) ~ "NULL_VALUE",
        !polytype %in% c('ISL','RCK','WAT') ~ "NOT_IN_SET",
        TRUE ~ mapvalues(polytype, c('ISL','RCK','WAT'), c('IS','RK','RI'))),

    nfl_soil_moist_reg = "NOT_APPLICABLE",

    nfl_structure_per=0,

    nfl_layer="TO_BE_CALCULATED",

    nfl_layer_rank="TO_BE_CALCULATED",

    nfl_crown_closure_upper = if_else((!nat_non_veg=="NULL_VALUE" | !non_for_anth=="NULL_VALUE" | !non_for_veg=="NULL_VALUE"), as.numeric(occlo), as.numeric(-8888)),

    nfl_crown_closure_lower = if_else((!nat_non_veg=="NULL_VALUE" | !non_for_anth=="NULL_VALUE" | !non_for_veg=="NULL_VALUE"), as.numeric(occlo), as.numeric(-8888)),

    nfl_height_upper = if_else((!nat_non_veg=="NULL_VALUE" | !non_for_anth=="NULL_VALUE" | !non_for_veg=="NULL_VALUE"), as.numeric(oht), as.numeric(-8888)),

    nfl_height_lower = if_else((!nat_non_veg=="NULL_VALUE" | !non_for_anth=="NULL_VALUE" | !non_for_veg=="NULL_VALUE"), as.numeric(oht), as.numeric(-8888)),


    # DST ATTRIBUTES

    # Not used: 'NEWNAT','THINCOM','THINPRE'
    dist_type_1 = case_when(
        is.na(devstage) ~ "NULL_VALUE",
        devstage=="" ~ "NULL_VALUE",
        !devstage %in% c('DEPHARV','DEPNAT','FIRSTCUT','FRSTPASS','FTGNAT','FTGPLANT','FTGSEED','IMPROVE','LASTCUT','LOWMGMT','LOWNAT','NEWPLANT','NEWSEED','PREPCUT','SEEDCUT','SELECT') ~ "NOT_IN_SET",
        TRUE ~ mapvalues(devstage, c('DEPHARV','DEPNAT','FIRSTCUT','FRSTPASS','FTGNAT','FTGPLANT','FTGSEED','IMPROVE','LASTCUT','LOWMGMT','LOWNAT','NEWPLANT','NEWSEED','PREPCUT','SEEDCUT','SELECT'), c('CO','BU','PC','PC','BU','CO','CO','PC','PC','CO','BU','CO','CO','PC','PC','PC'))),
    
    dist_year_1 = case_when(
        is.null(yrdep) ~ as.integer(-8888),
        yrdep < 1800 | yrdep > 2100 ~ as.integer(-9999),
        TRUE ~ yrdep),

    dist_ext_upper_1 = "NOT_APPLICABLE",

    dist_ext_lower_1 = "NOT_APPLICABLE",


    # ECO ATTRIBUTES

    wetland_type = "TO_BE_COMPLETED",

    wet_veg_cover = "TO_BE_COMPLETED",

    wet_landform_mod = "TO_BE_COMPLETED",

    wet_local_mod = "TO_BE_COMPLETED",

    eco_site = "TO_BE_COMPLETED"

)

#rmarkdown::render("on02/on02.Rmd", output_dir="on02")
#browseURL("file://D:/PierreV/CAS/on02/on02.html", browser="C:/Program Files (x86)/Google/Chrome/Application/chrome.exe")
#shiny::runApp("shiny")
