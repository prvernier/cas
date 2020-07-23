---
title: "AB_0016"
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
df = dbGetQuery(con, "SELECT avi_, meridian, range, township, crownclose, height, sp1, sp1_percnt, sp2, sp2_percnt, sp3, sp3_percnt, sp4, sp4_percnt, sp5, sp5_percnt FROM fri.ab16;")
```

**CAS_ID**

The CAS_ID is created by concatenating existing and modified attributes.

```{r}
x1 = "AB_0016"
x2 = "xxxxxxxxxCANFOR"
x3 = paste0("xT0",df$township,"R0",df$range,"M",df$meridian)
x4 = sprintf("%010d",df$forest_id)
x5 = sprintf("%07d",0:(nrow(df)-1))
df$cas_id = paste0(x1,"-",x2,"-",x3,"-",x4,"-",x5)
head(df[,c("poly_num","cas_id")])
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
spp = unique(c(df$sp1,df$sp2,df$sp3,df$sp4,df$sp5))
cat(spp,"\n")
```

<br>
**SPECIES_PER_1 - SPECIES_PER_10**

Tabulate all species percentages to ensure they are within 0-100

```{r}
spp_pct = unique(c(df$sp1_percnt,df$sp2_percnt,df$sp3_percnt,df$sp4_percnt,df$sp5_percnt))
cat("Range of values:",range(spp_pct, na.rm=T))
cat("Unique values:",spp_pct,"\n")
```

<br>
**CROWN_CLOSURE_LOWER, CROWN_CLOSURE_HIGHER**

```{r}
print(suppressMessages(dfSummary(df$crownclose)))
```

<br>
**HEIGHT_LOWER, HEIGHT_UPPER**

```{r}
print(suppressMessages(dfSummary(df$height)))
```
