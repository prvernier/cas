# ======================================================= WRITING Output inventory info IN CAS FILES =======================================================================================================
my $prod_for="PF";
my $lyr_poly=1;
if(isempty($Sp1) || $SpeciesComp eq "-1" || $SpeciesComp eq "") {
	$SpeciesComp="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
	if ( !is_missing($CCHigh) ||  !is_missing($CCLow) || !is_missing($HeightHigh) || !is_missing($HeightLow))  
	{
		$prod_for="PP";
		$SpeciesComp="UNDEF,0,UNDEF,0,UNDEF,0,UNDEF,0,UNDEF,0,UNDEF,0,UNDEF,0,UNDEF,0,UNDEF,0,UNDEF,0";
	} else {
		$lyr_poly=0;
	}
}
if ($Cd1  eq "CO") {
	$prod_for="PF";
	$lyr_poly=1;
}
if (!is_missing($UnProdFor)) {
	#new rule from Melina and Steve
	$prod_for="PP";
	if($UnProdFor eq "SD") {
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
if($ucsp1 eq "XC" || $ucsp1 eq "XH" || $ucsp1 eq "ZC" || $ucsp1 eq "ZH") {
	if(isempty($Nfor_desc))	{
		$prod_for = "PP";
	} else {
		$prod_for = "NP";
	}
}

if ($invstd eq "F" && $Hdr_F_set==0) {
	$Hdr_F_set=1;
	print CASHDR $HDR_RecordF . "\n";
} elsif ($invstd eq "V" && $Hdr_V_set==0) {
	#print "invent is $invstd and hdrset = $Hdr_V_set\n"; 
	$Hdr_V_set=1;
	print CASHDR $HDR_RecordV . "\n";
} elsif ($invstd eq "I" && $Hdr_I_set==0) {
	$Hdr_I_set=1;
	print CASHDR $HDR_RecordI . "\n";
}

$CAS_Record = $CAS_ID . "," . $StandID . "," . $StandStructureCode. "," .$NumLayers.",". $IdentifyID . "," . $MapSheetID . "," . $Area . "," . $Perimeter . ",".$Area. ",".$PHOTO_YEAR;
print CASCAS $CAS_Record . "\n";
$nbpr=1;$$ncas++;$ncasprev++;

$isNFL=1;
if ($invstd eq "V" || $invstd eq "I") {
	if (($NatNonVeg ne MISSCODE && $NatNonVeg ne UNDEF) || ($NonVegAnth ne MISSCODE && $NonVegAnth ne UNDEF) || ($NonForVeg ne MISSCODE && $NonForVeg ne UNDEF)){
	#if ($NatNonVeg ne MISSCODE || $NonVegAnth ne MISSCODE || $NonForVeg ne MISSCODE){
		$NFL_Record3 = $NatNonVeg . "," . $NonVegAnth . "," . $NonForVeg;
	} elsif (($NatNonVeg2 ne MISSCODE && $NatNonVeg2 ne UNDEF) || ($NonVegAnth2 ne MISSCODE && $NonVegAnth2 ne UNDEF) || ($NonForVeg2 ne MISSCODE && $NonForVeg2 ne UNDEF)){
	#elsif ($NatNonVeg2 ne MISSCODE || $NonVegAnth2 ne MISSCODE || $NonForVeg2 ne MISSCODE){
		$NFL_Record3 = $NatNonVeg2 . "," . $NonVegAnth2 . "," . $NonForVeg2;
	} elsif (($NatNonVeg3 ne MISSCODE && $NatNonVeg3 ne UNDEF) || ($NonVegAnth3 ne MISSCODE && $NonVegAnth3 ne UNDEF) || ($NonForVeg3 ne MISSCODE && $NonForVeg3 ne UNDEF)){
	#elsif ($NatNonVeg3 ne MISSCODE || $NonVegAnth3 ne MISSCODE || $NonForVeg3 ne MISSCODE){
		$NFL_Record3 = $NatNonVeg3 . "," . $NonVegAnth3 . "," . $NonForVeg3;
	} else {
		$isNFL=0;
	}
} elsif ($invstd eq "F" ) {
	if (($NatNonVeg ne MISSCODE && $NatNonVeg ne UNDEF) || ($NonVegAnth ne MISSCODE && $NonVegAnth ne UNDEF) || ($NonForVeg ne MISSCODE && $NonForVeg ne UNDEF)) {
	#if ($NatNonVeg ne MISSCODE || $NonVegAnth ne MISSCODE || $NonForVeg ne MISSCODE){
		$NFL_Record3 = $NatNonVeg . "," . $NonVegAnth . "," . $NonForVeg;
	} else {
		$isNFL=0;
	}
} else {
	print "standard not V,I nor F; check it!\n"; exit;
}

if (defined $Sp1 ) {
	
} else {
	$Sp1="";
}
if (defined $Sp2 ) {
	
} else {
	$Sp2="";
}

#layer 1
#if (!isempty($Sp1) || ($UnProdFor ne MISSCODE && $UnProdFor ne ERRCODE && $UnProdFor ne UNDEF)) {
if (!isempty($Sp1) || $lyr_poly==1) {
	$LYR_Record1 = $CAS_ID . "," . $SMR  . "," . $StandStructureVal . "," .$LayerId.",". $LayerRank;  #old ",1,1"  -change on july 2014
	$LYR_Record2 = $CCHigh . "," . $CCLow . "," . $HeightHigh . "," . $HeightLow . "," . $prod_for.",".$SpeciesComp;
	$LYR_Record3 = $OriginHigh . "," . $OriginLow . "," . $SiteClass . "," . $SiteIndex;
	$Lyr_Record = $LYR_Record1 . "," . $LYR_Record2 . "," . $LYR_Record3;
	print CASLYR $Lyr_Record . "\n";
	$nbpr++; $$nlyr++;$nlyrprev++;
	#print "voici $LYR_Record3\n";
} elsif ( $isNFL==1) { 
	$NFL_Record1 = $CAS_ID . "," . $SMR  . "," . $StandStructureVal . "," .$LayerId.",". $LayerRank;  #old ",1,1"  -change on july 2014
	$NFL_Record2 = $CCHigh . "," . $CCLow . "," . MISSCODE . "," . MISSCODE;
	$NFL_Record3 = $NatNonVeg . "," . $NonVegAnth . "," . $NonForVeg;
	$NFL_Record = $NFL_Record1 . "," . $NFL_Record2 . "," . $NFL_Record3;
	print CASNFL $NFL_Record . "\n";
	$nbpr++;$$nnfl++;$nnflprev++;
}

if (!isempty($Mod1) && $Cd1 ne ERRCODE) {
	$DST_Record = $CAS_ID . "," . $Dist. ",". $LayerId;  #June 2014 --- newly added, layer fiel in .dst record
	print CASDST $DST_Record . "\n";
	if($nbpr==1) {$$ndstonly++; $ndstonlyprev++;}
	$nbpr++;$$ndst++;$ndstprev++;
}

$Ecosite="-";
if(defined $row->{BEC_ZONE_CODE} ) {
	if( !isempty($row->{BEC_ZONE_CODE})) {
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
if ($Wetland ne MISSCODE) {
	$Wetland = $CAS_ID . "," . $Wetland.$Ecosite;
	print CASECO $Wetland . "\n";
	if($nbpr==1) {$$necoonly++;$necoonlyprev++;}
	$nbpr++;$$neco++;$necoprev++;
}

if($nbpr ==1 ) {
	$ndrops++;
	if($temp2 ne "") {
		if($INV_version eq "V" || $INV_version eq "I") {
			if(defined $BC_Areatracking{$CAS_ID}) {
				$$temp3+=$Area; $missing_area+=$Area;
				print MISSING_STANDS "$CAS_ID, LYR from $$SpComp, NFL from $LandCoverClassCode and $NonVeg, wetland= $Wetland, DST from $Mod1 >>>file=$Glob_filename \n"; 
			}
		} else {	
			if(defined $BC_Areatracking{$CAS_ID}) {
				$$temp3+=$Area; $missing_area+=$Area;
				print MISSING_STANDS "$CAS_ID, LYR from $$SpComp, NFL from $NPdesc, wetland= $Wetland, DST from $Mod1 >>>file=$Glob_filename \n";
			}
		}
	}
}
