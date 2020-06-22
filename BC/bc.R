# SK SFV01 Inventories
# PV 2020-06-12

library(rpostgis)
library(summarytools)

con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")
bc = RPostgreSQL::dbGetQuery(con, "SELECT * FROM rawfri.bc10")
dbDisconnect(con)

di = substr(bc$line_7b_disturbance_history,1,1)

bc$line_7b_disturbance_history[bc$dist_1=="N"]
