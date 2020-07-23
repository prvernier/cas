library(rpostgis)
library(tidyverse)
library(summarytools)

con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="cas", host="localhost", port=5432, user="postgres", password="1Boreal!")

# LYR
ab06 = dbGetQuery(con, "SELECT * FROM casfri50.ab06 WHERE cas_id LIKE 'AB06%'") %>% mutate(cas_id=NULL)
sink("output/cas05_lyr_ab06.txt"); print(dfSummary(ab06, graph.col=FALSE, max.distinct.values=999)); sink()
ab16 = dbGetQuery(con, "SELECT * FROM casfri50.ab16 WHERE cas_id LIKE 'AB16%'") %>% mutate(cas_id=NULL)
sink("output/cas05_lyr_ab16.txt"); print(dfSummary(ab16, graph.col=FALSE, max.distinct.values=999)); sink()
bc08 = dbGetQuery(con, "SELECT * FROM casfri50.bc08 WHERE cas_id LIKE 'BC08%'") %>% mutate(cas_id=NULL)
sink("output/cas05_lyr_bc08.txt"); print(dfSummary(bc08, graph.col=FALSE, max.distinct.values=999)); sink()
nb01 = dbGetQuery(con, "SELECT * FROM casfri50.nb01 WHERE cas_id LIKE 'NB01%'") %>% mutate(cas_id=NULL)
sink("output/cas05_lyr_nb01.txt"); print(dfSummary(nb01, graph.col=FALSE, max.distinct.values=999)); sink()

# LYR
ab06 = read_csv("output/cas04_ab_0006_nfl.csv") %>% mutate(cas_id=NULL)
sink("output/cas04_nfl_ab06.txt"); print(dfSummary(ab06, graph.col=FALSE, max.distinct.values=999)); sink()
