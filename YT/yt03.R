# YT03 Inventory
# PV 2021-02-18

library(rpostgis)
library(summarytools)

# Read inventory
con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")
x = RPostgreSQL::dbGetQuery(con, "SELECT * FROM rawfri.yt01")

#sink("YT/yt03.txt")
#dfSummary(x, graph.col=FALSE, max.distinct.values = 20)
#sink()

sink("YT/yt01.otl")
cat("= V7 Outline MultiLine NoSorting TabWidth=30\n\n")
print(names(x))
for (i in names(x)) {
    cat("\nH=", i,"\n", sep="")
    flush.console()
    print(dfSummary(x[[i]], graph.col=FALSE, max.distinct.values = 20))
}
sink()

dbDisconnect(con)
