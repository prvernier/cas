# SK SFV01 Inventories
# PV 2020-06-12

library(rpostgis)
library(summarytools)


# Read inventory
con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")

# MB05
mb5 = RPostgreSQL::dbGetQuery(con, "SELECT * FROM rawfri.mb05")
sink("MB/mb05.txt")
cat("FRI Attributes\n---------------------\n\n")
print(names(mb5))
for (i in names(mb5)) {
    cat("\n\n", toupper(i),"\n\n", sep="")
    print(dfSummary(mb5[[i]], graph.col=FALSE))
}
sink()

# MB06
mb6 = RPostgreSQL::dbGetQuery(con, "SELECT * FROM rawfri.mb06")
sink("MB/mb06.txt")
cat("FRI Attributes\n---------------------\n\n")
print(names(mb6))
for (i in names(mb6)) {
    cat("\n\n", toupper(i),"\n\n", sep="")
    print(dfSummary(mb6[[i]], graph.col=FALSE))
}
sink()

dbDisconnect(con)
