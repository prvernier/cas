library(sf)
library(rpostgis)
library(tidyverse)
library(summarytools)

con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")
x = as_tibble(dbGetQuery(con, "SELECT * FROM rawfri.bc09 LIMIT 10000"))
y = dbGetQuery(con, "SELECT * FROM rawfri.bc09")
dbDisconnect(con)

x1 = st_read("C:/Users/PIVER37/Documents/ArcGIS/Default.gdb", "Metro_L1")
x2 = st_read("C:/Users/PIVER37/Documents/ArcGIS/Default.gdb", "Metro_L2")
xd = st_read("C:/Users/PIVER37/Documents/ArcGIS/Default.gdb", "Metro_D")

sink("metro/BC10_L1.txt")
dfSummary(x1, graph.col=FALSE)
sink()

sink("metro/BC10_L2.txt")
dfSummary(x2, graph.col=FALSE)
sink()

sink("metro/BC10_D.txt")
dfSummary(xd, graph.col=FALSE)
#dfSummary(x$cl_age, graph.col=F, max.distinct.values=99)
sink()
