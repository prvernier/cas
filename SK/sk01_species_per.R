# R code to generate species percent attributes (SPECIES_PER_1 - SPECIES_PER_5)
# PV 2020-04-09

foreach row in sk01 {
        
    # Create 5 forest type attributes (softwood or hardwood), one for each source spXX attribute
    if sp10 %in% c("WS","BS","JP","BF","TL","LP") {
        ft10 = "softwood"
    } else if (sp10 %in% c("GA","TA","BP","WB","WE","MM","BO"))
        ft10 = "hardwood"
    }
    if sp11 %in% c("WS","BS","JP","BF","TL","LP") {
        ft11 = "softwood"
    } else if (sp10 %in% c("GA","TA","BP","WB","WE","MM","BO"))
        ft11 = "hardwood"
    }
    if sp12 %in% c("WS","BS","JP","BF","TL","LP") {
        ft12 = "softwood"
    } else if (sp10 %in% c("GA","TA","BP","WB","WE","MM","BO"))
        ft12 = "hardwood"
    }
    if sp20 %in% c("WS","BS","JP","BF","TL","LP") {
        ft20 = "softwood"
    } else if (sp10 %in% c("GA","TA","BP","WB","WE","MM","BO"))
        ft20 = "hardwood"
    }
    if sp21 %in% c("WS","BS","JP","BF","TL","LP") {
        ft21 = "softwood"
    } else if (sp10 %in% c("GA","TA","BP","WB","WE","MM","BO"))
        ft21 = "hardwood"
    }

    # Create three counters: nsp1 (1-3) for primary species, nsp2 (0-2) for secondary species; nsp12 for all species (1-5)
    nsp1 = as.integer(!sp10==" ") + as.integer(!sp11==" ") + as.integer(!sp12==" ")
    nsp2 = as.integer(!sp20==" ") + as.integer(!sp21==" ")
    nsp12 = nsp1 + nsp2

    # SOFTWOOD AND HARDWOOD
    if (sa=="S" | sa=="H"):
        if (nsp12==1) {
            spp_pct = c(100, 0, 0, 0, 0)
        } else if (nsp12==2 & (nsp1==1 & nsp2==1)) {
            spp_pct = c(80, 0, 0, 20, 0)
        } else if (nsp12==2 & (nsp1==2 & ((!sp10=="JP" & !sp11=="BS") | (!sp11 %in% c("BS","JP"))))) {
            spp_pct = c(70, 30, 0, 0, 0)
        } else if (nsp12==2 & (nsp1==2 & ( sp10=="JP" | sp10=="BS")  &  (sp11=="BS" | sp11=="JP" ))) {
            spp_pct = c(60, 40, 0, 0, 0)
        } else if (nsp12==3 & nsp1==3) {
            spp_pct = c(40, 30, 30, 0, 0)
        } else if (nsp12==3 & nsp1==2) {
            spp_pct = c(50, 30, 0, 20, 0)
        } else if (nsp12==3 & nsp1==1) {
            spp_pct = c(70, 0, 0, 20, 10)
        } else if (nsp12==4 & nsp1==2) {
            spp_pct = c(40, 30, 0, 20, 10)
        } else if (nsp12==4 & nsp1==3) {
            spp_pct = c(50, 20, 20, 10, 0)
        } else if (nsp12==5) {
            spp_pct = c(40, 20, 20, 10, 10)
        }

    # MIXEDWOOD
    } else if (sa=="SH" | sa=="HS") {
        if (nsp12==2 & (nsp1==2)) {
            spp_pct = c(60, 40, 0, 0, 0)
        } else if (nsp12==2 & (nsp1==1 & nsp2==1)) {
            spp_pct = c(65, 0, 0, 35, 0)
        } else if (nsp12==3 & (nsp1==2 & nsp2==1) & (!ft10==ft11 & ft11==ft20)) {
            spp_pct = c(60, 30, 0, 10, 0)
        } else if (nsp12==3 & (nsp1==2 & nsp2==1) & (!ft10==ft11 & ft10==ft20)) {
            spp_pct = c(40, 40, 0, 20, 0)
        } else if (nsp12==3 & (nsp1==2 & nsp2==1) & (ft10==ft11 & !ft11==ft20)) {
            spp_pct = c(50, 20, 0, 30, 0)
        } else if (nsp12==3 & (nsp1==1 & nsp2==2) & (!ft10==ft20 & ft20==ft21)) {
            spp_pct = c(60, 0, 0, 30, 10)
        } else if (nsp12==3 & (nsp1==1 & nsp2==2) & (!ft10==ft20 & ft10==ft21)) {
            spp_pct = c(40, 0, 0, 40, 20)
        } else if (nsp12==3 & (!ft10==ft11 & ft11==ft12)) {
            spp_pct = c(60, 30, 10, 0, 0)
        } else if (nsp12==3 & (!ft10==ft11 & ft10==ft12)) {
            spp_pct = c(40, 40, 20, 0, 0)
        } else if (nsp12==4 & (nsp1==2 & nsp2==2) & (ft10==ft20 & ft11==ft21) & (!ft10==ft11)) {
            spp_pct = c(30, 30, 0, 20, 20)
        } else if (nsp12==4 & (nsp1==2 & nsp2==2) & (ft10==ft20 & ft10==ft21) & (!ft10==ft11)) {
            spp_pct = c(40, 30, 0, 20, 10)
        } else if (nsp12==4 & (nsp1==2 & nsp2==2) & (!ft10==ft11 & ft11==ft20) & (ft11==ft21)) {
            spp_pct = c(50, 30, 0, 10, 10)
        } else if (nsp12==4 & (nsp1==2 & nsp2==2) & (ft10==ft11 & ft20==ft21) & (!ft10==ft20)) {
            spp_pct = c(30, 20, 0, 30, 20)
        } else if (nsp12==4 & (nsp1==2 & nsp2==2) & (!ft10==ft12 & ft12==ft20) & (!ft20==ft21)) {
            spp_pct = c(50, 0, 20, 20, 10)
        } else if (nsp12==4 & (nsp1==3 & nsp2==1) & (ft10==ft12 & ft11==ft20) & (!ft10==ft11)) {
            spp_pct = c(30, 30, 20, 20, 0)
        } else if (nsp12==4 & (nsp1==3 & nsp2==1) & (ft10==ft12 & ft11==ft20) & (!ft10==ft11)) {
            spp_pct = c(40, 30, 20, 10, 0)
        } else if (nsp12==4 & (nsp1==3 & nsp2==1) & (ft10==ft12 & ft11==ft20) & (ft11==ft21)) {
            spp_pct = c(50, 30, 10, 10, 0)
        } else if (nsp12==4 & (nsp1==3 & nsp2==1) & (ft10==ft12 & ft11==ft20) & (!ft10==ft20)) {
            spp_pct = c(40, 20, 10, 30, 0)
        } else if (nsp12==5 & (!ft10==ft11 & ft10==ft12 & ft10==ft20 & ft10==ft21)) {
            spp_pct = c(30, 30, 20, 10, 10)
        } else if (nsp12==5 & (ft11==ft21 & ft10==ft12 & ft10==ft20 & !ft10==ft11)) {
            spp_pct = c(30, 30, 20, 10, 10)
        } else if (nsp12==5 & (ft10==ft12 & ft11==ft20 & ft11==ft21 & !ft10==ft11)) {
            spp_pct = c(30, 30, 20, 10, 10)
        } else if (nsp12==5 & (!ft11==ft11 & ft11==ft12 & ft11==ft20 & ft11==ft21)) {
            spp_pct = c(40, 30, 10, 10, 10)
        } else if (nsp12==5 & (ft10==ft11 & ft11==ft12 & ft20==ft21 & !ft10==ft20)) { 
            spp_pct = c(30, 20, 10, 30, 10)
        }
    }

)