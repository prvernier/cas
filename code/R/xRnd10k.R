library(rpostgis)

# Connect to cas database
con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="cas", host="localhost", port=5432, user="postgres", password="postgres")

# rawfri schema - create random sample of tables
dbGetQuery(con, "DROP TABLE rawfri.ab06_rnd10k;")
dbGetQuery(con, "SELECT * INTO rawfri.ab06_rnd10k FROM rawfri.ab06 LIMIT 10000;")

dbGetQuery(con, "DROP TABLE rawfri.ab16_rnd10k;")
dbGetQuery(con, "SELECT * INTO rawfri.ab16_rnd10k FROM rawfri.ab16 LIMIT 10000;")

dbGetQuery(con, "DROP TABLE rawfri.bc08_rnd10k;")
dbGetQuery(con, "SELECT * INTO rawfri.bc08_rnd10k FROM rawfri.bc08 LIMIT 10000;")

dbGetQuery(con, "DROP TABLE rawfri.nb01_rnd10k;")
dbGetQuery(con, "SELECT * INTO rawfri.nb01_rnd10k FROM rawfri.nb01 LIMIT 10000;")
#dbGetQuery(con, "SELECT * INTO rawfri.nb01_rnd10k FROM rawfri.nb01 WHERE STDLAB>0 LIMIT 10000;")

# casfri50 schema - create random sample of tables
dbGetQuery(con, "DROP TABLE casfri50.ab06_rnd10k;")
dbGetQuery(con, "SELECT * INTO casfri50.ab06_rnd10k FROM casfri50.ab06 LIMIT 10000;")

dbGetQuery(con, "DROP TABLE casfri50.ab16_rnd10k;")
dbGetQuery(con, "SELECT * INTO casfri50.ab16_rnd10k FROM casfri50.ab16 LIMIT 10000;")

dbGetQuery(con, "DROP TABLE casfri50.bc08_rnd10k;")
dbGetQuery(con, "SELECT * INTO casfri50.bc08_rnd10k FROM casfri50.bc08 LIMIT 10000;")

dbGetQuery(con, "DROP TABLE casfri50.nb01_rnd10k;")
dbGetQuery(con, "SELECT * INTO casfri50.nb01_rnd10k FROM casfri50.nb01 LIMIT 10000;")
