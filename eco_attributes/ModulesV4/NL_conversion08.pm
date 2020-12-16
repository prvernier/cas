package ModulesV4::NL_conversion08;


use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(&NLinv_to_CAS );
#our @EXPORT_OK = qw(&SoilMoistureRegime &StandStructure  &StandStructureValue &CCUpper  &CCLower &StandHeight &Latine &UpperOrigin &NaturallyNonVeg  &LowerOrigin &Species  &Disturbance &Site );

use strict;

use constant 
{
    INFTY =>-1,
    ERRCODE => -9999,
	SPECIES_ERRCODE => "XXXX ERRC",
	MISSCODE => -1111,
	UNDEF=> -8888
};


our $Glob_CASID;
our $Glob_filename;	
our $Species_table;	

sub isempty
{
  my $val=shift(@_);
  if(!defined ($val))
  {
    return 1;
  }
  $val =~ s/\s//g;

  if($val eq "" || $val eq "NULL") {
    return 1;
  }
  else {
    return 0;
  } 
}

sub is_missing
{
  my $val=shift(@_);
    
  if(!defined ($val) || $val eq MISSCODE || $val eq ERRCODE || $val eq UNDEF) 
  {
    return 1;
  }
  else 
  {
    return 0;
  } 
}

#Derive SoilMoistureRegime only for non commercial forest
sub SoilMoistureRegime
{
	my $MoistReg;
	my %MoistRegList = ("", 1, "D", 1, "W", 1, "R", 1, "d", 1, "r", 1, "w", 1 );
	my $SoilMoistureReg;

	($MoistReg) = shift(@_);

	if (isempty($MoistReg) ) { $SoilMoistureReg = MISSCODE;}
	elsif (!$MoistRegList {$MoistReg} )  {$SoilMoistureReg = ERRCODE; }

	elsif (($MoistReg eq "d") || ($MoistReg eq "D"))         { $SoilMoistureReg = "D"; }
	elsif (($MoistReg eq "w") || ($MoistReg eq "W"))         { $SoilMoistureReg = "W"; }
	elsif (($MoistReg eq "R") || ($MoistReg eq "r"))         { $SoilMoistureReg = "R"; }
	
	return $SoilMoistureReg;
}


#Determine CCUpper from Crown Closure 

sub CCUpper 
{
	my $CCHigh="";
	my $Density;
	my $ComFor;my $Wkg;
	my %DensityList = ("0", 1, "1", 1, "2", 1, "3", 1, "4", 1);

	($Density) = shift(@_); 
	($ComFor) = shift(@_); 
	($Wkg) = shift(@_); 

	if (isempty($Density ))              { $CCHigh = MISSCODE; }
	elsif (!$DensityList {$Density} ) {$CCHigh = ERRCODE; }
	
		if($ComFor) 
		{

			#if (($Wkg eq "DI") || ($Wkg eq "NS"))            { $CCHigh = 25; }
			if (($Density eq "4"))            { $CCHigh = ERRCODE; }
			elsif (($Density eq "3"))            { $CCHigh = 50; }
			elsif (($Density eq "2"))            { $CCHigh = 75; }
			elsif (($Density eq "1"))            { $CCHigh = 100; }
			elsif (($Density eq "0"))            { $CCHigh = 50; }#50 from John
			elsif(!isempty($Wkg))
			{
				if (($Wkg eq "DI") || ($Wkg eq "NS"))       { $CCHigh = 25; }
				else { $CCHigh = ERRCODE; }
			}
		}
		else 
		{
			if (($Density eq "4"))            { $CCHigh = 25; }
			elsif (($Density eq "3"))            { $CCHigh = 50; }
			elsif (($Density eq "2"))            { $CCHigh = 75; }
			elsif (($Density eq "1"))            { $CCHigh = 100; }
			elsif (($Density eq "0"))            { $CCHigh = 50; }#50 from John
		}
	

	return $CCHigh;
}

#Determine CCLower from CC
sub CCLower 
{
	my $CCLow="";
	my $Density;
	my $ComFor; my $Wkg;
	my %DensityList = ( "0", 1, "1", 1, "2", 1, "3", 1, "4", 1);

	($Density) = shift(@_); 
	($ComFor) = shift(@_);
	($Wkg) = shift(@_); 

	if (isempty($Density))               { $CCLow = MISSCODE; }
	elsif (!$DensityList {$Density} )  {$CCLow = ERRCODE; }

	if($ComFor) {
			#if (($Wkg eq "DI") || ($Wkg eq "NS"))     { $CCLow = 1; }
		
		if (($Density eq "4"))            { $CCLow = ERRCODE; }
		elsif (($Density eq "3"))            { $CCLow = 26; }
		elsif (($Density eq "2"))            { $CCLow = 51; }
		elsif (($Density eq "1"))            { $CCLow = 76; }
		elsif (($Density eq "0"))            { $CCLow = 26; } #26from John
		elsif(!isempty($Wkg)) 
		{
			if (($Wkg eq "DI") || ($Wkg eq "NS"))            { $CCLow = 1; }
			else { $CCLow = ERRCODE; }
		}
	}
	else
	{ 
		if (($Density eq "4"))            { $CCLow = 1; } #must be 10
		elsif (($Density eq "3"))            { $CCLow = 26; }
		elsif (($Density eq "2"))            { $CCLow = 51; }
		elsif (($Density eq "1"))            { $CCLow = 76; }
		elsif (($Density eq "0"))            { $CCLow = 26; }#26 from John
		
	}
	return $CCLow;
}


#Determine stand height from HEIGHT	5   2.5 - 7.5	| 10   7.6-12.5	| 15  12.6 - 17.5  |	20   17.6 - 22.5 | 25    22.6-INFINITY	

sub StandHeightUp 
{
	my $Height; 
	my $isCF;
	my %HeightList = ("", 1, "1", 1, "2", 1, "3", 1, "4", 1, "5", 1, "6", 1, "7", 1, "8", 1);
	my $HUpp;

	($Height) = shift(@_);
	($isCF) = shift(@_);

	if  (isempty($Height))           { $HUpp = MISSCODE; }
	elsif (!$HeightList {$Height} ) { $HUpp = ERRCODE; }
	
	elsif (($Height eq "1"))  		  		{ $HUpp = 3.5; }
	elsif (($Height eq "2"))                  { $HUpp = 6.5; }
	elsif (($Height eq "3"))                  { $HUpp = 9.5; }
	elsif (($Height eq "4"))                  { $HUpp = 12.5; }
	elsif (($Height eq "5"))                  { $HUpp = 15.5; }

	elsif($isCF) 
	{
		if (($Height eq "6"))                  { $HUpp = 18.5; }
		elsif (($Height eq "7"))                  { $HUpp = 21.5; }
		elsif (($Height eq "8"))                  { $HUpp = INFTY; }
	 }
	else 
	{
		$HUpp =ERRCODE;
	}

	return $HUpp;
}

#Determine lower bound stand height from HEIGHT  
sub StandHeightLow 
{
	my $Height; my $isCF;
	my %HeightList = ("", 1, "1", 1, "2", 1, "3", 1, "4", 1, "5", 1, "6", 1, "7", 1, "8", 1);
	my $HLow;

	($Height) = shift(@_);
	($isCF) = shift(@_);
	
	if  (isempty($Height))                    { $HLow = MISSCODE; }
	elsif (!$HeightList {$Height} )  	{ $HLow = ERRCODE; }
	
	elsif (($Height eq "1"))  	          { $HLow = 0; }
	elsif (($Height eq "2"))                  { $HLow = 3.6; }
	elsif (($Height eq "3"))                  { $HLow = 6.6; }
	elsif (($Height eq "4"))                  { $HLow = 9.6; }
	elsif (($Height eq "5"))                  { $HLow = 12.6; }

	elsif($isCF) 
	{
		if (($Height eq "6"))                  { $HLow = 15.6; }
		elsif (($Height eq "7"))                  { $HLow = 18.6; }
		elsif (($Height eq "8"))                  { $HLow = 21.6; }
	}
	else 
	{
		$HLow =ERRCODE;
	}

	return $HLow;
	            		       
}

sub Latine 
{
	my $CurrentSpecies = shift(@_);
	my $GenusSpecies;

	if (isempty($CurrentSpecies))   { $GenusSpecies = "XXXX MISS"; }
	else 
	{
		$_ = $CurrentSpecies;
		tr/a-z/A-Z/;
		$CurrentSpecies = $_;
		$CurrentSpecies =~ s/\s//g;

		if (isempty($CurrentSpecies))   { $GenusSpecies = "XXXX MISS"; }

		elsif ($CurrentSpecies eq "CS") { $GenusSpecies = "XXXX UNDF"; } 
		elsif ($CurrentSpecies eq "DS")  { $GenusSpecies = "XXXX UNDF"; }
		elsif ($Species_table->{$CurrentSpecies}) { $GenusSpecies = $Species_table->{$CurrentSpecies}; }
		else 	 {$GenusSpecies = SPECIES_ERRCODE;  print SPECSLOGFILE "Illegal species code $CurrentSpecies, CAS_ID=$Glob_CASID, file=$Glob_filename\n";  } 
	}

	return $GenusSpecies;
}



#Determine Species from the 3 Species fields
sub Species
{
	my $Sp1c    = shift(@_);
	my $Sp1Per=0;
	my $Sp2c    = shift(@_);
	my $Sp2Per=0;
	my $Sp3c    = shift(@_);
	my $Sp3Per=0;
	my $spfreq = shift(@_);
	my $myc;

	my $Species;
	my $notnull=0;
	
	my $Sp1;my $Sp2;my $Sp3;
	if(!isempty($Sp1c)){$notnull++;}
	else {	$Sp1c    = "";}
	if(!isempty($Sp2c)){$notnull++;}
	else {	$Sp2c    = "";}
	if(!isempty($Sp3c)){$notnull++;}
	else {	$Sp3c    = "";}
	
	 
	if($notnull==1)
	{
		$Sp1Per=100;$Sp2Per=0;$Sp3Per=0;
	}
	elsif($notnull==2)
	{  
		$Sp1Per=60;$Sp2Per=40;$Sp3Per=0;
					
	}
	elsif($notnull==3)
	{
		$Sp1Per=40;$Sp2Per=30;$Sp3Per=30; 
	} 
		
	$spfreq->{$Sp1c}++;
	$spfreq->{$Sp2c}++;
	$spfreq->{$Sp3c}++; 
	
	if($Sp1c eq "BF" || $Sp2c eq "BF" || $Sp3c eq "BF") {$myc ="BF"; print "value for BF is $spfreq->{$myc}\n"; exit;}
	
	$Sp1 = Latine($Sp1c); if($Sp1 eq "XXXX UNDF") {$Sp1Per=0;} 
	$Sp2 = Latine($Sp2c); if($Sp2 eq "XXXX UNDF") {$Sp2Per=0;} 
	$Sp3 = Latine($Sp3c); if($Sp3 eq "XXXX UNDF") {$Sp3Per=0;} 
	#if($Sp1 eq SPECIES_ERRCODE) {print "unrecognised species 1 $Sp1c (sp2= $Sp2	- sp3= $Sp3)\n"; }
	#if($Sp2 eq SPECIES_ERRCODE) {print "unrecognised species 2 $Sp2c (sp1= $Sp1	- sp3= $Sp3)\n"; }
	#if($Sp3 eq SPECIES_ERRCODE) {print "unrecognised species 3 $Sp3c  (sp1= $Sp1	- sp2= $Sp2)\n"; }
	$Species = $Sp1 . "," . $Sp1Per . "," . $Sp2 . "," . $Sp2Per . "," . $Sp3 . "," . $Sp3Per;

	#$Species = $Sp1 . "," . $Sp1Per . "," . $Sp2 . "," . $sp2Per . "," . $Sp3 . "," . $sp3Per . "," . $Sp4 . "," . $sp4Per. "," . $Sp5 . "," . $sp5Per;

	return $Species;
}

#Determine upper stand origin from Age

sub UpperOrigin 
{
	my $Origin;
	my $OriginHigh;
	my $CodeI;
	my %OriginList = ("", 1, "1", 1, "2", 1, "3", 1, "4", 1, "5", 1, "6", 1, "7", 1, "8", 1, "9", 1 );

	($Origin) = shift(@_);
	($CodeI) = shift(@_);

	if  (isempty($Origin))          { $OriginHigh  = MISSCODE; }
	elsif (!$OriginList {$Origin} ) { $OriginHigh = ERRCODE; }

	elsif (($Origin eq "1"))  	          	  { $OriginHigh = 20; }
	elsif (($Origin eq "2"))                  { $OriginHigh = 40; }
	elsif (($Origin eq "3"))                  { $OriginHigh = 60; }
	elsif (($Origin eq "4"))                  { $OriginHigh = 80; }
	elsif (($Origin eq "5"))                  { $OriginHigh = 100; }
	elsif (($Origin eq "6"))                  { $OriginHigh= 120; }

	elsif ($CodeI >= 1 && $CodeI <= 180) {

		
		if (($Origin eq "7"))                  { $OriginHigh = INFTY; }
		elsif (($Origin eq "8"))  		  { $OriginHigh = ERRCODE; }
		elsif (($Origin eq "9"))  		  { $OriginHigh = ERRCODE; }
		 
	}
	elsif ($CodeI >= 238 && $CodeI <= 415) { 

		if (($Origin eq "7"))                  { $OriginHigh = 140; }
		elsif (($Origin eq "8"))                  { $OriginHigh = 160; }
		elsif (($Origin eq "9"))                  { $OriginHigh = INFTY; }
		 
	}

	return $OriginHigh;
}

#Determine lower stand origin from Origin
#NL_0001-xxxMS001 à NL_0001-xxxMS180 sont à l'île de Terre-Neuve
#NL_0001-xxxMS238 à NL_0001-xxxMS415 sont au Labrador

sub LowerOrigin 
{
	my $Origin;my $OriginLow;
	my $CodeI;
	my %OriginList = ("", 1, "1", 1, "2", 1, "3", 1, "4", 1, "5", 1, "6", 1, "7", 1, "8", 1, "9", 1 );
	
	($Origin) = shift(@_);
	($CodeI) = shift(@_);

	if  (isempty($Origin))                    { $OriginLow  = MISSCODE; }
	elsif (!$OriginList {$Origin} )  { $OriginLow = ERRCODE; }

	elsif (($Origin eq "1"))  	          	  { $OriginLow = 0; }
	elsif (($Origin eq "2"))                  { $OriginLow = 21; }
	elsif (($Origin eq "3"))                  { $OriginLow = 41; }
	elsif (($Origin eq "4"))                  { $OriginLow = 61; }
	elsif (($Origin eq "5"))                  { $OriginLow = 81; }
	elsif (($Origin eq "6"))                  { $OriginLow = 101; }
	elsif (($Origin eq "7"))                  { $OriginLow = 121; }

	elsif ($CodeI >= 1 && $CodeI <= 180) {

		if (($Origin eq "8"))  		  { $OriginLow = ERRCODE; }
		elsif (($Origin eq "9"))  		  { $OriginLow = ERRCODE; }	 
	}
	elsif ($CodeI >= 238 && $CodeI <= 415) {
		if (($Origin eq "8"))                  { $OriginLow = 141; }
		elsif (($Origin eq "9"))                  { $OriginLow = 161; }
		 
	}

	return $OriginLow;
}



#as defined in ref document
sub Site 
{
	my $Site;
	my $TPR; my $isComFor;
	my %TPRList = ("", 1, "p", 1, "m", 1, "g", 1, "h", 1, "w", 1, "d", 1, "r",1, "P", 1, "M", 1, "G", 1, "H", 1, "W", 1, "R", 1, "D",1); #w,b=r,d

	($TPR) = shift(@_);
	($isComFor) = shift(@_);

	if  (isempty($TPR))                                      { $Site = MISSCODE; }
	elsif (!$TPRList {$TPR} ) { $Site = ERRCODE; }
	elsif (($TPR eq "h") || ($TPR eq "H"))                   { $Site = "G"; }
	elsif (($TPR eq "p") || ($TPR eq "P"))                   { $Site = "P"; }
	elsif (($TPR eq "m") || ($TPR eq "M"))                   { $Site = "M"; }
	elsif (($TPR eq "g") || ($TPR eq "G"))                   { $Site = "G"; }
	elsif (($TPR eq "w") || ($TPR eq "W"))                   { $Site = "P"; } #from John
	elsif (($TPR eq "d") || ($TPR eq "D"))                   { $Site = "P"; } #from John
	elsif (($TPR eq "r") || ($TPR eq "R"))                   { $Site = "P"; } #from John
	return $Site;
}


#Forest Stands----------------------------- 1 to 899, 1000 to 7000
#S#*Softwood Scrub ------------------------ 900 
#Stand Remnant -------------------------- 905
#Small Cut Area (Unknown Year) ----- 906
#Small Island------------------------------ 907
#H#*Hardwood Scrub ----------------------- 910
#Area not interpreted--------------------- 915
#Bog---------------------------------------- 920
#Wet Bog ---------------------------------- 925
#Treed Bog -------------------------------- 930
#Rb#Rock Barren------------------------------ 940
#Sb#Soil Barren ------------------------------- 950
#Sand--------------------------------------- 951
#C#Cleared Land----------------------------- 960
#RW#Rights-of-Ways (Road)----------------- 961
#RW#Rights-of-Ways (Transmission) ------- 962
#A#Agricultural Land ----------------------- 970
#RES#Residential land ------------------------- 980
#Lakes and Ponds ------------------------ 990
#Double-Sided Rivers-------------------- 991
#Salt Water -------------------------------- 992

#Rb( Rock Barren), Sb ( Soil Barren),  Treed bog (Symbol),  Organic Bog (Symbol), Wet Bog (Symbol),  C (Cleared Land), A (Agriculture), Rw (Right-of-way) , Res (Residential),  

#S900-H910-Bog920-WetBog925-TreedBog930-Rb940-Sb950-C960-RW961-Rw962-A970-Res980
#NatNonVeg 990=LA-991=RI-992=LA-915=OT-951=SD
#UnprodForested NonVegetated NonForested
 

#Natnonveg ==== AP, LA, RI, OC, RK, SA, SI, SL, EX, BE, WS, FL, IS, TF

sub NaturallyNonVeg
{
	my $NatNonVeg;my $NatNonVegRes;
	my %NatNonVegList = ("", 1, "940", 1, "950", 1, "990", 1, "991", 1, "992", 1);

	($NatNonVeg) = shift(@_);
	if  (isempty($NatNonVeg))				{ $NatNonVegRes = MISSCODE; }
	elsif (!$NatNonVegList {$NatNonVeg} ) { $NatNonVegRes = ERRCODE; }
	elsif (($NatNonVeg eq "940"))	{ $NatNonVegRes = "RK"; }
	elsif (($NatNonVeg eq "950"))	{ $NatNonVegRes = "EX"; }
	elsif (($NatNonVeg eq "990"))	{ $NatNonVegRes = "LA"; } 
	elsif (($NatNonVeg eq "991"))	{ $NatNonVegRes = "RI"; } 
	elsif (($NatNonVeg eq "992"))	{ $NatNonVegRes = "WS"; } #previous SW NatNonveg code was there corrected by WS on 28 feb 2013
	else 				{ $NatNonVegRes = ERRCODE; }
	return $NatNonVegRes;
}
#Anthropogenic IN, FA, CL, SE, LG, BP, OT


sub Anthropogenic 
{
	my $NonForAnth = shift(@_); 
	my $NonForAnthRes;
	my %NonForAnthList = ("", 1, "960", 1, "961", 1, "962", 1, "970", 1, "980", 1);


	if  (isempty($NonForAnth))					{ $NonForAnthRes = MISSCODE; }
	elsif (!$NonForAnthList {$NonForAnth} )  { $NonForAnthRes = ERRCODE; }
	
	elsif (($NonForAnth eq "970"))				{ $NonForAnthRes = "CL"; }
	elsif (($NonForAnth eq "961")||($NonForAnth eq "962"))	{ $NonForAnthRes = "FA"; }
	elsif (($NonForAnth eq "980"))				{ $NonForAnthRes = "SE"; }
	elsif (($NonForAnth eq "960"))				{ $NonForAnthRes = "OT"; }
	else { $NonForAnthRes = ERRCODE; }
	return $NonForAnthRes;
}

#NonForestedVeg ---ST, SL, HF, HE, HG, BR, OM, TN


sub NonForestedVeg 
{
    my $NonForVeg = shift(@_); 
    my $NonForVegRes;
	my %NonForVegList = ("", 1, "906", 1, "920", 1, "925", 1);

	my $Mod= shift(@_);


	if  (isempty($NonForVeg))			{ $NonForVegRes = MISSCODE; }
	elsif (!$NonForVegList {$NonForVeg} )   { $NonForVegRes = ERRCODE; }

	elsif (($NonForVeg eq "906" && $Mod eq "CO"))	{ $NonForVegRes = "HF"; }
	elsif (($NonForVeg eq "920"))			{ $NonForVegRes = "BR"; }
	elsif (($NonForVeg eq "925"))			{ $NonForVegRes = "OM"; }
	else 						{ $NonForVegRes = ERRCODE; }
	return $NonForVegRes;
}


#UnProdForest TM, TR, AL, SD, SC, NP,  P

sub UnProdForest 
{
    my $NonForVeg = shift(@_); 
    my $NonForVegRes;
	my %NonForVegList = ("", 1, "900", 1, "905", 1, "907", 1,  "910", 1, "915", 1, "951", 1,"930", 1, "925", 1, "931", 1);


	if  (isempty($NonForVeg))	{ $NonForVegRes = MISSCODE; }
	elsif (!$NonForVegList {$NonForVeg} )  { $NonForVegRes = ERRCODE; }
	
	elsif (($NonForVeg eq "900"))	{ $NonForVegRes = "SC"; }
	elsif (($NonForVeg eq "905"))	{ $NonForVegRes = "SC"; }
	elsif (($NonForVeg eq "907"))	{ $NonForVegRes = "SC"; }
	elsif (($NonForVeg eq "910"))	{ $NonForVegRes = "SD"; }
	elsif (($NonForVeg eq "915"))	{ $NonForVegRes = UNDEF; }
	elsif (($NonForVeg eq "951"))	{ $NonForVegRes = "SD"; }
	elsif (($NonForVeg eq "930"))	{ $NonForVegRes = "TM"; }
	elsif (($NonForVeg eq "931"))	{ $NonForVegRes = "TM"; } # added to correct error
	else 				{ $NonForVegRes = ERRCODE; }
	return $NonForVegRes;
}


##########

sub NonForNonProdFor
{
	my $NatNonVeg; my $NatNonVegRes;
	my %NatNonVegList = ("", 1, "940", 1, "950", 1, "960", 1, "970", 1, "961", 1, "962", 1,"980", 1, "920", 1, "930", 1, "931", 1);

	($NatNonVeg) = shift(@_);
	
	if  (isempty($NatNonVeg))		{ $NatNonVegRes = MISSCODE; }
	elsif (!$NatNonVegList {$NatNonVeg} )  { $NatNonVegRes = ERRCODE; }
	
	elsif (($NatNonVeg eq "940"))		{ $NatNonVegRes = "RK"; }
	elsif (($NatNonVeg eq "950"))		{ $NatNonVegRes = "EX"; }
	elsif (($NatNonVeg eq "960"))		{ $NatNonVegRes = "OT"; }
	elsif (($NatNonVeg eq "970"))		{ $NatNonVegRes = "CL"; }
	elsif (($NatNonVeg eq "961")||($NatNonVeg eq "962"))	{ $NatNonVegRes = "FA"; }
	elsif (($NatNonVeg eq "980"))		{ $NatNonVegRes = "SE"; }
	elsif (($NatNonVeg eq "920"))		{ $NatNonVegRes = "BR"; }
	elsif (($NatNonVeg eq "930"))		{ $NatNonVegRes = "TM"; }
	elsif (($NatNonVeg eq "931"))		{ $NatNonVegRes = "TM"; } # added to correct error
	else 					{ $NatNonVegRes = ERRCODE; }
	return $NatNonVegRes;
}
 
sub NonCommercFor
{
	my $NonCommF;my $NonCommFRes;
	my %NonCommFList = ("", 1, "900", 1, "905", 1, "906", 1, "907", 1,  "910", 1, "915", 1, "940", 1, "950", 1, "951", 1,"960", 1, "970", 1, "961", 1, "962", 1,"980", 1, "920", 1, "925", 1, "930", 1, "990", 1, "991", 1, "992", 1);

	($NonCommF) = shift(@_);
	my $Mod= shift(@_);


	if  (isempty($NonCommF))	{ $NonCommFRes = MISSCODE; }
	elsif (!$NonCommFList {$NonCommF} )  { $NonCommFRes = ERRCODE; }
	
	elsif (($NonCommF eq "900"))	{ $NonCommFRes = "SC"; }
	elsif (($NonCommF eq "905"))	{ $NonCommFRes = "SC"; }
	elsif (($NonCommF eq "906" && $Mod eq "CO"))	{ $NonCommFRes = "HF"; }
	elsif (($NonCommF eq "907"))	{ $NonCommFRes = "SC"; }
	elsif (($NonCommF eq "910"))	{ $NonCommFRes = "SD"; }
	elsif (($NonCommF eq "915"))	{ $NonCommFRes = UNDEF; }
	elsif (($NonCommF eq "940"))	{ $NonCommFRes = "RK"; }
	elsif (($NonCommF eq "950"))	{ $NonCommFRes = "EX"; }
	elsif (($NonCommF eq "951"))	{ $NonCommFRes = "SD"; }
	elsif (($NonCommF eq "960"))	{ $NonCommFRes = "OT"; }
	elsif (($NonCommF eq "970"))	{ $NonCommFRes = "CL"; }
	elsif (($NonCommF eq "961")||($NonCommF eq "962"))	{ $NonCommFRes = "FA"; }
	elsif (($NonCommF eq "980"))	{ $NonCommFRes = "SE"; }
	elsif (($NonCommF eq "920"))	{ $NonCommFRes = "BR"; }
	elsif (($NonCommF eq "925"))	{ $NonCommFRes = "OM"; }
	elsif (($NonCommF eq "930"))	{ $NonCommFRes = "TM"; }
	elsif (($NonCommF eq "990"))	{ $NonCommFRes = "LA"; }#verify
	elsif (($NonCommF eq "991"))	{ $NonCommFRes = "RI"; }#verify
	elsif (($NonCommF eq "992"))	{ $NonCommFRes = "SW"; }#verify
	else 				{ $NonCommFRes = ERRCODE; }
	return $NonCommFRes;
}


#S = SC                    Rb = RK     	H = SD                Sb = EX	(Also assign height code and crown closure code)        Organic Bog (symbol) = OM			Treed Bog (Symbol) = TM		Wet Bog (Symbol) = OM		A = CL	Res = SE	RW = FA	C = OT
#X=CO	Y=BU	Z=IK	W=WF	M=OT

#from Disturbance or STAND HISTORY
sub Disturbance1 
{
	my $ModCode;
	my $Mod;
	my $ModYr;
	my $Disturbance;
	
	my %ModList = ("", 1, "X", 1, "Y", 1, "Z", 1, "W", 1, "M", 1, "V", 1,
			      "x", 1, "y", 1, "z", 1, "w", 1, "m", 1, "v", 1);
   
	($ModCode) = shift(@_);
	($ModYr) = shift(@_);
	

	if (isempty($ModYr)) {$ModYr=MISSCODE; }

	if (isempty($ModCode)) 
	{ 
		$Disturbance = MISSCODE.",".$ModYr; 
	}
	elsif ($ModList{$ModCode}) 
	{ 

 		if (($ModCode  eq "X") || ($ModCode eq "x")) { $Mod="CO"; }
		elsif (($ModCode  eq "Y") || ($ModCode eq "y")) { $Mod="BU"; }
		elsif (($ModCode  eq "Z") || ($ModCode eq "z")) { $Mod="IK"; }
		elsif (($ModCode  eq "W") || ($ModCode eq "w")) { $Mod="WF"; }	
		elsif (($ModCode  eq "M") || ($ModCode eq "m")) { $Mod="OT"; }	
		elsif (($ModCode  eq "V") || ($ModCode eq "v")) { $Mod="OT"; }	

		$Disturbance = $Mod . "," . $ModYr; 
	}
	else 
	{
		 $Mod = ERRCODE; 
		 $Disturbance = $Mod . "," . $ModYr; 
	}

	return $Disturbance;
}

sub Disturbance2 
{
	my $Mod;
	my $ModYr; my $Sylvc;
	my $Disturbance;

	($Sylvc) = shift(@_);
	($ModYr) = shift(@_);
	$_ =$Sylvc;tr/a-z/A-Z/; $Sylvc = $_;
	
	my %ModList = ("", 1, "PB", 1,  "P", 1, "DS",1, "SP",1, "PCT",1, "CT",1, "CAR",1, "CNR",1, "MAR",1, "PM",1, "RC",1, "GP",1, "H",1, "IS",1, "DLT",1, "AS",1, "CTD",1, "PC",1);
   
	#PC is added to correct error 
	
	
	if (isempty($ModYr)) {$ModYr=MISSCODE; }

	if (isempty($Sylvc)) 
	{ 
		$Disturbance = MISSCODE.",".$ModYr; 
	}
	elsif ($ModList{$Sylvc}) 
	{ 
 		if (($Sylvc  eq "PB") || ($Sylvc eq "P") || ($Sylvc  eq "DS") || ($Sylvc eq "SP") || ($Sylvc eq "PC")) { $Mod="SI"; }
		elsif (($Sylvc  eq "PCT") || ($Sylvc eq "CT") || ($Sylvc  eq "CAR") || ($Sylvc eq "CNR")) { $Mod="SI"; }
		elsif (($Sylvc  eq "MAR") || ($Sylvc eq "PM") || ($Sylvc  eq "RC") || ($Sylvc eq "GP")) { $Mod="SI"; }
		elsif (($Sylvc  eq "H") || ($Sylvc eq "IS") || ($Sylvc  eq "DLT") || ($Sylvc eq "AS") || ($Sylvc eq "CTD")) 							  							{ $Mod="SI"; }
					
		$Disturbance = $Mod . "," . $ModYr; 
	} 
	else 
	{
		 $Mod = ERRCODE; 
		 $Disturbance = $Mod . "," . $ModYr; 
	}

	return $Disturbance;
}

#Organic Bog - Bons     Treed Bog = Btnn    Wet Bog = Mong    Softwood Scrub (S) or Hardwood scrub (H) with W (Wet) Biophysical Class = Stnn
# Determine wetland codes
sub WetlandCodes 
{
	my $NonProd = shift(@_);
	my $Moist =  shift(@_);
	my $Species =  shift(@_);
	 
	my $WetlandCode = "";
	
	 
	if(defined $NonProd) {$_ = $NonProd;tr/a-z/A-Z/; $NonProd = $_;}
	else {$NonProd = "";}
	if(defined $Moist) {$_ = $Moist; tr/a-z/A-Z/; $Moist = $_;}
	else {$Moist = "";}
	if(defined $Species) {$_ = $Species; tr/a-z/A-Z/; $Species = $_;}
	else {$Species = "";}
	 
	
	if($NonProd eq  "920" )  
	{ $WetlandCode = "B,O,N,S,"; }
	elsif($NonProd eq "925" )  
	{ $WetlandCode = "B,T,N,N,"; }
	elsif($NonProd eq "930")  
	{ $WetlandCode = "M,O,N,G,"; }
	elsif($NonProd eq "900" && $Moist eq "W" )  
	{ $WetlandCode = "S,T,N,N,"; }
	elsif($NonProd eq "910" && $Moist eq "W")  
	{ $WetlandCode = "S,T,N,N,"; }
	elsif($Species eq "BSTL" || $Species eq "BSTLBF" ||$Species eq "BSTLWB" )  
	{ $WetlandCode = "S,T,N,N,"; }
	elsif($Species eq "TL" || $Species eq "TLBF" ||$Species eq "TLWB" || $Species eq "TLBS" ||$Species eq "TLBSBF" ||$Species eq "TLBSWB")  
	{ $WetlandCode = "S,T,N,N,"; }
	elsif($Species eq "WBTL" || $Species eq "WBTLBS" ||$Species eq "WBBSTL" )  
	{ $WetlandCode = "S,T,N,N,"; }
	#else  { $WetlandCode = ERRCODE; }
	if ($WetlandCode eq "") {$WetlandCode = MISSCODE;}# MISSCODE.",".MISSCODE.",".MISSCODE.",".MISSCODE.",";
	return $WetlandCode;
}


sub NLinv_to_CAS 
{
	my $NL_File = shift(@_);
	$Species_table = shift(@_);
	my $CAS_File = shift(@_);
	my $ERRFILE = shift(@_);
	my $nbiters = shift(@_);
	my $optgroups= shift(@_);
	my $pathname=shift(@_);
	my $TotalIT=shift(@_);
	
	my $SPERRS = shift(@_); 
	my $spfreq=shift(@_);

	my $ncas=shift(@_);
	my $nlyr=shift(@_);
	my $nnfl=shift(@_);
	my $ndst=shift(@_);
	my $neco=shift(@_);
	my $ndstonly=shift(@_);
	my $necoonly=shift(@_);
	my $SPECSLOG=shift(@_);

	my $ncasprev=0;
	my $nlyrprev=0;
	my $nnflprev=0;
	my $ndstprev=0;
	my $necoprev=0;
	my $ndstonlyprev=0;
	my $necoonlyprev=0;
	my $nbpr=0;
	my $total=0;
	my $total2=0;
	my $ndrops=0;
	my $photofile=$NL_File;
	$photofile =~ s/\.csv$/_photoyear\.csv/g;

 	#print "photofile is $photofile\n"; 
	#####
	# Declare hashtable for a photoyear
	my %NLtable=();
	# Here is the loop to interprete photoyear files when photoyear come from an other source
		
	open (NLsheets, "$photofile") || die "\n Error: Could not open file $photofile !\n";
	my $csv1 = Text::CSV_XS->new
	({
		binary          => 1,
		sep_char    => ";" 
	});
	my $nothing=<NLsheets>;  #drop header line
	my $nbr=0;
	while(<NLsheets>) 
	{ 
		if ($csv1->parse($_)) 
		{
			my @NLS_Record =();
			#print("fFILE is $photofile\n");
		    @NLS_Record = $csv1->fields();  
			my $NLkeys=$NLS_Record[0];
			$NLtable{$NLkeys}=$NLS_Record[1];
			$nbr++;	
			#print("fFILE no = $NLkeys , age = $NLS_Record[1]\n"); exit;
		} 
		else 
		{
		    my $err = $csv1->error_input;
		    print "Failed to parse line: $err"; exit(1);
		}	
	}
	close(NLsheets);
				
				#print " $nbr lines in $photofile\n";

	#####
	my $CAS_File_HDR = $CAS_File . ".hdr";
	my $CAS_File_CAS = $CAS_File . ".cas";
	my $CAS_File_LYR = $CAS_File . ".lyr";
	my $CAS_File_NFL = $CAS_File . ".nfl";
	my $CAS_File_DST = $CAS_File . ".dst";
	my $CAS_File_ECO = $CAS_File . ".eco";

	open (ERRS, ">>$ERRFILE") || die "\n Error: Could not open $ERRFILE file!\n";
	open (SPERRSFILE, ">>$SPERRS") || die "\n Error: Could not open $SPERRS file!\n";
	open (SPECSLOGFILE, ">>$SPECSLOG") || die "\n Error: Could not open $SPECSLOG file!\n";

	if($optgroups==1)
	{

	 	$CAS_File_HDR = $pathname."/NLtable.hdr";
	 	$CAS_File_CAS = $pathname."/NLtable.cas";
	 	$CAS_File_LYR = $pathname."/NLtable.lyr";
	 	$CAS_File_NFL = $pathname."/NLtable.nfl";
	 	$CAS_File_DST = $pathname."/NLtable.dst";
	 	$CAS_File_ECO = $pathname."/NLtable.eco";
	}
	elsif($optgroups==2)
	{

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
		#open (INFOHDR, "<$INFOHDR_File") || die "\n Error: Could not open file $INFOHDR_File !\n";
		# Declare the name of the column that you want into every file. Always the same structure for all the province. Refere to documentation John Cosco

		print CASCAS "CAS_ID,ORIG_STAND_ID,STAND_STRUCTURE,NUM_OF_LAYERS,IDENTIFICATION_ID,MAP_SHEET_ID,GIS_AREA,GIS_PERIMETER,INVENTORY_AREA,PHOTO_YEAR\n";
		print CASLYR "CAS_ID,SOIL_MOIST_REG,STRUCTURE_PER,LAYER,LAYER_RANK,CROWN_CLOSURE_UPPER,CROWN_CLOSURE_LOWER,HEIGHT_UPPER,HEIGHT_LOWER,PRODUCTIVE_FOR,". 		
		"SPECIES_1,SPECIES_PER_1,SPECIES_2,SPECIES_PER_2,SPECIES_3,SPECIES_PER_3,SPECIES_4,SPECIES_PER_4,SPECIES_5,SPECIES_PER_5,SPECIES_6,SPECIES_PER_6,SPECIES_7,SPECIES_PER_7,".
		"SPECIES_8,SPECIES_PER_8,SPECIES_9,SPECIES_PER_9,SPECIES_10,SPECIES_PER_10,ORIGIN_UPPER,ORIGIN_LOWER,SITE_CLASS,SITE_INDEX\n";
		print CASNFL "CAS_ID,SOIL_MOIST_REG,STRUCTURE_PER,LAYER,LAYER_RANK,CROWN_CLOSURE_UPPER,CROWN_CLOSURE_LOWER,HEIGHT_UPPER,HEIGHT_LOWER,NAT_NON_VEG,NON_FOR_ANTH,NON_FOR_VEG\n";
		print CASDST "CAS_ID,DIST_1,DIST_YR_1,DIST_EXT_UPPER_1,DIST_EXT_LOWER_1,DIST_2,DIST_YR_2,DIST_EXT_UPPER_2,DIST_EXT_LOWER_2,DIST_3,DIST_YR_3,DIST_EXT_UPPER_3,DIST_EXT_LOWER_3,LAYER\n";
		print CASECO "CAS_ID,WETLAND_TYPE,WET_VEG_COVER,WET_LANDFORM_MOD,WET_LOCAL_MOD,ECO_SITE\n";
		print CASHDR "IDENTIFICATION_ID,JURISDICTION,COORDINATE_SYS,PROJECTION,DATUM,INVENTORY_OWNER,LAND_OWNER,PERMISSION,TENURE_TYPE,INV_TYPE,INV_VERSION,INV_START_YR,INV_FINISH_YR,INV_ACQ_ID,INV_ACQ_YR,INV_UPDATE_YR\n";

	}
	else 	
	{
		open (CASCAS, ">>$CAS_File_CAS") || die "\n Error: Could not open GROUPCAS  output file!\n";
		open (CASLYR, ">>$CAS_File_LYR") || die "\n Error: Could not open GROUPCAS layer output file!\n";
		open (CASNFL, ">>$CAS_File_NFL") || die "\n Error: Could not open GROUPCAS non-forested file!\n";
		open (CASDST, ">>$CAS_File_DST") || die "\n Error: Could not open GROUPCAS disturbance  file!\n";
		open (CASECO, ">>$CAS_File_ECO") || die "\n Error: Could not open GROUPCAS ecological  file!\n";
		open (CASHDR, ">>$CAS_File_HDR") || die "\n Error: Could not open CAS header output file!\n";
		#open (INFOHDR, "<$INFOHDR_File") || die "\n Error: Could not open file $INFOHDR_File !\n";
	}

	my $Record; my @Fields;my $PolyNum; my $CAS_ID; my $MapSheetID; my $IdentifyID;my $Area; my $Perimeter;
	my $Mer;my $Rng;my $Twp;my $MoistReg; my $Height;
	my $SpAss; my $Sp1;my $Sp2;my $Sp3; my $Sp4;my $Sp5;
	my $Sp1Per;my $Sp2Per;my $Sp3Per;  my $Sp4Per; my $Sp5Per; 
	my $CrownClosure;
	my $Origin;
	my $Dist; my $Dist1; my $Dist2; my $Dist3; 
	my $WetEco;  my $SMR;my $StandStructureCode;
	my $CCHigh;my $CCLow;
	my $SpeciesComp; my $SpComp; 
	my $SiteClass; my $SiteIndex;
	my $Wetland;  
	my $NatNonVeg; 
	my $NonForAnth;  my $UnProdForLand; 
	my %herror=();
	my $keys;
	my $StandStructureVal;
	my $PHOTO_YEAR;
	 
	my $READY1=0; my $READY2=0;
  	my $HeightHigh ;
    my  $HeightLow;  my  $OriginHigh; my $OriginLow;    my @ListSp; my $Mod; my $ModYr; my $NonProd; my $Drain;

	my $CAS_Record; my $Lyr_Record; my $LYR_Record1; my $LYR_Record2; my $LYR_Record3;
	my $NFL_Record; my $NFL_Record1; my $NFL_Record2; my $NFL_Record3; my $DST_Record; 
	my  @SpecsPerList;my $pr1;my $pr2;my $pr3;my $pr4;my $pr5; my $SpAssoc; my $SiteCode; my $Modsylv; my $ModsylvYr;
	my $Wkg;my $isComFor; my $NonVegAnth; my $NonForVeg; my $UnProdFor; my$PRV, my $TRorL; 
	my $NUMBER_OF_LAYERS;
	# from BK 04-08-20011 ------------ $TRorL est une nouvelle variable indiquant si on se trouve à TN ou au Labrador

  	my $csv = Text::CSV_XS->new
  	({
  		binary          => 1,
		sep_char    => ";" 
	});
    open my $NLinv, "<", $NL_File or die " \n Error: Could not open NewFoundland input file $NL_File: $!";
  	my @tfilename= split ("/", $NL_File);
	my $nps=scalar(@tfilename);
	$Glob_filename= $tfilename[$nps-1];
	$NUMBER_OF_LAYERS=1;
	$StandStructureVal=UNDEF;


	$csv->column_names ($csv->getline ($NLinv));

   	while (my $row = $csv->getline_hr ($NLinv)) 
   	{	
		
		$Glob_CASID   =  $row->{CAS_ID};
		$CAS_ID       =  $row->{CAS_ID};
		$IdentifyID   =  $row->{HEADER_ID};
		($pr1,$pr2,$pr3,$pr4,$pr5)     =  split("-", $CAS_ID);  
		$PHOTO_YEAR   =  $NLtable{$CAS_ID };	
		if (!defined $PHOTO_YEAR){$PHOTO_YEAR=0;}
		if ($PHOTO_YEAR < 0 || $PHOTO_YEAR >2014) 
		{
			$keys="photoyear ! check value negative or  >2014 "."#".$PHOTO_YEAR;
			$herror{$keys}++;
			$PHOTO_YEAR = MISSCODE;
		}	 
		# print " value is  $PHOTOYEAR\n";  exit;	
        $MapSheetID   =  $pr3; 
        $MapSheetID =~ s/x+//;
        $PolyNum      =  $pr4; 
        $Area         =  $row->{GIS_AREA};
	 	$Perimeter    =  $row->{GIS_PERI};	 
    	$NonProd =  $row->{STAND_ID};	
		$SpAssoc=  $row->{SPECIES_CO};
		$Wkg	=	$row->{WORKING_GR};
		$Height      =  $row->{HEIGHT_CLA};
		$Height     =~ s/\s//g; 
		$CrownClosure      =  $row->{DENSITY_CO};
		$Origin       =  $row->{AGE_CLASS};
		$Origin       =~ s/\s//g;
		#if ($Origin eq " "){$Origin =0;}
		$MoistReg     =  $row->{SITE};  # for non commercial forest only
		$SiteCode     =  $row->{SITE};
		$Mod=  $row->{TYPE_DISTU};
		$ModYr =  $row->{YEAR_DISTU};
		$Modsylv=  $row->{TYPE_SIL};
		$ModsylvYr =  $row->{YEAR_SIL};
		$Sp1=  $row->{SPECIES_1};
		$Sp2=  $row->{SPECIES_2};
		$Sp3=  $row->{SPECIES_3};
			 
		
		if($NonProd eq "900" || $NonProd eq "910" || $Wkg eq "CS" || $Wkg eq "DS") 
		{
			$SMR =  SoilMoistureRegime($MoistReg);
			$isComFor=0;
		}
		else 
		{
			$SMR  = UNDEF;
			$isComFor=1;		
		}

		$SiteClass = Site($SiteCode); 
		if($SiteClass  eq ERRCODE) 
		{  
			$keys="Sitecode"."#".$SiteCode."#casID#".$CAS_ID."#nonProd#".$NonProd."#Wkg#".$Wkg;
			$herror{$keys}++; 
	  	}
		$SiteIndex = UNDEF; 
		$StandStructureCode = "S";


		$CCHigh = CCUpper($CrownClosure, $isComFor, $Wkg);
		$CCLow = CCLower($CrownClosure, $isComFor, $Wkg);
	    if(isempty($CCHigh)) { print "error in CCUpper CC= $CrownClosure, iscomfo=$isComFor, wkg=$Wkg\n"; exit;}
	    if(isempty($CCLow)) { print "error in CCLow  CC= $CrownClosure, iscomfo=$isComFor, wkg=$Wkg \n"; exit;}

		if($CCHigh  eq ERRCODE  ) 
		{
			$CrownClosure=2;
			$CCHigh = CCUpper($CrownClosure, $isComFor, $Wkg);
			if($CCHigh  eq ERRCODE ) 
			{ 
				$keys="Density"."#".$CrownClosure."#iscomfor=#".$isComFor;
			    $herror{$keys}++;
			}
		}
		if( $CCLow  eq ERRCODE) 
		{ 	
			$CrownClosure=2;
			$CCLow= CCUpper($CrownClosure, $isComFor, $Wkg);
			if($CCHigh  eq ERRCODE  ) 
			{ 
				$keys="Density"."#".$CrownClosure."#iscomfor=#".$isComFor;
			    $herror{$keys}++;
			}
		}
	
		$SpeciesComp = Species($Sp1, $Sp2, $Sp3, $spfreq);  

		@SpecsPerList  = split(",", $SpeciesComp); 
	 	$Sp1Per= $SpecsPerList[1];

		if($SpecsPerList[0]  eq SPECIES_ERRCODE  ) 
		{
			$keys="Species1"."#".$Sp1;
		    $herror{$keys}++;
		}
		if($SpecsPerList[2]  eq SPECIES_ERRCODE) 
		{
			$keys="Species2"."#".$Sp2;
			$herror{$keys}++;
		}
		if($SpecsPerList[4]  eq SPECIES_ERRCODE  ) 
		{
			$keys="Species3"."#".$Sp3;
			$herror{$keys}++;
		}
	 
		$SpeciesComp = $SpeciesComp .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";
	  

	 	# ===== Modifiers =====
		$Dist1 = Disturbance1($Mod, $ModYr);
		 
		$Dist2 = Disturbance2($Modsylv, $ModsylvYr); 
		
		my ($Cd1, $Cd2)=split(",", $Dist1);
		  
		my $SavMod=$Cd1;
		if($Cd1 eq ERRCODE) 
		{  		
			if($Mod ne "0" && !isempty($Mod))
			{ 	
				$Mod="M";
				$Dist1="OT".",".$Cd2;
				$SavMod="OT";
				$Cd1="OT";
			}
			else {$Cd1=MISSCODE;}
			#$keys="Disturbance1#".$Mod."#sylv#".$Modsylv;
			#$herror{$keys}++; 			
	  	}

  	 
 	  	#$Dist2 = UNDEF.",0"; 
	  	$Dist3 = UNDEF.",0"; 
        $Dist1 = $Dist1 . "," . UNDEF . "," . UNDEF;
        $Dist2 = $Dist2 . ","  . UNDEF . "," . UNDEF;
        $Dist3 = $Dist3 . "," . UNDEF . "," . UNDEF;

        $Dist = $Dist1 . "," . $Dist2 . "," . $Dist3;

		($PRV,$TRorL)=split("MS", $pr3);
		$OriginHigh = UpperOrigin($Origin, $TRorL);
		$OriginLow = LowerOrigin($Origin, $TRorL);
		if($OriginHigh  eq ERRCODE ||  $OriginLow  eq ERRCODE) 
		{ 
			if($Origin == 8 || $Origin ==9 ) 
			{
				$OriginHigh=INFTY;
				$OriginLow=121;
				$StandStructureCode = "C";
			}
			elsif($Origin ==0 && (($NonProd >=900 &&  $NonProd <1000) || isempty($Sp1) || $Sp1 eq "0"|| $Sp1 eq "CS" || $Sp1 eq "DS"))
			{
								 
			}
			else 
			{
				#$keys="Age"."#".$Origin."#species1#".$Sp1."#disturb#".$SavMod."#nonprod#".$NonProd."#comfor#".$isComFor;
				$keys="Age"."#".$Origin."#species1#".$Sp1;
				$herror{$keys}++;
			}
		}
		if(($OriginHigh  eq MISSCODE ||  $OriginLow  eq MISSCODE) && (!isempty($Sp1) && $Sp1 ne "0" && $Sp1 ne "CS" && $Sp1 ne "DS") && ($NonProd <900 || $NonProd >=1000)  )
		{ 
	#
			#$keys="empty Age#".$Origin."#species1#".$Sp1."#disturb#".$SavMod."#comfor#".$isComFor;
			$keys="empty Age#".$Origin."#species1#".$Sp1;
			$herror{$keys}++;
		}
	 
		$HeightHigh = StandHeightUp($Height,  $isComFor);
		$HeightLow = StandHeightLow($Height,  $isComFor);
		 

		if($HeightHigh  eq ERRCODE   || $HeightLow  eq ERRCODE) 
		{ 
			if ($Height == 0) 
			{
				if($OriginHigh < 30) {$Height=1;}
				elsif($OriginHigh >= 30  && $OriginHigh < 40) {$Height=2;}
				elsif($OriginHigh >= 40  && $OriginHigh < 50) {$Height=3;}
				elsif($OriginHigh >= 50  && $OriginHigh < 70) {$Height=4;}
				elsif($OriginHigh >= 70  && $OriginHigh < 90) {$Height=5;}
				elsif($OriginHigh >=  90 ) {$Height=6;}
		 		#<30years use code 1, 30 to 40 code 2, 4 to 50 code 3, 
				#51 to 70 use code 4, 	71 to 90 code 5 and >90 code 6
	 			$HeightHigh = StandHeightUp($Height,  $isComFor);
				$HeightLow = StandHeightLow($Height,  $isComFor);
			}
			if($HeightHigh  eq ERRCODE   || $HeightLow  eq ERRCODE) 
			{ 
				$keys="Height"."#".$Height."#iscomfor=#".$isComFor;
				$herror{$keys}++;
			}
		}


		#############TURNING AGE INTO ABSOLUTE YEAR VALUE ##################ADDED ON OCTOBER 8TH OF 2009 ##########################
		if ($OriginHigh ne ERRCODE && $OriginHigh ne MISSCODE && $PHOTO_YEAR ne "0" && !isempty($PHOTO_YEAR)) 
		{

			if ($OriginHigh ne INFTY ) {$OriginHigh = $PHOTO_YEAR-$OriginHigh;}
	  		$OriginLow  = $PHOTO_YEAR-$OriginLow;
			if ($OriginHigh > $OriginLow) 
			{ 
				$keys="CHEK ORIGINUPPER-"."#".$Origin."#high=".$OriginHigh."#low=".$OriginLow."#photoyear=".$PHOTO_YEAR."#number".$pr3;
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
		#############      ........­­­.END  OF  TURNING AGE INTO ABSOLUTE YEAR VALUE ###########ADDED ON OCTOBER 8TH OF 2009 #####################
	  
		if($OriginHigh  >2014    || ($OriginHigh  >0 && $OriginHigh <1700)    || $OriginLow >2010   || ($OriginLow <1700 && $OriginLow >0)) 
		{ 
			$keys="invalid age  "."#originhigh#".$OriginHigh."#originlow#".$OriginLow."#origin#".$Origin."#photoyear#".$PHOTO_YEAR;
			$herror{$keys}++;
		}
	  	$Wetland = WetlandCodes ($NonProd, $MoistReg, $SpAssoc);

	  	if($Wetland  eq ERRCODE ) 
	  	{ 
	  		$keys="WETLAND"."#".$NonProd."#".$MoistReg;
			$herror{$keys}++;
		}

	 	# ===== Non-forested Land =====

		$UnProdFor = MISSCODE; 

	 	$NatNonVeg = MISSCODE;  $UnProdForLand = MISSCODE;  
	 	$NonVegAnth = MISSCODE; 
	 	$NonForVeg = MISSCODE; 
	 	$UnProdFor = MISSCODE; 
 	 	if($NonProd >=900 &&  $NonProd <1000)
 	 	{

	 		# $NatNonVeg = NonForNonProdFor($NonProd);
	 		# $UnProdForLand = NonCommercFor($NonProd, $SavMod);

			$NatNonVeg = NaturallyNonVeg($NonProd);
			$NonVegAnth=Anthropogenic($NonProd);
			$NonForVeg=NonForestedVeg($NonProd, $SavMod);
			$UnProdFor=UnProdForest($NonProd);

			if(($NatNonVeg  eq ERRCODE) &&  ($NonVegAnth eq ERRCODE) && ($NonForVeg  eq ERRCODE) &&  ($UnProdFor eq ERRCODE))
			{ 
				$keys="New-NonForNonVeg"."#".$NonProd."#"."savmod"."#".$SavMod."#"."mod"."#".$Mod;
				$herror{$keys}++;
			}
			 else 
			 {
					if ($NatNonVeg  eq ERRCODE) { 
						$NatNonVeg = MISSCODE;  				
					 }
	 				if ($NonVegAnth  eq ERRCODE) { 
						$NonVegAnth = MISSCODE;  				
	 				}
					if ($NonForVeg  eq ERRCODE) { 
						$NonForVeg = MISSCODE;  				
					 }
	 				if ($UnProdFor  eq ERRCODE) { 
						$UnProdFor = MISSCODE;  				
	 				}
			}

	  }

        if($Sp1 eq "CS"){
				$UnProdFor = "SC"; $SpeciesComp="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
	}
 	if($Sp1 eq "DS"){
				$UnProdFor = "SD"; $SpeciesComp="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
	}

	# ======================================================= WRITING Output inventory info IN CAS FILES =================================================================================================
	my $prod_for="PF";
	my $lyr_poly=1;
	if(isempty($Sp1))
	{
		$SpeciesComp="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
		if ( !is_missing($CCHigh) ||  !is_missing($CCLow) || !is_missing($HeightHigh) || !is_missing($HeightLow))
		{
			$prod_for="PP";
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
	if ($UnProdFor ne MISSCODE && $UnProdFor ne ERRCODE && $UnProdFor ne UNDEF)
	{
		$prod_for=$UnProdFor;
	}

	if(!$READY1 && ($TRorL >=1  && $TRorL <=180)){
		print CASHDR  "1,NL,,UTM,NAD83,PROV_GOV (Island),,,,Forest Inventory,With Revisions,1978,2006,,,,\n";
		$READY1=1;
	} 
	elsif(!$READY2 && ($TRorL >=238  && $TRorL <=415)){
		print CASHDR  "2,NL,,UTM,NAD83,PROV_GOV (Labrador),,,,Forest Inventory,With Revisions,1989,1992,,,,\n";
		$READY2=1;
	}


	  if (($StandStructureCode eq "S") || ($StandStructureCode eq "C")) {
            #$CAS_Record = $CAS_ID . "," . $PolyNum . "," . $IdentifyID . "," . $MapSheetID . "," . $Area . "," . $Perimeter . ",".$Area. ",".$PHOTO_YEAR;
	    $CAS_Record = $CAS_ID . "," . $PolyNum . "," . $StandStructureCode .",". $NUMBER_OF_LAYERS.",". $IdentifyID . "," . $MapSheetID . "," . $Area . "," . $Perimeter . ",".$Area. ",".$PHOTO_YEAR;
	    print CASCAS $CAS_Record . "\n";
	    
            #forested
	   # if ($Sp1 ne "") {
 	#if(($NonProd <900 ||  $NonProd >=1000 || $Sp1 eq "CS" || $Sp1 eq "DS") || ($UnProdFor ne MISSCODE && $UnProdFor ne ERRCODE && $UnProdFor ne UNDEF)){
	if(($NonProd <900 ||  $NonProd >=1000 || $Sp1 eq "CS" || $Sp1 eq "DS") || $lyr_poly==1){
	      $LYR_Record1 = $CAS_ID . "," . $SMR  . "," .$StandStructureVal. ",1,1";
	      $LYR_Record2 = $CCHigh . "," . $CCLow . "," . $HeightHigh . "," . $HeightLow . "," .$prod_for.",". $SpeciesComp;
	      $LYR_Record3 = $OriginHigh . "," . $OriginLow . "," . $SiteClass . "," . $SiteIndex;
	      $Lyr_Record = $LYR_Record1 . "," . $LYR_Record2 . "," . $LYR_Record3;
	      print CASLYR $Lyr_Record . "\n";
	    }
            #non-forested
	    #if ($NatNonVeg ne MISSCODE || $UnProdForLand ne MISSCODE) {
	    elsif ( ($NatNonVeg  ne MISSCODE) ||  ($NonVegAnth ne MISSCODE) || ($NonForVeg  eq MISSCODE) ) {
	      $NFL_Record1 = $CAS_ID . "," . $SMR  . "," . $StandStructureVal . ",1,1";
	      $NFL_Record2 = $CCHigh . "," . $CCLow . "," . $HeightHigh . "," . $HeightLow;
             # $NFL_Record3 = $UnProdForLand . "," . $UnProdForLand.",".$NatNonVeg;  #	$UnProdFor;
	      $NFL_Record3 =$NatNonVeg.",".$NonVegAnth.",".$NonForVeg;
              $NFL_Record = $NFL_Record1 . "," . $NFL_Record2 . "," . $NFL_Record3;
	      print CASNFL $NFL_Record . "\n";
	    }
            #Disturbance
	    if (!isempty($Mod) && $SavMod ne ERRCODE && $SavMod ne MISSCODE) {
	      $DST_Record = $CAS_ID . "," . $Dist. ",1";
	      print CASDST $DST_Record . "\n";
	    }
	    #Ecological 
	    if ($Wetland ne MISSCODE) {
	      $Wetland = $CAS_ID . "," . $Wetland."-";
	      print CASECO $Wetland . "\n";
	    }
	  }

	
   }
 # Close csv file
  $csv->eof or $csv->error_diag ();
  close $NLinv;


	foreach my $k (sort {lc($a) cmp lc($b)} keys %$spfreq){
		$_ = $k;
		tr/a-z/A-Z/;
		my $upk = $_;
	 	print SPERRSFILE "cumulative frequency of species " ,$upk,  " is ", $spfreq->{$k},"\n";
		#print "invalid code " ,$k,  " found ", $herror{$k}," times\n";
  	}
	foreach my $k (keys %herror){
	 	print ERRS "invalid code " ,$k,  " found ", $herror{$k}," times\n";
		#print "invalid code " ,$k,  " found ", $herror{$k}," times\n";
	 }

	close (CASHDR);
	close (CASCAS);
	close (CASLYR);
	close (CASNFL);
	close (CASDST);
	close (CASECO);
	close(SPERRSFILE); close(SPECSLOGFILE); 
	close(ERRS);


}


1;
#province eq "NL";
