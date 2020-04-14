Species_UTM = function(sa, sp100, sp101, sp102, sp110, sp111, spfreq) {

    sp10=sp100; sp11=sp101; sp12=sp102; sp20=sp110; sp21=sp111
    nnsp10=0; nnsp11=0; notnull=0
	if (!is.na(sp10)) { nnsp10 = nnsp10 + 1; notnull = notnull + 1 }
	if (!is.na(sp11)) { nnsp10 = nnsp10 + 1; notnull = notnull + 1 }
	if (!is.na(sp12)) { nnsp10 = nnsp10 + 1; notnull = notnull + 1 }
	if (!is.na(sp20)) { nnsp11 = nnsp11 + 1; notnull = notnull + 1 }
	if (!is.na(sp21)) { nnsp11 = nnsp11 + 1; notnull = notnull + 1 }
	sp10Per=0; sp11Per=0; sp12Per=0; sp20Per=0; sp21Per=0
    
    # SOFTWOOD AND HARDWOOD
    if (sa=="S" | sa=="H") {
		# ONE SPECIES
        if (notnull==1) {
			sp10Per=100; sp11Per=0; sp12Per=0; sp20Per=0; sp21Per=0;
			if (is.na(sp10)) {
				return "-11,"."sp10".","."sp11".","."sp12".","."sp20".","."sp21";
			}
		# TWO SPECIES
		} else if (notnull==2) {  
		    if (nnsp10==1 & nnsp11==1) {
				sp10Per=80;sp11Per=0;sp12Per=0;sp20Per=20;sp21Per=0;
				if (is.na(sp10) | is.na(sp20)) {
					return "#121,"."sp10".","."sp11".","."sp12".","."sp20".","."sp21";
				}
			} else if (nnsp10==2 & ((!sp100=="JP" & !sp101=="BS") | (!sp101 %in% c("BS","JP")))) {
				sp10Per=70; sp11Per=30; sp12Per=0; sp20Per=0; sp21Per=0
				if (is.na(sp100) | is.na(sp101)) {
					return "#122,"."sp10".","."sp11".","."sp12".","."sp20".","."sp21";
				}
			} else if (nnsp10==2 & ( sp10=="JP" | sp10=="BS")  &  (sp11=="BS" | sp11=="JP" )) {		
				sp10Per=60; sp11Per=40; sp12Per=0; sp20Per=0; sp21Per=0
			} else {
                return "!!!!undefined config1";
            }
		# THREE SPECIES
		} elsif (notnull==3) {
            if (nnsp10==3){
                sp10Per=40; sp11Per=30; sp12Per=30; sp20Per=0; sp21Per=0
                if (is.na(sp10) | is.na(sp11) | is.na(sp12)) {
                    return "#131,"."sp10".","."sp11".","."sp12".","."sp20".","."sp21";
                }
            }
            elsif (nnsp10==2) {
                sp10Per=50; sp11Per=30; sp12Per=0; sp20Per=20; sp21Per=0
                if (is.na(sp10) | is.na(sp11) | is.na(sp20)) {
                    return "#132,"."sp10".","."sp11".","."sp12".","."sp20".","."sp21";
                }
            }
            elsif (nnsp10==1) {
                sp10Per=70; sp11Per=0; sp12Per=0; sp20Per=20; sp21Per=10
                if (is.na(sp10) | is.na(sp20) | is.na(sp21)) {
                    return "#133,"."sp10".","."sp11".","."sp12".","."sp20".","."sp21";
                }
            }
            else {
                return "!!!!undefined config2"
            }
		} 
		# FOUR SPECIES
		elsif (notnull==4) {
            if (nnsp10==2) {
                sp10Per=40;sp11Per=30;sp12Per=0;sp20Per=20;sp21Per=10;
                if (is.na(sp10) | is.na(sp11) | is.na(sp20) | is.na(sp21)) {
                    return "#141,"."sp10".","."sp11".","."sp12".","."sp20".","."sp21";
                }
            }
            elsif (nnsp10==3) {
                sp10Per=50;sp11Per=20;sp12Per=20;sp20Per=10;sp21Per=0;
                if (is.na(sp10) | is.na(sp11) | is.na(sp12) | is.na(sp20)) {
                    return "#142,"."sp10".","."sp11".","."sp12".","."sp20".","."sp21";
                }
            }
            else {return "!!!!undefined config3";}
		} 
		# FIVE SPECIES
		elsif (notnull==5) {
            sp10Per=40;sp11Per=20;sp12Per=20;sp20Per=10;sp21Per=10;
            if (is.na(sp10) | is.na(sp11) | is.na(sp12) | is.na(sp20) | is.na(sp21)) {
                return "#15,"."sp10".","."sp11".","."sp12".","."sp20".","."sp21";
            }
		}
	}
	
    # MIXEDWOOD
    elsif (sa=="SH" | sa=="HS")	{
		# TWO SPECIES
		if (notnull==2) {  
            if (nnsp10==2) {
                sp10Per=60;sp11Per=40;sp12Per=0;sp20Per=0;sp21Per=0;
                if (is.na(sp10) | is.na(sp11)) {
                    return "#22,"."sp10".","."sp11".","."sp12".","."sp20".","."sp21";
                }
            }
            elsif (nnsp10==1 & nnsp11==1) { 
                sp10Per=65;sp11Per=0;sp12Per=0;sp20Per=35;sp21Per=0;
                if (is.na(sp10) | is.na(sp20)) {
                    return "#23,"."sp10".","."sp11".","."sp12".","."sp20".","."sp21";
                }
                # return "#this from BK ---SH  first 2 species are not primary "."sp10".","."sp11".","."sp12".","."sp20".","."sp21\n";
            }
            else {
                return "!!!!undefined config4";
            }
		}
		# THREE SPECIES
		elsif (notnull==3) {
            if (nnsp10==2 & nnsp11==1) {	
                    if ( TypeForest(sp10) ne TypeForest(sp11) &  TypeForest(sp11)==TypeForest(sp20)) {
                            sp10Per=60;sp11Per=30;sp12Per=0;sp20Per=10;sp21Per=0;
                         }
                    elsif ( TypeForest(sp10) ne TypeForest(sp11) &  TypeForest(sp10)==TypeForest(sp20)) {
                            sp10Per=40;sp11Per=40;sp12Per=0;sp20Per=20;sp21Per=0;
                         }
                    elsif ( TypeForest(sp10)==TypeForest(sp11) &  TypeForest(sp10) ne TypeForest(sp20)) {
                            sp10Per=50;sp11Per=20;sp12Per=0;sp20Per=30;sp21Per=0;#verify with Steve
                         }
                    else {
                        return "!!!!undefined config5";
                    }
                    if (is.na(sp10) | is.na(sp11) | is.na(sp20)) {
                            return "#24,"."sp10".","."sp11".","."sp12".","."sp20".","."sp21";
                    }
            }
            elsif (nnsp10==1 & nnsp11==2) {
                    # print "my config1\n";
                    if ( TypeForest(sp10) ne TypeForest(sp20) &  TypeForest(sp20)==TypeForest(sp21)) {
                            sp10Per=60;sp11Per=0;sp12Per=0;sp20Per=30;sp21Per=10;
                         }
                    elsif ( TypeForest(sp10) ne TypeForest(sp20) &  TypeForest(sp10)==TypeForest(sp21)) {
                            sp10Per=40;sp11Per=0;sp12Per=0;sp20Per=40;sp21Per=20;
                         }
                    else {
                        return "!!!!undefined config6";
                    }
                    if (is.na(sp10) | is.na(sp20) | is.na(sp21)) {
                            return "#24,"."sp10".","."sp11".","."sp12".","."sp20".","."sp21";
                    }
            } else { 
                    print "my config2\n";
                    if ( TypeForest(sp10) ne TypeForest(sp11) &  TypeForest(sp11)==TypeForest(sp12)) {
                        sp10Per=60;sp11Per=30;sp12Per=10;sp20Per=0;sp21Per=0;
                    }
                    elsif ( TypeForest(sp10) ne TypeForest(sp11) &  TypeForest(sp10)==TypeForest(sp12)) {
                        sp10Per=40;sp11Per=40;sp12Per=20;sp20Per=0;sp21Per=0;
                    }
                    else {
                        return "!!!!undefined config7";
                    }
            }
		} 
		# FOUR SPECIES
		elsif (notnull==4) {
            if (nnsp10==2 & nnsp11==2) {   
                    if ((TypeForest(sp10)==TypeForest(sp20)) & ( TypeForest(sp11)==TypeForest(sp21)) & ( TypeForest(sp10) ne TypeForest(sp11))) {
                            sp10Per=30;sp11Per=30;sp12Per=0;sp20Per=20;sp21Per=20;
                    }
                    elsif ((TypeForest(sp10)==TypeForest(sp20)) & ( TypeForest(sp10)==TypeForest(sp21)) & ( TypeForest(sp10) ne TypeForest(sp11))) {
                            sp10Per=40;sp11Per=30;sp12Per=0;sp20Per=20;sp21Per=10;
                    }
                    elsif ((TypeForest(sp10) ne TypeForest(sp11)) & ( TypeForest(sp11)==TypeForest(sp20)) & ( TypeForest(sp11)==TypeForest(sp21))) {
                            sp10Per=50;sp11Per=30;sp12Per=0;sp20Per=10;sp21Per=10;
                    }
                    elsif ((TypeForest(sp10)==TypeForest(sp11)) & ( TypeForest(sp20)==TypeForest(sp21)) & ( TypeForest(sp10) ne TypeForest(sp20))) {
                            sp10Per=30;sp11Per=20;sp12Per=0;sp20Per=30;sp21Per=20;#verif this with Steeve
                    }
                    elsif ((TypeForest(sp10) ne TypeForest(sp12)) & ( TypeForest(sp12)==TypeForest(sp20)) & ( TypeForest(sp20)==TypeForest(sp21))) {
                            sp10Per=50;sp11Per=0;sp12Per=20;sp20Per=20;sp21Per=10;#verif this with Steeve
                    }
                    else {
                        return "!!!!undefined config8";
                    }
            }
            elsif (nnsp10==3 & nnsp11==1) {
                     #print "my config3\n";
                    if ((TypeForest(sp10)==TypeForest(sp12)) & ( TypeForest(sp11)==TypeForest(sp20)) & ( TypeForest(sp10) ne TypeForest(sp11))) {
                            sp10Per=30;sp11Per=30;sp12Per=20;sp20Per=20;sp21Per=0;
                    }
                    elsif ((TypeForest(sp10)==TypeForest(sp12)) & ( TypeForest(sp10)==TypeForest(sp20)) & ( TypeForest(sp10) ne TypeForest(sp11))) {
                            sp10Per=40;sp11Per=30;sp12Per=20;sp20Per=10;sp21Per=0;
                    }
                    elsif ((TypeForest(sp10) ne TypeForest(sp11)) & ( TypeForest(sp11)==TypeForest(sp12)) & ( TypeForest(sp11)==TypeForest(sp20))) {
                            sp10Per=50;sp11Per=30;sp12Per=10;sp20Per=10;sp21Per=0;
                    }
                    elsif ((TypeForest(sp10)==TypeForest(sp11)) & ( TypeForest(sp11)==TypeForest(sp12)) & ( TypeForest(sp10) ne TypeForest(sp20))) {
                            sp10Per=40;sp11Per=20;sp12Per=10;sp20Per=30;sp21Per=0;#verif this with Steeve
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
			if ((TypeForest(sp10) ne TypeForest(sp11)) & ( TypeForest(sp10)==TypeForest(sp12)) & ( TypeForest(sp10)==TypeForest(sp20)) & ( TypeForest(sp10)==TypeForest(sp21))) {
				sp10Per=30;sp11Per=30;sp12Per=20;sp20Per=10;sp21Per=10;
			}
			elsif ((TypeForest(sp11)==TypeForest(sp21)) & ( TypeForest(sp10)==TypeForest(sp12)) & ( TypeForest(sp10)==TypeForest(sp20)) & ( TypeForest(sp10) ne TypeForest(sp11))) {
				sp10Per=30;sp11Per=30;sp12Per=20;sp20Per=10;sp21Per=10;
			}
			elsif ((TypeForest(sp10)==TypeForest(sp12)) & ( TypeForest(sp11)==TypeForest(sp20)) & ( TypeForest(sp11)==TypeForest(sp21)) & ( TypeForest(sp10) ne TypeForest(sp11))) {
				sp10Per=30;sp11Per=30;sp12Per=20;sp20Per=10;sp21Per=10;
			}
			elsif ((TypeForest(sp10) ne TypeForest(sp11)) & ( TypeForest(sp11)==TypeForest(sp12)) & ( TypeForest(sp11)==TypeForest(sp20)) & ( TypeForest(sp11)==TypeForest(sp21)))	{
				sp10Per=40;sp11Per=30;sp12Per=10;sp20Per=10;sp21Per=10;
			}
			elsif ((TypeForest(sp10)==TypeForest(sp11)) & ( TypeForest(sp11)==TypeForest(sp12)) & ( TypeForest(sp20)==TypeForest(sp21)) & ( TypeForest(sp10) ne TypeForest(sp20)))	{
				sp10Per=30;sp11Per=20;sp12Per=10;sp20Per=30;sp21Per=10;#verif with steve
			}
			else {
				return "!!!!undefined config11";
			}
		}
	} 
	spfreq->{sp10}++;
	spfreq->{sp11}++;
	spfreq->{sp12}++;
	spfreq->{sp20}++;
	spfreq->{sp21}++;

	species = sp10 . "," . sp10Per . "," . sp11 . "," . sp11Per . "," . sp12 . "," . sp12Per . "," . sp20 . "," . sp20Per . "," . sp21 . "," . sp21Per;
	return species;

}
