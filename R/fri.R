# Connect to an inventory
# 2019-08-21

library(rpostgis)
library(tidyverse)
library(summarytools)

friConnect = function(inv, n) {
    con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")
    x = as_tibble(dbGetQuery(con, paste0("SELECT * FROM rawfri.",inv," LIMIT ",n))
    dbDisconnect(con)
    return(x)
}
