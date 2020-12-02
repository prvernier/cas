package ModulesV4::MBPRE97_conversion11;
# Use to convert TEMBEC

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(&MBPRE97inv_to_CAS );

#our %spfreq=();
our $nbas=0;
our $nbngr=0;
our $Species_table;	
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


use warnings;
our $Glob_CASID;
our $Glob_filename;
my $MAXk=0;


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

#SoilMoistureRegime  from $MOISTURE  (version FRI 1.3)
sub SoilMoistureRegime
{
	my $MoistReg;
	my %MoistRegList = ("", 1, "1", 1, "2", 1, "3", 1, "4", 1);

	my $SoilMoistureReg;

	($MoistReg) = shift(@_);  
	if(isempty($MoistReg))                	{ $SoilMoistureReg = MISSCODE;}
	elsif (($MoistReg eq "1") || ($MoistReg eq "2"))   { $SoilMoistureReg = "D"; }
	elsif (($MoistReg eq "3"))        		{ $SoilMoistureReg = "M"; }
	elsif (($MoistReg eq "4"))         		{ $SoilMoistureReg = "W"; }
	else                              { $SoilMoistureReg = ERRCODE; }

	return $SoilMoistureReg;
}

# from $CROWNCLOSURE for FRI 1.3
sub CCUpper 
{
	my $CCHigh;
	my $CC = shift(@_); 

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

sub CCLower 
{
	my $CCLow;
	my $CC = shift(@_);  

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


#from $CROWNCLOSURE for FRI PRIOR 1997

sub CCUpper_PR96 
{
	my $CCHigh;
	my $CC = shift(@_);  

 	if (isempty($CC)) { $CCHigh = MISSCODE; }
	elsif ($CC == 1)  { $CCHigh = 20; }
	elsif ($CC == 2)  { $CCHigh = 50; }
	elsif ($CC == 3)  { $CCHigh = 70; }
    elsif ($CC == 4)  { $CCHigh = 100; }
	else { $CCHigh = ERRCODE; }

	return $CCHigh;
}

sub CCLower_PR96 
{
	my $CCLow;
	my $CC = shift(@_); 

    if (isempty($CC)) { $CCLow = MISSCODE; }
	elsif ($CC == 1)  { $CCLow = 0; }
	elsif ($CC == 2)  { $CCLow = 21; }
	elsif ($CC == 3)  { $CCLow = 51; }
    elsif ($CC == 4)  { $CCLow = 71; }
	else { $CCLow = ERRCODE; }

	return $CCLow;
}


#from $HEIGHT (FLI)  and $HT (FRI)
sub StandHeight 
{
	my $Height = shift(@_);

	if  (isempty($Height))           { $Height = MISSCODE; }
	elsif  ($Height eq "0")          { $Height = MISSCODE; }
	elsif (($Height < 0)    || ($Height > 50))    { $Height = MISSCODE; }
	elsif (($Height > 0)   && ($Height <= 50))    { $Height = $Height; }
	return $Height;
}



sub Latine 
{
	my $CurrentSpecies = shift(@_);
	my $MoistCod = shift(@_);
	my $vtype = shift(@_);
	my $GenusSpecies;

	$_ = $CurrentSpecies;
	tr/a-z/A-Z/;
	$CurrentSpecies = $_;

	if ($CurrentSpecies =~ "JP" && length($CurrentSpecies)>2) 
	{
		print SPECSLOGFILE "Illegal species code $CurrentSpecies, ";	
		$CurrentSpecies =~ s/\\//;
		$GenusSpecies = $CurrentSpecies;
		print SPECSLOGFILE " will be replaced by $GenusSpecies, see at CAS_ID=$Glob_CASID,file=$Glob_filename\n";
	}
	
	if(isempty($CurrentSpecies))   { $GenusSpecies = "XXXX MISS"; }

	elsif ($Species_table->{$CurrentSpecies}) { $GenusSpecies = $Species_table->{$CurrentSpecies}; }
	#elsif ($CurrentSpecies eq "AS" && $vtype ==2) { $GenusSpecies = "Frax nigr"; $nbngr++; } #Ash
	#elsif ($CurrentSpecies eq "AS" && $vtype !=2) { $GenusSpecies = "Frax spp"; $nbas++; } #Ash
	#elsif (($CurrentSpecies eq "T") && ($MoistCod == 4)) { $GenusSpecies = "Lari lari"; }#Tamarack
	#elsif (($CurrentSpecies eq "T") && ($MoistCod != 4)) { $GenusSpecies = "Popu trem"; }#Trembling Aspen
	#elsif (($CurrentSpecies eq "S") && ($MoistCod == 4)) { $GenusSpecies = "Pice mari"; }#Black Spruce
	#elsif (($CurrentSpecies eq "S") && ($MoistCod != 4)) { $GenusSpecies = "Pice glau"; }#White Spruce
 	else {$GenusSpecies = SPECIES_ERRCODE;  print SPECSLOGFILE "Illegal species code $CurrentSpecies,CAS_ID=$Glob_CASID,file=$Glob_filename\n";  } 
	return $GenusSpecies;
}

#4 Species fields  # $COVERTYPE, $SUBTYPE  (from basal Area)

sub Species
{
	my ($SPcomposition,$MoistCod,$vtype,$spfreq) = @_;
	my $aux;
	my $Specs="";
	my $singleSP;
	my $i=0;
	my $j=0;
	my @ListSp; 
	my $Sp1;
	my $k=0;
	my $TotalPerctg=0;
	my $Speciescode;

	$SPcomposition =~ s/\s//g;
	$singleSP=$SPcomposition;   #print "entree sur $SPcomposition \n"; 

	while ($singleSP ne "" && $TotalPerctg <10) 
	{  
		while ($singleSP =~ /^\D/) 
		{  
			$i=$i+1;	
			$singleSP=~ s/^\D//;  
		}
		#$Specs=$Specs.",".(substr $SPcomposition, $j, $i);
		$Speciescode = (substr $SPcomposition, $j, $i);
		$spfreq->{$Speciescode}++;
		$Specs=$Specs.",".Latine($Speciescode, $MoistCod, $vtype);
		$j=$j+$i;	$i=0;

		while ($singleSP =~ /^\d/) 
		{  
			$i=$i+1;	
			$singleSP=~ s/^\d//;
		}
		$aux=(substr $SPcomposition, $j, $i);
		$aux=~ s/^0//;
		if($aux eq "") 
		{
			$aux=1; #print "look at $SPcomposition\n";
		}
		$TotalPerctg+=$aux; 
		$Specs=$Specs.",".$aux*10;
		$j=$j+$i;
		$i=0;
		$k=$k+1;
	}

	if($k > $MAXk)
	{
		$MAXk=$k;
	}
	
	#if ($k > 4 ){print "$SPcomposition\n";}
	while ($k < 7 )
	{
		if( $TotalPerctg <10)  
		{ 
			$Specs=$Specs.",XXXX MISS,0";
		}
		else 
		{ 
			$Specs=$Specs.",XXXX UNDF,0";
		}
		$k=$k+1;
	}                                     

	$Specs=~ s/^//;$Specs=~ s/^,//;

	#print $SPcomposition."\n";  print $Specs."\n\n";

	#if(grep ERRCODE, $Specs ) 
	#{
		#print "ERROR CODE FOUND\n"
	#}
	#@ListSp=split(/,/, $Specs);
	#$Sp1=$ListSp[0];

	#print "$Sp1 \n";
	return $Specs;
}

#4 Species fields  $COVERTYPE, $SUBTYPE  (from basal Area)
sub CoverTypeCode 
{
	my $Code; my $CCC;
	($Code) = shift(@_);

	if (($Code >= 0) && ($Code <= 3) )  {$CCC="S";}
	elsif (($Code >=4) && ($Code <= 7) )  {$CCC="M";}
	elsif (($Code >= 8) && ($Code < 9) )  {$CCC="N";}
	elsif (($Code >= 9) && ($Code < 10) )  {$CCC="H";}
	elsif (isempty($Code)) { $CCC=MISSCODE; }
	else {$CCC=ERRCODE; }

	return $CCC;
}

#from $YEAR_ORG
sub UpperLowerOrigin 
{
	my $Origin = shift(@_);

	if (isempty($Origin))  {$Origin = MISSCODE;}
	elsif ($Origin eq "0")  {$Origin = MISSCODE;}
	elsif ($Origin > 0) 
	{
	 	$Origin = $Origin; 
	}
	else 
	{ 
		$Origin = ERRCODE; 
	}

	return $Origin;
}

#Determine Site from SITE  pre 1997   FLI NONE
sub Site 
{
	my $Site;
	my $TPR;
	my %TPRList = ("", 1, "1", 1, "2", 1, "3", 1);

	($TPR) = shift(@_);

	if (isempty($TPR)) { $Site = MISSCODE; }
	elsif ($TPR eq "1")              { $Site = "G"; }
	elsif (($TPR eq "2"))            { $Site = "M"; }
	elsif (($TPR eq "3"))           { $Site = "P"; }
	else { $Site = ERRCODE; }
	return $Site;
}


#UnProdForest TM,TR, ?OM, AL, SD, SC, NP, 
#Natnonveg ==== AP, LA, RI, OC, RK, SD, SI, SL, EX, BE, WS, FL, IS, TF
#NonForestedVeg ---ST, SL, HF, HE, HG, BR, OM, BT
#Anthropogenic IN, FA, CL, SE, LG, BP, OT


#Non-forested anthropologocal stands  from $SUBTYPE?
sub NonForestedAnth 
{
	my $NonVegAnth = shift(@_);
	my %NonVegAnthList = ("", 1,  "811", 1, "812", 1, "813", 1, "815", 1,"816", 1, "810", 1, "814", 1, "840", 1);

	if (isempty($NonVegAnth)) { $NonVegAnth = MISSCODE; }
	elsif (!$NonVegAnthList {$NonVegAnth} ){ $NonVegAnth = ERRCODE; }

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
sub UnProdForest 
{

	my $NonProdFor = shift(@_);
	my %NonProdForList = ("", 1, "701", 1, "702", 1, "703", 1, "704", 1, "711", 1, "712", 1, "713", 1, "731", 1, "732",1, "733", 1, "734",1, "730",1, "700", 1, "710",1, "720",1);
	
	if (isempty($NonProdFor)) {$NonProdFor = MISSCODE; }
	elsif (!$NonProdForList {$NonProdFor}) { $NonProdFor = ERRCODE; }

	elsif (($NonProdFor eq "701"))	{ $NonProdFor = "TM"; }
	elsif (($NonProdFor eq "702"))	{ $NonProdFor = "TM"; }
	elsif (($NonProdFor eq "703"))	{ $NonProdFor = "TM"; }
	elsif (($NonProdFor eq "704"))	{ $NonProdFor = "TM"; }
    elsif (($NonProdFor eq "711"))  { $NonProdFor = "TR"; }
    elsif (($NonProdFor eq "712"))  { $NonProdFor = "TR"; }
    elsif (($NonProdFor eq "713"))  { $NonProdFor = "TR"; }
	elsif (($NonProdFor eq "730"))  { $NonProdFor = "NP"; }
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
sub NonForestedVeg 
{

	my $NonFor = shift(@_);
	#my %NonForList = ("", 1, "831", 1, "832", 1, "835", 1, "838", 1, "839", 1);
	my %NonForList = ("", 1, "831", 1, "832", 1, "835", 1, "821", 1, "822", 1, "823", 1, "824", 1, "801", 1, "721", 1, "722", 1, "723", 1, "724", 1, "725", 1,"800", 1, "830", 1, "820", 1, "825", 1, "833", 1, "834", 1);

	if (isempty($NonFor))  { $NonFor = MISSCODE; }
	elsif (!$NonForList {$NonFor} ){ $NonFor = ERRCODE; }
  
	elsif (($NonFor eq "831"))	{ $NonFor = "OM"; }
	elsif (($NonFor eq "832"))	{ $NonFor = "OM"; }
	elsif (($NonFor eq "835"))	{ $NonFor = "HG"; }
	elsif (($NonFor eq "821"))  { $NonFor = "HG"; }
	elsif (($NonFor eq "822"))  { $NonFor = "HG"; }
    elsif (($NonFor eq "823"))	{ $NonFor = "HG"; }
    elsif (($NonFor eq "824"))	{ $NonFor = "HG"; }
    elsif (($NonFor eq "801"))	{ $NonFor = "BT"; }
	elsif (($NonFor eq "721"))  { $NonFor = "ST"; }
    elsif (($NonFor eq "722"))  { $NonFor = "ST"; }
    elsif (($NonFor eq "723"))  { $NonFor = "ST"; }
    elsif (($NonFor eq "724"))  { $NonFor = "ST"; }
	elsif (($NonFor eq "725"))  { $NonFor = "ST"; }
	elsif (($NonFor eq "830") || ($NonFor eq "833") ||($NonFor eq "834"))   { $NonFor = "OM"; }
	elsif (($NonFor eq "820") || ($NonFor eq "825") )   { $NonFor = "HG"; }
	elsif (($NonFor eq "800"))   { $NonFor = "BT"; }
	else { $NonFor = ERRCODE; }
	return $NonFor;     
}


#Naturally non-vegetated  NNF_ANTH  (FLI)
sub NaturallyNonVeg 
{
    my $NatNonVeg;
    #my %NatNonVegList = ("", 1, "841", 1, "842", 1, "843", 1, "844", 1, "845", 1, "846", 1, "847", 1, "848", 1, "849", 1, "851", 1 );
	my %NatNonVegList = ("", 1, "841", 1, "842", 1, "843", 1, "844", 1, "845", 1, "846", 1, "847", 1, "848", 1, "849", 1, "851", 1, "802", 1, "803", 1, "804", 1, "838", 1, "839", 1 );

	($NatNonVeg) = shift(@_);
	if (isempty($NatNonVeg))  { $NatNonVeg = MISSCODE; }
	elsif (!$NatNonVegList {$NatNonVeg} ) { $NatNonVeg = ERRCODE; }
	
	elsif (($NatNonVeg eq "841"))   { $NatNonVeg = "SE"; }
    elsif (($NatNonVeg eq "842"))   { $NatNonVeg = "FA"; }
    elsif (($NatNonVeg eq "843"))   { $NatNonVeg = "FA"; }
    elsif (($NatNonVeg eq "844"))   { $NatNonVeg = "FA"; }
    elsif (($NatNonVeg eq "845"))   { $NatNonVeg = "IN"; }
    elsif (($NatNonVeg eq "846"))   { $NatNonVeg = "CL"; }
    elsif (($NatNonVeg eq "847"))   { $NatNonVeg = "FA"; }
    elsif (($NatNonVeg eq "848"))   { $NatNonVeg = "FL"; }
    elsif (($NatNonVeg eq "849"))   { $NatNonVeg = "BP"; }
    elsif (($NatNonVeg eq "851"))   { $NatNonVeg = "FA"; }
	elsif (($NatNonVeg eq "802"))	{ $NatNonVeg = "RK"; }
	elsif (($NatNonVeg eq "803"))	{ $NatNonVeg = "RK"; }
	elsif (($NatNonVeg eq "804"))	{ $NatNonVeg = "SD"; }
	elsif (($NatNonVeg eq "838"))	{ $NatNonVeg = "EX"; }
    elsif (($NatNonVeg eq "839"))   { $NatNonVeg = "BE"; }
	else { $NatNonVeg = ERRCODE; }

    return $NatNonVeg;
}
	

sub NonVegWater 
{

	my $NonVegW = shift(@_);
	my %NonVegWList = ("", 1, "900", 1, "901", 1, "991", 1, "992", 1, "993", 1, "994", 1, "995", 1);

	if (isempty($NonVegW))  { $NonVegW = MISSCODE; }
	elsif (!$NonVegWList {$NonVegW} ){ $NonVegW = ERRCODE; }
    	
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

# Determine wetland codes  $NonProdFor and subtype
sub WetlandCodes 
{
    my $WetlandCode = shift(@_);
	my $Wetland;

	my %WetList = ("", 1, "701", 1, "702", 1, "703", 1, "704",1,"721",1 , "722", 1, "723", 1, "724", 1, "725",1,"823",1 , "831", 1, "832", 1, "835", 1, "838",1,"848",1  ,"30", 1,"31", 1,"32", 1,"70", 1,"71", 1, "72", 1,"36", 1,"37", 1,"76", 1,"77", 1,"16", 1,"17", 1,"56", 1,"57", 1, "9E",1  );


	if (isempty($WetlandCode)) { $Wetland = MISSCODE; }
	elsif (!$WetList{$WetlandCode} ) {$Wetland = UNDEF; }
	
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
 	elsif ($WetlandCode eq "9E" ) {  $Wetland="S,O,N,S,";  }
	elsif ($WetList{$WetlandCode} ) {$Wetland="S,T,N,N,"; }
	else {$Wetland = UNDEF; }
	return $Wetland;
}


sub WetlandCodesT 
{
	
    my $LandMod = shift(@_);
	my $ECOS = shift(@_);
	my $Wetland;

	if ($LandMod eq "O" || $LandMod eq "W" ) { $Wetland = "W"; }
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


sub CorrectDistYear
{

	my $PrevYear = shift(@_);
	my $firstD = shift(@_);
	my $CYear;
	my $Delta;

	if ($firstD == 8 || $firstD == 9)
	{
    	$Delta = 3;
	}
	elsif ($firstD == 3 || $firstD==7)
	{
   		$Delta = 8;
	}
	elsif ($firstD == 0 || $firstD == 4 || $firstD == 2 || $firstD ==6)
	{
  		$Delta = 10;
	}
	else
	{
   		$Delta = 15;
	}

	$CYear=$PrevYear-$Delta;
	return $CYear;
}



sub MBPRE97inv_to_CAS 
{

	my $MB_File = shift(@_);
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
	my $nbasprev=shift(@_);
	my $nbngrprev=shift(@_);
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

	
	my $CAS_File_HDR = $CAS_File . ".hdr";
	my $CAS_File_CAS = $CAS_File . ".cas";
	my $CAS_File_LYR = $CAS_File . ".lyr";
	my $CAS_File_NFL = $CAS_File . ".nfl";
	my $CAS_File_DST = $CAS_File . ".dst";
	my $CAS_File_ECO = $CAS_File . ".eco";

	$nbas=0;
	$nbngr=0;

	#open (MBinv, "<$MB_File") || die "\n Error: Could not open MB input file ($MB_File)!\n";
	open (ERRS, ">>$ERRFILE") || die "\n Error: Could not open $ERRFILE file!\n";
	open (SPERRSFILE, ">>$SPERRS") || die "\n Error: Could not open $SPERRS file!\n";	
	open (SPECSLOGFILE, ">>$SPECSLOG") || die "\n Error: Could not open $SPECSLOG file!\n";
	open (MISSING_STANDS, ">>$MstandsLOG") || die "\n Error: Could not open $MstandsLOG file!\n";

	if($optgroups==1){

	 	$CAS_File_HDR = $pathname."/MBOtable.hdr";
	 	$CAS_File_CAS = $pathname."/MBOtable.cas";
	 	$CAS_File_LYR = $pathname."/MBOtable.lyr";
	 	$CAS_File_NFL = $pathname."/MBOtable.nfl";
	 	$CAS_File_DST = $pathname."/MBOtable.dst";
	 	$CAS_File_ECO = $pathname."/MBOtable.eco";
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



		my $HDR_Record =  "1,MB,,UTM,NAD83,INDUSTRY,Tembec,,,PRE97,,1997,1997,,,";
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


	
	my $Record; my @Fields;my $PolyNum; my $CAS_ID; my $MapSheetID; my $IdentifyID;my $Area; my $Perimeter;
	my $MoistReg; my $Height;
	my $Sp1;my $Sp2;my $Sp3; my $Sp4;
	my $Sp1Per;my $Sp2Per;my $Sp3Per;  my $Sp4Per; 
	my $CrownClosure;
	my $Origin; my $Age; my $NnForVeg; 
	my $WetEco;  my $Ecosite;my $SMR;my $StandStructureCode;
	my $CCHigh;my $CCLow;
	my $SpeciesComp; my $SpComp; 
	my $SiteClass; my $SiteIndex;my $UnprodFor;
	my $Wetland;  
	my $NatNonVeg; 

	my %herror=();
	my $keys;

	my $CAS_Record; my $Lyr_Record41; my $LYR_Record11; my $LYR_Record21; my $LYR_Record31;
	
	my $NFL_Record; my $NFL_Record1; my $NFL_Record11; my $NFL_Record21; my $NFL_Record31;
	my $PHOTO_YEAR;
	my $NnForVegCode;  my $NonVegAnth;my $NonProdFor; my $NonFor;  my $NonVegWat; my $Spcomp; my $Subtype;
	my $StandStructureVal; my $HeightHigh ;
    my  $HeightLow;   my  $OriginHigh; my $OriginLow; my $StrucVal;  my @ListSp;
    my $pr1; my $pr2; my $pr3; my $pr4; my $pr5;
  	my @SpecsPerList=(); my $cpt_ind; my $dstb;my $DST_Record; my $delta1; my $ModYr;


	my $csv = Text::CSV_XS->new(
	{
		binary          => 1,
		sep_char    => ";" 
	});
   	open my $MBinv, "<", $MB_File or die " \n Error: Could not open Manitoba Tembec input file $MB_File: $!";

	my @tfilename= split ("/", $MB_File);
	my $nps=scalar(@tfilename);
	$Glob_filename= $tfilename[$nps-1];

   	$csv->column_names ($csv->getline ($MBinv));

   	while (my $row = $csv->getline_hr ($MBinv)) 
   	{	
   		#print "CAS_ID is $row->{CAS_ID}  and AREA is $row->{OBJECTID_1} \n"; exit(0);
          
		($pr1,$pr2,$pr3, $pr4, $pr5)     =  split("-", $row->{CAS_ID} );   	    
	    $MapSheetID   =  $pr3; 
	    $MapSheetID =~ s/x+//;
		$PolyNum =$pr4;  
		# faut-t-il supprimer les 0 du d/but? si oui faire la ligne suivante, sinon la supprimer
		$PolyNum =~ s/^0+//;
	


	 	#$PolyNum      =  $row->{POLYNUM};    
	 	$CAS_ID       =  $row->{CAS_ID};   
		$Glob_CASID   =  $row->{CAS_ID};
        #$MapSheetID   =  $row->{MAPSHEET};    
        $IdentifyID   =  $row->{HEADER_ID};  
 		$Area         =  $row->{GIS_AREA};    
	 	$Perimeter    =  $row->{GIS_PERI};          
	 	$PHOTO_YEAR =  $row->{FRI_YR};	    
	 	$MoistReg     =  $row->{MOIST};	
	 	$CrownClosure =  $row->{CROWN10};
	 	$Height      =  $row->{HEIGHT};         
		$Spcomp       = $row->{SPECIES};
	 	$NnForVeg     =  $row->{SUBTYPE}; #3 digits and $Spcomp  eq ""		  
 		$Subtype     =  $row->{SUBTYPE};
        my $Originlog= $Origin       = $row->{YEAR_ORG};         
	 	$Age          =  $row->{AGE};  #photoyear=$Origin+$Age 
	 	$WetEco      =  $row->{SUBTYPE};   #NonProdFor from  $NnForVeg  #3 digits beginning with 7
        #$Ecosite      =  $Fields[29];   #vegetation type

 		$Origin =~ s/\.([0-9]+)$//g;

		$dstb=0;
	  	if($Origin ne "0" && !isempty($Origin) &&  !isempty($PHOTO_YEAR)) {

			if($Origin>0 && $Origin >$PHOTO_YEAR) 
			{
				$dstb=1;
	  		}
		}

	  	if(!isempty($row->{YEAR_ORG}) && !isempty($PHOTO_YEAR))
	  	{
			if($row->{YEAR_ORG} > $PHOTO_YEAR && $row->{YEAR_ORG} > 0)
			{
				if(length $NnForVeg !=3)
				{
					if(length $NnForVeg ==2)
					{
						$delta1=substr $NnForVeg, 0,1;
					}
					elsif(length $NnForVeg ==1)
					{
						$delta1=0;
					}  
		 			$Origin = CorrectDistYear($row->{YEAR_ORG}, $delta1);
					$Origin =~ s/\.([0-9]+)$//g;
					$OriginHigh=$Origin;
					$OriginLow=$Origin;
		 		}
			}
	 	}

		#if($PHOTO_YEAR ne ""){
	 	#  if( $Origin  >0 && $Origin  >$PHOTO_YEAR){
		#	$keys="Origin STILL greater than PY#".$Origin."#original#".$row->{YEAR_ORG}."#photoyear#".$PHOTO_YEAR."#covertype#".$NnForVeg;
			#$herror{$keys}++;
		 # }
		#}	
	  	$SMR =  SoilMoistureRegime($MoistReg);
	  	if($SMR eq ERRCODE) 
	  	{ 
			if($MoistReg == 0){$SMR=UNDEF;} 
			elsif($MoistReg == 8)
			{
				$MoistReg=3; 
				$SMR="M";
			} 
			else 
			{
				$keys="MoistReg"."#".$MoistReg;
				$herror{$keys}++;
			}	
		}

        $StandStructureCode   = "S"; 
        $StandStructureVal    =  UNDEF;  #"";

        $CCHigh       =  CCUpper($CrownClosure);
        $CCLow        =  CCLower($CrownClosure);
        my $Specs="";
          
	  	if($CCHigh  eq ERRCODE   || $CCLow  eq ERRCODE) 
	  	{ 
	  		$keys="CrownClosure"."#".$CrownClosure;
			$herror{$keys}++;
		}
	  
        $HeightHigh   =  StandHeight($Height);
        $HeightLow    =  StandHeight($Height);
        if( ($HeightHigh eq MISSCODE || $HeightLow eq MISSCODE) && !isempty($Height) && $Height ne "0") 
        {
			$keys="Heigh#".$row->{os_HT}."#comt#".$row->{os_COMHT}."#canlay#".$row->{os_CANLAY};
			$herror{$keys}++;
	  	}

        $SpeciesComp  =  Species($Spcomp, $MoistReg, $row->{V_TYPE},$spfreq);  #print "$Spcomp transl in $SpeciesComp \n";
	  	#if  (grep ERRCODE, $SpeciesComp)
	  	if (index($SpeciesComp , SPECIES_ERRCODE) > -1)  
	  	{ 
	  		$keys="speciescode"."#".$Spcomp." transl= ".$SpeciesComp;
			$herror{$keys}++;
		}

		@SpecsPerList = split(",", $SpeciesComp);  
		for($cpt_ind=0; $cpt_ind<=6; $cpt_ind++)
		{  
			my $posi=$cpt_ind*2;
        	if($SpecsPerList[$posi] eq SPECIES_ERRCODE) 
			{ 
				$keys="Species position#".$cpt_ind."##".$Spcomp;
              	$herror{$keys}++; 
			}
   		}
		my $total=$SpecsPerList[1] + $SpecsPerList[3]+ $SpecsPerList[5] +$SpecsPerList[7]+$SpecsPerList[9]+$SpecsPerList[11]+$SpecsPerList[13];
	
		if($total != 100 && $total != 0 )
		{
			$keys="total perct !=100 "."#$total#".$SpeciesComp."#original#".$Spcomp;
			$herror{$keys}++; 
		}
	  	$SpeciesComp  =  $SpeciesComp .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0"; # .UNDEF. "," .UNDEF. "," . UNDEF. "," .UNDEF. "," . UNDEF. "," .UNDEF;#. "," . UNDEF. "," .UNDEF."," .UNDEF. "," .UNDEF. "," . UNDEF. "," .UNDEF;	
		@ListSp=split(/,/, $SpeciesComp);
		$Sp1=$ListSp[0];
         
        $OriginHigh   =  UpperLowerOrigin($Origin);
        $OriginLow    =  UpperLowerOrigin($Origin);
         
		if($OriginHigh eq ERRCODE || $OriginLow eq ERRCODE) 
		{
			$keys="origin1#".$Origin;
			$herror{$keys}++;
		}
	
		if(($OriginHigh>0 && $OriginHigh <1600) || $OriginHigh >2014) 
		{
			$keys="WARNING !!! BOUNDS origin1#".$Origin;
			$herror{$keys}++;
			$OriginLow=ERRCODE;
			$OriginHigh=ERRCODE;
			#$dstb=1;
	  	}
		$StrucVal   =  UNDEF;#"";
		$SiteClass 	=  Site("");
		$SiteIndex 	=  UNDEF;# "";
        $UnprodFor 	=  UNDEF;#"";
        #use only one layer
        #$Wetland = WetlandCodes ($MoistReg, $WetEco1, $Ecosite, $NnfAnth, $Sp1, $Sp2, $Sp1Per, $CrownClosure1, $Height1);
	 	if(length($WetEco)== 3 || length($WetEco)==2 ) 
	 	{ 
			$Wetland = WetlandCodes ($WetEco);	
		 	if(length($WetEco)==3  && $Wetland  eq ERRCODE  ) 
		 	{ 
		 		$keys="Wetland"."#".$WetEco;
				$herror{$keys}++;
			}
		}
		else 
		{
			$Wetland =UNDEF;
		}
	  	# ===== Non-forested Land =====NonForestedAnth UnProdForest NonForestedVeg NaturallyNonVeg  NonVegWater
        #if(length($NnForVeg)==3  && $Spcomp eq "")
		if(length($NnForVeg)==3)
		{	
			$NnForVegCode =  $NnForVeg;
	 		$NonVegAnth	=  NonForestedAnth($NnForVegCode);
			$NonProdFor	=  UnProdForest($NnForVegCode);
	  		$NonFor 	=  NonForestedVeg($NnForVegCode);
	 		$NatNonVeg 	=  NaturallyNonVeg($NnForVegCode);
			$NonVegWat	=  NonVegWater($NnForVegCode);
			if($NatNonVeg eq ERRCODE)
			{
				$NatNonVeg=$NonVegWat;
			}
			if(($NonVegAnth  eq ERRCODE)  &&  ($NonProdFor  eq ERRCODE)  &&  ($NonFor  eq ERRCODE) &&  ($NatNonVeg  eq ERRCODE)) 
			{ 
				$keys="NonForVeg-NatNonVeg-NonForAnth"."#".$NnForVeg;  $herror{$keys}++; 
	  		}	
			# &&  ($NonVegWat  eq ERRCODE) 
		}
		else 
		{
			$NnForVegCode=""; 
			$NonVegAnth=$NonProdFor=$NonFor=$NatNonVeg=MISSCODE; 
		}     
	  	# ===== Modifiers =====  DIST=UNDEF;
	  	# ===== Output inventory info =====
		my $NumberLyr=1;


		my $ProdFor="PF";
		my $lyr_poly=0;
		if(isempty($Spcomp) || $Sp1 eq "XXXX MISS")
		{
			$SpeciesComp ="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";

			if($NonProdFor ne MISSCODE && $NonProdFor ne ERRCODE && $NonProdFor ne UNDEF)
			{
				$lyr_poly=1;
				$ProdFor = $NonProdFor;
			}
			elsif( ( !is_missing($CCHigh) ||  !is_missing($CCLow) || !is_missing($HeightHigh) || !is_missing($HeightLow)) && $CrownClosure != 0)
			{
				$ProdFor="PP";	
				$lyr_poly=1;
			}
			if($lyr_poly)
			{
				$keys="###check artificial lyr on #".$Spcomp."#";
				$herror{$keys}++; 
			}	
		}
		# if ($Mod  eq "CO")
		# {
		# 	$prod_for="PF";
		# 	$lyr_poly=1;
		# }
		
        $CAS_Record = $CAS_ID . "," . $PolyNum . "," . $StandStructureCode .",". $NumberLyr .",". $IdentifyID . "," . $MapSheetID . "," . $Area . "," . $Perimeter.",".$Area . ",".$PHOTO_YEAR;
	    print CASCAS $CAS_Record . "\n";
 	    $nbpr=1;$$ncas++;$ncasprev++;
        #layer 1
        if ($Sp1 ne "XXXX MISS" || $lyr_poly )
        {
	    	$LYR_Record11 = $CAS_ID . "," . $SMR  . "," .  $StandStructureVal . ",1,1";
	      	$LYR_Record21 = $CCHigh . "," . $CCLow . "," . $HeightHigh . "," . $HeightLow  . "," . $ProdFor. "," . $SpeciesComp;
	      	$LYR_Record31 = $OriginHigh . "," . $OriginLow . "," . $SiteClass . "," . $SiteIndex;
	      	$Lyr_Record41 = $LYR_Record11 . "," . $LYR_Record21 . "," . $LYR_Record31;
	      	print CASLYR $Lyr_Record41 . "\n";
			$nbpr++; $$nlyr++;$nlyrprev++;
	    }
        elsif (length($NnForVeg)==3 && (!is_missing($NonVegAnth) || !is_missing($NonFor) || !is_missing($NatNonVeg)) ) 
        {
            $NFL_Record11 = $CAS_ID . "," . $SMR  . "," .  $StandStructureVal . ",1,1";
            $NFL_Record21 = $CCHigh . "," . $CCLow . "," . UNDEF . "," . UNDEF;
            $NFL_Record31 = $NatNonVeg . "," . $NonVegAnth . "," . $NonFor;
            $NFL_Record1 = $NFL_Record11 . "," . $NFL_Record21 . "," . $NFL_Record31;
            print CASNFL $NFL_Record1 . "\n";
			$nbpr++;$$nnfl++;$nnflprev++;
	   	}
            
	   	else{}
           
        #Disturbance  is undef but if Origin year is > photoyear, log a disturbance record with MISSCODE
	    if($dstb==1)
	    {
			if($row->{YEAR_ORG} eq "")
			{
				$ModYr=MISSCODE;
			}
			else 
			{
				 $ModYr=$Origin;
			}
			$DST_Record = $row->{CAS_ID} . ",UK,".$ModYr.",-8888,-8888,-8888,-8888,-8888,-8888,-8888,-8888,-8888,-8888";
			print CASDST $DST_Record .",1\n";
			if($nbpr==1) {$$ndstonly++; $ndstonlyprev++;}
			$nbpr++;$$ndst++;$ndstprev++;
		}

        #Ecological, which layer for other info
	    if ($Wetland ne MISSCODE && $Wetland ne UNDEF) 
	    {
			if(!isempty($row->{V_TYPE}) &&  $row->{V_TYPE} ne "0" )
			{
		    	$Wetland = $CAS_ID . "," . $Wetland."V".$row->{V_TYPE};
			}
			else 
			{
				$Wetland = $CAS_ID . "," . $Wetland."-";
			}
	      	print CASECO $Wetland . "\n";
			if($nbpr==1) {$$necoonly++;$necoonlyprev++;}
			$nbpr++;$$neco++;$necoprev++;
	    }

		#TRACK THIS, WILL BE MISSING
		if($nbpr==1) 
		{
			print MISSING_STANDS "$CAS_ID, LYR from $Spcomp, NFL from $NnForVeg, ECO from $WetEco, DST from $Originlog (must be >$PHOTO_YEAR) >>>file=$Glob_filename \n";
		}
	}

	$csv->eof or $csv->error_diag ();
	close $MBinv;

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
	#close (MBinv);
	close (CASHDR);
	close (CASCAS);
	close (CASLYR);
	close (CASNFL);
	close (CASDST);
	close (CASECO);
	close(ERRS);	close(SPECSLOGFILE); close(MISSING_STANDS);  close (SPERRSFILE);
 
	$$nbngrprev+=$nbngr;
	print "total as=$nbngr\n";

	$$nbasprev+=$nbas;
	print "total as=$nbas\n";
	$total=$nlyrprev+ $nnflprev+  $ndstprev;
	$total2=$nlyrprev+ $nnflprev+  $ndstonlyprev + $necoonlyprev;
	#if($total > $ncasprev) {print "must check this !!! \n";}
	#print "$$ncas, $$nlyr, $$nnfl,  $$ndst, $total\n";
	#print "nb records in casfile : $ncasprev, lyrfile : $nlyrprev, nflfile : $nnflprev,  dstfile : $ndstprev--- total(without .cas): $total\n";
	#print " records in casfile : $ncasprev, lyrfile : $nlyrprev, nflfile : $nnflprev,  dstfile : $ndstprev($ndstonlyprev), ecofile : $necoprev($necoonlyprev)--- total (without .cas): $total($total2)\n";
	#print "MAXIMUM NUMBER OF SPECIES IS $MAXk\n";
}
1;

