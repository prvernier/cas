package ModulesV4::MB_frifli_gov_conversion09;


use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(&MBfrifliinv_to_CAS);
#our @EXPORT_OK = qw(%spfreq);
our $hdr_num;
#our %spfreq;
our $nbas=0;
our $Species_table;	
# our is a global variable that the main script will call
#our @EXPORT_OK = qw(@tabSpec &SoilMoistureRegime1 &SoilMoistureRegime2  &CCUpper  &CCLower &StandHeightUp &StandHeightLow &UpperOrigin &UpperOriginCompl &LowerOrigin &LowerOriginCompl  &Disturbance &DisturbanceM );

use strict;
use Text::CSV;
#use diagnostics;
#use Carp;

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

sub convert_to_int
{
	my $var = shift(@_);
	 
	if(!isempty($var))
	{
		my $intval = sprintf("%.0f", $var);
		return $intval;
	}
	else
	{
		return $var;
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
	
	my $version;
	my $MoistRegFRI; my $MoistRegFLI;
	my %MoistRegList_fli = ("", 1, "d", 1, "f", 1, "v", 1, "m", 1, "w", 1, "D", 1, "F", 1, "V", 1, "M", 1, "W", 1);
	my %MoistRegList_fri = ("", 1, "1", 1, "2", 1, "3", 1, "4", 1);

	my $SoilMoistureReg;
	($version) = shift(@_);  ($MoistRegFRI) = shift(@_);  ($MoistRegFLI) = shift(@_);  
	
	if($version eq "FLI")
	{
		if (isempty($MoistRegFLI))    { $SoilMoistureReg = MISSCODE; }
		elsif (!$MoistRegList_fli {$MoistRegFLI}) { $SoilMoistureReg = ERRCODE; }
		elsif (($MoistRegFLI eq "d") || ($MoistRegFLI eq "D"))         { $SoilMoistureReg = "D"; }
		elsif (($MoistRegFLI eq "m") || ($MoistRegFLI eq "M"))         { $SoilMoistureReg = "M"; }
		elsif (($MoistRegFLI eq "w") || ($MoistRegFLI eq "W"))         { $SoilMoistureReg = "W"; }
		elsif (($MoistRegFLI eq "f") || ($MoistRegFLI eq "F"))         { $SoilMoistureReg = "F"; }
       	elsif (($MoistRegFLI eq "v") || ($MoistRegFLI eq "V"))         { $SoilMoistureReg = "F"; }
		else                              { $SoilMoistureReg = ERRCODE; }
		return $SoilMoistureReg;
	}
	elsif($version eq "FRI")
	{

		if (isempty($MoistRegFRI))    { $SoilMoistureReg = MISSCODE; }
		elsif (!$MoistRegList_fri {$MoistRegFRI} )  { $SoilMoistureReg = ERRCODE; }

		elsif (($MoistRegFRI == 1) || ($MoistRegFRI == 2) )         { $SoilMoistureReg = "D"; }
		elsif (($MoistRegFRI == 3))      { $SoilMoistureReg = "M"; }
		elsif (($MoistRegFRI == 4))      { $SoilMoistureReg = "W"; }
		else      					 { $SoilMoistureReg = ERRCODE; }
		return $SoilMoistureReg;
	}
	else 
	{
		print "incorrect standard version $version!!!";
		exit;
	}
}


sub CCUpper
{
	my $CCHigh;
	my $CC; my $CANLAY;

	($CC) = shift(@_);  ($CANLAY) = shift(@_);

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

	if  ($Height eq "")     { $Height = MISSCODE; }
	elsif (($Height <= 0)    || ($Height > 50))   { $Height = MISSCODE; }
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

sub Latine_fli 
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

#up to 7 Species fields  SP#  and SP#PER
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
	# my $Sp7    = shift(@_);
	# my $Sp7Per = shift(@_);
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
	# if(isempty($Sp7Per))
	# {
	# 	$Sp7Per = 0;
	# }
	#if (defined $Sp7Per ){} else {$Sp7Per =0;}
	$Sp1Per=10*$Sp1Per; $Sp2Per=10*$Sp2Per; $Sp3Per=10*$Sp3Per; $Sp4Per=10*$Sp4Per; $Sp5Per=10*$Sp5Per; $Sp6Per=10*$Sp6Per; #$Sp7Per=10*$Sp7Per;

	$spfreq->{$Sp1}++;
	$spfreq->{$Sp2}++;
	$spfreq->{$Sp3}++;
	$spfreq->{$Sp4}++;
	$spfreq->{$Sp5}++;
	$spfreq->{$Sp6}++;
	# if (!isempty($Sp7))
	# {	
	# 	$spfreq->{$Sp7}++;
	# }
	# else
	# {
	# 	$Sp7 = "";
	# }
	$Sp1 = Latine_fli($Sp1); $Sp2 = Latine_fli($Sp2); $Sp3 = Latine_fli($Sp3); $Sp4 = Latine_fli($Sp4); $Sp5 = Latine_fli($Sp5);
	$Sp6 = Latine_fli($Sp6); #$Sp7 = Latine_fli($Sp7);
	
	$Species = $Sp1 . "," . $Sp1Per . "," . $Sp2 . "," . $Sp2Per . "," . $Sp3 . "," . $Sp3Per . "," . $Sp4 . "," . $Sp4Per . "," . $Sp5 . "," . $Sp5Per . "," . $Sp6 . "," . $Sp6Per; #. "," . $Sp7 . "," . $Sp7Per;

	return $Species;
}

#from $ORIGIN
sub UpperLowerOrigin 
{
	my $Origin;
	($Origin) = shift(@_);

	$Origin = convert_to_int($Origin);

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

#NWW-Lake Winnipeg  NWM-Lake Manitoba  NWO-Lake Winnipegosis  NWE-Red River  NWA-Assiniboine River  NSL-Small Islands - less then 2 hectares
 
sub NaturallyNonVeg 
{
    my $NatNonVeg;
    my %NatNonVegList = ("", 1, "NMB", 1, "NMC", 1, "NMF", 1, "NMR", 1, "NMS", 1, "NMM", 1, "NMG", 1, "NWL", 1, "NWR", 1, "NWF", 1, "NSL", 1,"NWO", 1,
				    "nmb", 1, "nmc", 1, "nmf", 1, "nmr", 1, "nms", 1, "nmm", 1, "nmg", 1, "nwl", 1, "nwr", 1, "nwf", 1,"nsl", 1,"nwo", 1   );

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
    elsif (($NatNonVeg eq "nsl") || ($NatNonVeg eq "NSL"))     { $NatNonVeg = "IS"; }
    elsif (($NatNonVeg eq "nwo") || ($NatNonVeg eq "NWO"))     { $NatNonVeg = "LA"; }
	else { $NatNonVeg = ERRCODE; }
        return $NatNonVeg;
}

#Non-forested anthropologocal stands
sub NonForestedAnth 
{
	my $NonForAnth = shift(@_);
	my %NonForAnthList = ("", 1, "CIP", 1, "CIW", 1, "CIU", 1, "ASC", 1, "ASP", 1, "ASR", 1, "ASN", 1, "AIH", 1, "AIR", 1, "AIG", 1, "AII", 1, "AIW", 1, "AIA", 1, "AIF", 1, "AIU", 1, "AFL", 1 , "AAR", 1, "ADD", 1,"CPR", 1 , "CA", 1, "CP", 1, "ASB", 1,
			 	     "cip", 1, "ciw", 1, "ciu", 1, "asc", 1, "asp", 1, "asr", 1, "asn", 1, "aih", 1, "air", 1, "aig", 1, "aii", 1, "aiw", 1, "aia", 1, "aif", 1, "aiu", 1 , "afl", 1, "aar", 1, "add", 1, "cpr", 1 , "cp", 1, "ca", 1, "asb", 1);

	if  (isempty($NonForAnth))					{ $NonForAnth = MISSCODE; }
	elsif (!$NonForAnthList {$NonForAnth} ) 	{ $NonForAnth = ERRCODE; }

	elsif (($NonForAnth eq "cip") || ($NonForAnth eq "CIP"))	{ $NonForAnth = "FA"; }
	elsif (($NonForAnth eq "ciw") || ($NonForAnth eq "CIW"))	{ $NonForAnth = "FA"; }
	elsif (($NonForAnth eq "ciu") || ($NonForAnth eq "CIU"))	{ $NonForAnth = "OT"; }
	elsif (($NonForAnth eq "asc") || ($NonForAnth eq "ASC"))	{ $NonForAnth = "SE"; }
    elsif (($NonForAnth eq "asp") || ($NonForAnth eq "ASP"))    { $NonForAnth = "FA"; }
    elsif (($NonForAnth eq "asr") || ($NonForAnth eq "ASR"))    { $NonForAnth = "SE"; }
    elsif (($NonForAnth eq "asn") || ($NonForAnth eq "ASN"))    { $NonForAnth = "FA"; }
    elsif (($NonForAnth eq "aih") || ($NonForAnth eq "AIH"))    { $NonForAnth = "FA"; }
    elsif (($NonForAnth eq "air") || ($NonForAnth eq "AIR"))    { $NonForAnth = "FA"; }
    elsif (($NonForAnth eq "aig") || ($NonForAnth eq "AIG"))    { $NonForAnth = "IN"; }
    elsif (($NonForAnth eq "aii") || ($NonForAnth eq "AII"))	{ $NonForAnth = "IN"; }
    elsif (($NonForAnth eq "aiw") || ($NonForAnth eq "AIW"))	{ $NonForAnth = "LG"; }
    elsif (($NonForAnth eq "aia") || ($NonForAnth eq "AIA"))	{ $NonForAnth = "FA"; }
    elsif (($NonForAnth eq "aif") || ($NonForAnth eq "AIF"))    { $NonForAnth = "SE"; }
	elsif (($NonForAnth eq "aiu") || ($NonForAnth eq "AIU"))	{ $NonForAnth = "OT"; }
	elsif (($NonForAnth eq "add") || ($NonForAnth eq "ADD"))	{ $NonForAnth = "CL"; } # ADDED ON 1ST-06-2015 
	elsif (($NonForAnth eq "aar") || ($NonForAnth eq "AAR"))	{ $NonForAnth = "FA"; } # ADDED ON 1ST-06-2015
	elsif (($NonForAnth eq "afl") || ($NonForAnth eq "AFL"))	{ $NonForAnth = "CL"; } # ADDED ON 1ST-06-2015 CPR, CP, NWO, CA, ASB, CP, CA

	elsif (($NonForAnth eq "cpr") || ($NonForAnth eq "CPR"))	{ $NonForAnth = "CL"; } # ADDED ON 1ST-06-2015 
	elsif (($NonForAnth eq "cp") || ($NonForAnth eq "CP"))	{ $NonForAnth = "CL"; } # ADDED ON 1ST-06-2015
	elsif (($NonForAnth eq "ca") || ($NonForAnth eq "CA"))	{ $NonForAnth = "CL"; } # ADDED ON 1ST-06-2015 
	elsif (($NonForAnth eq "asb") || ($NonForAnth eq "ASB"))	{ $NonForAnth = "CL"; } # ADDED ON 1ST-06-2015
	
	else { $NonForAnth = ERRCODE; }
	return $NonForAnth;
}


#Non-forested vegetation stands
sub NonForestedVeg 
{
    my $NonForVeg = shift(@_);
	my $Height=shift(@_);

    my %NonForVegList = ("", 1, "SO", 1, "SC", 1, "HG", 1, "HF", 1, "HU", 1, "BR", 1, "CL", 1, "AL", 1, "CC", 1, "CS", 1, "AS", 1, "VI", 1, "RA", 1, "DL", 1, "AU", 1, "WI", 1 , 
				    "so", 1, "sc", 1, "hg", 1, "hf", 1, "hu", 1, "br", 1, "cl", 1, "al", 1, "cc", 1, "cs", 1, "as", 1, "vi", 1, "ra", 1, "dl", 1, "au", 1 , "wi", 1  );

	if (isempty($NonForVeg)) { $NonForVeg = MISSCODE; }
	else 
	{
		#"VA", 1,"va", 1,
        #if SC followed by a number (e.g., SC7), convert to SC
        if ((substr $NonForVeg, 0, 2) eq "SC" || (substr $NonForVeg, 0, 2) eq "sc") { $NonForVeg = "SC"; }
		my $cod=(substr $NonForVeg, 0, 2);

	 	#if SO followed by a number (e.g., S07), convert to ST  or SL
        if (((substr $NonForVeg, 0, 2) eq "SO" || (substr $NonForVeg, 0, 2) eq "so")  && (substr $NonForVeg, 2, 2) gt 0) 
		{ 
			if  ($Height eq "")                                      { $Height = 0; }
			elsif (($Height < 0)    || ($Height > 50))               { $Height = 0; print "look at height $Height\n"; exit;}
			#print "$NonForVeg, cod =$cod, height = $Height \n"; 
			if(($Height >= 0)   && ($Height < 2)) {$NonForVeg = "SL"; }
			elsif(($Height >= 2)   && ($Height <= 50))  {$NonForVeg = "ST"; }
			else{ $NonForVeg = ERRCODE; }
			#print "$NonForVeg, cod =$cod, height = $Height , result = $NonForVeg\n"; 
		}
		elsif($cod eq "SO" )  {}  #  old {print "error on --$NonForVeg-- \n"; exit;}

		if (!$NonForVegList {$NonForVeg} ) 
		{ if (($NonForVeg ne "SL") && ($NonForVeg ne "ST")) {$NonForVeg = ERRCODE;}
		  else {return $NonForVeg;}
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
        elsif (($NonForVeg eq "wi") || ($NonForVeg eq "WI"))       { $NonForVeg = "ST"; } # ADDED ON 1ST-06-2015 
        #if (($NonForVeg eq "va") || ($NonForVeg eq "VA"))       { $NonForVeg = "VA"; }
		else {$NonForVeg = ERRCODE;}
	}
    return $NonForVeg;
}

#in case of SC7 type, need to compute CC
sub CCLower_SC 
{
	my $CCLow_SC=MISSCODE;
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
	my $CCHigh_SC=MISSCODE;
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
	my $CCLow_SO=MISSCODE;
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
	my $CCHigh_SO=MISSCODE;
	my $CC_SO;

	($CC_SO) = shift(@_);
	if (isempty($CC_SO)) {$CC_SO ="";}

    if (((substr $CC_SO, 0, 2) eq "SO" || (substr $CC_SO, 0, 2) eq "so") && (substr $CC_SO, 2, 2) gt 0) 
    {
        $CCHigh_SO   =  ((substr $CC_SO, 2, 2) + 1) . 0;
    }

	return $CCHigh_SO;
}

					
#valid list CO,PC,BU, WF, DI, IK, FL,WE, SL,OT, DT,SI, UK
sub Disturbance
{
	my $ModCode;
	my $Mod;
	my $ModYr;
	my $Disturbance;
	
	my %ModList = ("", 1, "CC", 1, "BU", 1, "WF", 1, "IK", 1, "DI", 1,"DM", 1, "UK", 1, "WE", 1, "DT", 1, "BT", 1, "CL", 1, "BF", 1, "SF", 1, "IB", 1, "SN", 1, "PP", 1,
	"cc", 1, "bu", 1, "wf", 1, "ik", 1, "di", 1, "uk", 1, "we", 1, "dt",1, "dm", 1, "bt", 1, "cl", 1, "bf", 1, "sf", 1, "ib", 1, "sn", 1, "pp", 1);
   
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
			elsif (($ModCode  eq "DI") || ($ModCode eq "di"))   { $Mod="DI"; }
			elsif (($ModCode  eq "DM") || ($ModCode eq "dm"))   { $Mod="DI"; }
			elsif (($ModCode  eq "IK") || ($ModCode eq "ik")) { $Mod="IK"; }
			elsif (($ModCode  eq "IB") || ($ModCode eq "ib")) { $Mod="IK"; }
			elsif (($ModCode  eq "UK") || ($ModCode eq "uk")) { $Mod="OT"; }
			elsif (($ModCode  eq "BF") || ($ModCode eq "bf")) { $Mod="FL"; }
			elsif (($ModCode  eq "SF") || ($ModCode eq "sf")) { $Mod="FL"; }

			elsif (($ModCode  eq "BF") || ($ModCode eq "bf")) { $Mod="FL"; }
			elsif (($ModCode  eq "WE") || ($ModCode eq "we")) { $Mod="WE"; }
			elsif (($ModCode  eq "DT") || ($ModCode eq "dt"))   { $Mod="DT"; }
			elsif (($ModCode  eq "BT") || ($ModCode eq "bt")) { $Mod="OT"; }
			elsif (($ModCode  eq "PP") || ($ModCode eq "pp")) { $Mod="UK"; }
				
			elsif (($ModCode  eq "SN") || ($ModCode eq "sn")) { $Mod=MISSCODE; }

			$Disturbance = $Mod . "," . $ModYr; 
	    }
	   else { $Disturbance = MISSCODE.",".$ModYr; }
	} 
	else { $Mod = ERRCODE; $Disturbance = $Mod . "," . $ModYr;  }

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
	
	elsif (!$DistExtList{$ModExt}) {$DistExtLower = ERRCODE; }
	
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
	my $SP1  = shift(@_);
    my $NNV1  = shift(@_);
    my $SP2  = shift(@_);
    my $NNV2  = shift(@_);
    my $SP3  = shift(@_);
	my $NNV3  = shift(@_);
    my $SP4  = shift(@_);
    my $NNV4  = shift(@_);
    my $SP5  = shift(@_);
    my $NNV5  = shift(@_);

	my $NumberOfLayers = 0;

	if (isempty($SP1))  {$SP1 ="";}
	if (isempty($SP2))  {$SP2 ="";}
	if (isempty($SP3))  {$SP3 ="";}
	if (isempty($SP4))  {$SP4 ="";}
	if (isempty($SP5))  {$SP5 ="";}
	if (isempty($NNV1)) {$NNV1 ="";}
	if (isempty($NNV2)) {$NNV2 ="";}
	if (isempty($NNV3)) {$NNV3 ="";}
	if (isempty($NNV4)) {$NNV4 ="";}
	if (isempty($NNV5)) {$NNV5 ="";}

    if ( $SP5 ne "" || $NNV5 ne "" ) { $NumberOfLayers = 5; }
    elsif ( $SP4 ne "" || $NNV4 ne "" ) { $NumberOfLayers = 4; }
    elsif ( $SP3 ne "" || $NNV3 ne "" ) { $NumberOfLayers = 3; }
    elsif ( $SP2 ne "" || $NNV2 ne "" ) { $NumberOfLayers = 2; }
    elsif ( $SP1 ne "" || $NNV1 ne "" ) { $NumberOfLayers = 1; }
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

	if (!$WetList{$WetlandCode} )  {$Wetland = ERRCODE; }
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


##############################################FRI subroutines

#Moisture function, defined by SC

sub SoilMoistureRegime_FRI{
	my $MoistReg=shift(@_);

	my %MoistRegList = ("", 1, "1", 1, "2", 1, "3", 1, "4", 1);
	my $SoilMoistureReg;
	if ($MoistRegList {$MoistReg} ) { } else { $SoilMoistureReg = ERRCODE; }

	if (isempty($MoistReg))         { $SoilMoistureReg = MISSCODE; }
	elsif (($MoistReg == 1))         { $SoilMoistureReg = "D"; }
	elsif (($MoistReg == 2))      { $SoilMoistureReg = "D"; }
	elsif (($MoistReg == 3))      { $SoilMoistureReg = "M"; }
	elsif (($MoistReg == 4))      { $SoilMoistureReg = "W"; }
	else                          { $SoilMoistureReg = ERRCODE; }

	return $SoilMoistureReg;
}


sub CCUpper_FRI {
	my $CCHigh;
	my $CC;
	
	($CC) = shift(@_);
    #if(defined $CC) {} else {$CC="";}  

 	if (isempty($CC)) { $CCHigh = MISSCODE; }
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


sub CCLower_FRI {
	my $CCLow;
	my $CC;

	($CC) = shift(@_); 
	#if(defined $CC) {} else {$CC="";}  
    	
	if (isempty($CC)) { $CCLow = MISSCODE; }
	elsif ($CC == 0)  { $CCLow = 0; }
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

sub StandHeight_FRI {
	my $Height;

	($Height) = shift(@_);
	#if (defined $Height){} else {$Height ="";}
	 
	if  (isempty($Height))                                      { $Height = MISSCODE; }
	elsif (($Height < 0)    || ($Height > 50))                  { $Height = 0; }
	elsif (($Height >= 0)   && ($Height <= 50))                 { $Height = $Height; }

	return $Height;
}
#Determine Site from SITE  pre 1997   FLI NONE
sub Site_FRI {
	my $Site;
	my $TPR;
	my %TPRList = ("", 1, "1", 1, "2", 1, "3", 1);  #, "8", 1, "4", 1, "7", 1, "9", 1

	($TPR) = shift(@_);
	
	if(defined $TPR) {} else {$TPR="";}  
	if ($TPRList {$TPR} ) { } else { $Site = ERRCODE; }

	if  (isempty($TPR))                   { $Site = MISSCODE; }
	elsif ($TPR eq "1")                   { $Site = "G"; }
	elsif (($TPR eq "2"))                   { $Site = "M"; }
	elsif (($TPR eq "3") )                   { $Site = "P"; }
	#elsif (($TPR eq "8") )                   { $Site = UNDEF; }  #added to avoid error  -----not in the CAS doc
	#elsif (($TPR eq "4") )                   { $Site = UNDEF; }  #added to avoid error  -----not in the CAS doc
	#elsif (($TPR eq "7") )                   { $Site = UNDEF; }  #added to avoid error  -----not in the CAS doc
	#elsif (($TPR eq "9") )                   { $Site = UNDEF; }  #added to avoid error  -----not in the CAS doc
	return $Site;
}

sub Latine_FRI {
	my $CurrentSpecies = shift(@_);
	my $MoistCod=shift(@_);
	my $GenusSpecies;

	$_ = $CurrentSpecies;
	tr/a-z/A-Z/;
	$CurrentSpecies = $_;

	if (isempty($CurrentSpecies))   { $GenusSpecies = "XXXX MISS"; }

	elsif ($Species_table->{$CurrentSpecies}) { $GenusSpecies = $Species_table->{$CurrentSpecies}; }
	elsif ($CurrentSpecies eq "XX") { $GenusSpecies =  "XXXX MISS";  }
	elsif (($CurrentSpecies eq "T") && ($MoistCod == 4)) { $GenusSpecies = "Lari lari"; }#Tamarack
	elsif (($CurrentSpecies eq "T") && ($MoistCod != 4)) { $GenusSpecies = "Popu trem"; }#Trembling Aspen
	elsif (($CurrentSpecies eq "S") && ($MoistCod == 4)) { $GenusSpecies = "Pice mari"; }#Black Spruce
	elsif (($CurrentSpecies eq "S") && ($MoistCod != 4)) { $GenusSpecies = "Pice glau"; }#White Spruce
	else 	 {$GenusSpecies = SPECIES_ERRCODE;  print SPECSLOGFILE "Illegal species code $CurrentSpecies,CAS_ID=$Glob_CASID,file=$Glob_filename\n";  } 
	return $GenusSpecies;
}


sub Species_FRI{
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
	my $Sp7    = shift(@_);
	my $Sp7Per = shift(@_);
	my $spfreq=shift(@_);

	my $Species;
	my $CurrentSpec;

 	if (defined $Sp1Per ){} else {$Sp1Per =0;}
 	if (defined $Sp2Per ){} else {$Sp2Per =0;}
	if (defined $Sp3Per ){} else {$Sp3Per =0;}
	if (defined $Sp4Per ){} else {$Sp4Per =0;}
 	if (defined $Sp5Per ){} else {$Sp5Per =0;}
	if (defined $Sp6Per ){} else {$Sp6Per =0;}
	if (defined $Sp7Per ){} else {$Sp7Per =0;}

	$spfreq->{$Sp1}++;
	$spfreq->{$Sp2}++;
	$spfreq->{$Sp3}++;
	$spfreq->{$Sp4}++;
	$spfreq->{$Sp5}++;
	$spfreq->{$Sp6}++;$spfreq->{$Sp7}++;
	$Sp1 = Latine_FRI($Sp1); $Sp2 = Latine_FRI($Sp2); $Sp3 = Latine_FRI($Sp3); $Sp4 = Latine_FRI($Sp4); $Sp5 = Latine_FRI($Sp5); 
	$Sp6 = Latine_FRI($Sp6); $Sp7 = Latine_FRI($Sp7);
	$Species = $Sp1 . "," . $Sp1Per*10 . "," . $Sp2 . "," . $Sp2Per*10 . "," . $Sp3 . "," . $Sp3Per*10 . "," . $Sp4 . "," . $Sp4Per*10 . "," . $Sp5 . "," . $Sp5Per*10 . "," . $Sp6 . "," . $Sp6Per*10 . "," . $Sp7 . "," . $Sp7Per*10;

 

	return $Species;
}

#Non-forested anthropologocal stands  from $SUBTYPE?
sub NonForestedAnth_FRI {
	my $NonVegAnth = shift(@_);
	#my %NonVegAnthList = ("", 1, "801", 1, "802", 1, "803", 1, "804", 1, "811", 1, "812", 1, "813", 1, "815", 1,"816", 1, "821", 1, "822", 1, "823", 1, "824",1);
	my %NonVegAnthList = ("", 1,  "811", 1, "812", 1, "813", 1, "815", 1,"816", 1,  "810", 1, "814", 1, "840", 1);

	if  (isempty($NonVegAnth))		 { $NonVegAnth = MISSCODE; }
	elsif (!$NonVegAnthList {$NonVegAnth} ) { $NonVegAnth = ERRCODE; }

    elsif (($NonVegAnth eq "811"))   { $NonVegAnth = "CL"; }
    elsif (($NonVegAnth eq "812"))   { $NonVegAnth = "CL"; }
    elsif (($NonVegAnth eq "813"))   { $NonVegAnth = "CL"; }
    elsif (($NonVegAnth eq "815"))   { $NonVegAnth = "OT"; }
    elsif (($NonVegAnth eq "816"))   { $NonVegAnth = "CL"; }
	elsif (($NonVegAnth eq "840"))	{ $NonVegAnth = "FA"; }
    elsif (($NonVegAnth eq "810"))	{ $NonVegAnth = "CL"; }
    elsif (($NonVegAnth eq "814"))	{ $NonVegAnth = "CL"; }
	else { $NonVegAnth = ERRCODE; }

    return $NonVegAnth;
}


#Non-forested vegetation stands
sub UnProdForest_FRI {

my $NonProdFor = shift(@_);
	my %NonProdForList = ("", 1, "701", 1, "702", 1, "703", 1, "704", 1, "711", 1, "712", 1, "713", 1, "731", 1, "732",1, "733", 1, "734",1, "730",1, "700", 1, "710",1, "720",1);

	if  (isempty($NonProdFor))					{ $NonProdFor = MISSCODE; }
	elsif (!$NonProdForList {$NonProdFor} ) { $NonProdFor = ERRCODE; }
	elsif (($NonProdFor eq "701"))	{ $NonProdFor = "TM"; }
	elsif (($NonProdFor eq "702"))	{ $NonProdFor = "TM"; }
	elsif (($NonProdFor eq "703"))	{ $NonProdFor = "TM"; }
	elsif (($NonProdFor eq "704"))	{ $NonProdFor = "TM"; }
    elsif (($NonProdFor eq "711"))   { $NonProdFor = "TR"; }
    elsif (($NonProdFor eq "712"))   { $NonProdFor = "TR"; }
    elsif (($NonProdFor eq "713"))   { $NonProdFor = "TR"; }
	elsif (($NonProdFor eq "730"))   { $NonProdFor = "NP"; }
    elsif (($NonProdFor eq "731"))	{ $NonProdFor = "NP"; }
    elsif (($NonProdFor eq "732"))	{ $NonProdFor = "NP"; }
    elsif (($NonProdFor eq "733"))	{ $NonProdFor = "NP"; }
    elsif (($NonProdFor eq "734"))	{ $NonProdFor = "NP"; }
	elsif (($NonProdFor eq "700"))	{ $NonProdFor = "TM"; }
    elsif (($NonProdFor eq "710"))	{ $NonProdFor = "TR"; }
    elsif (($NonProdFor eq "720"))	{ $NonProdFor = "SD"; }
	else { $NonProdFor = ERRCODE; }
	return $NonProdFor;

}

#Non-forested vegetation stands
sub NonForestedVeg_FRI {

my $NonFor = shift(@_);
	#my %NonForList = ("", 1, "831", 1, "832", 1, "835", 1, "838", 1, "839", 1);
	my %NonForList = ("", 1, "831", 1, "832", 1, "835", 1, "821", 1, "822", 1, "823", 1, "824", 1, "801", 1, "721", 1, "722", 1, "723", 1, "724", 1, "725", 1, "800", 1, "830", 1, "820", 1, "825", 1, "833", 1, "834", 1);

	if  (isempty($NonFor))		{ $NonFor = MISSCODE; }
	elsif (!$NonForList {$NonFor} ) { $NonFor = ERRCODE; }
	elsif (($NonFor eq "831"))	{ $NonFor = "OM"; }
	elsif (($NonFor eq "832"))	{ $NonFor = "OM"; }
	elsif (($NonFor eq "835"))	{ $NonFor = "HG"; }
	#elsif (($NonFor eq "838"))	{ $NonFor = "EX"; }
    # elsif (($NonFor eq "839"))   { $NonFor = "BE"; }

	elsif (($NonFor eq "821"))   { $NonFor = "HG"; }
	elsif (($NonFor eq "822"))   { $NonFor = "HG"; }
    elsif (($NonFor eq "823"))	{ $NonFor = "HG"; }
    elsif (($NonFor eq "824"))	{ $NonFor = "HG"; }
    elsif (($NonFor eq "801"))	{ $NonFor = "BT"; }
	elsif (($NonFor eq "721"))   { $NonFor = "ST"; }
    elsif (($NonFor eq "722"))   { $NonFor = "ST"; }
    elsif (($NonFor eq "723"))   { $NonFor = "ST"; }
    elsif (($NonFor eq "724"))   { $NonFor = "ST"; }
	elsif (($NonFor eq "725"))   { $NonFor = "ST"; }
	elsif (($NonFor eq "830") || ($NonFor eq "833") ||($NonFor eq "834"))   { $NonFor = "OM"; }
	elsif (($NonFor eq "820") || ($NonFor eq "825") )   { $NonFor = "HG"; }
	elsif (($NonFor eq "800"))   { $NonFor = "BT"; }
	else { $NonFor = ERRCODE; }
	return $NonFor;
        
}


#Naturally non-vegetated  NNF_ANTH  (FLI)
sub NaturallyNonVeg_FRI 
{
    my $NatNonVeg;
    #my %NatNonVegList = ("", 1, "841", 1, "842", 1, "843", 1, "844", 1, "845", 1, "846", 1, "847", 1, "848", 1, "849", 1, "851", 1 );
	my %NatNonVegList = ("", 1, "841", 1, "842", 1, "843", 1, "844", 1, "845", 1, "846", 1, "847", 1, "848", 1, "849", 1, "851", 1, "802", 1, "803", 1, "804", 1, "838", 1, "839", 1, "902", 1 );

	($NatNonVeg) = shift(@_);
	if  (isempty($NatNonVeg))            { $NatNonVeg = MISSCODE; }
	elsif (!$NatNonVegList {$NatNonVeg})  { $NatNonVeg = ERRCODE; }
    elsif (($NatNonVeg eq "841"))     { $NatNonVeg = "SE"; }
    elsif (($NatNonVeg eq "842"))     { $NatNonVeg = "FA"; }
    elsif (($NatNonVeg eq "843"))     { $NatNonVeg = "FA"; }
    elsif (($NatNonVeg eq "844"))     { $NatNonVeg = "FA"; }
    elsif (($NatNonVeg eq "845"))     { $NatNonVeg = "IN"; }
    elsif (($NatNonVeg eq "846"))     { $NatNonVeg = "CL"; }
    elsif (($NatNonVeg eq "847"))     { $NatNonVeg = "FA"; }
    elsif (($NatNonVeg eq "848"))     { $NatNonVeg = "FL"; }
    elsif (($NatNonVeg eq "849"))     { $NatNonVeg = "BP"; }
    elsif (($NatNonVeg eq "851"))     { $NatNonVeg = "FA"; }

	elsif (($NatNonVeg eq "802"))	{ $NatNonVeg = "RK"; }
	elsif (($NatNonVeg eq "803"))	{ $NatNonVeg = "RK"; }
	elsif (($NatNonVeg eq "804"))	{ $NatNonVeg = "SD"; }

	elsif (($NatNonVeg eq "838"))	{ $NatNonVeg = "EX"; }
    elsif (($NatNonVeg eq "839"))   { $NatNonVeg = "BE"; }
 	elsif (($NatNonVeg eq "902"))   { $NatNonVeg = ERRCODE; }
	else { $NatNonVeg = ERRCODE; }

    return $NatNonVeg;
}


sub NonVegWater_FRI 
{

	my $NonVegW = shift(@_);
	my %NonVegWList = ("", 1, "900", 1, "901", 1, "991", 1, "992", 1, "993", 1, "994", 1, "995", 1);

	if  (isempty($NonVegW))		{ $NonVegW = MISSCODE; }
	elsif (!$NonVegWList {$NonVegW})  { $NonVegW = ERRCODE; }   	
	elsif (($NonVegW eq "900"))	{ $NonVegW = "LA"; }
	elsif (($NonVegW eq "901"))	{ $NonVegW = "RI"; }
	elsif (($NonVegW eq "991"))	{ $NonVegW = "LA"; }
	elsif (($NonVegW eq "992"))	{ $NonVegW = "LA"; }
	elsif (($NonVegW eq "993"))	{ $NonVegW = "LA"; }
    elsif (($NonVegW eq "994"))   { $NonVegW = "RI"; }
	elsif (($NonVegW eq "995"))   { $NonVegW = "RI"; }
	else { $NonVegW = ERRCODE; }
	return $NonVegW;
}




# Determine wetland codes  $NonProdFor for treed wetlands
sub WetlandCodes_FRI 
{
    my $WetlandCode = shift(@_);
	my $Wetland;

	my %WetList = ("", 1, "701", 1, "702", 1, "703", 1, "704",1,"721",1 , "722", 1, "723", 1, "724", 1, "725",1,"823",1 , "831", 1, "832", 1, "835", 1, "838",1,"848",1 );

	if (isempty($WetlandCode)) { $Wetland = MISSCODE; }
	elsif (!$WetList{$WetlandCode} ){$Wetland = UNDEF; }
	elsif ($WetlandCode eq "701")  {  $Wetland="B,T,N,N,"; }  #if ($WETECO1 eq "WE1")
	elsif ($WetlandCode eq "702")  {  $Wetland="F,T,N,N,";  }
	elsif ($WetlandCode eq "703")  {  $Wetland="S,T,N,N,";  }
    elsif ($WetlandCode eq "704")  {  $Wetland="F,T,N,N,";  }
	elsif ($WetlandCode eq "721")  {  $Wetland="S,O,N,S,";  }
	elsif ($WetlandCode eq "722")  {  $Wetland="S,O,N,S,"; }
	elsif ($WetlandCode eq "723")  {  $Wetland="S,O,N,S,";  }
	elsif ($WetlandCode eq "724")  {  $Wetland="S,O,N,S,";  }
	elsif ($WetlandCode eq "725")  {  $Wetland="S,O,N,S,";  }
	elsif ($WetlandCode eq "823") {  $Wetland="M,O,N,G,";  }
	elsif ($WetlandCode eq "831") {  $Wetland="F,O,N,S,";  }
	elsif ($WetlandCode eq "832") {  $Wetland="F,T,P,N,";  }
	elsif ($WetlandCode eq "835") {  $Wetland="M,O,N,G,";  }
	elsif ($WetlandCode eq "838") {  $Wetland="T,M,N,N,";  }
	elsif ($WetlandCode eq "848") {  $Wetland="O,O,N,N,";  }
 	else {$Wetland = MISSCODE;}
	return $Wetland;
}


sub WetlandCodesT_FRI 
{
	
    my $LandMod = shift(@_);
	my $ECOS = shift(@_);
	my $Wetland;

	if ($LandMod eq "O" || $LandMod eq "W" ) { $Wetland = "W,-,-,-,"; }
	#elsif ($ECOS eq "V2") {  $Wetland="S,T,N,N,";  }
	#elsif ($ECOS eq "V19") {  $Wetland="S,T,N,N,";  }
	#elsif ($ECOS eq "V20") {  $Wetland="F,T,N,N,";  }
	#elsif ($ECOS eq "V30") {  $Wetland="S,T,N,N,";  }
	#elsif ($ECOS eq "V31") {  $Wetland="S,T,N,N,";  }
	#elsif ($ECOS eq "V32") {  $Wetland="F,T,N,N,";  }
	#elsif ($ECOS eq "V33") {  $Wetland="B,T,N,N,";  }
	elsif ($ECOS eq "2") {  $Wetland="S,T,N,N,";  }
	elsif ($ECOS eq "19") {  $Wetland="S,T,N,N,";  }
	elsif ($ECOS eq "20") {  $Wetland="F,T,N,N,";  }
	elsif ($ECOS eq "30") {  $Wetland="S,T,N,N,";  }
	elsif ($ECOS eq "31") {  $Wetland="S,T,N,N,";  }
	elsif ($ECOS eq "32") {  $Wetland="F,T,N,N,";  }
	elsif ($ECOS eq "33") {  $Wetland="B,T,N,N,";  }
    else {$Wetland = MISSCODE;}
 
	return $Wetland;
}


sub CorrectDistYear
{

	my $PrevYear=shift(@_);
	my $firstD=shift(@_);
	my $CYear;
	my $Delta;

	if ($firstD == 8 || $firstD == 9){
    					$Delta = 3;
	}
	elsif ($firstD == 3 || $firstD==7){
   					$Delta = 8;
	}
	elsif ($firstD == 0 || $firstD == 4 || $firstD == 2 || $firstD ==6){
  				 	$Delta = 10;
	}
	else{
   					$Delta = 15;
	}

	$CYear=$PrevYear-$Delta;
	return $CYear;

}


sub productive_code
{

	my $prod = "";
	my ($Sp1, $CCHigh, $CCLow, $HeightHigh, $HeightLow, $CrownCl) = @_;
	my $SpeciesComp;
	my $prod_for="PF";
	my $lyr_poly=0;
	
	if(isempty($CrownCl))
	{
		$CrownCl = 0 ;
	}

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

###########################################################

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

