# BC10 Inventory
# PV 2020-02-05

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
sppList = read_csv("../CASFRI/translation/tables/lookup/bc_vri01_species.csv")

if (!exists("bc10")) {
    con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")
    bc10 = st_read(con, query="SELECT * FROM rawfri.bc10 ORDER BY random() LIMIT 10000;") %>%
            select(inventory_standard_cd, projected_date, for_mgmt_land_base_ind, soil_moisture_regime_1, bec_zone_code, bec_subzone, bec_variant, bec_phase,
            map_id, l1_feature_id, line_7b_disturbance_history, feature_area_sqm, feature_length_m, reference_year, site_position_meso,
            land_cover_class_cd_1, non_veg_cover_type_1, bclcs_level_4, non_productive_descriptor_cd, l1_non_forest_descriptor,
            l1_layer_id, l1_for_cover_rank_cd, l1_crown_closure, l1_species_cd_1, l1_species_cd_2, l1_species_pct_1, l1_proj_height_1, l1_proj_age_1, l1_site_index, l1_est_site_index,
            l2_layer_id, l2_for_cover_rank_cd, l2_crown_closure, l2_species_cd_1, l2_species_pct_1, l2_proj_height_1, l2_proj_age_1, l2_site_index, l2_est_site_index,
            d_layer_id, d_for_cover_rank_cd, d_crown_closure, d_species_cd_1, d_species_pct_1, d_proj_height_1, d_proj_age_1, d_site_index, d_est_site_index)
    dbDisconnect(con)
}

bc10 = mutate(bc10,

    
    # CAS ATTRIBUTES

    orig_stand_id = l1_feature_id,

    stand_structure = case_when(
        l2_layer_id==2 ~ "M",
        l1_layer_id==1 ~ "S",
        TRUE ~ "NULL_VALUE"),

    num_of_layers = case_when(
        l2_layer_id==2 ~ 2,
        l1_layer_id==1 ~ 1,
        TRUE ~ -8888),

    identification_id = mapvalues(inventory_standard_cd, c("F","V","I","L"), c(4,5,6,7)),

    map_sheet_id = map_id,

    gis_area= round(feature_area_sqm/10000,1),
    
    gis_perimeter = round(feature_length_m,0),

    inventory_area = round(feature_area_sqm/10000,1),
    
    photo_year=reference_year,


    # LYR ATTRIBUTES

    l1_proj_height_1 = round(l1_proj_height_1, 1),
    l1_site_index = round(l1_site_index, 1),

    stand_structure = case_when(
        l2_layer_id==2 ~ "M",
        l1_layer_id==1 ~ "S",
        TRUE ~ "NULL_VALUE"),

    num_of_layers = case_when(
        l2_layer_id==2 ~ 2,
        l1_layer_id==1 ~ 1,
        TRUE ~ -8888),

    soil_moist_reg = case_when(
        is.na(soil_moisture_regime_1) ~ "NULL_VALUE",
        str_trim(soil_moisture_regime_1)=="" ~ "EMPTY_STRING",
        soil_moisture_regime_1 %in% c(0,1,2) ~ "D",
        soil_moisture_regime_1 %in% c(3,4) ~ "F",
        soil_moisture_regime_1 %in% c(5,6) ~ "M",
        soil_moisture_regime_1 %in% c(7,8) ~ "W",
        TRUE ~ "NOT_IN_SET"),

    structure_per=0,

    layer = case_when(
        is.na(l1_layer_id) ~ "NULL_VALUE",
        str_trim(l1_layer_id)=="" ~ "EMPTY_STRING",
        TRUE ~ l1_layer_id),

    layer_rank = case_when(
        is.na(l1_for_cover_rank_cd) ~ "NULL_VALUE",
        str_trim(l1_for_cover_rank_cd)=="" ~ "EMPTY_STRING",
        TRUE ~ l1_for_cover_rank_cd),

    crown_closure_upper=case_when(
        is.na(l1_crown_closure) ~ as.integer(-8888),
        l1_crown_closure < 0 | l1_crown_closure > 100 ~ as.integer(-9999),
        TRUE ~ l1_crown_closure),
    crown_closure_lower=crown_closure_upper,
    
    height_upper=case_when(
        is.na(l1_proj_height_1) ~ -8888,
        l1_proj_height_1 < 0.1 | l1_proj_height_1 > 100 ~ -9999,
        TRUE ~ l1_proj_height_1),
    height_lower=height_upper,

    productive_for = if_else(
        for_mgmt_land_base_ind=="Y", "PF", "PP"),

    species_1=case_when(
        is.na(l1_species_cd_1) ~ "NULL_VALUE",
        str_trim(l1_species_cd_1)=="" ~ "EMPTY_STRING",
        !l1_species_cd_1 %in% sppList$source_val ~ "NOT_IN_SET",
        TRUE ~ plyr::mapvalues(l1_species_cd_1, sppList$source_val, sppList$spec1)),

    species_per_1=case_when(
        is.na(l1_species_pct_1) ~ -8888,
        l1_species_pct_1 < 0 | l1_species_pct_1 > 100 ~ -9999,
        TRUE ~ l1_species_pct_1),

    projected_year=as.double(substr(projected_date, 1, 4)),
    origin_upper=case_when(
        is.na(l1_proj_age_1) ~ -8888,
        l1_proj_age_1==0 ~ -9999,
        TRUE ~ projected_year - l1_proj_age_1),
    origin_lower=origin_upper,

    site_class=NA,

    site_index=case_when(
        is.na(l1_site_index) & is.na(l1_est_site_index) ~ -8888,
        is.na(l1_site_index) & !is.na(l1_est_site_index) ~ l1_est_site_index,
        TRUE ~ l1_site_index),


    # NFL ATTRIBUTES

    non_for_veg="NULL_VALUE", 
    nat_non_veg="NULL_VALUE", 
    non_for_anth="NULL_VALUE", 
    un_prod_for="NULL_VALUE",

    # Process where inventory_standard_cd = "V" or "I"
    # ------------------------------------------------

    # Non-forested vegetated (land_cover_class_cd_1 THEN bclcs_level_4)
    non_for_veg = if_else((inventory_standard_cd=="V" | inventory_standard_cd=="I") & !is.na(land_cover_class_cd_1), 
                if_else(land_cover_class_cd_1 %in% c("BL","BM","BY","HE","HF","HG","SL","ST"), mapvalues(land_cover_class_cd_1,c("BL","BM","BY","HE","HF","HG","SL","ST"),c("BR","BR","BR","HE","HF","HG","SL","ST")), "NULL_VALUE"), "NULL_VALUE"),
    non_for_veg = if_else((inventory_standard_cd=="V" | inventory_standard_cd=="I") & !is.na(bclcs_level_4) & non_for_veg=="NULL_VALUE",
                if_else(bclcs_level_4 %in% c("BL","BM","BY","HE","HF","HG","SL","ST"), mapvalues(bclcs_level_4,c("BL","BM","BY","HE","HF","HG","SL","ST"),c("BR","BR","BR","HE","HF","HG","SL","ST")), non_for_veg), non_for_veg),

    # Non-vegetated natural (non_veg_cover_type_1 THEN land_cover_class_cd_1 THEN bclcs_level_4)
    nat_non_veg = if_else((inventory_standard_cd=="V" | inventory_standard_cd=="I") & !is.na(non_veg_cover_type_1), 
                if_else(non_veg_cover_type_1 %in% c("BE","BI","BR","BU","CB","DW","ES","GL","LA","LB","LL","LS","MN","MU","OC","PN","RE","RI","RM","RS","TA"), mapvalues(non_veg_cover_type_1,c("BE","BI","BR","BU","CB","DW","ES","GL","LA","LB","LL","LS","MN","MU","OC","PN","RE","RI","RM","RS","TA"),c("BE","RK","RK","EX","EX","DW","EX","SI","LA","RK","EX","WS","EX","WS","OC","SI","LA","RI","EX","WS","RK")), "NULL_VALUE"), "NULL_VALUE"),
    nat_non_veg = if_else((inventory_standard_cd=="V" | inventory_standard_cd=="I") & !is.na(land_cover_class_cd_1) & nat_non_veg=="NULL_VALUE", 
                if_else(land_cover_class_cd_1 %in% c("BE","BI","BR","BU","CB","EL","ES","GL","LA","LB","LL","LS","MN","MU","OC","PN","RE","RI","RM","RO","RS","SI","TA"), mapvalues(land_cover_class_cd_1,c("BE","BI","BR","BU","CB","EL","ES","GL","LA","LB","LL","LS","MN","MU","OC","PN","RE","RI","RM","RO","RS","SI","TA"),c("BE","RK","RK","EX","EX","EX","EX","SI","LA","RK","EX","WS","EX","WS","OC","SI","LA","RI","EX","RK","WS","SI","RK")), nat_non_veg), nat_non_veg),
    nat_non_veg = if_else((inventory_standard_cd=="V" | inventory_standard_cd=="I") & !is.na(bclcs_level_4) & nat_non_veg=="NULL_VALUE",
                if_else(bclcs_level_4 %in% c("EL","RO","SI"), mapvalues(bclcs_level_4,c("EL","RO","SI"),c("EX","RK","SI")), nat_non_veg), nat_non_veg),

    # Non-vegetated anthropogenic(non_veg_cover_type_1 THEN land_cover_class_cd_1)
    non_for_anth = if_else((inventory_standard_cd=="V" | inventory_standard_cd=="I") & !is.na(non_veg_cover_type_1),
                 if_else(non_veg_cover_type_1 %in% c("AP","GP","MI","MZ","OT","RN","RZ","TZ","UR"), mapvalues(non_veg_cover_type_1,c("AP","GP","MI","MZ","OT","RN","RZ","TZ","UR"),c("FA","IN","IN","IN","OT","FA","FA","IN","FA")), "NULL_VALUE"), "NULL_VALUE"),
    non_for_anth = if_else((inventory_standard_cd=="V" | inventory_standard_cd=="I") & !is.na(land_cover_class_cd_1) & non_for_anth=="NULL_VALUE", 
                 if_else(land_cover_class_cd_1 %in% c("AP","GP","MI","MZ","OT","RN","RZ","TZ","UR"), mapvalues(land_cover_class_cd_1,c("AP","GP","MI","MZ","OT","RN","RZ","TZ","UR"),c("FA","IN","IN","IN","OT","FA","FA","IN","FA")), non_for_anth), non_for_anth),

    # Process where inventory_standard_cd=="F"
    # ----------------------------------------

    # Non-forested vegetated (non_productive_descriptor_cd THEN bclcs_level_4)
    non_for_veg = if_else(inventory_standard_cd=="F" & !is.na(non_productive_descriptor_cd), 
                if_else(non_productive_descriptor_cd %in% c("AF","M","NPBR","OR"), mapvalues(non_productive_descriptor_cd,c("AF","M","NPBR","OR"),c("AF","HG","ST","HG")), "NULL_VALUE"), non_for_veg),
    non_for_veg = if_else(inventory_standard_cd=="F" & !is.na(bclcs_level_4) & non_for_veg=="NULL_VALUE",
                if_else(bclcs_level_4 %in% c("BL","BM","BY","HE","HF","HG","SL","ST"), mapvalues(bclcs_level_4,c("BL","BM","BY","HE","HF","HG","SL","ST"),c("BR","BR","BR","HE","HF","HG","SL","ST")), non_for_veg), non_for_veg),

    # Non-vegetated natural (non_productive_descriptor_cd THEN bclcs_level_4)
    nat_non_veg = if_else(inventory_standard_cd=="F" & !is.na(non_productive_descriptor_cd), 
                if_else(non_productive_descriptor_cd %in% c("A","CL","G","ICE","L","MUD","R","RIV","S","SAND","TIDE"), mapvalues(non_productive_descriptor_cd,c("A","CL","G","ICE","L","MUD","R","RIV","S","SAND","TIDE"),c("AP","EX","WS","SI","LA","EX","RK","RI","SL","SA","TF")), "NULL_VALUE"), nat_non_veg),
    nat_non_veg = if_else(inventory_standard_cd=="F" & !is.na(bclcs_level_4) & nat_non_veg=="NULL_VALUE", 
                if_else(bclcs_level_4 %in% c("EL","RO","SI"), mapvalues(bclcs_level_4,c("EL","RO","SI"),c("EX","RK","SI")), nat_non_veg), nat_non_veg),

    # Non-vegetated anthropogenic(non_productive_descriptor_cd)
    non_for_anth = if_else(inventory_standard_cd=="F" & !is.na(non_productive_descriptor_cd),
                 if_else(non_productive_descriptor_cd %in% c("C","GR","P","U"), mapvalues(non_productive_descriptor_cd,c("C","GR","P","U"),c("CL","IN","CL","FA")), "NULL_VALUE"), non_for_anth),

    nfl_soil_moist_reg = case_when(
        (!nat_non_veg=="NULL_VALUE" | !non_for_anth=="NULL_VALUE" | !non_for_veg=="NULL_VALUE") & is.na(soil_moisture_regime_1) ~ "NULL_VALUE",
        (!nat_non_veg=="NULL_VALUE" | !non_for_anth=="NULL_VALUE" | !non_for_veg=="NULL_VALUE") & str_trim(soil_moisture_regime_1)=="" ~ "EMPTY_STRING",
        (!nat_non_veg=="NULL_VALUE" | !non_for_anth=="NULL_VALUE" | !non_for_veg=="NULL_VALUE") & soil_moisture_regime_1 %in% c(0,1,2) ~ "D",
        (!nat_non_veg=="NULL_VALUE" | !non_for_anth=="NULL_VALUE" | !non_for_veg=="NULL_VALUE") & soil_moisture_regime_1 %in% c(3,4) ~ "F",
        (!nat_non_veg=="NULL_VALUE" | !non_for_anth=="NULL_VALUE" | !non_for_veg=="NULL_VALUE") & soil_moisture_regime_1 %in% c(5,6) ~ "M",
        (!nat_non_veg=="NULL_VALUE" | !non_for_anth=="NULL_VALUE" | !non_for_veg=="NULL_VALUE") & soil_moisture_regime_1 %in% c(7,8) ~ "W",
        TRUE                      ~ "NULL_VALUE"),
    
    nfl_structure_per=NA,

    nfl_layer=NA,

    nfl_layer_rank=NA,

    nfl_crown_closure_upper = if_else((!nat_non_veg=="NULL_VALUE" | !non_for_anth=="NULL_VALUE" | !non_for_veg=="NULL_VALUE"), as.numeric(l1_crown_closure), as.numeric(-8888)),

    nfl_crown_closure_lower = if_else((!nat_non_veg=="NULL_VALUE" | !non_for_anth=="NULL_VALUE" | !non_for_veg=="NULL_VALUE"), as.numeric(l1_crown_closure), as.numeric(-8888)),

    nfl_height_upper = if_else((!nat_non_veg=="NULL_VALUE" | !non_for_anth=="NULL_VALUE" | !non_for_veg=="NULL_VALUE"), as.numeric(l1_proj_height_1), as.numeric(-8888)),

    nfl_height_lower = if_else((!nat_non_veg=="NULL_VALUE" | !non_for_anth=="NULL_VALUE" | !non_for_veg=="NULL_VALUE"), as.numeric(l1_proj_height_1), as.numeric(-8888)),


    # DST ATTRIBUTES

    mod1 = substr(line_7b_disturbance_history,1,1),
    dist_type_1=if_else(is.na(mod1),"NULL_VALUE",if_else(!mod1 %in% c("L", "B", "W", "D", "K", "S", "F", "I", "R", "G", "Y", "A", "C", "T", "U", "V", "N"),"NOT_IN_SET",mapvalues(mod1, c("L", "B", "W", "D", "K", "S", "F", "I", "R", "G", "Y", "A", "C", "T", "U", "V", "N"), c("CO","BU","WF","DI","OT","SL","FL","IK","SI","WE","WE","OT","OT","OT","OT","OT","UK")))),
    
    mod1yr = substr(line_7b_disturbance_history,2,3),
    dist_year_1=if_else(is.na(mod1yr),as.numeric(-8888), if_else(mod1yr>17,as.numeric(paste0(19,mod1yr)),as.numeric(paste0(20,mod1yr)))),
    dist_year_1=as.integer(dist_year_1),

    dist_ext_upper_1=NA,

    dist_ext_lower_1=NA,


    # ECO ATTRIBUTES

    wetland_type="NULL_VALUE", 
    wet_veg_cover="NULL_VALUE", 
    wet_landform_mod="NULL_VALUE", 
    wet_local_mod="NULL_VALUE",

    # Process where inventory_standard_cd=="F"
    # ----------------------------------------
    wetland = case_when(
        inventory_standard_cd=="F" & l1_species_cd_1 %in% c("SF","CW","YC") & non_productive_descriptor_cd=="S" ~ "STNN",
        inventory_standard_cd=="F" & l1_species_cd_1 %in% c("SF","CW","YC") & non_productive_descriptor_cd=="NP" ~ "STNN",
        inventory_standard_cd=="F" & l1_non_forest_descriptor=="NPBR" ~ "STNN",
        inventory_standard_cd=="F" & l1_non_forest_descriptor=="S" ~ "SONS",
        inventory_standard_cd=="F" & l1_non_forest_descriptor=="MUSKEG" ~ "STNN",
        TRUE ~ "NULL_VALUE"),

    # Process where inventory_standard_cd = "V" or "I"
    # ------------------------------------------------
    wetland = case_when(
        inventory_standard_cd %in% c("V","I") & land_cover_class_cd_1=="W" ~ "W---",
        inventory_standard_cd %in% c("V","I") & soil_moisture_regime_1 %in% c(7,8) & l1_species_cd_1=="SB" & l1_species_pct_1==100 & l1_crown_closure==50 & l1_proj_height_1==12 ~ "BTNN",
        inventory_standard_cd %in% c("V","I") & soil_moisture_regime_1 %in% c(7,8) & l1_species_cd_1 %in% c("SB","LT") & l1_species_pct_1==100 & l1_crown_closure>=50 & l1_proj_height_1>=12 ~ "STNN",
        inventory_standard_cd %in% c("V","I") & soil_moisture_regime_1 %in% c(7,8) & l1_species_cd_1 %in% c("SB","LT") & l1_species_cd_2 %in% c("SB","LT") & l1_crown_closure>=50 & l1_proj_height_1>=12 ~ "STNN",
        inventory_standard_cd %in% c("V","I") & soil_moisture_regime_1 %in% c(7,8) & l1_species_cd_1 %in% c("EP","EA","CW","YR","PI") ~ "STNN",
        inventory_standard_cd %in% c("V","I") & soil_moisture_regime_1 %in% c(7,8) & l1_species_cd_1 %in% c("SB","LT") & l1_species_cd_2 %in% c("SB","LT") & l1_crown_closure<50 ~ "FTNN",
        inventory_standard_cd %in% c("V","I") & soil_moisture_regime_1 %in% c(7,8) & l1_species_cd_1=="LT" & l1_species_pct_1==100 & l1_proj_height_1<12 ~ "FTNN",
        TRUE ~ wetland),

    wetland = case_when(
        inventory_standard_cd %in% c("V","I") & soil_moisture_regime_1 %in% c(7,8) & land_cover_class_cd_1 %in% c("ST","SL") ~ "SONS",
        inventory_standard_cd %in% c("V","I") & soil_moisture_regime_1 %in% c(7,8) & land_cover_class_cd_1 %in% c("HE","HF","HG") ~ "MONG",
        inventory_standard_cd %in% c("V","I") & soil_moisture_regime_1 %in% c(7,8) & land_cover_class_cd_1 %in% c("BY","BM") ~ "FONN", 
        inventory_standard_cd %in% c("V","I") & soil_moisture_regime_1 %in% c(7,8) & land_cover_class_cd_1=="BL" ~ "BONN",
        inventory_standard_cd %in% c("V","I") & soil_moisture_regime_1 %in% c(7,8) & land_cover_class_cd_1=="MU" ~ "TMNN",
        TRUE ~ wetland),

    # Extract from wetland:
    wetland_type = if_else(wetland=="NULL_VALUE", "NULL_VALUE", substr(wetland,1,1)),
    wet_veg_cover = if_else(wetland=="NULL_VALUE", "NULL_VALUE", substr(wetland,2,2)),
    wet_landform_mod = if_else(wetland=="NULL_VALUE", "NULL_VALUE", substr(wetland,3,3)),
    wet_local_mod = if_else(wetland=="NULL_VALUE", "NULL_VALUE", substr(wetland,4,4)),

    eco_site = if_else(is.na(bec_zone_code), "", bec_zone_code),
    eco_site = if_else(is.na(bec_subzone), paste0(eco_site,"."), paste0(eco_site,".",bec_subzone)),
    eco_site = if_else(is.na(bec_variant), paste0(eco_site,"."), paste0(eco_site,".",bec_variant)),
    eco_site = if_else(is.na(bec_phase), paste0(eco_site,"."), paste0(eco_site,".",bec_phase)),
    eco_site = if_else(is.na(site_position_meso), paste0(eco_site,"."), paste0(eco_site,".",site_position_meso))

)

rmarkdown::render("BC/BC10/bc10.Rmd", output_dir="BC/BC10")
browseURL("file://D:/PierreV/CAS/BC/BC10/bc10.html", browser="C:/Program Files (x86)/Google/Chrome/Application/chrome.exe")
shiny::runApp("R")
