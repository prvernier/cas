library(rpostgis)
library(tidyverse)
library(summarytools)

con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")
x1 = as_tibble(dbGetQuery(con, "SELECT * FROM rawfri.nb01")) # LIMIT 10000"))
#x2 = as_tibble(dbGetQuery(con, "SELECT * FROM rawfri.nb02")) # LIMIT 10000"))
dbDisconnect(con)

sink("NB/nb01.txt")
dfSummary(x1, graph.col=FALSE)
sink()

sink("NB/nb02.txt")
dfSummary(x2, graph.col=FALSE)
sink()

