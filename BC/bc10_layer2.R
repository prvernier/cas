library(rpostgis)
library(tidyverse)
library(summarytools)

con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")
bc10 = dbGetQuery(con, "SELECT * FROM rawfri.bc10 LIMIT 10000")
dbDisconnect(con)

y = as_tibble(x) %>% filter(l2_layer_id==2) %>%
    select(l1_crown_closure, l2_crown_closure, l1_species_cd_1, l2_species_cd_1, l1_species_pct_1, l2_species_pct_1, l1_proj_height_1, l2_proj_height_1, l1_proj_age_1, l2_proj_age_1)
y

con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")
a = dbGetQuery(con, "SELECT * FROM rawfri.bc10_l1_to_bc_l1_map_200")
b = dbGetQuery(con, "SELECT * FROM rawfri.bc10_l1_to_bc_l1_map_200")
dbDisconnect(con)

a = as_tibble(a)