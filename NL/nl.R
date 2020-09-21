# NL NL01 Inventory
# PV 2020-09-21

library(rpostgis)
library(summarytools)

# Read inventory
con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")

# NL01
nl = RPostgreSQL::dbGetQuery(con, "SELECT * FROM rawfri.nl01")
sink("NL/nl01_fli01.otl")
cat("= V7 Outline MultiLine NoSorting TabWidth=30\n\n")
print(names(nl))
for (i in names(nl)) {
    cat("\nH=", i,"\n", sep="")
    print(dfSummary(nl[[i]], graph.col=FALSE, max.distinct.values = 20))
}
sink()

dbDisconnect(con)
