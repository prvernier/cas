package ModulesV4::PANP_conversion06;


use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(&PANPinv_to_CAS );
our @EXPORT_OK = qw(@tabSpec);      

#our @EXPORT_OK = qw(@tabSpec &SoilMoistureRegime1 &SoilMoistureRegime2  &CCUpper  &CCLower &StandHeightUp &StandHeightLow &UpperOrigin &UpperOriginCompl &LowerOrigin &LowerOriginCompl  &Disturbance &DisturbanceM );

use strict;
use Text::CSV;
our @tabSpec;
our $Species_table;	
use constant {
        INFTY =>-1,
        ERRCODE => -9999,
	SPECIES_ERRCODE => "XXXX ERRC",
	MISSCODE => -1111,
	UNDEF=> -8888
    };


our $Glob_CASID;
our $Glob_filename;

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
		
	if($val eq MISSCODE || $val eq ERRCODE || $val eq UNDEF) 
	{
		return 1;
	}
	else 
	{
		return 0;
	}	
}
#up to 3 cover type in both overstory and ground level layer
#Standstructure = H 

sub SoilMoistureRegime
{
	my $SoilMoistureReg;

	my ($G1SPEC) = shift(@_);  
	my ($C1SPEC) = shift(@_);  
	 
	if(isempty($G1SPEC)){$G1SPEC = MISSCODE;}
	if(isempty($C1SPEC)){$C1SPEC = MISSCODE;}

	if (($G1SPEC eq "M1") || ($G1SPEC eq "M2"))         { $SoilMoistureReg = "W"; }
	elsif (($C1SPEC eq "LL") || ($C1SPEC eq "LLBP")|| ($C1SPEC eq "BPLL"))         { $SoilMoistureReg = "W"; }
	else     { $SoilMoistureReg = MISSCODE; }     

	return $SoilMoistureReg;
}

#Determine CCUpper from Density C#DENS and U#DENS
#Also have C1PERCA, C#PERC, G1PERCA and G#PERC; these describe percent cover of up to three different cover types allowed per polgon. In 10 or 20% classes (0=0%, 2=20%, 3=30%....8=80%, 10=100%)
sub CCUpper 
{
	my $CCHigh;
	my $Density;
	my %DensityList = ("1", 1, "2", 1, "3", 1);

	($Density) = shift(@_);
	
	if (isempty($Density))            { $CCHigh = MISSCODE; }
	elsif (!$DensityList {$Density}) { $CCHigh = ERRCODE; }

	elsif (($Density eq "1"))            { $CCHigh = 29; }
	elsif (($Density eq "2"))            { $CCHigh = 59; }
	elsif (($Density eq "3"))            { $CCHigh = 100; }
	 

	return $CCHigh;
}

#Determine CCLower from Density  C#DENS
sub CCLower 
{
	my $CCLow;
	my $Density;
	my %DensityList = ("", 1, "1", 1, "2", 1, "3", 1);

	($Density) = shift(@_);
	
	if (isempty($Density))               { $CCLow = MISSCODE; }
	elsif (!$DensityList {$Density} )   { $CCLow= ERRCODE; }

	elsif (($Density eq "1"))            { $CCLow = 0; }
	elsif (($Density eq "2"))            { $CCLow = 30; }
	elsif (($Density eq "3"))            { $CCLow = 60; }

	return $CCLow;
}


#1                        0 - 6	3                       7 - 12	5                         13 - 18	7                            > 19

#Determine upper bound stand height from C1HT, C2HT, C3HT; U1HT, U2HT, U3HT
sub StandHeightUp 
{
	my $Height;
	my %HeightList = ("", 1, "0", 1, "1", 1,  "3", 1, "5", 1, "7", 1);
	my $HUpp;

	($Height) = shift(@_);
	
	if  (isempty($Height) || $Height eq "0" )                    { $HUpp = MISSCODE; }
	elsif (!$HeightList {$Height} ) { $HUpp = ERRCODE; }


	elsif (($Height eq "1"))  		  { $HUpp = 6; } 
	elsif (($Height eq "3"))                  { $HUpp = 12; } 
	elsif (($Height eq "5"))                  { $HUpp = 18; }
	elsif (($Height eq "7"))                  { $HUpp = INFTY; }	

	return $HUpp;
}

#Determine lower bound stand height from Height CHA_CO
sub StandHeightLow {
	my $Height;
	my %HeightList = ("", 1, "0", 1, "1", 1,  "3", 1, "5", 1, "7", 1);
	my $HLow;

	($Height) = shift(@_);
	

	if  (isempty($Height) || $Height eq "0")   { $HLow = MISSCODE; }
	elsif (!$HeightList {$Height} )  { $HLow = ERRCODE; }
	elsif (($Height eq "1"))  	       { $HLow = 0; } 
	elsif (($Height eq "3"))                  { $HLow = 7; } 
	elsif (($Height eq "5"))                  { $HLow = 13; }
	elsif (($Height eq "7"))                  { $HLow = 19; }	

	return $HLow;
	            		       
}


#Dertermine Latine name of species
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

		if ($Species_table->{$CurrentSpecies}) { $GenusSpecies = $Species_table->{$CurrentSpecies}; }
		else 	 {$GenusSpecies = SPECIES_ERRCODE;  print SPECSLOGFILE "Illegal species code $CurrentSpecies,CAS_ID=$Glob_CASID,file=$Glob_filename\n";  } 
	}
	return $GenusSpecies;
}

#Determine Species from the 2 species C#SPEC U#SPEC
#Note: codes 0, WATER, and ISLAND represent non forest or non vegetated cover.
sub Species
{
	my $Spec    = shift(@_);
	my $spfreq = shift(@_);

	my $Sp1Per=0;my $Sp2Per=0;my $Sp3Per=0;
	my $Sp1c=""; my $Sp2c=""; my $Sp3c="";

	my $Species;
	my $notnull=0;
	
	my $Sp1;my $Sp2;my $Sp3;

	
	my $lt = length($Spec);
	if(!isempty($Spec) && $lt >0){
		$Sp1c=(substr $Spec, 0, 2);
	}
	if(!isempty($Spec) && $lt >2){
		$Sp2c=(substr $Spec, 2, 2);
	}
	if(!isempty($Spec) && $lt >4){ 
		$Sp3c=(substr $Spec, 4, 2);
	}
 

	if($Sp1c ne "" ){$notnull++;$spfreq->{$Sp1c}++;}
	if($Sp2c ne "" ){$notnull++;$spfreq->{$Sp2c}++;}
	if($Sp3c ne "" ){$notnull++;$spfreq->{$Sp3c}++;}
	 
		if($notnull==1)
			{
					$Sp1Per=100;$Sp2Per=0;
			}
		elsif($notnull==2 && $Sp1c eq "PB" && $Sp2c eq "PM"){  
					
					$Sp1Per=60;$Sp2Per=40;		
			}
		elsif($notnull==2) {  
					$Sp1Per=70;$Sp2Per=30;
					
			}
		elsif($notnull==3) {  
					$Sp1Per=50;$Sp2Per=30;$Sp3Per=20;
					
			}
		else {print "cannot process null species\n"; exit;}
 
	$Sp1 = Latine($Sp1c); if($Sp1 eq SPECIES_ERRCODE) {return  "!!! unrecognised species 1 $Sp1c in $Spec\n"; }
	$Sp2 = Latine($Sp2c); if($Sp2 eq SPECIES_ERRCODE) {return  "!!! unrecognised species 2 $Sp2c in $Spec\n"; } 
	$Sp3 = Latine($Sp3c); if($Sp3 eq SPECIES_ERRCODE) {return  "!!! unrecognised species 3 $Sp3c in $Spec\n"; } 
				 
	$Species = $Sp1 . "," . $Sp1Per . "," . $Sp2 . "," . $Sp2Per. "," . $Sp3 . "," . $Sp3Per;
	if($Sp1Per+$Sp2Per+$Sp3Per !=100){return  "!!! invalid species percentage $Sp1Per,$Sp2Per,$Sp3Per for species --$Spec--returned value is -$Species-\n"; }

	return $Species;
}



#No Age Field. Can use C#COND and U#COND field

#Determine upper stand origin from  C#COND and U#COND
#1 = 10 yrs	2 or 2A= 10 - 30 yrs	3 or 3A= 30 - 60 yrs	4 = 60 - 80 yrs	5 or 5A = >80 yrs	

sub UpperOrigin
{
	my $Origin;
	my $OriginHigh;
	my $CodeI;
	my %OriginList = ("0", 1, "1", 1, "2", 1, "3", 1, "4", 1, "5", 1,  "1A", 1, "2A", 1, "3A", 1, "4A", 1, "5A", 1);

	($Origin) = shift(@_);
	 

	
	if  (isempty($Origin) || $Origin eq "0")                    { $OriginHigh  = MISSCODE; }
	elsif (!$OriginList {$Origin} )  { $OriginHigh =ERRCODE; }

	elsif (($Origin eq "1") || ($Origin eq "1A"))  	          { $OriginHigh = 10; }
	elsif (($Origin eq "2") || ($Origin eq "2A"))                  { $OriginHigh = 30; }
	elsif (($Origin eq "3") || ($Origin eq "3A"))                  { $OriginHigh = 60; }
	elsif (($Origin eq "4") || ($Origin eq "4A"))                  { $OriginHigh = 80; }
	elsif (($Origin eq "5") || ($Origin eq "5A"))                  { $OriginHigh = INFTY; }
	 
	return $OriginHigh;
}

#Determine lower stand origin  
sub LowerOrigin
{
	my $Origin;
	my $OriginLow;
	my $CodeI;
	my %OriginList = ("0", 1, "1", 1, "2", 1, "3", 1, "4", 1, "5", 1 , "1A", 1, "2A", 1, "3A", 1, "4A", 1, "5A", 1);
	
	($Origin) = shift(@_);
	 

	

	if  (isempty($Origin) || $Origin eq "0" )                    { $OriginLow  = MISSCODE; }
	elsif (!$OriginList {$Origin} )  { $OriginLow =ERRCODE; }
	elsif (($Origin eq "1") || ($Origin eq "1A"))  	          { $OriginLow = 0; }
	elsif (($Origin eq "2") || ($Origin eq "2A"))                  { $OriginLow = 11; }
	elsif (($Origin eq "3") || ($Origin eq "3A"))                  { $OriginLow = 31; }
	elsif (($Origin eq "4") || ($Origin eq "4A"))                  { $OriginLow = 61; }
	elsif (($Origin eq "5") || ($Origin eq "5A"))                  { $OriginLow = 81; }

	return $OriginLow;
}

 
#C#SPEC , U#SPEC   G#SPEC   
#Non Vegetated (C#SPEC, U#SPEC):     0 = OT; WATER = LA; ISLAND = IS			
#Non Vegetated Anthropogenic (G#SPEC): C = OT				
#Non Forested Vegetated (G#SPEC):   M1 = HG; M2 = SL; U1 = HG, U2 = SL				
#Non Vegetated (G#SPEC): FL = FL			
#type ::: VN=Vegetated, non forested; NW=Non vegetated water; NU=Non Vegetated, Urban/industrial; NE=Non vegetated, Exposed land; NS=Non Vegetated, Snow/Ice


sub NaturallyNonVeg
{
	my $NatNonVeg;my $NatNonVegRes;
	my %NatNonVegList = ("", 1, "WATER", 1, "ISLAND", 1, "FL", 1);

	($NatNonVeg) = shift(@_);
	
	
	if  (isempty($NatNonVeg))				{ $NatNonVegRes = MISSCODE; }
	elsif (!$NatNonVegList {$NatNonVeg} )  {  $NatNonVegRes = ERRCODE; }
	elsif (($NatNonVeg eq "0"))	{ $NatNonVegRes = "OT"; }
	elsif (($NatNonVeg eq "WATER"))	{ $NatNonVegRes = "LA"; }
	elsif (($NatNonVeg eq "ISLAND"))	{ $NatNonVegRes = "IS"; } 
	elsif (($NatNonVeg eq "FL"))	{ $NatNonVegRes = "FL"; } 
 	else 				{ $NatNonVegRes = ERRCODE; }
	return $NatNonVegRes;
}
#Anthropogenic IN, FA, CL, SE, LG, BP, OT
sub NonForestedAnth 
{
	my $NonForAnth = shift(@_);
	my %NonForAnthList = ("", 1, "C", 1, "0", 1);

	my $NonForAnthRes;

	if  (isempty($NonForAnth))				{ $NonForAnthRes = MISSCODE; }
	elsif (!$NonForAnthList {$NonForAnth} )  { $NonForAnthRes = ERRCODE; }
	elsif (($NonForAnth eq "C"))				{ $NonForAnthRes = "OT"; }
	elsif (($NonForAnth eq "0"))				{ $NonForAnthRes = "OT"; }
	else { $NonForAnthRes = ERRCODE; }
	return $NonForAnthRes;
}

#NonForestedVeg ---ST, SL, HF, HE, HG, BR, OM, TN

sub NonForestedVeg 
{
    my $NonForVeg = shift(@_);
	my %NonForVegList = ("", 1, "M1", 1, "M2", 1, "U1", 1, "U2", 1);

	my $Mod = shift(@_);
	my $NonForVegRes;

	
	if  (isempty($NonForVeg))				{ $NonForVegRes = MISSCODE; }
	elsif (!$NonForVegList {$NonForVeg} )   { $NonForVegRes = ERRCODE; }

	elsif (($NonForVeg eq "M1") || ($NonForVeg eq "U1"))	{ $NonForVegRes = "HG"; }
	elsif (($NonForVeg eq "M2") || ($NonForVeg eq "U2"))	{ $NonForVegRes = "SL"; }
	else  { $NonForVegRes = ERRCODE; }
	return $NonForVegRes;

}


#If C#SPEC and U#SPEC contain only PM and C#DENS is code 1 or 2 and C#HT is code 1 then Btnn
#If C#SPEC and U#SPEC contain only PM and C#DENS is code 3 and C#HT is code 1, 2 or 3 then Stnn

#If C#SPEC and U#SPEC contain only LL or PM and LL occur in either one of the layers (i.e. must have PM and LL in one of the layers) or PM and LL occur as mixed in either layer and C#HT code is 1 or 3 and C#DENS is code 1, 3, 5 or 7 then Ftnn
#If C#SPEC and U#SPEC contain only LL or PM and LL occur in either one of the layers (i.e. must have PM and LL in one of the layers) or PM and LL occur as mixed in either layer and C#HT code is 5 or 7 and C#DENS is code 3 then Stnn

#can derive wetland from G#SPEC field: M1 (sedge and herb) and M2 (shrub)   M1 = Fons; M2 = Sons
sub WetlandCodes 
{
	my $GSPEC = shift(@_);
	my $USpec =  shift(@_);
	my $CDens =  shift(@_);
	my $CHT =  shift(@_);
	 
	my $WetlandCode = "";
	
	 
	if(!isempty($GSPEC))
	{
		$_ = $GSPEC;tr/a-z/A-Z/; $GSPEC = $_;
	}
	else {$GSPEC="";}

	if(!isempty($USpec))
	{
		$_ = $USpec; tr/a-z/A-Z/; $USpec= $_;
	}
	else {$USpec="";}
	#$_ = $CDens; tr/a-z/A-Z/; $CDens = $_;
	#$_ = $CHT; tr/a-z/A-Z/; $CHT = $_;
	if(isempty($CDens)){$CDens=0;}
	if(isempty($CHT)){$CHT=0;}


	 if($GSPEC eq  "M1" )  
	    { $WetlandCode = "F,O,N,S,"; }
	 elsif($GSPEC eq "M2" )  
	    { $WetlandCode = "S,O,N,S,"; }
 	elsif($GSPEC eq "FL" )  
	    { $WetlandCode = "M,O,N,G,"; }

	elsif($USpec eq "PM" && ($CDens ==1 || $CDens ==2)  && $CHT ==1)  
	    { $WetlandCode = "B,T,N,N,"; }
	elsif($USpec eq "PM" && ($CDens ==3)  && ($CHT ==1  || $CHT ==2 || $CHT ==3))  
	    { $WetlandCode = "S,T,N,N,"; }

	elsif(($USpec =~ "PM" || $USpec =~ "LL" ) && ($CDens ==3)  && ($CHT ==1 || $CHT ==3))  
	    { $WetlandCode = "S,T,N,N,"; }


	elsif(($USpec =~ "PM" || $USpec =~ "LL" ) && ($CDens ==1 || $CDens ==3 || $CDens ==5 || $CDens ==7)  && ($CHT ==5 || $CHT ==7))  
	    { $WetlandCode = "S,T,N,N,"; }


	if ($WetlandCode eq "") {$WetlandCode = MISSCODE;}# MISSCODE.",".MISSCODE.",".MISSCODE.",".MISSCODE.",";
	return $WetlandCode;
	
}																																																																																																																																																																																																														
  


sub PANPinv_to_CAS
{

	my $PANP_File = shift(@_);
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
	
	my $CAS_File_HDR = $CAS_File . ".hdr";
	my $CAS_File_CAS = $CAS_File . ".cas";
	my $CAS_File_LYR = $CAS_File . ".lyr";
	my $CAS_File_NFL = $CAS_File . ".nfl";
	my $CAS_File_DST = $CAS_File . ".dst";
	my $CAS_File_ECO = $CAS_File . ".eco";

	open (ERRS, ">>$ERRFILE") || die "\n Error: Could not open $ERRFILE file!\n";
	open (SPERRSFILE, ">>$SPERRS") || die "\n Error: Could not open $SPERRS file!\n";

	open (SPECSLOGFILE, ">>$SPECSLOG") || die "\n Error: Could not open $SPECSLOG file!\n";

	if($optgroups==1){

	 	$CAS_File_HDR = $pathname."/PANPtable.hdr";
	 	$CAS_File_CAS = $pathname."/PANPtable.cas";
	 	$CAS_File_LYR = $pathname."/PANPtable.lyr";
	 	$CAS_File_NFL = $pathname."/PANPtable.nfl";
	 	$CAS_File_DST = $pathname."/PANPtable.dst";
	 	$CAS_File_ECO = $pathname."/PANPtable.eco";
	}
	elsif($optgroups==2){

	 	$CAS_File_HDR = $pathname."/CanadaInventorytable.hdr";
	 	$CAS_File_CAS = $pathname."/CanadaInventorytable.cas";
	 	$CAS_File_LYR = $pathname."/CanadaInventorytable.lyr";
	 	$CAS_File_NFL = $pathname."/CanadaInventorytable.nfl";
	 	$CAS_File_DST = $pathname."/CanadaInventorytable.dst";
	 	$CAS_File_ECO = $pathname."/CanadaInventorytable.eco";
	}

	if(($optgroups==0) || ($optgroups==1 && $nbiters==1)|| ($optgroups==2 && $TotalIT==1)){

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

	
	my $HDR_Record =  "1,PC,,Albers,NAD83,FED_GOV (Prince Albert National Park),,,,,,,,,,";
	print CASHDR $HDR_Record . "\n";
	
	}
	else 	
	{
		
		open (CASCAS, ">>$CAS_File_CAS") || die "\n Error: Could not open GROUPCAS  output file!\n";
		open (CASLYR, ">>$CAS_File_LYR") || die "\n Error: Could not open GROUPCAS layer output file!\n";
		open (CASNFL, ">>$CAS_File_NFL") || die "\n Error: Could not open GROUPCAS non-forested file!\n";
		open (CASDST, ">>$CAS_File_DST") || die "\n Error: Could not open GROUPCAS disturbance  file!\n";
		open (CASECO, ">>$CAS_File_ECO") || die "\n Error: Could not open GROUPCAS ecological  file!\n";
		open (CASHDR, ">>$CAS_File_HDR") || die "\n Error: Could not open CAS header output file!\n";
		
	}
my $CAS_ID; my $IdentifyID;my $StandID;my $MapSheetID;my $Area; my $Perimeter; 
my $pr1; my $pr2; my $pr3; my $pr4; my $pr5;
my $SMR; my $StandStructureCode;
my $StandStructureVal1; my $StandStructureVal2; my $StandStructureVal3;
my $StandStructureVal4; my $StandStructureVal5; my $StandStructureVal6;
my $CCHigh1;my $CCLow1; my $HeightHigh1; my $HeightLow1;
my $CCHigh2;my $CCLow2; my $HeightHigh2; my $HeightLow2;
my $CCHigh3;my $CCLow3; my $HeightHigh3; my $HeightLow3;
my $CCHigh4;my $CCLow4; my $HeightHigh4; my $HeightLow4;
my $CCHigh5;my $CCLow5; my $HeightHigh5; my $HeightLow5;
my $CCHigh6;my $CCLow6; my $HeightHigh6; my $HeightLow6;
my $SpeciesComp;
my $SpeciesComp1; my $SpeciesComp2;my $SpeciesComp3;my $SpeciesComp4; my $SpeciesComp5;my $SpeciesComp6;
my $SiteClass; my $SiteIndex;my $Wetland1; my $StrucVal;my $Wetland2;my $Wetland3; my $Wetland4; my $Wetland5;my $Wetland6;
my $OriginHigh1; my $OriginLow1;my $OriginHigh2; my $OriginLow2;my $OriginHigh3; my $OriginLow3;
my $OriginHigh4; my $OriginLow4;my $OriginHigh5; my $OriginLow5; my $OriginHigh6; my $OriginLow6;
my $NonForVeg1; my $NonForAnth1; my $NatNonVeg1;my $NonForVeg2; my $NonForAnth2; my $NatNonVeg2;my $NonForVeg3; my $NonForAnth3; my $NatNonVeg3;
my $NonForVeg4; my $NonForAnth4; my $NatNonVeg4;my $NonForVeg5; my $NonForAnth5; my $NatNonVeg5;my $NonForVeg6; my $NonForAnth6; my $NatNonVeg6;
    
my %herror=();
my $keys;

my $AREA1; my $AREA2; my $AREA3; my $AREA4; my $AREA5; my $AREA6;
my $CAS_Record;
#my $CAS_Record1; my $CAS_Record2; my $CAS_Record3; my $CAS_Record4; my $CAS_Record5; my $CAS_Record6; 
my $Lyr_Record41; my $LYR_Record11; my $LYR_Record21; my $LYR_Record31;
my $Lyr_Record42; my $LYR_Record12; my $LYR_Record22; my $LYR_Record32;
my $Lyr_Record43; my $LYR_Record13; my $LYR_Record23; my $LYR_Record33;
my $NFL_Record1; my $NFL_Record11; my $NFL_Record21; my $NFL_Record31; my $DST_Record; 
my $NFL_Record2; my $NFL_Record12; my $NFL_Record22; my $NFL_Record32;
my $NFL_Record3; my $NFL_Record13; my $NFL_Record23; my $NFL_Record33;
my $NFL_Record4; my $NFL_Record14; my $NFL_Record24; my $NFL_Record34;
my $NFL_Record5; my $NFL_Record15; my $NFL_Record25; my $NFL_Record35;
my $NFL_Record6; my $NFL_Record16; my $NFL_Record26; my $NFL_Record36;
my  $CC1;my $CC2; my $CC3;my  $CC4;my $CC5; my $CC6;
my $PHOTO_YEAR;

#CAS_ID	HEADER_ID	AREA	PERIMETER	FPOLY_	FPOLY_ID	PANP_ID	C1HT	C1SPEC	C1DENS	C1COND	C1PERCA	C2HT	C2SPEC	C2DENS	C2COND	C2PERC	C3HT	C3SPEC	C3DENS	C3COND	C3PERC	U1HT	U1SPEC	U1DENS	U1COND	U1PERCA	U2HT	U2SPEC	U2DENS	U2COND	U2PERC	U3HT	U3SPEC	U3DENS	U3COND	U3PERC	G1SPEC	G1PERCA	G2SPEC	G2PERC	G3SPEC	G3PERC	SA1	SA2	SA3	SA12	CTOTPERC	CLASS																																																																																																																																																																																																															

#IMPORTANT NOTICE : this inventory has 6 components, C1,C2,C3,G1,G2,G3; U# are understorey and will be ignored; G# are non forested
#my $testr = " ";
#my $IE= NaturallyNonVeg($testr);
#my $IE1=isempty($testr);
#print " result = $IE, isempty = $IE1 \n";
#exit;
	my $csv = Text::CSV_XS->new({  binary              => 1,
				sep_char => ";"   });
        open my $PANPinv, "<", $PANP_File or die " \n Error: Could not open PANP input file $PANP_File: $!";
	
	my @tfilename= split ("/", $PANP_File);
	my $nps=scalar(@tfilename);
	$Glob_filename= $tfilename[$nps-1];

 	$csv->column_names ($csv->getline ($PANPinv));

   	while (my $row = $csv->getline_hr ($PANPinv)) {	 
   		
	($pr1,$pr2,$pr3, $pr4, $pr5)     =  split("-", $row->{CAS_ID} );  
	$Glob_CASID   =  $row->{CAS_ID};
	$CAS_ID = $row->{CAS_ID}; 	    
    $MapSheetID =  UNDEF; 
	$IdentifyID = $row->{HEADER_ID};  
	# faut-t-il supprimer les 0 du d/but? si oui faire la ligne suivante, sinon la supprimer
	$StandID = $pr4;
	$StandID =~ s/^0+//;
	$Area    =  $row->{GIS_AREA};
	$Perimeter =  $row->{GIS_PERI};	
	  
	$SMR = SoilMoistureRegime($row->{G1SPEC}, $row->{C1SPEC});	
	   
	$StandStructureCode   = "H";
	$PHOTO_YEAR=1968;
	$StandStructureVal1     = $row->{C1PERCA}*10;  
 	$StandStructureVal2     =  $row->{C2PERC}*10;     
 	$StandStructureVal3     =  $row->{C3PERC}*10;  
	$StandStructureVal4     = $row->{G1PERCA}*10;  
 	$StandStructureVal5     =  $row->{G2PERC}*10;    
 	$StandStructureVal6     =  $row->{G3PERC}*10;  

	if($StandStructureVal1 >100 || $StandStructureVal1 <0) 
	{		$keys="standstructureval1"."#".$StandStructureVal1."#";
			 		$herror{$keys}++;
	}
 	if($StandStructureVal2 >100 || $StandStructureVal2 <0) 
	{		$keys="standstructureval2"."#".$StandStructureVal2."#";
			 		$herror{$keys}++;
	} 
 	if($StandStructureVal3 >100 || $StandStructureVal3 <0)  
	{		$keys="standstructureval3"."#".$StandStructureVal3."#";
			 		$herror{$keys}++;
	}
    if($StandStructureVal4 >100 || $StandStructureVal4 <0)  
	{		$keys="standstructureval4"."#".$StandStructureVal4."#";
			 		$herror{$keys}++;
	}
 	 if($StandStructureVal5 >100 || $StandStructureVal5 <0)  
	{		$keys="standstructureval5"."#".$StandStructureVal5."#";
			 		$herror{$keys}++;
	}
 	if($StandStructureVal6 >100 || $StandStructureVal6 <0)  
	{		$keys="standstructureval6"."#".$StandStructureVal6."#";
			 		$herror{$keys}++;
	}

 
	if(defined $row->{C1DENS}) {$CC1=$row->{C1DENS};} else {$CC1="";}
	if(defined $row->{C2DENS}) {$CC2=$row->{C2DENS};} else {$CC2="";}
	if(defined $row->{C3DENS}) {$CC3=$row->{C3DENS};} else {$CC3="";}

	
	if($CC1 eq "0"){$CC1="";} if($CC2 eq "0"){$CC2="";} if($CC3 eq "0"){$CC3="";}
	$CCHigh1       =  CCUpper( $CC1);  
    $CCHigh2       =  CCUpper( $CC2); 
    $CCHigh3       =  CCUpper( $CC3); 
    $CCLow1        =  CCLower( $CC1); 
    $CCLow2        =  CCLower( $CC2); 
    $CCLow3        =  CCLower( $CC3);   

	$CCHigh4	 =  $row->{G1PERCA}*10;  $CCHigh5=$row->{G2PERC}*10;  $CCHigh6=$row->{G3PERC}*10;   
	$CCLow4        =  $row->{G1PERCA}*10;  $CCLow5=$row->{G2PERC}*10; $CCLow6=$row->{G3PERC}*10;

 	if($CCHigh1 eq ERRCODE || $CCLow1 eq ERRCODE ||$CCHigh2  eq ERRCODE   || $CCLow2  eq ERRCODE || $CCHigh3  eq ERRCODE || $CCLow3  eq ERRCODE)	
 	{ 
		$keys="CrownClosure1-3"."#".$CC1."#".$CC2."#".$CC3."#";
		$herror{$keys}++;
	}

	$HeightHigh1   =  StandHeightUp( $row->{C1HT}); 
	$HeightHigh2   =  StandHeightUp( $row->{C2HT});
    $HeightHigh3   =  StandHeightUp( $row->{C3HT});
          
    $HeightLow1    =  StandHeightLow($row->{C1HT});
    $HeightLow2    =  StandHeightLow($row->{C2HT});
    $HeightLow3    =  StandHeightLow($row->{C3HT});

	if($HeightHigh1 eq ERRCODE || $HeightLow1 eq ERRCODE ||$HeightHigh2  eq ERRCODE   || $HeightLow2  eq ERRCODE || $HeightHigh3  eq ERRCODE || $HeightLow3  eq ERRCODE)
	{ 
		$keys="Heigh1to3"."#".$row->{C1HT}."#".$row->{C2HT}."#".$row->{C3HT}."#";
		$herror{$keys}++;
	}

	$HeightHigh4	=   MISSCODE; $HeightHigh5=MISSCODE; $HeightHigh6=MISSCODE; #they are non forested
	$HeightLow4	=   MISSCODE; $HeightLow5=MISSCODE; $HeightLow6=MISSCODE;

	#$SpeciesComp1="";$SpeciesComp2="";$SpeciesComp3="";
   
	if (!isempty($row->{C1SPEC}) && $row->{C1SPEC} ne "0" && $row->{C1SPEC} ne "WATER" &&  $row->{C1SPEC} ne "ISLAND") 
	{
	
		$SpeciesComp1  =  Species($row->{C1SPEC},$spfreq);
		  
		if($SpeciesComp1 =~ m/^!/)
		{
			$keys="species error ".$SpeciesComp1."#original1#".$row->{C1SPEC};
			$herror{$keys}++; 
			$SpeciesComp1="-9999,0,-9999,0,-9999,0";
		}
		$SpeciesComp1  =  $SpeciesComp1 .",XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";		
	}
	else 
	{ 
		$SpeciesComp1  =  UNDEF;
	}

 	if (!isempty($row->{C2SPEC}) && $row->{C2SPEC} ne "0" && $row->{C2SPEC} ne "WATER" &&  $row->{C2SPEC} ne "ISLAND") 
 	{

	    $SpeciesComp2  =  Species($row->{C2SPEC},$spfreq);
		if($SpeciesComp2 =~ m/^!/)
		{
			$keys="species error ".$SpeciesComp2."#original2#".$row->{C2SPEC};
			$herror{$keys}++; 
			$SpeciesComp2="-9999,0,-9999,0,-9999,0";
		}
	 	$SpeciesComp2  =  $SpeciesComp2 .",XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";	
	}
	else 
	{
		$SpeciesComp2 =  UNDEF;
	}

	if (!isempty($row->{C3SPEC}) && $row->{C3SPEC} ne "0" && $row->{C3SPEC} ne "WATER" &&  $row->{C3SPEC} ne "ISLAND") 
	{

	    $SpeciesComp3  =  Species($row->{C3SPEC},$spfreq);
		if($SpeciesComp3 =~ m/^!/)
		{
			$keys="species error ".$SpeciesComp3."#original3#".$row->{C3SPEC};
			$herror{$keys}++; 
			$SpeciesComp3="-9999,0,-9999,0,-9999,0";
		}
	 	$SpeciesComp3  =  $SpeciesComp3 .",XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";			
	}
	else 
	{ 
		$SpeciesComp3 =  UNDEF;
	}

    $OriginHigh1   =  UpperOrigin($row->{C1COND});
    $OriginHigh2   =  UpperOrigin($row->{C2COND});
    $OriginHigh3   =  UpperOrigin($row->{C3COND});
         
    $OriginLow1    =  LowerOrigin($row->{C1COND});
    $OriginLow2    =  LowerOrigin($row->{C2COND});
    $OriginLow3    =  LowerOrigin($row->{C3COND});

	if($OriginHigh1 eq ERRCODE || $OriginLow1 eq ERRCODE ||$OriginHigh2  eq ERRCODE   || $OriginLow2  eq ERRCODE || $OriginHigh3  eq ERRCODE || $OriginLow3  eq ERRCODE)
	{ 
		$keys="Origin1to3"."#".$row->{C1COND}."#".$row->{C2COND}."#".$row->{C3COND}."#";
		$herror{$keys}++;
	}

	if( ($OriginHigh1  eq MISSCODE || $OriginLow1  eq MISSCODE) && !isempty($row->{C1SPEC}) && $row->{C1SPEC} ne "0" && $row->{C1SPEC} ne "WATER" && $row->{C1SPEC} ne "ISLAND")
	{ 
		$keys="Null Origin C1COND "."#Value#".$row->{C1COND}."#species = ".$row->{C1SPEC}."#casid#".$CAS_ID;
		$herror{$keys}++;
	}

	if(($OriginHigh2  eq MISSCODE || $OriginLow2  eq MISSCODE) && !isempty($row->{C2SPEC})  && $row->{C2SPEC} ne "0" && $row->{C2SPEC} ne "WATER" && $row->{C2SPEC} ne "ISLAND")
	{ 
		$keys="Null Origin C2COND "."#Value#".$row->{C2COND}."#species = ".$row->{C2SPEC}."#casid#".$CAS_ID;
		$herror{$keys}++;
	}

	if(($OriginHigh3  eq MISSCODE || $OriginLow3  eq MISSCODE) &&  !isempty($row->{C3SPEC}) && $row->{C3SPEC} ne "0" && $row->{C3SPEC} ne "WATER" && $row->{C3SPEC} ne "ISLAND")
	{ 
		$keys="Null Origin C3COND "."#Value#".$row->{C3COND}."#species = ".$row->{C3SPEC}."#casid#".$CAS_ID;
		$herror{$keys}++;
	}
#############TURNING AGE INTO ABSOLUTE YEAR VALUE ##################ADDED ON 13th May 2012##########################
		if ($OriginHigh1 ne ERRCODE  && $OriginHigh1 ne MISSCODE ) {
			if ($OriginHigh1 ne INFTY) {$OriginHigh1 = $PHOTO_YEAR-$OriginHigh1;}
	  		$OriginLow1  = $PHOTO_YEAR-$OriginLow1;
			if ($OriginHigh1 > $OriginLow1 ) { 
							 $keys="CHEK ORIGINUPPER-"."#high1=".$OriginHigh1."#low1=".$OriginLow1;
							 $herror{$keys}++;$OriginHigh1 = MISSCODE;$OriginLow1  = MISSCODE;
			}
			my $aux1=$OriginHigh1;
			$OriginHigh1=$OriginLow1;
			$OriginLow1=$aux1;
		}
		else {
			$OriginHigh1=MISSCODE;$OriginHigh1 = MISSCODE;
		}

		if ($OriginHigh2 ne ERRCODE  && $OriginHigh2 ne MISSCODE ) {
			if ($OriginHigh2 ne INFTY) {$OriginHigh2 = $PHOTO_YEAR-$OriginHigh2;}
	  		$OriginLow2  = $PHOTO_YEAR-$OriginLow2;
			if ($OriginHigh2 > $OriginLow2 ) { 
							 $keys="CHEK ORIGINUPPER-"."#high2=".$OriginHigh2."#low2=".$OriginLow2;
							 $herror{$keys}++;$OriginHigh2 = MISSCODE;$OriginLow2  = MISSCODE;
			}
			my $aux2=$OriginHigh2;
			$OriginHigh2=$OriginLow2;
			$OriginLow2=$aux2;
		}
		else {
			$OriginHigh2=MISSCODE;$OriginHigh2 = MISSCODE;
		}

if ($OriginHigh3 ne ERRCODE  && $OriginHigh3 ne MISSCODE ) {
			if ($OriginHigh3 ne INFTY) {$OriginHigh3 = $PHOTO_YEAR-$OriginHigh3;}
	  		$OriginLow3  = $PHOTO_YEAR-$OriginLow3;
			if ($OriginHigh3 > $OriginLow3 ) { 
							 $keys="CHEK ORIGINUPPER-"."#high3=".$OriginHigh3."#low3=".$OriginLow3;
							 $herror{$keys}++;$OriginHigh3 = MISSCODE;$OriginLow3  = MISSCODE;
			}
			my $aux3=$OriginHigh3;
			$OriginHigh3=$OriginLow3;
			$OriginLow3=$aux3;
		}
		else {
			$OriginHigh3=MISSCODE;$OriginHigh3 = MISSCODE;
		}
#############      ........­­­.END  OF  TURNING AGE INTO ABSOLUTE YEAR VALUE ###########ADDED ON OCTOBER 8TH OF 2009 #####################
	  
	 if($OriginHigh1  >2014    || ($OriginHigh1  >0 && $OriginHigh1 <1700)    || $OriginLow1 >2014   || ($OriginLow1 <1700 && $OriginLow1 >0)) { 
									 $keys="invalid age1  "."#originhigh1#".$OriginHigh1."#originlow#".$OriginLow1;
						    			$herror{$keys}++;
	}
if($OriginHigh2  >2014    || ($OriginHigh2  >0 && $OriginHigh2 <1700)    || $OriginLow2 >2014   || ($OriginLow2 <1700 && $OriginLow2 >0)) { 
									 $keys="invalid age2  "."#originhigh2#".$OriginHigh2."#originlow#".$OriginLow2;
						    			$herror{$keys}++;
	}
if($OriginHigh3  >2014    || ($OriginHigh3  >0 && $OriginHigh3 <1700)    || $OriginLow3 >2014   || ($OriginLow3 <1700 && $OriginLow3 >0)) { 
									 $keys="invalid age3  "."#originhigh3#".$OriginHigh3."#originlow#".$OriginLow3;
						    			$herror{$keys}++;
	}

	  $StrucVal     =  UNDEF;
	  $SiteClass 	=  UNDEF;
	  $SiteIndex 	=  UNDEF;
       
    $Wetland1  = WetlandCodes ($row->{G1SPEC}, $row->{C1SPEC}, $row->{C1DENS}, $row->{C1HT});
 	$Wetland2 = WetlandCodes ($row->{G2SPEC}, $row->{C2SPEC}, $row->{C2DENS}, $row->{C2HT});
 	$Wetland3 = WetlandCodes ($row->{G3SPEC}, $row->{C3SPEC}, $row->{C3DENS}, $row->{C3HT});
 	$Wetland4  = WetlandCodes ($row->{G1SPEC}, $row->{C1SPEC}, $row->{C1DENS}, $row->{C1HT});
 	$Wetland5 = WetlandCodes ($row->{G2SPEC}, $row->{C2SPEC}, $row->{C2DENS}, $row->{C2HT});
 	$Wetland6 = WetlandCodes ($row->{G3SPEC}, $row->{C3SPEC}, $row->{C3DENS}, $row->{C3HT});

	# ===== Non-forested Land =====
    if(defined $row->{C1SPEC}) 
    { 
	  
		if($row->{C1SPEC} eq "0" || $row->{C1SPEC} eq "WATER" || $row->{C1SPEC} eq "ISLAND")
		{
         	$NatNonVeg1 	=  NaturallyNonVeg($row->{C1SPEC});
	  		$NonForVeg1 	=  MISSCODE;
	  		$NonForAnth1	=  NonForestedAnth($row->{C1SPEC});
	  		if(($NatNonVeg1  eq ERRCODE)  && ($NonForAnth1  eq ERRCODE))
	  		{ 
				$keys="NonForVeg1-NatNonVeg1-NonForAnth1"."#".$row->{C1SPEC}."#";  $herror{$keys}++; 
	 		}
		}
		else 
		{ 
			$NatNonVeg1=$NonForVeg1=$NonForAnth1=MISSCODE;
		}

    }
	else
	{ 
		$NatNonVeg1=$NonForVeg1=$NonForAnth1=MISSCODE;
	}

	
 	  if(defined $row->{C2SPEC}) { 
	 
		if($row->{C2SPEC} eq "0" || $row->{C2SPEC} eq "WATER" || $row->{C2SPEC} eq "ISLAND"){
			$NatNonVeg2 	=  NaturallyNonVeg($row->{C2SPEC});
			$NonForVeg2 	=   MISSCODE;
	  		$NonForAnth2	=  NonForestedAnth($row->{C2SPEC});
	  		if(($NatNonVeg2  eq ERRCODE)  &&  ($NonForAnth2  eq ERRCODE)) { 
				$keys="NonForVeg2-NatNonVeg2-NonForAnth2"."#".$row->{C2SPEC}."#";  $herror{$keys}++; 

	  		}
		}
		else { $NatNonVeg2=$NonForVeg2=$NonForAnth2=MISSCODE;}
          }
	  else { $NatNonVeg2=$NonForVeg2=$NonForAnth2=MISSCODE;}


		if(defined $row->{C3SPEC}) { 
	 
		if($row->{C3SPEC} eq "0" || $row->{C3SPEC} eq "WATER" || $row->{C3SPEC} eq "ISLAND"){
			$NatNonVeg3	=  NaturallyNonVeg($row->{C3SPEC});
			$NonForVeg3 	=   MISSCODE;
	  		$NonForAnth3	=  NonForestedAnth($row->{C3SPEC});
	  		if(($NatNonVeg3  eq ERRCODE)  &&  ($NonForAnth3  eq ERRCODE)) { 
				$keys="NonForVeg3-NatNonVeg3-NonForAnth3"."#".$row->{C3SPEC}."#";  $herror{$keys}++; 

	  		}
		}
		else { $NatNonVeg3=$NonForVeg3=$NonForAnth3=MISSCODE;}
          }
	  else { $NatNonVeg3=$NonForVeg3=$NonForAnth3=MISSCODE;}


	if(defined $row->{G1SPEC}) { 

		$NatNonVeg4 	=  NaturallyNonVeg($row->{G1SPEC});
	  	$NonForVeg4 	=  NonForestedVeg($row->{G1SPEC});
	  	$NonForAnth4	=  NonForestedAnth($row->{G1SPEC});
	  	if(($NatNonVeg4  eq ERRCODE)  &&  ($NonForVeg4  eq ERRCODE)  &&  ($NonForAnth4  eq ERRCODE)) { 
			$keys="NonForVeg4-NatNonVeg4-NonForAnth4"."#".$row->{G1SPEC}."#";  $herror{$keys}++; 

	 	 }
         }
	  else { $NatNonVeg4=$NonForVeg4=$NonForAnth4=MISSCODE;}

	if(defined $row->{G2SPEC}) { 

		$NatNonVeg5 	=  NaturallyNonVeg($row->{G2SPEC});
	  	$NonForVeg5 	=  NonForestedVeg($row->{G2SPEC});
	  	$NonForAnth5	=  NonForestedAnth($row->{G2SPEC});
	  	if(($NatNonVeg5  eq ERRCODE)  &&  ($NonForVeg5  eq ERRCODE)  &&  ($NonForAnth5  eq ERRCODE)) { 
			$keys="NonForVeg5-NatNonVeg5-NonForAnth5"."#".$row->{G2SPEC}."#";  $herror{$keys}++; 

	 	 }
         }
	  else { $NatNonVeg5=$NonForVeg5=$NonForAnth5=MISSCODE;}

	if(defined $row->{G3SPEC}) { 

		$NatNonVeg6 	=  NaturallyNonVeg($row->{G3SPEC});
	  	$NonForVeg6 	=  NonForestedVeg($row->{G3SPEC});
	  	$NonForAnth6	=  NonForestedAnth($row->{G3SPEC});
	  	if(($NatNonVeg6  eq ERRCODE)  &&  ($NonForVeg6  eq ERRCODE)  &&  ($NonForAnth6  eq ERRCODE)) { 
			$keys="NonForVeg6-NatNonVeg6-NonForAnth6"."#".$row->{G3SPEC}."#";  $herror{$keys}++; 

	 	 }
         }
	  else { $NatNonVeg6=$NonForVeg6=$NonForAnth6=MISSCODE;}


	if($NatNonVeg1 eq ERRCODE){$NatNonVeg1=MISSCODE;}  if($NatNonVeg2 eq ERRCODE){$NatNonVeg2=MISSCODE;}  if($NatNonVeg3 eq ERRCODE){$NatNonVeg3=MISSCODE;}
	if($NonForVeg1 eq ERRCODE){$NonForVeg1=MISSCODE;}  if($NonForVeg2 eq ERRCODE){$NonForVeg2=MISSCODE;}  if($NonForVeg3 eq ERRCODE){$NonForVeg3=MISSCODE;}
	if($NonForAnth1 eq ERRCODE){$NonForAnth1=MISSCODE;} if($NonForAnth2 eq ERRCODE){$NonForAnth2=MISSCODE;} if($NonForAnth3 eq ERRCODE){$NonForAnth3=MISSCODE;}

	if($NatNonVeg4 eq ERRCODE){$NatNonVeg4=MISSCODE;}  if($NatNonVeg5 eq ERRCODE){$NatNonVeg5=MISSCODE;}  if($NatNonVeg6 eq ERRCODE){$NatNonVeg6=MISSCODE;}
	if($NonForVeg4 eq ERRCODE){$NonForVeg4=MISSCODE;}  if($NonForVeg5 eq ERRCODE){$NonForVeg5=MISSCODE;}  if($NonForVeg6 eq ERRCODE){$NonForVeg6=MISSCODE;}
	if($NonForAnth4 eq ERRCODE){$NonForAnth4=MISSCODE;} if($NonForAnth5 eq ERRCODE){$NonForAnth5=MISSCODE;} if($NonForAnth6 eq ERRCODE){$NonForAnth6=MISSCODE;}
		 
	

	# ======================================================= WRITING Output inventory info IN CAS FILES =================================================================================================
	my $prod_for1="PF";
	my $lyr_poly1=1;
	if(isempty($row->{C1SPEC}) || $row->{C1SPEC} eq "0")
	{
		$SpeciesComp1="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
		if ( $CCHigh1 >= 0 || $CCLow1 >= 0  || $HeightHigh1  >=0  || $HeightLow1 >=0)
		{
			$prod_for1="PP";
		}
		else
		{
			$lyr_poly1=0;
		}
	}
	#$AREA1=$row->{AREA}/10000 * $row->{C1PERCA}/10;
	#$AREA2=$row->{AREA}/10000 * $row->{C2PERC}/10;
	#$AREA3=$row->{AREA}/10000 * $row->{C3PERC}/10;
	#$AREA4=$row->{AREA}/10000 * $row->{G1PERCA}/10;
	#$AREA5=$row->{AREA}/10000 * $row->{G2PERC}/10;
	#$AREA6=$row->{AREA}/10000 * $row->{G3PERC}/10;


 	#component 1


	#if($row->{C1PERCA} ne "0") {


        $CAS_Record = $CAS_ID . "," . $StandID .  "," . $StandStructureCode . ",6," . $IdentifyID . "," . $MapSheetID . "," . $Area . "," . $Perimeter . ",". $Area . ",".$PHOTO_YEAR;
	   	print CASCAS $CAS_Record . "\n";
  		$nbpr=1;$$ncas++;$ncasprev++;
           
        if ($lyr_poly1 == 1 && $SpeciesComp1 ne UNDEF) 
        {
	     	$LYR_Record11 = $row->{CAS_ID} . "," . $SMR  ."," . $StandStructureVal1 . ",1,1";
	    	$LYR_Record21 = $CCHigh1 . "," . $CCLow1 . "," . $HeightHigh1 . "," . $HeightLow1 . "," . $prod_for1.",".$SpeciesComp1;
	     	$LYR_Record31 = $OriginHigh1 . "," . $OriginLow1 . "," . $SiteClass . "," . $SiteIndex;
	      	$Lyr_Record41 = $LYR_Record11 . "," . $LYR_Record21 . "," . $LYR_Record31;
	      	print CASLYR $Lyr_Record41 . "\n";
			$nbpr++; $$nlyr++;$nlyrprev++;
		}
        elsif(($NatNonVeg1 ne MISSCODE || $NonForAnth1 ne MISSCODE || $NonForVeg1 ne MISSCODE) && $StandStructureVal1 >0)
        { 
            $NFL_Record11 = $row->{CAS_ID} . "," . $SMR . "," . $StandStructureVal1 . ",1,1";
            $NFL_Record21 = $CCHigh1 . "," . $CCLow1 . "," . $HeightHigh1 . "," . $HeightLow1;
            $NFL_Record31 = $NatNonVeg1 . "," . $NonForAnth1 . "," . $NonForVeg1;
            $NFL_Record1 = $NFL_Record11 . "," . $NFL_Record21 . "," . $NFL_Record31;
            print CASNFL $NFL_Record1 . "\n";
			$nbpr++;$$nnfl++;$nnflprev++;
		}
            

            #component  2
		my $prod_for2="PF";
		my $lyr_poly2=1;
		if(isempty($row->{C2SPEC}) || $row->{C2SPEC} eq "0")
		{
			$SpeciesComp2="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
			if ( $CCHigh2 >= 0 || $CCLow2 >=0  || $HeightHigh2 >=0  || $HeightLow2 >=0)
			{
				$prod_for2="PP";
			}
			else
			{
				$lyr_poly2=0;
			}
		}

		# $CAS_Record2 = $row->{CAS_ID} . "," . $row->{FPOLY_}. "," . $row->{FPOLY_ID}. "," . $row->{HEADER_ID} . "," . $AREA2 . "," . $row->{PERIMETER}. ",". $AREA2 . ",".MISSCODE. ",".MISSCODE;
		# print CASCAS $CAS_Record2 . "\n";

        if ($lyr_poly2==1 && $SpeciesComp2 ne UNDEF) 
        {
		    $LYR_Record12 = $row->{CAS_ID} . "," . $SMR . "," . $StandStructureVal2 . ",2,2";
		    $LYR_Record22 = $CCHigh2 . "," . $CCLow2 . "," . $HeightHigh2 . "," . $HeightLow2 . "," . $prod_for2.",".$SpeciesComp2;
		    $LYR_Record32 = $OriginHigh2 . "," . $OriginLow2 . "," . $SiteClass . "," . $SiteIndex;
		    $Lyr_Record42 = $LYR_Record12 . "," . $LYR_Record22 . "," . $LYR_Record32;
		    print CASLYR $Lyr_Record42 . "\n";
			if($nbpr==1){$nbpr++; $$nlyr++;$nlyrprev++;}
		}
        elsif(($NatNonVeg2 ne MISSCODE || $NonForAnth2 ne MISSCODE || $NonForVeg2 ne MISSCODE)&& $StandStructureVal2 >0) 
        { 
            $NFL_Record12 = $row->{CAS_ID} . "," . $SMR  . "," . $StandStructureVal2 . ",2,2";
            $NFL_Record22 = $CCHigh2 . "," . $CCLow2 . "," . $HeightHigh2 . "," . $HeightLow2;
            $NFL_Record32 = $NatNonVeg2 . "," . $NonForAnth2 . "," . $NonForVeg2;
            $NFL_Record2 = $NFL_Record12 . "," . $NFL_Record22 . "," . $NFL_Record32;
            print CASNFL $NFL_Record2 . "\n";
			if($nbpr==1){$nbpr++;$$nnfl++;$nnflprev++;}
	   	}
            	
		#component  3
		my $prod_for3="PF";
		my $lyr_poly3=1;
		if(isempty($row->{C3SPEC}) || $row->{C3SPEC} eq "0")
		{
			$SpeciesComp3="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
			if ( $CCHigh3 >= 0 || $CCLow3 >=0  || $HeightHigh3 >=0  || $HeightLow3 >=0)
			{
				$prod_for3="PP";
			}
			else
			{
				$lyr_poly3=0;
			}
		}

	   # $CAS_Record3 = $row->{CAS_ID} . "," . $row->{FPOLY_}. "," . $row->{FPOLY_ID}. "," . $row->{HEADER_ID} . "," . $AREA3 . "," . $row->{PERIMETER}. ",". $AREA3 . ",".MISSCODE. ",".MISSCODE;
	   #  print CASCAS $CAS_Record3 . "\n";

        if ($lyr_poly3==1 && $SpeciesComp3 ne UNDEF) 
        {
		    $LYR_Record13 = $row->{CAS_ID} . "," . $SMR  .  "," . $StandStructureVal3 . ",3,3";
		    $LYR_Record23 = $CCHigh3 . "," . $CCLow3 . "," . $HeightHigh3 . "," . $HeightLow3 . "," .$prod_for3.",". $SpeciesComp3;
		    $LYR_Record33 = $OriginHigh3 . "," . $OriginLow3 . "," . $SiteClass . "," . $SiteIndex;
		    $Lyr_Record43 = $LYR_Record13 . "," . $LYR_Record23 . "," . $LYR_Record33;
		    print CASLYR $Lyr_Record43 . "\n";
			if($nbpr==1){$nbpr++; $$nlyr++;$nlyrprev++;}
		}
        elsif(($NatNonVeg3 ne MISSCODE || $NonForAnth3 ne MISSCODE || $NonForVeg3 ne MISSCODE)&& $StandStructureVal3 >0) 
        { 
            $NFL_Record13 = $row->{CAS_ID} . "," . $SMR  .  "," . $StandStructureVal3 . ",3,3";
            $NFL_Record23 = $CCHigh3 . "," . $CCLow3 . "," . $HeightHigh3 . "," . $HeightLow3;
            $NFL_Record33 = $NatNonVeg3 . "," . $NonForAnth3 . "," . $NonForVeg3;
            $NFL_Record3 = $NFL_Record13 . "," . $NFL_Record23 . "," . $NFL_Record33;
            print CASNFL $NFL_Record3 . "\n";
			if($nbpr==1){$nbpr++;$$nnfl++;$nnflprev++;}
	    }


        #component  4

	    # $CAS_Record4 = $row->{CAS_ID} . "," . $row->{FPOLY_}. "," . $row->{FPOLY_ID}. "," . $row->{HEADER_ID} . "," . $AREA4 . "," . $row->{PERIMETER}. ",". $AREA4 . ",".MISSCODE. ",".MISSCODE;
	    #  print CASCAS $CAS_Record4 . "\n";

        if ((!isempty($row->{G1SPEC}) && ($NatNonVeg4 ne MISSCODE || $NonForAnth4 ne MISSCODE || $NonForVeg4 ne MISSCODE)) && $StandStructureVal4 >0) 
        {
	     
         	$NFL_Record14 = $row->{CAS_ID} . "," . $SMR . "," . $StandStructureVal4 . ",4,4";
          	$NFL_Record24 = $CCHigh4 . "," . $CCLow4 . "," . $HeightHigh4 . "," . $HeightLow4;
            $NFL_Record34 = $NatNonVeg4 . "," . $NonForAnth4 . "," . $NonForVeg4;
            $NFL_Record4 = $NFL_Record14 . "," . $NFL_Record24 . "," . $NFL_Record34;
            print CASNFL $NFL_Record4 . "\n";
		  	if($nbpr==1){$nbpr++;$$nnfl++;$nnflprev++;}
	    }
           
	    #component  5

	    # $CAS_Record5 = $row->{CAS_ID} . "," . $row->{FPOLY_}. "," . $row->{FPOLY_ID}. "," . $row->{HEADER_ID} . "," . $AREA5 . "," . $row->{PERIMETER}. ",". $AREA5 . ",".MISSCODE. ",".MISSCODE;
	    # print CASCAS $CAS_Record5 . "\n";

        if ((!isempty($row->{G2SPEC})  && ($NatNonVeg5 ne MISSCODE || $NonForAnth5 ne MISSCODE || $NonForVeg5 ne MISSCODE)) && $StandStructureVal5 >0)
        {
         	$NFL_Record15 = $row->{CAS_ID} . "," . $SMR . "," . $StandStructureVal5 . ",5,5";
          	$NFL_Record25 = $CCHigh5 . "," . $CCLow5 . "," . $HeightHigh5 . "," . $HeightLow5;
            $NFL_Record35 = $NatNonVeg5 . "," . $NonForAnth5 . "," . $NonForVeg5;
            $NFL_Record5 = $NFL_Record15 . "," . $NFL_Record25 . "," . $NFL_Record35;
            print CASNFL $NFL_Record5 . "\n";
		  	if($nbpr==1){$nbpr++;$$nnfl++;$nnflprev++;}
	    }
            
	    #component  6
	    #  $CAS_Record6 = $row->{CAS_ID} . "," . $row->{FPOLY_}. "," . $row->{FPOLY_ID}. "," . $row->{HEADER_ID} . "," . $AREA6 . "," . $row->{PERIMETER}. ",". $AREA6 . ",".MISSCODE. ",".MISSCODE;
	    #print CASCAS $CAS_Record6 . "\n";

		if ((!isempty($row->{G3SPEC})  && ($NatNonVeg6 ne MISSCODE || $NonForAnth6 ne MISSCODE || $NonForVeg6 ne MISSCODE))&& $StandStructureVal6 >0) 
		{
	        $NFL_Record16 = $row->{CAS_ID} . "," . $SMR  . "," . $StandStructureVal6 . ",6,6";
	        $NFL_Record26 = $CCHigh6 . "," . $CCLow6 . "," . $HeightHigh6 . "," . $HeightLow6;
	        $NFL_Record36 = $NatNonVeg6 . "," . $NonForAnth6 . "," . $NonForVeg6;
	        $NFL_Record6 = $NFL_Record16 . "," . $NFL_Record26 . "," . $NFL_Record36;
	        print CASNFL $NFL_Record6 . "\n";
			if($nbpr==1){$nbpr++;$$nnfl++;$nnflprev++;}
		}
	    

		#Disturbance  is UNDEF
		
		#Ecological, which layer for other info

		if ($Wetland1 ne MISSCODE && $Wetland1 ne ERRCODE) 
		{
		      $Wetland1 = $row->{CAS_ID} . "," . $Wetland1. "1";
		      print CASECO $Wetland1 . "\n";
			if($nbpr==1) {$$necoonly++;$necoonlyprev++;}
			$nbpr++;$$neco++;$necoprev++;
		}
		  # if ($Wetland2 ne MISSCODE && $Wetland2 ne ERRCODE) {
		    #  $Wetland2 = $row->{CAS_ID} . "," . $Wetland2. "2";
		   #   print CASECO $Wetland2 . "\n";
		   # }
		   # if ($Wetland3 ne MISSCODE && $Wetland3 ne ERRCODE) {
		   #   $Wetland3 = $row->{CAS_ID} . "," . $Wetland3. "3";
		   #   print CASECO $Wetland3. "\n";
		   # }
		   #if ($Wetland4 ne MISSCODE && $Wetland4 ne ERRCODE) {
		   #  $Wetland4 = $row->{CAS_ID} . "," . $Wetland4. "4";
		   #  print CASECO $Wetland4 . "\n";
		   #}
		   #if ($Wetland5 ne MISSCODE && $Wetland5 ne ERRCODE) {
		   #   $Wetland5 = $row->{CAS_ID} . "," . $Wetland5. "5";
		   #   print CASECO $Wetland5 . "\n";
		   #  }
		   # if ($Wetland6 ne MISSCODE && $Wetland6 ne ERRCODE) {
		   #   $Wetland6 = $row->{CAS_ID} . "," . $Wetland6. "6";
		   #   print CASECO $Wetland6. "\n";
		   # }
		if($nbpr ==1 )
		{
			$ndrops++;
			#if($Sp1 eq ""  &&  $Wetland eq  MISSCODE && $Mod1 eq "") {
			#$keys ="MAY  DROP THIS>>>-inversion=$invstd,=nfordesc=".$Nfor_desc."-npdesc=".$NPdesc."-nonveg=".$NonVeg."landclass=$LandCoverClassCode";
			#$herror{$keys}++; 
			#}
			#else {
			#	$keys ="!!! record may be dropped#"."inversion=$invstd,specs=".$Sp1."nfordesc".$Nfor_desc."-npdesc=".$NPdesc."-nonveg=".$NonVeg."landclass=$LandCoverClassCode"."mod1".$Mod1;
			#$herror{$keys}++; 
			#$keys ="#droppable#";
			#$herror{$keys}++; 
			#}
		}
    }	 
	$csv->eof or $csv->error_diag ();
	close $PANPinv;

  	foreach my $k (keys %herror)
  	{
	 	print ERRS "invalid code " ,$k,  " found ", $herror{$k}," times\n";
		#print "invalid code " ,$k,  " found ", $herror{$k}," times\n";
  	}
	foreach my $k (sort {lc($a) cmp lc($b)} keys %$spfreq)
	{
		$_ = $k;
		tr/a-z/A-Z/;
		my $upk = $_;
	 	print SPERRSFILE "cumulative frequency of species " ,$upk,  " is ", $spfreq->{$k},"\n";
		#print "invalid code " ,$k,  " found ", $herror{$k}," times\n";
  	}

	close (CASHDR);
	close (CASCAS);
	close (CASLYR);
	close (CASNFL);
	close (CASDST);
	close (CASECO);
	close(ERRS);	 
	close(SPERRSFILE);close(SPECSLOGFILE); 
	$total=$nlyrprev+ $nnflprev+  $ndstprev;
	$total2=$nlyrprev+ $nnflprev+  $ndstonlyprev + $necoonlyprev;
	print " ndrops =$ndrops, nb records in casfile : $ncasprev, lyrfile : $nlyrprev, nflfile : $nnflprev,  dstfile : $ndstprev($ndstonlyprev), ecofile : $necoprev($necoonlyprev)--- total (without .cas): $total($total2)\n";
}
1;
#province eq "PANP";

