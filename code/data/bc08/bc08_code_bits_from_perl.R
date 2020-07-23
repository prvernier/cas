library(sf)
library(plyr)
library(rpostgis)
library(mapview)
library(tidyverse)
library(summarytools)

# List of FRI attributes to use
fri_cols = c("map_id", "feature_id", "inventory_standard_cd", "soil_moisture_regime_1", "crown_closure", "proj_height_1", "layer_id", "species_cd_1", "species_pct_1", "site_index", "est_site_index_source_cd", "proj_age_1", "non_veg_cover_type_1", "non_veg_cover_pct_1", "land_cover_class_cd_1", "land_cover_class_cd_2", "land_cover_class_cd_3", "bclcs_level_1", "bclcs_level_2", "bclcs_level_3", "bclcs_level_4", "bclcs_level_5", "non_forest_descriptor", "non_productive_descriptor_cd", "non_productive_cd", "for_mgmt_land_base_ind", "line_5_vegetation_cover", "line_7b_disturbance_history", "reference_year", "projected_date", "reference_date", "shape_length", "shape_area")
nfl_cols = c("inventory_standard_cd", "soil_moisture_regime_1", "species_cd_1", "non_veg_cover_type_1", "non_veg_cover_pct_1", "land_cover_class_cd_1", "land_cover_class_cd_2", "land_cover_class_cd_3", "bclcs_level_4", "non_forest_descriptor", "non_productive_descriptor_cd", "non_productive_cd", "for_mgmt_land_base_ind", "line_5_vegetation_cover", "line_7b_disturbance_history")
map_sheets = c('094O081','094O082','094O083','094O071','094O072','094O073','094O061','094O062','094O063')

# Connect to database
#con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="cas", host="localhost", port=5432, user="postgres", password="1Boreal!")

# Get geometry and attributes for 2 mapsheets in northeast BC
#y = st_as_sf(pgGetGeom(con, c("rawfri","bc08"), geom="wkb_geometry", other.cols=fri_cols, clauses="WHERE map_id IN ('094O081','094O082','094O083','094O071','094O072','094O073','094O061','094O062','094O063')"))
#dbDisconnect(con)

#dfSummary(y$for_mgmt_land_base_ind, graph.col=FALSE, max.distinct.values=99)
#dfSummary(y$line_5_vegetation_cover, graph.col=FALSE, max.distinct.values=99)
z = filter(y, map_id %in% c("094O081","094O082","094O083","094O071","094O072","094O073","094O061","094O062","094O063"))


# productive_for (from Perl; this has been replaced using the for_mgmt_land_base_ind attribute)
x = mutate(x, mod1=substr(line_7b_disturbance_history, 1,1), mod1yr=substr(line_7b_disturbance_history, 2,3), structure_per = -8888, layer=1, layer_rank=1, productive_for = "PF" )
x = mutate(x, productive_for=if_else((!is.na(species_cd_1) & str_trim(species_cd_1)=="") & (!is.na(crown_closure) | !is.na(proj_height_1)), "PP", productive_for))
x = mutate(x, productive_for=if_else(!is.na(mod1) & mod1=="L", "PF", productive_for))
#x = mutate(x, productive_for=if_else(modcon1!="CC" & species_1=="EMPTY_STRING" & (crown_closure_upper!=-9998 | height_upper!=-9999), "PP", "PF"))


# NFL codes
nfv_fri = c("ST","SL","HF","HE","HG","BY","BM","BL","XX","XX")
nfv_cas = c("ST","SL","HF","HE","HG","BR","BR","BR","OM","BT") # check if "BT" is also "TN"
nnv_fri = c("XX","LA","RE","RI","OC","BR","TA","BI","LB","RO","XX","GL","PN","SI","XX","RM","LL","CB","MN","EL","ES","BE","MU","RS","LS","XX","XX","XX")
nnv_cas = c("AP","LA","LA","RI","OC","RK","RK","RK","RK","RK","SA","SI","SI","SI","SL","EX","EX","EX","EX","EX","EX","BE","WS","WS","WS","FL","IS","TF")
nva_fri = c("MZ","GP","TZ","MI","RZ","RN","AP","XX","UR","XX","XX","OT")
nva_cas = c("IN","IN","IN","IN","FA","FA","FA","CL","SE","LG","BP","OT")
unp_fri = c("XX","XX","AF","NPBU","XX","NP","NPL","GRAVELNP","NC","NTA","NCBR","NSR","NA")
unp_cas = c("TM","TR","AL","SD","SC","NP","NP","NP","PP","PP","PP","PP","PP") # PV: See Perl code for PP class
npd_fri = c("A","AF","C","CL","G","GR","ICE","L","M","MUD","NA","NP","NPBR","NPBU","NTA","OR","P","R","RIV","S","SAND","TIDE","U")
npd_cas = c("AP","","CL","","WS","IN","SI","LA","HG","EX","NULL VALUE","NP","ST","SD","","HG","CL","RK","RI","SL","SA","TF","FA")

# Create NFL attributes
z = mutate(y, un_prod_for="NULL_VALUE",

  # Initialize with null values
  nat_non_veg="NULL_VALUE", non_veg_anth="NULL_VALUE", non_for_veg="NULL_VALUE",
  nat_non_veg2="NULL_VALUE", non_veg_anth2="NULL_VALUE", non_for_veg2="NULL_VALUE",
  nat_non_veg3="NULL_VALUE", non_veg_anth3="NULL_VALUE", non_for_veg3="NULL_VALUE",

  # inventory_standard_cd = "V" or "I"
  
  # Non-forested vegetated: ST, SL, HF, HE, HG, BR, OM, BT
  non_for_veg = case_when(
    #(inventory_standard_cd=="V" | inventory_standard_cd=="I") & (!is.na(species_cd_1) & land_cover_class_cd_1 %in% c("TM","TC","TB","ST","SL")) ~ "NULL_VALUE",
    #(inventory_standard_cd=="V" | inventory_standard_cd=="I") & (!is.na(species_cd_1) & bclcs_level_4 %in% c("TM","TC","TB","ST","SL")) ~ "NULL_VALUE",
    (inventory_standard_cd=="V" | inventory_standard_cd=="I") & (is.na(species_cd_1) & (!is.na(land_cover_class_cd_1) | !is.na(non_veg_cover_type_1) | !is.na(bclcs_level_4))) ~ mapvalues(land_cover_class_cd_1,nfv_fri,nfv_cas),
    TRUE ~ "NULL_VALUE"),
  # Non-vegetated natural: AP, LA, RI, OC, RK, SA, SI, SL, EX, BE, WS, FL, IS, TF
  nat_non_veg = case_when(
    #(inventory_standard_cd=="V" | inventory_standard_cd=="I") & (!is.na(species_cd_1) & land_cover_class_cd_1 %in% c("TM","TC","TB","ST","SL")) ~ "NULL_VALUE",
    #(inventory_standard_cd=="V" | inventory_standard_cd=="I") & (!is.na(species_cd_1) & bclcs_level_4 %in% c("TM","TC","TB","ST","SL")) ~ "NULL_VALUE",
    (inventory_standard_cd=="V" | inventory_standard_cd=="I") & (is.na(species_cd_1) & (!is.na(land_cover_class_cd_1) | !is.na(non_veg_cover_type_1) | !is.na(bclcs_level_4))) ~ mapvalues(non_veg_cover_type_1,nnv_fri,nnv_cas),
    TRUE ~ "NULL_VALUE"),
  # Non-vegetated anthropogencic: IN, FA, CL, SE, LG, BP, OT
  non_veg_anth = case_when(
    #(inventory_standard_cd=="V" | inventory_standard_cd=="I") & (!is.na(species_cd_1) & land_cover_class_cd_1 %in% c("TM","TC","TB","ST","SL")) ~ "NULL_VALUE",
    #(inventory_standard_cd=="V" | inventory_standard_cd=="I") & (!is.na(species_cd_1) & bclcs_level_4 %in% c("TM","TC","TB","ST","SL")) ~ "NULL_VALUE",
    (inventory_standard_cd=="V" | inventory_standard_cd=="I") & (is.na(species_cd_1) & (!is.na(land_cover_class_cd_1) | !is.na(non_veg_cover_type_1) | !is.na(bclcs_level_4))) ~ mapvalues(bclcs_level_4,nva_fri,nva_cas),
    TRUE ~ "NULL_VALUE"),
  # Unproductive forest: TM, TR, AL, SD, SC, NP
  un_prod_for = if_else((inventory_standard_cd=="V" | inventory_standard_cd=="I") & (!is.na(species_cd_1) & (land_cover_class_cd_1 %in% c("TM","TC","TB","ST","SL") | bclcs_level_4 %in% c("TM","TC","TB","ST","SL"))), "PF", "NULL_VALUE"),
  nat_non_veg2 = if_else((inventory_standard_cd=="V" | inventory_standard_cd=="I"), mapvalues(land_cover_class_cd_1,nnv_fri,nnv_cas), nat_non_veg2),
  non_veg_anth2 = if_else((inventory_standard_cd=="V" | inventory_standard_cd=="I"), mapvalues(land_cover_class_cd_1,nva_fri,nva_cas), non_veg_anth2),
  non_for_veg2 = if_else((inventory_standard_cd=="V" | inventory_standard_cd=="I"), mapvalues(non_veg_cover_type_1,nfv_fri,nfv_cas), non_for_veg2),
  non_for_veg3 = if_else((inventory_standard_cd=="V" | inventory_standard_cd=="I"), mapvalues(bclcs_level_4,nfv_fri,nfv_cas), non_for_veg3),
  nat_non_veg3 = if_else((inventory_standard_cd=="V" | inventory_standard_cd=="I"), mapvalues(bclcs_level_4,nnv_fri,nnv_cas), nat_non_veg3),
  non_veg_anth3 = if_else((inventory_standard_cd=="V" | inventory_standard_cd=="I"), mapvalues(bclcs_level_4,nva_fri,nva_cas), non_veg_anth3),
  nat_non_veg = if_else((inventory_standard_cd=="V" | inventory_standard_cd=="I") & (((nat_non_veg=="INVALID") & (non_veg_anth=="INVALID") & (non_for_veg=="INVALID") & (nat_non_veg2=="INVALID") & (non_veg_anth2=="INVALID") & (non_for_veg2=="INVALID") & (nat_non_veg3=="INVALID") & (non_veg_anth3=="INVALID") & (non_for_veg3=="INVALID")) | ((nat_non_veg=="NULL_VALUE") & (non_veg_anth=="NULL_VALUE") & (non_for_veg=="NULL_VALUE") & (nat_non_veg2=="NULL_VALUE") & (non_veg_anth2=="NULL_VALUE") & (non_for_veg2=="NULL_VALUE") & (nat_non_veg3=="NULL_VALUE") & (non_veg_anth3=="NULL_VALUE") & (non_for_veg3=="NULL_VALUE"))), "NOT_IN_SET", nat_non_veg),
  non_for_veg = if_else((inventory_standard_cd=="V" | inventory_standard_cd=="I") & (((nat_non_veg=="INVALID") & (non_veg_anth=="INVALID") & (non_for_veg=="INVALID") & (nat_non_veg2=="INVALID") & (non_veg_anth2=="INVALID") & (non_for_veg2=="INVALID") & (nat_non_veg3=="INVALID") & (non_veg_anth3=="INVALID") & (non_for_veg3=="INVALID")) | ((nat_non_veg=="NULL_VALUE") & (non_veg_anth=="NULL_VALUE") & (non_for_veg=="NULL_VALUE") & (nat_non_veg2=="NULL_VALUE") & (non_veg_anth2=="NULL_VALUE") & (non_for_veg2=="NULL_VALUE") & (nat_non_veg3=="NULL_VALUE") & (non_veg_anth3=="NULL_VALUE") & (non_for_veg3=="NULL_VALUE"))), "NOT_IN_SET", non_for_veg),
  non_veg_anth = if_else((inventory_standard_cd=="V" | inventory_standard_cd=="I") & (((nat_non_veg=="INVALID") & (non_veg_anth=="INVALID") & (non_for_veg=="INVALID") & (nat_non_veg2=="INVALID") & (non_veg_anth2=="INVALID") & (non_for_veg2=="INVALID") & (nat_non_veg3=="INVALID") & (non_veg_anth3=="INVALID") & (non_for_veg3=="INVALID")) | ((nat_non_veg=="NULL_VALUE") & (non_veg_anth=="NULL_VALUE") & (non_for_veg=="NULL_VALUE") & (nat_non_veg2=="NULL_VALUE") & (non_veg_anth2=="NULL_VALUE") & (non_for_veg2=="NULL_VALUE") & (nat_non_veg3=="NULL_VALUE") & (non_veg_anth3=="NULL_VALUE") & (non_for_veg3=="NULL_VALUE"))), "NOT_IN_SET", non_veg_anth),
  # species_cd_1 = something or other; not very clear; see Perl code

  # inventory_standard_cd=="F"
  un_prod_for = if_else(inventory_standard_cd=="F", if_else(is.na(non_forest_descriptor), "NULL_VALUE", mapvalues(non_forest_descriptor,unp_fri,unp_cas)), un_prod_for),
  non_for_veg = if_else(inventory_standard_cd=="F", "NULL_VALUE", non_for_veg),
  nat_non_veg = if_else(inventory_standard_cd=="F", "NULL_VALUE", nat_non_veg),
  non_veg_anth = if_else(inventory_standard_cd=="F", "NULL_VALUE", non_veg_anth),
  un_prod_for = if_else(inventory_standard_cd=="F" & (un_prod_for=="INVALID" | un_prod_for=="NULL_VALUE"), if_else(is.na(non_productive_descriptor_cd), "NULL_VALUE", mapvalues(non_productive_descriptor_cd,unp_fri,unp_cas)), un_prod_for),
  non_for_veg = if_else(inventory_standard_cd=="F" & (un_prod_for=="INVALID" | un_prod_for=="NULL_VALUE"), if_else(is.na(non_productive_descriptor_cd), "NULL_VALUE", mapvalues(non_productive_descriptor_cd,nfv_fri,nfv_cas)), non_for_veg),
  nat_non_veg = if_else(inventory_standard_cd=="F" & (un_prod_for=="INVALID" | un_prod_for=="NULL_VALUE"), if_else(is.na(non_productive_descriptor_cd), "NULL_VALUE", mapvalues(non_productive_descriptor_cd,nnv_fri,nnv_cas)), nat_non_veg),
  
  non_veg_anth = if_else(inventory_standard_cd=="F" & (un_prod_for=="INVALID" | un_prod_for=="NULL_VALUE"), mapvalues(non_productive_descriptor_cd,nva_fri,nva_cas), non_veg_anth),
  non_for_veg = if_else(inventory_standard_cd=="F" & (((nat_non_veg=="INVALID") & (non_veg_anth=="INVALID") & (non_for_veg=="INVALID") & (un_prod_for=="INVALID")) | ((nat_non_veg=="NULL_VALUE") & (un_prod_for=="NULL_VALUE") & (non_veg_anth=="NULL_VALUE") & (non_for_veg=="NULL_VALUE"))), if_else(bclcs_level_4=="ST" | bclcs_level_4=="SL", "NULL_VALUE", non_for_veg), non_for_veg),
  nat_non_veg = if_else(inventory_standard_cd=="F" & ((nat_non_veg=="INVALID" & non_veg_anth=="INVALID" & non_for_veg=="INVALID" & un_prod_for=="INVALID") | (nat_non_veg=="NULL_VALUE" & un_prod_for=="NULL_VALUE" & non_veg_anth=="NULL_VALUE" & non_for_veg=="NULL_VALUE")), if_else(bclcs_level_4=="ST" | bclcs_level_4=="SL", "NULL_VALUE", nat_non_veg), nat_non_veg),
  non_veg_anth = if_else(inventory_standard_cd=="F" & ((nat_non_veg=="INVALID" & non_veg_anth=="INVALID" & non_for_veg=="INVALID" & un_prod_for=="INVALID") | (nat_non_veg=="NULL_VALUE" & un_prod_for=="NULL_VALUE" & non_veg_anth=="NULL_VALUE" & non_for_veg=="NULL_VALUE")), if_else(bclcs_level_4=="ST" | bclcs_level_4=="SL", "NULL_VALUE", non_veg_anth), non_veg_anth),
  non_for_veg = if_else(inventory_standard_cd=="F" & ((nat_non_veg=="INVALID" & non_veg_anth=="INVALID" & non_for_veg=="INVALID" & un_prod_for=="INVALID") | (nat_non_veg=="NULL_VALUE" & un_prod_for=="NULL_VALUE" & non_veg_anth=="NULL_VALUE" & non_for_veg=="NULL_VALUE")), if_else(bclcs_level_4=="TM" | bclcs_level_4=="TC" | bclcs_level_4=="TB" | bclcs_level_4=="ST" | bclcs_level_4=="SL", "NULL_VALUE", non_for_veg), non_for_veg),
  nat_non_veg = if_else(inventory_standard_cd=="F" & ((nat_non_veg=="INVALID" & non_veg_anth=="INVALID" & non_for_veg=="INVALID" & un_prod_for=="INVALID") | (nat_non_veg=="NULL_VALUE" & un_prod_for=="NULL_VALUE" & non_veg_anth=="NULL_VALUE" & non_for_veg=="NULL_VALUE")), if_else(bclcs_level_4=="TM" | bclcs_level_4=="TC" | bclcs_level_4=="TB" | bclcs_level_4=="ST" | bclcs_level_4=="SL", "NULL_VALUE", nat_non_veg), nat_non_veg),
  non_veg_anth = if_else(inventory_standard_cd=="F" & ((nat_non_veg=="INVALID" & non_veg_anth=="INVALID" & non_for_veg=="INVALID" & un_prod_for=="INVALID") | (nat_non_veg=="NULL_VALUE" & un_prod_for=="NULL_VALUE" & non_veg_anth=="NULL_VALUE" & non_for_veg=="NULL_VALUE")), if_else(bclcs_level_4=="TM" | bclcs_level_4=="TC" | bclcs_level_4=="TB" | bclcs_level_4=="ST" | bclcs_level_4=="SL", "NULL_VALUE", non_veg_anth), non_veg_anth),
  nat_non_veg = if_else(inventory_standard_cd=="F" & nat_non_veg=="INVALID","NOT_IN_SET",nat_non_veg),
  non_for_veg = if_else(inventory_standard_cd=="F" & non_for_veg=="INVALID","NOT_IN_SET",non_for_veg),
  non_veg_anth = if_else(inventory_standard_cd=="F" & non_veg_anth=="INVALID","NOT_IN_SET",non_veg_anth),
  un_prod_for = if_else(inventory_standard_cd=="F" & un_prod_for=="INVALID","NOT_IN_SET",un_prod_for),

  # is_nfor
  is_nfor = if_else((!nat_non_veg=="NULL_VALUE" & !nat_non_veg=="NOT_IN_SET") | (!non_veg_anth=="NULL_VALUE" & !non_veg_anth=="NOT_IN_SET") | (!non_for_veg=="NULL_VALUE" & !non_for_veg=="NOT_IN_SET"), 1, 0)
)
