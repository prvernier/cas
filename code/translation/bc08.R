library(rpostgis)
library(tidyverse)
library(summarytools)

sink("output/bc08.md")
cat("# BC08 Attributes\n\n")

con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="cas", host="localhost", port=5433, user="postgres", password="postgres")
df = dbGetQuery(con, "SELECT inventory_standard_cd, map_id, reference_year, crown_closure, proj_height_1, species_cd_1, species_pct_1, species_cd_2, species_pct_2, species_cd_3, species_pct_3, species_cd_4, species_pct_4, species_cd_5, species_pct_5, species_cd_6, species_pct_6, objectid FROM fri.bc08 limit 1000;")

# CAS_ID
cat("## CAS_ID\n\n")

#x1 = paste0("BC_000",plyr::mapvalues(df$inventory_standard_cd, from=c("F","V","I","L"), to=c("4","5","6","7")))
x1 = "BC08"
x2 = "VEG_COMP_LYR_R1"
x3 = paste0("xxx",df$map_id)
x4 = sprintf("%010d",df$objectid)
x5 = sprintf("%07d",1:nrow(df))
df$cas_id = paste0(x1,"-",x2,"-",x3,"-",x4,"-",x5)
print(head(df[,c("objectid","cas_id")]))

# PHOTO_YEAR
cat("\n## PHOTO_YEAR\n\n")
cat("The year of photography is included in the attributes table (REFERENCE_YEAR).\n\n")

df$photo_year = df$reference_year
print(head(df[,c("reference_year","photo_year")]))

cat("\n## SPECIES_1 - SPECIES_10\n\n")
cat("  * Tabulate all species codes across species fields.\n")
cat("  * Check that all species codes exist in CAS04 species list for BC\n\n")

spp = unique(c(df$species_cd_1,df$species_cd_2,df$species_cd_3,df$species_cd_4,df$species_cd_5,df$species_cd_6))
cat(spp,"\n")

cat("\n## SPECIES_PER_1 - SPECIES_PER_10\n\n")
cat("  * Tabulate all species percentages to ensure they are within 0-100.\n")
cat("  * Values are not integers!\n\n")

spp_pct = unique(c(df$species_pct_1,df$species_pct_2,df$species_pct_3,df$species_pct_4,df$species_pct_5,df$species_pct_6))
cat("Range of values:",range(spp_pct, na.rm=T),"\n")
cat("Unique values:",sort(spp_pct),"\n")

cat("\n## CROWN_CLOSURE_LOWER, CROWN_CLOSURE_HIGHER\n\n")

print(suppressMessages(dfSummary(df$crown_closure)))

cat("\n## HEIGHT_LOWER, HEIGHT_UPPER\n\n")

print(suppressMessages(dfSummary(df$proj_height_1)))

sink()