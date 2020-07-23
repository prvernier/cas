sub BCinv_to_CAS 
{

	#################################3

	my %BC_Areatracking = ();
	my $missingcasfile= $temp2;
 	if($temp2 ne "")
 	{
		open( BC_MS, "$missingcasfile" )
		  || die "\n Error: Could not open species correction file --*$missingcasfile*--- !\n";
		my $csv2    = Text::CSV_XS->new();
		my $nothing2 = <BC_MS>;            #drop header line
		while (<BC_MS>) 
		{
			if ( $csv2->parse($_) ) {
				my @BCcas_Record = ();
				@BCcas_Record = $csv2->fields();
				my $BCkeys = $BCcas_Record[0];
				$BC_Areatracking{$BCkeys} = 1;
				#print("fFILE no = $MBkeys , age = @MBS_Record[1]\n"); #exit;
			}
			else {
				my $err = $csv2->error_input;
				print "Failed to parse line: $err";
				exit(1);
			}
		}
		close(BC_MS);
	}
	################

	while (my $row = $csv->getline_hr ($BCinv)) 
   	{	
  
		#$INV_cod_stand = $row->{INVENTORY_STANDARD_CD}; #INVENTORY_
		$CAS_ID       =  $row->{CAS_ID}; 
		$Glob_CASID   =  $row->{CAS_ID};
		($pr1,$pr2,$pr3, $pr4, $pr5)     =  split("-", $row->{CAS_ID} );    	    
	    $MapSheetID   =  $pr3; 
	    $MapSheetID =~ s/x+//;
	    $StandID = $pr4;
		$StandID =~ s/^0+//;
	     
	    $IdentifyID   =  $row->{HEADER_ID};     	
	    $Area         =  $row->{GIS_AREA};    
		$Perimeter    =  $row->{GIS_PERI};  

		($P1, $P2)=split("-",  $CAS_ID);
		($juridname, $std_num)=split ("_", $P1);

		if($std_num eq "0007")
		{
			$INV_version="V";
			$invstd="V";
		}
		else 
		{
			$invstd=$row->{INVENTORY_STANDARD_CD}; 
			$INV_version=$invstd;
		}
	 	 
		if ( $std_num ne "0007" && $INV_version ne $invstd)
		{
			print "standard mistmatch : _inventory field is $invstd --- computed is $INV_version from $P1 \n";
			exit;
		} 

	  	if (defined $row->{REFERENCE_YEAR}) {$SUBS_REFYEAR=$row->{REFERENCE_YEAR};}
		elsif ( defined $row->{REFERENCE_YR}) {$SUBS_REFYEAR=$row->{REFERENCE_YR};}
		else { print "ref_year not found in source data\n"; exit;}

	 	$PROJECTED_YEAR= substr $row->{PROJECTED_DATE}, 0, 4;

		if(isempty($SUBS_REFYEAR))
		{
			$REF_YEAR=MISSCODE;
			#print "look for this refyear $SUBS_REFYEAR \n"; #exit;
		}
		else 
		{	  
			$REF_YEAR = $SUBS_REFYEAR; #  substr $row->{REFERENCE_YEAR}, 0, 4 ; #substr $row->{REF_DATE}, 0, 4 ; 
		 
	        if ($REF_YEAR <=0) 
	        {
				print "want to see this one  $REF_YEAR from ".$SUBS_REFYEAR. " \n"; exit;
				$REF_YEAR = MISSCODE;
				$keys="ref_year negative value"."#".$REF_YEAR;
				$herror{$keys}++;
		 	}
		}
		# REFERENCE_DATE  
		$PHOTO_YEAR=0;

	 	if(isempty($row->{REFERENCE_DATE})  && !isempty($SUBS_REFYEAR))
	 	{
			$PHOTO_YEAR=$SUBS_REFYEAR;
		}
		elsif(isempty($row->{REFERENCE_DATE}))
		{
			$PHOTO_YEAR=MISSCODE;
		}
		else
		{
		 	my $nl=length ($row->{REFERENCE_DATE});
		  	if($nl >=4)
		  	{
		  		$PHOTO_YEAR = substr $row->{REFERENCE_DATE}, 0, 4 ;  #$PHOTO_YEAR = substr $row->{REFERENCE_DATE}, $nl-4, 4 ;
		  	}
		  	# if(defined $PHOTO_YEAR){}else {$PHOTO_YEAR=0;}
		 	
		  	if ($PHOTO_YEAR <=0 || $PHOTO_YEAR >2014) 
		  	{
				$PHOTO_YEAR = MISSCODE;
				$keys="photoyear "."#".$PHOTO_YEAR."#taken from#".$row->{REFERENCE_DATE};
				$herror{$keys}++;
		  	}
		}
    	
		$MoistReg     =  $row->{SOIL_MOISTURE_REGIME_1}; 

		#if($std_num eq "0007"){
					$LayerRank=1;
					$Struc="S";  
					$NumLayers=1;
					$LayerId=1;
		#}
		#else {
		 	
	  	#  	$LayerRank	= $row->{FOR_COVER_RANK_CD}; #RANK_CD, FOR_COVER_
		#		        if($LayerRank ne "" && $LayerRank ne "1" && $LayerRank ne "NULL") {$keys="rank_cd"."#".$LayerRank;
		#						     $herror{$keys}++;   
		#		  	} 
		#			if ($LayerRank eq "NULL") {$LayerRank=MISSCODE;}
		#	$Struc="M";  
		#	$NumLayers=1; #temporaire
		 # 	$LayerId	= $row->{LAYER_ID};
		#	$keys="LayerID***" .$LayerId;
		#	$herror{$keys}++;	
		#	if ($LayerId ne "NULL" && $LayerRank eq MISSCODE) { $keys="BIZARRE layer_id not null but rankcd is"."#".$LayerId;
		#						    		 $herror{$keys}++;   
		#	}
		#	if ($LayerId eq "NULL") {$LayerId=MISSCODE;}
		#}


		#if($INV_version eq "F" ){   #$INV_cod_stand   USE THIS FOT BCTFL48
		#  	$CrownClosure =  $row->{CROWN_CLOSURE_CLASS_CD};   #$row->{CROWN_CL_1};  or $row->{CR_CLOSURE};	
		#	#if(!$row->{CROWN_CLOSURE_CLASS_CD}) {$CrownClosure ="";}
		#} 
		#elsif($std_num eq "0004" || $std_num eq "0005" || $std_num eq "0006"){   #$INV_cod_stand   USE THIS FOT BCTFL48
		#  	$CrownClosure =  $row->{CROWN_CLOSURE};   #$row->{CROWN_CL_1};  or $row->{CR_CLOSURE};	
		#	#if(!$row->{CROWN_CLOSURE_CLASS_CD}) {$CrownClosure ="";}
		#} 
		
		$CrownClosure =  $row->{CROWN_CLOSURE_CLASS_CD};
	 	$CCHigh       =  CCUpper($CrownClosure); 
	    $CCLow        =  CCLower($CrownClosure);
	   
	 	if($CCHigh  eq ERRCODE   || $CCLow  eq ERRCODE || $CCHigh  >100   || $CCLow >100) 
	 	{ 
			$keys="CrownClosure"."#".$CrownClosure;
		    $herror{$keys}++; 
		}

		$Sp1          =  $row->{SPECIES_CD_1}; #SPEC_CD_1
	    $Sp2          =  $row->{SPECIES_CD_2}; #SPEC_CD_2
	    $Sp3          =  $row->{SPECIES_CD_3}; #SPEC_CD_3
	    $Sp4          =  $row->{SPECIES_CD_4}; #SPEC_CD_4
	    $Sp5          =  $row->{SPECIES_CD_5}; #SPEC_CD_5
	    $Sp6          =  $row->{SPECIES_CD_6}; #SPEC_CD_6
	         
	    $Sp1Per       =  $row->{SPECIES_PCT_1};  #SPEC_PCT_1
	    $Sp2Per       =  $row->{SPECIES_PCT_2} ;  #SPECIES__2
	    $Sp3Per       =  $row->{SPECIES_PCT_3} ;  #SPEC_PCT_3
	    $Sp4Per       =  $row->{SPECIES_PCT_4} ;  #SPEC_PCT_4
	    $Sp5Per       =  $row->{SPECIES_PCT_5}  ;  #SPEC_PCT_5
	    $Sp6Per       =  $row->{SPECIES_PCT_6} ; #SPEC_PCT_6

		if(!defined $Sp1Per || isempty($Sp1Per)){$Sp1Per=0;}
		if(!defined $Sp2Per || isempty($Sp2Per)){$Sp2Per=0;}
		if(!defined $Sp3Per || isempty($Sp3Per)){$Sp3Per=0;}
		if(!defined $Sp4Per || isempty($Sp4Per)){$Sp4Per=0;}
		if(!defined $Sp5Per || isempty($Sp5Per)){$Sp5Per=0;}
		if(!defined $Sp6Per || isempty($Sp6Per)){$Sp6Per=0;}

		$Sp1Per =~ s/\.([0-9]+)$//g;$Sp2Per =~ s/\.([0-9]+)$//g;$Sp3Per =~ s/\.([0-9]+)$//g;$Sp4Per =~ s/\.([0-9]+)$//g;$Sp5Per =~ s/\.([0-9]+)$//g;
		$Sp6Per =~ s/\.([0-9]+)$//g;

        $Total_pct=$Sp1Per+$Sp2Per+$Sp3Per+$Sp4Per+$Sp5Per+$Sp6Per;
	
		if(  $Total_pct >100) 
		{
			$keys="Perctg_Species >100"."#".$Sp1."___". $Sp1Per."####".$Sp2."___". $Sp2Per."####".$Sp3."___". $Sp3Per."####".$Sp4."___". $Sp4Per."####".$Sp5."___". $Sp5Per."####".$Sp6."___". $Sp6Per;
			$herror{$keys}++;
		}
		$NonVeg       =  $row->{NON_VEG_COVER_TYPE_1};   #NVEG_TYP_1,  NON_VEG__2
	  	$NonVegPct    =  $row->{NON_VEG_COVER_PCT_1};   #NVEG_TYP_1,  NON_VEG__2
	  	

		$NPdesc	=  $row->{NON_PRODUCTIVE_DESCRIPTOR_CD}; #NP_DESC, NON_PRODUC
		$NPcode	=  $row->{NON_PRODUCTIVE_CD};    #NP_CODE, NON_PROD_1
		if(defined $row->{NON_FOREST_DESCRIPTOR}) 
		{
			$Nfor_desc= $row->{NON_FOREST_DESCRIPTOR};
		} #NFOR_DESC, NON_FOREST
		else {$Nfor_desc="";}   

 	
	  
	 	$SiteClass	=  $row->{EST_SITE_INDEX_SOURCE_CD}; #HIST_S_CD, EST_SITE_I
		#$SiteIndex 	=  $row->{SITE_INDEX}; 
        if (!isempty($row->{SITE_INDEX}))
        {
  			$SiteIndex  = sprintf("%.1f", $row->{SITE_INDEX});
  			#print "siteindex is $SiteIndex\n";
	   	}
	  	else {$SiteIndex  = MISSCODE;} 

 	  	$LandCoverClassCode  =  $row->{LAND_COVER_CLASS_CD_1}; #LAND_CD_1, LAND_COVER
       	 
	  	$SMR =  SoilMoistureRegime($row->{SOIL_MOISTURE_REGIME_1}, $std_num);
	  	if($SMR eq ERRCODE) 
	  	{ 
			$keys="MoistReg"."#".$row->{SOIL_MOISTURE_REGIME_1};
			$herror{$keys}++;	
	  	}

        $StandStructureCode   =  $Struc; # BK- july 2014 StandStructure($Struc);#StandStructure($Struc, $INV_version);
        $StandStructureVal     =  UNDEF;  #"";

	  	$Height   =  $row->{PROJ_HEIGHT_CLASS_CD_1};
	  	if($Height eq "0.0" || isempty($Height)){$Height=0;}
	  	$HeightHigh   =  StandHeightUp($Height);
        $HeightLow    =  StandHeightLow($Height);

	  	if($HeightHigh  eq ERRCODE   || $HeightLow  eq ERRCODE) 
	  	{ 
	  		$keys="Height"."#".$Height; #."#comment#".$row->{MD_COMMENT};
			$herror{$keys}++; 
		}

		#if($HeightHigh  eq MISSCODE   || $HeightLow  eq MISSCODE) { 
		#					if($Sp1 ne "" && $Sp1 ne "0" && $Sp1 ne "NULL" && $LayerRank eq "1"){
		#						       $keys="NULL Height"."#".$Height."#species1#".$Sp1."#LandCC#".$LandCoverClassCode;
		#				     			$herror{$keys}++;
		#					}	
														
		#}

		$SpComp=$Sp1."#".$Sp1Per."#".$Sp2."#".$Sp2Per."#".$Sp3."#".$Sp3Per."#".$Sp4."#".$Sp4Per."#".$Sp5."#".$Sp5Per."#".$Sp6."#".$Sp6Per;

		$SpeciesComp  =  Species($Sp1, $Sp1Per, $Sp2, $Sp2Per, $Sp3, $Sp3Per, $Sp4, $Sp4Per, $Sp5, $Sp5Per, $Sp6, $Sp6Per, $spfreq);
		@SpecsPerList  = split(",", $SpeciesComp); 
		@SpecsInit=($Sp1, $Sp2, $Sp3, $Sp4, $Sp5, $Sp6);
		$totalpct=$SpecsPerList[1]+$SpecsPerList[3]+$SpecsPerList[5]+$SpecsPerList[7]+$SpecsPerList[9]+$SpecsPerList[11];
		my $nbf=0;
		my $pos_inc=0;
	 	if(  $totalpct>=80 &&  $totalpct<100) 
	 	{ 

			for($cpt_ind=0; $cpt_ind<6; $cpt_ind++)
			{  
				my $posi=$cpt_ind*2;
	 	 		if($SpecsPerList[$posi] ne "XXXX MISS"  && $SpecsPerList[$posi+1]==0 ) 
	 	 		{ 
					$nbf++;	
					$pos_inc=$posi+1;	  
				}
		  	}
			if($nbf>1)
			{
				$keys="CORRECTION nb P=0#".$nbf;
				$herror{$keys}++; 
			}
			elsif($nbf==1)
			{
					
				if( (100-$totalpct) > $SpecsPerList[$pos_inc-2])
				{
					$SpecsPerList[$pos_inc]=$SpecsPerList[$pos_inc-2];
					$SpecsPerList[$pos_inc-2]=100-$totalpct;
				}
				else
				{
					$SpecsPerList[$pos_inc]=100-$totalpct;
				}
	 			#$totalpct=$SpecsPerList[1]+$SpecsPerList[3]+$SpecsPerList[5]+$SpecsPerList[7]+$SpecsPerList[9]+$SpecsPerList[11];
				#$SpeciesComp=join(",", @SpecsPerList );
			}
			else 
			{
				$SpecsPerList[1]=$SpecsPerList[1] + 100-$totalpct;
				#$totalpct=$SpecsPerList[1]+$SpecsPerList[3]+$SpecsPerList[5]+$SpecsPerList[7]+$SpecsPerList[9]+$SpecsPerList[11];
			}
			$totalpct=$SpecsPerList[1]+$SpecsPerList[3]+$SpecsPerList[5]+$SpecsPerList[7]+$SpecsPerList[9]+$SpecsPerList[11];
			$SpeciesComp=join(",", @SpecsPerList );
	 	}
	
		if(  $totalpct!=100 &&  $totalpct!= 0) 
		{ 
			$keys="nbf=$nbf  total pctg != 100#"."(".$totalpct.")#".$SpeciesComp;
			$herror{$keys}++; 
		}

	  	for($cpt_ind=0; $cpt_ind<6; $cpt_ind++)
	  	{  
	  		my $posi=$cpt_ind*2;
 	 		if($SpecsPerList[$posi]  eq SPECIES_ERRCODE ) 
 	 		{
 	 		 	$keys="Species$cpt_ind"."#".$SpecsInit[$cpt_ind]."#casid=".$CAS_ID;
				$herror{$keys}++; 
			}
	  	}	
 	  	$SpeciesComp  =  $SpeciesComp .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";		#

  	  	$Origin       =  $row->{PROJ_AGE_CLASS_CD_1}; 
        $OriginHigh   =  UpperOrigin($Origin);
        $OriginLow    =  LowerOrigin($Origin);

	 
	  	if($std_num ne "0007")
	  	{ 
			$Mod1         = $row->{LINE_7B_DISTURBANCE_HISTORY};
 			$Mod2         = $row->{LINE_6_SITE_PREP_HISTORY}; 
	 		$Mod3         = $row->{LINE_8_PLANTING_HISTORY};
	 		if (!isempty($Mod2))
	 		{
				$keys="valid other 2nd disturbance----*".$Mod2;
				$herror{$keys}++;
			}
			if (!isempty($Mod3))
			{
				$keys="valid other 3rd disturbance----*".$Mod3;
				$herror{$keys}++;
			}
	 	}
	 	else 
	 	{
	 		$Mod1=MISSCODE;$Mod1Yr=MISSCODE;
	 	}
	
	 	#if(($OriginHigh  eq MISSCODE   || $OriginLow  eq MISSCODE ) &&  $Sp1 ne "" &&  $Sp1 ne "NULL" && $LayerRank eq "1" ) { 
			#						       $keys="NULL Age"."#".$Origin."#species1#".$Sp1."#LandCC#".$LandCoverClassCode."#disturb#".$Mod1;
		#					     			$herror{$keys}++;									
		#	}
		if($OriginHigh  eq ERRCODE   || $OriginLow  eq ERRCODE) 
		{ 
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

	  	#NaturallyNonVeg-Anthropogenic-NonForestedVeg-UnProdForest
	  
 	  	#$NPcodedesc	=  NPCodetoNPDesc($NPcode); $NatNonVeg3 =  NaturallyNonVeg($NPcodedesc);$NonVegAnth3  =  Anthropogenic($NPcodedesc); $UnProdFor2 	=  UnProdForest($NPcodedesc); $NonForVeg3 	=  NonForestedVeg($NPcodedesc);

	  	my $IS_NFOR=0;
	  	my $bclcs4=$row->{BCLCS_LEVEL_4};
		$NonVegAnth2=MISSCODE;$NonVegAnth3=MISSCODE;$NatNonVeg2=MISSCODE;$NatNonVeg3=MISSCODE;$NonForVeg2=MISSCODE;$NonForVeg3=MISSCODE;
 	  	if($INV_version eq "V" || $INV_version eq "I") 
 	  	{

			$UnProdFor 	=  MISSCODE;
			
			if(!isempty($Sp1) && ($LandCoverClassCode eq "TM") || ($LandCoverClassCode eq "TC")|| ($LandCoverClassCode eq "TB")|| ($LandCoverClassCode eq "ST")|| ($LandCoverClassCode eq "SL")) 
	  		{$NonForVeg 	= MISSCODE; $NatNonVeg =MISSCODE;  $NonVegAnth=MISSCODE; $UnProdFor 	= "PF";}

			elsif(!isempty($Sp1) && ($bclcs4 eq "TM") || ($bclcs4 eq "TC")|| ($bclcs4 eq "TB")|| ($bclcs4 eq "ST")|| ($bclcs4 eq "SL")) 
	  		{$NonForVeg 	= MISSCODE; $NatNonVeg =MISSCODE;  $NonVegAnth=MISSCODE; $UnProdFor 	= "PF";}

			elsif(isempty($Sp1) && (!isempty($LandCoverClassCode) || !isempty($NonVeg) || !isempty($bclcs4)) ) 	
			{ 
				$NonForVeg 	=  NonForestedVeg($LandCoverClassCode);
				$NatNonVeg2 	=  NaturallyNonVeg($LandCoverClassCode);   
  		 		$NonVegAnth2	=  Anthropogenic($LandCoverClassCode);   

				$NonForVeg2 	=  NonForestedVeg($NonVeg);
				$NatNonVeg 	=  NaturallyNonVeg($NonVeg);   
	  		 	$NonVegAnth	=  Anthropogenic($NonVeg);   

				$NonForVeg3 	=  NonForestedVeg($bclcs4);
				$NatNonVeg3 	=  NaturallyNonVeg($bclcs4);   
	  		 	$NonVegAnth3	=  Anthropogenic($bclcs4); 

		
	 		 	if((($NatNonVeg  eq ERRCODE) && ($NonVegAnth  eq ERRCODE) && ($NonForVeg  eq ERRCODE) && ($NatNonVeg2 eq ERRCODE) && ($NonVegAnth2  eq ERRCODE) && ($NonForVeg2  eq ERRCODE) && ($NatNonVeg3 eq ERRCODE) && ($NonVegAnth3  eq ERRCODE) && ($NonForVeg3  eq ERRCODE)) || (($NatNonVeg  eq MISSCODE) && ($NonVegAnth  eq MISSCODE) && ($NonForVeg  eq MISSCODE) && ($NatNonVeg2  eq MISSCODE) && ($NonVegAnth2  eq MISSCODE) && ($NonForVeg2  eq MISSCODE) && ($NatNonVeg3  eq MISSCODE) && ($NonVegAnth3  eq MISSCODE) && ($NonForVeg3  eq MISSCODE)))
	 		 	{ 

	  				if (defined $Sp1 ) {} else {$Sp1="";}
					$keys="NatNonVeg-NonvegetatedAnth-Nonfor"."#".$NonVeg."#LCCC"."#".$LandCoverClassCode."#bclcs4".$row->{BCLCS_LEVEL_4}."#species is ".$Sp1." and npdesc=".$NPdesc;
					$herror{$keys}++;	
					$NatNonVeg=UNDEF;$NonForVeg =UNDEF;$NonVegAnth=UNDEF;
	  			}
					#if($NonVeg eq "BL" || $NonVeg eq "I" || $NonVeg eq "ER" )
					#{
					#	 $NatNonVeg 	=  MISSCODE;   
	  				#	 $NonVegAnth	=  MISSCODE;   
					#} 
			}
			
			else  {$NonForVeg 	= MISSCODE; $NatNonVeg =MISSCODE;  $NonVegAnth=MISSCODE;}

	  	}
	  	else
	  	{

			$UnProdFor 	=  UnProdForest($Nfor_desc);
			$NonForVeg = MISSCODE; $NatNonVeg= MISSCODE; $NonVegAnth= MISSCODE ;
			
			if ($UnProdFor eq ERRCODE || $UnProdFor eq MISSCODE)
			{
				if(!isempty($Nfor_desc))
				{	
					$keys="Nonfordesc"."#".$Nfor_desc;  $herror{$keys}++;
				}
 				$UnProdFor 	=  UnProdForest($NPdesc);
				$NonForVeg	=  NonForestedVeg($NPdesc);
				$NatNonVeg	=  NaturallyNonVeg($NPdesc);
				$NonVegAnth	=  Anthropogenic($NPdesc);
				
 				if(($UnProdFor  eq ERRCODE) && ($NatNonVeg  eq ERRCODE) && ($NonVegAnth  eq ERRCODE)&& ($NonForVeg  eq ERRCODE) ) 
 				{ 
		 			$keys="UnProdFor-and NN2"."#".$Nfor_desc."#NPdesc".$NPdesc;  $herror{$keys}++;
					#$NatNonVeg=UNDEF;$NonForVeg =UNDEF;$NonVegAnth=UNDEF;$UnProdFor=UNDEF;
				}
			}
			#new to find dropped stands
			if( (($NatNonVeg  eq ERRCODE) && ($NonVegAnth  eq ERRCODE) && ($NonForVeg  eq ERRCODE) && ($UnProdFor  eq ERRCODE)) || (($NatNonVeg  eq MISSCODE) && ($UnProdFor  eq MISSCODE) &&($NonVegAnth  eq MISSCODE) && ($NonForVeg  eq MISSCODE))){ 
	  			if (defined $Sp1 ) {} else {$Sp1="";}

				if(($bclcs4 eq "ST")|| ($bclcs4  eq "SL")) 
	  			{
					$NonForVeg 	= MISSCODE; $NatNonVeg =MISSCODE;  $NonVegAnth=MISSCODE; 
				}

				if(($bclcs4 eq "TM") || ($bclcs4 eq "TC")|| ($bclcs4 eq "TB")|| ($bclcs4 eq "ST")|| ($bclcs4  eq "SL")) 
	  			{
					$NonForVeg 	= MISSCODE; $NatNonVeg =MISSCODE;  $NonVegAnth=MISSCODE; $UnProdFor = "PF";
				}
				elsif(isempty($Sp1))
				{
					$keys="NatNonVeg-nonfordesc="."#".$Nfor_desc."#bclcs4".$row->{BCLCS_LEVEL_4}."#STANDARD F, invversion=".$INV_version." and species is nulland NPdesc=".$NPdesc."*";  								$herror{$keys}++;
				}
	  		}	
			#end new
			if ($NatNonVeg eq ERRCODE) {$NatNonVeg=UNDEF;} if ( $NonForVeg eq ERRCODE) {$NonForVeg =UNDEF;} if ($NonVegAnth eq ERRCODE) {$NonVegAnth=UNDEF;}
 			if ($UnProdFor eq ERRCODE) {$UnProdFor=UNDEF;}
		}

      	if (($NatNonVeg ne MISSCODE && $NatNonVeg ne UNDEF) || ($NonVegAnth ne MISSCODE && $NonVegAnth ne UNDEF) || ($NonForVeg ne MISSCODE && $NonForVeg ne UNDEF)) 
      	{ 
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

		#second disturbance 

		#if(length $row->{LINE_8_PLA} >=3){
		#	$Mod2         =  substr $row->{LINE_8_PLA}, 0, 1; 
		 #	$Mod2Yr       =  substr $row->{LINE_8_PLA}, 1, 2; 
		#
		#	if($row->{LINE_8_PLA} =~ /L\%/){
		#					$keys="Extent2 not handled#"."#".$row->{LINE_8_PLA};
		#					$herror{$keys}++;
		#	}
		# 	if($Mod2Yr =~ /\D/){
		#		$Mod2Yr="";
		#		$Mod2=-1;
		#		$keys="disturbance"."#".$row->{LINE_8_PLA};
		#		$herror{$keys}++;
		#	}
		#	else { 
		#		if($Mod2Yr >10) {
		#					$Mod2Yr= "19".$Mod2Yr;
		#		}
		#		else {
		#					$Mod2Yr= "20".$Mod2Yr;
		#		}
		#	}
		#}
		#elsif(length $row->{LINE_8_PLA} ==1) {
		#	$Mod2 =$row->{LINE_8_PLA};
		#	$Mod2Yr="";
		#}
		#elsif($row->{LINE_8_PLA} ne "") {
		#	$Mod2 ="";
		#	$Mod2Yr="";
		#	$keys="disturbance length <3"."#".$row->{LINE_8_PLA};
		#	$herror{$keys}++;
		#}
		#else {
		#	$Mod2 ="";
		#	$Mod2Yr="";
		#}
	 
		#$Mod2 =UNDEF; $Mod1 =UNDEF;
		#$Mod2Yr=UNDEF;	$Mod1Yr=UNDEF;	
		# $Mod1="";
		#if($Mod1 eq "N" && defined $row->{EARLIEST_NONLOGGING_DIST_TYPE} && length $row->{EARLIEST_NONLOGGING_DIST_TYPE} >1){  #EARLIEST_N
		#	$Mod1= substr $row->{EARLIEST_NONLOGGING_DIST_TYPE}, 1,1;
		#}
		
	  	$Dist1 = Disturbance($Mod1, $Mod1Yr);
	  	($Cd1, $Cd2)=split(",", $Dist1);
	 	if($Cd1 eq ERRCODE) 
	 	{  
			$keys="Disturbance1"."#---".$Mod1."***earliest#".$row->{HARVEST_DATE};
			$herror{$keys}++; 
	  	}
	
		$Dist1ExtHigh  =  UNDEF;
		$Dist1ExtLow   =  UNDEF;
        # $Dist1ExtHigh  =  DisturbanceExtUpper($Mod1Ext);
        # $Dist1ExtLow   =  DisturbanceExtLower($Mod1Ext);
        $Dist1 = $Dist1 . "," . $Dist1ExtHigh . "," . $Dist1ExtLow;
        $Dist2 = UNDEF . "," .UNDEF. "," .UNDEF . "," .UNDEF;
        # $Dist3 = $Dist3 . "," . $Dist3ExtHigh . "," . $Dist3ExtLow;
        $Dist = $Dist1 . "," . $Dist2. "," . UNDEF. "," .UNDEF. "," .UNDEF. "," .UNDEF;


		# ======================================================= WRITING Output inventory info IN CAS FILES =======================================================================================================

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

