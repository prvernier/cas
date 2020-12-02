package ModulesV4::MBFLI_LP_conversion15;


use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(&MBFLIinv_to_CAS );
#our @EXPORT_OK = qw(%spfreq);
our $hdr_num;
#our %spfreq;
our $nbas=0;
our $Species_table;	
# our is a global variable that the main script will call
#our @EXPORT_OK = qw(@tabSpec &SoilMoistureRegime1 &SoilMoistureRegime2  &CCUpper  &CCLower &StandHeightUp &StandHeightLow &UpperOrigin &UpperOriginCompl &LowerOrigin &LowerOriginCompl  &Disturbance &DisturbanceM );

use strict;
use Text::CSV;

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
		
	if($val eq MISSCODE || $val eq ERRCODE || $val eq UNDEF) 
	{
		return 1;
	}
	else 
	{
		return 0;
	}	
}
# sub indicate a function
#StandStructure from $CANLAY (version FLI)   
sub StandStructure
{
	my $Struc;
	# list variable that you expect by the CAS. 
	my %StrucList = ("", 1, "S", 1, "V", 1, "C", 1, "M", 1, "U", 1, "s", 1, "v", 1, "v", 1, "m", 1, "u", 1);
	my $StandStructure;


	($Struc) = shift(@_);
	if (isempty($Struc)) {$StandStructure = "S"; }
	elsif (!$StrucList {$Struc} ) {  $StandStructure = ERRCODE; }

	# Converion parameters following John rules
	elsif (($Struc eq "S")|| ($Struc eq "s"))               { $StandStructure = "S"; }
	elsif (($Struc eq "v") || ($Struc eq "V"))               { $StandStructure = "V"; }
	elsif (($Struc eq "c") || ($Struc eq "C"))               { $StandStructure = "C"; }
    elsif (($Struc eq "m") || ($Struc eq "M"))               { $StandStructure = "M"; }
	elsif (($Struc eq "u") || ($Struc eq "U"))               { $StandStructure = "U"; }
	else  {  $StandStructure = ERRCODE; }

	return $StandStructure;
}
#number of layers derived from SEQ : canrank


#SoilMoistureRegime  from $MR
sub SoilMoistureRegime
{
	my $MoistReg;
	my %MoistRegList = ("", 1, "1", 1, "2", 1, "3", 1, "4", 1, "d", 1, "f", 1, "v", 1, "m", 1, "w", 1, "D", 1, "F", 1, "V", 1, "M", 1, "W", 1);

	my $SoilMoistureReg;

	($MoistReg) = shift(@_);  

	if (isempty($MoistReg))    { $SoilMoistureReg = MISSCODE; }

	elsif (!$MoistRegList {$MoistReg} ) { $SoilMoistureReg = ERRCODE; }
	elsif (($MoistReg eq "d") || ($MoistReg eq "D"))         { $SoilMoistureReg = "D"; }
	elsif (($MoistReg eq "m") || ($MoistReg eq "M"))         { $SoilMoistureReg = "M"; }
	elsif (($MoistReg eq "w") || ($MoistReg eq "W"))         { $SoilMoistureReg = "W"; }
	elsif (($MoistReg eq "f") || ($MoistReg eq "F"))         { $SoilMoistureReg = "F"; }
    elsif (($MoistReg eq "v") || ($MoistReg eq "V"))         { $SoilMoistureReg = "F"; }
	else { $SoilMoistureReg = ERRCODE; }
	return $SoilMoistureReg;
}


sub CCUpper 
{
	my $CCHigh;
	my $CC; 
	my $CANLAY;

	($CC) = shift(@_);  
	($CANLAY) = shift(@_);

	if (isempty($CC))   {$CC ="";}
	if (isempty($CANLAY)) {$CANLAY ="";}

    if ($CC eq "") { $CCHigh = MISSCODE; }
	elsif ($CC == 0  && $CANLAY eq "V")  { $CCHigh = 5; }
	elsif ($CC == 0)  { $CCHigh = 10; }
	elsif ($CC == 1)  { $CCHigh = 20; }
	elsif ($CC == 2)  { $CCHigh = 30; }
	elsif ($CC == 3)  { $CCHigh = 40; }
    elsif ($CC == 4)  { $CCHigh = 50; }
	elsif ($CC == 5)  { $CCHigh = 60; }
	elsif ($CC == 6)  { $CCHigh = 70; }
	elsif ($CC == 7)  { $CCHigh = 80; }
    elsif ($CC == 8)  { $CCHigh = 90; }
	elsif ($CC == 9)  { $CCHigh = 100; }
	else { $CCHigh = ERRCODE; }

	return $CCHigh;
}

sub CCLower 
{
	my $CCLow;
	my $CC; my $CANLAY;

    ($CC) = shift(@_);  ($CANLAY) = shift(@_);

	if (isempty($CC))   {$CC ="";}
	if (isempty($CANLAY)) {$CANLAY ="";}

	if ($CC eq "") { $CCLow = MISSCODE; }
	elsif ($CC == 0 && $CANLAY eq "V")  { $CCLow = 1; }
	elsif ($CC == 0)  { $CCLow = 6; }
	elsif ($CC == 1)  { $CCLow = 11; }
	elsif ($CC == 2)  { $CCLow = 21; }
	elsif ($CC == 3)  { $CCLow = 31; }
    elsif ($CC == 4)  { $CCLow = 41; }
	elsif ($CC == 5)  { $CCLow = 51; }
	elsif ($CC == 6)  { $CCLow = 61; }
	elsif ($CC == 7)  { $CCLow = 71; }
    elsif ($CC == 8)  { $CCLow = 81; }
	elsif ($CC == 9)  { $CCLow = 91; }
	else { $CCLow = ERRCODE; }

	return $CCLow;
}

#from $HEIGHT

sub StandHeight 
{
	my $Height;
	my $COMHT;
	my $Canlay; my $numb; #to say if it is Low or High

	($Height) = shift(@_);
	($COMHT) = shift(@_);
	($Canlay) = shift(@_);
	($numb) = shift(@_);

	if (isempty($Height)) {$Height = "";}
	if (isempty($COMHT))  {$COMHT = 0;}
	if (isempty($Canlay)) {$Canlay = "";}
	if (isempty($numb)) {$numb = 0;}

	if  ($Height eq "")      { $Height = MISSCODE; }
	elsif (($Height <= 0)    || ($Height > 50))  { $Height = MISSCODE; }
	else 
	{ 
		if ($Canlay eq "C") 
		{
			if($numb >=0) {$Height = $Height+$COMHT;} 
			else {$Height =$Height-$COMHT;}
		}
		else {$Height = $Height; }
	}

	return $Height;
}

sub Latine 
{
	my $CurrentSpecies = shift(@_);
	my $GenusSpecies;

	$_ = $CurrentSpecies;
	tr/a-z/A-Z/;
	$CurrentSpecies = $_;

	if (isempty($CurrentSpecies))   { $GenusSpecies = "XXXX MISS"; }

	elsif ($Species_table->{$CurrentSpecies}) { $GenusSpecies = $Species_table->{$CurrentSpecies}; }
	else 	 {$GenusSpecies = SPECIES_ERRCODE;  print SPECSLOGFILE "Illegal species code $CurrentSpecies, CAS_ID=$Glob_CASID, file=$Glob_filename\n";  }  
	return $GenusSpecies;
}

#6 Species fields  SP#  and SP#PER
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
    my $Sp6    = shift(@_);
	my $Sp6Per = shift(@_);
	my $spfreq = shift(@_);

	my $Species;
	my $CurrentSpec;


	if(isempty($Sp1Per))
	{
		$Sp1Per = 0;
	}
	if(isempty($Sp2Per))
	{
		$Sp2Per = 0;
	}
	if(isempty($Sp3Per))
	{
		$Sp3Per = 0;
	}
	if(isempty($Sp4Per))
	{
		$Sp4Per = 0;
	}
	if(isempty($Sp5Per))
	{
		$Sp5Per = 0;
	}
	if(isempty($Sp6Per))
	{
		$Sp6Per = 0;
	}
 	

	$spfreq->{$Sp1}++;
	$spfreq->{$Sp2}++;
	$spfreq->{$Sp3}++;
	$spfreq->{$Sp4}++;
	$spfreq->{$Sp5}++;
	$spfreq->{$Sp6}++;
	$Sp1 = Latine($Sp1); $Sp2 = Latine($Sp2); $Sp3 = Latine($Sp3); $Sp4 = Latine($Sp4); $Sp5 = Latine($Sp5); $Sp6 = Latine($Sp6);
	$Sp1Per=10*$Sp1Per; $Sp2Per=10*$Sp2Per; $Sp3Per=10*$Sp3Per; $Sp4Per=10*$Sp4Per; $Sp5Per=10*$Sp5Per; $Sp6Per=10*$Sp6Per; 

	$Species = $Sp1 . "," . $Sp1Per . "," . $Sp2 . "," . $Sp2Per . "," . $Sp3 . "," . $Sp3Per . "," . $Sp4 . "," . $Sp4Per . "," . $Sp5 . "," . $Sp5Per . "," . $Sp6 . "," . $Sp6Per;

	return $Species;
}

#from $ORIGIN
sub UpperLowerOrigin 
{
	my $Origin;
	($Origin) = shift(@_);

 	if (isempty($Origin))  {$Origin = MISSCODE;}

	elsif ($Origin eq "0")  {$Origin=MISSCODE;}
	elsif ($Origin > 0) 
	{
	 	$Origin = $Origin; 
	}
	else { $Origin = ERRCODE; }

	return $Origin;
}

#Determine Site from SITE  pre 1997   FLI NONE
sub Site_nofield 
{
	my $Site;
	my $TPR;
	my %TPRList = ("", 1, "1", 1, "2", 1, "3", 1);

	($TPR) = shift(@_);
	if (isempty($TPR))  { $Site = MISSCODE; }
	
	elsif ($TPR eq "1")          { $Site = "G"; }
	elsif (($TPR eq "2"))        { $Site = "M"; }
	elsif (($TPR eq "3") )       { $Site = "P"; }
	else                         { $Site = ERRCODE; }

	return $Site;
}


#UnProdForest TM,TR, ?OM, AL, SD, SC, NP, 
#Natnonveg ==== AP, LA, RI, OC, RK, SD, SI, SL, EX, BE, WS, FL, IS, TF
#NonForestedVeg ---ST, SL, HF, HE, HG, BR, OM, BT
#Anthropogenic IN, FA, CL, SE, LG, BP, OT


#Naturally non-vegetated  NNF_ANTH  (FLI)
sub NaturallyNonVeg 
{
    my $NatNonVeg;
    my %NatNonVegList = ("", 1, "NMB", 1, "NMC", 1, "NMF", 1, "NMR", 1, "NMS", 1, "NMM", 1, "NMG", 1, "NWL", 1, "NWR", 1, "NWF", 1,
				    "nmb", 1, "nmc", 1, "nmf", 1, "nmr", 1, "nms", 1, "nmm", 1, "nmg", 1, "nwl", 1, "nwr", 1, "nwf", 1 );

	($NatNonVeg) = shift(@_);
	if (isempty($NatNonVeg)) { $NatNonVeg = MISSCODE; }
	elsif (!$NatNonVegList {$NatNonVeg} ) { $NatNonVeg = ERRCODE; }

    elsif (($NatNonVeg eq "nmb") || ($NatNonVeg eq "NMB"))     { $NatNonVeg = "EX"; }
    elsif (($NatNonVeg eq "nmc") || ($NatNonVeg eq "NMC"))     { $NatNonVeg = "EX"; }
    elsif (($NatNonVeg eq "nmf") || ($NatNonVeg eq "NMF"))     { $NatNonVeg = "RK"; }
    elsif (($NatNonVeg eq "nmr") || ($NatNonVeg eq "NMR"))     { $NatNonVeg = "RK"; }
    elsif (($NatNonVeg eq "nms") || ($NatNonVeg eq "NMS"))     { $NatNonVeg = "SA"; }
    elsif (($NatNonVeg eq "nmm") || ($NatNonVeg eq "NMM"))     { $NatNonVeg = "EX"; }
    elsif (($NatNonVeg eq "nmg") || ($NatNonVeg eq "NMG"))     { $NatNonVeg = "WS"; }
    elsif (($NatNonVeg eq "nwl") || ($NatNonVeg eq "NWL"))     { $NatNonVeg = "LA"; }
    elsif (($NatNonVeg eq "nwr") || ($NatNonVeg eq "NWR"))     { $NatNonVeg = "RI"; }
    elsif (($NatNonVeg eq "nwf") || ($NatNonVeg eq "NWF"))     { $NatNonVeg = "FL"; }
	else { $NatNonVeg = ERRCODE; }
    return $NatNonVeg;
}

#Non-forested anthropologocal stands
sub NonForestedAnth 
{
	my $NonForAnth = shift(@_);
	my %NonForAnthList = ("", 1, "CIP", 1, "CIW", 1, "CIU", 1, "ASC", 1, "ASP", 1, "ASR", 1, "ASN", 1, "AIH", 1, "AIR", 1, "AIG", 1, "AII", 1, "AIW", 1, "AIA", 1, "AIF", 1, "AIU", 1,
	"cip", 1, "ciw", 1, "ciu", 1, "asc", 1, "asp", 1, "asr", 1, "asn", 1, "aih", 1, "air", 1, "aig", 1, "aii", 1, "aiw", 1, "aia", 1, "aif", 1, "aiu", 1 );

	
	if  (isempty($NonForAnth))					{ $NonForAnth = MISSCODE; }
	elsif (!$NonForAnthList {$NonForAnth} ) 	{ $NonForAnth = ERRCODE; }
	elsif (($NonForAnth eq "cip") || ($NonForAnth eq "CIP"))	{ $NonForAnth = "FA"; }
	elsif (($NonForAnth eq "ciw") || ($NonForAnth eq "CIW"))	{ $NonForAnth = "FA"; }
	elsif (($NonForAnth eq "ciu") || ($NonForAnth eq "CIU"))	{ $NonForAnth = "OT"; }
	elsif (($NonForAnth eq "asc") || ($NonForAnth eq "ASC"))	{ $NonForAnth = "SE"; }
    elsif (($NonForAnth eq "asp") || ($NonForAnth eq "ASP"))   { $NonForAnth = "FA"; }
    elsif (($NonForAnth eq "asr") || ($NonForAnth eq "ASR"))   { $NonForAnth = "SE"; }
    elsif (($NonForAnth eq "asn") || ($NonForAnth eq "ASN"))   { $NonForAnth = "FA"; }
    elsif (($NonForAnth eq "aih") || ($NonForAnth eq "AIH"))   { $NonForAnth = "FA"; }
    elsif (($NonForAnth eq "air") || ($NonForAnth eq "AIR"))   { $NonForAnth = "FA"; }
    elsif (($NonForAnth eq "aig") || ($NonForAnth eq "AIG"))   { $NonForAnth = "IN"; }
    elsif (($NonForAnth eq "aii") || ($NonForAnth eq "AII"))	{ $NonForAnth = "IN"; }
    elsif (($NonForAnth eq "aiw") || ($NonForAnth eq "AIW"))	{ $NonForAnth = "LG"; }
    elsif (($NonForAnth eq "aia") || ($NonForAnth eq "AIA"))	{ $NonForAnth = "FA"; }
    elsif (($NonForAnth eq "aif") || ($NonForAnth eq "AIF"))   { $NonForAnth = "SE"; }
	elsif (($NonForAnth eq "aiu") || ($NonForAnth eq "AIU"))	{ $NonForAnth = "OT"; }
	else { $NonForAnth = ERRCODE; }
	return $NonForAnth;
}


#Non-forested vegetation stands
sub NonForestedVeg 
{
    my $NonForVeg = shift(@_);
	my $Height=shift(@_);

    my %NonForVegList = ("", 1, "SO", 1, "SC", 1, "HG", 1, "HF", 1, "HU", 1, "BR", 1, "CL", 1, "AL", 1, "CC", 1, "CS", 1, "AS", 1, "VI", 1, "RA", 1, "DL", 1, "AU", 1, 
	"so", 1, "sc", 1, "hg", 1, "hf", 1, "hu", 1, "br", 1, "cl", 1, "al", 1, "cc", 1, "cs", 1, "as", 1, "vi", 1, "ra", 1, "dl", 1, "au", 1  );

	
	if (isempty($NonForVeg)) { $NonForVeg = MISSCODE; }
	else 
	{
	 	#"VA", 1,"va", 1,
    	#if SC followed by a number (e.g., SC7), convert to SC
    	if ((substr $NonForVeg, 0, 2) eq "SC" || (substr $NonForVeg, 0, 2) eq "sc") { $NonForVeg = "SC"; }
		my $cod = (substr $NonForVeg, 0, 2);

		#if SO followed by a number (e.g., S07), convert to ST  or SL
	    if (((substr $NonForVeg, 0, 2) eq "SO" || (substr $NonForVeg, 0, 2) eq "so")  && (substr $NonForVeg, 2, 2) gt 0) 
		{ 
			if  (isempty($Height))                                      { $Height = 0; }
			elsif (($Height < 0)    || ($Height > 50))                  { $Height = 0; print "look at height $Height\n"; exit;}

			#print "$NonForVeg, cod =$cod, height = $Height \n"; 

			if(($Height >= 0)   && ($Height < 2)) {$NonForVeg = "SL"; }
			elsif(($Height >= 2)   && ($Height <= 50))  {$NonForVeg = "ST"; }
			else{ $NonForVeg = ERRCODE; }
			#print "$NonForVeg, cod =$cod, height = $Height , result = $NonForVeg\n"; 
		}
		elsif($cod eq "SO" ) {print "error on --$NonForVeg-- \n"; exit;}

		if (!$NonForVegList {$NonForVeg} ) 
		{ 
			if (($NonForVeg ne "SL") && ($NonForVeg ne "ST"))
			{
				$NonForVeg = ERRCODE;
			}
			else 
			{
				return $NonForVeg;
			}
		}

	    if (($NonForVeg eq "so") || ($NonForVeg eq "SO"))       { $NonForVeg = "SL"; }
	    elsif (($NonForVeg eq "sc") || ($NonForVeg eq "SC"))       { $NonForVeg = "ST"; }
	    elsif (($NonForVeg eq "hg") || ($NonForVeg eq "HG"))       { $NonForVeg = "HG"; }
	    elsif (($NonForVeg eq "hf") || ($NonForVeg eq "HF"))       { $NonForVeg = "HF"; }
	    elsif (($NonForVeg eq "hu") || ($NonForVeg eq "HU"))       { $NonForVeg = "HF"; }
	    elsif (($NonForVeg eq "br") || ($NonForVeg eq "BR"))       { $NonForVeg = "BR"; }
	    elsif (($NonForVeg eq "cl") || ($NonForVeg eq "CL"))       { $NonForVeg = "BR"; }
	    elsif (($NonForVeg eq "al") || ($NonForVeg eq "AL"))       { $NonForVeg = "ST"; }
	    elsif (($NonForVeg eq "cc") || ($NonForVeg eq "CC"))       { $NonForVeg = "ST"; }
	    elsif (($NonForVeg eq "cs") || ($NonForVeg eq "CS"))       { $NonForVeg = "ST"; }
	    elsif (($NonForVeg eq "as") || ($NonForVeg eq "AS"))       { $NonForVeg = "ST"; }
	    elsif (($NonForVeg eq "vi") || ($NonForVeg eq "VI"))       { $NonForVeg = "ST"; }
	    elsif (($NonForVeg eq "ra") || ($NonForVeg eq "RA"))       { $NonForVeg = "SL"; }
	    elsif (($NonForVeg eq "dl") || ($NonForVeg eq "DL"))       { $NonForVeg = "SL"; }
	    elsif (($NonForVeg eq "au") || ($NonForVeg eq "AU"))       { $NonForVeg = "SL"; }
	    #if (($NonForVeg eq "va") || ($NonForVeg eq "VA"))       { $NonForVeg = "VA"; }
		else {$NonForVeg = ERRCODE;}
	}
    return $NonForVeg;
}

#in case of SC7 type, need to compute CC
sub CCLower_SC 
{
	my $CCLow_SC = MISSCODE;
	my $CC_SC;

    ($CC_SC) = shift(@_);
 	if (isempty($CC_SC))  {$CC_SC ="";}

    if (((substr $CC_SC, 0, 2) eq "SC" || (substr $CC_SC, 0, 2) eq "sc") && (substr $CC_SC, 2, 2) gt 0) 
    {
        $CCLow_SC   =  (substr $CC_SC, 2, 2) . 1;
    }

	return $CCLow_SC;
}

#in case of SC7 type, need to compute CC
sub CCUpper_SC 
{
	my $CCHigh_SC = MISSCODE;
	my $CC_SC;

	($CC_SC) = shift(@_);

	if (isempty($CC_SC))  {$CC_SC ="";}

	if (((substr $CC_SC, 0, 2) eq "SC" || (substr $CC_SC, 0, 2) eq "sc") && (substr $CC_SC, 2, 2) gt 0) 
	{
        $CCHigh_SC   =  ((substr $CC_SC, 2, 2) + 1) . 0;
    }

	return $CCHigh_SC;
}


#in case of SO7 type, need to compute CC
sub CCLower_SO 
{
	my $CCLow_SO = MISSCODE;
	my $CC_SO;

    ($CC_SO) = shift(@_);
	if (isempty($CC_SO)) {$CC_SO ="";}

    if (((substr $CC_SO, 0, 2) eq "SO" || (substr $CC_SO, 0, 2) eq "so") && (substr $CC_SO, 2, 2) gt 0) 
    {
        $CCLow_SO   =  (substr $CC_SO, 2, 2) . 1;
    }
	return $CCLow_SO;
}

#in case of SO7 type, need to compute CC
sub CCUpper_SO 
{
	my $CCHigh_SO = MISSCODE;
	my $CC_SO;

	($CC_SO) = shift(@_);
	if (isempty($CC_SO)) {$CC_SO ="";}

    if (((substr $CC_SO, 0, 2) eq "SO" || (substr $CC_SO, 0, 2) eq "so") && (substr $CC_SO, 2, 2) gt 0) 
    {
        $CCHigh_SO   =  ((substr $CC_SO, 2, 2) + 1) . 0;
    }

	return $CCHigh_SO;
}

 						

sub Disturbance 
{
	my $ModCode;
	my $Mod;
	my $ModYr;
	my $Disturbance;
	
	my %ModList = ("", 1, "CC", 1, "BU", 1, "WF", 1, "IK", 1, "DI", 1,"DM", 1, "UK", 1, "WE", 1, "DT", 1, "BT", 1, "CL", 1, "BF", 1, "SF", 1, "IB", 1, "SN", 1,
	"cc", 1, "bu", 1, "wf", 1, "ik", 1, "di", 1, "uk", 1, "we", 1, "dt",1, "dm", 1, "bt", 1, "cl", 1, "bf", 1, "sf", 1, "ib", 1, "sn", 1);
   
	#NOTE ::: SN is not really a DIST code, ===> MISSCODE
	#new rule : change NT to FL and CU to CO
	($ModCode) = shift(@_);
	($ModYr) = shift(@_);
	if (isempty($ModYr)) {$ModYr = MISSCODE;}

	if (isempty($ModCode)) {$ModCode = ""; }

	if ($ModList{$ModCode} ) 
	{ 
		if ($ModCode ne "") 
		{ 
 			if (($ModCode  eq "CC") || ($ModCode eq "cc")) { $Mod="CO"; }
			elsif (($ModCode  eq "BU") || ($ModCode eq "bu")) { $Mod="BU"; }
			elsif (($ModCode  eq "WF") || ($ModCode eq "wf")) { $Mod="WF"; }
			elsif (($ModCode  eq "CL") || ($ModCode eq "cl")) { $Mod="OT"; }
			elsif (($ModCode  eq "DI") || ($ModCode eq "di")) { $Mod="DI"; }
			elsif (($ModCode  eq "DM") || ($ModCode eq "dm")) { $Mod="DI"; }
			elsif (($ModCode  eq "IK") || ($ModCode eq "ik")) { $Mod="IK"; }
			elsif (($ModCode  eq "IB") || ($ModCode eq "ib")) { $Mod="IK"; }
			elsif (($ModCode  eq "UK") || ($ModCode eq "uk")) { $Mod="OT"; }
			elsif (($ModCode  eq "BF") || ($ModCode eq "bf")) { $Mod="FL"; }
			elsif (($ModCode  eq "SF") || ($ModCode eq "sf")) { $Mod="FL"; }

			elsif (($ModCode  eq "BF") || ($ModCode eq "bf")) { $Mod="FL"; }
			elsif (($ModCode  eq "WE") || ($ModCode eq "we")) { $Mod="WE"; }
			elsif (($ModCode  eq "DT") || ($ModCode eq "dt")) { $Mod="DT"; }
			elsif (($ModCode  eq "BT") || ($ModCode eq "bt")) { $Mod="OT"; }
			elsif (($ModCode  eq "SN") || ($ModCode eq "sn")) { $Mod=MISSCODE; }
			$Disturbance = $Mod . "," . $ModYr; 
	    }
	   	else 
	   	{ 
	   		$Disturbance = MISSCODE.",".$ModYr; 
	   	}
	} else { $Mod = ERRCODE; $Disturbance = $Mod . "," . $ModYr;  }

	return $Disturbance;
}

sub DisturbanceExtUpper 
{
    my $ModExt;
    my $DistExtUpper;
	my %DistExtList = ("", 1, "0", 1, "1", 1, "2", 1, "3", 1, "4",1,"5",1);


    ($ModExt) = shift(@_);

	if (isempty($ModExt)) { $DistExtUpper = MISSCODE; }
	elsif (!$DistExtList{$ModExt} ) {$DistExtUpper = ERRCODE; }

	elsif ($ModExt == 1)  { $DistExtUpper = 25; }
	elsif ($ModExt == 2)  { $DistExtUpper = 50; }
	elsif ($ModExt == 3)  { $DistExtUpper = 75; }
    elsif ($ModExt == 4)  { $DistExtUpper = 95; }
	elsif ($ModExt == 5)  { $DistExtUpper = 100; }
	elsif ($ModExt == 0)  { $DistExtUpper = UNDEF; }
    return $DistExtUpper;
}

sub DisturbanceExtLower 
{
    my $ModExt;
    my $DistExtLower;

	my %DistExtList = ("", 1, "0", 1, "1", 1, "2", 1, "3", 1, "4",1,"5",1);

    ($ModExt) = shift(@_);

	if (isempty($ModExt)) { $DistExtLower = MISSCODE; }
	elsif (!$DistExtList{$ModExt} )  {$DistExtLower = ERRCODE; }
	
	elsif ($ModExt == 1)  { $DistExtLower = 1; }
	elsif ($ModExt == 2)  { $DistExtLower = 26; }
	elsif ($ModExt == 3)  { $DistExtLower = 51; }
    elsif ($ModExt == 4)  { $DistExtLower = 76; }
	elsif ($ModExt == 5)  { $DistExtLower = 96; }
	elsif ($ModExt == 0)  { $DistExtLower = UNDEF; }

    return $DistExtLower;
}

sub ComputeNumberOfLayers 
{
	my $SEQ1  = shift(@_);
    my $SEQ2  = shift(@_);
    my $SEQ3  = shift(@_);
    my $SEQ4  = shift(@_);
    my $SEQ5  = shift(@_);

	my $NumberOfLayers = 0;

	if (isempty($SEQ1)) {$SEQ1 ="";}
	if (isempty($SEQ2)) {$SEQ2 ="";}
	if (isempty($SEQ3)) {$SEQ3 ="";}
	if (isempty($SEQ4)) {$SEQ4 ="";}
	if (isempty($SEQ5)) {$SEQ5 ="";}

    if ( $SEQ5 ne 0 && $SEQ5 ne "" ) { $NumberOfLayers = $SEQ5; }
    elsif ( $SEQ4 ne 0 && $SEQ4 ne "" ) { $NumberOfLayers = $SEQ4; }
    elsif ( $SEQ3 ne 0 && $SEQ3 ne "" ) { $NumberOfLayers = $SEQ3; }
    elsif ( $SEQ2 ne 0 && $SEQ2 ne "" ) { $NumberOfLayers = $SEQ2; }
   	elsif ( $SEQ1 ne 0 && $SEQ1 ne "" ) { $NumberOfLayers = $SEQ1; }
    else {}

    return  $NumberOfLayers;
}

# Determine wetland codes  $WETECO1 (and $WETECO2)  for non treed wetlands
sub WetlandCodes 
{
	
	#redo
    my $WetlandCode =shift(@_); my $LandMod =shift(@_); my $OSMR =shift(@_);
	my $SP1 =shift(@_);my $SP1PER =shift(@_);my $SP2 =shift(@_); my $CC =shift(@_); my $HT =shift(@_); my $NNF_ANTH=shift(@_);
	my $Wetland;

	my %WetList = ("", 1, "0", 1, "1", 1, "2", 1, "3", 1, "4",1,"5",1 , "6", 1, "7", 1, "8", 1, "9",1,"10",1 );

 	$Wetland = MISSCODE;
	if(isempty($SP1)) {$SP1="";}
	if(isempty($SP1PER)) {$SP1PER=0;}
	if(isempty($SP2)) {$SP2="";}
	if(isempty($CC)) {$CC=0;}
	if(isempty($HT)) {$HT=0;}
	if(isempty($NNF_ANTH)) {$NNF_ANTH="";}

	if (!$WetList{$WetlandCode} ) {$Wetland = ERRCODE; }

	if ($LandMod eq "O" || $LandMod eq "W" ) { $Wetland = "W,-,-,-,"; }

	if (isempty($WetlandCode)) { $Wetland = MISSCODE; }
	elsif ($WetlandCode == 1)  {  $Wetland="B,O,N,S,"; }  #if ($WETECO1 eq "WE1")
	elsif ($WetlandCode == 2)  {  $Wetland="F,O,N,S,";  }
	elsif ($WetlandCode == 3)  {  $Wetland="F,O,N,G,";  }
    elsif ($WetlandCode == 4)  {  $Wetland="S,O,N,S,";  }
	elsif ($WetlandCode == 5)  {  $Wetland="F,O,N,S,";  }
	elsif ($WetlandCode == 6)  {  $Wetland="M,O,N,G,"; }
	elsif ($WetlandCode == 7)  {  $Wetland="M,O,N,G,";  }
	elsif ($WetlandCode == 8)  {  $Wetland="M,O,N,G,";  }
    elsif ($WetlandCode == 9)  {  $Wetland="M,O,N,G,";  }
	elsif ($WetlandCode == 10) {  $Wetland="M,O,N,G,";  }
	 
	elsif ($WetlandCode == 0 ||  $WetlandCode eq "") 
	{
	    if ($OSMR eq "W") 
	    {
			if ($SP1 eq "BS" &&  $SP1PER == 100  && $CC < 50 && $HT <12) {  $Wetland="B,T,N,N,";  }
			elsif (($SP1 eq "BS" || $SP1 eq "TL") &&  $SP1PER == 100  && $CC > 50 && $HT >12) {  $Wetland="S,T,N,N,";  }
			elsif (($SP1 eq "BS" || $SP1 eq "TL") &&  ($SP2 eq "BS" || $SP2 eq "TL")  && $CC > 50 && $HT >12) {  $Wetland="S,T,N,N,";  }
			elsif (($SP1 eq "WB" || $SP1 eq "MM" || $SP1 eq "EC" || $SP1 eq "BA") ) {  $Wetland="S,T,N,N,";  }
			elsif (($SP1 eq "BS" || $SP1 eq "TL") &&  ($SP2 eq "BS" || $SP2 eq "TL")  && $CC < 50 ) {  $Wetland="F,T,N,N,";  }
			elsif (($SP1 eq "TL") &&  $SP1PER == 100  && $HT <12) {  $Wetland="F,T,N,N,";  }
		
			else 
			{
				#if($NNF_ANTH eq "SO" || $NNF_ANTH eq "SC"  )	{  $Wetland="S,O,N,S,";  }
				if ((substr $NNF_ANTH, 0, 2) eq "SO" || (substr $NNF_ANTH, 0, 2) eq "SC") {  $Wetland="S,O,N,S,";  }
				elsif($NNF_ANTH eq "HG" || $NNF_ANTH eq "HF" || $NNF_ANTH eq "HU")	{  $Wetland="M,O,N,G,";  }
				elsif($NNF_ANTH eq "BR")	{  $Wetland="F,O,N,N,";  }
				elsif($NNF_ANTH eq "CL")	{  $Wetland="B,O,N,N,";  }
			}
		}
	    elsif($NNF_ANTH eq "NWF")	{  $Wetland="M,O,N,G,";  }
	    else {$Wetland = MISSCODE; }
	}
	else {$Wetland = ERRCODE; }

	return $Wetland;
}


sub WetlandCodesT 
{
	
    my $LandMod = shift(@_);
	my $ECOS = shift(@_);
	my $Wetland;

	if ($LandMod eq "O" || $LandMod eq "W" ) { $Wetland = "W,-,-,-,"; }
	elsif ($ECOS eq "V2") {  $Wetland="S,T,N,N,";  }
	elsif ($ECOS eq "V19") {  $Wetland="S,T,N,N,";  }
	elsif ($ECOS eq "V20") {  $Wetland="F,T,N,N,";  }
	elsif ($ECOS eq "V30") {  $Wetland="S,T,N,N,";  }
	elsif ($ECOS eq "V31") {  $Wetland="S,T,N,N,";  }
	elsif ($ECOS eq "V32") {  $Wetland="F,T,N,N,";  }
	elsif ($ECOS eq "V33") {  $Wetland="B,T,N,N,";  }
    else {$Wetland = MISSCODE;}
 
	return $Wetland;
}



sub productive_code
{

	my $prod =  "";
	my ($Sp1, $CCHigh, $CCLow, $HeightHigh, $HeightLow, $CrownCl) = @_;
	my $SpeciesComp;
	my $prod_for="PF";
	my $lyr_poly=0;
		
	if(isempty($Sp1))
	{
		#$SpeciesComp ="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";

		if( ( !is_missing($CCHigh) ||  !is_missing($CCLow) || !is_missing($HeightHigh) || !is_missing($HeightLow)) && $CrownCl != 0)
		#if( ( !is_missing($CCHigh) ||  !is_missing($CCLow) || !is_missing($HeightHigh) || !is_missing($HeightLow)))
		{
			$prod_for="PP";	
			$lyr_poly=1;
		}
	}
	return ($prod_for, $lyr_poly );
}

sub MBFLIinv_to_CAS 
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

	######		
	my $photofile=$MB_File;
	$photofile =~ s/\.csv$/_photoyear\.csv/g;

 	print "photofile is $photofile\n"; 
 	

	# Declare hashtable for a photoyear
	my %MBFLItable=();
	$nbas=0;
	# Here is the loop to interprete photoyear files when photoyear come from an other source
		
	open (MBFLIsheets, "$photofile") || die "\n Error: Could not open file of MB sheets $photofile !\n";
	my $csv1 = Text::CSV_XS->new();
	my $nothing=<MBFLIsheets>;  #drop header line
	if($nothing =~ /;/)
	{
		#set the separator to ; instead of default ;
		$csv1->sep_char (";");
	}
	my $nbr=0;
	while(<MBFLIsheets>) 
	{ 
		if ($csv1->parse($_)) 
		{
			my @MBFLIS_Record =();
		    @MBFLIS_Record = $csv1->fields();  
			my $MBFLIkeys=$MBFLIS_Record[0];
			$MBFLItable{$MBFLIkeys}=$MBFLIS_Record[1];
			$nbr++;	
			#print("fFILE no = $MBFLIkeys , age = $MBFLIS_Record[1]\n"); exit;
		} 
		else
		{
		    my $err = $csv1->error_input;
		    print "Failed to parse line: $err"; exit(1);
		}	
	}
	close(MBFLIsheets);
	print " $nbr lines in $photofile\n";

	#####

	my $CAS_File_HDR = $CAS_File . ".hdr";
	my $CAS_File_CAS = $CAS_File . ".cas";
	my $CAS_File_LYR = $CAS_File . ".lyr";
	my $CAS_File_NFL = $CAS_File . ".nfl";
	my $CAS_File_DST = $CAS_File . ".dst";
	my $CAS_File_ECO = $CAS_File . ".eco";


	#open (MBinv, "<$MB_File") || die "\n Error: Could not open Manitoba_LP input file!\n";
	open (ERRS, ">>$ERRFILE") || die "\n Error: Could not open $ERRFILE file!\n";
	open (SPERRSFILE, ">>$SPERRS") || die "\n Error: Could not open $SPERRS file!\n";	
	open (SPECSLOGFILE, ">>$SPECSLOG") || die "\n Error: Could not open $SPECSLOG file!\n";
	open (MISSING_STANDS, ">>$MstandsLOG") || die "\n Error: Could not open $MstandsLOG file!\n";

	my $errcode=ERRCODE;
	my $misscode=MISSCODE;
	my $ndrops=0;

	if($optgroups==1)
	{

	 	$CAS_File_HDR = $pathname."/MBLPtable.hdr";
	 	$CAS_File_CAS = $pathname."/MBLPtable.cas";
	 	$CAS_File_LYR = $pathname."/MBLPtable.lyr";
	 	$CAS_File_NFL = $pathname."/MBLPtable.nfl";
	 	$CAS_File_DST = $pathname."/MBLPtable.dst";
	 	$CAS_File_ECO = $pathname."/MBLPtable.eco";
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

		my $HDR_Record;
		my $P1;
		
		my @hdr_tab=split("/",  $MB_File);
		my $sz=scalar(@hdr_tab);		$Glob_filename= $hdr_tab[$sz-1];
		my @hdr_id=split ("-", $hdr_tab[$sz-1]);
		($P1, $hdr_num)=split ("_", $hdr_id[0]);
		#print "number is ". $hdr_num."\n";
		#exit;
		$hdr_num =~ s/\.csv//g;
		if($hdr_num eq "0002")
		{
			$HDR_Record =  "2,MB,,UTM,NAD83,INDUSTRY,LouisianaPacific,,,FLI,,1998,1998,,,";
		}
		elsif($hdr_num eq "0004")
		{
			$HDR_Record = "4,MB,,UTM,NAD83,INDUSTRY(Porcupine Mountain),,,,FLI,,1998,1998,,,";
		}
		else 
		{
			print "other hdrnum = $hdr_num"; exit;
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
	my $NatNonVeg; my $NatNonVeg1;my $NatNonVeg2;my $NatNonVeg3;my $NatNonVeg4;my $NatNonVeg5;
	my $NonForVeg; my $NonForVeg1;my $NonForVeg2;my $NonForVeg3;my $NonForVeg4;my $NonForVeg5;
	my $NonForAnth;my $NonForAnth1;my $NonForAnth2;my $NonForAnth3;my $NonForAnth4;my $NonForAnth5;
	my $Dist1;my $Dist2; my $Dist;
	my $Dist1ExtHigh;my $Dist2ExtHigh; my $Dist1ExtLow;my $Dist2ExtLow; 
	my $LayerRank1="";my $LayerRank2="";my $LayerRank3="";my $LayerRank4="";my $LayerRank5="";
	my $pr1; my  $pr2; my $pr3; my $pr4;  my $pr5;

	my %herror=();
	my $keys;

	my $LandMod;

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
	my $Perimeter;
	my $PHOTO_YEAR;  
	my $layer_rank1; my $layer_rank2; my $layer_rank3; my $layer_rank4; my $layer_rank5;
	my @SpecsPerList1=(); my $cpt_ind;
	my @SpecsPerList2=();my @SpecsPerList3=();my @SpecsPerList4=();my @SpecsPerList5=();my @SpecsPerList6=();my @SpecsPerList7=();

  	my $csv = Text::CSV_XS->new(
  	{
  		binary    => 1,
		sep_char  => ";" 
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
		if(defined $row->{HEADER_ID})
		{
			$IdentifyID= $row->{HEADER_ID};
		} 
		else 
		{ 
			print "HEADER_ID MISSING for $CAS_ID\n"; exit;
		} #print "header is $CAS_ID, $PolyNum , $IdentifyID\n "; exit;
			
		$Area=$row->{GIS_AREA};
		$Perimeter=$row->{GIS_PERI};
		$PHOTO_YEAR   =  $MBFLItable{$CAS_ID };
			
		if (isempty($PHOTO_YEAR) || $PHOTO_YEAR eq "0") {$PHOTO_YEAR = MISSCODE;}

		if (defined $row->{OS_LANDMOD})
		{	
			$LandMod=$row->{OS_LANDMOD};
		} 
		else
		{
			$LandMod="";
		}          
		$SMR  =  SoilMoistureRegime($row->{OS_MR});
		if($SMR eq ERRCODE) 
		{ 
			$keys="MoistReg"."#". $row->{OS_MR};
			$herror{$keys}++;	
		}

        $StandStructureCode1   =  StandStructure( $row->{OS_CANLAY});
	    if($StandStructureCode1 eq ERRCODE) 
	    { 
			$keys="Struc1"."#". $row->{OS_CANLAY};
			$herror{$keys}++;	
		}

          	$StandStructureCode2   =  StandStructure( $row->{US2_CANLAY});
 	  		if($StandStructureCode2 eq ERRCODE)
 	  		{ 
				$keys="Struc2"."#". $row->{US2_CANLAY};
				$herror{$keys}++;	
			}

          	$StandStructureCode3   =  StandStructure( $row->{US3_CANLAY});
            if($StandStructureCode3 eq ERRCODE) 
            { 
				$keys="Struc3"."#". $row->{US3_CANLAY};
				$herror{$keys}++;	
			}

	  		$StandStructureCode4   =  StandStructure( $row->{US4_CANLAY});
 	  		if($StandStructureCode4 eq ERRCODE) 
 	  		{ 
				$keys="Struc4"."#". $row->{US4_CANLAY};
				$herror{$keys}++;	
			}

          	$StandStructureCode5   =  StandStructure( $row->{US5_CANLAY});
 	  		if($StandStructureCode5 eq ERRCODE) 
 	  		{ 
				$keys="Struc5"."#". $row->{US5_CANLAY};
				$herror{$keys}++;	
			}
          	$StandStructureVal     =  UNDEF;  
	  		$CCHigh1       =  CCUpper( $row->{OS_CC},  $row->{OS_CANLAY}); 
	        $CCHigh2       =  CCUpper( $row->{US2_CC},  $row->{US2_CANLAY}); 
	        $CCHigh3       =  CCUpper( $row->{US3_CC},  $row->{US3_CANLAY}); 
	        $CCHigh4       =  CCUpper( $row->{US4_CC},  $row->{US4_CANLAY}); 
	        $CCHigh5       =  CCUpper( $row->{US5_CC},  $row->{US5_CANLAY}); 
	        $CCLow1        =  CCLower( $row->{OS_CC},  $row->{OS_CANLAY}); 
	        $CCLow2        =  CCLower( $row->{US2_CC},  $row->{US2_CANLAY}); 
	        $CCLow3        =  CCLower( $row->{US3_CC},  $row->{US3_CANLAY}); 
	        $CCLow4        =  CCLower( $row->{US4_CC},  $row->{US4_CANLAY}); 
	        $CCLow5        =  CCLower( $row->{US5_CC},  $row->{US5_CANLAY}); 

 	  		if($CCHigh1  eq ERRCODE   || $CCLow1  eq ERRCODE || $CCHigh2  eq ERRCODE   || $CCLow2  eq ERRCODE || $CCHigh3  eq ERRCODE   || $CCLow3  eq ERRCODE || $CCHigh4  eq ERRCODE   || $CCLow4  eq ERRCODE || $CCHigh5  eq ERRCODE   || $CCLow5  eq ERRCODE) 
 	  		{ 
 	  			$keys="CrownClosure1-5"."#".$row->{OS_CC};
				$herror{$keys}++;
			}

          # $HeightHigh
			if(!defined $row->{US5_HT})
			{
				$row->{US5_HT}="";
			}
	  		$HeightHigh1   =  StandHeight($row->{OS_HT} , $row->{OS_COMHT}, $row->{OS_CANLAY}, 1); 
	 		$HeightHigh2   =  StandHeight($row->{US2_HT}, $row->{OS_COMHT}, $row->{US2_CANLAY}, 1);
          	$HeightHigh3   =  StandHeight($row->{US3_HT}, $row->{OS_COMHT}, $row->{US3_CANLAY}, 1);
          	$HeightHigh4   =  StandHeight($row->{US4_HT}, $row->{OS_COMHT}, $row->{US4_CANLAY}, 1);
          	$HeightHigh5   =  StandHeight($row->{US5_HT}, $row->{OS_COMHT}, $row->{US5_CANLAY}, 1);
          	$HeightLow1    =  StandHeight($row->{OS_HT} , $row->{OS_COMHT}, $row->{OS_CANLAY}, -1);
          	$HeightLow2    =  StandHeight($row->{US2_HT}, $row->{OS_COMHT}, $row->{US2_CANLAY}, -1);
         	$HeightLow3    =  StandHeight($row->{US3_HT}, $row->{OS_COMHT}, $row->{US3_CANLAY}, -1);
          	$HeightLow4    =  StandHeight($row->{US4_HT}, $row->{OS_COMHT}, $row->{US4_CANLAY}, -1);
          	$HeightLow5    =  StandHeight($row->{US5_HT}, $row->{OS_COMHT}, $row->{US5_CANLAY}, -1);

		  	if( ($HeightHigh1 eq MISSCODE || $HeightLow1 eq MISSCODE) && !isempty($row->{OS_HT}) && $row->{OS_HT} ne "0") 
		  	{
				$keys="Heigh1#".$row->{OS_HT}."#comt#".$row->{OS_COMHT}."#canlay#".$row->{OS_CANLAY};
				$herror{$keys}++;
			}
			if( ($HeightHigh2 eq MISSCODE || $HeightLow2 eq MISSCODE) && !isempty($row->{US2_HT}) && $row->{US2_HT} ne "0")
			{
				$keys="Heigh2#".$row->{US2_HT}."#comt#".$row->{US2_COMHT}."#canlay#".$row->{US2_CANLAY};
				$herror{$keys}++;
			}
			if( ($HeightHigh3 eq MISSCODE || $HeightLow3 eq MISSCODE) && !isempty($row->{US3_HT}) && $row->{US3_HT} ne "0")
			{
				$keys="Heigh3#".$row->{US3_HT}."#comt#".$row->{US3_COMHT}."#canlay#".$row->{US3_CANLAY};
				$herror{$keys}++;
			}
			if( ($HeightHigh4 eq MISSCODE || $HeightLow4 eq MISSCODE) && !isempty($row->{US4_HT}) && $row->{US4_HT} ne "0")
			{
				$keys="Heigh4#".$row->{US4_HT}."#comt#".$row->{US4_COMHT}."#canlay#".$row->{US4_CANLAY};
				$herror{$keys}++;
			}
			if( ($HeightHigh5 eq MISSCODE || $HeightLow5 eq MISSCODE) && !isempty($row->{US5_HT}) && $row->{US5_HT} ne "0")
			{
				$keys="Heigh5#".$row->{US5_HT}."#comt#".$row->{US5_COMHT}."#canlay#".$row->{US5_CANLAY};
				$herror{$keys}++;
			}
          	#in case of SC7 type
          	$CCHigh1_SC       =  CCUpper_SC($row->{OS_NNF_ANTH});
          	$CCHigh2_SC       =  CCUpper_SC($row->{US2_NNF_ANTH});
          	$CCHigh3_SC       =  CCUpper_SC($row->{US3_NNF_ANTH});
          	$CCHigh4_SC       =  CCUpper_SC($row->{US4_NNF_ANTH});
          	$CCHigh5_SC       =  CCUpper_SC($row->{US5_NNF_ANTH});
          	$CCLow1_SC        =  CCLower_SC($row->{OS_NNF_ANTH});
          	$CCLow2_SC        =  CCLower_SC($row->{US2_NNF_ANTH});
          	$CCLow3_SC        =  CCLower_SC($row->{US3_NNF_ANTH});
          	$CCLow4_SC        =  CCLower_SC($row->{US4_NNF_ANTH});
          	$CCLow5_SC        =  CCLower_SC($row->{US5_NNF_ANTH});

	 		#in case of SO7 type
          	$CCHigh1_SO       =  CCUpper_SO($row->{OS_NNF_ANTH}); 
          	$CCLow1_SO        =  CCLower_SO($row->{OS_NNF_ANTH});
 	  		$CCHigh2_SO       =  CCUpper_SO($row->{US2_NNF_ANTH}); 
          	$CCLow2_SO        =  CCLower_SO($row->{US2_NNF_ANTH});
 	  		$CCHigh3_SO       =  CCUpper_SO($row->{US3_NNF_ANTH}); 
          	$CCLow3_SO        =  CCLower_SO($row->{US3_NNF_ANTH});
 	  		$CCHigh4_SO       =  CCUpper_SO($row->{US4_NNF_ANTH}); 
          	$CCLow4_SO        =  CCLower_SO($row->{US4_NNF_ANTH});
 	  		$CCHigh5_SO       =  CCUpper_SO($row->{US5_NNF_ANTH}); 
          	$CCLow5_SO        =  CCLower_SO($row->{US5_NNF_ANTH});
          
			my $Spcomp=$row->{OS_SP1}."#".$row->{OS_SP1PER}."#".$row->{OS_SP2}."#".$row->{OS_SP2PER}."#".$row->{OS_SP3}."#".$row->{OS_SP3PER}."#".$row->{OS_SP4}."#".$row->{OS_SP4PER}."#".$row->{OS_SP5}."#".$row->{OS_SP5PER}."#".$row->{OS_SP6}."#".$row->{OS_SP6PER};

	  		$SpeciesComp1  =  Species($row->{OS_SP1}, $row->{OS_SP1PER}, $row->{OS_SP2}, $row->{OS_SP2PER}, $row->{OS_SP3}, $row->{OS_SP3PER}, $row->{OS_SP4}, $row->{OS_SP4PER}, $row->{OS_SP5}, $row->{OS_SP5PER}, $row->{OS_SP6}, $row->{OS_SP6PER}, $spfreq);

	 		@SpecsPerList1 = split(",", $SpeciesComp1);  
			for($cpt_ind=0; $cpt_ind<=5; $cpt_ind++)
			{  
				my $posi=$cpt_ind*2;
        		if($SpecsPerList1[$posi] eq SPECIES_ERRCODE) 
				{ 
					$keys="Species layer1 position#".$cpt_ind."#sp1#".$row->{OS_SP1}."#sp2#".$row->{OS_SP2}."#sp3#".$row->{OS_SP3}."#sp4#".$row->{OS_SP4}."#sp5#".$row->{OS_SP5}."#sp6#".$row->{OS_SP6};
              		$herror{$keys}++; 
				}
   			}
			my $total1=$SpecsPerList1[1] + $SpecsPerList1[3]+ $SpecsPerList1[5] +$SpecsPerList1[7]+$SpecsPerList1[9]+$SpecsPerList1[11];
	
			if($total1 != 100 && $total1 != 0 )
			{
				$keys="total perct !=100 "."#$total1#".$SpeciesComp1."#original#".$row->{OS_SP1}.",".$row->{OS_SP2}.",".$row->{OS_SP3}.",".$row->{OS_SP4}.",".$row->{OS_SP5}.",".$row->{OS_SP6};
				$herror{$keys}++; 
			}
 	  		$SpeciesComp1  =  $SpeciesComp1 .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";		

          	$SpeciesComp2  =  Species($row->{US2_SP1}, $row->{US2_SP1PER}, $row->{US2_SP2}, $row->{US2_SP2PER}, $row->{US2_SP3}, $row->{US2_SP3PER}, $row->{US2_SP4}, $row->{US2_SP4PER}, $row->{US2_SP5}, $row->{US2_SP5PER}, $row->{US2_SP6}, $row->{US2_SP6PER});

			@SpecsPerList2 = split(",", $SpeciesComp2);  
			for($cpt_ind=0; $cpt_ind<=5; $cpt_ind++)
			{  
				my $posi=$cpt_ind*2;
        		if($SpecsPerList2[$posi]  eq SPECIES_ERRCODE ) 
				{ 
					$keys="Species layer 2#".$cpt_ind."#sp1#".$row->{US2_SP1}."#sp2#".$row->{US2_SP2}."#sp3#".$row->{US2_SP3}."#sp4#".$row->{US2_SP4}."#sp5#".$row->{US2_SP5}."#sp6#".$row->{US2_SP6};
              		$herror{$keys}++; 
				}
   			}
			my $total2=$SpecsPerList2[1] + $SpecsPerList2[3]+ $SpecsPerList2[5] +$SpecsPerList2[7]+$SpecsPerList2[9]+$SpecsPerList2[11];
	
			if($total2 != 100 && $total2 != 0 )
			{
				$keys="total perct !=100 "."#$total2#".$SpeciesComp2."#original#".$row->{US2_SP1}.",".$row->{US2_SP2}.",".$row->{US2_SP3}.",".$row->{US2_SP4}.$row->{US2_SP5}.",".$row->{US2_SP6};
				$herror{$keys}++; 
			}

	  		$SpeciesComp2  =  $SpeciesComp2 .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";	

          	$SpeciesComp3  =  Species($row->{US3_SP1}, $row->{US3_SP1PER}, $row->{US3_SP2}, $row->{US3_SP2PER}, $row->{US3_SP3}, $row->{US3_SP3PER}, $row->{US3_SP4}, $row->{US3_SP4PER}, $row->{US3_SP5}, $row->{US3_SP5PER}, $row->{US3_SP6}, $row->{US3_SP6PER});
	  
			@SpecsPerList3 = split(",", $SpeciesComp3);  
			for($cpt_ind=0; $cpt_ind<=5; $cpt_ind++)
			{  
				my $posi=$cpt_ind*2;
        		if($SpecsPerList3[$posi]  eq SPECIES_ERRCODE ) 
				{ 
					$keys="Species layer 3#".$cpt_ind."#sp1#".$row->{US3_SP1}."#sp2#".$row->{US3_SP2}."#sp3#".$row->{US3_SP2}."#sp4#".$row->{US3_SP4}."#sp5#".$row->{US3_SP5}."#sp6#".$row->{US3_SP6};
              		$herror{$keys}++; 
				}
   			}
			my $total3=$SpecsPerList3[1] + $SpecsPerList3[3]+ $SpecsPerList3[5] +$SpecsPerList3[7]+$SpecsPerList3[9]+$SpecsPerList3[11];
	
			if($total3 != 100 && $total3 != 0 )
			{
				$keys="total perct !=100 "."#$total3#".$SpeciesComp3."#original#".$row->{US3_SP1}.",".$row->{US3_SP2}.",".$row->{US3_SP3}.",".$row->{US3_SP4}.$row->{US3_SP5}.",".$row->{US3_SP6};
				$herror{$keys}++; 
			}

			$SpeciesComp3  =  $SpeciesComp3 .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";			

          	$SpeciesComp4  =  Species($row->{US4_SP1}, $row->{US4_SP1PER}, $row->{US4_SP2}, $row->{US4_SP2PER}, $row->{US4_SP3}, $row->{US4_SP3PER}, $row->{US4_SP4}, $row->{US4_SP4PER}, $row->{US4_SP5}, $row->{US4_SP5PER}, $row->{US4_SP6}, $row->{US4_SP6PER});
	  
	  		@SpecsPerList4 = split(",", $SpeciesComp4);  
			for($cpt_ind=0; $cpt_ind<=5; $cpt_ind++)
			{  
				my $posi=$cpt_ind*2;
        		if($SpecsPerList4[$posi]  eq SPECIES_ERRCODE ) 
				{ 
					$keys = "Species layer 4#".$cpt_ind."#sp1#".$row->{US4_SP1}."#sp2#".$row->{US4_SP2}."#sp3#".$row->{US4_SP3}."#sp4#".$row->{US4_SP4}."#sp5#".$row->{US4_SP5}."#sp6#".$row->{US4_SP6};
              		$herror{$keys}++; 
				}
   			}
			my $total4=$SpecsPerList4[1] + $SpecsPerList4[3]+ $SpecsPerList4[5] +$SpecsPerList4[7]+$SpecsPerList4[9]+$SpecsPerList4[11];
	
			if($total4 != 100 && $total4 != 0 )
			{
				$keys="total perct !=100 "."#$total4#".$SpeciesComp4."#original#".$row->{US4_SP1}.",".$row->{US4_SP2}.",".$row->{US4_SP3}.",".$row->{US4_SP4}.$row->{US4_SP5}.",".$row->{US4_SP6};
				$herror{$keys}++; 
			}
			$SpeciesComp4  =  $SpeciesComp4 .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";	

			if($hdr_num eq "0002")
			{
          		$SpeciesComp5  =  Species($row->{US5_SP1}, $row->{US5_SP1PER}, $row->{US5_SP2}, $row->{US5_SP2PER}, $row->{US5_SP3}, $row->{US5_SP3PER}, $row->{US5_SP4}, $row->{US5_SP4PER}, $row->{US5_SP5}, $row->{US5_SP5PER}, $row->{US5_SP6}, $row->{US5_SP6PER});
	  			@SpecsPerList5 = split(",", $SpeciesComp5);  
				for($cpt_ind=0; $cpt_ind<=5; $cpt_ind++)
				{  
					my $posi=$cpt_ind*2;
        		  	if($SpecsPerList5[$posi]  eq SPECIES_ERRCODE ) 
					{ 
						$keys="Species layer 5#".$cpt_ind."#sp1#".$row->{US5_SP1}."#sp2#".$row->{US5_SP2}."#sp3#".$row->{US5_SP3}."#sp4#".$row->{US5_SP4}."#sp5#".$row->{US5_SP5}."#sp6#".$row->{US5_SP6};
              			$herror{$keys}++; 
					}
   				}
				my $total5=$SpecsPerList5[1] + $SpecsPerList5[3]+ $SpecsPerList5[5] +$SpecsPerList5[7]+$SpecsPerList5[9]+$SpecsPerList5[11];
	
				if($total5 != 100 && $total5 != 0 )
				{
					$keys="total perct !=100 "."#$total5#".$SpeciesComp5."#original#".$row->{US5_SP1}.",".$row->{US5_SP2}.",".$row->{US5_SP3}.",".$row->{US5_SP4}.$row->{US5_SP5}.",".$row->{US5_SP6};
					$herror{$keys}++; 
				}
				$SpeciesComp5  =  $SpeciesComp5 .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";	
			}

			if(!defined $row->{US5_ORIGIN}) {$row->{US5_ORIGIN}="";}
          	$OriginHigh1   =  UpperLowerOrigin($row->{OS_ORIGIN});
          	$OriginHigh2   =  UpperLowerOrigin($row->{US2_ORIGIN});
          	$OriginHigh3   =  UpperLowerOrigin($row->{US3_ORIGIN});
          	$OriginHigh4   =  UpperLowerOrigin($row->{US4_ORIGIN});
          	$OriginHigh5   =  UpperLowerOrigin($row->{US5_ORIGIN});
          	$OriginLow1    =  UpperLowerOrigin($row->{OS_ORIGIN});
          	$OriginLow2    =  UpperLowerOrigin($row->{US2_ORIGIN});
          	$OriginLow3    =  UpperLowerOrigin($row->{US3_ORIGIN});
          	$OriginLow4    =  UpperLowerOrigin($row->{US4_ORIGIN});
          	$OriginLow5    =  UpperLowerOrigin($row->{US5_ORIGIN});

			if($OriginHigh1 eq ERRCODE || $OriginLow1 eq ERRCODE)
			{
				$keys="origin1#".$row->{OS_ORIGIN};
				$herror{$keys}++;
			}
		 	if($OriginHigh2 eq ERRCODE || $OriginLow2 eq ERRCODE) 
		 	{
				$keys="origin2#".$row->{US2_ORIGIN};
				$herror{$keys}++;
		  	}
	 
			if($OriginHigh3 eq ERRCODE || $OriginLow3 eq ERRCODE) 
			{
				$keys="origin3#".$row->{US3_ORIGIN};
				$herror{$keys}++;
			}
 
			if($OriginHigh4 eq ERRCODE || $OriginLow4 eq ERRCODE) 
			{
				$keys="origin4#".$row->{US4_ORIGIN};
				$herror{$keys}++;
			}
 
		if($OriginHigh5 eq ERRCODE || $OriginLow5 eq ERRCODE) 
		{
			$keys="origin5#".$row->{US5_ORIGIN};
			$herror{$keys}++;
		}

 	if(($OriginHigh1>0 && $OriginHigh1 <1600) || $OriginHigh1 >2014) 
 	{
		$keys="BOUNDS origin1#".$row->{OS_ORIGIN};
		$herror{$keys}++;
	}
	if(($OriginHigh2>0 && $OriginHigh2 <1600) || $OriginHigh2 >2014) 
	{
		$keys=" BOUNDS origin2#".$row->{US2_ORIGIN};
		$herror{$keys}++;
	}
 
	if(($OriginHigh3>0 && $OriginHigh3 <1600) || $OriginHigh3 >2014) 
	{
		$keys="BOUNDS origin3#".$row->{US3_ORIGIN};
		$herror{$keys}++;
	}
 
	if(($OriginHigh4>0 && $OriginHigh4 <1600) || $OriginHigh4 >2014) 
	{
		$keys="BOUNDS origin4#".$row->{US4_ORIGIN};
		$herror{$keys}++;
	}
 
	if(($OriginHigh5>0 && $OriginHigh5 <1600) || $OriginHigh5 >2014) 
	{
		$keys="BOUNDS origin5#".$row->{US5_ORIGIN};
		$herror{$keys}++;
	}
 
	$StrucVal     =  UNDEF;#"";
	$SiteClass 	=  UNDEF;#"";
	$SiteIndex 	=  UNDEF;# "";
    $UnprodFor 	=  UNDEF;#"";

    #use only one layer
	#$Wetland = WetlandCodes ($row->{OS_WETECO1},  $row->{OS_WETECO2});
	######IMPORTANT !!!! in a more recent version of FLI, check for ECOSITE field to derive treed wetland

	if ($row->{OS_CANLAY} ne "V")
	{
	    $Wetland = WetlandCodes ($row->{OS_WETECO1},  $LandMod, $row->{OS_MR}, $row->{OS_SP1}, $row->{OS_SP1PER}, $row->{OS_SP2}, $row->{OS_CC}, $row->{OS_HT}, $row->{OS_NNF_ANTH});
	}
	else 
	{
		$Wetland = WetlandCodes ($row->{OS_WETECO1}, $LandMod, $row->{OS_MR}, $row->{US2_SP1}, $row->{US2_SP1PER}, $row->{US2_SP2}, $row->{US2_CC}, $row->{US2_HT}, $row->{US2_NNF_ANTH});
	}

	if($Wetland eq ERRCODE) 
	{ 
		$keys="wetland"."#". $row->{OS_WETECO1}."#".$LandMod;
		$herror{$keys}++;	
		$Wetland = MISSCODE;
	}

    # compute number of layers
    $NumberLyr	=  ComputeNumberOfLayers($row->{OS_SEQ}, $row->{US2_SEQ}, $row->{US3_SEQ}, $row->{US4_SEQ}, $row->{US5_SEQ});

	# ===== Non-forested Land =====
    if(defined $row->{OS_NNF_ANTH} && defined $row->{OS_HT}) 
    { 
	  
	  	$NatNonVeg1 	=  NaturallyNonVeg($row->{OS_NNF_ANTH});
	  	$NonForVeg1 	=  NonForestedVeg($row->{OS_NNF_ANTH}, $row->{OS_HT});
	  	$NonForAnth1	=  NonForestedAnth($row->{OS_NNF_ANTH});
	  	if(($NatNonVeg1  eq ERRCODE)  &&  ($NonForVeg1  eq ERRCODE)  &&  ($NonForAnth1  eq ERRCODE)) 
	  	{ 
			$keys="NonForVeg1-NatNonVeg1-NonForAnth1"."#".$row->{OS_NNF_ANTH}.":::HEIGHT=".$row->{OS_HT};  
			$herror{$keys}++; 
	 	}
    }
	else { $NatNonVeg1=$NonForVeg1=$NonForAnth1=MISSCODE;}
	
 	if(defined $row->{US2_NNF_ANTH} && defined $row->{US2_HT}) 
 	{ 
		$NatNonVeg2 	=  NaturallyNonVeg($row->{US2_NNF_ANTH});
		$NonForVeg2 	=  NonForestedVeg($row->{US2_NNF_ANTH}, $row->{US2_HT});
	  	$NonForAnth2	=  NonForestedAnth($row->{US2_NNF_ANTH});
	  	if(($NatNonVeg2  eq ERRCODE)  &&  ($NonForVeg2  eq ERRCODE)  &&  ($NonForAnth2  eq ERRCODE)) 
	  	{ 
			$keys="NonForVeg2-NatNonVeg2-NonForAnth2"."#".$row->{US2_NNF_ANTH}.":::HEIGHT=".$row->{US2_HT};  
			$herror{$keys}++; 
	  	}
    }
	else { $NatNonVeg2=$NonForVeg2=$NonForAnth2=MISSCODE;}


	  if(defined $row->{US3_NNF_ANTH} && defined $row->{US3_HT}) { 

		$NatNonVeg3 	=  NaturallyNonVeg($row->{US3_NNF_ANTH});
	  	$NonForVeg3 	=  NonForestedVeg($row->{US3_NNF_ANTH}, $row->{US3_HT});
	  	$NonForAnth3	=  NonForestedAnth($row->{US3_NNF_ANTH});
	  	if(($NatNonVeg3  eq ERRCODE)  &&  ($NonForVeg3  eq ERRCODE)  &&  ($NonForAnth3  eq ERRCODE)) { 
			$keys="NonForVeg3-NatNonVeg3-NonForAnth3"."#".$row->{US3_NNF_ANTH}.":::HEIGHT=".$row->{US3_HT};  $herror{$keys}++; 

	 	 }
         }
	  else { $NatNonVeg3=$NonForVeg3=$NonForAnth3=MISSCODE;}

	  if(defined $row->{US4_NNF_ANTH} && defined $row->{US4_HT}) { 

		$NatNonVeg4 	=  NaturallyNonVeg($row->{US4_NNF_ANTH});
	  	$NonForVeg4 	=  NonForestedVeg($row->{US4_NNF_ANTH}, $row->{US4_HT});
	  	$NonForAnth4	=  NonForestedAnth($row->{US4_NNF_ANTH});
		 if(($NatNonVeg4  eq ERRCODE)  &&  ($NonForVeg4  eq ERRCODE)  &&  ($NonForAnth4  eq ERRCODE)) { 
			$keys="NonForVeg4-NatNonVeg4-NonForAnth4"."#".$row->{US4_NNF_ANTH}.":::HEIGHT=".$row->{US4_HT};  $herror{$keys}++; 

	  	}   
	  }
	  else { $NatNonVeg4=$NonForVeg4=$NonForAnth4=MISSCODE;}
	  

	  if(defined $row->{US5_NNF_ANTH} && defined $row->{US5_HT}) { 

		$NatNonVeg5 	=  NaturallyNonVeg($row->{US5_NNF_ANTH});
	 	$NonForVeg5 	=  NonForestedVeg($row->{US5_NNF_ANTH}, $row->{US5_HT});
	  	$NonForAnth5	=  NonForestedAnth($row->{US5_NNF_ANTH});
	 	 if(($NatNonVeg5  eq ERRCODE)  &&  ($NonForVeg5  eq ERRCODE)  &&  ($NonForAnth5  eq ERRCODE)) { 
			$keys="NonForVeg5-NatNonVeg5-NonForAnth5"."#".$row->{US5_NNF_ANTH}."#".":::HEIGHT=".$row->{US5_HT};  $herror{$keys}++; 

	  	}
          }
	  else { $NatNonVeg5=$NonForVeg5=$NonForAnth5=MISSCODE;}

	  # ===== Modifiers =====
	  $Dist1 = Disturbance($row->{OS_MOD1}, $row->{OS_ORIG1});
	  $Dist2 = Disturbance($row->{OS_MOD2}, $row->{OS_ORIG2});


	if(!isempty($row->{OS_ORIG1}))
	{
		if(($row->{OS_ORIG1}>0 && $row->{OS_ORIG1} <1600) || $row->{OS_ORIG1} >2014) 
		{
			$keys="BOUNDS Dist year1#".$row->{OS_ORIG1};
			$herror{$keys}++;
		}
	}
	if(!isempty($row->{OS_ORIG2}))
	{
		if(!isempty($row->{OS_ORIG2}) &&  ( $row->{OS_ORIG2}>0 &&  $row->{OS_ORIG2} <1600) ||  $row->{OS_ORIG2} >2014) 
		{
			$keys="BOUNDS Dist year2#". $row->{OS_ORIG2};
			$herror{$keys}++;
		}
	}
		if($Dist1 =~ ERRCODE) { 
			$keys="disturbance1"."#". $row->{OS_MOD1}."#".$row->{OS_ORIG1};
			$herror{$keys}++;  	
		}

		if($Dist2 =~ ERRCODE) { 
			$keys="disturbance2"."#". $row->{OS_MOD2}."#".$row->{OS_ORIG2};
			$herror{$keys}++;	
		}
		  
		if(defined $row->{OS_EXT1}) {
          
				$Dist1ExtHigh  =  DisturbanceExtUpper($row->{OS_EXT1});
         			$Dist1ExtLow   =  DisturbanceExtLower($row->{OS_EXT1});

				if($Dist1ExtHigh eq ERRCODE) { 
						$keys="disturbance1ExtUpp"."#". $row->{OS_EXT1};
						$herror{$keys}++;	
				}

				if($Dist1ExtLow eq ERRCODE) { 
						$keys="disturbance1ExtLow"."#". $row->{OS_EXT1};
						$herror{$keys}++;	
				}
		}
		else {

				$Dist1ExtHigh  =  MISSCODE;
         			$Dist1ExtLow   =  MISSCODE;
		}


        	if(defined $row->{OS_EXT2}) {

				$Dist2ExtHigh  =  DisturbanceExtUpper($row->{OS_EXT2});
         			$Dist2ExtLow   =  DisturbanceExtLower($row->{OS_EXT2});

				if($Dist2ExtHigh eq ERRCODE) { 
						$keys="disturbance2ExtUpp"."#". $row->{OS_EXT2};
						$herror{$keys}++;	
				}

				if($Dist2ExtLow  eq ERRCODE) { 
						$keys="disturbance2ExtLow"."#". $row->{OS_EXT2};
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
         my  ($Cd1, $Cd2)=split(",", $Dist1);
		 	if($Cd1  eq ERRCODE ) 
		 	{ 
		 		$keys="Disturbance"."#".$row->{OS_MOD1};
				$herror{$keys}++;
			}
        		 
 	  	$Dist = $Dist1 . "," . $Dist2.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF;



 	 my ($prodFor1, $lyr_poly1) = productive_code ($row->{OS_SP1}, $CCHigh1 , $CCLow1 , $HeightHigh1 , $HeightLow1,  $row->{OS_CC});
	 if($lyr_poly1)
		{
			$SpeciesComp1 ="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
			$keys="###check artificial lyr1 on #".$row->{OS_SP1}."#nblayers = $NumberLyr";
			$herror{$keys}++; 
		}	
		my ($prodFor2, $lyr_poly2) = productive_code ($row->{US2_SP1}, $CCHigh2 , $CCLow2 , $HeightHigh2 , $HeightLow2,  $row->{US2_CC});
	 if($lyr_poly2)
		{
			$SpeciesComp2 ="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
			$keys="###check artificial lyr2 on #".$row->{US2_SP1}."#nblayers = $NumberLyr";
			$herror{$keys}++; 
		}	
		my ($prodFor3, $lyr_poly3) = productive_code ($row->{US3_SP1}, $CCHigh3 , $CCLow3 , $HeightHigh3 , $HeightLow3,  $row->{US3_CC});
	 if($lyr_poly3)
		{
			$SpeciesComp3 ="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
			$keys="###check artificial lyr3 on #".$row->{US3_SP1}."#nblayers = $NumberLyr";
			$herror{$keys}++; 
		}	
		my ($prodFor4, $lyr_poly4) = productive_code ($row->{US4_SP1}, $CCHigh4 , $CCLow4 , $HeightHigh4 , $HeightLow4,  $row->{US4_CC});
	 if($lyr_poly4)
		{
			$SpeciesComp4 ="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
			$keys="###check artificial lyr4 on #".$row->{US4_SP1}."#nblayers = $NumberLyr";
			$herror{$keys}++; 
		}	
		my ($prodFor5, $lyr_poly5) = productive_code ($row->{US5_SP1}, $CCHigh5, $CCLow5 , $HeightHigh5 , $HeightLow5,  $row->{US5_CC});
	 if($lyr_poly5)
		{
			$SpeciesComp5 ="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
			$keys="###check artificial lyr5 on #".$row->{US5_SP1}."#nblayers = $NumberLyr";
			$herror{$keys}++; 
		}	

	if ($Cd1  eq "CO")
	{
		$prodFor1="PF";
		$lyr_poly1=1;
	}
	 

	# ===== Output inventory info =====
           # $CAS_Record = $row->{CAS_ID} . "," . $PolyNum . "," . $IdentifyID . "," . $MapSheetID . "," . $Area . "," . $Perimeter . ",";

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
  	   		
		if(defined $IdentifyID){} else {print "cas nb $CAS_ID  header undef $IdentifyID \n"; exit;}
	  	$CAS_Record = $CAS_ID . "," . $PolyNum . "," . $StandStructureCode1 .",". $NumberLyr .",".  $IdentifyID . "," . $MapsheetID. "," . $Area . "," . $Perimeter.",".$Area.",".$PHOTO_YEAR;
	   print CASCAS $CAS_Record . "\n";
  	   $nbpr=1;$$ncas++;$ncasprev++;

            #layer 1
            if (!isempty($row->{OS_SP1}) || $lyr_poly1 ) {
	     	 	$LYR_Record11 = $row->{CAS_ID} . "," . $SMR  . ","  . $StandStructureVal . "," .  $row->{OS_SEQ} . "," . $layer_rank1;
	    	 	$LYR_Record21 = $CCHigh1 . "," . $CCLow1 . "," . $HeightHigh1 . "," . $HeightLow1 . "," .  $prodFor1. "," . $SpeciesComp1;
	     		$LYR_Record31 = $OriginHigh1 . "," . $OriginLow1 . "," . $SiteClass . "," . $SiteIndex;
	      		$Lyr_Record41 = $LYR_Record11 . "," . $LYR_Record21 . "," . $LYR_Record31;
	      		print CASLYR $Lyr_Record41 . "\n";
			$nbpr++; $$nlyr++;$nlyrprev++;
		}
            elsif (!isempty($row->{OS_NNF_ANTH})) {
             		 #in case of SC7 type, re-calculate CC
              		if (((substr $row->{OS_NNF_ANTH}, 0, 2) eq "SC"||(substr $row->{OS_NNF_ANTH},0, 2) eq "sc") && (substr $row->{OS_NNF_ANTH}, 2, 2) gt 0) {
           			  $CCLow1   = $CCLow1_SC;
                 		 $CCHigh1  = $CCHigh1_SC;
             		 }
 			#in case of SO7 type, re-calculate CC
              		elsif(((substr $row->{OS_NNF_ANTH}, 0, 2) eq "SO"||(substr $row->{OS_NNF_ANTH},0,2) eq "so") && (substr $row->{OS_NNF_ANTH}, 2, 2) gt 0) 				{
           			  $CCLow1   = $CCLow1_SO;
                  		$CCHigh1  = $CCHigh1_SO;
             		 }

            		$NFL_Record11 = $row->{CAS_ID} . "," . $SMR  .  "," . $StandStructureVal . "," . $row->{OS_SEQ} . "," . $layer_rank1;
            		 $NFL_Record21 = $CCHigh1 . "," . $CCLow1 . "," . UNDEF . "," . UNDEF;
             		 $NFL_Record31 = $NatNonVeg1 . "," . $NonForAnth1 . "," . $NonForVeg1;
             		 $NFL_Record1 = $NFL_Record11 . "," . $NFL_Record21 . "," . $NFL_Record31;
             		 print CASNFL $NFL_Record1 . "\n";
			$nbpr++;$$nnfl++;$nnflprev++;
		}
            else {}

            #layer 2
            if (!isempty($row->{US2_SP1}) || $lyr_poly2 ) {
	      $LYR_Record12 = $row->{CAS_ID} . "," . $SMR  . "," . $StandStructureVal . "," . $row->{US2_SEQ} . "," . $layer_rank2;
	      $LYR_Record22 = $CCHigh2 . "," . $CCLow2 . "," . $HeightHigh2 . "," . $HeightLow2 . "," .  $prodFor2. "," .$SpeciesComp2;
	      $LYR_Record32 = $OriginHigh2 . "," . $OriginLow2 . "," . $SiteClass . "," . $SiteIndex;
	      $Lyr_Record42 = $LYR_Record12 . "," . $LYR_Record22 . "," . $LYR_Record32;
	      print CASLYR $Lyr_Record42 . "\n";
		if($nbpr==1) {$nbpr++; $$nlyr++;$nlyrprev++;}
	    }
            elsif (!isempty($row->{US2_NNF_ANTH})) {
             	 #in case of SC7 type, re-calculate CC
           	   if (((substr $row->{US2_NNF_ANTH}, 0, 2) eq "SC" || (substr $row->{US2_NNF_ANTH}, 0, 2) eq "sc") && (substr $row->{US2_NNF_ANTH}, 2, 2) gt 0) {
           		  $CCLow2   = $CCLow2_SC;
                	  $CCHigh2  = $CCHigh2_SC;
            	  }
 		#in case of SO7 type, re-calculate CC
            	  elsif (((substr $row->{US2_NNF_ANTH}, 0, 2) eq "SO" || (substr $row->{US2_NNF_ANTH}, 0, 2) eq "so") && (substr $row->{US2_NNF_ANTH}, 2, 2) gt 0) {
           		  $CCLow2   = $CCLow2_SO;
                	  $CCHigh2  = $CCHigh2_SO;
             	 }


             	 $NFL_Record12 = $row->{CAS_ID} . "," . $SMR  . "," .  $StandStructureVal . "," . $row->{US2_SEQ} . "," . $layer_rank2;
            	  $NFL_Record22 = $CCHigh2 . "," . $CCLow2 . "," . UNDEF . "," . UNDEF;
            	  $NFL_Record32 = $NatNonVeg2 . "," . $NonForAnth2 . "," . $NonForVeg2;
            	 $NFL_Record2 = $NFL_Record12 . "," . $NFL_Record22 . "," . $NFL_Record32;
              	print CASNFL $NFL_Record2 . "\n";
		if($nbpr==1){$nbpr++;$$nnfl++;$nnflprev++;}
	   }
            else {}


            #layer 3
            if (!isempty($row->{US3_SP1}) || $lyr_poly3 ) {
	      $LYR_Record13 = $row->{CAS_ID} . "," . $SMR  . "," . $StandStructureVal . "," . $row->{US3_SEQ} . "," . $layer_rank3;
	      $LYR_Record23 = $CCHigh3 . "," . $CCLow3 . "," . $HeightHigh3 . "," . $HeightLow3 . "," .  $prodFor3. "," .$SpeciesComp3;
	      $LYR_Record33 = $OriginHigh3 . "," . $OriginLow3 . "," . $SiteClass . "," . $SiteIndex;
	      $Lyr_Record43 = $LYR_Record13 . "," . $LYR_Record23 . "," . $LYR_Record33;
	      print CASLYR $Lyr_Record43 . "\n";
		if($nbpr==1){$nbpr++; $$nlyr++;$nlyrprev++;}
	   }
            elsif (!isempty($row->{US3_NNF_ANTH})) {
              #in case of SC7 type, re-calculate CC
            	  if (((substr $row->{US3_NNF_ANTH}, 0, 2) eq "SC" || (substr $row->{US3_NNF_ANTH}, 0, 2) eq "sc") && (substr $row->{US3_NNF_ANTH}, 2, 2) gt 0) {
           	  	$CCLow3   = $CCLow3_SC;
                 	 $CCHigh3  = $CCHigh3_SC;
           	   }
 		#in case of SO7 type, re-calculate CC
             	elsif (((substr $row->{US3_NNF_ANTH}, 0, 2) eq "SO" || (substr $row->{US3_NNF_ANTH}, 0, 2) eq "so") && (substr $row->{US3_NNF_ANTH}, 2, 2) gt 0) {
           		  $CCLow3   = $CCLow3_SO;
                	  $CCHigh3  = $CCHigh3_SO;
            	  }

         	     $NFL_Record13 = $row->{CAS_ID} . "," . $SMR  . "," . $StandStructureVal . "," . $row->{US3_SEQ} . "," . $layer_rank3;
          	    $NFL_Record23 = $CCHigh3 . "," . $CCLow3 . "," . UNDEF . "," . UNDEF;
            	  $NFL_Record33 = $NatNonVeg3 . "," . $NonForAnth3 . "," . $NonForVeg3;
            	  $NFL_Record3 = $NFL_Record13 . "," . $NFL_Record23 . "," . $NFL_Record33;
             	 print CASNFL $NFL_Record3 . "\n";
		if($nbpr==1){$nbpr++;$$nnfl++;$nnflprev++;}
	    }
            else {}

            #layer 4
            if (!isempty($row->{US4_SP1}) || $lyr_poly4 ) {
	      $LYR_Record14 = $row->{CAS_ID} . "," . $SMR  . ","  . $StandStructureVal . "," . $row->{US4_SEQ} . "," . $layer_rank4;
	      $LYR_Record24 = $CCHigh4 . "," . $CCLow4 . "," . $HeightHigh4 . "," . $HeightLow4 . "," . $prodFor4. "," . $SpeciesComp4;
	      $LYR_Record34 = $OriginHigh4 . "," . $OriginLow4 . "," . $SiteClass . "," . $SiteIndex;
	      $Lyr_Record44 = $LYR_Record14 . "," . $LYR_Record24 . "," . $LYR_Record34;
	      print CASLYR $Lyr_Record44 . "\n";
		if($nbpr==1){$nbpr++; $$nlyr++;$nlyrprev++;}
		}
            elsif (!isempty($row->{US4_NNF_ANTH})) {
             	 #in case of SC7 type, re-calculate CC
             	 if (((substr $row->{US4_NNF_ANTH}, 0, 2) eq "SC" || (substr $row->{US4_NNF_ANTH}, 0, 2) eq "sc") && (substr $row->{US4_NNF_ANTH}, 2, 2) gt 0) {
           		  $CCLow4   = $CCLow4_SC;
                	  $CCHigh4  = $CCHigh4_SC;
              	}

 			#in case of SO7 type, re-calculate CC
	   	 elsif (((substr $row->{US4_NNF_ANTH}, 0, 2) eq "SO" || (substr $row->{US4_NNF_ANTH}, 0, 2) eq "so") && (substr $row->{US4_NNF_ANTH}, 2, 2) gt 0) {
           		  $CCLow4   = $CCLow4_SO;
                 	 $CCHigh4  = $CCHigh4_SO;
              	}

            	  $NFL_Record14 = $row->{CAS_ID} . "," . $SMR  . "," . $StandStructureVal . "," . $row->{US4_SEQ} . "," . $layer_rank4;
            	  $NFL_Record24 = $CCHigh4 . "," . $CCLow4 . "," . UNDEF . "," . UNDEF;
             	 $NFL_Record34 = $NatNonVeg4 . "," . $NonForAnth4 . "," . $NonForVeg4;
             	 $NFL_Record4 = $NFL_Record14 . "," . $NFL_Record24 . "," . $NFL_Record34;
             	 print CASNFL $NFL_Record4 . "\n";
		if($nbpr==1){$nbpr++;$$nnfl++;$nnflprev++;}
		}
            else {}

            #layer 5
	if (defined $row->{US5_SP1} ){
            if (!isempty($row->{US5_SP1}) || $lyr_poly5 ) {
	      $LYR_Record15 = $row->{CAS_ID} . "," . $SMR  . ","  . $StandStructureVal . "," . $row->{US5_SEQ} . "," . $layer_rank5;
	      $LYR_Record25 = $CCHigh5 . "," . $CCLow5 . "," . $HeightHigh5 . "," . $HeightLow5 . "," .  $prodFor5. "," .$SpeciesComp5;
	      $LYR_Record35 = $OriginHigh5 . "," . $OriginLow5 . "," . $SiteClass . "," . $SiteIndex;
	      $Lyr_Record45 = $LYR_Record15 . "," . $LYR_Record25 . "," . $LYR_Record35;
	      print CASLYR $Lyr_Record45 . "\n";
	      if($nbpr==1){$nbpr++; $$nlyr++;$nlyrprev++;}
	    }
            elsif (!isempty($row->{US5_NNF_ANTH})) {
            	  #in case of SC7 type, re-calculate CC
             	 if (((substr $row->{US5_NNF_ANTH}, 0, 2) eq "SC" || (substr $row->{US5_NNF_ANTH}, 0, 2) eq "sc") && (substr $row->{US5_NNF_ANTH}, 2, 2) gt 0) {
           	 	 $CCLow5   = $CCLow5_SC;
                 	 $CCHigh5  = $CCHigh5_SC;
             	 }

		  #in case of SO7 type, re-calculate CC
             	elsif (((substr $row->{US5_NNF_ANTH}, 0, 2) eq "SO" || (substr $row->{US5_NNF_ANTH}, 0, 2) eq "so") && (substr $row->{US5_NNF_ANTH}, 2, 2) gt 0) {
           	   $CCLow5   = $CCLow5_SO;
                   $CCHigh5  = $CCHigh5_SO;
               }
              	$NFL_Record15 = $row->{CAS_ID} . "," . $SMR  . "," . $StandStructureVal . "," . $row->{US5_SEQ} . "," . $layer_rank5;
            	  $NFL_Record25 = $CCHigh5 . "," . $CCLow5 . "," . UNDEF . "," . UNDEF;
             	 $NFL_Record35 = $NatNonVeg5 . "," . $NonForAnth5 . "," . $NonForVeg5;
             	 $NFL_Record5 = $NFL_Record15 . "," . $NFL_Record25 . "," . $NFL_Record35;
             	 print CASNFL $NFL_Record5 . "\n";
		if($nbpr==1){$nbpr++;$$nnfl++;$nnflprev++;}
	     }
            else {}
	} 

            #Disturbance
	    if (!isempty($row->{OS_MOD1})  &&  $Dist1 !~ m/^($errcode)/ &&  $Dist1 !~ m/^($misscode)/) {  #&&  $Dist1 !=~ m/ERRCODE/
	      $DST_Record = $row->{CAS_ID} . "," . $Dist;
	      print CASDST $DST_Record .",1". "\n";
		if($nbpr==1) {$$ndstonly++; $ndstonlyprev++;}
			$nbpr++;$$ndst++;$ndstprev++;
	    }

      #Ecological, which layer for other info
		if  (!isempty($row->{OS_WETECO1}))
		{
            if ($Wetland ne MISSCODE &&  ((substr $row->{OS_WETECO1}, 0,1) ne "0") ) 
            {
                $Wetland = $row->{CAS_ID} . "," . $Wetland."WE".$row->{OS_WETECO1};
                print CASECO $Wetland . "\n";
				if($nbpr==1) {$$necoonly++;$necoonlyprev++;}
				$nbpr++;$$neco++;$necoprev++;
            }          
         	else  
         	{
                if( $row->{OS_WETECO1} ne "0")  
                {
                    $Wetland = $row->{CAS_ID} . "," . "-,-,-,-,"."WE".$row->{OS_WETECO1};
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

		if($nbpr ==1 )
		{
			$ndrops++;
			#if($row->{OS_SP1} eq ""  &&  $row->{OS_NNF_ANTH} eq "" && $Wetland eq  MISSCODE && $row->{OS_MOD1} eq "") {
					#	$keys ="MAY  DROP THIS>>>-natnonc=";
 					#	$herror{$keys}++; 
			#}
			#else {
			#	$keys ="!!! record may be dropped#"."sp1=".$row->{OS_SP1}."nfordesc".$row->{OS_NNF_ANTH}."mod1".$row->{OS_MOD1} ;
 				#$herror{$keys}++; 
				#$keys ="#droppable#";
 				#$herror{$keys}++; 
			#}
			print MISSING_STANDS "$CAS_ID, LYR from $Spcomp, NFL from $row->{OS_NNF_ANTH}, ECO from $row->{OS_WETECO1}, DST from $row->{OS_MOD1}  >>>file=$Glob_filename \n";
		}
    }   

  	$csv->eof or $csv->error_diag ();
  	close $MBinv;

	#%%spfreqprev=%spfreq;
	
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

