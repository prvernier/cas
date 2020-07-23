sub BCinv_to_CAS {
	while (my $row = $csv->getline_hr ($BCinv)) {	
		$MoistReg     =  $row->{SOIL_MOISTURE_REGIME_1}; 
		$LayerRank=1;
		$Struc="S";  
		$NumLayers=1;
		$LayerId=1;
		$CrownClosure =  $row->{CROWN_CLOSURE_CLASS_CD};
	 	$CCHigh       =  CCUpper($CrownClosure); 
	    $CCLow        =  CCLower($CrownClosure);
	 	if($CCHigh  eq ERRCODE   || $CCLow  eq ERRCODE || $CCHigh  >100   || $CCLow >100) { 
			$keys="CrownClosure"."#".$CrownClosure;
		    $herror{$keys}++; 
		}
		$Sp1          =  $row->{SPECIES_CD_1}; #SPEC_CD_1
	    $Sp1Per       =  $row->{SPECIES_PCT_1};  #SPEC_PCT_1
		if(!defined $Sp1Per || isempty($Sp1Per)){$Sp1Per=0;}
		$Sp1Per =~ s/\.([0-9]+)$//g;$Sp2Per =~ s/\.([0-9]+)$//g;$Sp3Per =~ s/\.([0-9]+)$//g;$Sp4Per =~ s/\.([0-9]+)$//g;$Sp5Per =~ s/\.([0-9]+)$//g;
		$Sp6Per =~ s/\.([0-9]+)$//g;
        $Total_pct=$Sp1Per+$Sp2Per+$Sp3Per+$Sp4Per+$Sp5Per+$Sp6Per;
		if(  $Total_pct >100) {
			$keys="Perctg_Species >100"."#".$Sp1."___". $Sp1Per."####".$Sp2."___". $Sp2Per."####".$Sp3."___". $Sp3Per."####".$Sp4."___". $Sp4Per."####".$Sp5."___". $Sp5Per."####".$Sp6."___". $Sp6Per;
			$herror{$keys}++;
		}
		$NonVeg       =  $row->{NON_VEG_COVER_TYPE_1};   #NVEG_TYP_1,  NON_VEG__2
	  	$NonVegPct    =  $row->{NON_VEG_COVER_PCT_1};   #NVEG_TYP_1,  NON_VEG__2
		$NPdesc	=  $row->{NON_PRODUCTIVE_DESCRIPTOR_CD}; #NP_DESC, NON_PRODUC
		$NPcode	=  $row->{NON_PRODUCTIVE_CD};    #NP_CODE, NON_PROD_1
		if(defined $row->{NON_FOREST_DESCRIPTOR}) {
			$Nfor_desc= $row->{NON_FOREST_DESCRIPTOR};
		} else {
            $Nfor_desc=""; # NFOR_DESC, NON_FOREST
        }   
	 	$SiteClass	=  $row->{EST_SITE_INDEX_SOURCE_CD}; #HIST_S_CD, EST_SITE_I
        if (!isempty($row->{SITE_INDEX})) {
  			$SiteIndex  = sprintf("%.1f", $row->{SITE_INDEX});
	   	} else {
            $SiteIndex  = MISSCODE;
        } 
 	  	$LandCoverClassCode  =  $row->{LAND_COVER_CLASS_CD_1}; #LAND_CD_1, LAND_COVER
	  	$SMR =  SoilMoistureRegime($row->{SOIL_MOISTURE_REGIME_1}, $std_num);
	  	if($SMR eq ERRCODE) { 
			$keys="MoistReg"."#".$row->{SOIL_MOISTURE_REGIME_1};
			$herror{$keys}++;	
	  	}
        $StandStructureCode   =  $Struc; # BK- july 2014 StandStructure($Struc);#StandStructure($Struc, $INV_version);
        $StandStructureVal     =  UNDEF;  #"";
	  	$Height   =  $row->{PROJ_HEIGHT_CLASS_CD_1};
	  	if($Height eq "0.0" || isempty($Height)){$Height=0;}
	  	$HeightHigh   =  StandHeightUp($Height);
        $HeightLow    =  StandHeightLow($Height);
	  	if($HeightHigh  eq ERRCODE   || $HeightLow  eq ERRCODE) { 
	  		$keys="Height"."#".$Height; #."#comment#".$row->{MD_COMMENT};
			$herror{$keys}++; 
		}
		$SpComp=$Sp1."#".$Sp1Per."#".$Sp2."#".$Sp2Per."#".$Sp3."#".$Sp3Per."#".$Sp4."#".$Sp4Per."#".$Sp5."#".$Sp5Per."#".$Sp6."#".$Sp6Per;
		$SpeciesComp  =  Species($Sp1, $Sp1Per, $Sp2, $Sp2Per, $Sp3, $Sp3Per, $Sp4, $Sp4Per, $Sp5, $Sp5Per, $Sp6, $Sp6Per, $spfreq);
		@SpecsPerList  = split(",", $SpeciesComp); 
		@SpecsInit=($Sp1, $Sp2, $Sp3, $Sp4, $Sp5, $Sp6);
		$totalpct=$SpecsPerList[1]+$SpecsPerList[3]+$SpecsPerList[5]+$SpecsPerList[7]+$SpecsPerList[9]+$SpecsPerList[11];
		my $nbf=0;
		my $pos_inc=0;
	 	if(  $totalpct>=80 &&  $totalpct<100) { 
			for($cpt_ind=0; $cpt_ind<6; $cpt_ind++)	{  
				my $posi=$cpt_ind*2;
	 	 		if($SpecsPerList[$posi] ne "XXXX MISS"  && $SpecsPerList[$posi+1]==0 ) { 
					$nbf++;	
					$pos_inc=$posi+1;	  
				}
		  	}
			if($nbf>1) {
				$keys="CORRECTION nb P=0#".$nbf;
				$herror{$keys}++; 
			} elsif ($nbf==1) {
				if ( (100-$totalpct) > $SpecsPerList[$pos_inc-2]) {
					$SpecsPerList[$pos_inc]=$SpecsPerList[$pos_inc-2];
					$SpecsPerList[$pos_inc-2]=100-$totalpct;
				} else {
					$SpecsPerList[$pos_inc]=100-$totalpct;
				}
			}
			else {
				$SpecsPerList[1]=$SpecsPerList[1] + 100-$totalpct;
			}
			$totalpct=$SpecsPerList[1]+$SpecsPerList[3]+$SpecsPerList[5]+$SpecsPerList[7]+$SpecsPerList[9]+$SpecsPerList[11];
			$SpeciesComp=join(",", @SpecsPerList );
	 	}
		if(  $totalpct!=100 &&  $totalpct!= 0) { 
			$keys="nbf=$nbf  total pctg != 100#"."(".$totalpct.")#".$SpeciesComp;
			$herror{$keys}++; 
		}
	  	for($cpt_ind=0; $cpt_ind<6; $cpt_ind++)	{  
	  		my $posi=$cpt_ind*2;
 	 		if($SpecsPerList[$posi]  eq SPECIES_ERRCODE ) {
 	 		 	$keys="Species$cpt_ind"."#".$SpecsInit[$cpt_ind]."#casid=".$CAS_ID;
				$herror{$keys}++; 
			}
	  	}	
 	  	$SpeciesComp  =  $SpeciesComp .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";		#
  	  	$Origin       =  $row->{PROJ_AGE_CLASS_CD_1}; 
        $OriginHigh   =  UpperOrigin($Origin);
        $OriginLow    =  LowerOrigin($Origin);
	  	if($std_num ne "0007") { 
			$Mod1         = $row->{LINE_7B_DISTURBANCE_HISTORY};
 			$Mod2         = $row->{LINE_6_SITE_PREP_HISTORY}; 
	 		$Mod3         = $row->{LINE_8_PLANTING_HISTORY};
	 		if (!isempty($Mod2)) {
				$keys="valid other 2nd disturbance----*".$Mod2;
				$herror{$keys}++;
			}
			if (!isempty($Mod3)) {
				$keys="valid other 3rd disturbance----*".$Mod3;
				$herror{$keys}++;
			}
	 	} else {
	 		$Mod1=MISSCODE;$Mod1Yr=MISSCODE;
	 	}
		if($OriginHigh  eq ERRCODE   || $OriginLow  eq ERRCODE) { 
		    $keys="Origin"."#".$Origin;
			$herror{$keys}++;									
		}
    
		#############TURNING AGE INTO ABSOLUTE YEAR VALUE ################## ##########################
		if ($OriginHigh ne ERRCODE && $OriginHigh ne MISSCODE && $PROJECTED_YEAR ne MISSCODE && $PROJECTED_YEAR ne "0" && !isempty($PROJECTED_YEAR)) 
		{

			if ($OriginHigh ne INFTY ) {$OriginHigh = $PROJECTED_YEAR-$OriginHigh;}
	  		$OriginLow  = $PROJECTED_YEAR-$OriginLow;
			if ($OriginHigh > $OriginLow)
			{ 
				$keys="CHEK ORIGINUPPER-"."#".$Origin."#high=".$OriginHigh."#low=".$OriginLow."#photoyear=".$REF_YEAR."#number".$pr3;
				$herror{$keys}++; 
				$OriginHigh = MISSCODE;
				$OriginLow  = MISSCODE;
			}
			my $aux=$OriginHigh;
			$OriginHigh=$OriginLow;
			$OriginLow=$aux;
		}
		else 
		{
			$OriginHigh=MISSCODE;
			$OriginLow=MISSCODE;
		}
		#############      ........\AD\AD\AD.END  OF  TURNING AGE INTO ABSOLUTE YEAR VALUE ###########  #####################
	  
 		if($OriginHigh  >2014     || ($OriginLow <1700 && $OriginLow >0)) 
 		{ 
			print "check origin Year hight = $OriginHigh , low = $OriginLow, both from $Origin\n"; exit;
			$keys="invalid age  "."#originhigh#".$OriginHigh."#originlow#".$OriginLow."#origin#".$Origin."#photoyear#".$REF_YEAR;
			$herror{$keys}++;									
		}

	  	$SiteClass 	=  Site($SiteClass, $INV_version);
	 
	  	$Wetland = WetlandCodes ($NPdesc,$Nfor_desc, $LandCoverClassCode, $MoistReg, $Sp1, $Sp2, $Sp1Per, $CrownClosure, $Height);

	  	# ===== Non-forested Land =====
	  	my $IS_NFOR=0;
	  	my $bclcs4=$row->{BCLCS_LEVEL_4};
		$NonVegAnth2=MISSCODE;$NonVegAnth3=MISSCODE;$NatNonVeg2=MISSCODE;$NatNonVeg3=MISSCODE;$NonForVeg2=MISSCODE;$NonForVeg3=MISSCODE;
 	  	if($INV_version eq "V" || $INV_version eq "I") {
			$UnProdFor 	=  MISSCODE;
			if(!isempty($Sp1) && ($LandCoverClassCode eq "TM") || ($LandCoverClassCode eq "TC")|| ($LandCoverClassCode eq "TB")|| ($LandCoverClassCode eq "ST")|| ($LandCoverClassCode eq "SL")) {
                $NonForVeg 	= MISSCODE; $NatNonVeg =MISSCODE;  $NonVegAnth=MISSCODE; $UnProdFor 	= "PF";
            } elsif(!isempty($Sp1) && ($bclcs4 eq "TM") || ($bclcs4 eq "TC")|| ($bclcs4 eq "TB")|| ($bclcs4 eq "ST")|| ($bclcs4 eq "SL")) {
                $NonForVeg 	= MISSCODE; $NatNonVeg =MISSCODE;  $NonVegAnth=MISSCODE; $UnProdFor 	= "PF";
            } elsif(isempty($Sp1) && (!isempty($LandCoverClassCode) || !isempty($NonVeg) || !isempty($bclcs4)) ) { 
				$NonForVeg 	=  NonForestedVeg($LandCoverClassCode);
				$NatNonVeg2 	=  NaturallyNonVeg($LandCoverClassCode);   
  		 		$NonVegAnth2	=  Anthropogenic($LandCoverClassCode);   
				$NonForVeg2 	=  NonForestedVeg($NonVeg);
				$NatNonVeg 	=  NaturallyNonVeg($NonVeg);   
	  		 	$NonVegAnth	=  Anthropogenic($NonVeg);   
				$NonForVeg3 	=  NonForestedVeg($bclcs4);
				$NatNonVeg3 	=  NaturallyNonVeg($bclcs4);   
	  		 	$NonVegAnth3	=  Anthropogenic($bclcs4); 
	 		 	if((($NatNonVeg  eq ERRCODE) && ($NonVegAnth  eq ERRCODE) && ($NonForVeg  eq ERRCODE) && ($NatNonVeg2 eq ERRCODE) && ($NonVegAnth2  eq ERRCODE) && ($NonForVeg2  eq ERRCODE) && ($NatNonVeg3 eq ERRCODE) && ($NonVegAnth3  eq ERRCODE) && ($NonForVeg3  eq ERRCODE)) || (($NatNonVeg  eq MISSCODE) && ($NonVegAnth  eq MISSCODE) && ($NonForVeg  eq MISSCODE) && ($NatNonVeg2  eq MISSCODE) && ($NonVegAnth2  eq MISSCODE) && ($NonForVeg2  eq MISSCODE) && ($NatNonVeg3  eq MISSCODE) && ($NonVegAnth3  eq MISSCODE) && ($NonForVeg3  eq MISSCODE))) { 
	  				# PV: What does this do?
	  				if (defined $Sp1 ) {
                    
                    } else {
                        $Sp1="";
                    }
					$keys="NatNonVeg-NonvegetatedAnth-Nonfor"."#".$NonVeg."#LCCC"."#".$LandCoverClassCode."#bclcs4".$row->{BCLCS_LEVEL_4}."#species is ".$Sp1." and npdesc=".$NPdesc;
					$herror{$keys}++;	
					$NatNonVeg=UNDEF;$NonForVeg =UNDEF;$NonVegAnth=UNDEF;
	  			}
			} else  {
                $NonForVeg 	= MISSCODE; $NatNonVeg =MISSCODE;  $NonVegAnth=MISSCODE;
            }
	  	} else {
			$UnProdFor 	=  UnProdForest($Nfor_desc);
			$NonForVeg = MISSCODE; $NatNonVeg= MISSCODE; $NonVegAnth= MISSCODE ;
			if ($UnProdFor eq ERRCODE || $UnProdFor eq MISSCODE) {
				if(!isempty($Nfor_desc)) {	
					$keys="Nonfordesc"."#".$Nfor_desc;  $herror{$keys}++;
				}
 				$UnProdFor 	=  UnProdForest($NPdesc);
				$NonForVeg	=  NonForestedVeg($NPdesc);
				$NatNonVeg	=  NaturallyNonVeg($NPdesc);
				$NonVegAnth	=  Anthropogenic($NPdesc);
 				if(($UnProdFor  eq ERRCODE) && ($NatNonVeg  eq ERRCODE) && ($NonVegAnth  eq ERRCODE)&& ($NonForVeg  eq ERRCODE) ) { 
		 			$keys="UnProdFor-and NN2"."#".$Nfor_desc."#NPdesc".$NPdesc;  $herror{$keys}++;
				}
			}
            #new to find dropped stands
			if( (($NatNonVeg  eq ERRCODE) && ($NonVegAnth  eq ERRCODE) && ($NonForVeg  eq ERRCODE) && ($UnProdFor  eq ERRCODE)) || (($NatNonVeg  eq MISSCODE) && ($UnProdFor  eq MISSCODE) &&($NonVegAnth  eq MISSCODE) && ($NonForVeg  eq MISSCODE))){ 
	  			if (defined $Sp1 ) {
                    
                } else {
                    $Sp1="";
                }
				if(($bclcs4 eq "ST")|| ($bclcs4  eq "SL")) {
					$NonForVeg 	= MISSCODE; $NatNonVeg =MISSCODE;  $NonVegAnth=MISSCODE; 
				}
				if(($bclcs4 eq "TM") || ($bclcs4 eq "TC")|| ($bclcs4 eq "TB")|| ($bclcs4 eq "ST")|| ($bclcs4  eq "SL")) {
					$NonForVeg 	= MISSCODE; $NatNonVeg =MISSCODE;  $NonVegAnth=MISSCODE; $UnProdFor = "PF";
				} elsif(isempty($Sp1)) {
					$keys="NatNonVeg-nonfordesc="."#".$Nfor_desc."#bclcs4".$row->{BCLCS_LEVEL_4}."#STANDARD F, invversion=".$INV_version." and species is nulland NPdesc=".$NPdesc."*";  								$herror{$keys}++;
				}
	  		}	
			#end new
			if ($NatNonVeg eq ERRCODE) {
                $NatNonVeg=UNDEF;
            } 
            if ( $NonForVeg eq ERRCODE) {
                $NonForVeg =UNDEF;
            } 
            if ($NonVegAnth eq ERRCODE) {
                $NonVegAnth=UNDEF;
            }
 			if ($UnProdFor eq ERRCODE) {
                $UnProdFor=UNDEF;
            }
		}
      	
      	if (($NatNonVeg ne MISSCODE && $NatNonVeg ne UNDEF) || ($NonVegAnth ne MISSCODE && $NonVegAnth ne UNDEF) || ($NonForVeg ne MISSCODE && $NonForVeg ne UNDEF)) { 
			$IS_NFOR=1;
		}

	  # ===== Modifiers =====   TODO
 
	  	$Mod1Ext      =  UNDEF;  
	
		if ($std_num eq "0007") 
		{
			$Mod1 ="";
			$Mod1Yr="";
		}
		else 
		{
			$Mod1         = $row->{LINE_7B_DISTURBANCE_HISTORY};
			if(length $Mod1 >=3 && !isempty($Mod1))
			{
		 		$Mod1         =  substr $row->{LINE_7B_DISTURBANCE_HISTORY}, 0, 1;
				$Mod1Yr       =  substr $row->{LINE_7B_DISTURBANCE_HISTORY}, 1, 2; 

				if($row->{LINE_7B_DISTURBANCE_HISTORY} =~ /L\%/)
				{
					$keys="Extent1 not handled#"."#".$row->{LINE_7B_DISTURBANCE_HISTORY};
					$herror{$keys}++;
				}
		 		if($Mod1Yr =~ /\D/){
					$Mod1Yr="";
					$Mod1=-1;
					$keys="disturbance"."#".$row->{LINE_7B_DISTURBANCE_HISTORY};
					$herror{$keys}++;
				}
				else { 
					if($Mod1Yr >10) {
							$Mod1Yr= "19".$Mod1Yr;
					}
					else {
							$Mod1Yr= "20".$Mod1Yr;
					}
				}
			}
			elsif(length $row->{LINE_7B_DISTURBANCE_HISTORY} ==1) {
				
				$Mod1 =$row->{LINE_7B_DISTURBANCE_HISTORY};
				$Mod1Yr="";
			}
			elsif($row->{LINE_7B_DISTURBANCE_HISTORY} ne "NULL") {
				$Mod1 ="";
				$Mod1Yr="";
				$keys="disturbance length <3"."#".$row->{LINE_7B_DISTURBANCE_HISTORY};
				$herror{$keys}++;
			}
			else {
			
				$Mod1 ="";
				$Mod1Yr="";
			}
		}

	  	$Dist1 = Disturbance($Mod1, $Mod1Yr);
	  	($Cd1, $Cd2)=split(",", $Dist1);
	 	if($Cd1 eq ERRCODE) 
	 	{  
			$keys="Disturbance1"."#---".$Mod1."***earliest#".$row->{HARVEST_DATE};
			$herror{$keys}++; 
	  	}
	
		$Dist1ExtHigh  =  UNDEF;
		$Dist1ExtLow   =  UNDEF;
        $Dist1 = $Dist1 . "," . $Dist1ExtHigh . "," . $Dist1ExtLow;
        $Dist2 = UNDEF . "," .UNDEF. "," .UNDEF . "," .UNDEF;
        $Dist = $Dist1 . "," . $Dist2. "," . UNDEF. "," .UNDEF. "," .UNDEF. "," .UNDEF;


		# ======================================================= WRITING Output inventory info IN CAS FILES =======================================================================================================
		my $prod_for="PF";
		my $lyr_poly=1;
		if(isempty($Sp1) || $SpeciesComp eq "-1" || $SpeciesComp eq "")
		{
			$SpeciesComp="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
			if ( !is_missing($CCHigh) ||  !is_missing($CCLow) || !is_missing($HeightHigh) || !is_missing($HeightLow))  
			{
				$prod_for="PP";
				$SpeciesComp="UNDEF,0,UNDEF,0,UNDEF,0,UNDEF,0,UNDEF,0,UNDEF,0,UNDEF,0,UNDEF,0,UNDEF,0,UNDEF,0";
			}
			else
			{
				$lyr_poly=0;
			}

		}
		if ($Cd1  eq "CO")
		{
			$prod_for="PF";
			$lyr_poly=1;
		}
		if (!is_missing($UnProdFor))
		{
			#new rule from Melina and Steve
			$prod_for="PP";
			if($UnProdFor eq "SD")
			{
				$prod_for = "NP";
				if(isempty($Sp1))
				{
				  	$SpeciesComp="UNDEF,0,UNDEF,0,UNDEF,0,UNDEF,0,UNDEF,0,UNDEF,0,UNDEF,0,UNDEF,0,UNDEF,0,UNDEF,0";
				}
				$keys="verify disturbance for SD Prodfor "."#---".$Cd1."***origin#".$Mod1;
				$herror{$keys}++; 
			}
			# else 
			# {
			# 	$prod_for=$UnProdFor;
			# }
		}

		#new rule from Melina and Steve
		$ucsp1 = defined ($Sp1)? uc($Sp1) :"";
		if($ucsp1 eq "XC" || $ucsp1 eq "XH" || $ucsp1 eq "ZC" || $ucsp1 eq "ZH")
		{
			if(isempty($Nfor_desc))
			{
				$prod_for = "PP";
			}
			else 
			{
				$prod_for = "NP";
			}
		}

		if ($invstd eq "F" && $Hdr_F_set==0)
		{
			$Hdr_F_set=1;
			print CASHDR $HDR_RecordF . "\n";
		}
		elsif ($invstd eq "V" && $Hdr_V_set==0)
		{
			#print "invent is $invstd and hdrset = $Hdr_V_set\n"; 
			$Hdr_V_set=1;
			print CASHDR $HDR_RecordV . "\n";
		}
		elsif ($invstd eq "I" && $Hdr_I_set==0)
		{
			$Hdr_I_set=1;
			print CASHDR $HDR_RecordI . "\n";
		}



        $CAS_Record = $CAS_ID . "," . $StandID . "," . $StandStructureCode. "," .$NumLayers.",". $IdentifyID . "," . $MapSheetID . "," . $Area . "," . $Perimeter . ",".$Area. ",".$PHOTO_YEAR;
	    print CASCAS $CAS_Record . "\n";
		$nbpr=1;$$ncas++;$ncasprev++;


	    $isNFL=1;
	    if ($invstd eq "V" || $invstd eq "I")
	    {
 			if (($NatNonVeg ne MISSCODE && $NatNonVeg ne UNDEF) || ($NonVegAnth ne MISSCODE && $NonVegAnth ne UNDEF) || ($NonForVeg ne MISSCODE && $NonForVeg ne UNDEF)){
			#if ($NatNonVeg ne MISSCODE || $NonVegAnth ne MISSCODE || $NonForVeg ne MISSCODE){
				$NFL_Record3 = $NatNonVeg . "," . $NonVegAnth . "," . $NonForVeg;
			}
			elsif (($NatNonVeg2 ne MISSCODE && $NatNonVeg2 ne UNDEF) || ($NonVegAnth2 ne MISSCODE && $NonVegAnth2 ne UNDEF) || ($NonForVeg2 ne MISSCODE && $NonForVeg2 ne UNDEF)){
			#elsif ($NatNonVeg2 ne MISSCODE || $NonVegAnth2 ne MISSCODE || $NonForVeg2 ne MISSCODE){
				$NFL_Record3 = $NatNonVeg2 . "," . $NonVegAnth2 . "," . $NonForVeg2;
			}
			elsif (($NatNonVeg3 ne MISSCODE && $NatNonVeg3 ne UNDEF) || ($NonVegAnth3 ne MISSCODE && $NonVegAnth3 ne UNDEF) || ($NonForVeg3 ne MISSCODE && $NonForVeg3 ne UNDEF)){
			#elsif ($NatNonVeg3 ne MISSCODE || $NonVegAnth3 ne MISSCODE || $NonForVeg3 ne MISSCODE){
				$NFL_Record3 = $NatNonVeg3 . "," . $NonVegAnth3 . "," . $NonForVeg3;
			}
			else {$isNFL=0;}
	    }
	    elsif ($invstd eq "F" )
	    {
 		
			if (($NatNonVeg ne MISSCODE && $NatNonVeg ne UNDEF) || ($NonVegAnth ne MISSCODE && $NonVegAnth ne UNDEF) || ($NonForVeg ne MISSCODE && $NonForVeg ne UNDEF)){
			#if ($NatNonVeg ne MISSCODE || $NonVegAnth ne MISSCODE || $NonForVeg ne MISSCODE){
				$NFL_Record3 = $NatNonVeg . "," . $NonVegAnth . "," . $NonForVeg;
			}
			else {$isNFL=0;}
	    }
	    else {print "standard not V,I nor F; check it!\n"; exit;}



	    if (defined $Sp1 ) {} else {$Sp1="";}  if (defined $Sp2 ) {} else {$Sp2="";}
        #layer 1
        #if (!isempty($Sp1) || ($UnProdFor ne MISSCODE && $UnProdFor ne ERRCODE && $UnProdFor ne UNDEF)) {
		if (!isempty($Sp1) || $lyr_poly==1) 
		{
	     	$LYR_Record1 = $CAS_ID . "," . $SMR  . "," . $StandStructureVal . "," .$LayerId.",". $LayerRank;  #old ",1,1"  -change on july 2014
	      	$LYR_Record2 = $CCHigh . "," . $CCLow . "," . $HeightHigh . "," . $HeightLow . "," . $prod_for.",".$SpeciesComp;
	      	$LYR_Record3 = $OriginHigh . "," . $OriginLow . "," . $SiteClass . "," . $SiteIndex;
	      	$Lyr_Record = $LYR_Record1 . "," . $LYR_Record2 . "," . $LYR_Record3;
	      	print CASLYR $Lyr_Record . "\n";
 			$nbpr++; $$nlyr++;$nlyrprev++;
 			#print "voici $LYR_Record3\n";
		}

        elsif ( $isNFL==1) 
        { 
            $NFL_Record1 = $CAS_ID . "," . $SMR  . "," . $StandStructureVal . "," .$LayerId.",". $LayerRank;  #old ",1,1"  -change on july 2014
            $NFL_Record2 = $CCHigh . "," . $CCLow . "," . MISSCODE . "," . MISSCODE;
            $NFL_Record3 = $NatNonVeg . "," . $NonVegAnth . "," . $NonForVeg;
            $NFL_Record = $NFL_Record1 . "," . $NFL_Record2 . "," . $NFL_Record3;
            print CASNFL $NFL_Record . "\n";
	      	$nbpr++;$$nnfl++;$nnflprev++;
		}
		#else {print "NFL null --- codes2 ::: natnonveg---$NatNonVeg2--- NonvegAnth---$NonVegAnth2--- nonforveg---$NonForVeg2---\n"}
               # elsif ($Sp1 eq "") {print "NFL null ---  ::: species 1 null--$CAS_ID\n"; }
		######################## other layer
		######################end 

	   	if (!isempty($Mod1) && $Cd1 ne ERRCODE) 
	   	{
		    $DST_Record = $CAS_ID . "," . $Dist. ",". $LayerId;  #June 2014 --- newly added, layer fiel in .dst record
		    print CASDST $DST_Record . "\n";
			if($nbpr==1) {$$ndstonly++; $ndstonlyprev++;}
			$nbpr++;$$ndst++;$ndstprev++;
	   	}

		$Ecosite="-";
		if(defined $row->{BEC_ZONE_CODE} )
		{
			if( !isempty($row->{BEC_ZONE_CODE}))
			{
				if( isempty($row->{BEC_SUBZONE})){$row->{BEC_SUBZONE}="";}
				if( isempty($row->{BEC_VARIANT})){$row->{BEC_VARIANT}="";}
				if( isempty($row->{BEC_PHASE})) {$row->{BEC_PHASE}="";}
				if( isempty($row->{SITE_POSITION_MESO})) {$row->{SITE_POSITION_MESO}="";}
				$row->{BEC_SUBZONE}=~ s/\s//g;
				$row->{BEC_VARIANT}=~ s/\s//g;
				$row->{BEC_PHASE}=~ s/\s//g;
				$row->{SITE_POSITION_MESO}=~ s/\s//g;
				$Ecosite=$row->{BEC_ZONE_CODE}.".".$row->{BEC_SUBZONE}.".".$row->{BEC_VARIANT}.".".$row->{BEC_PHASE}.".".$row->{SITE_POSITION_MESO};
			}
		} 
        #Ecological, which layer for other info
	    if ($Wetland ne MISSCODE) 
	    {
	    	$Wetland = $CAS_ID . "," . $Wetland.$Ecosite;
	      	print CASECO $Wetland . "\n";
			if($nbpr==1) {$$necoonly++;$necoonlyprev++;}
			$nbpr++;$$neco++;$necoprev++;
	    }

		if($nbpr ==1 )
		{

			$ndrops++;
			if($temp2 ne "")
			{
				if($INV_version eq "V" || $INV_version eq "I") 
				{
			 		if(defined $BC_Areatracking{$CAS_ID}) 
			 		{
						$$temp3+=$Area; $missing_area+=$Area;
						print MISSING_STANDS "$CAS_ID, LYR from $$SpComp, NFL from $LandCoverClassCode and $NonVeg, wetland= $Wetland, DST from $Mod1 >>>file=$Glob_filename \n"; 
					}
		    	}
		    	else 
		    	{	
		    		if(defined $BC_Areatracking{$CAS_ID})
		    		{
						$$temp3+=$Area; $missing_area+=$Area;
						print MISSING_STANDS "$CAS_ID, LYR from $$SpComp, NFL from $NPdesc, wetland= $Wetland, DST from $Mod1 >>>file=$Glob_filename \n";
					}
		    	}
			}
        }
	}

  	$csv->eof or $csv->error_diag ();
 	 close $BCinv;

	print MISSING_STANDS "###########total area missed in this file = $missing_area,  cumul= $$temp3\n";

	foreach my $k (sort {lc($a) cmp lc($b)} keys %$spfreq)
	{
		$_ = $k;
		tr/a-z/A-Z/;
		my $upk = $_;
	 	print SPERRSFILE "cumulative frequency of species " ,$upk,  " is ", $spfreq->{$k},"\n";
		#print "invalid code " ,$k,  " found ", $herror{$k}," times\n";
  	}
	foreach my $k (keys %herror)
	{
	 	print ERRS "invalid code " ,$k,  " found ", $herror{$k}," times\n";
		#print "invalid code " ,$k,  " found ", $herror{$k}," times\n";
	}
	 
    #close (BCinv);
	close (CASHDR);
	close (CASCAS);
	close (CASLYR);
	close (CASNFL);
	close (CASDST);
	close (CASECO);
	close(ERRS);	
	close(SPECSLOGFILE); 
	close(SPERRSFILE);
	close(MISSING_STANDS);

	$total=$nlyrprev+ $nnflprev+  $ndstprev;
	$total2=$nlyrprev+ $nnflprev+  $ndstonlyprev + $necoonlyprev;
	print " ndrops =$ndrops, nb current records in: casfile = $ncasprev, lyrfile = $nlyrprev, nflfile = $nnflprev,  dstfile = $ndstprev($ndstonlyprev), ecofile = $necoprev($necoonlyprev)--- total (without .cas): $total($total2)\n";
}

1;

