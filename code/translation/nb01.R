---
title: "NB_0001"
author: "Pierre Vernier"
date: "2019-02-26"
output:
    html_notebook:
        code_folding: hide
---

<br>
This purpose of this notebook is to provide a first and rapid pass at validating and translating the forest inventory data. The intent is to help in the development of SQL validation and translation rules.

```{r}
library(rpostgis)
library(tidyverse)
library(summarytools)
con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="cas", host="localhost", port=5432, user="postgres", password="postgres")
df = dbGetQuery(con, "SELECT stdlab, l1s1, l1pr1, l1s2, l1pr2, l1s3, l1pr3, l1s4, l1pr4, l1s5, l1pr5, l1cc, l1ht FROM fri.nb01 where stdlab>0;")
```

**CAS_ID**

The CAS_ID is created by concatenating existing and modified attributes.

```{r}
x1 = "NB_0001"
x2 = "xxFOREST_NONFOR"
x3 = "xxxxxxxxxx"
x4 = sprintf("%010d",df$stdlab)
x5 = sprintf("%07d",1:nrow(df))
df$cas_id = paste0(x1,"-",x2,"-",x3,"-",x4,"-",x5)
head(df[,c("stdlab","cas_id")])
```

<br>
**PHOTO_YEAR**

The year of photography is included in the attributes table (REFERENCE_YEAR)

```{r}
#df$photo_year = df$reference_year
#head(df[,c("reference_year","photo_year")])
```

<br>
**SPECIES_1 - SPECIES_10**

Tabulate all species codes across species fields

```{r}
spp = unique(c(df$species_cd_1,df$species_cd_2,df$species_cd_3,df$species_cd_4,df$species_cd_5,df$species_cd_6))
cat(spp,"\n")
```

<br>
**SPECIES_PER_1 - SPECIES_PER_10**

Tabulate all species percentages to ensure they are within 0-100

```{r}
spp_pct = unique(c(df$species_pct_1,df$species_pct_2,df$species_pct_3,df$species_pct_4,df$species_pct_5,df$species_pct_6))
cat("Range of values:",range(spp_pct, na.rm=T))
cat("Unique values:",spp_pct,"\n")
```

<br>
**CROWN_CLOSURE_LOWER, CROWN_CLOSURE_HIGHER**

```{r}
print(suppressMessages(dfSummary(df$crown_closure)))
```

<br>
**HEIGHT_LOWER, HEIGHT_UPPER**

```{r}
print(suppressMessages(dfSummary(df$proj_height_1)))
```
