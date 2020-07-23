sub MBfrifliinv_to_CAS 
{

	# Those files correspond to the line in the main script where you define the module (end of the script). They have to appear in the same order.
	my $MB_File = shift(@_);
	$Species_table = shift(@_);
	my $CAS_File = shift(@_);
	my $ERRFILE = shift(@_);
	my $nbiters = shift(@_);
	my $optgroups= shift(@_);
	my $pathname=shift(@_);
	my $TotalIT=shift(@_);
	my $std_version = shift(@_);
	my $SPERRS = shift(@_);

	my $spfreq=shift(@_);

	my $ncas=shift(@_);
	my $nlyr=shift(@_);
	my $nnfl=shift(@_);
	my $ndst=shift(@_);
	my $neco=shift(@_);
	my $ndstonly=shift(@_);
	my $necoonly=shift(@_);
	my $nbasprev=shift(@_);
	my $SPECSLOG=shift(@_);
	my $MstandsLOG=shift(@_);

	my $ncasprev=0;
	my $nlyrprev=0;
	my $nnflprev=0;
	my $ndstprev=0;
	my $necoprev=0;
	my $ndstonlyprev=0;
	my $necoonlyprev=0;
	my $total=0;
	my $total2=0;
	my $nbpr=0;

	my $standard_name;

	my $CAS_File_HDR = $CAS_File . ".hdr";
	my $CAS_File_CAS = $CAS_File . ".cas";
	my $CAS_File_LYR = $CAS_File . ".lyr";
	my $CAS_File_NFL = $CAS_File . ".nfl";
	my $CAS_File_DST = $CAS_File . ".dst";
	my $CAS_File_ECO = $CAS_File . ".eco";

	$nbas=0;
	#open (MBinv, "<$MB_File") || die "\n Error: Could not open Manitoba_LP input file!\n";
	open (ERRS, ">>$ERRFILE") || die "\n Error: Could not open $ERRFILE file!\n";
	open (SPERRSFILE, ">>$SPERRS") || die "\n Error: Could not open $SPERRS file!\n";	
	open (SPECSLOGFILE, ">>$SPECSLOG") || die "\n Error: Could not open $SPECSLOG file!\n";
	open (MISSING_STANDS, ">>$MstandsLOG") || die "\n Error: Could not open $MstandsLOG file!\n";

	my $errcode=ERRCODE;
	my $misscode=MISSCODE;
	my $ndrops=0;

	if($optgroups==1){

	 	$CAS_File_HDR = $pathname."/MBLPtable.hdr";
	 	$CAS_File_CAS = $pathname."/MBLPtable.cas";
	 	$CAS_File_LYR = $pathname."/MBLPtable.lyr";
	 	$CAS_File_NFL = $pathname."/MBLPtable.nfl";
	 	$CAS_File_DST = $pathname."/MBLPtable.dst";
	 	$CAS_File_ECO = $pathname."/MBLPtable.eco";
	}
	elsif($optgroups==2){

	 	$CAS_File_HDR = $pathname."/CanadaInventorytable.hdr";
	 	$CAS_File_CAS = $pathname."/CanadaInventorytable.cas";
	 	$CAS_File_LYR = $pathname."/CanadaInventorytable.lyr";
	 	$CAS_File_NFL = $pathname."/CanadaInventorytable.nfl";
	 	$CAS_File_DST = $pathname."/CanadaInventorytable.dst";
	 	$CAS_File_ECO = $pathname."/CanadaInventorytable.eco";
	}

	if(($optgroups==0) || ($optgroups==1 && $nbiters==1)|| ($optgroups==2 && $TotalIT==1))
	{
		open (CASHDR, ">$CAS_File_HDR") || die "\n Error: Could not open CAS header output file!\n";
		open (CASCAS, ">$CAS_File_CAS") || die "\n Error: Could not open CAS common attribute schema  file!\n";
		open (CASLYR, ">$CAS_File_LYR") || die "\n Error: Could not open CAS layer output file!\n";
		open (CASNFL, ">$CAS_File_NFL") || die "\n Error: Could not open CAS non-forested land output file!\n";
		open (CASDST, ">$CAS_File_DST") || die "\n Error: Could not open CAS disturbance output file!\n";
		open (CASECO, ">$CAS_File_ECO") || die "\n Error: Could not open CAS ecological output file!\n";

		print CASCAS "CAS_ID,ORIG_STAND_ID,STAND_STRUCTURE,NUM_OF_LAYERS,IDENTIFICATION_ID,MAP_SHEET_ID,GIS_AREA,GIS_PERIMETER,INVENTORY_AREA,PHOTO_YEAR\n";
		print CASLYR "CAS_ID,SOIL_MOIST_REG,STRUCTURE_PER,LAYER,LAYER_RANK,CROWN_CLOSURE_UPPER,CROWN_CLOSURE_LOWER,HEIGHT_UPPER,HEIGHT_LOWER,PRODUCTIVE_FOR,". 		
		"SPECIES_1,SPECIES_PER_1,SPECIES_2,SPECIES_PER_2,SPECIES_3,SPECIES_PER_3,SPECIES_4,SPECIES_PER_4,SPECIES_5,SPECIES_PER_5,SPECIES_6,SPECIES_PER_6,SPECIES_7,SPECIES_PER_7,".
		"SPECIES_8,SPECIES_PER_8,SPECIES_9,SPECIES_PER_9,SPECIES_10,SPECIES_PER_10,ORIGIN_UPPER,ORIGIN_LOWER,SITE_CLASS,SITE_INDEX\n";
		print CASNFL "CAS_ID,SOIL_MOIST_REG,STRUCTURE_PER,LAYER,LAYER_RANK,CROWN_CLOSURE_UPPER,CROWN_CLOSURE_LOWER,HEIGHT_UPPER,HEIGHT_LOWER,NAT_NON_VEG,NON_FOR_ANTH,NON_FOR_VEG\n";
		print CASDST "CAS_ID,DIST_1,DIST_YR_1,DIST_EXT_UPPER_1,DIST_EXT_LOWER_1,DIST_2,DIST_YR_2,DIST_EXT_UPPER_2,DIST_EXT_LOWER_2,DIST_3,DIST_YR_3,DIST_EXT_UPPER_3,DIST_EXT_LOWER_3,LAYER\n";
		print CASECO "CAS_ID,WETLAND_TYPE,WET_VEG_COVER,WET_LANDFORM_MOD,WET_LOCAL_MOD,ECO_SITE\n";
		print CASHDR "IDENTIFICATION_ID,JURISDICTION,COORDINATE_SYS,PROJECTION,DATUM,INVENTORY_OWNER,LAND_OWNER,PERMISSION,TENURE_TYPE,INV_TYPE,INV_VERSION,INV_START_YR,INV_FINISH_YR,INV_ACQ_ID,INV_ACQ_YR,INV_UPDATE_YR\n";

		my $HDR_Record;
		my $P1;
		
		my @hdr_tab=split("/",  $MB_File);
		my $sz=scalar(@hdr_tab);		$Glob_filename= $hdr_tab[$sz-1];
		my @hdr_id=split ("-", $hdr_tab[$sz-1]);
		($P1, $hdr_num)=split ("_", $hdr_id[0]);
		$hdr_num=~ s/\.csv$//g;
		print "number is ". $hdr_num."\n";
		#exit;

		if($hdr_num eq "0005")
		{
			$HDR_Record=  "5,MB,,UTM,NAD83,INDUSTRY,LouisianaPacific,,,FRI,,1998,1998,,,";
		}
		elsif($hdr_num eq "0006")
		{
			$HDR_Record= "6,MB,,UTM,NAD83,INDUSTRY(Porcupine Mountain),,,,FLI,,1998,1998,,,";
		}

		print CASHDR $HDR_Record . "\n";
	}
	else 	
	{
		open (CASCAS, ">>$CAS_File_CAS") || die "\n Error: Could not open GROUPCAS  output file!\n";
		open (CASLYR, ">>$CAS_File_LYR") || die "\n Error: Could not open GROUPCAS layer output file!\n";
		open (CASNFL, ">>$CAS_File_NFL") || die "\n Error: Could not open GROUPCAS non-forested file!\n";
		open (CASDST, ">>$CAS_File_DST") || die "\n Error: Could not open GROUPCAS disturbance  file!\n";
		open (CASECO, ">>$CAS_File_ECO") || die "\n Error: Could not open GROUPCAS ecological  file!\n";
	}



	#my $Record; my @Fields;my $PolyNum; my $CAS_ID; my $MapSheetID; my $IdentifyID;my $Area; my $Perimeter;
	#my $MoistReg; 
	my $Height;
	my $CrownClosure;
	my $Origin; my $Age; my $NnForVeg; 
	my $WetEco;  my $Ecosite;my $StandStructureCode;
	my $CCHigh;my $CCLow;
	my $SpeciesComp; 
	my $NatNonVeg; 


	#my $CAS_Record; my $Lyr_Record41; my $LYR_Record11; my $LYR_Record21; my $LYR_Record31;
	
	#my $NFL_Record; my $NFL_Record1; my $NFL_Record11; my $NFL_Record21; my $NFL_Record31;
	#my $PHOTO_YEAR;
	#my $CASphotoYear;
	my $NnForVegCode;  my $NonVegAnth;my $NonProdFor; my $NonFor;  my $NonVegWat; my $Spcomp; my $Covertype;
	my $HeightHigh ;  my  $HeightLow;   my  $OriginHigh; my $OriginLow;  my $SiteCode; my @SpecsPerList =(); 
	my $pr_dstb, my $DistCode; my $ModYr; #my $upfCode;
	my $ownlyr; my $delta1; my $dstb;


	my $SMR;my $StandStructureCode1;my $StandStructureCode2;my $StandStructureCode3;
	my $StandStructureCode4;my $StandStructureCode5;my $StandStructureVal; 
	my $CCHigh1;my $CCHigh2;my $CCHigh3;my $CCHigh4;my $CCHigh5;my $CCLow1;my $CCLow2;my $CCLow3;my $CCLow4;
	my $CCLow5;my $HeightHigh1;my $HeightHigh2;my $HeightHigh3;my $HeightHigh4;my $HeightHigh5;my $HeightLow1;
	my $HeightLow2;my $HeightLow3;my $HeightLow4;my $HeightLow5;
	my $SpeciesComp1; my $SpeciesComp2; my $SpeciesComp3;my $SpeciesComp4;my $SpeciesComp5;
	my $OriginHigh1;my $OriginHigh2;my $OriginHigh3;my $OriginHigh4;my $OriginHigh5;
	my $OriginLow1;my $OriginLow2;my $OriginLow3;my $OriginLow4;my $OriginLow5; 
	my $StrucVal;my $SiteClass; my $SiteIndex;my $UnprodFor;
	my $Wetland;  my $NumberLyr; 
	my $NatNonVeg1;my $NatNonVeg2;my $NatNonVeg3;my $NatNonVeg4;my $NatNonVeg5;
	my $NonForVeg; my $NonForVeg1;my $NonForVeg2;my $NonForVeg3;my $NonForVeg4;my $NonForVeg5;
 	my $NonForAnth;my $NonForAnth1;my $NonForAnth2;my $NonForAnth3;my $NonForAnth4;my $NonForAnth5;
	my $Dist1;my $Dist2; my $Dist;
	my $Dist1ExtHigh;my $Dist2ExtHigh; my $Dist1ExtLow;my $Dist2ExtLow; 
	my $LayerRank1="";my $LayerRank2="";my $LayerRank3="";my $LayerRank4="";my $LayerRank5="";
	my $pr1; my  $pr2; my $pr3; my $pr4;  my $pr5;

	my %herror=();
	my $keys;

	my $LandMod;
	my $YEARORG;
	my $CAS_Record; my $Lyr_Record41; my $LYR_Record11; my $LYR_Record21; my $LYR_Record31;
	my $Lyr_Record42; my $LYR_Record12; my $LYR_Record22; my $LYR_Record32;
	my $Lyr_Record43; my $LYR_Record13; my $LYR_Record23; my $LYR_Record33;
	my $Lyr_Record44; my $LYR_Record14; my $LYR_Record24; my $LYR_Record34;
	my $Lyr_Record45; my $LYR_Record15; my $LYR_Record25; my $LYR_Record35;
	my $NFL_Record; my $NFL_Record1; my $NFL_Record11; my $NFL_Record12; my $NFL_Record13;
	my $NFL_Record2; my $NFL_Record21;my $NFL_Record22;my $NFL_Record23; 
	my $NFL_Record3; my $NFL_Record31; my $NFL_Record32; my $NFL_Record33; 
	my $NFL_Record4; my $NFL_Record14; my $NFL_Record24; my $NFL_Record34; 
	my $NFL_Record5; my $NFL_Record15; my $NFL_Record25; my $NFL_Record35; 
	my $DST_Record; 
	my $CCHigh1_SC;my $CCHigh2_SC;my $CCHigh3_SC;my $CCHigh4_SC;my $CCHigh5_SC;
	my $CCLow1_SC;my $CCLow2_SC;my $CCLow3_SC;my $CCLow4_SC;my $CCLow5_SC;

	my $CCHigh1_SO;my $CCHigh2_SO;my $CCHigh3_SO;my $CCHigh4_SO;my $CCHigh5_SO;
	my $CCLow1_SO;my $CCLow2_SO;my $CCLow3_SO;my $CCLow4_SO;my $CCLow5_SO;

	my $NnfAnth1;my $NnfAnth2;my $NnfAnth3;my $NnfAnth4;my $NnfAnth5;
	my $CAS_ID;
	my $PolyNum;
	my $IdentifyID;
	my $MapsheetID;
	my $Area;
	my $Perimeter; my $Spcomp1;
	my $PHOTO_YEAR;  
	my $layer_rank1; my $layer_rank2; my $layer_rank3; my $layer_rank4; my $layer_rank5;
	my $Nondropped; my $problem;
	my %UPFsplist=(
	"700" => "Pice mari", 
	"701" => "Pice mari",   
	"702" => "Lari lari",
    "703" => "Thuj occi",  
    "704 " => "Pice mari", 
	"711" => "Pinu bank", 
	"712" => "Pice mari", 
	"713" => "Hard unkn"
	);

    my @SpecsPerList1=(); my $cpt_ind;
    my @SpecsPerList2=(); my @SpecsPerList3=(); my @SpecsPerList4=(); my @SpecsPerList5=(); my @SpecsPerList6=(); my @SpecsPerList7=();
    my $csv = Text::CSV_XS->new(
    {
    	binary          => 1,
 		sep_char        => ';',
  		allow_whitespace      => 1, 
  	});
    open my $MBinv, "<", $MB_File or die " \n Error: Could not open Manitoba_LP input file $MB_File: $!";
    $csv->column_names ($csv->getline ($MBinv));

    while (my $row = $csv->getline_hr ($MBinv)) 
    {	
    	#print "CAS_ID is $row->{CAS_ID}  and AREA is $row->{OBJECTID_1} \n"; exit(0);
          

		$Glob_CASID   =  $row->{CAS_ID};
		$CAS_ID=$row->{CAS_ID};
		($pr1,$pr2,$pr3, $pr4, $pr5)     =  split("-", $row->{CAS_ID} );   	    
		$MapsheetID   =  $pr3; 
		$MapsheetID =~ s/x+//;
		$PolyNum =$pr4;  
		$PolyNum =~ s/^0+//;
		if(defined $row->{HEADER_ID})
		{
			$IdentifyID= $row->{HEADER_ID};
		} 
		else 
		{ 
			print "HEADER_ID MISSING for $CAS_ID\n"; exit;
		} #print "header is $CAS_ID, $PolyNum , $IdentifyID\n "; exit;
	

		$Area=$row->{GIS_AREA}; #Steve has changed SHAPE_AREA and SHAPE_PERI for GIS_AREA and GIS_PERI
		$Perimeter=$row->{GIS_PERI}; # old mb field  $Perimeter=$row->{SHAPE_PERI};
		
		$PHOTO_YEAR =  convert_to_int($row->{YEARPHOTO});
		if ($PHOTO_YEAR eq "0") {$PHOTO_YEAR = MISSCODE;}

		$standard_name=$row->{FRI_FLI};

		if(defined $standard_name){} else {$standard_name="FLI";}

		if(defined $IdentifyID){} else {print "cas nb $CAS_ID  header undef $IdentifyID \n"; exit;}
		# $CAS_Record = $CAS_ID . "," . $PolyNum  . "," . $StandStructureCode1 .",". $NumberLyr .",". $IdentifyID . "," . $MapsheetID. "," . $Area . "," . $Perimeter.",".$Area.",".$PHOTO_YEAR;
		# print CASCAS $CAS_Record . "\n";
	 #  	$nbpr=1;$$ncas++;$ncasprev++;

		if (defined $row->{LANDMOD})
		{
			$LandMod=$row->{LANDMOD};
		} 
		else
		{
			$LandMod="";
		} 
		$Spcomp1= $row->{SPECIES};
		$Covertype     =  $row->{COVERTYPE}; #3 digits and $Spcomp  eq ""
		#Moisture
		$SMR =  SoilMoistureRegime($standard_name, $row->{MOIST}, $row->{MR});
		if($SMR eq ERRCODE) 
		{ 
			$keys="MoistReg"."#version is ".$standard_name."#MOIST=".$row->{MOIST}."#MR =".$row->{MR};
			$herror{$keys}++;	
		}

	  	#Stand structure
		$StandStructureVal     =  UNDEF; 
		$Nondropped=0;$problem="";

		my $prodFor5; my $lyr_poly5; my $prodFor4; my $lyr_poly4; my $prodFor3; my $lyr_poly3; my $prodFor2; my $lyr_poly2; my $prodFor1; my $lyr_poly1; my $prodFor; my $lyr_poly;

		#################################################################
		################################################################
		#########################  FRI ###########################

		if($standard_name eq "FRI")
		{
			$StandStructureCode1   = "S"; 
			$CrownClosure=$row->{CROWNCL};

	        $CCHigh    =  CCUpper_FRI($CrownClosure);
	        $CCLow     =  CCLower_FRI($CrownClosure);            
		  	if($CCHigh  eq ERRCODE   || $CCLow  eq ERRCODE) 
		  	{ 
				$keys="CrownClosure"."#".$CrownClosure;
				$herror{$keys}++;
			}	  

	        $HeightHigh   = StandHeight_FRI($row->{HEIGHT});
	        $HeightLow    = StandHeight_FRI($row->{HEIGHT});

	        $YEARORG=$OriginHigh   = convert_to_int($row->{YEAR_ORG}); # UpperOrigin($Origin);
	        $OriginLow    = convert_to_int($row->{YEAR_ORG}); # LowerOrigin($Origin);
		  	$OriginHigh =~ s/,([0-9]+)$//g;
		  	$OriginLow =~ s/,([0-9]+)$//g;
			$YEARORG =~ s/,([0-9]+)$//g;

		  	if($OriginHigh ==0){$OriginHigh=MISSCODE;}
		  	if($OriginLow ==0){$OriginLow=MISSCODE;}
	 	  	$Origin =$OriginHigh ;

			$dstb=0;
		  	if($Origin ne "0" &&  !isempty($Origin) &&  !isempty($PHOTO_YEAR)) 
		  	{

				if($Origin>0 && $Origin >$PHOTO_YEAR)
				{
					$dstb=1;
					$keys="FRI---Origin greater than PY#"; #to be removed
					$herror{$keys}++; #to be removed
		  		}
				# elsif($Origin>0 && $Origin <=$PHOTO_YEAR) 
				# {	
				# 	$keys="FRIOrigin correct#"; #to be removed
				# 	$herror{$keys}++; #to be removed
		  		# }
			}
		  	if(!isempty($YEARORG) && !isempty($PHOTO_YEAR))
		  	{
				if($YEARORG > $PHOTO_YEAR && $YEARORG > 0)
				{
					if(length $Covertype ==5)
					{
						$delta1=substr $Covertype, 0,1;
					}
					else 
					{
						$delta1=0;
					}
					if($delta1 eq "O"){$delta1=0;} #there is an error in MU_53.csv, a covertype = O4200 instead of 04200

		 			$Origin = CorrectDistYear($YEARORG, $delta1);
					$Origin =~ s/\.([0-9]+)$//g;
					$OriginHigh=$Origin;
					$OriginLow=$Origin;
		 		}
		 	}

			if(!isempty($PHOTO_YEAR))
			{
	 	  		if( $Origin >0 &&  $Origin>$PHOTO_YEAR)
	 	  		{
					#$keys="Origin STILL greater than PY#".$Origin."#original#".$YEARORG."#photoyear#".$PHOTO_YEAR."#covertype#".$Covertype;
					#$herror{$keys}++;
					$keys="CONCL---Origin STILL greater than PY#";
					$herror{$keys}++;
		  		}
			}
		  	if( ($OriginHigh >0 && $OriginHigh <1600) || $OriginHigh>2014 )
		  	{
				$keys="BOUNDS Origin#".$Origin."#original#".$YEARORG."#yearphoto#".$PHOTO_YEAR;
				$herror{$keys}++;
				$OriginHigh=ERRCODE;
				$OriginLow=ERRCODE;
		  	}

		 	my $Spcomp=$row->{SP_1}."#".$row->{SP_1PER}."#".$row->{SP_2}."#".$row->{SP_2PER}."#".$row->{SP_3}."#".$row->{SP_3PER}."#".$row->{SP_4}."#".$row->{SP_4PER}."#".$row->{SP_5}."#".$row->{SP_5PER}."#".$row->{SP_6}."#".$row->{SP_6PER}."#".$row->{SP_7}."#".$row->{SP_7PER};

		  	$SpeciesComp  =  Species_FRI($row->{SP_1}, $row->{SP_1PER}, $row->{SP_2}, $row->{SP_2PER}, $row->{SP_3}, $row->{SP_3PER}, $row->{SP_4}, $row->{SP_4PER}, $row->{SP_5}, $row->{SP_5PER}, $row->{SP_6}, $row->{SP_6PER}, $row->{SP_7}, $row->{SP_7PER},$spfreq);

		 	@SpecsPerList = split(",", $SpeciesComp);  
			for($cpt_ind=0; $cpt_ind<=6; $cpt_ind++)
			{  
				my $posi=$cpt_ind*2;
	        	if($SpecsPerList[$posi] eq SPECIES_ERRCODE) 
				{ 
					$keys="Species position#".$cpt_ind."#sp1#".$row->{SP_1}."#sp2#".$row->{SP_2}."#sp3#".$row->{SP_3}."#sp4#".$row->{SP_4}."#sp5#".$row->{SP_5}."#sp6#".$row->{SP_6}."#sp7#".$row->{SP_7};
	              	$herror{$keys}++; 
				}
	   		}
			my $total=$SpecsPerList[1] + $SpecsPerList[3]+ $SpecsPerList[5] +$SpecsPerList[7]+$SpecsPerList[9]+$SpecsPerList[11]+$SpecsPerList[13];
		
			if($total != 100 && $total != 0 )
			{
				$keys="total perct !=100 "."#$total#".$SpeciesComp."#original#".$row->{SP_1}.",".$row->{SP_2}.",".$row->{SP_3}.",".$row->{SP_4}.",".$row->{SP_5}.",".$row->{SP_6}.",".$row->{SP_7};
				$herror{$keys}++; 
			}
		  		
			$SpeciesComp  =  $SpeciesComp .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";	
			
		  	$StrucVal     =  UNDEF;#"";
		 	# if($LCT-3 >0) { $SiteCode=   (substr $Covertype, $LCT-3, 1); }
			# else {$SiteCode=""; }

		  	$SiteCode=$row->{SITE};

			##juin 2014 revoir la formule pour SiteClass - pour FLI, SiteClass = UNDEF, pour GOV, on utilise Species et covertype, mais pour FRI_FLI, semble différent car on a species ="", sitecode=1,2,3/ species non null avec sitecode=0

		  	if(!isempty($Spcomp1)) { $SiteClass 	=  Site_FRI($SiteCode);} 
		  	else { $SiteClass 	=  UNDEF;}
		  	$SiteIndex 	=  UNDEF;# "";
		  	if( $SiteClass  eq ERRCODE)
		  	 { 
				$keys="SiteClass"."#". $SiteCode;
				#$herror{$keys}++;
			}
	 		
			if($SMR eq "W")
			{
		  		$Wetland = "W,-,-,-,";
			}
			else 
			{
		  		$Wetland =UNDEF;
			}

		  	# ===== Non-forested Land =====NonForestedAnth UnProdForest NonForestedVeg NaturallyNonVeg  NonVegWater
			$NonProdFor=MISSCODE;
	 		$ownlyr=0;
			#if($Spcomp1 eq ""  &&  $Covertype =~ /^99[789][0-9][0-9]/) {

			if($row->{COVER_TYPE} ne "H" && $row->{COVER_TYPE} ne "M" && $row->{COVER_TYPE} ne "N" && $row->{COVER_TYPE} ne "S")
			{
				#if( $Covertype =~ /^99[789][0-9][0-9]/) {  #old version for MBGOV
		 		#$NnForVegCode=substr $Covertype, 2,3;
				#$NnForVegCode	=  $NnForVeg;
				#print "pass\n";
				if (!isempty($row->{COVER_TYPE}) && isempty($row->{PRODUCTIVITY}) && isempty($row->{COVERTYPE})) 
				{
					$Nondropped=1; 
					$problem="onlyNONFOR";
				}  #new 2014
				$NnForVegCode = $row->{PRODUCTIVITY};

		 		$NonVegAnth	=  NonForestedAnth_FRI($NnForVegCode);
				$NonProdFor	=  UnProdForest_FRI($NnForVegCode);
		  		$NonFor 	=  NonForestedVeg_FRI($NnForVegCode);
		 		$NatNonVeg 	=  NaturallyNonVeg_FRI($NnForVegCode);
				$NonVegWat	=  NonVegWater_FRI($NnForVegCode);

				if(is_missing($NatNonVeg))
				{
					$NatNonVeg = $NonVegWat;
				}
		 		 
				if($NatNonVeg eq ERRCODE){$NatNonVeg=$NonVegWat;}
				if(($NonVegAnth  eq ERRCODE) && ($NonProdFor  eq ERRCODE) && ($NonFor  eq ERRCODE) &&  ($NatNonVeg  eq ERRCODE) ) 
				{ 
					$keys="NonForVeg-NatNonVeg-NonForAnth"."#".$NnForVegCode;  
					$herror{$keys}++; 
					$NonProdFor=$NonFor=$NatNonVeg=MISSCODE;
		  		}
				else 
				{
					$ownlyr=1;
					# $keys="TOOK NonForVeg-NatNonVeg-NonForAnth on"."#".$NnForVegCode;  
					# $herror{$keys}++; 
				}
			}	
			else 
			{
				#if(isempty($Spcomp1)  &&  isempty($Covertype) && !isempty($row->{LAND_TYPE})) {$Nondropped=1;$problem="emptySPECIES";}
				if(isempty($Spcomp1) && !isempty($row->{LAND_TYPE})) 
				{
					$Nondropped=2;$problem="emptySPECIES";
					$SpeciesComp  = Latine_FRI($row->{LAND_TYPE}).",100,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";	
				}
				else 
				{
					$NnForVegCode=""; 
					$NonProdFor=$NonVegAnth=$NonFor=$NatNonVeg=MISSCODE; 
				}
			}

			$Dist1=MISSCODE;
			$pr_dstb=0;
			if(isempty($Spcomp1)  &&  !isempty($Covertype) && $Covertype !~ /^99/) 
			{
				#print "-----------------verif 1, $CAS_ID\n";
		 		$DistCode=substr $Covertype, 2,3;
		 		$pr_dstb=1;
		 		if($DistCode eq "100")
		 		{
					$Dist1="CU";
		 		}
		 		elsif($DistCode eq "200")
		 		{
					$Dist1="BU";
		 		}
				else 
				{
					$Dist1="UK";
				}
			}   

			if( $Covertype eq "99100" || $Covertype eq "99200") 
			{
				#print "verif 2\n";
				#exit;
		 		$DistCode=substr $Covertype, 2,3;
		 		$pr_dstb=1;
		 		if($DistCode eq "100")
		 		{
					$Dist1="CU";
		 		}
		 		elsif($DistCode eq "200")
		 		{
					$Dist1="BU";
		 		}
			}         	
			
			if($NonProdFor ne MISSCODE && $NonProdFor ne ERRCODE && !isempty($Spcomp1) )
			{
				$keys ="GOOD nonprodfro#".$NonProdFor."#speciescomp#".$Spcomp1;
	 			$herror{$keys}++; 
			}
	 		($prodFor, $lyr_poly) = productive_code ($row->{SP_1}, $CCHigh , $CCLow , $HeightHigh , $HeightLow, $CrownClosure);
		 	if($lyr_poly)
			{
				if($Nondropped!=2)
				{
					$SpeciesComp ="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
				}
				$keys="###check artificial lyr on #".$row->{SP_1}."#";
				$herror{$keys}++; 
				if(!is_missing($NonProdFor))
				{
					if($NonProdFor ne "NP")
					{
						$prodFor = $NonProdFor; 
						# $keys="set nonprodfor to #".$NonProdFor."#";
						# $herror{$keys}++;
					}
				}
			}
			$NumberLyr = 1;
			#end of if statement for FRI polygones
		}
		#################################################################
		################################################################
		#########################  FLI VERSION ###########################
		elsif($standard_name eq "FLI")
		{
			#fields for FLI standard
			#Stand structure
	        $StandStructureCode1   =  StandStructure( $row->{CANLAY});
		 	if($StandStructureCode1 eq ERRCODE) 
		 	{ 
				$keys="Struc1"."#". $row->{CANLAY};
				$herror{$keys}++;	
			}

	        $StandStructureCode2   =  StandStructure( $row->{US2CANLAY});
	 	  	if($StandStructureCode2 eq ERRCODE) 
	 	  	{ 
				$keys="Struc2"."#". $row->{US2CANLAY};
				$herror{$keys}++;	
			}

	        $StandStructureCode3   =  StandStructure( $row->{US3CANLAY});
	        if($StandStructureCode3 eq ERRCODE) 
	        { 
				$keys="Struc3"."#". $row->{US3CANLAY};
				$herror{$keys}++;	
			}

		  	$StandStructureCode4   =  StandStructure( $row->{uUS4CANLAY});
	 	  	if($StandStructureCode4 eq ERRCODE)
	 	  	{ 
				$keys="Struc4"."#". $row->{US4CANLAY};
				$herror{$keys}++;	
			}

	        $StandStructureCode5   =  StandStructure( $row->{US5CANLAY});
	 	  	if($StandStructureCode5 eq ERRCODE) 
	 	  	{ 
				$keys="Struc5"."#". $row->{US5CANLAY};
				$herror{$keys}++;	
			}

	        $StandStructureVal     =  UNDEF;  
			#layers and rank
			#print "here is the casid  $CAS_ID,$PHOTO_YEAR, <<<$row->{CC}>>>, <<<$row->{CANLAY}>>>, $Area,$Perimeter,<<$row->{FID_MB_FRI}>>,<<$row->{FRI_FLI}>>,<<$row->{MU_ID}>>,\n\n\n"; exit;

		  	$CCHigh1       =  CCUpper($row->{CC}, $row->{CANLAY}); 
	    	$CCHigh2       =  CCUpper($row->{US2CC}, $row->{US2CANLAY}); 
	        $CCHigh3       =  CCUpper($row->{US3CC}, $row->{US3CANLAY}); 
	        $CCHigh4       =  CCUpper($row->{US4CC}, $row->{US4CANLAY}); 
	        $CCHigh5       =  CCUpper($row->{US5CC}, $row->{US5CANLAY}); 
	        $CCLow1        =  CCLower($row->{CC}, $row->{CANLAY}); 
	        $CCLow2        =  CCLower($row->{US2CC}, $row->{US2CANLAY}); 
	        $CCLow3        =  CCLower($row->{US3CC}, $row->{US3CANLAY}); 
	        $CCLow4        =  CCLower($row->{US4CC}, $row->{US4CANLAY}); 
	        $CCLow5        =  CCLower($row->{US5CC}, $row->{US5CANLAY}); 

	 	  	if($CCHigh1  eq ERRCODE   || $CCLow1  eq ERRCODE || $CCHigh2  eq ERRCODE   || $CCLow2  eq ERRCODE || $CCHigh3  eq ERRCODE   || $CCLow3  eq ERRCODE || $CCHigh4  eq ERRCODE   || $CCLow4  eq ERRCODE || $CCHigh5  eq ERRCODE   || $CCLow5  eq ERRCODE) 
	 	  	{ 
	 	  		$keys="CrownClosure1-5"."#".$row->{CC};
				$herror{$keys}++;
			}

	        # $HeightHigh

			if(!defined $row->{US5HT}){$row->{US5HT}="";}
		  	$HeightHigh1   =  StandHeight($row->{HT} , $row->{COMHT}, $row->{CANLAY}, 1); 
		  	$HeightHigh2   =  StandHeight($row->{US2HT}, $row->{COMHT}, $row->{US2CANLAY}, 1);
	        $HeightHigh3   =  StandHeight($row->{US3HT}, $row->{COMHT}, $row->{US3CANLAY}, 1);
	        $HeightHigh4   =  StandHeight($row->{US4HT}, $row->{COMHT}, $row->{US4CANLAY}, 1);
	        $HeightHigh5   =  StandHeight($row->{US5HT}, $row->{COMHT}, $row->{US5CANLAY}, 1);
	        $HeightLow1    =  StandHeight($row->{HT} , $row->{COMHT}, $row->{CANLAY}, -1);
	        $HeightLow2    =  StandHeight($row->{US2HT}, $row->{COMHT}, $row->{US2CANLAY}, -1);
	        $HeightLow3    =  StandHeight($row->{US3HT}, $row->{COMHT}, $row->{US3CANLAY}, -1);
	        $HeightLow4    =  StandHeight($row->{US4HT}, $row->{COMHT}, $row->{US4CANLAY}, -1);
	        $HeightLow5    =  StandHeight($row->{US5HT}, $row->{COMHT}, $row->{US5CANLAY}, -1);

		  	if( ($HeightHigh1 eq MISSCODE || $HeightLow1 eq MISSCODE) && !isempty($row->{HT}) && $row->{HT} ne "0") 
		  	{
				$keys="Heigh1#".$row->{HT}."#comt#".$row->{COMHT}."#canlay#".$row->{CANLAY};
				$herror{$keys}++;
			}
			if( ($HeightHigh2 eq MISSCODE || $HeightLow2 eq MISSCODE) && !isempty($row->{US2HT}) && $row->{US2HT} ne "0") 
			{
				$keys="Heigh2#".$row->{US2HT}."#comt#".$row->{COMHT}."#canlay#".$row->{US2CANLAY};
				$herror{$keys}++;
			}
			if( ($HeightHigh3 eq MISSCODE || $HeightLow3 eq MISSCODE) && !isempty($row->{US3HT}) && $row->{US3HT} ne "0") 
			{
				$keys="Heigh3#".$row->{US3HT}."#comt#".$row->{COMHT}."#canlay#".$row->{US3CANLAY};
				$herror{$keys}++;
			}
			if( ($HeightHigh4 eq MISSCODE || $HeightLow4 eq MISSCODE) && !isempty($row->{US4HT}) && $row->{US4HT} ne "0") 
			{
				$keys="Heigh4#".$row->{US4HT}."#comt#".$row->{COMHT}."#canlay#".$row->{US4CANLAY};
				$herror{$keys}++;
			}
			if( ($HeightHigh5 eq MISSCODE || $HeightLow5 eq MISSCODE) && !isempty($row->{US5HT}) && $row->{US5HT} ne "0") 
			{
				$keys="Heigh5#".$row->{US5HT}."#comt#".$row->{COMHT}."#canlay#".$row->{US5CANLAY};
				$herror{$keys}++;
			}

	        #in case of SC7 type  CC FOR NEW CROWN CLOSURE
	        $CCHigh1_SC       =  CCUpper_SC($row->{NNF_ANTH});
	        $CCHigh2_SC       =  CCUpper_SC($row->{US2NNF_ANT});
	        $CCHigh3_SC       =  CCUpper_SC($row->{US3NNF_ANT});
	        $CCHigh4_SC       =  CCUpper_SC($row->{US4NNF_ANT});
	        $CCHigh5_SC       =  CCUpper_SC($row->{US5NNF_ANT});
	        $CCLow1_SC        =  CCLower_SC($row->{NNF_ANTH});
	        $CCLow2_SC        =  CCLower_SC($row->{US2NNF_ANT});
	        $CCLow3_SC        =  CCLower_SC($row->{US3NNF_ANT});
	        $CCLow4_SC        =  CCLower_SC($row->{US4NNF_ANT});
	        $CCLow5_SC        =  CCLower_SC($row->{US5NNF_ANT});

		 	#in case of SO7 type
	        $CCHigh1_SO       =  CCUpper_SO($row->{NNF_ANTH}); 
	        $CCLow1_SO        =  CCLower_SO($row->{NNF_ANTH});
	 	  	$CCHigh2_SO       =  CCUpper_SO($row->{US2NNF_ANT}); 
	        $CCLow2_SO        =  CCLower_SO($row->{US2NNF_ANT});
	 	  	$CCHigh3_SO       =  CCUpper_SO($row->{US3NNF_ANT}); 
	        $CCLow3_SO        =  CCLower_SO($row->{US3NNF_ANT});
	 	  	$CCHigh4_SO       =  CCUpper_SO($row->{US4NNF_ANT}); 
	        $CCLow4_SO        =  CCLower_SO($row->{US4NNF_ANT});
	 	  	$CCHigh5_SO       =  CCUpper_SO($row->{US5NNF_ANT}); 
	        $CCLow5_SO        =  CCLower_SO($row->{US5NNF_ANT});
	          
			#Species composition
			#print "here is the casid  $CAS_ID,$PHOTO_YEAR, <<<$row->{CC}>>>, <<<$row->{CANLAY}>>>, $Area,$Perimeter,<<$row->{FID_MB_FRI}>>,<<$row->{FRI_FLI}>>,<<$row->{MU_ID}>>,\n\n\n"; exit;
			my $Spcomp=$row->{SP1}."#".$row->{SP1PER}."#".$row->{SP2}."#".$row->{SP2PER}."#".$row->{SP3}."#".$row->{SP3PER}."#".$row->{SP4}."#".$row->{SP4PER}."#".$row->{SP5}."#".$row->{SP5PER}."#".$row->{SP6}."#".$row->{SP6PER};

		  	$SpeciesComp1  =  Species($row->{SP1}, $row->{SP1PER}, $row->{SP2}, $row->{SP2PER}, $row->{SP3}, $row->{SP3PER}, $row->{SP4}, $row->{SP4PER}, $row->{SP5}, $row->{SP5PER}, $row->{SP6}, $row->{SP6PER},$spfreq);

		 	@SpecsPerList1 = split(",", $SpeciesComp1);  
			for($cpt_ind=0; $cpt_ind<=5; $cpt_ind++)
			{  
				my $posi=$cpt_ind*2;
	        	if($SpecsPerList1[$posi] eq SPECIES_ERRCODE) 
				{ 
					$keys="Species layer1 position#".$cpt_ind."#sp1#".$row->{SP1}."#sp2#".$row->{SP2}."#sp3#".$row->{SP3}."#sp4#".$row->{SP4}."#sp5#".$row->{SP5}."#sp6#".$row->{SP6};
	              	$herror{$keys}++; 
				}
	   		}
			my $total1=$SpecsPerList1[1] + $SpecsPerList1[3]+ $SpecsPerList1[5] +$SpecsPerList1[7]+$SpecsPerList1[9]+$SpecsPerList1[11];
		
			if($total1 != 100 && $total1 != 0 )
			{
				$keys="total perct !=100 "."#$total1#".$SpeciesComp1."#original#".$row->{SP1}.",".$row->{SP2}.",".$row->{SP3}.",".$row->{SP4}.",".$row->{SP5}.",".$row->{SP6};
				$herror{$keys}++; 
			}
	 	  	$SpeciesComp1  =  $SpeciesComp1 .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";		

	        $SpeciesComp2  =  Species($row->{US2SP1}, $row->{US2SP1PER}, $row->{US2SP2}, $row->{US2SP2PER}, $row->{US2SP3}, $row->{US2SP3PER}, $row->{US2SP4}, $row->{US2SP4PER}, $row->{US2SP5}, $row->{US2SP5PER}, $row->{US2SP6}, $row->{US2SP6PER},$spfreq);

			@SpecsPerList2 = split(",", $SpeciesComp2);  
			for($cpt_ind=0; $cpt_ind<=5; $cpt_ind++)
			{  
				my $posi=$cpt_ind*2;
	        	if($SpecsPerList2[$posi]  eq SPECIES_ERRCODE ) 
				{ 
					$keys="Species layer 2#".$cpt_ind."#sp1#".$row->{US2SP1}."#sp2#".$row->{US2SP2}."#sp3#".$row->{US2SP3}."#sp4#".$row->{US2SP4}."#sp5#".$row->{US2SP5}."#sp6#".$row->{US2SP6};
	              	$herror{$keys}++; 
				}
	   		}
			my $total2=$SpecsPerList2[1] + $SpecsPerList2[3]+ $SpecsPerList2[5] +$SpecsPerList2[7]+$SpecsPerList2[9]+$SpecsPerList2[11];
		
			if($total2 != 100 && $total2 != 0 )
			{
				$keys="total perct !=100 "."#$total2#".$SpeciesComp2."#original#".$row->{US2SP1}.",".$row->{US2SP2}.",".$row->{US2SP3}.",".$row->{US2SP4}.$row->{US2SP5}.",".$row->{US2SP6};
				$herror{$keys}++; 
			}

		  	$SpeciesComp2  =  $SpeciesComp2 .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";	
	        $SpeciesComp3  =  Species($row->{US3SP1}, $row->{US3SP1PER}, $row->{US3SP2}, $row->{US3SP2PER}, $row->{US3SP3}, $row->{US3SP3PER}, $row->{US3SP4}, $row->{US3SP4PER}, $row->{US3SP5}, $row->{US3SP5PER}, $row->{US3SP6}, $row->{US3SP6PER},$spfreq);
		  
			@SpecsPerList3 = split(",", $SpeciesComp3);  
			for($cpt_ind=0; $cpt_ind<=5; $cpt_ind++)
			{  
				my $posi=$cpt_ind*2;
	        	if($SpecsPerList3[$posi]  eq SPECIES_ERRCODE ) 
				{ 
					$keys="Species layer 3#".$cpt_ind."#sp1#".$row->{US3SP1}."#sp2#".$row->{US3SP2}."#sp3#".$row->{US3SP2}."#sp4#".$row->{US3SP4}."#sp5#".$row->{US3SP5}."#sp6#".$row->{US3SP6};
	              	$herror{$keys}++; 
				}
	   		}
			my $total3=$SpecsPerList3[1] + $SpecsPerList3[3]+ $SpecsPerList3[5] +$SpecsPerList3[7]+$SpecsPerList3[9]+$SpecsPerList3[11];
		
			if($total3 != 100 && $total3 != 0 )
			{
				$keys="total perct !=100 "."#$total3#".$SpeciesComp3."#original#".$row->{US3SP1}.",".$row->{US3SP2}.",".$row->{US3SP3}.",".$row->{US3SP4}.$row->{US3SP5}.",".$row->{US3SP6};
				$herror{$keys}++; 
			}
			$SpeciesComp3  =  $SpeciesComp3 .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";		
	        $SpeciesComp4  =  Species($row->{US4SP1}, $row->{US4SP1PER}, $row->{US4SP2}, $row->{US4SP2PER}, $row->{US4SP3}, $row->{US4SP3PER}, $row->{US4SP4}, $row->{US4SP4PER}, $row->{US4SP5}, $row->{US4SP5PER}, $row->{US4SP6}, $row->{US4SP6PER},$spfreq);
		    @SpecsPerList4 = split(",", $SpeciesComp4);  
			for($cpt_ind=0; $cpt_ind<=5; $cpt_ind++)
			{  
				my $posi=$cpt_ind*2;
	        	if($SpecsPerList4[$posi]  eq SPECIES_ERRCODE ) 
				{ 
					$keys="Species layer 4#".$cpt_ind."#sp1#".$row->{US4SP1}."#sp2#".$row->{US4SP2}."#sp3#".$row->{US4SP3}."#sp4#".$row->{US4SP4}."#sp5#".$row->{US4SP5}."#sp6#".$row->{US4SP6};
	              	$herror{$keys}++; 
				}
	   		}
			my $total4=$SpecsPerList4[1] + $SpecsPerList4[3]+ $SpecsPerList4[5] +$SpecsPerList4[7]+$SpecsPerList4[9]+$SpecsPerList4[11];
		
			if($total4 != 100 && $total4 != 0 ){
				$keys="total perct !=100 "."#$total4#".$SpeciesComp4."#original#".$row->{US4SP1}.",".$row->{US4SP2}.",".$row->{US4SP3}.",".$row->{US4SP4}.$row->{US4SP5}.",".$row->{US4SP6};
				$herror{$keys}++; 
			}
			$SpeciesComp4  =  $SpeciesComp4 .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";	

			#if($hdr_num eq "0002"){
	        $SpeciesComp5  =  Species($row->{US5SP1}, $row->{US5SP1PER}, $row->{US5SP2}, $row->{US5SP2PER}, $row->{US5SP3}, $row->{US5SP3PER}, $row->{US5SP4}, $row->{US5SP4PER}, $row->{US5SP5}, $row->{US5SP5PER}, $row->{US5SP6}, $row->{US5SP6PER},$spfreq);
		  	@SpecsPerList5 = split(",", $SpeciesComp5);  
			for($cpt_ind=0; $cpt_ind<=5; $cpt_ind++)
			{  
				my $posi=$cpt_ind*2;
	        	if($SpecsPerList5[$posi]  eq SPECIES_ERRCODE  ) 
				{ 
					$keys="Species layer 5#".$cpt_ind."#sp1#".$row->{US5SP1}."#sp2#".$row->{US5SP2}."#sp3#".$row->{US5SP3}."#sp4#".$row->{US5SP4}."#sp5#".$row->{US5SP5}."#sp6#".$row->{US5SP6};
	              	$herror{$keys}++; 
				}
	   		}
			my $total5=$SpecsPerList5[1] + $SpecsPerList5[3]+ $SpecsPerList5[5] +$SpecsPerList5[7]+$SpecsPerList5[9]+$SpecsPerList5[11];
		
			if($total5 != 100 && $total5 != 0 )
			{
				$keys="total perct !=100 "."#$total5#".$SpeciesComp5."#original#".$row->{US5SP1}.",".$row->{US5SP2}.",".$row->{US5SP3}.",".$row->{US5SP4}.$row->{US5SP5}.",".$row->{US5SP6};
				$herror{$keys}++; 
			}

			$SpeciesComp5  =  $SpeciesComp5 .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";	

			#}  end loop for if ($hdr_num eq "0002")

		  	if(!defined $row->{US5ORIGIN}) {$row->{US5ORIGIN}="";}
	          
		  	$OriginHigh1   =  UpperLowerOrigin($row->{ORIGIN});
	        $OriginHigh2   =  UpperLowerOrigin($row->{US2ORIGIN});
	        $OriginHigh3   =  UpperLowerOrigin($row->{US3ORIGIN});
	        $OriginHigh4   =  UpperLowerOrigin($row->{US4ORIGIN});
	        $OriginHigh5   =  UpperLowerOrigin($row->{US5ORIGIN});
	        $OriginLow1    =  UpperLowerOrigin($row->{ORIGIN});
	        $OriginLow2    =  UpperLowerOrigin($row->{US2ORIGIN});
	        $OriginLow3    =  UpperLowerOrigin($row->{US3ORIGIN});
	        $OriginLow4    =  UpperLowerOrigin($row->{US4ORIGIN});
	        $OriginLow5    =  UpperLowerOrigin($row->{US5ORIGIN});

			if($OriginHigh1 eq ERRCODE || $OriginLow1 eq ERRCODE) 
			{
				$keys="origin1#".$row->{ORIGIN};
				$herror{$keys}++;
			}
			if($OriginHigh2 eq ERRCODE || $OriginLow2 eq ERRCODE) 
			{
				$keys="origin2#".$row->{US2ORIGIN};
				$herror{$keys}++;
			}
		 
			if($OriginHigh3 eq ERRCODE || $OriginLow3 eq ERRCODE) 
			{
				$keys="origin3#".$row->{US3ORIGIN};
				$herror{$keys}++;
			}
		 
			if($OriginHigh4 eq ERRCODE || $OriginLow4 eq ERRCODE) 
			{
				$keys="origin4#".$row->{US4ORIGIN};
				$herror{$keys}++;
			}
		 
			if($OriginHigh5 eq ERRCODE || $OriginLow5 eq ERRCODE) 
			{
				$keys="origin5#".$row->{US5ORIGIN};
				$herror{$keys}++;
			}

		 	if(($OriginHigh1>0 && $OriginHigh1 <1600) || $OriginHigh1 >2014) 
		 	{
				$keys="BOUNDS origin1#".$row->{ORIGIN};
				$herror{$keys}++;
				$OriginHigh1 = ERRCODE;
			}
			if(($OriginHigh2>0 && $OriginHigh2 <1600) || $OriginHigh2 >2014) 
			{
				$keys=" BOUNDS origin2#".$row->{US2ORIGIN};
				$herror{$keys}++;
				$OriginHigh2 = ERRCODE;
			}
		 
			if(($OriginHigh3>0 && $OriginHigh3 <1600) || $OriginHigh3 >2014) 
			{
				$keys="BOUNDS origin3#".$row->{US3ORIGIN};
				$herror{$keys}++;
				$OriginHigh3 = ERRCODE;
			}
		 
			if(($OriginHigh4>0 && $OriginHigh4 <1600) || $OriginHigh4 >2014) 
			{
				$keys="BOUNDS origin4#".$row->{US4ORIGIN};
				$herror{$keys}++;
				$OriginHigh4 = ERRCODE;
			}
		 
			if(($OriginHigh5>0 && $OriginHigh5 <1600) || $OriginHigh5 >2014) 
			{
				$keys="BOUNDS origin5#".$row->{US5ORIGIN};
				$herror{$keys}++;
				$OriginHigh5 = ERRCODE;
			}
	 
			$StrucVal     =  UNDEF;#"";
			$SiteClass 	=  UNDEF;#"";
			$SiteIndex 	=  UNDEF;# "";
		    $UnprodFor 	=  UNDEF;#"";

	        #use only one layer
		  	#$Wetland = WetlandCodes ($row->{WETECO1},  $row->{WETECO2});
			######IMPORTANT !!!! in a more recent version of FLI, check for ECOSITE field to derive treed wetland

			if ($row->{CANLAY} ne "V")
			{
			    $Wetland = WetlandCodes ($row->{WETECO1},  $LandMod, $row->{MR}, $row->{SP1}, $row->{SP1PER}, $row->{SP2}, $row->{CC}, $row->{HT}, $row->{NNF_ANTH});
			}
			else 
			{
			   $Wetland = WetlandCodes ($row->{WETECO1}, $LandMod, $row->{MR}, $row->{US2SP1}, $row->{US2SP1PER}, $row->{US2SP2}, $row->{US2CC}, $row->{US2HT}, $row->{US2NNF_ANT});
			}

			if($Wetland eq ERRCODE) 
			{ 
				$keys="wetland"."#". $row->{WETECO1}."#".$LandMod;
				$herror{$keys}++;	
				$Wetland = MISSCODE;
			}

	        # compute number of layers
	        $NumberLyr	=  ComputeNumberOfLayers($row->{SP1},$row->{NNF_ANTH}, $row->{US2SP1}, $row->{US2NNF_ANT}, $row->{US3SP3}, $row->{US3NNF_ANT},$row->{US4SP4}, $row->{US4NNF_ANT}, $row->{US5SP5}, $row->{US5NNF_ANT});
			if ($NumberLyr	==0){$NumberLyr	= 1;}
		  	# ===== Non-forested Land =====
	        if(defined $row->{NNF_ANTH} && defined $row->{HT}) 
	        { 
	         	$NatNonVeg1 	=  NaturallyNonVeg($row->{NNF_ANTH});
			  	$NonForVeg1 	=  NonForestedVeg($row->{NNF_ANTH}, $row->{HT});
			  	$NonForAnth1	=  NonForestedAnth($row->{NNF_ANTH});
			  	if(($NatNonVeg1  eq ERRCODE)  &&  ($NonForVeg1  eq ERRCODE)  &&  ($NonForAnth1  eq ERRCODE))
			  	{ 
					$keys="NonForVeg1-NatNonVeg1-NonForAnth1"."#".$row->{NNF_ANTH}.":::HEIGHT=".$row->{HT};  $herror{$keys}++; 
			 	}
	        }
		  	else 
		  	{ 
		  		$NatNonVeg1=$NonForVeg1=$NonForAnth1=MISSCODE;
		  	}
		
	 	  	if(defined $row->{US2NNF_ANT} && defined $row->{US2HT})
	 	  	{ 
		 
				$NatNonVeg2 	=  NaturallyNonVeg($row->{US2NNF_ANT});
				$NonForVeg2 	=  NonForestedVeg($row->{US2NNF_ANT}, $row->{US2HT});
			  	$NonForAnth2	=  NonForestedAnth($row->{US2NNF_ANT});
			  	if(($NatNonVeg2  eq ERRCODE)  &&  ($NonForVeg2  eq ERRCODE)  &&  ($NonForAnth2  eq ERRCODE)) 
			  	{ 
					$keys="NonForVeg2-NatNonVeg2-NonForAnth2"."#".$row->{US2NNF_ANT}.":::HEIGHT=".$row->{US2HT};  $herror{$keys}++; 
			  	}
	        }
		  	else 
		  	{ 
		  		$NatNonVeg2=$NonForVeg2=$NonForAnth2=MISSCODE;
		  	}

		  	if(defined $row->{US3NNF_ANT} && defined $row->{US3HT}) 
		  	{ 

				$NatNonVeg3 	=  NaturallyNonVeg($row->{US3NNF_ANT});
			  	$NonForVeg3 	=  NonForestedVeg($row->{US3NNF_ANT}, $row->{US3HT});
			  	$NonForAnth3	=  NonForestedAnth($row->{US3NNF_ANT});
			  	if(($NatNonVeg3  eq ERRCODE)  &&  ($NonForVeg3  eq ERRCODE)  &&  ($NonForAnth3  eq ERRCODE)) 
			  	{ 
					$keys="NonForVeg3-NatNonVeg3-NonForAnth3"."#".$row->{US3NNF_ANT}.":::HEIGHT=".$row->{US3HT};  $herror{$keys}++; 
			 	}
	        }
		  	else 
		  	{ 
		  		$NatNonVeg3=$NonForVeg3=$NonForAnth3=MISSCODE;
		  	}

		  	if(defined $row->{US4NNF_ANT} && defined $row->{US4HT}) 
		  	{ 

				$NatNonVeg4 	=  NaturallyNonVeg($row->{US4NNF_ANT});
			  	$NonForVeg4 	=  NonForestedVeg($row->{US4NNF_ANT}, $row->{US4HT});
			  	$NonForAnth4	=  NonForestedAnth($row->{US4NNF_ANT});
				if(($NatNonVeg4  eq ERRCODE)  &&  ($NonForVeg4  eq ERRCODE)  &&  ($NonForAnth4  eq ERRCODE)) 
				{ 
					$keys="NonForVeg4-NatNonVeg4-NonForAnth4"."#".$row->{US4NNF_ANT}.":::HEIGHT=".$row->{US4HT};  $herror{$keys}++; 
			  	}   
		  	}
		  	else 
		  	{ 
		  		$NatNonVeg4=$NonForVeg4=$NonForAnth4=MISSCODE;
		  	}
		  
		  	if(defined $row->{US5NNF_ANT} && defined $row->{US5HT}) 
		  	{ 

				$NatNonVeg5 	=  NaturallyNonVeg($row->{US5NNF_ANT});
			 	$NonForVeg5 	=  NonForestedVeg($row->{US5NNF_ANT}, $row->{US5HT});
			  	$NonForAnth5	=  NonForestedAnth($row->{US5NNF_ANT});
			 	if(($NatNonVeg5  eq ERRCODE)  &&  ($NonForVeg5  eq ERRCODE)  &&  ($NonForAnth5  eq ERRCODE)) 
			 	{ 
					$keys="NonForVeg5-NatNonVeg5-NonForAnth5"."#".$row->{US5NNF_ANT}."#".":::HEIGHT=".$row->{US5HT};  $herror{$keys}++; 
			  	}
	        }
		  	else 
		  	{ 
		  		$NatNonVeg5=$NonForVeg5=$NonForAnth5=MISSCODE;
		  	}

			# ===== Modifiers =====
			$Dist1 = Disturbance($row->{MOD1}, $row->{ORIG1});
			$Dist2 = Disturbance($row->{MOD2}, $row->{ORIG2});

			if(!isempty($row->{ORIG1}))
			{  
				if(($row->{ORIG1}>0 && $row->{ORIG1} <1600) || $row->{ORIG1} >2014) 
				{
					$keys="BOUNDS Dist year1#".$row->{ORIG1};
					$herror{$keys}++;
				}
			}

			if(!isempty($row->{ORIG2}))
			{ 
				if(( $row->{ORIG2}>0 &&  $row->{ORIG2} <1600) ||  $row->{ORIG2} >2014) 
				{
					$keys="BOUNDS Dist year2#". $row->{ORIG2};
					$herror{$keys}++;
				}
			}

			# if($Dist1 =~ ERRCODE) 
			# { 
			# 	$keys="disturbance1"."#". $row->{MOD1}."#".$row->{ORIG1};
			# 	$herror{$keys}++;  	
			# }

			# if($Dist2 =~ ERRCODE)
			# { 
			# 	$keys="disturbance2"."#". $row->{MOD2}."#".$row->{ORIG2};
			# 	$herror{$keys}++;	
			# }
			  
			if(defined $row->{EXT1}) 
			{
				$Dist1ExtHigh  =  DisturbanceExtUpper($row->{EXT1});
	         	$Dist1ExtLow   =  DisturbanceExtLower($row->{EXT1});

				if($Dist1ExtHigh eq ERRCODE) 
				{ 
					$keys="disturbance1ExtUpp"."#". $row->{EXT1};
					$herror{$keys}++;	
				}

				if($Dist1ExtLow eq ERRCODE) 
				{ 
					$keys="disturbance1ExtLow"."#". $row->{EXT1};
					$herror{$keys}++;	
				}
			}
			else 
			{
				$Dist1ExtHigh  =  MISSCODE;
	         	$Dist1ExtLow   =  MISSCODE;
			}


	        if(defined $row->{EXT2}) 
	        {
				$Dist2ExtHigh  =  DisturbanceExtUpper($row->{EXT2});
	         	$Dist2ExtLow   =  DisturbanceExtLower($row->{EXT2});

				if($Dist2ExtHigh eq ERRCODE)
				{ 
					$keys="disturbance2ExtUpp"."#". $row->{EXT2};
					$herror{$keys}++;	
				}

				if($Dist2ExtLow  eq ERRCODE) 
				{ 
					$keys="disturbance2ExtLow"."#". $row->{EXT2};
					$herror{$keys}++;	
				}
			}
			else 
			{
				$Dist2ExtHigh  =  MISSCODE;
	         	$Dist2ExtLow   =  MISSCODE;
			}
				
	        $Dist1 = $Dist1 . "," . $Dist1ExtHigh . "," . $Dist1ExtLow;
	        $Dist2 = $Dist2 . "," . $Dist2ExtHigh . "," . $Dist2ExtLow;

	        my ($Cd1, $Cd2)=split(",", $Dist1);
			if($Cd1  eq ERRCODE ) 
			{ 
			 	$keys="Disturbance"."#".$row->{MOD1};
				$herror{$keys}++;
			}
	        		 
	 	  	$Dist = $Dist1 . "," . $Dist2.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF;

	 	  	($prodFor1, $lyr_poly1) = productive_code ($row->{SP1}, $CCHigh1 , $CCLow1 , $HeightHigh1 , $HeightLow1, $row->{CC});
		 	if($lyr_poly1)
			{
				$SpeciesComp1 ="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
				$keys="###check artificial lyr on #".$row->{SP1}."#";
				$herror{$keys}++; 
			}	
			($prodFor2, $lyr_poly2) = productive_code ($row->{US2SP1}, $CCHigh2 , $CCLow2 , $HeightHigh2 , $HeightLow2, $row->{US2CC});
		 	if($lyr_poly2)
			{
				$SpeciesComp2 ="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
				$keys="###check artificial lyr on #".$row->{US2SP1}."#";
				$herror{$keys}++; 
			}	
			($prodFor3, $lyr_poly3) = productive_code ($row->{US3SP1}, $CCHigh3 , $CCLow3 , $HeightHigh3 , $HeightLow3, $row->{US3CC});
		 	if($lyr_poly3)
			{
				$SpeciesComp3 ="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
				$keys="###check artificial lyr on #".$row->{US3SP1}."#";
				$herror{$keys}++; 
			}	
			($prodFor4, $lyr_poly4) = productive_code ($row->{US4SP1}, $CCHigh4 , $CCLow4 , $HeightHigh4 , $HeightLow4, $row->{US4CC});
		 	if($lyr_poly4)
			{
				$SpeciesComp4 ="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
				$keys="###check artificial lyr on #".$row->{US4SP1}."#";
				$herror{$keys}++; 
			}	
			($prodFor5, $lyr_poly5) = productive_code ($row->{US5SP1}, $CCHigh5, $CCLow5 , $HeightHigh5 , $HeightLow5, $row->{US5CC});
		 	if($lyr_poly5)
			{
				$SpeciesComp5 ="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
				$keys="###check artificial lyr on #".$row->{US5SP1}."#";
				$herror{$keys}++; 
			}	

			if ($Cd1  eq "CO")
			{
				$prodFor1="PF";
				$lyr_poly1=1;
			}
			#enf of if statement for FLI standard
		}

		$CAS_Record = $CAS_ID . "," . $PolyNum  . "," . $StandStructureCode1 .",". $NumberLyr .",". $IdentifyID . "," . $MapsheetID. "," . $Area . "," . $Perimeter.",".$Area.",".$PHOTO_YEAR;
		print CASCAS $CAS_Record . "\n";
	  	$nbpr=1;$$ncas++;$ncasprev++;

		# ===== Output inventory info =====
	    if($standard_name eq "FRI")
	    {

	        #layer 1
	        if (!isempty($row->{SP_1})  || $lyr_poly || $Nondropped ==2) 
	        {
		      	$LYR_Record11 = $CAS_ID . "," . $SMR  . "," . $StandStructureVal . ",1,1";
		      	$LYR_Record21 = $CCHigh . "," . $CCLow . "," . $HeightHigh . "," . $HeightLow . "," .$prodFor. "," .  $SpeciesComp;
		      	$LYR_Record31 = $OriginHigh . "," . $OriginLow . "," . $SiteClass . "," . $SiteIndex ;
		      	$Lyr_Record41 = $LYR_Record11 . "," . $LYR_Record21 . "," . $LYR_Record31;
		      	print CASLYR $Lyr_Record41 . "\n";
		      	$nbpr++; $$nlyr++;$nlyrprev++;
		    }
		    
	        elsif (!is_missing($NonVegAnth) || !is_missing($NonFor) || !is_missing($NatNonVeg))
	        {
	           	$NFL_Record11 = $CAS_ID . "," . $SMR  . "," .  $StandStructureVal . ",1,1";
	            $NFL_Record21 = $CCHigh . "," . $CCLow . "," . UNDEF . "," . UNDEF;
	            $NFL_Record31 = $NatNonVeg . "," . $NonVegAnth . "," . $NonFor;
	            $NFL_Record1 = $NFL_Record11 . "," . $NFL_Record21 . "," . $NFL_Record31;
	            print CASNFL $NFL_Record1 . "\n";
				$nbpr++;$$nnfl++;$nnflprev++;
		   	}
			if(isempty($YEARORG))
			{
				$ModYr=MISSCODE;
			}
			else 
			{
				$ModYr=$Origin;
			}
		   	if($pr_dstb ==1 && $Dist1 ne MISSCODE)
		   	{	
				$DST_Record = $row->{CAS_ID} . "," . $Dist1.",".$ModYr.",-8888,-8888,-8888,-8888,-8888,-8888,-8888,-8888,-8888,-8888";
		      	print CASDST $DST_Record .",1". "\n";
				if($nbpr==1) {$$ndstonly++; $ndstonlyprev++;}
				$nbpr++;$$ndst++;$ndstprev++;
				#if($nbpr==3) {print "this is alreday in lyr or nfl $CAS_ID\n"}
			}
		 	elsif($dstb ==1)
		 	{
				$DST_Record = $row->{CAS_ID} . ",UK,".$ModYr.",-8888,-8888,-8888,-8888,-8888,-8888,-8888,-8888,-8888,-8888";
				print CASDST $DST_Record .",1". "\n";
				if($nbpr==1) {$$ndstonly++; $ndstonlyprev++;}
				$nbpr++;$$ndst++;$ndstprev++;
				#if($nbpr==3) {print "UK ::: this is alreday in lyr or nfl $CAS_ID\n"}
			}
	        #Ecological, which layer for other info
		    if ($Wetland ne MISSCODE && $Wetland ne UNDEF) 
		    {
		    	$Wetland = $CAS_ID . "," . $Wetland. "-";
		      	print CASECO $Wetland . "\n";
				if($nbpr==1) {$$necoonly++;$necoonlyprev++;}
				$nbpr++;$$neco++;$necoprev++;
		    }
	 		############################### end loop for writing FRI records          
		}
		else 
		{ 
			############################################################################33#wrinting FLI records

			$layer_rank1 = $row->{CANRANK};
  	   		$layer_rank2 = $row->{US2CANRANK};
  	   		$layer_rank3 = $row->{US3CANRANK};
  	   		$layer_rank4 = $row->{US4CANRANK};
  	   		$layer_rank5 = $row->{US5CANRANK};

  	   		if(isempty($layer_rank1))
  	   		{
  	   			$layer_rank1 = MISSCODE;
  	   		}

  	   		if(isempty($layer_rank2))
  	   		{
  	   			$layer_rank2 = MISSCODE;
  	   		}
  	   		if(isempty($layer_rank3))
  	   		{
  	   			$layer_rank3 = MISSCODE;
  	   		}
  	   		if(isempty($layer_rank4))
  	   		{
  	   			$layer_rank4 = MISSCODE;
  	   		}
  	   		if(isempty($layer_rank5))
  	   		{
  	   			$layer_rank5 = MISSCODE;
  	   		}

	        #layer 1
	        if (!isempty($row->{SP1}) || $lyr_poly1  ) 
	        {
		     	$LYR_Record11 = $row->{CAS_ID} . "," . $SMR  . ",". $StandStructureVal . ",1," . $layer_rank1;
		    	$LYR_Record21 = $CCHigh1 . "," . $CCLow1 . "," . $HeightHigh1 . "," . $HeightLow1 . "," .$prodFor1 . "," . $SpeciesComp1;
		     	$LYR_Record31 = $OriginHigh1 . "," . $OriginLow1 . "," . $SiteClass . "," . $SiteIndex ;
		      	$Lyr_Record41 = $LYR_Record11 . "," . $LYR_Record21 . "," . $LYR_Record31;
		      	print CASLYR $Lyr_Record41 . "\n";
				$nbpr++; $$nlyr++;$nlyrprev++;
			}
	        elsif (!isempty($row->{NNF_ANTH})) 
	        {
	            #in case of SC7 type, re-calculate CC
	            if (((substr $row->{NNF_ANTH}, 0, 2) eq "SC"||(substr $row->{NNF_ANTH},0, 2) eq "sc") && (substr $row->{NNF_ANTH}, 2, 2) gt 0) 
	            {
		           	$CCLow1   = $CCLow1_SC;
		            $CCHigh1  = $CCHigh1_SC;
	           	}
	 			#in case of SO7 type, re-calculate CC
	            elsif(((substr $row->{NNF_ANTH}, 0, 2) eq "SO"||(substr $row->{NNF_ANTH},0,2) eq "so") && (substr $row->{NNF_ANTH}, 2, 2) gt 0)
	            {
	           		$CCLow1   = $CCLow1_SO;
	                $CCHigh1  = $CCHigh1_SO;
	            }
	            $NFL_Record11 = $row->{CAS_ID} . "," . $SMR  . "," . $StandStructureVal . ",1," . $layer_rank1;
	           	$NFL_Record21 = $CCHigh1 . "," . $CCLow1 . "," . UNDEF . "," . UNDEF;
	            $NFL_Record31 = $NatNonVeg1 . "," . $NonForAnth1 . "," . $NonForVeg1;
	            $NFL_Record1 = $NFL_Record11 . "," . $NFL_Record21 . "," . $NFL_Record31;
	            print CASNFL $NFL_Record1 . "\n";
				$nbpr++;$$nnfl++;$nnflprev++;
			}
	        else {}
	        #layer 2
	        if (!isempty($row->{US2SP1}) || $lyr_poly2 ) 
	        {
			    $LYR_Record12 = $row->{CAS_ID} . "," . $SMR  . "," .  $StandStructureVal . ",2,". $layer_rank2;
			    $LYR_Record22 = $CCHigh2 . "," . $CCLow2 . "," . $HeightHigh2 . "," . $HeightLow2 . "," .$prodFor2 . "," .  $SpeciesComp2;
			    $LYR_Record32 = $OriginHigh2 . "," . $OriginLow2 . "," . $SiteClass . "," . $SiteIndex;
			    $Lyr_Record42 = $LYR_Record12 . "," . $LYR_Record22 . "," . $LYR_Record32;
			    print CASLYR $Lyr_Record42 . "\n";
				if($nbpr==1) {$nbpr++; $$nlyr++;$nlyrprev++;}
		    }
	        elsif (!isempty($row->{US2NNF_ANT}))
	        {
	            #in case of SC7 type, re-calculate CC
	           	if (((substr $row->{US2NNF_ANT}, 0, 2) eq "SC" || (substr $row->{US2NNF_ANT}, 0, 2) eq "sc") && (substr $row->{US2NNF_ANT}, 2, 2) gt 0) 
	           	{
	           		$CCLow2   = $CCLow2_SC;
	                $CCHigh2  = $CCHigh2_SC;
	            }
	 			#in case of SO7 type, re-calculate CC
	            elsif (((substr $row->{US2NNF_ANT}, 0, 2) eq "SO" || (substr $row->{US2NNF_ANT}, 0, 2) eq "so") && (substr $row->{US2NNF_ANT}, 2, 2) gt 0) 
	            {
	           		$CCLow2   = $CCLow2_SO;
	                $CCHigh2  = $CCHigh2_SO;
	            }


	            $NFL_Record12 = $row->{CAS_ID} . "," . $SMR  . "," . $StandStructureVal .",2," . $layer_rank2;
	            $NFL_Record22 = $CCHigh2 . "," . $CCLow2 . "," . UNDEF . "," . UNDEF;
	            $NFL_Record32 = $NatNonVeg2 . "," . $NonForAnth2 . "," . $NonForVeg2;
	            $NFL_Record2 = $NFL_Record12 . "," . $NFL_Record22 . "," . $NFL_Record32;
	            print CASNFL $NFL_Record2 . "\n";
				if($nbpr==1){$nbpr++;$$nnfl++;$nnflprev++;}
		   	}
	        else {}

	        #layer 3
	        if (!isempty($row->{US3SP1}) || $lyr_poly3 ) 
	        {
			    $LYR_Record13 = $row->{CAS_ID} . "," . $SMR  . "," . $StandStructureVal . ",3," . $layer_rank3;
			    $LYR_Record23 = $CCHigh3 . "," . $CCLow3 . "," . $HeightHigh3 . "," . $HeightLow3  . "," .$prodFor3 . "," . $SpeciesComp3;
			    $LYR_Record33 = $OriginHigh3 . "," . $OriginLow3 . "," . $SiteClass . "," . $SiteIndex;
			    $Lyr_Record43 = $LYR_Record13 . "," . $LYR_Record23 . "," . $LYR_Record33;
			    print CASLYR $Lyr_Record43 . "\n";
				if($nbpr==1){$nbpr++; $$nlyr++;$nlyrprev++;}
		    }
	        elsif (!isempty($row->{US3NNF_ANT}))
	        {
	            #in case of SC7 type, re-calculate CC
	           	if (((substr $row->{US3NNF_ANT}, 0, 2) eq "SC" || (substr $row->{US3NNF_ANT}, 0, 2) eq "sc") && (substr $row->{US3NNF_ANT}, 2, 2) gt 0) 
	           	{
	           	  	$CCLow3   = $CCLow3_SC;
	                $CCHigh3  = $CCHigh3_SC;
	           	}
	 			#in case of SO7 type, re-calculate CC
	            elsif (((substr $row->{US3NNF_ANT}, 0, 2) eq "SO" || (substr $row->{US3NNF_ANT}, 0, 2) eq "so") && (substr $row->{US3NNF_ANT}, 2, 2) gt 0)
	            {
	           		$CCLow3   = $CCLow3_SO;
	                $CCHigh3  = $CCHigh3_SO;
	            }

	         	$NFL_Record13 = $row->{CAS_ID} . "," . $SMR  . "," . $StandStructureVal .",3," . $layer_rank3;
	            $NFL_Record23 = $CCHigh3 . "," . $CCLow3 . "," . UNDEF . "," . UNDEF;
	            $NFL_Record33 = $NatNonVeg3 . "," . $NonForAnth3 . "," . $NonForVeg3;
	            $NFL_Record3 = $NFL_Record13 . "," . $NFL_Record23 . "," . $NFL_Record33;
	            print CASNFL $NFL_Record3 . "\n";
				if($nbpr==1){$nbpr++;$$nnfl++;$nnflprev++;}
		    }
	        else {}

	        #layer 4
	        if (!isempty($row->{US4SP1}) || $lyr_poly4 ) 
	        {
		      	$LYR_Record14 = $row->{CAS_ID} . "," . $SMR  . "," . $StandStructureVal .  ",4,". $layer_rank4;
		      	$LYR_Record24 = $CCHigh4 . "," . $CCLow4 . "," . $HeightHigh4 . "," . $HeightLow4 . "," .$prodFor4 . "," . $SpeciesComp4;
		      	$LYR_Record34 = $OriginHigh4 . "," . $OriginLow4 . "," . $SiteClass . "," . $SiteIndex;
		      	$Lyr_Record44 = $LYR_Record14 . "," . $LYR_Record24 . "," . $LYR_Record34;
		      	print CASLYR $Lyr_Record44 . "\n";
				if($nbpr==1){$nbpr++; $$nlyr++;$nlyrprev++;}
			}
	        elsif (!isempty($row->{US4NNF_ANT})) 
	        {
	            #in case of SC7 type, re-calculate CC
	            if (((substr $row->{US4NNF_ANT}, 0, 2) eq "SC" || (substr $row->{US4NNF_ANT}, 0, 2) eq "sc") && (substr $row->{US4NNF_ANT}, 2, 2) gt 0) 
	            {
	            	$CCLow4   = $CCLow4_SC;
	            	$CCHigh4  = $CCHigh4_SC;
	        	}
	 			#in case of SO7 type, re-calculate CC
		   	 	elsif (((substr $row->{US4NNF_ANT}, 0, 2) eq "SO" || (substr $row->{US4NNF_ANT}, 0, 2) eq "so") && (substr $row->{US4NNF_ANT}, 2, 2) gt 0) 
		   	 	{
	           		$CCLow4   = $CCLow4_SO;
	                $CCHigh4  = $CCHigh4_SO;
	            }

	           	$NFL_Record14 = $row->{CAS_ID} . "," . $SMR  . "," . $StandStructureVal  . ",4,". $layer_rank4;
	            $NFL_Record24 = $CCHigh4 . "," . $CCLow4 . "," . UNDEF . "," . UNDEF;
	            $NFL_Record34 = $NatNonVeg4 . "," . $NonForAnth4 . "," . $NonForVeg4;
	            $NFL_Record4 = $NFL_Record14 . "," . $NFL_Record24 . "," . $NFL_Record34;
	            print CASNFL $NFL_Record4 . "\n";
				if($nbpr==1){$nbpr++;$$nnfl++;$nnflprev++;}
			}
	        else {}

	        #layer 5
			if (defined $row->{US5SP1})
			{
	          	if (!isempty($row->{US5SP1}) || $lyr_poly5 ) 
	          	{
			      	$LYR_Record15 = $row->{CAS_ID} . "," . $SMR  . "," .  $StandStructureVal . ",5,".$layer_rank5;
			      	$LYR_Record25 = $CCHigh5 . "," . $CCLow5 . "," . $HeightHigh5 . "," . $HeightLow5 . "," .$prodFor5 . "," . $SpeciesComp5;
			      	$LYR_Record35 = $OriginHigh5 . "," . $OriginLow5 . "," . $SiteClass . "," . $SiteIndex;
			      	$Lyr_Record45 = $LYR_Record15 . "," . $LYR_Record25 . "," . $LYR_Record35;
			      	print CASLYR $Lyr_Record45 . "\n";
			      	if($nbpr==1){$nbpr++; $$nlyr++;$nlyrprev++;}
		    	}
	            elsif (!isempty($row->{US5NNF_ANT})) 
	            {
	            	#in case of SC7 type, re-calculate CC
	             	if (((substr $row->{US5NNF_ANT}, 0, 2) eq "SC" || (substr $row->{US5NNF_ANT}, 0, 2) eq "sc") && (substr $row->{US5NNF_ANT}, 2, 2) gt 0) 
	             	{
		           	 	$CCLow5   = $CCLow5_SC;
		                $CCHigh5  = $CCHigh5_SC;
	            	}
				  	#in case of SO7 type, re-calculate CC
		            elsif (((substr $row->{US5NNF_ANT}, 0, 2) eq "SO" || (substr $row->{US5NNF_ANT}, 0, 2) eq "so") && (substr $row->{US5NNF_ANT}, 2, 2) gt 0)
		            {
		           	   $CCLow5   = $CCLow5_SO;
		               $CCHigh5  = $CCHigh5_SO;
		            }
		            $NFL_Record15 = $row->{CAS_ID} . "," . $SMR  . "," .  $StandStructureVal .",5,".$layer_rank5;
		            $NFL_Record25 = $CCHigh5 . "," . $CCLow5 . "," . UNDEF . "," . UNDEF;
		            $NFL_Record35 = $NatNonVeg5 . "," . $NonForAnth5 . "," . $NonForVeg5;
		            $NFL_Record5 = $NFL_Record15 . "," . $NFL_Record25 . "," . $NFL_Record35;
		            print CASNFL $NFL_Record5 . "\n";
					if($nbpr==1){$nbpr++;$$nnfl++;$nnflprev++;}
		    	}
	       	 else {}
			} 

		    #Disturbance
			if (!isempty($row->{MOD1})  &&  $Dist1 !~ m/^($errcode)/ &&  $Dist1 !~ m/^($misscode)/) 
			{ 
				#&&  $Dist1 !=~ m/ERRCODE/
			    $DST_Record = $row->{CAS_ID} . "," . $Dist. ",1";
			    print CASDST $DST_Record . "\n";
				if($nbpr==1) {$$ndstonly++; $ndstonlyprev++;}
				$nbpr++;$$ndst++;$ndstprev++;
			}

		    #Ecological, which layer for other info
			if  (!isempty($row->{WETECO1}))
			{
		        if ($Wetland ne MISSCODE &&  ((substr $row->{WETECO1}, 0,1) ne "0") )
		        {
		            $Wetland = $row->{CAS_ID} . "," . $Wetland."WE".$row->{WETECO1};
		            print CASECO $Wetland . "\n";
					if($nbpr==1) {$$necoonly++;$necoonlyprev++;}
					$nbpr++;$$neco++;$necoprev++;
		        }          
		        else
		        {
		            if( $row->{WETECO1} ne "0") 
		            {
		                $Wetland = $row->{CAS_ID} . "," . "-,-,-,-,"."WE".$row->{WETECO1};
		                print CASECO $Wetland . "\n"; 
						if($nbpr==1) {$$necoonly++;$necoonlyprev++;}
						$nbpr++;$$neco++;$necoprev++;

		            }
		        } 
		    }
		    else 
		    {
		        if ($Wetland ne MISSCODE) 
		        {
		            $Wetland = $row->{CAS_ID} . "," . $Wetland."-";
		            print CASECO $Wetland . "\n";
					if($nbpr==1) {$$necoonly++;$necoonlyprev++;}
					$nbpr++;$$neco++;$necoprev++;
		        }             
		    }      
			####################end loop for FLI records
		}
		#if($nbpr ==1 && !$Nondropped){
		if($nbpr ==1 )
		{
			$ndrops++;		
			if($hdr_num eq "0005")
			{
				print MISSING_STANDS "$CAS_ID, LYR from $row->{SPECIES}, NFL from $row->{NNF_ANTH}, ECO from $row->{WETECO1}, DST from $row->{MOD1} >$row->{PROBLEM}>>file=$Glob_filename.",".$problem \n";
			}
			elsif($hdr_num eq "0006")
			{
				print MISSING_STANDS "$CAS_ID, LYR from $row->{SP1}-$row->{SP2}-$row->{SP3}-$row->{SP4}-$row->{SP5}-$row->{SP6}, NFL from $row->{NNF_ANTH}, ECO from $row->{WETECO1}, DST from $row->{MOD1}  >>>file=$Glob_filename \n";
			}
		}  
	}   

	$csv->eof or $csv->error_diag ();
	close $MBinv;

	#%%spfreqprev=%spfreq;
	
	foreach my $k (sort {lc($a) cmp lc($b)} keys %$spfreq){
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
	#close (MBinvo);
	close (CASHDR);
	close (CASCAS);
	close (CASLYR);
	close (CASNFL);
	close (CASDST);
	close (CASECO);
	close(ERRS);	close(SPECSLOGFILE);   close(MISSING_STANDS);  close (SPERRSFILE);
 
	$$nbasprev+=$nbas;
	print "total as=$nbas\n";
	$total=$nlyrprev+ $nnflprev+  $ndstprev;
	$total2=$nlyrprev+ $nnflprev+  $ndstonlyprev + $necoonlyprev;
	#if($total > $ncasprev) {print "must check this !!! \n";}
		#print "$$ncas, $$nlyr, $$nnfl,  $$ndst, $total\n";
	#print "nb records in casfile : $ncasprev, lyrfile : $nlyrprev, nflfile : $nnflprev,  dstfile : $ndstprev--- total(without .cas): $total\n";
	print " ndrops=$ndrops records in casfile : $ncasprev, lyrfile : $nlyrprev, nflfile : $nnflprev,  dstfile : $ndstprev($ndstonlyprev), ecofile : $necoprev($necoonlyprev)--- total (without .cas): $total($total2)\n";
	return($spfreq);
}

1;

