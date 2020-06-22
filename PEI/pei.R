# SK SFV01 Inventories
# PV 2020-06-12

library(rpostgis)
library(summarytools)


# Read inventory
con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")
pe = RPostgreSQL::dbGetQuery(con, "SELECT * FROM rawfri.pe01")
sink("PEI/pe01.txt")
cat("FRI Attributes\n---------------------\n\n")
print(names(pe))
for (i in names(pe)) {
    cat("\n\n", toupper(i),"\n\n", sep="")
    print(dfSummary(pe[[i]], graph.col=FALSE))
}
sink()
dbDisconnect(con)


# General Notes

  * two layers (layer 1 + disturbance; NFL)

