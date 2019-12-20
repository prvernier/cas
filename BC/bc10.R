# BC10 translation test code
# PV 2019-12-17

library(rpostgis)
library(tidyverse)
library(summarytools)

con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")
x = dbGetQuery(con, "SELECT * FROM rawfri.bc10 LIMIT 10000") %>%
	select(projected_date, for_mgmt_land_base_ind, soil_moisture_regime_1,
		l1_layer_id, l1_for_cover_rank_cd, l1_crown_closure, l1_species_cd_1, l1_species_pct_1, l1_proj_height_1, l1_proj_age_1, l1_site_index, l1_est_site_index,
		l2_layer_id, l2_for_cover_rank_cd, l2_crown_closure, l2_species_cd_1, l2_species_pct_1, l2_proj_height_1, l2_proj_age_1, l2_site_index, l2_est_site_index,
		d_layer_id, d_for_cover_rank_cd, d_crown_closure, d_species_cd_1, d_species_pct_1, d_proj_height_1, d_proj_age_1, d_site_index, d_est_site_index)
dbDisconnect(con)

# SOIL_MOIST_REG
# Source attribute: soil_moisture_regime_1
x = mutate(x, soil_moist_reg = case_when(
    is.na(soil_moisture_regime_1) ~ "NULL_VALUE",
    str_trim(soil_moisture_regime_1)=="" ~ "EMPTY_STRING",
    soil_moisture_regime_1 %in% c(0,1,2) ~ "D",
    soil_moisture_regime_1 %in% c(3,4) ~ "F",
    soil_moisture_regime_1 %in% c(5,6) ~ "M",
    soil_moisture_regime_1 %in% c(7,8) ~ "W",
    TRUE ~ "NOT_IN_SET"))
dfSummary(x["soil_moisture_regime_1"], graph.col=FALSE, max.distinct.values=99)
dfSummary(x["soil_moist_reg"], graph.col=FALSE, max.distinct.values=99)

# STRUCTURE_PER
# source attribute: ?

# LAYER
# source attribute: l1_layer_id
x = mutate(x, layer = case_when(
    is.na(l1_layer_id) ~ "NULL_VALUE",
    str_trim(l1_layer_id)=="" ~ "EMPTY_STRING",
    TRUE ~ l1_layer_id))
dfSummary(x["l1_layer_id"], graph.col=FALSE, max.distinct.values=99)
dfSummary(x["layer"], graph.col=FALSE, max.distinct.values=99)

# LAYER_RANK
# source attribute: l1_for_cover_rank_cd
x = mutate(x, layer_rank = case_when(
    is.na(l1_for_cover_rank_cd) ~ "NULL_VALUE",
    str_trim(l1_for_cover_rank_cd)=="" ~ "EMPTY_STRING",
    TRUE ~ l1_for_cover_rank_cd))
dfSummary(x["l1_for_cover_rank_cd"], graph.col=FALSE, max.distinct.values=99)
dfSummary(x["layer_rank"], graph.col=FALSE, max.distinct.values=99)

# CROWN_CLOSURE
# source attribute: l1_crown_closure
x = mutate(x, crown_closure_upper=case_when(
    is.na(l1_crown_closure) ~ as.integer(-8888),
    l1_crown_closure < 0 | l1_crown_closure > 100 ~ as.integer(-9999),
    TRUE ~ l1_crown_closure),
    crown_closure_lower=crown_closure_upper)
dfSummary(x["l1_crown_closure"], graph.col=FALSE)
dfSummary(x["crown_closure_upper"], graph.col=FALSE)
dfSummary(x["crown_closure_lower"], graph.col=FALSE)

# HEIGHT 
# source attribute: l1_proj_height_1
x = mutate(x, height_upper=case_when(
    is.na(l1_proj_height_1) ~ -8888,
    l1_proj_height_1 < 0.1 | l1_proj_height_1 > 100 ~ -9999,
    TRUE ~ l1_proj_height_1),
    height_lower=height_upper)
dfSummary(x["l1_proj_height_1"], graph.col=FALSE, max.distinct.values=99)
dfSummary(x["height_upper"], graph.col=FALSE, max.distinct.values=99)
dfSummary(x["height_lower"], graph.col=FALSE, max.distinct.values=99)

# PRODUCTIVE_FOR
# source attribute: for_mgmt_land_base_ind
x = mutate(x, productive_for = if_else(
    for_mgmt_land_base_ind=="Y", "PF", "PP"))
dfSummary(x["for_mgmt_land_base_ind"], graph.col=FALSE, max.distinct.values=99)
dfSummary(x["productive_for"], graph.col=FALSE, max.distinct.values=99)

# SPECIES
# source attribute: l1_species_cd_1 - l1_species_cd_6
sppList = read_csv("../CASFRI/translation/tables/lookup/bc_vri01_species.csv")
x = mutate(x, species_1=case_when(
    is.na(l1_species_cd_1) ~ "NULL_VALUE",
    str_trim(l1_species_cd_1)=="" ~ "EMPTY_STRING",
    !l1_species_cd_1 %in% sppList$source_val ~ "NOT_IN_SET",
    TRUE ~ plyr::mapvalues(l1_species_cd_1, sppList$source_val, sppList$spec1)))
dfSummary(x["l1_species_cd_1"], graph.col=FALSE, max.distinct.values=99)
dfSummary(x["species_1"], graph.col=FALSE, max.distinct.values=99)

# SPECIES_PER
# source attribute: l1_species_cd_1 - l1_species_cd_6
x = mutate(x, species_per_1=case_when(
    is.na(l1_species_pct_1) ~ -8888,
    l1_species_pct_1 < 0 | l1_species_pct_1 > 100 ~ -9999,
    TRUE ~ l1_species_pct_1))
dfSummary(x["l1_species_pct_1"], graph.col=FALSE, max.distinct.values=99)
dfSummary(x["species_per_1"], graph.col=FALSE, max.distinct.values=99)

# ORIGIN
# source attribute: l1_proj_age_1
x = mutate(x, projected_year=as.double(substr(projected_date, 1, 4)),
	origin_upper=case_when(
	is.na(l1_proj_age_1) ~ -8888,
	l1_proj_age_1==0 ~ -9999,
	TRUE ~ projected_year - l1_proj_age_1),
	origin_lower=origin_upper)
#dfSummary(x["projected_date"], graph.col=FALSE, max.distinct.values=99)
#dfSummary(x["projected_year"], graph.col=FALSE, max.distinct.values=99)
dfSummary(x["l1_proj_age_1"], graph.col=FALSE, max.distinct.values=99)
dfSummary(x["origin_upper"], graph.col=FALSE, max.distinct.values=99)
dfSummary(x["origin_lower"], graph.col=FALSE, max.distinct.values=99)

# SITE_CLASS
# source attribute: ?

# SITE_INDEX
# source_attribute: site_index if available or est_site_index otherwise
x = mutate(x, site_index=case_when(
    is.na(l1_site_index) & is.na(l1_est_site_index) ~ -8888,
    is.na(l1_site_index) & !is.na(l1_est_site_index) ~ l1_est_site_index,
    TRUE ~ l1_site_index))
dfSummary(x["l1_site_index"], graph.col=FALSE)
dfSummary(x["l1_est_site_index"], graph.col=FALSE)
dfSummary(x["site_index"], graph.col=FALSE)
