library(rpostgis)
library(tidyverse)
library(summarytools)

con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")
x1 = as_tibble(dbGetQuery(con, "SELECT * FROM rawfri.nb01"))
x2 = as_tibble(dbGetQuery(con, "SELECT * FROM rawfri.nb02"))
dbDisconnect(con)

sink("NB/nb01.txt")
dfSummary(x1, graph.col=FALSE)
sink()

sink("NB/nb02.txt")
dfSummary(x2, graph.col=FALSE)
sink()

# NFL ATTRIBUTES

# These are all the SLU codes in NB01 and NB02, some of which are not in the manual
slu = c('AI','AR','BA','BL','BO','BR','BW','CB','CG','CH','CL','CO','CS','CT','DM','EA','FD','FL','FP','FW','GC','GP','GR','IP','IZ','LE','LF','MI','P1','P2','PA','PB','PP','PR','QU','RD','RF','RO','RR','RU','RY','SG','SK','SP','TM','TR','UR','WF','WR','WT')
inManual = c('AI','AR','BA','BL','BO','CB','CG','CH','CL','CO','CS','CT','EA','FD','FP','FW','GC','GP','IP','IZ','LE','LF','MI','PA','PB','PP','PR','QU','RD','RF','RO','RR','RU','RY','SG','SK','TM','TR','UR','WR')
notInManual = c('BR','BW','DM','FL','GR','P1','P2','SP','WF','WT')

# nat_non_veg (friList includes all occurences in NB01 and NB02)
friList = c('BL','FW','RF','RO')
casList = c('EX','FL','WS','RK')

# nat_for_anth (friList includes all occurences in NB01 and NB02)
friList = c('AI','AR','BA','CB','CG','CH','CL','CO','CS','CT','EA','FD','FP','GC','GP','IP','IZ','LE','LF','MI','PA','PB','PP','PR','QU','RD','RR','RU','RY','SG','SK','TM','TR','UR','WR')
casList = c('FA','FA','FA','CL','FA','CL','CL','CL','FA','CL','FA','CL','CL','FA','IN','IN','FA','FA','IN','IN','FA','IN','FA','FA','IN','FA','FA','SE','FA','LG','FA','FA','FA','SE','FA')

# non_for_veg (friList includes all occurences in NB01 and NB02)
friList = c('BO')
casList = c('OM')
