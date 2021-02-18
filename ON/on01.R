# ON01 Inventory
# PV 2021-02-11

library(rpostgis)
library(summarytools)

# Read inventory
con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")

# ON01
on01 = RPostgreSQL::dbGetQuery(con, "SELECT * FROM rawfri.on01")

sink("ON01/on01.txt")
dfSummary(on01, graph.col=FALSE, max.distinct.values = 20)
sink()

sink("ON01/on01.otl")
cat("= V7 Outline MultiLine NoSorting TabWidth=30\n\n")
print(names(on01))
for (i in names(on01)) {
    cat("\nH=", i,"\n", sep="")
    print(dfSummary(on01[[i]], graph.col=FALSE, max.distinct.values = 20))
}
sink()

# ON02
on02 = RPostgreSQL::dbGetQuery(con, "SELECT * FROM rawfri.on02")
sink("ON02/on02.otl")
cat("= V7 Outline MultiLine NoSorting TabWidth=30\n\n")
print(names(on01))
for (i in names(on01)) {
    cat("\nH=", i,"\n", sep="")
    print(dfSummary(on01[[i]], graph.col=FALSE, max.distinct.values = 20))
}
sink()

dbDisconnect(con)
