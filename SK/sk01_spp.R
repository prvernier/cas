for (i in
    sp1=sp10; sp2=sp11; sp3=sp12; sp4=sp20; sp5=sp21
    nnsp1=0; nnsp2=0; notnull=0
	if (!is.na(sp1)) { nnsp1 = nnsp1 + 1; notnull = notnull + 1 }
	if (!is.na(sp2)) { nnsp1 = nnsp1 + 1; notnull = notnull + 1 }
	if (!is.na(sp3)) { nnsp1 = nnsp1 + 1; notnull = notnull + 1 }
	if (!is.na(sp4)) { nnsp2 = nnsp2 + 1; notnull = notnull + 1 }
	if (!is.na(sp5)) { nnsp2 = nnsp2 + 1; notnull = notnull + 1 }
	sp1Per=0; sp2Per=0; sp3Per=0; sp4Per=0; sp5Per=0
    
    # SOFTWOOD AND HARDWOOD
    if (sa=="S" | sa=="H") {
		# ONE SPECIES
        if (notnull==1) {
			sp1Per=100; sp2Per=0; sp3Per=0; sp4Per=0; sp5Per=0;
			if (is.na(sp1)) {
				return "-11,"."sp1".","."sp2".","."sp3".","."sp4".","."sp5";
			}
		# TWO SPECIES
		} else if (notnull==2) {  
		    if (nnsp1==1 & nnsp2==1) {
				sp1Per=80;sp2Per=0;sp3Per=0;sp4Per=20;sp5Per=0;
				if (is.na(sp1) | is.na(sp4)) {
					return "#121,"."sp1".","."sp2".","."sp3".","."sp4".","."sp5";
				}
			} else if (nnsp1==2 & ((!sp10=="JP" & !sp11=="BS") | (!sp11 %in% c("BS","JP")))) {
				sp1Per=70; sp2Per=30; sp3Per=0; sp4Per=0; sp5Per=0
				if (is.na(sp10) | is.na(sp11)) {
					return "#122,"."sp1".","."sp2".","."sp3".","."sp4".","."sp5";
				}
			} else if (nnsp1==2 & ( sp1=="JP" | sp1=="BS")  &  (sp2=="BS" | sp2=="JP" )) {		
				sp1Per=60; sp2Per=40; sp3Per=0; sp4Per=0; sp5Per=0
			} else {
                return "!!!!undefined config1";
            }
    # MIXEDWOOD
    elsif (sa=="SH" | sa=="HS")	{
		# TWO SPECIES
		if (notnull==2) {  
            if (nnsp1==2) {
                sp1Per=60;sp2Per=40;sp3Per=0;sp4Per=0;sp5Per=0;
                if (is.na(sp1) | is.na(sp2)) {
                    return "#22,"."sp1".","."sp2".","."sp3".","."sp4".","."sp5";
                }
            }
            elsif (nnsp1==1 & nnsp2==1) { 
                sp1Per=65;sp2Per=0;sp3Per=0;sp4Per=35;sp5Per=0;
                if (is.na(sp1) | is.na(sp4)) {
                    return "#23,"."sp1".","."sp2".","."sp3".","."sp4".","."sp5";
                }
                # return "#this from BK ---SH  first 2 species are not primary "."sp1".","."sp2".","."sp3".","."sp4".","."sp5\n";
            }
            else {
                return "!!!!undefined config4";
            }
		}
	} 
	spfreq->{sp1}++;
	spfreq->{sp2}++;
	spfreq->{sp3}++;
	spfreq->{sp4}++;
	spfreq->{sp5}++;

	species = sp1 . "," . sp1Per . "," . sp2 . "," . sp2Per . "," . sp3 . "," . sp3Per . "," . sp4 . "," . sp4Per . "," . sp5 . "," . sp5Per;
	return species;
