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

#mapviewOptions(basemaps=c("Esri.WorldImagery","Esri.NatGeoWorldMap"), layers.control.pos="topright")

#friVars = c('ref_year', 'landpos', 'smr', 'type_lnd', 'class', 'cl_mod', 'sp1', 'sp1_per', 'avg_ht', 'cc', 'age', 'dist_code1', 'dist_code2', 'dist_year1', 'dist_year2', 'site_index', 'site_class', 'stratum', 'type_for')
#casVars = c("stand_structure", "num_of_layers", "structure_per", "layer", "layer_rank", "soil_moist_reg", "crown_closure_upper", "crown_closure_lower", "height_upper", "productive_for", "species_1", "species_per_1", "origin_upper", "height_lower", "origin_upper", "origin_lower", "site_index", "non_for_veg", "nat_non_veg", "non_for_anth", "nfl_soil_moist_reg", "nfl_structure_per", "nfl_layer", "nfl_layer_rank", "nfl_crown_closure_upper", "nfl_crown_closure_lower", "nfl_height_upper", "nfl_height_lower", "dist_type_1", "dist_year_1", "dist_ext_upper_1", "dist_ext_lower_1", "wetland_type", "wet_veg_cover", "wet_landform_mod", "wet_local_mod","eco_site")

sppList = read_csv("../CASFRI/translation/tables/lookup/sk_utm01_species.csv")

if (!exists("sk01")) {
    con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")
    sk01 = st_read(con, query="SELECT * FROM rawfri.sk01;")
    #sk = dbGetQuery(con, statement="SELECT * FROM rawfri.sk01 ORDER BY random() LIMIT 10000;")
    sink("SK/sk01.txt")
    cat("sk01 - FRI Attributes\n---------------------\n")
    for (i in names(sk01)) {
        cat("\n\n", toupper(i),"\n\n", sep="")
        print(dfSummary(sk01[[i]], graph.col=FALSE))
    }
    sink()
    dbDisconnect(con)
}

sppList = c("WB","BP","JP","TA","BS","TL","WS","MM","BF","WE","LP")
sk01 = mutate(sk01,	
    nnsp1=0, nnsp2=0, notnull=0, 
    nnsp1 = if_else(sp10 %in% sppList, nnsp1 + 1, nnsp1),
    notnull = if_else(sp10 %in% sppList, notnull + 1, notnull),
    nnsp1 = if_else(sp11 %in% sppList, nnsp1 + 1, nnsp1),
    notnull = if_else(sp11 %in% sppList, notnull + 1, notnull),
    nnsp1 = if_else(sp12 %in% sppList, nnsp1 + 1, nnsp1),
    notnull = if_else(sp12 %in% sppList, notnull + 1, notnull),
    nnsp2 = if_else(sp20 %in% sppList, nnsp2 + 1, nnsp2),
    notnull = if_else(sp20 %in% sppList, notnull + 1, notnull),
    nnsp2 = if_else(sp21 %in% sppList, nnsp2 + 1, nnsp2),
    notnull = if_else(sp21 %in% sppList, notnull + 1, notnull),
    test = if_else(sp10 %in% sppList, "Not NA", "NA"),
    species_1=if_else(
        sa %in% c("S","H"),
            case_when(
                notnull==1 ~ sp10,
                TRUE ~ "NULL_VALUE"), "NULL_VALUE"),
    species_per_1=if_else(
        sa %in% c("S","H"),
            case_when(
                notnull==1 ~ as.integer(100),
                TRUE ~ as.integer(-8888)), as.integer(-8888))
)
sk01

dfSummary(sk01$species_1, graph.col=F)
dfSummary(sk01$species_per_1, graph.col=F)

    # LYR ATTRIBUTES

    soil_moist_reg=case_when(
        is.na(drain) ~ "NULL_VALUE",
        drain=="" ~ "NULL_VALUE",
        !drain %in% c('VR','VRR','R','RW','W','WMW','MW','MWI','I','IP','P','PVP','VP') ~ "NOT_IN_SET",
        TRUE ~ mapvalues(drain, c('VR','VRR','R','RW','W','WMW','MW','MWI','I','IP','P','PVP','VP'), c('D','D','D','F','F','F','F','M','M','M','M','W','W'))),
    

    origin_upper=case_when(
        is.na(yoo) ~ as.integer(-8888),
        yoo==0 ~ as.integer(-9999),
        TRUE ~ yoo),
    origin_lower=origin_upper,

    # DST ATTRIBUTES

    dist_type_1 = case_when(
        is.na(dist) ~ "NULL_VALUE",
        dist=="" ~ "NULL_VALUE",
        !dist %in% c('SCO','WCO','OCO','SPC','WPC','OPC','BO') ~ "NOT_IN_SET",
        TRUE ~ mapvalues(dist, c('SCO','WCO','OCO','SPC','WPC','OPC','BO'), c('CO','CO','CO','PC','PC','PC','BU'))),
    
    dist_year_1 = case_when(
        is.null(dyr) ~ as.integer(-8888),
        dyr < 1800 | dyr > 2100 ~ as.integer(-9999),
        TRUE ~ dyr),

    dist_ext_upper_1 = "NOT_APPLICABLE",

    dist_ext_lower_1 = "NOT_APPLICABLE",

    # NFL ATTRIBUTES

    nat_non_veg = case_when(
        is.na(np) ~ "NULL_VALUE",
        np=="" ~ "NULL_VALUE",
        !np %in% c('3800','5100','3400','5210','5220','5200') ~ "NOT_IN_SET",
        TRUE ~ mapvalues(np,c('3800','5100','3400','5210','5220','5200'),c('SD','FL','RK','LA','FL','RI'))),

    non_for_anth = case_when(
        is.na(np) ~ "NULL_VALUE",
        np=="" ~ "NULL_VALUE",
        !np %in% c('3300','3500','3600') ~ "NOT_IN_SET",
        TRUE ~ mapvalues(np,c('3300','3500','3600'),c('OM','ST','HG'))),

    non_for_veg = case_when(
        is.na(np) ~ "NULL_VALUE",
        np=="" ~ "NULL_VALUE",
        !np %in% c('3700','9000','4000') ~ "NOT_IN_SET",
        TRUE ~ mapvalues(np,c('3700','9000','4000'),c('OT','OT','CL')))
)

dfSummary(sk01$np, graph.col=F,max.distinct.values = 100)
dfSummary(sk01$nat_non_veg, graph.col=F)
dfSummary(sk01$non_for_anth, graph.col=F)
dfSummary(sk01$non_for_veg, graph.col=F)

