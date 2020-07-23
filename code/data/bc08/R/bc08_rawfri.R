library(plyr)
library(rpostgis)
library(tidyverse)
library(summarytools)

con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="cas", host="localhost", port=5432, user="postgres", password="1Boreal!")

bc08 = as_tibble(dbGetQuery(con, "SELECT soil_moisture_regime_1, crown_closure, proj_height_1, layer_id, species_cd_1, species_pct_1, site_index, proj_age_1, line_7b_disturbance_history FROM rawfri.bc08"))
write_csv(bc08, "data/bc08/rawfri_bc08_in.csv")
sink("data/rawfri_bc08_in.txt"); print(dfSummary(bc08, graph.col=FALSE, max.distinct.values=99)); sink()
bc = bc08 %>%
    mutate(mod1=substr(line_7b_disturbance_history, 1,1), mod1yr=substr(line_7b_disturbance_history, 2,3), structure_per = -8888, layer=1, layer_rank=1, productive_for = "PF" ) %>%
    mutate(productive_for=if_else((!is.na(species_cd_1) & (species_cd_1=="" | species_cd_1==" ")) & (!is.na(crown_closure) | !is.na(proj_height_1)), "PP", productive_for)) %>%
    mutate(productive_for=if_else(!is.na(mod1) & mod1=="L", "PF", productive_for))
write_csv(bc08, "data/bc08/rawfri_bc08_out.csv")
sink("data/rawfri_bc08_out.txt"); dfSummary(bc, graph.col=FALSE, max.distinct.values=99); sink()

# by inventory_standard_cd

