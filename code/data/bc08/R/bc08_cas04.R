# Create summaries of attributes from CAS04 (requires that CAS04 tables are exported to csv from server)
# PVernier 2019-04-15

library(tidyverse)
library(summarytools)

for (i in c("cas","lyr","nfl","dst","eco")) {
	x = read_csv(paste0("output/ab06/cas04_ab06_",i,".csv")) %>% mutate(cas_id=NULL)
	sink(paste0("output/ab06/cas04_ab06_",i,".txt"))
    print(dfSummary(x, graph.col=FALSE, max.distinct.values=99))
    sink()
}
