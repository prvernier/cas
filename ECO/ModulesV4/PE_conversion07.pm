package ModulesV4::PE_conversion07;


use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(&PEinv_to_CAS );
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


use Cwd;
use Text::CSV; 
our $Species_table;	

our $Glob_CASID;
our $Glob_filename;

sub isempty
{

	my $val = shift(@_);
	$val =~ s/\s//g;

	if($val eq "" || $val eq "NULL") 
	{
		return 1;
	}
	else 
	{
		return 0;
	}	
}

sub is_missing
{

	my $val = shift(@_);
	if($val eq MISSCODE || $val eq ERRCODE || $val eq UNDEF) 
	{
		return 1;
	}
	else 
	{
		return 0;
	}	
}
#SoilMoistureRegime is not defined for this inventory

#Determine StandStructure is S beacuase the understory is not descriebed

 

#Determine CCUpper from Density  CC  
#pre-2006
sub CCUpper 
{
	my $CCHigh;
	my $Density;
	my %DensityList = ("", 1, "A", 1, "B", 1, "C", 1, "D", 1,  "E", 1, "F", 1, "G", 1, "H", 1, "I", 1, "J", 1);

	($Density) = shift(@_);
	

	if (isempty($Density))               { $CCHigh = MISSCODE; }
	elsif (($Density eq "A") )           { $CCHigh = 100; }
	elsif (($Density eq "B") )           { $CCHigh = 90; }
	elsif (($Density eq "C"))            { $CCHigh = 80; }
	elsif (($Density eq "D"))            { $CCHigh = 70; }
	elsif (($Density eq "E") )           { $CCHigh = 60; }
	elsif (($Density eq "F") )           { $CCHigh = 50; }
	elsif (($Density eq "G"))            { $CCHigh = 40; }
	elsif (($Density eq "H"))            { $CCHigh = 30; }
	elsif (($Density eq "I"))            { $CCHigh = 20; }
	elsif (($Density eq "J"))            { $CCHigh = 10; }
	else {$CCHigh = ERRCODE; }
	return $CCHigh;
}

#Determine CCLower from Density  CC
#0-5	6-10	11-15	16-20	21-25	26-30	31-35	36-40	41-45	46-50	51-55	56-60	61-70	71-75	76-80	81-85	86-91	91-95	96-100

sub CCLower 
{
	my $CCLow;
	my $Density;
	my %DensityList = ("", 1, "A", 1, "B", 1, "C", 1, "D", 1,  "E", 1, "F", 1, "G", 1, "H", 1, "I", 1, "J", 1);

	($Density) = shift(@_);
	
	if (isempty($Density))               { $CCLow = MISSCODE; }
	elsif (($Density eq "A"))            { $CCLow = 91; }
	elsif (($Density eq "B"))            { $CCLow = 81; }
	elsif (($Density eq "C"))            { $CCLow = 71; }
	elsif (($Density eq "D"))            { $CCLow = 61; }
	elsif (($Density eq "E"))            { $CCLow = 51; }
	elsif (($Density eq "F"))            { $CCLow = 41; }
	elsif (($Density eq "G"))            { $CCLow = 31; }
	elsif (($Density eq "H"))            { $CCLow = 21; }
	elsif (($Density eq "I"))            { $CCLow = 11; }
	elsif (($Density eq "J"))            { $CCLow = 1; }
	else {$CCLow = ERRCODE; }
	return $CCLow;
}


#Dertermine Latine name of species  
sub Latine 
{
	my $CurrentSpecies = shift(@_);
	my $GenusSpecies;

	$_ = $CurrentSpecies;
	tr/a-z/A-Z/;
	$CurrentSpecies = $_;
	$CurrentSpecies =~ s/\s//g;

	if (isempty($CurrentSpecies))   { $GenusSpecies = "XXXX MISS"; }

	elsif ($Species_table->{$CurrentSpecies}) { $GenusSpecies = $Species_table->{$CurrentSpecies}; }
	#elsif ($CurrentSpecies eq "AG" || $CurrentSpecies eq "BO" || $CurrentSpecies eq "BR" ||$CurrentSpecies eq "CC") { $GenusSpecies = SPECIES_ERRCODE; }
	#elsif ($CurrentSpecies eq "CL" || $CurrentSpecies eq "EP" || $CurrentSpecies eq "FL" ||$CurrentSpecies eq "PL") { $GenusSpecies = SPECIES_ERRCODE; }
	#elsif ($CurrentSpecies eq "PN" || $CurrentSpecies eq "RD" || $CurrentSpecies eq "RN" ||$CurrentSpecies eq "RR") { $GenusSpecies = SPECIES_ERRCODE; }
	#elsif ($CurrentSpecies eq "SD" || $CurrentSpecies eq "SO" || $CurrentSpecies eq "UR" ||$CurrentSpecies eq "WF"||$CurrentSpecies eq "WW") { $GenusSpecies = SPECIES_ERRCODE; }
	else 	 {$GenusSpecies = SPECIES_ERRCODE;  print SPECSLOGFILE "Illegal species code $CurrentSpecies, CAS_ID=$Glob_CASID, file=$Glob_filename\n";  }  
	return $GenusSpecies;
}


#Determine Species from the cover class field
sub Species
{
	my $Sp1    = shift(@_);
	my $Sp1Per = shift(@_);
	my $Sp2    = shift(@_);
	my $Sp2Per = shift(@_);
	my $Sp3    = shift(@_);
	my $Sp3Per = shift(@_);
	my $Sp4    = shift(@_);
	my $Sp4Per = shift(@_);
	my $Sp5    = shift(@_);
	my $Sp5Per = shift(@_);
	#my $spfreq = shift(@_);

	my $Species;
	my $CurrentSpec;
	my $spper1=$Sp1Per*10;my $spper2=$Sp2Per*10;my $spper3=$Sp3Per*10;my $spper4=$Sp4Per*10;my $spper5=$Sp5Per*10;

	#$spfreq->{$Sp1}++;
	#$spfreq->{$Sp2}++;
	#$spfreq->{$Sp3}++;
	#$spfreq->{$Sp4}++;
	#$spfreq->{$Sp5}++;

	$Sp1 = Latine($Sp1); $Sp2 = Latine($Sp2); $Sp3 = Latine($Sp3); $Sp4 = Latine($Sp4); $Sp5 = Latine($Sp5); 
	#$Species = $Sp1 . "," . $Sp1Per . "," . $Sp2 . "," . $Sp2Per . "," . $Sp3 . "," . $Sp3Per . "," . $Sp4 . "," . $Sp4Per . "," . $Sp5 . "," . $Sp5Per;
	$Species = $Sp1 . "," . $spper1 . "," . $Sp2 . "," . $spper2 . "," . $Sp3 . "," . $spper3 . "," . $Sp4 . "," . $spper4 . "," . $Sp5 . "," . $spper5 ;

	return $Species;
}

#Age is not defined for PE
#Natnonveg ==== AP, LA, RI, OC, RK, SD, SI, SL, EX, BE, WS, FL, IS, TF
#bo=TM	al=ST	so=SL	cl=OT	cln=OT	ag=CL	gp=IN	rc=FA	sd=SD	Lake=LA	Pond=LA
#BAR=EX	BSB=BE	BLD=OT	WWW=OC	GRS=HG	PAV=FA	SHR=SL	TRE=OT	WAT=LA		

#Natnonveg ==== AP, LA, RI, OC, RK, SA, SI, SL, EX, BE, WS, FL, IS, TF
sub NaturallyNonVeg 
{
	my $NatNonVeg; my $ClassMod;

	my %NatNonVegList = ("", 1, "BO", 1, "AL", 1, "GRS", 1,  "CL", 1, "CLN", 1, "GP", 1, "RC", 1, "AG", 1, "TRE", 1, "BLD", 1,  "SO", 1, "SD", 1, "LAKE", 1, "POND", 1, "BAR", 1, "BSB", 1, "WWW", 1, "SHR", 1, "WAT", 1, "WW", 1,  "RN", 1,  "CC", 1,  "FL", 1, "UR", 1, "BR", 1,"PL", 1, "RD", 1, "RR", 1, "PN", 1, "WF", 1);
	
	($NatNonVeg) = shift(@_);
	
	#if ($NatNonVegList {$NatNonVeg} ) { } else { $NatNonVeg = ERRCODE; }

	if  (isempty($NatNonVeg))	{ $NatNonVeg = MISSCODE; }
	elsif (($NatNonVeg eq "SO") )	{ $NatNonVeg = "SL"; }
	elsif (($NatNonVeg eq "SD"))	{ $NatNonVeg = "SA"; }
	elsif (($NatNonVeg eq "LAKE") || ($NatNonVeg eq "POND"))	{ $NatNonVeg = "LA"; }
	elsif (($NatNonVeg eq "BAR") )	{ $NatNonVeg = "EX"; } #|| ($NatNonVeg eq "BR")
	elsif (($NatNonVeg eq "BSB"))	{ $NatNonVeg = "BE"; }
	elsif (($NatNonVeg eq "WWW"))	{ $NatNonVeg = "OC"; }
	elsif (($NatNonVeg eq "SHR"))	{ $NatNonVeg = "SL"; }
	elsif (($NatNonVeg eq "WAT"))	{ $NatNonVeg = "LA"; }
	elsif (($NatNonVeg eq "WW"))	{ $NatNonVeg = "LA"; }
	elsif (($NatNonVeg eq "FL"))	{ $NatNonVeg = "FL"; }
	else { $NatNonVeg =  ERRCODE; }
	return $NatNonVeg;

	
}

#Anthropogenic IN, FA, CL, SE, LG, BP, OT
#bo=TM	al=ST	so=SL	cl=OT	cln=OT	ag=CL	gp=IN	rc=FA	sd=SD	Lake=LA	Pond=LA
sub NonForestedAnth 
{
	my $NonForAnth;   
	my %NonForAnthList = ("", 1, "BO", 1, "AL", 1, "GRS", 1,  "CL", 1, "CLN", 1, "GP", 1, "RC", 1, "AG", 1, "TRE", 1, "BLD", 1,  "SO", 1, "SD", 1, "LAKE", 1, "POND", 1, "BAR", 1, "BSB", 1, "WWW", 1, "SHR", 1, "WAT", 1,  "RN", 1,  "CC", 1,  "FL", 1,  "UR", 1, "BR", 1,"PL", 1, "RD", 1, "RR", 1, "PN", 1, "EP", 1, "WF", 1);


	($NonForAnth) = shift(@_);
	 
	#if ($NonForAnthList {$NonForAnth} ) { } else { $NonForAnth = ERRCODE; }

	if  (isempty($NonForAnth))					{ $NonForAnth = MISSCODE; }
	#elsif (($NonForAnth  eq "CL") || ($NonForAnth  eq "CLN")|| ($NonForAnth  eq "TRE") || ($NonForAnth  eq "BLD")|| ($NonForAnth  eq "PN"))	{ $NonForAnth  = "OT"; }  #($NonForAnth  eq "CC") ||  || ($NonForAnth  eq "WF")
	elsif (($NonForAnth  eq "CL") || ($NonForAnth  eq "CLN")|| ($NonForAnth  eq "TRE") || ($NonForAnth  eq "BLD") || ($NonForAnth  eq "WF"))	{ $NonForAnth  = "OT"; }  #($NonForAnth  eq "CC") || || ($NonForAnth  eq "PN")
	elsif (($NonForAnth  eq "GP"))	{ $NonForAnth  = "IN"; }
	#elsif (($NonForAnth  eq "RC")|| ($NonForAnth  eq "PAV"))	{ $NonForAnth  = "FA"; } #($NonForAnth  eq "PL")|| || ($NonForAnth  eq "RN") 
	elsif (($NonForAnth  eq "PL") || ($NonForAnth  eq "RC")|| ($NonForAnth  eq "PAV")|| ($NonForAnth  eq "RN") )	{ $NonForAnth  = "FA"; } #
	elsif ( ($NonForAnth  eq "RD")|| ($NonForAnth  eq "RR") )	{ $NonForAnth  = "FA"; }
	elsif (($NonForAnth  eq "AG") )	{ $NonForAnth  = "CL"; }
	elsif (($NonForAnth  eq "UR") )	{ $NonForAnth  = "SE"; }
	#elsif (($NonForAnth  eq "EP") )	{ $NonForAnth  = "BP"; }
	elsif (($NonForAnth  eq "EP") )	{ $NonForAnth  = "BP"; }
	else { $NonForAnth  =   ERRCODE; }
	#return $Type_lnd.",".$NonForAnth;
	return $NonForAnth;
}

#EP excavation pit*************IN NO Use BP
#SD sand dune***********SD NO Use SA
#SO swamp************SL NO:  HG (and see wetland rules, below)
#SW bog                      BR (and see wetland rules, below		
#NonForestedVeg ---ST, SL, HF, HE, HG, BR, OM, TN
#Determine Non-forested vegetation stands
sub NonForestedVeg 
{
	my $NonForVeg;  my $ClassMod;
	my %NonForVegList = ("", 1, "BO", 1, "AL", 1, "GRS", 1,  "CL", 1, "CLN", 1, "GP", 1, "RC", 1, "AG", 1, "TRE", 1, "BLD", 1,  "SO", 1, "SD", 1, "LAKE", 1, "POND", 1, "BAR", 1, "BSB", 1, "WWW", 1, "SHR", 1, "WAT", 1, "RN", 1,  "CC", 1,  "FL", 1, "UR", 1, "BR", 1,"PL", 1, "RD", 1, "RR", 1, "PN", 1, "EP", 1, "WF", 1);

	($NonForVeg) = shift(@_);
	
	#if ($NonForVegList {$NonForVeg} ) { } else { $NonForVeg = ERRCODE; }

	if  (isempty($NonForVeg))					{ $NonForVeg = MISSCODE; }
	elsif (($NonForVeg eq "AL"))	{ $NonForVeg = "ST";}
	elsif (($NonForVeg eq "GRS")||($NonForVeg eq "HG"))	{ $NonForVeg = "HG"; }
	#elsif (($NonForVeg eq "SW"))	{ $NonForVeg = "BR";}
	elsif (($NonForVeg eq "SW"))	{ $NonForVeg = "BR";}
	else { $NonForVeg =  ERRCODE; }
	return $NonForVeg;

}
 
#UnProdForest TM, TR, AL, SD, SC, NP,  P

sub UnProdForest 
{
    my $NonForVeg = shift(@_);
	my %NonForVegList = ("", 1, "BO", 1, "AL", 1, "GRS", 1,  "CL", 1, "CLN", 1, "GP", 1, "RC", 1, "AG", 1, "TRE", 1, "BLD", 1,  "SO", 1, "SD", 1, "LAKE", 1, "POND", 1, "BAR", 1, "BSB", 1, "WWW", 1, "SHR", 1, "WAT", 1 ,"RN", 1,  "CC", 1,  "FL", 1, "UR", 1, "BR", 1,"PL", 1, "RD", 1, "RR", 1, "PN", 1, "EP", 1, "WF", 1);

	#if ($NonForVegList {$NonForVeg} ) { }  else { $NonForVeg = ERRCODE; }

	if  (isempty($NonForVeg))	{ $NonForVeg = MISSCODE; }
	elsif (($NonForVeg eq "BO"))	{ $NonForVeg = "TM"; }
	else { $NonForVeg =  ERRCODE; }
	return $NonForVeg;
}

#Determine Disturbance from disturbance, history1, history2
#BR=BU	WF=WF	PC=PC	PL=PC	PP=PC	CC=CO	DI=DI								
#BR=BU	WF=WF	CC=CO	PL=PC	HR=OT	IT=OT								PN, SE, TH, XS = SI	
#ST=PC FL=FL

sub Disturbance 
{
	my $ModCode;my $ModCode1="";
	my $ModCodeFull;
	my $Mod;my $Mod1;
	my $ModYr;
	my $Disturbance;
	my $Extent=UNDEF.",".UNDEF;
   	my $n;

	($ModCodeFull) = shift(@_);
	$ModYr = UNDEF;
	$Mod1 = ERRCODE;
	$Mod = ERRCODE;  
	if (isempty($ModCodeFull)){$Mod = MISSCODE; }
	else 
	{

		$n = length($ModCodeFull);
		$ModCode = (substr $ModCodeFull, ($n-2));
	
		if (($ModCode  eq "BR")) { $Mod="BU"; }
		elsif (($ModCode  eq "WF")) { $Mod="WF"; }
		elsif (($ModCode  eq "CC")) { $Mod="CO"; }
		elsif (($ModCode  eq "FL")) { $Mod="FL"; }
		elsif (($ModCode  eq "DI")) { $Mod="DI"; }
		elsif (($ModCode eq "EP") ||  ($ModCode eq "OF")||  ($ModCode eq "HR")||  ($ModCode eq "IT")) { $Mod="OT"; }
		elsif (($ModCode  eq "RN") || ($ModCode eq "SD")|| ($ModCode eq "SY") ||  ($ModCode eq "UR")||  ($ModCode eq "SW")) { $Mod="OT";}
		elsif (($ModCode  eq "E") || ($ModCode  eq "PN") ||($ModCode  eq "TH")|| ($ModCode  eq "SE") ||($ModCode  eq "XS")) { $Mod="SI";}
		elsif (($ModCode eq "RC")|| ($ModCode eq "PC")|| ($ModCode eq "PL") || ($ModCode eq "PP")|| ($ModCode eq "ST")) { $Mod="PC";}

		else { $Mod=ERRCODE;}

		if($n >2 && $Mod eq ERRCODE)
		{
			$ModCode1=(substr $ModCodeFull, 0, 2);
			if (($ModCode1  eq "BR")) { $Mod1="BU"; }
			elsif (($ModCode1  eq "WF")) { $Mod1="WF"; }
			elsif (($ModCode1  eq "CC")) { $Mod1="CO"; }
			elsif (($ModCode1  eq "FL")) { $Mod1="FL"; }
			elsif (($ModCode1  eq "DI")) { $Mod1="DI"; }
			elsif (($ModCode1 eq "EP") ||  ($ModCode1 eq "OF")||  ($ModCode1 eq "HR")||  ($ModCode1 eq "IT")) { $Mod1="OT"; }
			elsif (($ModCode1 eq "PC") || ($ModCode1 eq "PL") || ($ModCode1 eq "PP") ) { $Mod1="PC";}
			elsif ( ($ModCode1 eq "SW")) { $Mod1="OT";}
			elsif (  ($ModCode1  eq "PN")||($ModCode1  eq "TH")||($ModCode1  eq "SE")||($ModCode1  eq "XS")) { $Mod1="SI";}
			else { $Mod1=ERRCODE;}
		}
	}

	if($Mod ne ERRCODE)
	{
		$Disturbance = $Mod . "," . $ModYr. "," . $Extent; 
	}
	else	
	{
		$Disturbance = $Mod1 . "," . $ModYr. "," . $Extent; 
	}

	return $Disturbance;
}


sub WetlandCodes 
{
	my $WetlandCode = shift(@_);
	my $perctg1 = shift(@_);
	my $Wetland  = MISSCODE; 
	 
	if (isempty($WetlandCode)){ $Wetland = MISSCODE; }
	elsif ($WetlandCode eq "BO" && $perctg1 !=0) { $Wetland = "B,F,X,X,"; }
	elsif ($WetlandCode eq "BO" && $perctg1 ==0) { $Wetland = "B,O,X,X,"; }
	elsif ($WetlandCode eq "SO") { $Wetland = "S,O,X,X,"; }
	elsif ($WetlandCode eq "SW" && $perctg1 !=0) { $Wetland = "S,T,X,X,"; }
	elsif ($WetlandCode eq "SW" && $perctg1 ==0) { $Wetland = "S,O,X,X,"; }
	 
	#$WetlandCode = MISSCODE.",".MISSCODE.",".MISSCODE.",".MISSCODE.",";
	return $Wetland;
	
}


sub PEinv_to_CAS 
{
	my $PE_File = shift(@_);
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
	my $total=0;
	my $total2=0;
	#my $ndrops=0;
	
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
	 	$CAS_File_HDR = $pathname."/PEtable.hdr";
	 	$CAS_File_CAS = $pathname."/PEtable.cas";
	 	$CAS_File_LYR = $pathname."/PEtable.lyr";
	 	$CAS_File_NFL = $pathname."/PEtable.nfl";
	 	$CAS_File_DST = $pathname."/PEtable.dst";
	 	$CAS_File_ECO = $pathname."/PEtable.eco";
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

	if(($optgroups==0) || ($optgroups==1 && $nbiters==1)|| ($optgroups==2 && $TotalIT==1)){

		open (CASHDR, ">$CAS_File_HDR") || die "\n Error: Could not open CAS header output file!\n";
		open (CASCAS, ">$CAS_File_CAS") || die "\n Error: Could not open CAS common attribute schema  file!\n";
		open (CASLYR, ">$CAS_File_LYR") || die "\n Error: Could not open CAS layer output file!\n";
		open (CASNFL, ">$CAS_File_NFL") || die "\n Error: Could not open CAS non-forested land output file!\n";
		open (CASDST, ">$CAS_File_DST") || die "\n Error: Could not open CAS disturbance output file!\n";
		open (CASECO, ">$CAS_File_ECO") || die "\n Error: Could not open CAS ecological output file!\n";

		print CASCAS "CAS_ID,ORIG_STAND_ID,STAND_STRUCTURE,NUM_OF_LAYERS,IDENTIFICATION_ID,MAP_SHEET_ID,GIS_AREA,GIS_PERIMETER,INVENTORY_AREA,PHOTO_YEAR\n";
		print CASLYR "CAS_ID,SOIL_MOIST_REG,STRUCTURE_PER,LAYER,LAYER_RANK,CROWN_CLOSURE_UPPER,CROWN_CLOSURE_LOWER,HEIGHT_UPPER,HEIGHT_LOWER,PRODUCTIVE_FOR,". 		"SPECIES_1,SPECIES_PER_1,SPECIES_2,SPECIES_PER_2,SPECIES_3,SPECIES_PER_3,SPECIES_4,SPECIES_PER_4,SPECIES_5,SPECIES_PER_5,SPECIES_6,SPECIES_PER_6,SPECIES_7,SPECIES_PER_7,".
		"SPECIES_8,SPECIES_PER_8,SPECIES_9,SPECIES_PER_9,SPECIES_10,SPECIES_PER_10,ORIGIN_UPPER,ORIGIN_LOWER,SITE_CLASS,SITE_INDEX\n";
		print CASNFL "CAS_ID,SOIL_MOIST_REG,STRUCTURE_PER,LAYER,LAYER_RANK,CROWN_CLOSURE_UPPER,CROWN_CLOSURE_LOWER,HEIGHT_UPPER,HEIGHT_LOWER,NAT_NON_VEG,NON_FOR_ANTH,NON_FOR_VEG\n";
		print CASDST "CAS_ID,DIST_1,DIST_YR_1,DIST_EXT_UPPER_1,DIST_EXT_LOWER_1,DIST_2,DIST_YR_2,DIST_EXT_UPPER_2,DIST_EXT_LOWER_2,DIST_3,DIST_YR_3,DIST_EXT_UPPER_3,DIST_EXT_LOWER_3,LAYER\n";
		print CASECO "CAS_ID,WETLAND_TYPE,WET_VEG_COVER,WET_LANDFORM_MOD,WET_LOCAL_MOD,ECO_SITE\n";
		print CASHDR "IDENTIFICATION_ID,JURISDICTION,COORDINATE_SYS,PROJECTION,DATUM,INVENTORY_OWNER,LAND_OWNER,PERMISSION,TENURE_TYPE,INV_TYPE,INV_VERSION,INV_START_YR,INV_FINISH_YR,INV_ACQ_ID,".
		"INV_ACQ_YR,INV_UPDATE_YR,COMMENT\n";

		my $HDR_Record =  "1,PE,,CSRS_Prince_Edward_Island,NAD83,PROV_GOV,PEI Department of Environment, Energy & Forestry,UNRESTRICTED,,,,1990,1990,,,,";
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

	

 	my @Fields;my $PolyNum; my $CAS_ID; my $MapSheetID; my $IdentifyID;my $Area; my $Perimeter;my $Mer;my $Rng; 
	my $Twp;my $Gid;my $MoistReg;my $Density; my $Height; my $Sp1;my $Sp1Per;my $Sp2;my $Sp2Per;my $Sp3;my $Sp3Per;my $Sp4;  my $Sp4Per; my $Struc; my $StrucVal;
	my $Origin;my $TPR; my $Initials;  

	my $NFL; my $NFLPer;my $NatNon;my $AnthVeg; my $AnthNon;my $Mod1;my $Mod1Ext;my $Mod1Yr;my $Mod2;my $Mod2Ext;my $Mod2Yr;  my $Data; my $DataYr; 

	my $MoistCode;my $Mod3; 
	my $Mod3Ext; my $Mod3Yr;my $IntTpr;
	my $SMR; my $StandStructureCode;my $StandStructureVal; 
	my $CCHigh;my $CCLow; ;my $HeightHigh; my $HeightLow; 
	my $SpeciesComp;  my $Ageact;
	my $SiteClass;my $SiteIndex;my $Wetland;

	my $NonForVeg; my $NonForVeg2; 
	my $NonForAnth; my $NonForAnth1;my $NonForAnth2;  
	my $Dist1; my $Dist2; my $Dist3; 
	my $Dist1ExtHigh; my $Dist2ExtHigh; my $Dist3ExtHigh; 
	my $Dist1ExtLow; my $Dist2ExtLow; my $Dist3ExtLow; 
	my $UnProdFor;
	my $NatNonVeg;my $NatNonVeg1;my $NatNonVeg2;
	my $Dist; my $UDist; 
	my $Class; my $ClassMod; my $Type_lnd;my $TPRI;

	my %herror=();
	my $keys; my $cpt_ind;

	my $CAS_Record; my $Lyr_Record; my $LYR_Record1; my $LYR_Record2; my $LYR_Record3;
	my $NFL_Record; my $NFL_Record1; my $NFL_Record2; my $NFL_Record3; my $DST_Record; 
	my $pr1; my $pr2; my $pr3; my $pr4; my $pr5;
	my $covtype; my $non_for;
	my $Disturb; my $none1; my $none2; my $none3;
	my @SpecsPerList=(); my $Sp5;
	my $errspec=0;
	#CAS_ID,HEADER_ID,LANDTYPE,KEY_,MAP,STAND,COUNTY,DISTRICT,LOT,AREA,SI,HIST_GRD,STRATUM,GROUP_,INTGROUP,NAT_TRUST,SPEC1,PER1,SPEC2,PER2,SPEC3,PER3,SPEC4,PER4,SPEC5,
	#PER5,HEIGHT,CROWN,ORG_HIST,DI,SHAPE_AREA,SHAPE_PERI

	my $nbpr=0;
	my $ndrops=0;
	my %NFL_list = ("BO", 1, "AG", 1, "RN", 1,  "CL", 1, "BU", 1, "DI", 1, "EP", 1, "FL", 1, "PL", 1,  "RD", 1,"RR", 1, "SD", 1,"SO", 1, "UR", 1, "WF", 1, "WW", 1, "BR", 1, "CC", 1, "PN", 1);
	
	##############################################

	my $csv = Text::CSV_XS->new(
	{  
		binary       => 1,
		sep_char    => ";"
	});
    open my $PEinv, "<", $PE_File or die " \n Error: Could not open NS input file $PE_File: $!";
	
	my @tfilename= split ("/", $PE_File);
	my $nps=scalar(@tfilename);
	$Glob_filename= $tfilename[$nps-1];

 	$csv->column_names ($csv->getline ($PEinv));

   	while (my $row = $csv->getline_hr ($PEinv)) 
   	{	 

	# added because of the new codification of CAS_ID

		$Glob_CASID   =  $row->{CAS_ID};
		($pr1,$pr2,$pr3, $pr4, $pr5)     =  split("-", $row->{CAS_ID} );   	    
	    $MapSheetID   =  $pr3; 
		$PolyNum =$pr4;  
		# faut-t-il supprimer les 0 du d/but? si oui faire la ligne suivante, sinon la supprimer
		$PolyNum =~ s/^0+//;
		$MapSheetID =~ s/x+//;

	  	$SMR = UNDEF;	
	  	$StandStructureCode = "S";
	  	$StandStructureVal = UNDEF;

	  	$CCHigh = CCUpper($row->{CROWN});
	  	$CCLow = CCLower($row->{CROWN});
	  	if($CCHigh  eq ERRCODE   || $CCLow  eq ERRCODE) 
	  	{
	  		$keys="Density"."#".$row->{CROWN};
			$herror{$keys}++;
		}
	  

	  	$HeightHigh = ($row->{HEIGHT})+0.5;
	  	$HeightLow = ($row->{HEIGHT})-0.5;
  	 	if  (($HeightHigh < 0  || $HeightLow  <0) && ((isempty($row->{SPEC1}) || (!isempty($row->{SPEC1}) && $row->{PER1} eq "0"))|| $row->{SPEC1} eq "AG")) 
  	 	{
			$HeightHigh = MISSCODE;
			$HeightLow = MISSCODE;
	 	}

	  	if( ($HeightHigh < 0  || $HeightLow  <0) && !isempty($row->{SPEC1}) && $row->{SPEC1} ne "AG" && $row->{PER1} ne "0") 
	  	{
	  		# $keys="negative Height"."#".$row->{HEIGHT}."#species#".$row->{SPEC1}.",".$row->{PER1} ;
			# $herror{$keys}++;
			$HeightHigh = MISSCODE;
			$HeightLow = MISSCODE;
		}
		$errspec=0;
		$SpeciesComp = Species($row->{SPEC1},$row->{PER1},$row->{SPEC2},$row->{PER2},$row->{SPEC3},$row->{PER3},$row->{SPEC4},$row->{PER4},$row->{SPEC5},$row->{PER5}, $spfreq);

		if($SpeciesComp =~ /SPECIES_ERRCODE/) 
		{ 
			$keys="Species"."#".$row->{SPEC1}."-".$row->{SPEC2}."-".$row->{SPEC3}."-".$row->{SPEC4};
			$herror{$keys}++;
		}

	 	@SpecsPerList  = split(",", $SpeciesComp); $Sp1=$SpecsPerList[0];$Sp2=$SpecsPerList[2];$Sp3=$SpecsPerList[4];$Sp4=$SpecsPerList[6];$Sp5=$SpecsPerList[8];
 
   		for($cpt_ind=0; $cpt_ind<=4; $cpt_ind++)
		{  
			my $posi=$cpt_ind*2;
					
        	#if($SpecsPerList[$posi]  eq SPECIES_ERRCODE ) 
			#{ 
				#	$errspec=1; #print "error on pos $posi sp1= $row->{SPEC1} spcomp =$SpeciesComp\n";
			#}
   		}
		my $total=$SpecsPerList[1] + $SpecsPerList[3]+ $SpecsPerList[5] +$SpecsPerList[7] +$SpecsPerList[9];
		if($total == 90)
		{
			if($row->{SPEC1} eq "WP") 
			{
				$SpeciesComp = Species($row->{SPEC1},($row->{PER1}),$row->{SPEC2},$row->{PER2},$row->{SPEC3},$row->{PER3},$row->{SPEC4},$row->{PER4}+1,$row->{SPEC5},$row->{PER5});
			}
			else
			{
				$SpeciesComp = Species($row->{SPEC1},($row->{PER1}+1),$row->{SPEC2},$row->{PER2},$row->{SPEC3},$row->{PER3},$row->{SPEC4},$row->{PER4},$row->{SPEC5},$row->{PER5});
			}
			#$keys="corrected perct#". $SpeciesComp;
			#$herror{$keys}++; 
		}

		#elsif($total != 100 && $total != 0 && $errspec==0){
		#$keys="Stotal perct !=100"."#$total#".$SpeciesComp."#original#".$row->{SPEC1}.",".$row->{PER1}.",".$row->{SPEC2}.",".$row->{PER2}.",".$row->{SPEC3}.",".$row->{PER3}.",".$row->{SPEC4}.",".$row->{PER4};
		#$herror{$keys}++; 
			#$errspec=1;
		#}
	  	$SpeciesComp = $SpeciesComp .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";
	  
		$Origin = UNDEF;
		$SiteClass = UNDEF;
		$SiteIndex = UNDEF; #"";
		#$errspec=0;
		$Wetland = WetlandCodes ($row->{LANDTYPE}, $row->{PER1});
		#not defined for the standard pre 2000
		#  if($Wetland  eq "")
		#{
			#$keys="WETLAND-MoistReg"."#".$MoistReg."#".$NFL."#".$Sp1."#".$Sp2."#".$Sp1Per."#".$Sp3."#".$Sp4."#".$Sp5;
			#  $herror{$keys}++;
		#}
	
  		# ===== Non-forested Land =====
  		my $create_dst = 0;
  		if ($row->{LANDTYPE} eq "BR" || $row->{LANDTYPE} eq "CC" || $row->{LANDTYPE} eq "PN" )
  		{
  			$NatNonVeg = $NonForAnth = $UnProdFor = $NonForVeg = MISSCODE;
  			$create_dst = 1;
  		}
  		else 
  		{
			$NatNonVeg = NaturallyNonVeg($row->{LANDTYPE});
			$NonForAnth = NonForestedAnth($row->{LANDTYPE});
			$UnProdFor = UnProdForest($row->{LANDTYPE});
			$NonForVeg = NonForestedVeg($row->{LANDTYPE}); 
		    $keys="tried NFL"."#".$row->{LANDTYPE}."#";
			$herror{$keys}++;
		 
			if($NatNonVeg  eq ERRCODE && $NonForAnth eq ERRCODE && $NonForVeg eq ERRCODE && $UnProdFor eq ERRCODE)
			{ 
				if (($row->{LANDTYPE} ne "HH") && ($row->{LANDTYPE} ne "HS")&& ($row->{LANDTYPE} ne "SH")&& ($row->{LANDTYPE} ne "SS")&& ($row->{LANDTYPE} ne "S")) 
				{
					$keys="check eers NatNV"."#".$row->{LANDTYPE}."#";
					$herror{$keys}++;
				}
			  	$NonForVeg=UNDEF;$NonForAnth=UNDEF;$NatNonVeg =UNDEF;
			}

			if($NatNonVeg  eq MISSCODE && $NonForAnth eq MISSCODE && $NonForVeg eq MISSCODE)
			{ 
				$keys="check missing NatNV"."#".$row->{LANDTYPE};
				$herror{$keys}++;
			 	$NonForVeg=UNDEF;$NonForAnth=UNDEF;$NatNonVeg =UNDEF;
			}
 		}
	
	  	if($row->{ORG_HIST} eq "WF") 
	  	{

			$UnProdFor="NP";
		}
	 	if($UnProdFor eq ERRCODE){$UnProdFor=UNDEF;}

  		# ===== Modifiers =====

  		if ($create_dst) 
  		{
  			$Dist1 = Disturbance($row->{LANDTYPE});  
  		}
	  	else 
	  	{
	  		$Dist1 = Disturbance($row->{ORG_HIST}); 
	  	} 
	  	($Disturb, $none1,$none2, $none3)=split(",",$Dist1 );
	  	if($Disturb  eq ERRCODE ) 
	  	{ 
	  		$keys="check dist code"."#".$row->{ORG_HIST};
			$herror{$keys}++;
		}	
        $Dist = $Dist1. ",". UNDEF. "," .UNDEF. "," .UNDEF. "," .UNDEF. "," . UNDEF. "," .UNDEF. "," .UNDEF. "," .UNDEF;

        # $Dist = $Dist1 . "," . $Dist2 . "," . $Dist3;
          

	

		# ======================================================= WRITING Output inventory info IN CAS FILES =======================================================================================================
		# ===== Output inventory info for layer 1 =====
		my $prod_for="PF";
		my $lyr_poly=0;
		if(isempty($row->{SPEC1}))
		{
			$SpeciesComp="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
			if ( !is_missing($CCHigh) ||  !is_missing($CCLow) || !is_missing($HeightHigh) || !is_missing($HeightLow))
			{
				$prod_for="PP";
				$lyr_poly=1;
			}
		}
		if ($Disturb  eq "CO" || $create_dst)
		{
			$prod_for="PF";
			$lyr_poly=1;
		}
		if ($UnProdFor ne MISSCODE && $UnProdFor ne ERRCODE && $UnProdFor ne UNDEF)
		{
			$prod_for=$UnProdFor;
		}

		if (($StandStructureCode eq "S")) 
		{
	        $CAS_Record = $row->{CAS_ID} . "," . $PolyNum . ",S,1," . $row->{HEADER_ID} . "," . $MapSheetID . "," . $row->{GIS_AREA} . "," . $row->{GIS_PERI} . ",".$row->{GIS_AREA}.",1990";
		    print CASCAS $CAS_Record . "\n";
		    $nbpr=1;$$ncas++;$ncasprev++;

	        #forested  || ($UnProdFor ne MISSCODE && $UnProdFor ne ERRCODE && $UnProdFor ne UNDEF)
			#if ((!isempty($row->{SPEC1}) && !isempty($row->{PER1}) && $row->{PER1} ne "0"  && $row->{SPEC1} ne "AG") || ($UnProdFor ne MISSCODE && $UnProdFor ne ERRCODE && $UnProdFor ne UNDEF)) {
			if ((!isempty($row->{SPEC1}) && !isempty($row->{PER1}) && $row->{PER1} != 0  && !$NFL_list{$row->{SPEC1}}) || $lyr_poly) 
			{
				$LYR_Record1 = $row->{CAS_ID} . "," . $SMR  . "," . $StandStructureVal . ",1,1";
		     	$LYR_Record2 = $CCHigh . "," . $CCLow . "," . $HeightHigh . "," . $HeightLow . "," .$prod_for.",". $SpeciesComp;
		      	$LYR_Record3 = $Origin . "," . $Origin . ",". $SiteClass . "," . $SiteIndex;
		      	$Lyr_Record = $LYR_Record1 . "," . $LYR_Record2 . "," . $LYR_Record3;
		     	print CASLYR $Lyr_Record . "\n";
				$nbpr++; $$nlyr++;$nlyrprev++;
		    }
	            #non-foested
		    elsif (!is_missing($NatNonVeg)  || !is_missing($NonForAnth) || !is_missing($NonForVeg))
		    {
			    #elsif (($NatNonVeg ne MISSCODE || $NonForAnth ne MISSCODE || $NonForVeg ne MISSCODE) && ($NatNonVeg ne UNDEF || $NonForAnth ne UNDEF || $NonForVeg ne UNDEF)) {
			    #if ($NonForVeg ne MISSCODE || $NonForAnth ne MISSCODE || $NonForVeg ne MISSCODE) {
			    $NFL_Record1 = $row->{CAS_ID} . "," . $SMR  . "," .  $StandStructureVal . ",1,1";
			    $NFL_Record2 = $CCHigh . "," . $CCLow . "," . $HeightHigh . "," . $HeightLow;
		        $NFL_Record3 = $NatNonVeg . "," . $NonForAnth . "," . $NonForVeg;
		        $NFL_Record = $NFL_Record1 . "," . $NFL_Record2 . "," . $NFL_Record3;
			    print CASNFL $NFL_Record . "\n";
				$nbpr++;$$nnfl++;$nnflprev++;
		    }
	            #Disturbance
		    if (!is_missing($Disturb))
		    {
		     	$DST_Record = $row->{CAS_ID} . "," . $Dist. ",1";
		      	print CASDST $DST_Record . "\n";
				if($nbpr==1) {$$ndstonly++; $ndstonlyprev++;}
				$nbpr++;$$ndst++;$ndstprev++;
		    }
		    #Ecological 
		    if ($Wetland ne MISSCODE) 
		    {
		      	$Wetland = $row->{CAS_ID} . "," . $Wetland."-";
		      	print CASECO $Wetland . "\n";
				if($nbpr==1) {$$necoonly++;$necoonlyprev++;}
				$nbpr++;$$neco++;$necoprev++;
		   	}
		}

		if($nbpr ==1 )
		{
			$ndrops++;
			if(isempty($row->{SPEC1})  && (isempty($row->{ORG_HIST}) || $Disturb eq ERRCODE) &&  isempty($row->{LANDTYPE}) && $Wetland eq MISSCODE)
			{
				$keys = "WILL DROP THIS>>>empty-TYPEFOR=".$row->{CLASS}."-CLMOD=".$row->{CL_MOD}."-TYPEFOR=".$row->{TYPE_FOR};
	 			$herror{$keys}++; 
			}
			else
			{
				$keys ="!!! record may be dropped#bcse>>>specs=".$row->{SPEC1}."-distcode=".$row->{ORG_HIST}."-LANDTYPE=".$row->{LANDTYPE};
	 			$herror{$keys}++; 
				$keys ="#droppable#";
	 			$herror{$keys}++; 
			}
		}
		#end while         
	}

 	$csv->eof or $csv->error_diag ();
  	close $PEinv;

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
    close(ERRS);
    close (CASCAS);
	close (CASLYR);
	close (CASNFL);
	close (CASDST);
	close (CASECO);
	close (CASHDR);
	close(SPERRSFILE);close(SPECSLOGFILE); 
	$total=$nlyrprev+ $nnflprev+  $ndstprev + $necoprev;
	#if($total > $ncasprev) {print "must check this !!! \n";}
	#rint "$ncasprev, $nlyrprev, $nnflprev,  $ndstprev, $necoprev, $total\n";
	$total2=$nlyrprev+ $nnflprev+  $ndstonlyprev + $necoonlyprev;
	#print "drops = $ndrops nb records in casfile : $ncasprev, lyrfile : $nlyrprev, nflfile : $nnflprev,  dstfile : $ndstprev, ecofile : $necoprev--- total (without .cas): $total\n";
	print " drops = $ndrops,  nb records in casfile : $ncasprev, lyrfile : $nlyrprev, nflfile : $nnflprev,  dstfile : $ndstprev($ndstonlyprev), ecofile : $necoprev($necoonlyprev)--- total (without .cas): $total($total2)\n";
}

1;
#province eq "PE";

