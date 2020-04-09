Species_UTM = function(sa, sp10, sp11, sp12, sp20, sp21, spfreq) {

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
		# THREE SPECIES
		} elsif (notnull==3) {
            if (nnsp1==3){
                sp1Per=40; sp2Per=30; sp3Per=30; sp4Per=0; sp5Per=0
                if (is.na(sp1) | is.na(sp2) | is.na(sp3)) {
                    return "#131,"."sp1".","."sp2".","."sp3".","."sp4".","."sp5";
                }
            }
            elsif (nnsp1==2) {
                sp1Per=50; sp2Per=30; sp3Per=0; sp4Per=20; sp5Per=0
                if (is.na(sp1) | is.na(sp2) | is.na(sp4)) {
                    return "#132,"."sp1".","."sp2".","."sp3".","."sp4".","."sp5";
                }
            }
            elsif (nnsp1==1) {
                sp1Per=70; sp2Per=0; sp3Per=0; sp4Per=20; sp5Per=10
                if (is.na(sp1) | is.na(sp4) | is.na(sp5)) {
                    return "#133,"."sp1".","."sp2".","."sp3".","."sp4".","."sp5";
                }
            }
            else {
                return "!!!!undefined config2"
            }
		} 
		# FOUR SPECIES
		elsif (notnull==4) {
            if (nnsp1==2) {
                sp1Per=40;sp2Per=30;sp3Per=0;sp4Per=20;sp5Per=10;
                if (is.na(sp1) | is.na(sp2) | is.na(sp4) | is.na(sp5)) {
                    return "#141,"."sp1".","."sp2".","."sp3".","."sp4".","."sp5";
                }
            }
            elsif (nnsp1==3) {
                sp1Per=50;sp2Per=20;sp3Per=20;sp4Per=10;sp5Per=0;
                if (is.na(sp1) | is.na(sp2) | is.na(sp3) | is.na(sp4)) {
                    return "#142,"."sp1".","."sp2".","."sp3".","."sp4".","."sp5";
                }
            }
            else {return "!!!!undefined config3";}
		} 
		# FIVE SPECIES
		elsif (notnull==5) {
            sp1Per=40;sp2Per=20;sp3Per=20;sp4Per=10;sp5Per=10;
            if (is.na(sp1) | is.na(sp2) | is.na(sp3) | is.na(sp4) | is.na(sp5)) {
                return "#15,"."sp1".","."sp2".","."sp3".","."sp4".","."sp5";
            }
		}
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
		# THREE SPECIES
		elsif (notnull==3) {
            if (nnsp1==2 & nnsp2==1) {	
                    if ( TypeForest(sp1) ne TypeForest(sp2) &  TypeForest(sp2)==TypeForest(sp4)) {
                            sp1Per=60;sp2Per=30;sp3Per=0;sp4Per=10;sp5Per=0;
                         }
                    elsif ( TypeForest(sp1) ne TypeForest(sp2) &  TypeForest(sp1)==TypeForest(sp4)) {
                            sp1Per=40;sp2Per=40;sp3Per=0;sp4Per=20;sp5Per=0;
                         }
                    elsif ( TypeForest(sp1)==TypeForest(sp2) &  TypeForest(sp1) ne TypeForest(sp4)) {
                            sp1Per=50;sp2Per=20;sp3Per=0;sp4Per=30;sp5Per=0;#verify with Steve
                         }
                    else {
                        return "!!!!undefined config5";
                    }
                    if (is.na(sp1) | is.na(sp2) | is.na(sp4)) {
                            return "#24,"."sp1".","."sp2".","."sp3".","."sp4".","."sp5";
                    }
            }
            elsif (nnsp1==1 & nnsp2==2) {
                    # print "my config1\n";
                    if ( TypeForest(sp1) ne TypeForest(sp4) &  TypeForest(sp4)==TypeForest(sp5)) {
                            sp1Per=60;sp2Per=0;sp3Per=0;sp4Per=30;sp5Per=10;
                         }
                    elsif ( TypeForest(sp1) ne TypeForest(sp4) &  TypeForest(sp1)==TypeForest(sp5)) {
                            sp1Per=40;sp2Per=0;sp3Per=0;sp4Per=40;sp5Per=20;
                         }
                    else {
                        return "!!!!undefined config6";
                    }
                    if (is.na(sp1) | is.na(sp4) | is.na(sp5)) {
                            return "#24,"."sp1".","."sp2".","."sp3".","."sp4".","."sp5";
                    }
            } else { 
                    print "my config2\n";
                    if ( TypeForest(sp1) ne TypeForest(sp2) &  TypeForest(sp2)==TypeForest(sp3)) {
                        sp1Per=60;sp2Per=30;sp3Per=10;sp4Per=0;sp5Per=0;
                    }
                    elsif ( TypeForest(sp1) ne TypeForest(sp2) &  TypeForest(sp1)==TypeForest(sp3)) {
                        sp1Per=40;sp2Per=40;sp3Per=20;sp4Per=0;sp5Per=0;
                    }
                    else {
                        return "!!!!undefined config7";
                    }
            }
		} 
		# FOUR SPECIES
		elsif (notnull==4) {
            if (nnsp1==2 & nnsp2==2) {   
                    if ((TypeForest(sp1)==TypeForest(sp4)) & ( TypeForest(sp2)==TypeForest(sp5)) & ( TypeForest(sp1) ne TypeForest(sp2))) {
                            sp1Per=30;sp2Per=30;sp3Per=0;sp4Per=20;sp5Per=20;
                    }
                    elsif ((TypeForest(sp1)==TypeForest(sp4)) & ( TypeForest(sp1)==TypeForest(sp5)) & ( TypeForest(sp1) ne TypeForest(sp2))) {
                            sp1Per=40;sp2Per=30;sp3Per=0;sp4Per=20;sp5Per=10;
                    }
                    elsif ((TypeForest(sp1) ne TypeForest(sp2)) & ( TypeForest(sp2)==TypeForest(sp4)) & ( TypeForest(sp2)==TypeForest(sp5))) {
                            sp1Per=50;sp2Per=30;sp3Per=0;sp4Per=10;sp5Per=10;
                    }
                    elsif ((TypeForest(sp1)==TypeForest(sp2)) & ( TypeForest(sp4)==TypeForest(sp5)) & ( TypeForest(sp1) ne TypeForest(sp4))) {
                            sp1Per=30;sp2Per=20;sp3Per=0;sp4Per=30;sp5Per=20;#verif this with Steeve
                    }
                    elsif ((TypeForest(sp1) ne TypeForest(sp3)) & ( TypeForest(sp3)==TypeForest(sp4)) & ( TypeForest(sp4)==TypeForest(sp5))) {
                            sp1Per=50;sp2Per=0;sp3Per=20;sp4Per=20;sp5Per=10;#verif this with Steeve
                    }
                    else {
                        return "!!!!undefined config8";
                    }
            }
            elsif (nnsp1==3 & nnsp2==1) {
                     #print "my config3\n";
                    if ((TypeForest(sp1)==TypeForest(sp3)) & ( TypeForest(sp2)==TypeForest(sp4)) & ( TypeForest(sp1) ne TypeForest(sp2))) {
                            sp1Per=30;sp2Per=30;sp3Per=20;sp4Per=20;sp5Per=0;
                    }
                    elsif ((TypeForest(sp1)==TypeForest(sp3)) & ( TypeForest(sp1)==TypeForest(sp4)) & ( TypeForest(sp1) ne TypeForest(sp2))) {
                            sp1Per=40;sp2Per=30;sp3Per=20;sp4Per=10;sp5Per=0;
                    }
                    elsif ((TypeForest(sp1) ne TypeForest(sp2)) & ( TypeForest(sp2)==TypeForest(sp3)) & ( TypeForest(sp2)==TypeForest(sp4))) {
                            sp1Per=50;sp2Per=30;sp3Per=10;sp4Per=10;sp5Per=0;
                    }
                    elsif ((TypeForest(sp1)==TypeForest(sp2)) & ( TypeForest(sp2)==TypeForest(sp3)) & ( TypeForest(sp1) ne TypeForest(sp4))) {
                            sp1Per=40;sp2Per=20;sp3Per=10;sp4Per=30;sp5Per=0;#verif this with Steeve
                    }
                    else {
                        return "!!!!undefined config9";
                    }
            }
            else {
                return "!!!!undefined config10";
            }
		}
		# FIVE SPECIES
		elsif (notnull==5) {
			if ((TypeForest(sp1) ne TypeForest(sp2)) & ( TypeForest(sp1)==TypeForest(sp3)) & ( TypeForest(sp1)==TypeForest(sp4)) & ( TypeForest(sp1)==TypeForest(sp5))) {
				sp1Per=30;sp2Per=30;sp3Per=20;sp4Per=10;sp5Per=10;
			}
			elsif ((TypeForest(sp2)==TypeForest(sp5)) & ( TypeForest(sp1)==TypeForest(sp3)) & ( TypeForest(sp1)==TypeForest(sp4)) & ( TypeForest(sp1) ne TypeForest(sp2))) {
				sp1Per=30;sp2Per=30;sp3Per=20;sp4Per=10;sp5Per=10;
			}
			elsif ((TypeForest(sp1)==TypeForest(sp3)) & ( TypeForest(sp2)==TypeForest(sp4)) & ( TypeForest(sp2)==TypeForest(sp5)) & ( TypeForest(sp1) ne TypeForest(sp2))) {
				sp1Per=30;sp2Per=30;sp3Per=20;sp4Per=10;sp5Per=10;
			}
			elsif ((TypeForest(sp1) ne TypeForest(sp2)) & ( TypeForest(sp2)==TypeForest(sp3)) & ( TypeForest(sp2)==TypeForest(sp4)) & ( TypeForest(sp2)==TypeForest(sp5)))	{
				sp1Per=40;sp2Per=30;sp3Per=10;sp4Per=10;sp5Per=10;
			}
			elsif ((TypeForest(sp1)==TypeForest(sp2)) & ( TypeForest(sp2)==TypeForest(sp3)) & ( TypeForest(sp4)==TypeForest(sp5)) & ( TypeForest(sp1) ne TypeForest(sp4)))	{
				sp1Per=30;sp2Per=20;sp3Per=10;sp4Per=30;sp5Per=10;#verif with steve
			}
			else {
				return "!!!!undefined config11";
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

}
