# SK SFV01 Inventories
# PV 2020-05-04

library(rpostgis)
library(summarytools)


# Sk02 Inventory
con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")
sk = RPostgreSQL::dbGetQuery(con, "SELECT * FROM rawfri.sk02")
sink("SK/SFV01/sk02.txt")
cat("FRI Attributes\n---------------------\n\n")
print(names(sk))
for (i in names(sk)) {
    cat("\n\n", toupper(i),"\n\n", sep="")
    print(dfSummary(sk[[i]], graph.col=FALSE))
}
sink()
dbDisconnect(con)


# sk03 Inventory
con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")
sk = RPostgreSQL::dbGetQuery(con, "SELECT * FROM rawfri.sk03")
sink("SK/SFV01/sk03.txt")
cat("FRI Attributes\n---------------------\n\n")
print(names(sk))
for (i in names(sk)) {
    cat("\n\n", toupper(i),"\n\n", sep="")
    print(dfSummary(sk[[i]], graph.col=FALSE))
}
sink()
dbDisconnect(con)


# sk04 Inventory
con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")
sk = RPostgreSQL::dbGetQuery(con, "SELECT * FROM rawfri.sk04")
sink("SK/SFV01/sk04.txt")
cat("FRI Attributes\n---------------------\n\n")
print(names(sk))
for (i in names(sk)) {
    cat("\n\n", toupper(i),"\n\n", sep="")
    print(dfSummary(sk[[i]], graph.col=FALSE))
}
sink()
dbDisconnect(con)


# sk05 Inventory
con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")
sk5 = RPostgreSQL::dbGetQuery(con, "SELECT * FROM rawfri.sk05")
sink("SK/SFV01/sk05.txt")
cat("FRI Attributes\n---------------------\n\n")
print(names(sk))
for (i in names(sk)) {
    cat("\n\n", toupper(i),"\n\n", sep="")
    print(dfSummary(sk[[i]], graph.col=FALSE))
}
sink()
dbDisconnect(con)


# sk06 Inventory
con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")
sk6 = RPostgreSQL::dbGetQuery(con, "SELECT * FROM rawfri.sk06")
sink("SK/SFV01/sk06.txt")
cat("FRI Attributes\n---------------------\n\n")
print(names(sk))
for (i in names(sk)) {
    cat("\n\n", toupper(i),"\n\n", sep="")
    print(dfSummary(sk[[i]], graph.col=FALSE))
}
sink()
dbDisconnect(con)
