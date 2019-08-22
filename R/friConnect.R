# This file needs to be run once prior to rendering the markdown files
# 2019-08-21

library(plyr)
library(readxl)
library(rpostgis)
library(rmarkdown)
library(tidyverse)
library(summarytools)

friConnect = function(inv) {
    # First line connects to server database and second to notebook database
    con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")
    #con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="cas", host="localhost", port=5432, user="postgres", password="1Boreal!")
    if (inv=="ab06") {
        x = as_tibble(dbGetQuery(con, "SELECT * FROM rawfri.ab06"))
        #x = as_tibble(dbGetQuery(con, "SELECT moist_reg, density, height, sp1, sp1_per, struc_val, tpr, mod1, origin, nfl, nat_non, anth_veg, anth_non, shape_length, shape_area FROM rawfri.ab06"))
    } else if (inv=="ab16") {
        x = as_tibble(dbGetQuery(con, "SELECT * FROM rawfri.ab16"))
        #x = as_tibble(dbGetQuery(con, "SELECT moisture, crownclose, height, sp1, sp1_percnt, std_struct, tpr, modcon1, origin, nonfor_veg, anthro_veg, anth_noveg, nat_nonveg FROM rawfri.ab16"))
    } else if (inv=="bc04") {
        x = as_tibble(dbGetQuery(con, "SELECT map_id, feature_id, inventory_standard_cd, soil_moisture_regime_1, crown_closure, proj_height_1, layer_id, species_cd_1, species_pct_1, species_cd_2, site_index, est_site_index, est_site_index_source_cd, proj_age_1, non_veg_cover_type_1, non_veg_cover_pct_1, land_cover_class_cd_1, land_cover_class_cd_2, land_cover_class_cd_3, bclcs_level_1, bclcs_level_2, bclcs_level_3, bclcs_level_4, bclcs_level_5, non_forest_descriptor, non_productive_descriptor_cd, non_productive_cd, for_mgmt_land_base_ind, line_5_vegetation_cover, line_6_site_prep_history, line_7b_disturbance_history, line_8_planting_history, reference_year, projected_date, reference_date, shape_length, shape_area, bec_zone_code, bec_subzone, bec_variant, bec_phase, site_position_meso FROM rawfri.bc04"))
    } else if (inv=="bc08") {
        x = as_tibble(dbGetQuery(con, "SELECT map_id, feature_id, inventory_standard_cd, soil_moisture_regime_1, crown_closure, proj_height_1, layer_id, species_cd_1, species_pct_1, species_cd_2, site_index, est_site_index, est_site_index_source_cd, proj_age_1, non_veg_cover_type_1, non_veg_cover_pct_1, land_cover_class_cd_1, land_cover_class_cd_2, land_cover_class_cd_3, bclcs_level_1, bclcs_level_2, bclcs_level_3, bclcs_level_4, bclcs_level_5, non_forest_descriptor, non_productive_descriptor_cd, non_productive_cd, for_mgmt_land_base_ind, line_5_vegetation_cover, line_6_site_prep_history, line_7b_disturbance_history, line_8_planting_history, reference_year, projected_date, reference_date, shape_length, shape_area, bec_zone_code, bec_subzone, bec_variant, bec_phase, site_position_meso FROM rawfri.bc08"))
    } else if (inv=="nb01") {
        #x = as_tibble(dbGetQuery(con, "SELECT ogc_fid, fst, sitei, l1cc, l1ht, l1s1, l1pr1, l1estyr, l1trt, l1trtyr, l1vs, l2cc, l2ht, l2s1, l2pr1, l2estyr, l2trt, l2trtyr, l2vs FROM rawfri.nb01"))
        x = as_tibble(dbGetQuery(con, "SELECT * FROM rawfri.nb01"))
    } else if (inv=="nb02") {
        #x = as_tibble(dbGetQuery(con, "SELECT ogc_fid, fst, sitei, l1cc, l1ht, l1s1, l1pr1, l1estyr, l1trt, l1trtyr, l1vs, l2cc, l2ht, l2s1, l2pr1, l2estyr, l2trt, l2trtyr, l2vs FROM rawfri.nb01"))
        x = as_tibble(dbGetQuery(con, "SELECT * FROM rawfri.nb02"))
    } else {
        stop('There is no inventory with that name!')
    }
    dbDisconnect(con)
    return(x)
}
