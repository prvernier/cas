library(RArcInfo)
library(maptools)

e00 = "test_e00/GB_S21_TWP.e00"
e00toavc(e00, "test_e00/ab06")
arc = get.arcdata(".", "test_e00/ab06")
pal = get.paldata(".", "test_e00/ab06")
pat = get.tabledata("test_e00/info", "s21_twp.att")
IDs = paste(pat$POLY_NUM)
nc = pal2SpatialPolygons(arc, pal, IDs=IDs)

