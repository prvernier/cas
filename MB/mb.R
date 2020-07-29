# SK SFV01 Inventories
# PV 2020-07-29

library(rpostgis)
library(summarytools)

# Read inventory
con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")

# MB05
mb5 = RPostgreSQL::dbGetQuery(con, "SELECT * FROM rawfri.mb05")
sink("MB/mb05_fri01.otl")
cat("= V7 Outline MultiLine NoSorting TabWidth=30\n\n")
print(names(mb5))
for (i in names(mb5)) {
    cat("\nH=", i,"\n", sep="")
    print(dfSummary(mb5[[i]], graph.col=FALSE, max.distinct.values = 20))
}
sink()

# MB06
mb6 = RPostgreSQL::dbGetQuery(con, "SELECT * FROM rawfri.mb06")
sink("MB/mb06_fli01.otl")
cat("= V7 Outline MultiLine NoSorting TabWidth=30\n\n")
for (i in names(mb6)) {
    cat("\nH=", i,"\n", sep="")
    print(dfSummary(mb6[[i]], graph.col=FALSE, max.distinct.values = 20))
}
sink()

dbDisconnect(con)
