package ModulesV4::YT_conversion08;


use Exporter;
use Cwd;
use Text::CSV; 
our @ISA = qw(Exporter);
our @EXPORT = qw(&YTinv_to_CAS );
#our @EXPORT_OK = qw(&SoilMoistureRegime &StandStructure  &StandStructureValue &CCUpper  &CCLower &StandHeight &Latine &UpperOrigin &NaturallyNonVeg  &LowerOrigin &Species  &Disturbance &Site );
use strict;

our $Species_table;	
our $cpt2=0;our $cpt4=0;

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


#Determine SoilMoistureRegime from SMR value
sub SoilMoistureRegime
{
	my $MoistReg;
	my %MoistRegList = ("", 1, "d", 1, "m", 1, "w", 1, "a", 1, "D", 1, "M", 1, "W", 1, "A", 1);
	my $SoilMoistureReg;

	($MoistReg) = shift(@_);

	if(isempty($MoistReg)) 
	{
		$SoilMoistureReg = MISSCODE; 
		return $SoilMoistureReg;
	}

	if ($MoistRegList {$MoistReg} ) { } 
	else 
	{
		$SoilMoistureReg = ERRCODE; 
		return $SoilMoistureReg;
	}

	if (($MoistReg eq "d") || ($MoistReg eq "D"))         { $SoilMoistureReg = "D"; }
	elsif (($MoistReg eq "m") || ($MoistReg eq "M"))      { $SoilMoistureReg = "F"; }
	elsif (($MoistReg eq "w") || ($MoistReg eq "W"))      { $SoilMoistureReg = "W"; }
	elsif (($MoistReg eq "a") || ($MoistReg eq "A"))      { $SoilMoistureReg = "A"; }
	
	return $SoilMoistureReg;
}

#Determine StandStructure from Struc value### 1 layer


sub StandStructure
{
	my $Struc;
	my $StandStructure;

	($Struc) = shift(@_);

	if(isempty($Struc)) 
	{
		$StandStructure = "S"; 
	}
	else 
	{ 
		$StandStructure  = ERRCODE; 
	}

	return $StandStructure;
}

#Determine StandStructure from StrucVal    REDO
sub StandStructureValue
{
	my $StrucVal;
	my  $StandStructureValue;

	($StrucVal) = shift(@_);
	if  (isempty($StrucVal ))                                     { $StandStructureValue = 0; }
	elsif (($StrucVal < 1)    || ($StrucVal > 9))                 { $StandStructureValue = 0; }
	elsif (($StrucVal > 0)    && ($StrucVal < 10))                { $StandStructureValue = $StrucVal; }

	return $StandStructureValue;
}

#Determine CCUpper from Density  CC   -----------TO COMPLETE
#0-5	6-10	11-15	16-20	21-25	26-30	31-35	36-40	41-45	46-50	51-55	56-60	61-65  66-70	71-75	76-80	81-85	86-90	91-95	96-100

sub CCUpper 
{
	my $CCHigh;
	my $Density;
	my %DensityList = ("", 1, "0", 1, "5", 1, "10", 1, "15", 1, "20", 1, "25", 1, "30", 1, "35", 1, "40", 1, "45", 1, "50", 1, "55", 1, "60", 1, "65", 1, "70", 1, "75", 1, "80", 1, "85", 1, "90", 1, "95", 1);

	($Density) = shift(@_);

	if(isempty($Density)) 				  { $CCHigh = MISSCODE;  }
	elsif (!$DensityList {$Density} )        {$CCHigh = ERRCODE; }
	else 
	{
		if (($Density eq "0") )            { $CCHigh = 5;  }
		elsif (($Density eq "5") )            { $CCHigh = 10; }
		elsif (($Density eq "10"))            { $CCHigh = 15; }
		elsif (($Density eq "15"))            { $CCHigh = 20; }
		elsif (($Density eq "20"))            { $CCHigh = 25; }
		elsif (($Density eq "25"))            { $CCHigh = 30; }
		elsif (($Density eq "30"))            { $CCHigh = 35; }
		elsif (($Density eq "35"))            { $CCHigh = 40; }
		elsif (($Density eq "40"))            { $CCHigh = 45; }
		elsif (($Density eq "45"))            { $CCHigh = 50; }
		elsif (($Density eq "50"))            { $CCHigh = 55; }
		elsif (($Density eq "55"))            { $CCHigh = 60; }
		elsif (($Density eq "60"))            { $CCHigh = 65; }
		elsif (($Density eq "65"))            { $CCHigh = 70; }
		elsif (($Density eq "70"))            { $CCHigh = 75; }
		elsif (($Density eq "75"))            { $CCHigh = 80; }
		elsif (($Density eq "80"))            { $CCHigh = 85; }
		elsif (($Density eq "85"))            { $CCHigh = 90; }
		elsif (($Density eq "90"))            { $CCHigh = 95; }
		elsif (($Density eq "95"))            { $CCHigh = 100; }		
	}

	return $CCHigh;
}

#Determine CCLower from Density  CC
#0-5	6-10	11-15	16-20	21-25	26-30	31-35	36-40	41-45	46-50	51-55	56-60	61-70	71-75	76-80	81-85	86-91	91-95	96-100

sub CCLower 
{
	my $CCLow;
	my $Density;
	my %DensityList = ("", 1, "0", 1, "5", 1, "10", 1, "15", 1, "20", 1, "25", 1, "30", 1, "35", 1, "40", 1, "45", 1, "50", 1, "55", 1, "60", 1, "65", 1, "70", 1, "75", 1, "80", 1, "85", 1, "90", 1, "95", 1);

	($Density) = shift(@_);
	
	if(isempty($Density))                 { $CCLow = MISSCODE; }
	elsif (!$DensityList {$Density} ) {$CCLow = ERRCODE; }
	else  
	{ 
		if (($Density eq "0"))                { $CCLow = 0; }
		elsif (($Density eq "5"))             { $CCLow = 6; }
		elsif (($Density eq "10"))            { $CCLow = 11; }
		elsif (($Density eq "15"))            { $CCLow = 16; }
		elsif (($Density eq "20"))            { $CCLow = 21; }
		elsif (($Density eq "25"))            { $CCLow = 26; }
		elsif (($Density eq "30"))            { $CCLow = 31; }
		elsif (($Density eq "35"))            { $CCLow = 36; }
		elsif (($Density eq "40"))            { $CCLow = 41; }
		elsif (($Density eq "45"))            { $CCLow = 46; }
		elsif (($Density eq "50"))            { $CCLow = 51; }
		elsif (($Density eq "55"))            { $CCLow = 56; }
		elsif (($Density eq "60"))            { $CCLow = 61; }
		elsif (($Density eq "65"))            { $CCLow = 66; }	
		elsif (($Density eq "70"))            { $CCLow = 71; }
		elsif (($Density eq "75"))            { $CCLow = 76; }
		elsif (($Density eq "80"))            { $CCLow = 81; }
		elsif (($Density eq "85"))            { $CCLow = 86; }
		elsif (($Density eq "90"))            { $CCLow = 91; }
		elsif (($Density eq "95"))            { $CCLow = 96; }
	}
	return $CCLow;
}

#Determine stand height from Height   AVG_HT
sub StandHeight 
{
	my $Height;my $HeightUL;

	($Height) = shift(@_);
	if  (isempty($Height) )                     { $HeightUL = MISSCODE; }
	elsif (($Height < 0)    || ($Height > 50))     { $HeightUL = 0; }
	elsif (($Height >= 0)   && ($Height <= 50))    { $HeightUL = $Height; }
	else { $HeightUL = ERRCODE; }
	return $HeightUL;
}

#Dertermine Latine name of species   REDO
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
		#$CurrentSpecies =~ s/\s//g;

		if ($Species_table->{$CurrentSpecies}) { $GenusSpecies = $Species_table->{$CurrentSpecies}; }
		else 	 {$GenusSpecies = SPECIES_ERRCODE;  print SPECSLOGFILE "Illegal species code $CurrentSpecies,CAS_ID=$Glob_CASID,file=$Glob_filename\n";  } 
	}
	return $GenusSpecies;
}



#Determine Species from the 4 Species fields  SP and SP_PER   VERIFY
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
	my $spfreq = shift(@_);
	my $spper1; 
	my $spper2;
	my $spper3;
	my $spper4;
	my $Species;
	 
	
	if ( isempty($Sp1Per)) { $spper1 = 0; }
	else { $spper1 = $Sp1Per; }

	if ( isempty($Sp2Per)) { $spper2 = 0; }
	else { $spper2 = $Sp2Per; }

	if ( isempty($Sp3Per)) { $spper3 = 0; }
	else { $spper3 = $Sp3Per; }
	
	if ( isempty($Sp4Per)) { $spper4 = 0; }
	else { $spper4 = $Sp4Per; }

	#my $spper1=$Sp1Per;my $spper2=$Sp2Per;my $spper3=$Sp3Per;my $spper4=$Sp4Per;

	if (isempty($Sp1)) { $Sp1 = ""; }
	if (isempty($Sp2)) { $Sp2 = ""; }
	if (isempty($Sp3)) { $Sp3 = ""; }
	if (isempty($Sp4)) { $Sp4 = ""; }
	$spfreq->{$Sp1}++;
	$spfreq->{$Sp2}++;
	$spfreq->{$Sp3}++;
	$spfreq->{$Sp4}++;

	$Sp1 = Latine($Sp1); $Sp2 = Latine($Sp2); $Sp3 = Latine($Sp3); $Sp4 = Latine($Sp4); 
	#$Species = $Sp1 . "," . $Sp1Per . "," . $Sp2 . "," . $Sp2Per . "," . $Sp3 . "," . $Sp3Per . "," . $Sp4 . "," . $Sp4Per . "," . $Sp5 . "," . $Sp5Per;

	$Species = $Sp1 . "," . $spper1 . "," . $Sp2 . "," . $spper2 . "," . $Sp3 . "," . $spper3 . "," . $Sp4 . "," . $spper4 ;

	return $Species;
}

#Determine upper stand origin from AGE
sub ActualOrigin 
{
	my $Origin;
	($Origin) = shift(@_);

	if (isempty($Origin)) {$Origin = MISSCODE;}
  	elsif ($Origin >= 0) 
  	{
	   $Origin = $Origin;
	}
	else { $Origin = ERRCODE; }

	return $Origin;
}


#Determine Site from SITE_CLASS
sub Site 
{
	my $Site;
	my $TPR;
	my %TPRList = ("", 1, "l", 1, "p", 1, "m", 1, "g", 1, "L", 1, "P", 1, "M", 1, "G", 1);

	($TPR) = shift(@_);
	
	if(isempty($TPR))   { $Site = MISSCODE; }
	elsif (!$TPRList {$TPR} ) { $Site = ERRCODE; }
    else 
    { 
		if  ($TPR eq "")                            { $Site = MISSCODE; }
		elsif (($TPR eq "l") || ($TPR eq "L"))      { $Site = "P"; }
		elsif (($TPR eq "p") || ($TPR eq "P"))      { $Site = "P"; }
		elsif (($TPR eq "m") || ($TPR eq "M"))      { $Site = "M"; }
		elsif (($TPR eq "g") || ($TPR eq "G"))      { $Site = "G"; }
	} 
	return $Site;
}

#Determine SiteIndex from SITE_INDEX  VERIFY
sub SiteIndex 
{
	my $SiteIndex;
	my $SiteIndexCode;
	
	($SiteIndex) = shift(@_);

	if  (isempty($SiteIndex)) { $SiteIndexCode = MISSCODE; }
	elsif (($SiteIndex >= 0 )  && ($SiteIndex <= 30))  { $SiteIndexCode = $SiteIndex; }
	 
	else { $SiteIndexCode = 0; }

	return $SiteIndexCode;
}

#Determine Naturally non-vegetated stands  from   CLASS and CL_MOD
#VN=Vegetated, non forested; NW=Non vegetated water; NU=Non Vegetated, Urban/industrial; NE=Non vegetated, Exposed land; NS=Non Vegetated, Snow/Ice

#Naturally non vegetated: Identified as a cover type (TYPE); NE (exposed land), NS (snow and Ice), NW (water). These are further identified as a cover type class (CLASS), 
#RS – river sediments, E – exposed soil, S – sand, B – burned area, RR – bedrock or fragmented rock, O – other, R – River, L – Lake. R
#ock can be further identified with a cover type class modifier Ro – rock, Ru – rubble.

#NatNonveg list  AP LA RI OC  RK  SA SI    SL EX    BE  WS   FL     IS    TF

sub NaturallyNonVeg 
{
	my $NatNonVeg; my $ClassMod;my $Typefor;my $ClassModRes;my $NatNonVegRes; 

	my %NatNonVegList = ("", 1, "L", 1, "RS", 1, "E", 1, "S", 1, "B", 1, "RR", 1, "R", 1,  
			 	    "l", 1, "rs", 1, "e", 1, "s", 1, "b", 1, "rr", 1, "r", 1 );#"O", 1,, "o", 1

	#my %TypelndList = ("", 1, "NE", 1, "NS", 1, "NW", 1,
			 	 #  "ne", 1, "ns", 1, "nw", 1);

	my %ClModList = ("", 1, "RO", 1, "RU", 1, "RIV", 1,"W", 1, "L", 1,"R", 1,
			 	"ro", 1, "ru", 1);


	($NatNonVeg) = shift(@_);
	($ClassMod) = shift(@_);
	$Typefor = shift(@_);

	if (defined $ClassMod ){$_ = $ClassMod; tr/a-z/A-Z/; $ClassMod = $_;}
	else {$ClassMod ="";} 

	
	if ($ClModList {$ClassMod} ) { } else { $ClassModRes = ERRCODE; }
	#if (isempty($ClassMod)) { $ClassModRes = MISSCODE; }
	if ($NatNonVegList {$NatNonVeg} ) { } else { $NatNonVegRes = ERRCODE; }

	if  (isempty($NatNonVeg))					{ $NatNonVegRes = MISSCODE; }
	
	elsif (($NatNonVeg eq "l") || ($NatNonVeg eq "L"))	{ $NatNonVegRes = "LA"; }
	elsif (($NatNonVeg eq "rs") || ($NatNonVeg eq "RS"))	{ $NatNonVegRes = "WS"; }	
	elsif (($NatNonVeg eq "e") || ($NatNonVeg eq "E"))	{ $NatNonVegRes = "EX"; }
	elsif (($NatNonVeg eq "s") || ($NatNonVeg eq "S"))	{ $NatNonVegRes = "SA"; }
	elsif (($NatNonVeg eq "b") || ($NatNonVeg eq "B"))	{ $NatNonVegRes = "EX"; }
	elsif (($NatNonVeg eq "rr") || ($NatNonVeg eq "RR"))	{ $NatNonVegRes = "RK"; }
	#elsif (($NatNonVeg eq "h") || ($NatNonVeg eq "H"))	{ $NatNonVegRes = "HE"; }
	#elsif (($NatNonVeg eq "m") || ($NatNonVeg eq "M"))	{ $NatNonVegRes = "HE"; }
	elsif (($NatNonVeg eq "r") || ($NatNonVeg eq "R"))	{ $NatNonVegRes = "RI"; }
	else 							{ $NatNonVegRes = ERRCODE; }

	if (isempty($ClassMod))  					{ $ClassModRes = MISSCODE;}	
	elsif (($ClassMod eq "ro") || ($ClassMod eq "RO"))	{ $ClassModRes = "RK"; }
	elsif (($ClassMod eq "ru") || ($ClassMod eq "RU"))	{ $ClassModRes = "RK"; }
	elsif (($ClassMod eq "R") && ($Typefor==1))	{ $ClassModRes = "RK"; }
	elsif (($ClassMod eq "RIV") && ($Typefor==1))	{ $ClassModRes = "RI"; }
	elsif (($ClassMod eq "L" || $ClassMod eq "W") && ($Typefor==1))	{ $ClassModRes = "LA"; }
	else 							{ $ClassModRes = ERRCODE; }

	if($NatNonVegRes eq MISSCODE || $NatNonVegRes eq ERRCODE) 
	{	
		return $ClassModRes;
	}
	else
	{
		return $NatNonVegRes;
	}
}

#Determine Non-forested anthropogenic stands
sub NonForestedAnth 
{
	my $NonForAnth;   my $NonForAnthRes;
	my %NonForAnthList = ("", 1, "G", 1, "T", 1, "RD", 1, "O", 1,
				     "g", 1, "t", 1, "rd", 1, "o", 1);

	($NonForAnth) = shift(@_);
	 
	if ($NonForAnthList {$NonForAnth} ) { } else { $NonForAnthRes = ERRCODE; }

	if  (isempty($NonForAnth))					{ $NonForAnthRes = MISSCODE; }
	elsif (($NonForAnth  eq "g") || ($NonForAnth  eq "G"))	{ $NonForAnthRes = "IN"; }
	elsif (($NonForAnth  eq "t") || ($NonForAnth  eq "T"))	{ $NonForAnthRes  = "IN"; }
	elsif (($NonForAnth  eq "rd") || ($NonForAnth  eq "RD"))	{ $NonForAnthRes  = "FA"; }
	elsif (($NonForAnth  eq "o") || ($NonForAnth  eq "O"))	{ $NonForAnthRes = "OT"; }
	else { $NonForAnthRes = ERRCODE; }
	#return $Type_lnd.",".$NonForAnth;
	return $NonForAnthRes;
}

#Determine Non-forested vegetation stands

#Non forest vegetated: cover type = VN, cover type class = S – shrub, H – herb, C – cryptogam, M- mixed. Cover type class modifier = TS – tall shrub, TSo – tall shrub open, TSc – tall shrub closed, LS – low shrub.

sub NonForestedVeg 
{
	my $NonForVeg;  my $ClassMod;my $NonForVegRes;  my $ClassModRes;
	my %NonForVegList = ("", 1, "S", 1,  "H", 1, "M", 1, "C", 1,
				    "s", 1,  "h", 1, "m", 1, "c", 1);

	my %ClModList = ("", 1, "TS", 1, "TSO", 1, "TSC", 1, "LS", 1,
			 	"ts", 1, "tso", 1, "tsc", 1, "ls", 1);


	($NonForVeg) = shift(@_);
	($ClassMod)=shift(@_);
	if (defined $ClassMod ){$_ = $ClassMod; tr/a-z/A-Z/; $ClassMod = $_;}
	else {$ClassMod ="";} 

	if ($ClModList {$ClassMod} ) { } else { $ClassModRes = ERRCODE; }
	if ($NonForVegList {$NonForVeg} ) { } else { $NonForVegRes = ERRCODE; }

	if  (isempty($NonForVeg))					{ $NonForVegRes =MISSCODE; }
	elsif (($NonForVeg eq "s") || ($NonForVeg eq "S"))	{ $NonForVegRes = "ST"; }
	
	elsif (($NonForVeg eq "h") || ($NonForVeg eq "H"))	{ $NonForVegRes = "HE"; }
	elsif (($NonForVeg eq "m") || ($NonForVeg eq "M"))	{ $NonForVegRes = "HE"; }
	elsif (($NonForVeg eq "c") || ($NonForVeg eq "C"))	{ $NonForVegRes = "BR"; }
	#elsif (($NonForVeg eq "r") || ($NonForVeg eq "R"))	{ $NonForVeg = "RI"; }
	else 							{ $NonForVegRes = ERRCODE; }

	if  (isempty($ClassMod))					{ $ClassModRes =MISSCODE;}
	elsif (($ClassMod eq "ts") || ($ClassMod eq "TS"))	{ $ClassModRes = "ST"; }
	elsif (($ClassMod eq "tsc") || ($ClassMod eq "TSC"))	{ $ClassModRes = "ST"; }
	elsif (($ClassMod eq "tso") || ($ClassMod eq "TSO"))	{ $ClassModRes = "ST"; }
	elsif (($ClassMod eq "ls") || ($ClassMod eq "LS"))	{ $ClassModRes = "SL"; }
	else 							{ $ClassModRes = ERRCODE; }

	if($NonForVegRes eq MISSCODE || $NonForVegRes eq ERRCODE) 
	{
		return $ClassModRes;
	}
	else
	{
		return $NonForVegRes;
	}
	#$Type_lnd.",".$NonForVeg.",".$ClassMod;
}



#Determine Disturbance from DIST1

sub Disturbance 
{
	my $ModCode;
	my $Mod;
	my $ModYr;
	my $Disturbance;
	my @key=(0, 1, 2, 3, 4, 5, 6, 7, 8, 9);
	
	my %ModList = ("", 1, "DB", 1, "DL", 1, "DW", 1, "DD", 1, "DI", 1, "DS", 1, "DF", 1, 
					"db", 1, "dl", 1, "dw", 1, "dd", 1, "di", 1, "ds", 1, "df", 1);
   
	($ModCode) = shift(@_);
	$ModYr = $ModCode;

	if(length($ModCode) == 3)
	{
		print "found distcode with length3 --- $ModCode\n";
	}
	#if(length($ModCode) ==4){print "found distcode with length 4 --- $ModCode\n";}

	while ($ModCode =~ /\d$/) {$ModCode=~ s/\d$//;}
	while ($ModYr =~ /^\D/) {$ModYr=~ s/\D//;}
	if (isempty($ModYr) || $ModYr eq "0")  {$ModYr=MISSCODE; }
	elsif(length ($ModYr) == 2) 
	{
		print SPECSLOGFILE "Illegal 2 digits ModYear in DistCode $ModYr (correction is to add 1900)\n"; 
		$ModYr = 1900+$ModYr; 
		$cpt2++; 
	}
	elsif(length ($ModYr) == 4) 
	{
		$cpt4++; 
	}
	else 
	{
		print "bizarre config modcode =$ModCode, modyear=$ModYr, casid=$Glob_CASID\n"; 
		exit;
	}

	if(isempty($ModCode))
 	{
		$Disturbance = MISSCODE.",".$ModYr;
	}
	elsif ($ModList{$ModCode} ) 
	{  
 		if (($ModCode  eq "DB") || ($ModCode eq "db")) { $Mod="BU"; }
		elsif (($ModCode  eq "DL") || ($ModCode eq "dl")) { $Mod="CO"; }
		elsif (($ModCode  eq "DW") || ($ModCode eq "dw")) { $Mod="WF"; }
		elsif (($ModCode  eq "DD") || ($ModCode eq "dd")) { $Mod="DI"; }
		elsif (($ModCode  eq "DI") || ($ModCode eq "di"))   { $Mod="IK"; }
		elsif (($ModCode  eq "DS") || ($ModCode eq "ds")) { $Mod="SL"; }
		elsif (($ModCode  eq "DF") || ($ModCode eq "df")) { $Mod="FL"; }	
		$Disturbance = $Mod . "," . $ModYr; 	   
	} 
	else 
	{ 
		$Mod = ERRCODE; $Disturbance = $Mod . "," . $ModYr; 
	}

	return $Disturbance;
}





# Determine wetland codes  from SMR (Moisture)
sub WetlandCodes 
{
	my $Moisture = shift(@_);
	my $CCHigh =  shift(@_);
	my $NonForVeg = shift(@_);
	my $Spec1 = shift(@_);
	my $Spec2 = shift(@_);
	my $Spec1Per = shift(@_);
	
	my $AVG_HT = shift(@_);
	 

	my $WetlandCode = "";
	
	if (isempty( $Moisture)) 
	{ 
		$Moisture = ""; 
	}
	else
	{
		$_ = $Moisture; tr/a-z/A-Z/; $Moisture = $_;
	}
	
	if (isempty($NonForVeg)) 
	{ 
		$NonForVeg = ""; 
	}
	else
	{
		$_ = $NonForVeg; tr/a-z/A-Z/; $NonForVeg = $_;
	}

	if (isempty($Spec1)) 
	{ 
		$Spec1 = ""; 
	}
	else
	{
		$_ = $Spec1; tr/a-z/A-Z/; $Spec1 = $_;
	}
	if (isempty($Spec2)) 
	{ 
		$Spec2 = ""; 
	}
	else
	{
		$_ = $Spec2; tr/a-z/A-Z/; $Spec2 = $_;
	}
	if (isempty( $Spec1Per)) { $Spec1Per = 0; }
	
	
	
	if ($Moisture eq "A") 
	{ 
		$WetlandCode = "M,O,N,G,"; 
	}
	elsif ($Moisture eq "W")
	{ 
	 
	  	if ($NonForVeg eq "S") 
	    { $WetlandCode = "S,O,N,S,"; }
	  	elsif ($NonForVeg eq "H") 
	    { $WetlandCode = "M,O,N,G,"; }
	  	elsif ($NonForVeg eq "M") 
	    { $WetlandCode = "S,O,N,S,"; }
	  	elsif ($NonForVeg eq "C") 
	    { $WetlandCode = "F,O,N,S,"; }
	 	else
	    { $WetlandCode = "W,-,-,-,"; }
	}

	if ($Moisture eq "W") 
	{

	  	if (($Spec1 eq "SB" && $Spec1Per== 100) && $CCHigh < 50  && $AVG_HT < 12) 
	    { $WetlandCode = "B,T,N,N,"; }
	  	elsif (($Spec1 eq "SB" && $Spec1Per== 100) && ($CCHigh >= 50  &&  $CCHigh < 70)  && $AVG_HT >= 12) 
	    { $WetlandCode = "S,T,N,N,"; }
	  	elsif (($Spec1 eq "SB" && $Spec1Per== 100) && ($CCHigh >= 70)  && $AVG_HT >= 12) 
	    { $WetlandCode = "S,F,N,N,"; }
	  	elsif (($Spec1 eq "SB" || $Spec1 eq "L") &&  ($Spec2 eq "SB" || $Spec2 eq "L") && $CCHigh <= 50  && $AVG_HT < 12) 
	    { $WetlandCode = "F,T,N,N,"; }
	  	elsif (($Spec1 eq "SB" || $Spec1 eq "L" || $Spec1 eq "W") &&  ($Spec2 eq "SB" || $Spec2 eq "L" || $Spec2 eq "W") && $CCHigh > 50  && $AVG_HT > 12) 
	    { $WetlandCode = "S,T,N,N,"; }
	  	elsif (($Spec1 eq "L" && $Spec1Per== 100) && $CCHigh <= 50) 
	    { $WetlandCode = "F,T,N,N,"; }
	  	elsif (($Spec1 eq "L" || $Spec1 eq "W") && $Spec1Per== 100 && ($CCHigh > 50  &&  $CCHigh < 70) )
	    { $WetlandCode = "S,T,N,N,"; }
        elsif (($Spec1 eq "L" || $Spec1 eq "W") && $Spec1Per== 100 && ($CCHigh > 70) )
	    { $WetlandCode = "S,F,N,N,"; }	
	}
	  
	if ($WetlandCode eq "") {$WetlandCode = MISSCODE;}
	#$WetlandCode = MISSCODE.",".MISSCODE.",".MISSCODE.",".MISSCODE.",";
	return $WetlandCode;
}


sub YTinv_to_CAS 
{
	my $YT_File = shift(@_);
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
	my $nbdrops=0;

	# if ($YT_File !~ m/\.txt/) { $YT_File = $YT_File . ".txt"; }
	# if ($CAS_File =~ m/\./) { return 1; }

	my $CAS_File_HDR = $CAS_File . ".hdr";
	my $CAS_File_CAS = $CAS_File . ".cas";
	my $CAS_File_LYR = $CAS_File . ".lyr";
	my $CAS_File_NFL = $CAS_File . ".nfl";
	my $CAS_File_DST = $CAS_File . ".dst";
	my $CAS_File_ECO = $CAS_File . ".eco";

	#open (YTinv, "<$YT_File") || die "\n Error: Could not open Yukon 0001 input file!\n";
	#my $csv = Text::CSV_XS->new();
	open (ERRS, ">>$ERRFILE") || die "\n Error: Could not open $ERRFILE file!\n";
	open (SPERRSFILE, ">>$SPERRS") || die "\n Error: Could not open $SPERRS file!\n";
	open (SPECSLOGFILE, ">>$SPECSLOG") || die "\n Error: Could not open $SPECSLOG file!\n";
	
	if($optgroups==1)
	{

	 	$CAS_File_HDR = $pathname."/YTtable.hdr";
	 	$CAS_File_CAS = $pathname."/YTtable.cas";
	 	$CAS_File_LYR = $pathname."/YTtable.lyr";
	 	$CAS_File_NFL = $pathname."/YTtable.nfl";
	 	$CAS_File_DST = $pathname."/YTtable.dst";
	 	$CAS_File_ECO = $pathname."/YTtable.eco";
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
		
	
		print CASCAS "CAS_ID,ORIG_STAND_ID,STAND_STRUCTURE,NUM_OF_LAYERS,IDENTIFICATION_ID,MAP_SHEET_ID,GIS_AREA,GIS_PERIMETER,INVENTORY_AREA,PHOTO_YEAR\n";
		print CASLYR "CAS_ID,SOIL_MOIST_REG,STRUCTURE_PER,LAYER,LAYER_RANK,CROWN_CLOSURE_UPPER,CROWN_CLOSURE_LOWER,HEIGHT_UPPER,HEIGHT_LOWER,PRODUCTIVE_FOR,". 		
		"SPECIES_1,SPECIES_PER_1,SPECIES_2,SPECIES_PER_2,SPECIES_3,SPECIES_PER_3,SPECIES_4,SPECIES_PER_4,SPECIES_5,SPECIES_PER_5,SPECIES_6,SPECIES_PER_6,SPECIES_7,SPECIES_PER_7,".
		"SPECIES_8,SPECIES_PER_8,SPECIES_9,SPECIES_PER_9,SPECIES_10,SPECIES_PER_10,ORIGIN_UPPER,ORIGIN_LOWER,SITE_CLASS,SITE_INDEX\n";
		print CASNFL "CAS_ID,SOIL_MOIST_REG,STRUCTURE_PER,LAYER,LAYER_RANK,CROWN_CLOSURE_UPPER,CROWN_CLOSURE_LOWER,HEIGHT_UPPER,HEIGHT_LOWER,NAT_NON_VEG,NON_FOR_ANTH,NON_FOR_VEG\n";
		print CASDST "CAS_ID,DIST_1,DIST_YR_1,DIST_EXT_UPPER_1,DIST_EXT_LOWER_1,DIST_2,DIST_YR_2,DIST_EXT_UPPER_2,DIST_EXT_LOWER_2,DIST_3,DIST_YR_3,DIST_EXT_UPPER_3,DIST_EXT_LOWER_3,LAYER\n";
		print CASECO "CAS_ID,WETLAND_TYPE,WET_VEG_COVER,WET_LANDFORM_MOD,WET_LOCAL_MOD,ECO_SITE\n";
		print CASHDR "IDENTIFICATION_ID,JURISDICTION,COORDINATE_SYS,PROJECTION,DATUM,INVENTORY_OWNER,LAND_OWNER,PERMISSION,TENURE_TYPE,INV_TYPE,INV_VERSION,INV_START_YR,INV_FINISH_YR,INV_ACQ_ID,INV_ACQ_YR,INV_UPDATE_YR\n";

		my $HDR_Record =  "1,YK,,Albers,NAD83,TERRITORY,,,,YVI,2.1,1999,2004,,,,";
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

	

	my @Fields; my $CAS_ID; my $IdentifyID;my $StandID;my $MapSheetID;my $Area; my $Perimeter;my $PHOTO_YEAR;
	my $MoistReg;my $Density; my $Height; my $Sp1;my $Sp1Per;my $Sp2;my $Sp2Per;my $Sp3;my $Sp3Per;my $Sp4;  my $Sp4Per; my $Struc; my $StrucVal;
	my $Origin;my $TPR; my $Initials;  

	my $NFL; my $NFLPer;my $NatNon;my $AnthVeg; my $AnthNon;my $Mod1;my $Mod1Ext;my $Mod1Yr;my $Mod2;my $Mod2Ext;my $Mod2Yr;  my $Data; my $DataYr; 

	my $MoistCode;my $Mod3; 
	my $Mod3Ext; my $Mod3Yr;my $IntTpr;
	my $SMR; my $StandStructureCode;my $StandStructureVal; 
	my $CCHigh;my $CCLow; ;my $HeightHigh; 
	my $SpeciesComp;  my $Ageact;
	my $SiteClass; my $SiteIndex;my $Wetland;

	my $NonForVeg; my $NonForAnth; 
	my $Dist1; my $Dist2; my $Dist3; 
	my $Dist1ExtHigh; my $Dist2ExtHigh; my $Dist3ExtHigh; 
	my $Dist1ExtLow; my $Dist2ExtLow; my $Dist3ExtLow; 

	my $NatNonVeg;
	my $Dist; my $UDist; 
	my $Class; my $ClassMod; my $Type_lnd;my $TPRI;

	my %herror=();
	my $keys;
	my $ndrops=0;

	my $CAS_Record; my $Lyr_Record; my $LYR_Record1; my $LYR_Record2; my $LYR_Record3;
	my $NFL_Record; my $NFL_Record1; my $NFL_Record2; my $NFL_Record3; my $DST_Record; 
	#01-08-2011 ---- variables added to  the newly coded CAS_ID
	my $pr1; my $pr2; my $pr3; my $pr4; my $pr5;
	my $HeightLow; my $UnprodFor;
	my $NUMBER_OF_LAYERS; my $TypeLND; my $CLMOD; my $auxCLASS; my $nb_null_photo =0;
	#CAS_ID	MAPSHEET	HEADER_ID	AREA	PERIMETER	Poly_NUM	REF_YEAR	MAP	LANDPOS	SMR	TYPE_LND	CLASS	CL_MOD	SP1	SP1_PER	SP2	SP2_PER	SP3	SP3_PER	SP4	SP4_PER	AVG_HT	MIN_HT	MAX_HT	CC	AGE	DIST_CODE1	DIST_CODE2	SITE_INDEX	SITE_CLASS	STRATUM	FIELD_PLT	TYPE_FOR	POLY_NO	AREA_1	LEN																																																																																																																																																																																																																												
	#my $NULL = <YTinv>;
	#while(<YTinv>) {
	##############################################

	my $csv = Text::CSV_XS->new
	({  
		binary              => 1,
		sep_char    => ";" 
	});
    open my $YTinv, "<", $YT_File or die " \n Error: Could not open YT input file $YT_File: $!";
	
	my @tfilename= split ("/", $YT_File);
	my $nps=scalar(@tfilename);
	$Glob_filename= $tfilename[$nps-1];
	$NUMBER_OF_LAYERS=1;

 	$csv->column_names ($csv->getline ($YTinv));

   	while (my $row = $csv->getline_hr ($YTinv)) 
   	{	#print "CAS_ID is $row->{CAS_ID}  and AREA is $row->{AREA} \n"; #exit(0);

	
		#CAS_ID,MAPSHEET,HEADER_ID,AREA,PERIMETER,Poly_NUM,REF_YEAR,MAP,LANDPOS,SMR,TYPE_LND,CLASS,CL_MOD,SP1,SP1_PER,SP2,SP2_PER,SP3,SP3_PER,SP4,SP4_PER,AVG_HT,MIN_HT,
		#MAX_HT,CC,AGE,DIST_CODE1,DIST_CODE2,SITE_INDEX,SITE_CLASS,STRATUM,FIELD_PLT,TYPE_FOR,POLY_NO,AREA_1,LEN

		#################################################################

		#01-08-2011 added because of the new codification of CAS_ID

	 

		$Glob_CASID   =  $row->{CAS_ID};
		($pr1,$pr2,$pr3, $pr4, $pr5)     =  split("-", $row->{CAS_ID} );  
		$CAS_ID = $row->{CAS_ID}; 	    
    	$MapSheetID   =  $pr3; 
    	$MapSheetID =~ s/x+//;
		$IdentifyID = $row->{HEADER_ID};  
		# faut-t-il supprimer les 0 du d/but? si oui faire la ligne suivante, sinon la supprimer
		$StandID = $pr4;
		$StandID =~ s/^0+//;
		if ($StandID eq "") 
		{
	        $StandID = "0";
	    }
 
		$Area    =  $row->{GIS_AREA};
		$Perimeter =  $row->{GIS_PERI};	
		$PHOTO_YEAR = $row->{REF_YEAR};
		

		$TypeLND=$row->{TYPE_LND};
		$TypeLND =~ s/\s//g;
		$CLMOD=$row->{CL_MOD};
		$CLMOD=~ s/\s//g;
		$auxCLASS=$row->{CLASS};
		$auxCLASS=~ s/\s//g;


		$SMR = SoilMoistureRegime($row->{SMR});
		  	 
		if($SMR eq ERRCODE) 
		{ 
			$keys="MoistReg"."#".$row->{SMR};
			$herror{$keys}++;	
		}
		
		$StandStructureCode = "S";
		$StandStructureVal = UNDEF;

		$CCHigh = CCUpper($row->{CC});
		$CCLow = CCLower($row->{CC});
		if($CCHigh  eq ERRCODE   || $CCLow  eq ERRCODE) 
		{ 
		 	$keys="Density"."#".$row->{CC};
			$herror{$keys}++;
		}
		  

	    if($row->{MIN_HT} eq "0" || $row->{MAX_HT} eq "0")
	    {
	 		$HeightHigh = StandHeight($row->{AVG_HT});
 	  		$HeightLow = StandHeight($row->{AVG_HT});
	   	}
	   	else 
	   	{
	  		$HeightHigh = StandHeight($row->{MAX_HT});
			$HeightLow = StandHeight($row->{MIN_HT});
	  	}

	   	if($HeightHigh == 0 )
	   	{
			if( !isempty($row->{SP1}))
			{ 
				$keys="null height#".$HeightHigh."species#".$row->{SP1}."#casid#".$CAS_ID."#typefor#".$row->{TYPE_FOR}."#typeclass#".$TypeLND;
              	$herror{$keys}++; 
				$HeightHigh=MISSCODE;
				$HeightLow=MISSCODE;
			}
			else 
			{
				$HeightLow=MISSCODE;
				$HeightHigh=MISSCODE;
			}
		}
	   	elsif($row->{MIN_HT} eq "0" || $row->{MAX_HT} eq "0")
	   	{
	 		$HeightLow=$HeightLow - 0.5;
			$HeightHigh=$HeightHigh + 0.5;
	  	}
	  	$SpeciesComp = Species($row->{SP1},$row->{SP1_PER},$row->{SP2},$row->{SP2_PER},$row->{SP3},$row->{SP3_PER},$row->{SP4},$row->{SP4_PER},$spfreq);

	  	my @SpecsPerList  = split(",", $SpeciesComp); 

	  	my $TotalPerctg = $SpecsPerList[1] + $SpecsPerList[3] +$SpecsPerList[5] +$SpecsPerList[7];
	  	if($TotalPerctg >100) {

			$keys="check Species function !!! Total species percentage > 100 in $SpeciesComp\n";
			$herror{$keys}++; 
		}

	  	if($SpecsPerList[0]  eq SPECIES_ERRCODE ) 
		{ 
			$keys = "Species#".$row->{SP1};
            $herror{$keys}++; 
	 	}
 		if($SpecsPerList[2]  eq SPECIES_ERRCODE ) 
		{ 
			$keys = "Species#".$row->{SP2};
             $herror{$keys}++; 
	 	}
 		if($SpecsPerList[4]  eq SPECIES_ERRCODE ) 
		{ 
			$keys = "Species#".$row->{SP3};
            $herror{$keys}++; 
	 	}
 		if($SpecsPerList[6]  eq SPECIES_ERRCODE ) 
		{ 
			$keys = "Species#".$row->{SP4};
            $herror{$keys}++; 
	 	}
   				
	  	$SpeciesComp = $SpeciesComp .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";

		if ($PHOTO_YEAR <= 0 || $PHOTO_YEAR >2014) 
		{
			print "check this photoyear $PHOTO_YEAR \n";
			$nb_null_photo ++;
			$keys="photoyear "."#".$PHOTO_YEAR."#taken from#".$row->{REF_YEAR};
			$herror{$keys}++;
	  	}
	  

		if(isempty($row->{AGE}))	
		{
			$Origin = $row->{REF_YEAR}; 
		}
	  	elsif ( isempty($row->{REF_YEAR})== 0 &&  $row->{REF_YEAR} ne "0") 
	  	{
	  		$Origin = $row->{REF_YEAR}-$row->{AGE}; 
	  	}
	  	else 
	  	{
	  		$Origin = MISSCODE; 
	  	}	  

	  	if( $Origin>2014 || ($Origin <1700 && $Origin >0) ) 
	  	{ 
			$keys="bounds for ref_year"."#".$row->{REF_YEAR}."#age=".$row->{AGE}."#casid#".$CAS_ID;
			$herror{$keys}++;
			$Origin=ERRCODE;
	  	}

	  	$SiteClass = Site($row->{SITE_CLASS});
	 	if($SiteClass  eq ERRCODE) 
	 	{ 
	 		if($TypeLND eq "NW" || $TypeLND eq "NE")
	 		{
	 			$SiteClass=MISSCODE;
	 		}
			elsif($TypeLND eq "VN" || isempty($TypeLND) )
			{
				$SiteClass="P";
			}
			else 
			{ 
				$keys="SiteClass"."#".$row->{SITE_CLASS}."######AND ID is ".$row->{CAS_ID}."#species#".$row->{SP1}.",".$row->{SP2}.",".$row->{SP3}.",".$row->{SP4}."#Height#".$row->{AVG_HT}."#Age#".$Origin."#CoverType#".$TypeLND."#Class#". $row->{CLASS}."#Class_modifier#".$CLMOD;
				$herror{$keys}++;
			}
		}

	  	$SiteIndex = SiteIndex($row->{SITE_INDEX}); #"";

	  	if($SiteIndex  eq ERRCODE) 
	  	{ 
	  		$keys="SiteIndex"."#".$row->{SITE_INDEX};
			$herror{$keys}++;
		}

	  	$Wetland = WetlandCodes ($row->{SMR}, $row->{CC}, $row->{CLASS}, $row->{SP1}, $row->{SP2}, $row->{SP1_PER}, $row->{AVG_HT});
		#  if($Wetland  eq "") { $keys="WETLAND-MoistReg"."#".$MoistReg."#".$NFL."#".$Sp1."#".$Sp2."#".$Sp1Per."#".$Sp3."#".$Sp4."#".$Sp5;
						   #  $herror{$keys}++;
						#}
	

  		# ===== Non-forested Land =====

		$NatNonVeg = MISSCODE; $NonForVeg=MISSCODE;$NonForAnth =MISSCODE;$UnprodFor=MISSCODE;
		#$TypeLND=$row->{TYPE_LND}; s/\s//g;
		#$CLMOD=$row->{CL_MOD};s/\s//g;
		#$auxCLASS=$row->{CLASS};s/\s//g;
		if($TypeLND eq "NW" || $TypeLND eq "NS" || $TypeLND eq "NE"  ||  (isempty($TypeLND) &&  (!isempty($auxCLASS) || !isempty($CLMOD)))) 
		{

		 	$NatNonVeg = NaturallyNonVeg($auxCLASS, $CLMOD, 0);
	 	 	if($NatNonVeg  eq ERRCODE) 
	 	 	{ 
	 	  		$keys="NatNon"."#".$NatNonVeg;
				$herror{$keys}++;			
		  		$NonForVeg = NonForestedVeg($auxCLASS, $CLMOD);
		  	}
		 	if($row->{TYPE_FOR} eq "A" || $TypeLND eq "NS")
		 	{
				$NatNonVeg="AP"; # changeb by BK on 04042013; $UnprodFor="AP";
			}
		}
	  
		if($TypeLND eq "NU" ||  (isempty($TypeLND) &&  (!isempty($auxCLASS)))) 
		{ 

			$NonForAnth = NonForestedAnth($auxCLASS);
			if($NonForAnth   =~ /-9999/) 
			{ 
				$NatNonVeg = NaturallyNonVeg($auxCLASS, $auxCLASS, 0);
				$NonForVeg = NonForestedVeg($auxCLASS, $auxCLASS);
				$keys="changed natnonveg, type clas= NU and nonforanth errcode"."#".$auxCLASS;
				$herror{$keys}++;
				if($NatNonVeg eq ERRCODE && $NonForVeg eq ERRCODE) 
				{
					$keys="AnthVeg"."#".$auxCLASS."-clmod"."#".$CLMOD."-type_lnd"."#".$TypeLND."init=$NonForAnth";
				    $herror{$keys}++;
				}
			}
		}	

		if($TypeLND eq "VN" ||  (isempty($TypeLND) &&  (!isempty($auxCLASS) || !isempty($CLMOD)))) 
		{ 
			$NonForVeg = NonForestedVeg($auxCLASS, $CLMOD);
			if($auxCLASS eq "RR") 
			{							#added to avoid errcode in NFL
				$NatNonVeg = NaturallyNonVeg($auxCLASS, $CLMOD, 0);
			}
			#if($NonForVeg   =~ /-9999/) { $keys="NFL"."#".$auxCLASS."#".$CLMOD."turn into Natnonveg#".$NatNonVeg;
			#	$herror{$keys}++;
			#}	
		}	
	 
		if( isempty($auxCLASS) && isempty($CLMOD) && !isempty($row->{TYPE_FOR})) 
		{

			if($row->{TYPE_FOR} eq "NP" || $row->{TYPE_FOR} eq "KNP")
			{
				$UnprodFor="NP";
			}
		 	elsif( $row->{TYPE_FOR} eq "U")
		 	{
				$NonForAnth="SE";
			}
		 	elsif($row->{TYPE_FOR} eq "NSR")
		 	{
				$Dist1="UK";
			}
 			elsif($row->{TYPE_FOR} eq "A" && isempty($row->{SP1})==0)
 			{
				$UnprodFor="AL";$SiteClass="U";
			}
			elsif($row->{TYPE_FOR} eq "A" && isempty($row->{SP1}))
			{
				$NatNonVeg ="AP"; # $keys="found AP#".$TypeLND;
				#$herror{$keys}++;
			}
		 	else
		 	{
				$NatNonVeg = NaturallyNonVeg($auxCLASS, $row->{TYPE_FOR}, 1);
		 	}	  
		}
 	
	
	  	# ===== Modifiers =====
		$spfreq->{"dst#".$row->{DIST_CODE1}}++;
		$spfreq->{"dst#".$row->{DIST_CODE2}}++;
		$Dist1 = Disturbance($row->{DIST_CODE1});   # result is DISTCODE1.",".YEAR
		$Dist1 = $Dist1 . "," . UNDEF . "," . UNDEF;
		$Dist2 = Disturbance($row->{DIST_CODE2});
		$Dist2 = $Dist2 . "," . UNDEF. "," . UNDEF;
		# $Dist2 = $Dist2 . "," . $Dist2ExtHigh . "," . $Dist2ExtLow;
		# $Dist3 = $Dist3 . "," . $Dist3ExtHigh . "," . $Dist3ExtLow;
		$Dist = $Dist1 . "," . $Dist2. "," . UNDEF. "," .UNDEF. "," .UNDEF. "," .UNDEF;
			
		my @pdist1= split (",", $Dist1 );
  		if($pdist1[0]  eq ERRCODE) 
  		{ 
  			$keys = "Disturbance"."#".$row->{DIST_CODE1};
			$herror{$keys}++;
		}
		my @pdist2= split (",", $Dist2 );
  		if($pdist2[0]  eq ERRCODE ) 
  		{ 
  			$keys="Disturbance"."#".$row->{DIST_CODE2};
			$herror{$keys}++;
		}
        # $Dist = $Dist1 . "," . $Dist2 . "," . $Dist3; 
		$nbpr=0;

		# ======================================================= WRITING Output inventory info IN CAS FILES =================================================================================================
		my $prod_for = "PF";
		my $lyr_poly = 0;
		if(isempty($row->{SP1}))
		{
			$SpeciesComp="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
			
			if ($UnprodFor ne MISSCODE && $UnprodFor ne ERRCODE && $UnprodFor ne UNDEF)
			{
				$prod_for = $UnprodFor;
				$lyr_poly = 1;
			}
			elsif ( ($row->{CC} ne "0" && (!is_missing($CCHigh) ||  !is_missing($CCLow))) || !is_missing($HeightHigh) || !is_missing($HeightLow))
			{
				$prod_for = "PP";
				$lyr_poly = 1;
			}
		}
		if($pdist1[0] eq "CO")
		{
			$prod_for="PF";
			$lyr_poly=1;
		}

	  	# ===== Output inventory info for layer 1 =====
	  	if (($StandStructureCode eq "S") ) 
	  	{
	   		$CAS_Record = $CAS_ID . "," . $StandID . "," . $StandStructureCode .",". $NUMBER_OF_LAYERS.",". $IdentifyID . "," . $MapSheetID . "," . $Area . "," . $Perimeter . ",".$Area. ",".$PHOTO_YEAR;
	    	print CASCAS $CAS_Record . "\n";
	     	$nbpr=1;$$ncas++;$ncasprev++;
            #forested
	   		#if (!isempty($row->{SP1}) || $UnprodFor ne MISSCODE) {
  			if (!isempty($row->{SP1}) || $lyr_poly==1) 
  			{

				#if(isempty($row->{SP1}) && $UnprodFor ne MISSCODE){
				#$SpeciesComp ="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
				#}
				#if(!isempty($row->{SP1}) && $UnprodFor ne MISSCODE){
					#print "check this config species1 non null --$row->{SP1}-- specomp= $SpeciesComp, typefor= $row->{TYPE_FOR} but unprodfor == $UnprodFor\n";
				#	$keys="check this config species1 non null --".$row->{SP1}."-- specomp= ".$SpeciesComp.", typefor= ".$row->{TYPE_FOR}." but unprodfor ==". $UnprodFor."\n";
				#				   $herror{$keys}++;
				#}

		     	$LYR_Record1 = $row->{CAS_ID} . "," . $SMR  . ",". $StandStructureVal . ",1,1";
		      	$LYR_Record2 = $CCHigh . "," . $CCLow . "," . $HeightHigh . "," . $HeightLow . "," . $prod_for.",".$SpeciesComp;
		      	$LYR_Record3 = $Origin . "," . $Origin . "," . $SiteClass . "," . $SiteIndex;
		      	$Lyr_Record = $LYR_Record1 . "," . $LYR_Record2 . "," . $LYR_Record3;
		      	print CASLYR $Lyr_Record . "\n";
				$nbpr++; $$nlyr++;$nlyrprev++;
	    	}
            #non-forested
	    	#elsif ($NatNonVeg ne MISSCODE || $NonForAnth ne MISSCODE || $NonForVeg ne MISSCODE) 
	    	elsif ( !is_missing($NatNonVeg) || !is_missing($NonForAnth) || !is_missing($NonForVeg) )
	    	{
	    		#if ($NonForVeg ne MISSCODE || $NonForAnth ne MISSCODE || $NonForVeg ne MISSCODE) {
	      		$NFL_Record1 = $row->{CAS_ID} . "," . $SMR  . "," . $StandStructureVal . ",1,1";
	      		$NFL_Record2 = $CCHigh . "," . $CCLow . "," . $HeightHigh . "," . $HeightLow;
              	$NFL_Record3 = $NatNonVeg . "," . $NonForAnth . "," . $NonForVeg;
              	$NFL_Record = $NFL_Record1 . "," . $NFL_Record2 . "," . $NFL_Record3;
	      		print CASNFL $NFL_Record . "\n";
				$nbpr++;$$nnfl++;$nnflprev++;
	    	}
            #Disturbance
	   		# if ($row->{DIST_CODE1} ne "" || $row->{DIST_CODE2} ne "") {
  	   		if ($pdist1[0] ne MISSCODE && $pdist1[0] ne ERRCODE) 
  	   		{
	      		$DST_Record = $row->{CAS_ID} . "," . $Dist. ",1";
	      		print CASDST $DST_Record . "\n";
				if($nbpr==1) 
				{
					$$ndstonly++; 
					$ndstonlyprev++;
				}
				$nbpr++;$$ndst++;$ndstprev++;
	    	}
	   		elsif(isempty($row->{DIST_CODE1})  && $row->{TYPE_FOR} eq "NSR")
	   		{
				$Dist="UK,-1111,-8888,-8888,-1111,-1111,-8888,-8888,-8888,-8888,-8888,-8888";
		 		$DST_Record = $row->{CAS_ID} . "," . $Dist. ",1";
		      	print CASDST $DST_Record . "\n";
				if($nbpr==1) 
				{
					$$ndstonly++; 
					$ndstonlyprev++;
				}
				$nbpr++;$$ndst++;$ndstprev++;
	  		}
	    	#Ecological 
		    if ($Wetland ne MISSCODE) 
		    {
		    	$Wetland = $row->{CAS_ID} . "," . $Wetland."-";
		      	print CASECO $Wetland . "\n";
				if($nbpr==1) 
				{
					$$necoonly++;
					$necoonlyprev++;
				}
				$nbpr++;$$neco++;$necoprev++;
		    }
	  	}

		if($nbpr ==1 )
		{
			$ndrops++;
			if(isempty($row->{SP1}) &&  isempty($row->{DIST_CODE1})  &&   isempty($TypeLND) && isempty($row->{SMR})  ) 
			{
				if(isempty($auxCLASS) && isempty($CLMOD))
				{
					$keys ="WILL PROBABLY DROP THIS>>>TYPEFOR=".$row->{TYPE_FOR}."natnonveg=".$NatNonVeg."unprodfor=$UnprodFor";
 					$herror{$keys}++; 
				}
				else 
				{
					$keys ="WILL DROP THIS>>>empty-TYPEFOR=".$auxCLASS."-CLMOD=".$CLMOD."-TYPEFOR=".$row->{TYPE_FOR};
 					$herror{$keys}++; 
				}
			}
			elsif( isempty($row->{SP1}) &&  isempty($row->{DIST_CODE1} ) && !isempty($TypeLND) && isempty($auxCLASS) && isempty($CLMOD) ) 
			{
				$keys ="WILL DROP althaugh there is a TYPELND>>>typefor = ".$row->{TYPE_FOR}."-TYPELND = ".$TypeLND;
 				$herror{$keys}++; 
			}
			else
			{
				#$keys ="!!! record may be dropped#".$CAS_ID."bcse>>>specs=".$row->{SP1}."-distcode=".$row->{DIST_CODE1}."-SMR=".$row->{SMR}."-CLASS=".$auxCLASS."-CC=".$CLMOD."-TYPELND=".$TypeLND;
 				#$herror{$keys}++; 
				$keys ="#droppable#";
 				$herror{$keys}++; 
			}
		}
	#end while         
   	}

 	$csv->eof or $csv->error_diag ();
  	close $YTinv;

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
	#close (YTinv);
	print "nb null photoyear = $nb_null_photo\n";
	print "nbrs of 2 digits modyear = $cpt2\n";
	print "nbrs of 4 digits modyear = $cpt4\n";
	close (CASHDR);
	close (CASCAS);
	close (CASLYR);
	close (CASNFL);
	close (CASDST);
	close (CASECO);
	close(ERRS);
	close(SPERRSFILE); close(SPECSLOGFILE); 
	$total=$nlyrprev+ $nnflprev+  $ndstprev + $necoprev;
	#if($total > $ncasprev) {print "must check this !!! \n";}
	#rint "$ncasprev, $nlyrprev, $nnflprev,  $ndstprev, $necoprev, $total\n";
	$total2=$nlyrprev+ $nnflprev+  $ndstonlyprev + $necoonlyprev;
	#print "drops = $ndrops nb records in casfile : $ncasprev, lyrfile : $nlyrprev, nflfile : $nnflprev,  dstfile : $ndstprev, ecofile : $necoprev--- total (without .cas): $total\n";
	print " drops = $ndrops,  nb records in casfile : $ncasprev, lyrfile : $nlyrprev, nflfile : $nnflprev,  dstfile : $ndstprev($ndstonlyprev), ecofile : $necoprev($necoonlyprev)--- total (without .cas): $total($total2)\n";
}


1;
#province eq "YT";

