library(rpostgis)
library(tidyverse)
library(summarytools)

con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="cas", host="localhost", port=5432, user="postgres", password="1Boreal!")

sql2 = "SELECT src_filename, trm_1, poly_num, ogc_fid, cas_id, moist_reg, soil_moist_reg, struc_val, structure_per,
    layer, layer_rank, density, crown_closure_lower, crown_closure_upper, height, height_upper, height_lower, 
    productive_for, sp1, species_1, sp1_per, species_per_1, origin, origin_lower, origin_upper, tpr, site_class, site_index
    FROM casfri50.ab06, rawfri.ab06 WHERE poly_num = substr(cas_id, 33, 10)::int;"

#for (i in c("cas","lyr","nfl","dst","eco")) {
for (i in c("lyr")) {
    x = dbGetQuery(con, "SELECT * FROM casfri50.ab06") #%>% mutate(cas_id=NULL)
    write_csv(x, paste0("output/ab06/cas05_ab06_",i,".csv"))
    sink(paste0("output/ab06/cas05_ab06_",i,".txt"))
    print(dfSummary(x, graph.col=FALSE, max.distinct.values=99))
    sink()
    x2 = dbGetQuery(con, sql2) #%>% mutate(cas_id=NULL)
    write_csv(x2, paste0("output/ab06/cas05_ab06_",i,"_inout.csv"))
    sink(paste0("output/ab06/cas05_ab06_",i,"_inout.txt"))
    print(dfSummary(x2, graph.col=FALSE, max.distinct.values=99))
    sink()
}


