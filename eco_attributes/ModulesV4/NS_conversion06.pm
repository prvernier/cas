package ModulesV4::NS_conversion06;


use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(&NSinv_to_CAS );
#our @EXPORT_OK = qw(&SoilMoistureRegime &StandStructure  &StandStructureValue &CCUpper  &CCLower &StandHeight &Latine &UpperOrigin &NaturallyNonVeg  &LowerOrigin &Species  &Disturbance &Site );

use Cwd;
use Text::CSV; 
use strict;
use warnings;



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


#Determine StandStructure from StrucVal    REDO
sub StandStructureValue
{
	
	return UNDEF;
}

#Determine CCUpper from Density  CC  
#pre-2006
sub CCUpperp 
{
	my $CCHigh;
	my $Density;
	my %DensityList = ("", 1, "1", 1, "2", 1, "3", 1, "4", 1, "5", 1, "6", 1, "7", 1, "8", 1, "9", 1, "10", 1);

	($Density) = shift(@_);
	if ($DensityList {$Density} ) { } else {$CCHigh= ERRCODE; }

	if ($Density eq "")                                    { $CCHigh = 0; }
	elsif (($Density eq "1") )            { $CCHigh = 10; }
	elsif (($Density eq "2") )            { $CCHigh = 20; }
	elsif (($Density eq "3"))            { $CCHigh = 30; }
	elsif (($Density eq "4"))            { $CCHigh = 40; }
	elsif (($Density eq "5"))            { $CCHigh = 50; }
	elsif (($Density eq "6"))            { $CCHigh = 60; }
	elsif (($Density eq "7"))            { $CCHigh = 70; }
	elsif (($Density eq "8"))            { $CCHigh = 80; }
	elsif (($Density eq "9"))            { $CCHigh = 90; }
	elsif (($Density eq "10"))            { $CCHigh = 100; }
	
	return $CCHigh;
}

#Determine CCLower from Density  CC
#0-5	6-10	11-15	16-20	21-25	26-30	31-35	36-40	41-45	46-50	51-55	56-60	61-70	71-75	76-80	81-85	86-91	91-95	96-100

sub CCLowerp 
{
	my $CCLow;
	my $Density;
	my %DensityList = ("", 1, "1", 1, "2", 1, "3", 1, "4", 1, "5", 1, "6", 1, "7", 1, "8", 1, "9", 1, "10", 1);

	($Density) = shift(@_);
	if ($DensityList {$Density} ) { } else {$CCLow = ERRCODE; }

	if ($Density eq "")                                    { $CCLow = 0; }
	elsif (($Density eq "1"))            { $CCLow = 0; }
	elsif (($Density eq "2"))            { $CCLow = 11; }
	elsif (($Density eq "3"))            { $CCLow = 21; }
	elsif (($Density eq "4"))            { $CCLow = 31; }
	elsif (($Density eq "5"))            { $CCLow = 41; }
	elsif (($Density eq "6"))            { $CCLow = 51; }
	elsif (($Density eq "7"))            { $CCLow = 61; }
	elsif (($Density eq "8"))            { $CCLow = 71; }
	elsif (($Density eq "9"))            { $CCLow = 81; }
	elsif (($Density eq "10"))            { $CCLow = 91; }
	

	return $CCLow;
}

# > 2006
#Assigned in 5% increments from 0 to 95%.  e.g 27% = 25, 3% = 05
sub CCUpper 
{
	my $CCHigh;
	my $Density;	
	my $n;
	($Density) = shift(@_);
	
	if (isempty($Density))  { $CCHigh = MISSCODE; }
	else 
	{ 
		$n = $Density/5;
		$CCHigh = ($n+1)*5; 
	}
	return $CCHigh;
}

sub CCLower
{
	my $CCLow;
	my $Density;
	my $n;
	($Density) = shift(@_);
	 
	if (isempty($Density)) { $CCLow = MISSCODE; }
	else  
	{ 
		$n = $Density/5;
		$CCLow = $n*5; 
	}
	 
	return $CCLow;
}

#Determine stand height from Height   AVG_HT

sub StandHeight 
{
	my $Height;  
	my $HUpp;

	($Height) = shift(@_);
	 

	if  (isempty($Height))     { $HUpp = MISSCODE; }
	elsif ( ( $Height <= 0 ) || ( $Height > 50 ) ) { $HUpp = MISSCODE; }
	elsif ( ( $Height > 0 ) && ( $Height <= 50 ) ) { $HUpp = $Height; }
	else { $HUpp = ERRCODE; }
	
	return $HUpp;
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

	my $Species;
	my $CurrentSpec;
	my $spper1; 
	my $spper2;
	my $spper3;
	my $spper4;

	if (isempty($Sp1)) { $Sp1 = ""; }
	if (isempty($Sp2)) { $Sp2 = ""; }
	if (isempty($Sp3)) { $Sp3 = ""; }
	if (isempty($Sp4)) { $Sp4 = ""; }
	
	if ( isempty($Sp1Per)) { $spper1 = 0; }
	else { $spper1 = $Sp1Per * 10; }

	if ( isempty($Sp2Per)) { $spper2 = 0; }
	else { $spper2 = $Sp2Per * 10; }

	if ( isempty($Sp3Per)) { $spper3 = 0; }
	else { $spper3 = $Sp3Per * 10; }
	
	if ( isempty($Sp4Per)) { $spper4 = 0; }
	else { $spper4 = $Sp4Per * 10; }

	
	$spfreq->{$Sp1}++;
	$spfreq->{$Sp2}++;
	$spfreq->{$Sp3}++;
	$spfreq->{$Sp4}++;
	
	$Sp1 = Latine($Sp1); $Sp2 = Latine($Sp2); $Sp3 = Latine($Sp3); $Sp4 = Latine($Sp4); 
	#$Species = $Sp1 . "," . $Sp1Per . "," . $Sp2 . "," . $Sp2Per . "," . $Sp3 . "," . $Sp3Per . "," . $Sp4 . "," . $Sp4Per . "," . $Sp5 . "," . $Sp5Per;

	$Species = $Sp1 . "," . $spper1 . "," . $Sp2 . "," . $spper2 . "," . $Sp3 . "," . $spper3 . "," . $Sp4 . "," . $spper4 ;

	return $Species;
}


sub USpecies
{
	my $Sp   = shift(@_);
	my $spfreq = shift(@_);
	my $Sp1;
	my $spper1;
	my $Species;
	my $Sp2 ;
	my $spper2; 

	if (isempty($Sp)) { $Sp = ""; }
	if($Sp eq "S") {
		$Sp1="NOSC SOFT";  $spper1=85;  $Sp2="NOSC HARD"; $spper2=15; $spfreq->{$Sp}++;
	}
	elsif($Sp eq "SH") {
		$Sp1="NOSC SOFT";  $spper1=60; $Sp2="NOSC HARD";  $spper2=40; $spfreq->{$Sp}++;
	}
	elsif($Sp eq "HS") {
		$Sp1="NOSC HARD";  $spper1=60; $Sp2="NOSC SOFT";  $spper2=40; $spfreq->{$Sp}++;
	}
	elsif($Sp eq "H") {
		$Sp1="NOSC HARD";  $spper1=85; $Sp2="NOSC SOFT"; $spper2=15; $spfreq->{$Sp}++;
	}
	else 
	{
		print "Unrecognised config for Species in function USpecies;\n";
		exit(1);
	}

	$Species = $Sp1 . "," . $spper1 . "," . $Sp2 . "," . $spper2 . ",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";

	return $Species;
}
 
#Determine upper stand origin from AGE


#>2006
#Sw: 0,1,2,3,4=P, 5-9=M, 10-13=G                          Hw: 0,1=P, 2,3=M, 4,5=G
#Determine Site from SITE_CLAS
sub ActualOrigin
{
	my $Origin = shift(@_);

	if(isempty($Origin))
	{
		$Origin = MISSCODE;
	}
	elsif ($Origin >= 0) 
	{
		if ($Origin > 110) 
		{
	   		print "origin > maximum 110\n";
			exit(1);
		} 
	}
	else { $Origin = ERRCODE; }

	return $Origin;
}

sub Site1
{
	my $Site;
	my $SW;
	my %SWList = ("", 1, "0", 1, "1", 1, "2", 1, "3", 1, "4", 1, "5", 1, "6", 1, "7", 1, "8", 1, "9", 1, "10", 1, "11", 1, "12", 1, "13", 1);

	($SW) = shift(@_);

	if(isempty($SW))
	{
		$Site = MISSCODE;
	}
	elsif (!$SWList {$SW}) { $Site = ERRCODE; }

	elsif (($SW eq "0") || ($SW eq "1") || ($SW eq "2") || ($SW eq "3") || ($SW eq "4"))            { $Site = "P"; }
	elsif (($SW eq "5") || ($SW eq "6") || ($SW eq "7") || ($SW eq "8") || ($SW eq "9"))            { $Site = "M"; }
	elsif (($SW eq "10") || ($SW eq "11") || ($SW eq "12") || ($SW eq "13"))            { $Site = "G"; }
	
	return $Site;
}

sub Site2 
{
	my $Site;
	my $HW;
	my %HWList = ("", 1, "0", 1, "1", 1, "2", 1, "3", 1, "4", 1, "5", 1);

	($HW) = shift(@_);

	if(isempty($HW))
	{
		$Site = MISSCODE;
	}
	elsif (!$HWList {$HW} ) { $Site = ERRCODE; }

	elsif (($HW eq "0") || ($HW eq "1"))     { $Site = "P"; }
	elsif (($HW eq "2") || ($HW eq "3"))     { $Site = "M"; }
	elsif (($HW eq "4") || ($HW eq "5"))     { $Site = "G"; }
	
	return $Site;
}

#Determine SiteIndex from SITE_INDEX  VERIFY
sub SiteIndex 
{
	
	return UNDEF;
}


#Natnonveg ==== AP, LA, RI, OC, RK, SA, SI, SL, EX, BE, WS, FL, IS, TF
sub NaturallyNonVeg 
{
	my $NatNonVeg; my $ClassMod;

	($NatNonVeg) = shift(@_);
	if  (isempty($NatNonVeg))		{ $NatNonVeg = MISSCODE; }
	elsif (($NatNonVeg eq "77"))	{ $NatNonVeg = "LA"; }
	elsif (($NatNonVeg eq "84") || ($NatNonVeg eq "85"))	{ $NatNonVeg = "EX"; }
	elsif (($NatNonVeg eq "76"))	{ $NatNonVeg = "RK"; }
	elsif (($NatNonVeg eq "94"))	{ $NatNonVeg = "BE"; }
	elsif (($NatNonVeg eq "71"))	{ $NatNonVeg = "FL"; }
	elsif (($NatNonVeg eq "78"))	{ $NatNonVeg = "OC"; }
	else { $NatNonVeg = MISSCODE; }
	return $NatNonVeg;

	
}

#Anthropogenic IN, FA, CL, SE, LG, BP, OT

sub NonForestedAnth 
{
	my $NonForAnth;   
	($NonForAnth) = shift(@_);
	 
	if  (isempty($NonForAnth))	{ $NonForAnth = MISSCODE; }
	elsif (($NonForAnth  eq "93") || ($NonForAnth  eq "95"))	{ $NonForAnth  = "IN"; }
	elsif (($NonForAnth  eq "96")|| ($NonForAnth  eq "97"))	{ $NonForAnth  = "FA"; }
	elsif (($NonForAnth  eq "98") || ($NonForAnth  eq "99"))	{ $NonForAnth  = "FA"; }
	elsif (($NonForAnth  eq "91") || ($NonForAnth  eq "86") || ($NonForAnth  eq "5"))	{ $NonForAnth  = "CL"; }
	elsif (($NonForAnth  eq "87"))	{ $NonForAnth  = "SE"; }
	elsif (($NonForAnth  eq "92"))	{ $NonForAnth  = "OT"; }
	else { $NonForAnth = MISSCODE; }
	#return $Type_lnd.",".$NonForAnth;
	return $NonForAnth;
}

#NonForestedVeg ---ST, SL, HF, HE, HG, BR, OM, TN
#Determine Non-forested vegetation stands
sub NonForestedVeg 
{
	my $NonForVeg;  
	($NonForVeg) = shift(@_);
	
	if  (isempty($NonForVeg))					{ $NonForVeg =MISSCODE; }
	elsif (($NonForVeg eq "70") || ($NonForVeg eq "72")|| ($NonForVeg eq "75")|| ($NonForVeg eq "74"))	{ $NonForVeg = "OM"; }
	elsif (($NonForVeg eq "83")|| ($NonForVeg eq "33")|| ($NonForVeg eq "88")|| ($NonForVeg eq "38")|| ($NonForVeg eq "89") || ($NonForVeg eq "39"))	{ $NonForVeg = "ST"; }
	else { $NonForVeg = MISSCODE; }
	return $NonForVeg;

}

#UnProdForest TM, TR, AL, SD, SC, NP

sub UnProdForest 
{
    my $NonForVeg = shift(@_);
	
	if  (isempty($NonForVeg))		{ $NonForVeg = MISSCODE; }
	elsif (($NonForVeg eq "73"))	{ $NonForVeg = "TM"; }
	else { $NonForVeg = MISSCODE; }
	return $NonForVeg;
}

#Determine Disturbance from FORNON
#02=burn  06=windthrow   07=dead (<25%live)  08=dead 1(25-50%live)  09=dead2(51-70% live)  13= dead 3(25-50% dead)  14= dead 4(51-75%)   15 = dead 5(>75%)  60 = clearcut  61,62 = Partial cut
#two last digits of FORNON
#02 = BU             60 = CO	06 = WF     62 = PC    61 = PC	
#07 = OT  extent 5  08 = OT extent 3  09 = OT extent 2     13 = OT extent 2                       14 = OT extent 3	15 = OT extent 4

sub Disturbance 
{
	my $ModCode;
	my $Mod;
	my $ModYr;
	my $Disturbance;
	my $Extent = MISSCODE.",".MISSCODE;
   
	($ModCode) = shift(@_);
	$ModYr = UNDEF;

	if (isempty($ModCode)) {$Disturbance = MISSCODE . "," . $ModYr.",".$Extent; }
	elsif ($ModCode =~ /\d/) 
	{ 
 		if (($ModCode  eq "2")) { $Mod="BU"; }
		elsif (($ModCode  eq "6")) { $Mod="WF"; }
		elsif (($ModCode  eq "7")) { $Mod="OT"; $Extent="5,5";}
		elsif (($ModCode eq "8")) { $Mod="OT"; $Extent="3,3";}
		elsif (($ModCode  eq "60")) { $Mod="CO"; }
		elsif (($ModCode  eq "9") || ($ModCode eq "13"))   { $Mod="OT"; $Extent="2,2";}
		elsif (($ModCode  eq "62")) { $Mod="PC"; }
		elsif (($ModCode  eq "61")) { $Mod="PC"; }
		elsif (($ModCode  eq "14")) { $Mod="OT"; $Extent="3,3";}
		elsif (($ModCode eq "15")) { $Mod="OT"; $Extent="4,4";}
		elsif (($ModCode eq "12")) { $Mod="SI"; $Extent="4,4";} #newly aded by SGC - june 2015
		elsif (($ModCode eq "1")) { $Mod="SI"; $Extent="4,4";} #newly aded by SGC - june 2015
		else { $Mod=MISSCODE; $Extent="4,4";}
		$Disturbance = $Mod . "," . $ModYr. "," . $Extent; 
	} 
	else
	{ 
		$Mod = ERRCODE; $Disturbance = MISSCODE . "," . $ModYr. "," . $Extent;  
	}
	return $Disturbance;
}


# Determine wetland codes  from SMR (Moisture)
sub WetlandCodes 
{
	my $WetlandCode = shift(@_);
	my $specomp=shift(@_);
	my $CC=shift(@_);
	my $Height=shift(@_);
	my $Wetland  = "-,-,-,-,"; 
	#70 = W  71 = Mong  72 = Bonn  73 = Btnn  74 = Ecnn 75 = Mong

	
	if ($WetlandCode ==70) { $Wetland = "W,-,-,-,"; }
	elsif ($WetlandCode ==71) 
	{ $Wetland = "M,O,N,G,"; }
	elsif ($WetlandCode ==72) 
	{ $Wetland = "B,O,N,N,"; }
	elsif ($WetlandCode ==73) 
	{ $Wetland = "B,T,N,N,"; }
	elsif ($WetlandCode ==74) 
	{ $Wetland = "E,C,N,N,"; }
	elsif ($WetlandCode ==75) 
	{ $Wetland = "M,O,N,G,"; }
	   
	#elsif ($WetlandCode eq "") {$Wetland = MISSCODE;}
	else  {$Wetland = MISSCODE;}

	#add 17-09-2012
	if (($WetlandCode ==33 || $WetlandCode ==38 || $WetlandCode ==39) &&  ($specomp eq "BS10" || $specomp eq "TL10" || $specomp eq "EC10" || $specomp eq "WB10" || $specomp eq "YB10" || $specomp eq "AS10" ) ) 
	{ $Wetland = "S,O,N,S,"; }
	elsif ($WetlandCode ==0 && ($specomp eq "TL10" || ($specomp =~ m/TL/ && $specomp =~ m/WB/ ) && $CC <=50 && $Height <=12) )
	{ $Wetland = "F,T,N,N,"; }
	elsif ($WetlandCode ==0 && ($specomp eq "TL10" || ($specomp =~ m/TL/ && $specomp =~ m/WB/ ) && $CC >50) )
	{ $Wetland = "S,T,N,N,"; }
	elsif ($WetlandCode ==0 && ($specomp eq "EC10" || ($specomp =~ m/EC/ && $specomp =~ m/TL/ )  || ($specomp =~ m/EC/ && $specomp =~ m/BS/ )  || ($specomp =~ m/EC/ && $specomp =~ m/WB/ ) )) 
	{ $Wetland = "S,T,N,N,"; }
	elsif ($WetlandCode ==0 && ($specomp eq "AS10" || ($specomp =~ m/AS/ && $specomp =~ m/BS/ )  || ($specomp =~ m/AS/ && $specomp =~ m/TL/ )))
	{ $Wetland = "S,T,N,N,"; }
	elsif ($WetlandCode ==0 && ($specomp =~ m/BS/ && $specomp =~ m/LT/ )) 
	{ $Wetland = "S,T,N,N,"; }

	return $Wetland;
	
}


sub productive_code
{
	my ($Sp1, $CCHigh, $CCLow, $HeightHigh, $HeightLow, $CrownCl) = @_;
	my $SpeciesComp;
	my $prod_for="PF";
	my $lyr_poly=0;

	if(isempty($CrownCl) )
	{
		$CrownCl = 0;
	}
	if($CrownCl =~ /[A-D]/)
	{
		$CrownCl = 1;
	}
		
	if(isempty($Sp1))
	{
		#$SpeciesComp ="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";

		if(( ((!is_missing($CCHigh) ||  !is_missing($CCLow)) && $CrownCl != 0) || !is_missing($HeightHigh) || !is_missing($HeightLow)) )
		#if( ( !is_missing($CCHigh) ||  !is_missing($CCLow) || !is_missing($HeightHigh) || !is_missing($HeightLow)))
		{
			$prod_for="PP";	
			$lyr_poly=1;
		}
	}
	return ($prod_for, $lyr_poly );
}


sub NSinv_to_CAS 
{
	my $NS_File = shift(@_);
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

	if($optgroups==1)
	{

	 	$CAS_File_HDR = $pathname."/NStable.hdr";
	 	$CAS_File_CAS = $pathname."/NStable.cas";
	 	$CAS_File_LYR = $pathname."/NStable.lyr";
	 	$CAS_File_NFL = $pathname."/NStable.nfl";
	 	$CAS_File_DST = $pathname."/NStable.dst";
	 	$CAS_File_ECO = $pathname."/NStable.eco";
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

		my $HDR_Record =  "1,NS,,UTM,NAD83,PROV_GOV,Nova Scotia Department of Natural Resources,UNRESTRICTED,,,,1996,2006,,2012,";
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
	my $Twp;my $Gid;my $MoistReg;my $Density;  #my $Sp1;my $Sp1Per;my $Sp2;my $Sp2Per;my $Sp3;my $Sp3Per;my $Sp4;  my $Sp4Per; 
	my $Struc; my $StrucVal;
	my $Origin;my $TPR; my $Initials;  

	my $NFL; my $NFLPer;my $NatNon;my $AnthVeg; my $AnthNon;my $Mod1;my $Mod1Ext;my $Mod1Yr;my $Mod2;my $Mod2Ext;my $Mod2Yr;  my $Data; my $DataYr; 

	my $MoistCode;my $Mod3; 
	my $Mod3Ext; my $Mod3Yr;my $IntTpr;
	my $SMR; my $StandStructureCode;my $StandStructureVal; 
	my $CCHigh;my $CCLow; ;my $HeightHigh; 
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
	my $HeightLow;

	my %herror=();
	my $keys;

	my $CAS_Record; my $Lyr_Record; my $LYR_Record1; my $LYR_Record2; my $LYR_Record3;
	my $NFL_Record; my $NFL_Record1; my $NFL_Record2; my $NFL_Record3; my $DST_Record; 
	my $pr1; my $pr2; my $pr3; my $pr4; my $pr5;
	my $covtype; my $non_for;
	my $Distcode;my $Distcode2;my $Distcode3;my $Distcode4;
	my $nblayers;
	my  $UCCHigh; my  $UCCLow; my $UHeightHigh; my $UHeightLow;
	my $USpeciesComp;
	#CAS_ID,HEADER_ID,AREA,PERIMETER,FOREST_,FOREST_ID,MAPSTAND_,LNDCLASS,FORNON,SPECIES,CRNCL,HEIGHT,
	#ALLHEIGHT,SS_SPECIES,SS_CRNCL,SS_HEIGHT,SITE_SW,SITE_HW,FLDCHK,COVER_TYPE,PHOTOYR,HECTARES,MAPSHEET,
	#STAND_,FOR_NON,SP1,SP1P,SP2,SP2P,SP3,SP3P,SP4,SP4P,SHAPE_AREA,SHAPE_PERI
	my @SpecsPerList=();
	my $cpt_ind;
	#my $total;
	my $errspec;
	my $CASID;
	my $HeaderID;
	
	my $PhotoYear;
	my $CrownCl;
	my $Height;
	my $Sp1;
	my $Sp1P;
	my $Sp2;
	my $Sp2P;
	my $Sp3;
	my $Sp3P;
	my $Sp4;
	my $Sp4P;

	my $SS_Height;
	my $SS_CrownCl;
	my $SS_species;

	my $SiteSW;
	my $SiteHW;
	my $ForNon;
	my $LndClass;
	my $SpeciesCode;
	my $emit_lyr = 0;

	##############################################

	my $csv = Text::CSV_XS->new
	({
		binary          => 1,
		sep_char    => ";" 
	});
        
    open my $NSinv, "<", $NS_File or die " \n Error: Could not open NS input file $NS_File: $!";
	
	my @tfilename = split ("/", $NS_File);
	my $nps=scalar(@tfilename);
	$Glob_filename= $tfilename[$nps-1];

 	$csv->column_names ($csv->getline ($NSinv));

   	while (my $row = $csv->getline_hr ($NSinv)) 
   	{	 

		# added because of the new codification of CAS_ID

		$Glob_CASID   =  $row->{CAS_ID};

		($pr1,$pr2,$pr3, $pr4, $pr5)     =  split("-", $row->{CAS_ID} );   	    
	    $MapSheetID   =  $pr3; 
		$PolyNum = $pr4;  
		# faut-t-il supprimer les 0 du d/but? si oui faire la ligne suivante, sinon la supprimer
		$PolyNum =~ s/^0+//;
		$MapSheetID =~ s/^x+//;

		$CASID =  $row->{CAS_ID};
		$HeaderID = $row->{HEADER_ID};
		$Area =  $row->{GIS_AREA};
		$Perimeter = $row->{GIS_PERI};
		$PhotoYear = $row->{PHOTOYR};
		$CrownCl = $row->{CRNCL};
		$Height = $row->{HEIGHT};
		$Sp1 = $row->{SP1};
		$Sp1P = $row->{SP1P};
		$Sp2 = $row->{SP2};
		$Sp2P = $row->{SP2P};
		$Sp3 = $row->{SP3};
		$Sp3P = $row->{SP3P};
		$Sp4 = $row->{SP4};
		$Sp4P = $row->{SP4P};

		$SS_Height = $row->{SS_HEIGHT};
		$SS_CrownCl = $row->{SS_CRNCL};
		$SS_species = $row->{SS_SPECIES};

		$SiteSW = $row->{SITE_SW};
		$SiteHW = $row->{SITE_HW};
		$ForNon = $row->{FORNON};
		$LndClass = $row->{LNDCLASS};
		$SpeciesCode = $row->{SPECIES};

	  	$SMR = UNDEF;	
	  	$StandStructureCode = "S";
	  	$StandStructureVal = UNDEF;
	  	$nblayers=1;

	  	$CCHigh = CCUpper($CrownCl);
	  	$CCLow = CCLower($CrownCl);
	  	if($CCHigh  eq ERRCODE   || $CCLow  eq ERRCODE) 
	  	{ 
	  		$keys="Density"."#".$CrownCl;
			$herror{$keys}++;
		}

	  	$HeightHigh = StandHeight($Height);
	  	$HeightLow = StandHeight($Height);
	  	if($HeightHigh >0 ){$HeightHigh=$HeightHigh+0.5;}
		if($HeightLow >0.5){$HeightLow=$HeightLow-0.5;}

	  	if  (($HeightHigh < 0  || $HeightLow  <0) && isempty($Sp1)) 
	  	{
			$HeightHigh=UNDEF;
			$HeightLow =UNDEF;
		}

	  	if( ($HeightHigh < 0  || $HeightLow  <0) && !isempty($Sp1)) 
	  	{ 
	  		$keys="negative Height"."#".$Height;
			$herror{$keys}++;
			$HeightHigh = MISSCODE;
			$HeightLow = MISSCODE;
		}

	  	if($SS_species eq "S" || $SS_species eq "SH" || $SS_species eq "HS" || $SS_species eq "H" )
	  	{
			$USpeciesComp = USpecies($SS_species,$spfreq);
			$StandStructureCode = "M";
			$nblayers=2;
			$UCCHigh = CCUpper($SS_CrownCl);
			$UCCLow = CCLower($SS_CrownCl);
	  		if($UCCHigh  eq ERRCODE   || $UCCLow  eq ERRCODE) 
	  		{ 
	  			$keys="understorey Density"."#".$SS_CrownCl;
				$herror{$keys}++;
			}
	  		$UHeightHigh = StandHeight($SS_Height);
	  		$UHeightLow = StandHeight($SS_Height);
	  		if($UHeightHigh >0 ){$UHeightHigh=$UHeightHigh+0.5;}
			if($UHeightLow >0.5){$UHeightLow=$UHeightLow-0.5;}

			if(( $UHeightHigh < 0  || $UHeightLow  <0) && isempty($SS_species)) 
			{  
				$UHeightHigh=UNDEF;
				$UHeightLow =UNDEF;
			}

 			if(( $UHeightHigh < 0  || $UHeightLow  <0) && !isempty($SS_species)) 
 			{ 
 				$keys="understorey negative Height"."#".$SS_Height;
				$herror{$keys}++;
				$UHeightHigh=MISSCODE;
				$UHeightLow =MISSCODE;
			}
	  	}

	  	$SpeciesComp = Species($Sp1,$Sp1P,$Sp2,$Sp2P,$Sp3,$Sp3P,$Sp4,$Sp4P, $spfreq);
		$errspec=0;

	 	@SpecsPerList  = split(",", $SpeciesComp); #$Spp1=$SpecsPerList[0];$Spp2=$SpecsPerList[2];$Spp3=$SpecsPerList[4];$Spp4=$SpecsPerList[6];
 
   		for($cpt_ind=0; $cpt_ind<=3; $cpt_ind++)
		{  
			my $posi=$cpt_ind*2;	
        	if($SpecsPerList[$posi]  eq SPECIES_ERRCODE ) 
			{ 
				$errspec=1;
			}
   		}

		my $total=$SpecsPerList[1] + $SpecsPerList[3]+ $SpecsPerList[5] +$SpecsPerList[7] ;
		if($total!=100 && $total!=0)
		{
			$keys="total perct".$total.",".$Sp1."-".$Sp1P."-".$Sp2."-".$Sp2P."-".$Sp3."-".$Sp3P."-".$Sp4."-".$Sp4P;
			$herror{$keys}++;
		}
	  	$SpeciesComp = $SpeciesComp .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";
	   
		$Origin=UNDEF;

		if($SiteHW ==0)
		{
	  		$SiteClass = Site1($SiteSW);
		}
		else 
		{
 	  		$SiteClass = Site2($SiteHW);
		}
	 	if($SiteClass  eq ERRCODE) 
	 	{ 
			$keys="SiteClass"."#".$SiteSW."######AND ID is ".$SiteHW;
			$herror{$keys}++;
		}

	  	$SiteIndex = UNDEF; #"";

	  	$Wetland = WetlandCodes ($ForNon, $SpeciesCode, $CrownCl, $Height);  #$row->{FOREST_}, 
		# if($Wetland  eq "") { $keys="WETLAND-MoistReg"."#".$MoistReg."#".$NFL."#".$Spp1."#".$Spp2."#".$Sp1Per."#".$Spp3."#".$Spp4."#".$Spp5;
		#  $herror{$keys}++;
		#}
	
  		# ===== Non-forested Land =====
		$covtype=$LndClass;
		$non_for=$ForNon;
		$emit_lyr = 0;

		#$NatNonVeg = MISSCODE; $NonForVeg=MISSCODE;$NonForAnth =MISSCODE;
		if($non_for >=70 || $non_for == 33 || $non_for == 38 || $non_for == 39 || $non_for == 5 )
		{

 			$NatNonVeg = NaturallyNonVeg($ForNon);
		  	$NonForAnth = NonForestedAnth($ForNon);
		 	$NonForVeg = NonForestedVeg($ForNon);
		  	$UnProdFor=UnProdForest($ForNon);
			if($UnProdFor eq ERRCODE){$UnProdFor=UNDEF;}
			if($NatNonVeg  eq MISSCODE && $NonForAnth eq MISSCODE && $NonForVeg eq MISSCODE && $UnProdFor eq UNDEF) 
			{ 
				$keys="check eers NatNV"."#".$ForNon;
				$herror{$keys}++;
			}	
		}
		else
		{
			$NatNonVeg = MISSCODE;
			$NonForAnth = MISSCODE;
			$NonForVeg = MISSCODE;
			$UnProdFor = UNDEF;

			if($non_for == 0  )
			{
				$emit_lyr = 1;
				$SpeciesComp ="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
			}
		}
		 
 	
	  	# ===== Modifiers =====
	  	$Dist1 = Disturbance($ForNon);   # result is DISTCODE1.",".YEAR
	  	($Distcode, $Distcode2, $Distcode3, $Distcode4)=split(",", $Dist1);
        $Dist = $Dist1. ",". UNDEF. "," .UNDEF. "," .UNDEF. "," .UNDEF. "," . UNDEF. "," .UNDEF. "," .UNDEF. "," .UNDEF;

         # $Dist = $Dist1 . "," . $Dist2 . "," . $Dist3;
        my ($ProdFor, $lyr_poly) = productive_code ($Sp1, $CCHigh , $CCLow , $HeightHigh , $HeightLow,  $CrownCl);
		if($lyr_poly)
		{
			$SpeciesComp ="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
			$keys="###check artificial lyr1 on #".$Sp1;
			$herror{$keys}++; 
		}	
		if ($Distcode  eq "CO")
		{
			$ProdFor="PF";
		 	$lyr_poly=1;
		}  

	  	# ===== Output inventory info for layer 1 =====
	 
        $CAS_Record = $CASID . "," . $PolyNum. "," . $StandStructureCode .",". $nblayers .",".  $HeaderID . "," . $MapSheetID . "," . $Area . "," . $Perimeter . ",".$Area.",".$PhotoYear;
	    print CASCAS $CAS_Record . "\n";
	    $nbpr=1;$$ncas++;$ncasprev++;

            #forested
	    if (!isempty($Sp1) ||  $lyr_poly || $emit_lyr) 
	    {
	      	$LYR_Record1 = $CASID . "," . $SMR  . "," .$StandStructureVal . ",1,1";
	      	$LYR_Record2 = $CCHigh . "," . $CCLow . "," . $HeightHigh . "," . $HeightLow . "," .$ProdFor. "," . $SpeciesComp;
	      	$LYR_Record3 = $Origin . "," . $Origin . "," . $SiteClass . "," . $SiteIndex ;
	      	$Lyr_Record = $LYR_Record1 . "," . $LYR_Record2 . "," . $LYR_Record3;
	      	print CASLYR $Lyr_Record . "\n";
			$nbpr++; $$nlyr++;$nlyrprev++;
	    }
            #non-forested
	    elsif (!is_missing($NatNonVeg) || !is_missing($NonForAnth) || !is_missing($NonForVeg)) 
	    {
	    	#if ($NonForVeg ne MISSCODE || $NonForAnth ne MISSCODE || $NonForVeg ne MISSCODE) {
	      	$NFL_Record1 = $CASID . "," . $SMR  . "," . $StandStructureVal .",1,1";
	      	$NFL_Record2 = $CCHigh . "," . $CCLow . "," . $HeightHigh . "," . $HeightLow;
            $NFL_Record3 = $NatNonVeg . "," . $NonForAnth . "," . $NonForVeg;
            $NFL_Record = $NFL_Record1 . "," . $NFL_Record2 . "," . $NFL_Record3;
	      	print CASNFL $NFL_Record . "\n";
			$nbpr++;$$nnfl++;$nnflprev++;
	    }
            #Disturbance
	    if (!isempty($ForNon) && $Distcode ne MISSCODE) 
	    {
	      	$DST_Record = $CASID . "," . $Dist.",1";
	      	print CASDST $DST_Record . "\n";
			if($nbpr==1) {$$ndstonly++; $ndstonlyprev++;}
			$nbpr++;$$ndst++;$ndstprev++;
	    }
	    #Ecological 
	    if ($Wetland ne MISSCODE) 
	    {
	      	$Wetland = $CASID . "," . $Wetland."-";
	      	print CASECO $Wetland . "\n";
			if($nbpr==1) {$$necoonly++;$necoonlyprev++;}
			$nbpr++;$$neco++;$necoprev++;
	    }

 		if (($StandStructureCode eq "M")) 
 		{

	      	$LYR_Record1 = $CASID . "," . $SMR  . "," .  $StandStructureVal . ",2,2";
	      	$LYR_Record2 = $UCCHigh . "," . $UCCLow . "," . $UHeightHigh . "," . $UHeightLow . "," .$ProdFor. "," . $USpeciesComp;
	      	$LYR_Record3 = $Origin . "," . $Origin . "," . $SiteClass . "," . $SiteIndex ;
	      	$Lyr_Record = $LYR_Record1 . "," . $LYR_Record2 . "," . $LYR_Record3;
	      	print CASLYR $Lyr_Record . "\n";
	  	}

		#end while         
		if($nbpr ==1 )
		{
			$ndrops++;
			if(isempty($Sp1)  &&  isempty($ForNon) && $Wetland eq MISSCODE && (isempty($ForNon) || $Distcode ne MISSCODE)) 
			{
				$keys = "MAY  DROP THIS>>>-\n";
 				$herror{$keys}++; 
			}
			else 
			{
				$keys ="!!! record may be dropped#"."specs=".$Sp1."#nfordesc=".$ForNon."#wetland=".$Wetland."#disturb=".$Dist."#height=".$Height."#Crowncl=".$CrownCl;
 				$herror{$keys}++; 
				$keys ="#droppable#";
 				$herror{$keys}++; 
			}
		}
   	}

 	$csv->eof or $csv->error_diag ();
  	close $NSinv;

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
	#close (NSinv);
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
	#if($total > $ncasprev) {print "must check this !!! \n";}
	#print "$$ncas, $$nlyr, $$nnfl,  $$ndst, $total\n";
	#print "nb records in casfile : $ncasprev, lyrfile : $nlyrprev, nflfile : $nnflprev,  dstfile : $ndstprev--- total(without .cas): $total\n";
	print " drops=$ndrops : $ncasprev, lyrfile : $nlyrprev, nflfile : $nnflprev,  dstfile : $ndstprev($ndstonlyprev), ecofile : $necoprev($necoonlyprev)--- total (without .cas): $total($total2)\n";
}
1;
#province eq "YT";

