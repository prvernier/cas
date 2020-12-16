package ModulesV4::NT_conversion08;


use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(&NTinv_to_CAS );
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

	
our $Species_table;

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

#MOISTURE
#VX, X, SX=D	SM, M=F	SG, HG=M	SD, HD=W
#0=VX, 1=X, 2=SX, 3= SM, 4=M, 5=SG, 6=HG, 7=SD, and 8=HD.
#SN is typo error corrected by  SM
sub SoilMoistureRegime
{ 
    my $MoistReg;
    my $TypeClass;
    my $LandPos; 
    my %MoistRegList = ("", 1, "n", 1, "vx", 1, "x", 1, "sx", 1, "sm", 1, "sn", 1,"m", 1, "sg", 1, "hg", 1, "sd", 1, "hd", 1, 
                   "N", 1, "VX", 1, "X", 1, "SX", 1, "SM", 1,"SN", 1, "M", 1, "SG", 1, "HG", 1, "SD", 1, "HD", 1, "N/", 1, 
                   "0", 1, "1", 1, "2", 1, "3", 1, "4", 1, "5", 1, "6", 1, "7", 1, "8", 1); 

    my $SoilMoistureReg;
 
    ($MoistReg) = shift(@_);  
    ($TypeClass) = shift(@_);  
    ($LandPos) = shift(@_);  
 

    if  (isempty($MoistReg))                                      { $SoilMoistureReg = MISSCODE; }
 
    elsif (($MoistReg eq "vx") || ($MoistReg eq "VX") || ($MoistReg eq "0"))         { $SoilMoistureReg = "D"; }
    elsif (($MoistReg eq "x") || ($MoistReg eq "X")|| ($MoistReg eq "1"))         { $SoilMoistureReg = "D"; } 
    elsif (($MoistReg eq "sx") || ($MoistReg eq "SX")|| ($MoistReg eq "2"))         { $SoilMoistureReg = "D"; }
    elsif (($MoistReg eq "sm") || ($MoistReg eq "SM")|| ($MoistReg eq "3"))         { $SoilMoistureReg = "F"; }
    elsif (($MoistReg eq "m") || ($MoistReg eq "M")|| ($MoistReg eq "4"))         { $SoilMoistureReg = "F"; }
    elsif (($MoistReg eq "sg") || ($MoistReg eq "SG")|| ($MoistReg eq "5"))         { $SoilMoistureReg = "M"; }
    elsif (($MoistReg eq "hg") || ($MoistReg eq "HG")|| ($MoistReg eq "6"))         { $SoilMoistureReg = "M"; }
    elsif (($MoistReg eq "sd") || ($MoistReg eq "SD")|| ($MoistReg eq "7"))         { $SoilMoistureReg = "W"; } 
    elsif (($MoistReg eq "hd") || ($MoistReg eq "HD")|| ($MoistReg eq "8"))         { $SoilMoistureReg = "W"; }
    elsif (($MoistReg eq "sn") || ($MoistReg eq "SN"))         { $SoilMoistureReg = "F"; }
    elsif (($MoistReg eq "n") || ($MoistReg eq "N/") )         
    {
       if ($TypeClass eq "LA" ||  $TypeClass eq "RI" ||  $TypeClass eq "PO" || $TypeClass eq "RE" || $TypeClass eq "SW" || $TypeClass eq "GL" || $TypeClass eq "RP" || $TypeClass eq "BP" || $TypeClass eq "AP")  {$SoilMoistureReg = MISSCODE; }
       elsif (($TypeClass eq "TC" ||  $TypeClass eq "TM" ||  $TypeClass eq "TB")  && ($LandPos eq "U")) {$SoilMoistureReg = "M"; }
       elsif (($TypeClass eq "TC" ||  $TypeClass eq "TM" ||  $TypeClass eq "TB")  && ($LandPos eq "W")) {$SoilMoistureReg = "W"; } #SD
       elsif ($TypeClass eq "HE" && $LandPos eq "U" ) {$SoilMoistureReg = "M"; }#SG
       elsif ($TypeClass eq "ST" && $LandPos eq "W" ) {$SoilMoistureReg = "W"; }#SD
       elsif ($TypeClass eq "ST" && $LandPos eq "U" ) {$SoilMoistureReg = "M"; }#HG
       elsif (isempty($TypeClass) && isempty($LandPos) ) {$SoilMoistureReg = "M"; }
	   else {$SoilMoistureReg = "M"; }
    } 
    else { $SoilMoistureReg = ERRCODE; } 
 
    return $SoilMoistureReg; 
}



#StandStructure from  STRUCTURE
sub StandStructure
{
	my $Struc;
	my %StrucList = ("", 1,  "S", 1, "M", 1, "C", 1,  "H", 1, "s", 1, "m", 1, "c", 1, "h", 1);
	my $StandStructure;


	($Struc) = shift(@_);
		
	if (isempty($Struc))                			 		{ $StandStructure = MISSCODE; }
	elsif (($Struc eq "s") || ($Struc eq "S"))               { $StandStructure = "S"; }
	elsif (($Struc eq "m") || ($Struc eq "M"))               { $StandStructure = "M"; }
	elsif (($Struc eq "c") || ($Struc eq "C"))               { $StandStructure = "C"; }
	elsif (($Struc eq "h") || ($Struc eq "H"))               { $StandStructure = "H"; }
	
	else {  $StandStructure = ERRCODE; }

	return $StandStructure;
}


#from $CrownClos  

sub CCUpper
{
	my $CCHigh;
	my $CC; my $PCclass;
	
	($CC) = shift(@_);  
	($PCclass) = shift(@_);  

	if($PCclass eq "10")
	{
		if (isempty($CC)) { $CCHigh = MISSCODE; }
		elsif ($CC == 0)  { $CCHigh = 5; }
		elsif ($CC == 10)  { $CCHigh = 15; }
		elsif ($CC == 20)  { $CCHigh = 25; }
		elsif ($CC == 30)  { $CCHigh = 35; }
      	elsif ($CC == 40)  { $CCHigh = 45; }
		elsif ($CC == 50)  { $CCHigh = 55; }
		elsif ($CC == 60)  { $CCHigh = 65; }
		elsif ($CC == 70)  { $CCHigh = 75; }
      	elsif ($CC == 80)  { $CCHigh = 85; }
		elsif ($CC == 90)  { $CCHigh = 95; }
		elsif ($CC == 100) { $CCHigh = 100}
		else { $CCHigh = ERRCODE; }					
	}
	elsif($PCclass eq "5")
	{
		if (isempty($CC)) { $CCHigh = MISSCODE; }
		elsif ($CC == 0)  { $CCHigh = 5; }
		elsif ($CC == 10)  { $CCHigh = 10; }
		elsif ($CC == 20)  { $CCHigh = 15; }
		elsif ($CC == 30)  { $CCHigh = 20; }
      	elsif ($CC == 40)  { $CCHigh = 25; }
		elsif ($CC == 50)  { $CCHigh = 30; }
		elsif ($CC == 60)  { $CCHigh = 35; }
		elsif ($CC == 70)  { $CCHigh = 40; }
      	elsif ($CC == 80)  { $CCHigh = 45; }
		elsif ($CC == 90)  { $CCHigh = 50; }
		elsif ($CC == 100) { $CCHigh = 55}
		elsif ($CC == 110)  { $CCHigh = 60; }
		elsif ($CC == 120)  { $CCHigh = 65; }
		elsif ($CC == 130)  { $CCHigh = 70; }
      	elsif ($CC == 140)  { $CCHigh = 75; }
		elsif ($CC == 150)  { $CCHigh = 80; }
		elsif ($CC == 160)  { $CCHigh = 85; }
		elsif ($CC == 170)  { $CCHigh = 90; }
      	elsif ($CC == 180)  { $CCHigh = 95; }
		elsif ($CC == 190)  { $CCHigh = 100; }
		else { $CCHigh = ERRCODE; }					
	}
	return $CCHigh;
}

sub CCLower 
{
	my $CCLow;
	my $CC;  my $PCclass;
	
	($CC) = shift(@_);  
	($PCclass) = shift(@_);
		
	 
	if($PCclass eq "10")
	{
		if (isempty($CC)) { $CCLow = MISSCODE; }
		elsif ($CC == 0)  { $CCLow = 0; }
		elsif ($CC == 10)  { $CCLow = 6; }
		elsif ($CC == 20)  { $CCLow = 16; }
		elsif ($CC == 30)  { $CCLow = 26; }
        elsif ($CC == 40)  { $CCLow = 36; }
		elsif ($CC == 50)  { $CCLow = 46; }
		elsif ($CC == 60)  { $CCLow = 56; }
		elsif ($CC == 70)  { $CCLow = 66; }
       	elsif ($CC == 80)  { $CCLow = 76; }
		elsif ($CC == 90)  { $CCLow = 86; }
		elsif ($CC == 100)  { $CCLow = 96; }
		else { $CCLow = ERRCODE; }
	}
	elsif($PCclass eq "5")
	{
		if (isempty($CC)) { $CCLow = MISSCODE; }
		elsif ($CC == 0)  { $CCLow = 0; }
		elsif ($CC == 10)  { $CCLow = 6; }
		elsif ($CC == 20)  { $CCLow = 11; }
		elsif ($CC == 30)  { $CCLow = 16; }
        elsif ($CC == 40)  { $CCLow = 21; }
		elsif ($CC == 50)  { $CCLow = 26; }
		elsif ($CC == 60)  { $CCLow = 31; }
		elsif ($CC == 70)  { $CCLow = 36; }
       	elsif ($CC == 80)  { $CCLow = 41; }
		elsif ($CC == 90)  { $CCLow = 46; }
		elsif ($CC == 100)  { $CCLow = 51; }
		elsif ($CC == 110)  { $CCLow = 56; }
		elsif ($CC == 120)  { $CCLow = 61; }
		elsif ($CC == 130)  { $CCLow = 66; }
        elsif ($CC == 140)  { $CCLow = 71; }
		elsif ($CC == 150)  { $CCLow = 76; }
		elsif ($CC == 160)  { $CCLow = 81; }
		elsif ($CC == 170)  { $CCLow = 86; }
       	elsif ($CC == 180)  { $CCLow = 91; }
		elsif ($CC == 190)  { $CCLow = 96; }
		else { $CCLow = ERRCODE; }
	}
	return $CCLow;
}

#from $HT (FCI)   

sub StandHeightUp 
{
	my $Height;  
	my $HUpp;

	($Height) = shift(@_);
	 
	if  (isempty($Height))                                      {$HUpp = MISSCODE; }
	elsif (($Height < 0)    || ($Height > 80))                  { $HUpp = 0; }
	elsif (($Height >= 0)   && ($Height <= 80))                  { $HUpp = $Height; }
	return $HUpp;
}


sub StandHeightLow 
{
	my $Height;  
	my $HLow;

	($Height) = shift(@_);

	if  (isempty($Height))                                      {$HLow = MISSCODE; }
	elsif (($Height < 0)    || ($Height > 80))                  { $HLow = 0; }
	elsif (($Height >= 0)   && ($Height <= 80))                  { $HLow = $Height; }
	return $HLow;	            		       
}

#Bg, Sh, Cs, al equal ST and Lg = SL

#Dertermine Latine name of species
sub Latine 
{
	my $CurrentSpecies = shift(@_);
	my $GenusSpecies;

	$_ = $CurrentSpecies;
	tr/a-z/A-Z/;
	$CurrentSpecies = $_;
	$CurrentSpecies =~ s/^\s//g;

	if (isempty($CurrentSpecies))   { $GenusSpecies = "XXXX MISS"; }

	elsif ($Species_table->{$CurrentSpecies}) { $GenusSpecies = $Species_table->{$CurrentSpecies}; }
	elsif ($CurrentSpecies eq "SH" || $CurrentSpecies eq "CS" ||$CurrentSpecies eq "LG")  { $GenusSpecies = SPECIES_ERRCODE; }
	else 	 {$GenusSpecies = SPECIES_ERRCODE;  print SPECSLOGFILE "Illegal species code $CurrentSpecies,CAS_ID=$Glob_CASID,file=$Glob_filename\n";  } 
	return $GenusSpecies;
}


#Determine Species from the 4 Species fields
 
sub Species
{
	my $Sp1c    = shift(@_);
	my $Sp1Per=shift(@_);
	my $Sp2c    = shift(@_);
	my $Sp2Per=shift(@_);
	my $Sp3c    = shift(@_);
	my $Sp3Per=shift(@_);
	my $Sp4c    = shift(@_);
	my $Sp4Per = shift(@_);
	my $spfreq = shift(@_);
	my $savsp4 = $Sp4Per;
	my $savsp3 = $Sp3Per;
	my $total;
	my $Species;
	my $Sp1; my $Sp2; my $Sp3; my $Sp4;

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
		 
	$spfreq->{$Sp1c}++;
	$spfreq->{$Sp2c}++;
	$spfreq->{$Sp3c}++;
	$spfreq->{$Sp4c}++;
	 

	$Sp1 = Latine($Sp1c); #if($Sp1 eq MISSCODE) {$Sp1Per=0;} else {$Sp1Per=10*$Sp1Per;}
	$Sp1Per=10*$Sp1Per;
	$Sp2 = Latine($Sp2c); #if($Sp2 eq MISSCODE) {$Sp2Per=0;} else {$Sp2Per=10*$Sp2Per;}
	$Sp2Per=10*$Sp2Per;
	$Sp3 = Latine($Sp3c); #if($Sp3 eq MISSCODE) {$Sp3Per=0;} else {$Sp3Per=10*$Sp3Per; if ($Sp3Per==0){$Sp3Per=10;}} #
	$Sp3Per=10*$Sp3Per;
	$Sp4 = Latine($Sp4c); 
	$Sp4Per=10*$Sp4Per;

	if($Sp4 eq "XXXX MISS" && $Sp4Per!=0) {$Sp1Per=$Sp1Per + $Sp4Per; $Sp4Per=0;} #else {$Sp4Per=10*$Sp4Per; if ($Sp4Per==0){$Sp4Per=10;} }
	
	if($Sp1 eq "XXXX MISS") {$Sp1Per=0;$Sp2Per=0;$Sp3Per=0;$Sp4Per=0;$Sp2="XXXX MISS";$Sp3="XXXX MISS";$Sp4="XXXX MISS"; }

	$total=$Sp1Per+$Sp2Per+$Sp3Per+$Sp4Per;
	if($Sp1 ne "XXXX MISS" && $total==0) {$Sp1Per=100; $total =100;}  

	if($total ==110 && $Sp1Per==70 && $Sp2Per==20 && $Sp3Per==20){
		$Sp3Per=10;
	}
	elsif($total ==110 && $Sp1Per==70 && $Sp2Per==40){
		$Sp2Per=30;
	}
	elsif($total ==110 && $Sp1Per==70 && $Sp2Per==30 && $Sp3Per==10){
		$Sp1Per=60;
	}
	elsif($total ==110 && $Sp1Per==80 && $Sp2Per==10 && $Sp3Per==10  && $Sp4Per==10){
		$Sp1Per=70;
	}
	elsif($total ==110 && $Sp1Per==60 && $Sp2Per==30 && $Sp3Per==10  && $Sp4Per==10){
		$Sp1Per=50;
	}
	elsif($total ==110 && $Sp1Per==40 && $Sp2Per==30 && $Sp3Per==30  && $Sp4Per==10){
		$Sp3Per=20;
	}
	elsif($total ==110 && $Sp1Per==100 && $Sp2Per==10){
		$Sp1Per=90;
	}

	elsif($total ==130 && $Sp1Per==100 ){
		$Sp1Per=70;
	}
	elsif($total ==160 && $Sp1Per==80 && $Sp2Per==80 ){
		$Sp2Per=20;
	}
	elsif($total ==140 && $Sp1Per==70 && $Sp2Per==70 ){
		$Sp2Per=30;
	}
	elsif($total ==150 && $Sp1Per==50 && $Sp2Per==50 && $Sp3Per==30  && $Sp4Per==20){
		$Sp2Per=30;
		$Sp3Per=20;
		$Sp4Per=0;
	}
	elsif($total ==180 && $Sp1Per==90 && $Sp2Per==90 ){
		$Sp2Per=10;
	}
	elsif($total ==120 ){
		$Sp1Per=$Sp1Per-20;
	}
 	elsif($total ==40 && $Sp1Per==0 && $Sp2Per==40 ){
		$Sp1Per=60;
	}
	elsif($total ==90 && $Sp2 ne "XXXX MISS" ){
		$Sp2Per= $Sp2Per+10;
	}
	elsif(($total ==80) && $Sp1Per==60 && $Sp2Per==10 && $Sp3Per==10) {
		$Sp1Per= 70; 
		$Sp2Per= 20; 
	}
	elsif(($total ==80) && $Sp1Per==30 && $Sp2Per==40 && $Sp3Per==10) {
		$Sp1Per= 50; 
	}
	elsif(($total ==80) && $Sp1Per==60 && $Sp2Per==20) {
		$Sp1Per= 70; 
		$Sp2Per= 30; 
	}
	elsif(($total <100) && $Sp2Per==0 && $Sp3Per==0 && $Sp4Per==0  && !isempty($Sp2c)  ) 
	{ 
		$Sp2Per= 100 - $Sp1Per; 
	}

	elsif(($total <100) && $Sp2Per!=0 && $Sp3Per==0 && $Sp4Per==0  && !isempty($Sp2c)  ) 
	{ 
		$Sp1Per= 100 - $Sp2Per; 
	}



	$Species = $Sp1 . "," . $Sp1Per . "," . $Sp2 . "," . $Sp2Per . "," . $Sp3 . "," . $Sp3Per. "," . $Sp4 . "," . $Sp4Per;

	return $Species;
}


#Determine upper stand origin from ORIGIN MINORORIGIN

sub UpperOrigin 
{
	my $Origin;
	my $OriginHigh;

	($Origin) = shift(@_);
	
	if  (isempty($Origin))    { $OriginHigh  = MISSCODE; }
	elsif ($Origin % 10 == 0 && $Origin != 0)  { $OriginHigh = $Origin + 5; }
	else { $OriginHigh= $Origin; }
	return $OriginHigh;
}

#Determine lower stand origin from Origin
sub LowerOrigin 
{
	my $Origin;
	my $OriginLow;
	
	($Origin) = shift(@_);
	
	if  (isempty($Origin))      { $OriginLow  = MISSCODE; }
	elsif($Origin % 10 == 0 && $Origin != 0)  { $OriginLow = $Origin - 5; }
	else { $OriginLow= $Origin; }
	return $OriginLow;
}


sub Site 
{
	my $SiteC;
	my $TPR; 
	my %TPRList = ("", 1, "5", 1, "4", 1, "3", 1, "2", 1, "1", 1); #w,b=r,d

	($TPR) = shift(@_);
	

	if  (isempty($TPR))                     { $SiteC = MISSCODE; }
	elsif (($TPR eq "1") || ($TPR eq "2"))  { $SiteC = "G"; }
	elsif (($TPR eq "3"))                   { $SiteC = "M"; }
	elsif (($TPR eq "4"))                   { $SiteC = "P"; }
	elsif (($TPR eq "5"))                   { $SiteC = "U"; }
	else { $SiteC = ERRCODE; }

	return $SiteC;
}

sub SiteIndex 
{

	my $Index; 
	my $SiteIndex;

	($Index) = shift(@_);

	if  (isempty($Index))                     { $SiteIndex = MISSCODE; }
	elsif  ($Index >=1 && $Index<=99)          { $SiteIndex = $Index; }
	else   { $SiteIndex = ERRCODE; }
	return $SiteIndex;
}


#Natnonveg ==== AP, LA, RI, OC, RK, SA, SI, SL, EX, BE, WS, FL, IS, TF
sub NaturallyNonVeg
{
	my $NatNonVeg;
	my %NatNonVegList = ("", 1, "LA", 1, "GL", 1, "ES", 1, "PO", 1, "SC", 1, "RE", 1, "SI", 1, "LL", 1, "RI", 1, "BR", 1,
	"MU", 1, "SW", 1, "LB", 1, "RO", 1, "RT", 1, "LS", 1, "RM", 1, "BE", 1, "AS", 1, "BP", 1, "BU", 1, "CB", 1, "MO", 1, "RS", 1);

	($NatNonVeg) = shift(@_);
	
	if  (isempty($NatNonVeg))		{ $NatNonVeg = MISSCODE; }
	elsif (($NatNonVeg eq "LA"))	{ $NatNonVeg = "LA"; }
	elsif (($NatNonVeg eq "GL"))	{ $NatNonVeg = "SI"; }
	elsif (($NatNonVeg eq "ES"))	{ $NatNonVeg = "EX"; } 
	elsif (($NatNonVeg eq "PO"))	{ $NatNonVeg = "LA"; } 
	elsif (($NatNonVeg eq "SC"))	{ $NatNonVeg = "SI"; } 
	elsif (($NatNonVeg eq "RE"))	{ $NatNonVeg = "LA"; }
	elsif (($NatNonVeg eq "SI"))	{ $NatNonVeg = "SI"; }
	elsif (($NatNonVeg eq "LL"))	{ $NatNonVeg = "EX"; } 
	elsif (($NatNonVeg eq "RI"))	{ $NatNonVeg = "RI"; }
	elsif (($NatNonVeg eq "BR"))	{ $NatNonVeg = "RK"; }

	elsif (($NatNonVeg eq "MO"))	{ $NatNonVeg = "EX"; }
	elsif (($NatNonVeg eq "MU"))	{ $NatNonVeg = "EX"; }
	elsif (($NatNonVeg eq "SW"))	{ $NatNonVeg = "OC"; }
	elsif (($NatNonVeg eq "LB"))	{ $NatNonVeg = "RK"; } 
	elsif (($NatNonVeg eq "RO"))	{ $NatNonVeg = "RK"; } 
	elsif (($NatNonVeg eq "RT"))	{ $NatNonVeg = "RK"; } 
	elsif (($NatNonVeg eq "LS"))	{ $NatNonVeg = "WS"; }
	elsif (($NatNonVeg eq "RM"))	{ $NatNonVeg = "EX"; }
	elsif (($NatNonVeg eq "BE"))	{ $NatNonVeg = "BE"; } 
	elsif (($NatNonVeg eq "AS"))	{ $NatNonVeg = "WS"; }
	elsif (($NatNonVeg eq "RS"))	{ $NatNonVeg = "WS"; }
	elsif (($NatNonVeg eq "BP"))	{ $NatNonVeg = "SE"; }
	elsif (($NatNonVeg eq "BU"))	{ $NatNonVeg = "EX"; }
	elsif (($NatNonVeg eq "CB"))	{ $NatNonVeg = "EX"; }
	else { $NatNonVeg = ERRCODE; }
	return $NatNonVeg;
}

#Anthropogenic IN, FA, CL, SE, LG, BP, OT
sub Anthropogenic 
{
	my $NonForAnth = shift(@_);
	my %NonForAnthList = ("", 1, "GP", 1, "PM", 1, "TS", 1, "MS", 1, "RR", 1,  "RD", 1, "AP", 1, "EL", 1 );

	if  (isempty($NonForAnth))		{ $NonForAnth = MISSCODE; }
	elsif (($NonForAnth eq "GP")||($NonForAnth eq "PM")||($NonForAnth eq "TS") ||($NonForAnth eq "MS"))	{ $NonForAnth = "IN"; }
	elsif (($NonForAnth eq "RR")||($NonForAnth eq "RD")||($NonForAnth eq "AP"))	{ $NonForAnth = "FA"; }
	elsif (($NonForAnth eq "EL"))		{ $NonForAnth = "OT"; }
	else { $NonForAnth = ERRCODE; }
	return $NonForAnth;
}

#NonForestedVeg ---ST, SL, HF, HE, HG, BR, OM, TN ---  Bg, Sh, Cs, al equal ST and Lg = SL
sub NonForestedVeg 
{
    my $NonForVeg = shift(@_);
	my %NonForVegList = ("", 1, "ST", 1, "SL", 1, "HF", 1, "HG", 1, "HE", 1, "BM", 1, "BL", 1, "BY", 1 );

	my $Mod = shift(@_);

	if  (isempty($NonForVeg))		{ $NonForVeg = MISSCODE; }
	elsif (($NonForVeg eq "BM") || ($NonForVeg eq "BL") || ($NonForVeg eq "BY") )	{ $NonForVeg = "BR"; }
	elsif (($NonForVeg eq "ST"))	{ $NonForVeg = "ST"; }
	elsif (($NonForVeg eq "SL"))	{ $NonForVeg = "SL"; }
	elsif (($NonForVeg eq "HG"))	{ $NonForVeg = "HG"; }
	elsif (($NonForVeg eq "HF"))	{ $NonForVeg = "HF"; }
	elsif (($NonForVeg eq "HE"))	{ $NonForVeg = "HE"; }
	else { $NonForVeg = ERRCODE; }
	return $NonForVeg;
}




#DIS1CODE  DIS2CODE  DIS3CODE	DIS1YEAR  DIS2YEAR  DIS3YEAR	DIS1EXT  DIS2EXT  DIS3EXT	1,2,3,4,5	1-25	26-50	51-75	75-95	96-100	AV BT	BU CC	CR DT	DI FL	IK SC	UK WE	WI
#AV=SL	BT=OT	BU=BU	CC=CO	CR=OT	DT=OT	DI=DI	IK=IK	FL=FL	UK=OT	WE=WE	WI=WF

sub Disturbance 
{
	my $ModCode;
	my $Mod;
	my $ModYr;
	my $Disturbance;
	
	my %ModList = ("AV", 1, "BT", 1, "BU", 1, "CC", 1, "CR", 1, "DT", 1,"TH", 1, "SN", 1, "SL", 1, "VT", 1,
			      "DI", 1, "IK", 1, "FL", 1, "UK", 1, "WE", 1, "WI", 1);
   
	($ModCode) = shift(@_);
	($ModYr) = shift(@_);
	

	if (isempty($ModYr)) {$ModYr=0; }
	if (isempty($ModCode)) {$ModCode=""; $ModYr= "-1111", }

	if ($ModList{$ModCode}) { 

		if (!isempty($ModCode)) { 
 				if (($ModCode  eq "AV")) { $Mod="SL"; }
				elsif (($ModCode  eq "BT") || ($ModCode eq "CR") || ($ModCode eq "DT") || ($ModCode eq "UK")) { $Mod="OT"; }
				elsif (($ModCode  eq "BU")) { $Mod="BU"; }
				elsif (($ModCode  eq "CC")) { $Mod="CO"; }	
				elsif (($ModCode  eq "DI")) { $Mod="DI"; }	
				elsif (($ModCode  eq "IK")) { $Mod="IK"; }	
				elsif (($ModCode  eq "FL")) { $Mod="FL"; }	
				elsif (($ModCode  eq "WE")) { $Mod="WE"; }	
				elsif (($ModCode  eq "WI")) { $Mod="WF"; }

				elsif (($ModCode  eq "TH")) { $Mod="SI"; }
				elsif (($ModCode  eq "SN")) { $Mod="DT"; }		
				elsif (($ModCode  eq "SL")) { $Mod="SL"; }	
				elsif (($ModCode  eq "VT")) { $Mod=MISSCODE; }		#Note from SC on 16-05-2012  : need to fix this code in further version
				elsif (($ModCode  eq "UN")) { $Mod=MISSCODE; } #undisturbeb
				$Disturbance = $Mod . "," . $ModYr; 
	                  }
	  	 else { 
			$Disturbance = MISSCODE.",-1111"; 
		 }
	} 
	else 
	{
		if (isempty($ModCode)) {$Mod = MISSCODE; }
		else  {$Mod = ERRCODE;}
		$Disturbance = $Mod . "," . $ModYr; 
	}

	return $Disturbance;
}

#DIS1EXT  DIS2EXT  DIS3EXT	1,2,3,4,5	1-25	26-50	51-75	75-95	96-100
sub DisturbanceExtUpper 
{
    my $ModExt;
    my $DistExtUpper;
	my %DistExtList = ("", 1, "1", 1, "2", 1, "3", 1, "4",1, "5", 1);


    ($ModExt) = shift(@_);

	if (isempty($ModExt)) { $DistExtUpper = MISSCODE; }
	elsif ($ModExt == 1 ) { $DistExtUpper = 25; }
	elsif ($ModExt == 2)  { $DistExtUpper = 50; }
	elsif ($ModExt == 3)  { $DistExtUpper = 75; }
	elsif ($ModExt == 4)  { $DistExtUpper = 95; }
	elsif ($ModExt == 5)  { $DistExtUpper = 100; }
	else {$DistExtUpper = ERRCODE; }
    return $DistExtUpper;
}

sub DisturbanceExtLower 
{
    my $ModExt;
    my $DistExtLower;

	my %DistExtList = ("", 1, "1", 1, "2", 1, "3", 1, "4",1, "5", 1);
    ($ModExt) = shift(@_);

	
	if (isempty($ModExt)) { $DistExtLower = MISSCODE; }
	elsif ($ModExt == 1)  { $DistExtLower = 1; }
	elsif ($ModExt == 2)  { $DistExtLower = 26; }
	elsif ($ModExt == 3)  { $DistExtLower = 51; }
	elsif ($ModExt == 4)  { $DistExtLower = 76; }
	elsif ($ModExt == 5)  { $DistExtLower = 96; }
	else  {$DistExtLower = ERRCODE; }
      
    return $DistExtLower;
}
 

#WE = Stnn  SO = Oonn  MA = Mong  SW = Stnn (Sons)  FE = Ftnn, Fong, Fons  BO = Btnn			

# Determine wetland codes
sub WetlandCodes 
{
	my $LandPos= shift(@_);
	my $Struct =  shift(@_); 
	my $Moist =  shift(@_);
	my $TypeClass =  shift(@_);
	my $MINTypeClass =  shift(@_);
	my $Species1=shift(@_);
	my $Species2=shift(@_);
	my $SP1Per=shift(@_);
	my $CC=shift(@_);
	my $Height=shift(@_);
	my $WetClass=shift(@_);

	my $WetlandCode = "";
	
	 
	$_ =$LandPos;tr/a-z/A-Z/; $LandPos = $_;
	$_ = $Struct; tr/a-z/A-Z/; $Struct = $_;
	$_ = $Moist; tr/a-z/A-Z/; $Moist = $_;

	$_ = $TypeClass; tr/a-z/A-Z/; $TypeClass = $_;
	$_ = $MINTypeClass; tr/a-z/A-Z/; $MINTypeClass = $_;
	$_ = $Species1; tr/a-z/A-Z/; $Species1 = $_;
	$_ = $Species2; tr/a-z/A-Z/; $Species2 = $_;
	$_ =$WetClass;tr/a-z/A-Z/; $WetClass = $_;


	if($LandPos eq  "W" )  
	{ 
		$WetlandCode = "W"; 
	}
	#NON-FORESTED POLYGONS
	elsif( ($Struct eq "S") && ($Moist eq "SD" || $Moist eq "HD" || $Moist eq "7" || $Moist eq "8"))
	{
		if($TypeClass eq "ST" || $TypeClass eq "SL" ) { $WetlandCode = "S,O,N,S,"; }
		elsif($TypeClass eq "HG" || $TypeClass eq "HF" || $TypeClass eq "HE" ) { $WetlandCode = "M,O,N,G,"; }
		elsif($TypeClass eq "BM") { $WetlandCode = "F,O,N,G,"; }
		elsif($TypeClass eq "BL" || $TypeClass eq "BY" ) { $WetlandCode = "B,O,X,C,"; }
	}
	elsif( ($Struct eq "H") && ($Moist eq "SD" || $Moist eq "7"))
	{
		if($TypeClass eq "SL" || $TypeClass eq "HG" ) { $WetlandCode = "B,O,X,C,"; }
		if($MINTypeClass eq "HG" || $MINTypeClass eq "SL" ) { $WetlandCode = "B,O,X,C,"; }
	}
	elsif( ($Struct eq "H") && ($Moist eq "HD" || $Moist eq "8"))
	{
		if($TypeClass eq "HG" || $MINTypeClass eq "HG" ) { $WetlandCode = "M,O,N,G,"; }
	}
	elsif( ($Struct eq "M") && ($Moist eq "SD" || $Moist eq "HD" || $Moist eq "7" || $Moist eq "8"))
	{
		if($TypeClass eq "ST" || $TypeClass eq "SL" ) { $WetlandCode = "F,O,N,S,"; }
	}

	#FORESTED POLYGONS
	elsif(   ($Struct eq "M" || $Struct eq "C" || $Struct eq "H") && ($MINTypeClass eq "SL") && ($Moist eq "SD" || $Moist eq "7") && 
	(   ( ($Species1 eq "SB" || $Species1 eq "PJ") &&  $SP1Per == 100)  || ( ($Species1 eq "SB" || $Species1 eq "PJ") &&  ($Species2 eq "SB" || $Species2 eq "PJ"))) && ($CC < 50) && ($Height < 8)    )
	{
		$WetlandCode = "B,T,X,C,";  
	}

	elsif(   ($Struct eq "S") && ($Moist eq "SD" || $Moist eq "HD" || $Moist eq "7" || $Moist eq "8") && 
	(($Species1 eq "SB" || $Species1 eq "LT") &&  $SP1Per == 100) && ($CC > 50 && $CC < 70)  )
	{
		$WetlandCode = "S,T,N,N,";  
	}
	elsif(   ($Moist eq "SD" || $Moist eq "HD" || $Moist eq "7" || $Moist eq "8") && 
	(($Species1 eq "SB" || $Species1 eq "LT")) && ($CC > 70)  )
	{
		$WetlandCode = "S,F,N,N,";  
	}
	elsif(   ($Moist eq "SD" || $Moist eq "HD" || $Moist eq "7" || $Moist eq "8") && 
	(($Species1 eq "SB" || $Species1 eq "LT") && ($Species2 eq "SB" || $Species2 eq "LT"))  )
	{
		if ($Height < 12) {$WetlandCode = "F,T,N,N,";  }
		elsif ($Height >= 12) {$WetlandCode = "S,T,N,N,";  }
	}

	elsif( ($Moist eq "HD" || $Moist eq "8") && 
	(($Species1 eq "SB" || $Species1 eq "LT") &&  $SP1Per == 100) && ($CC < 50 )  )
	{
		$WetlandCode = "F,T,N,N,";  
	}

	elsif(   ($Moist eq "SD" || $Moist eq "HD" || $Moist eq "7" || $Moist eq "8") && 
	(($Species1 eq "SB" || $Species1 eq "LT" || $Species1 eq "BW" || $Species1 eq "SW") && 
	($Species2 eq "SB" || $Species2 eq "LT" || $Species2 eq "BW" || $Species2 eq "SW"))  &&  ($CC > 50 ))
	{
		$WetlandCode = "F,T,N,N,";  
	}
	elsif(   ($Moist eq "SD" || $Moist eq "HD" || $Moist eq "7" || $Moist eq "8") && 
		 ($Species1 eq "BW" || $Species1 eq "PO") )
	{
		$WetlandCode = "S,T,N,N,";  
	}

	#WETLANDCLASS is optionally defined
	elsif($WetClass eq  "WE" )  
	{ $WetlandCode = "W"; }
	elsif($WetClass eq "SO" )  
	{ $WetlandCode = "O,O,N,N,"; }
	elsif($WetClass eq "MA")  
	{ $WetlandCode = "M,O,N,G,"; }

	elsif($WetClass eq "SW" && !isempty($Species1))  
	{ $WetlandCode = "S,T,N,N,"; }
    elsif($WetClass eq "SW" && ($TypeClass eq "SL" || $TypeClass eq "ST") )  
	{ $WetlandCode = "S,O,N,S,"; }

	elsif($WetClass eq "FE" && !isempty($Species1))  
	{ $WetlandCode = "F,T,N,N,"; }
 	elsif($WetClass eq "FE" && $TypeClass eq "HG")  
	{ $WetlandCode = "F,O,N,G,"; }
	elsif($WetClass eq "FE" && ($TypeClass eq "SL" || $TypeClass eq "ST") )  
	{ $WetlandCode = "F,O,N,S,"; }

	elsif($WetClass eq "BO" && !isempty($Species1))  
	{ $WetlandCode = "B,T,X,C,"; }
	elsif($WetClass eq "BO" && ($TypeClass eq "BY" || $TypeClass eq "BL" || $TypeClass eq "BM"))  
	{ $WetlandCode = "B,O,X,C,"; }

	if (isempty($WetlandCode)) {$WetlandCode = MISSCODE;}# MISSCODE.",".MISSCODE.",".MISSCODE.",".MISSCODE.",";
	return $WetlandCode;
		
}



######################################################################################

###    Here is the main program   ####

######################################################################################


sub NTinv_to_CAS 
{
	my $NT_File = shift(@_);
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
	# When you are using different files to extract photoyear, you need to declare photfile 
	my $photofile=$NT_File;
	$photofile =~ s/\.csv$/_photoyear\.csv/g;
	#print "$NT_File";
	my $MSP1; my $MSP2;
	my $MSP3; my $MSP4;
	
	#####
	# Declare hashtable for a photoyear
	my %NTtable=();

	# Here is the loop to interprete photoyear files when photoyear come from an other source
		
	open (NTsheets, "$photofile") || die "\n Error: Could not open file of NT sheets $photofile !\n";
	my $csv1 = Text::CSV_XS->new(
	{  binary              => 1,
		sep_char    => ";" 
	});
	my $nothing = <NTsheets>;  #drop header line
	my $nbr=0;
	while(<NTsheets>) 
	{ 
		if ($csv1->parse($_)) 
		{
			my @NTS_Record =();
		    @NTS_Record = $csv1->fields();  
			my $NTkeys=$NTS_Record[0];
			# $NTS_Record[1] equal photoyear in the _photo.csv table
			$NTtable{$NTkeys}=$NTS_Record[1];
			$nbr++;	
			#print(" \nFILE no = >$NTkeys> , age = $NTS_Record[1]\n");
		} 
		else
		{
		    my $err = $csv1->error_input;
		    print "Failed to parse line: $err"; exit(1);
		}	
	}
	close(NTsheets);
	#print " $nbr lines in $photofile\n";
	my $CAS_File_HDR = $CAS_File . ".hdr";
	my $CAS_File_CAS = $CAS_File . ".cas";
	my $CAS_File_LYR = $CAS_File . ".lyr";
	my $CAS_File_NFL = $CAS_File . ".nfl";
	my $CAS_File_DST = $CAS_File . ".dst";
	my $CAS_File_ECO = $CAS_File . ".eco";
	#open (NTinv, "<$NT_File") || die "\n Error: Could not open input file $NT_File!\n";
	open (ERRS, ">>$ERRFILE") || die "\n Error: Could not open $ERRFILE file!\n";
	open (SPERRSFILE, ">>$SPERRS") || die "\n Error: Could not open $SPERRS file!\n";	
	open (SPECSLOGFILE, ">>$SPECSLOG") || die "\n Error: Could not open $SPECSLOG file!\n";

	if($optgroups==1)
	{

	 	$CAS_File_HDR = $pathname."/NTtable.hdr";
	 	$CAS_File_CAS = $pathname."/NTtable.cas";
	 	$CAS_File_LYR = $pathname."/NTtable.lyr";
	 	$CAS_File_NFL = $pathname."/NTtable.nfl";
	 	$CAS_File_DST = $pathname."/NTtable.dst";
	 	$CAS_File_ECO = $pathname."/NTtable.eco";
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
		print CASLYR "CAS_ID,SOIL_MOIST_REG,STRUCTURE_PER,LAYER,LAYER_RANK,CROWN_CLOSURE_UPPER,CROWN_CLOSURE_LOWER,HEIGHT_UPPER,HEIGHT_LOWER,PRODUCTIVE_FOR,". 		"SPECIES_1,SPECIES_PER_1,SPECIES_2,SPECIES_PER_2,SPECIES_3,SPECIES_PER_3,SPECIES_4,SPECIES_PER_4,SPECIES_5,SPECIES_PER_5,SPECIES_6,SPECIES_PER_6,SPECIES_7,SPECIES_PER_7,".
		"SPECIES_8,SPECIES_PER_8,SPECIES_9,SPECIES_PER_9,SPECIES_10,SPECIES_PER_10,ORIGIN_UPPER,ORIGIN_LOWER,SITE_CLASS,SITE_INDEX\n";
		print CASNFL "CAS_ID,SOIL_MOIST_REG,STRUCTURE_PER,LAYER,LAYER_RANK,CROWN_CLOSURE_UPPER,CROWN_CLOSURE_LOWER,HEIGHT_UPPER,HEIGHT_LOWER,NAT_NON_VEG,NON_FOR_ANTH,NON_FOR_VEG\n";
		print CASDST "CAS_ID,DIST_1,DIST_YR_1,DIST_EXT_UPPER_1,DIST_EXT_LOWER_1,DIST_2,DIST_YR_2,DIST_EXT_UPPER_2,DIST_EXT_LOWER_2,DIST_3,DIST_YR_3,DIST_EXT_UPPER_3,DIST_EXT_LOWER_3,LAYER\n";
		print CASECO "CAS_ID,WETLAND_TYPE,WET_VEG_COVER,WET_LANDFORM_MOD,WET_LOCAL_MOD,ECO_SITE\n";
		print CASHDR "IDENTIFICATION_ID,JURISDICTION,COORDINATE_SYS,PROJECTION,DATUM,INVENTORY_OWNER,LAND_OWNER,PERMISSION,TENURE_TYPE,INV_TYPE,INV_VERSION,INV_START_YR,INV_FINISH_YR,INV_ACQ_ID,".
		"INV_ACQ_YR,INV_UPDATE_YR,COMMENT\n";

		# ===== Output to header file =====
		my $HDR_Record =  "1,NT,,,NAD83,TERRITORY,,RESTRICTED,,NWTFVI,3.0,,,,,";
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

	my $Record; my @Fields;	my $PolyNum; my $CAS_ID; my $MapSheetID;my $IdentifyID;	my $StandID;my $Area;my $Perimeter;my $MoistReg;my $Height;my $Sp1;my $Sp2;
	my $Sp3;my $Sp4;my $Sp1Per;my $Sp2Per;my $Sp3Per;my $Sp4Per;my $CrownClosure;my $Origin;my $Dist;my $Dist1;my $Dist2;my $Dist3;my $WetEco;my $Ecosite;
	my $SMR;my $StandStructureCode;my $CCHigh;my $CCLow;my $SpeciesComp;my $SpComp;	my $SiteClass;my $SiteIndex;my $Wetland; my $WetlandClass;my $NatNonVeg; 
	my $NonForAnth;	my $UnProdForLand;my %herror=();my $keys;my $PHOTO_YEAR;my $Landpos;my $Ldbase;	my $StrucPer;my $Ldcov;	my $HeightHigh ;
        my  $HeightLow;my  $OriginHigh;my $OriginLow; my @ListSp;my $Mod;my $ModYr;my $NonProd;	my $CAS_Record; my $Lyr_Record; my $LYR_Record1; my $LYR_Record2; 
	my $LYR_Record3;my $NFL_Record; my $NFL_Record1; my $NFL_Record2; my $NFL_Record3; my $DST_Record;my  @SpecsPerList;my $pr1;my $pr2; my $SiteCode; 
	my $NonVegAnth; my $NonForVeg; my $UnProdFor; my  $Struc; my $LRK; my $CrownCl;my $Origin_aux;	my $prr1; my $prr2; my $prr3; my $prr4; my $prr5;
	my $typeclass2; my $SMR2;my $Extent;my $MSiteClass2; my $MSiteIndex2; my $CrownCl2; my $CCHigh2;my $CCLow2; my  @USpecsPerList; my $USpeciesComp; 
	my $USp1Per;my  $UOriginHigh;my $UOriginLow;  my $UOrigin_aux; my $UOrigin;my $UHeightHigh;my  $UHeightLow;  my $UNatNonVeg; my $UNonVegAnth; 
	my $UNonForVeg; my $UNonForAnth;  my $Ext1; my $Ext2;my $Cd1; my $Cd2; my $create_sp_nfl; my $nblayers; my $aux; my $Struct_perc2; my $Struct_perc;
	 
	##############################################################################
	##################################################

	my $csv = Text::CSV_XS->new(
	{
		binary          => 1,
		sep_char    => ";" 
	});
    open my $NTinv, "<", $NT_File or die " \n Error: Could not open QC input file $NT_File: $!";

 	my @tfilename= split ("/", $NT_File);
	my $nps=scalar(@tfilename);
	$Glob_filename= $tfilename[$nps-1];
	
	$csv->column_names ($csv->getline ($NTinv)); 	

   	while (my $row = $csv->getline_hr ($NTinv)) 
   	{	
   		#print "CAS_ID is $row->{CAS_ID}  and AREA is $row->{AREA} \n"; #exit(0);

		#CAS_ID,HEADER_ID,POLY_NUM,Ref_Year,AREAHA,INVPROJ_ID,AREA,PERIMETER,LANDBASE,LANDCOV,LANDPOS,TYPECLAS,DENSITYCLS,STRUCTUR,STRC_PER,MESOPOS,MOISTURE,SP1,SP1_PER,
		#SP2,SP2PER,SP3,SP3PER,SP4,SP4PER,HEIGHT,CROWNCLOS,ORIGIN,SITECLASS,WETLAND

		#CAS_ID,HEADER_ID,SHAPE_AREA,SHAPE_PERI,FC_ID,AREAHA,INVPROJ_ID,SHAPE_len,FC_ID_1,INVPROJ__1,LANDBASE,LANDCOV,LANDPOS,TYPECLAS,DENSITYCLS,STRUCTUR,STRC_PER,MESOPOS,
		#MOISTURE,SP1,SP1_PER,SP2,SP2PER,SP3,SP3PER,SP4,SP4PER,HEIGHT,CROWNCLOS,ORIGIN,SITECLASS,WETLAND,DATA_REF,OBJECTID,SEAM_ID,OBJECTID_1,SEAM_ID_1,REF_YEAR,LANDUSE,
		#DIS1CODE,DIS1EXT,DIS1YEAR,MINTYPECLA,MINMOIST,MINSP1,MINSP1PER,MINSP2,MINSP2PER,MINSP3,MINSP3PER,MINSP4,MINSP4PER,MINHEIGHT,MINCROWNCL,MINORIGIN,MINSITECLA,MATURITY,
		#SI_50,STRATUM,GR_VOL_HA,MR_VOL_HA,STEMS_HA,AVE_DBH,STAND_ORIG,MAP_20K,STAND_20K,MAP_STAND,GR_TOTVL,MR_TOTVL,TOT_STEM,GlobalID_1

		$Glob_CASID   =  $row->{CAS_ID};
		($prr1,$prr2,$prr3, $prr4, $prr5)     =  split("-", $row->{CAS_ID} ); 
		$CAS_ID = $row->{CAS_ID};
		$StandID = $prr4;
		$StandID =~ s/^0+//;
		$IdentifyID = $row->{HEADER_ID};  
		$Area    =  $row->{GIS_AREA};
		$Perimeter =  $row->{GIS_PERI};	
		$PHOTO_YEAR   =  $NTtable{$CAS_ID};
		$MapSheetID = MISSCODE;
		$nblayers = 1;
		my $create_lyr = 0;

		if (!defined $row->{MINTYPECLA})
		{
			$row->{MINTYPECLA} = "";
		}
		if (!defined $row->{TYPELAND})
		{
			$row->{TYPELAND} = "";
		}

		$SMR2 = MISSCODE;
		$typeclass2 = MISSCODE;
		$StandStructureCode = StandStructure($row->{STRUCTUR});
		if($StandStructureCode eq ERRCODE) 
		{
			if(!isempty($row->{SP1})) 
			{
  				if(!isempty($row->{MINSP1})) 
  				{ 
     				$StandStructureCode = "M";
					$nblayers=2;
				}  
  				else
  				{
    				$StandStructureCode = "S";
					$nblayers=1;
				}
  			}
			else
			{
    			$StandStructureCode = ERRCODE;
				$nblayers=1;
			}
  			#$keys="structurecode#".$row->{STRUCTUR};
			#$herror{$keys}++; 				
 		}

		$SMR = SoilMoistureRegime($row->{MOISTURE},$row->{TYPECLAS},$row->{LANDPOS} );  
		if($SMR eq ERRCODE) 
		{  					
			$keys="MoistReg"."#".$row->{MOISTURE};
			$herror{$keys}++; 
	  	}

		if($StandStructureCode eq "V" || $StandStructureCode eq "H" || $StandStructureCode eq "M")
		{
			$SMR2 = SoilMoistureRegime($row->{MINMOIST},$row->{MINTYPECLA},$row->{LANDPOS} );
			if($SMR2 eq MISSCODE) 
			{  
				$SMR2 = $SMR;	
	  		}
		}
	
		if($row->{SITECLASS} eq "0" || isempty($row->{SITECLASS})) {$SiteClass = MISSCODE;}
		else {$SiteClass = Site($row->{SITECLASS}); }
		if($SiteClass  eq ERRCODE) 
		{  
			$keys="Sitecode"."#".$row->{SITECLASS}."#casID#".$row->{CAS_ID}."#nonProd#".$row->{TYPECLAS};
			$herror{$keys}++; 
		}

		$SiteIndex = MISSCODE;
		$MSiteClass2 = $SiteClass;
		if(isempty($row->{MINSITECLA}) || $row->{MINSITECLA} eq "0" )
		{
			$MSiteClass2 = MISSCODE;
		}
		else 
		{
			$MSiteClass2 = Site($row->{MINSITECLA}); 
		}
		if($MSiteClass2  eq ERRCODE)
		{  
			$keys = "minSitecode"."#".$row->{MINSITECLA}."#casID#".$row->{CAS_ID}."#nonProd#".$row->{MINTYPECLA};
			$herror{$keys}++; 
	  	}
		$MSiteIndex2 = MISSCODE; 

		if (isempty($row->{CROWNCLOS}))
		{
			$CCHigh = MISSCODE;
			$CCLow = MISSCODE;
		}
		else 
		{
			if(($row->{CROWNCLOS} % 10) <5)
			{
				$CrownCl = $row->{CROWNCLOS}-($row->{CROWNCLOS} % 10);
			}
			else
			{
				$CrownCl=$row->{CROWNCLOS} + 10 -($row->{CROWNCLOS} % 10);
			} 
			$CCHigh = CCUpper($CrownCl, 10);
			$CCLow = CCLower($CrownCl, 10);

			if($CCHigh  eq ERRCODE  ) 
			{ 			
				$keys = "Density"."#".$row->{CROWNCLOS};
				$herror{$keys}++;					
			}
			if( $CCLow  eq ERRCODE) 
			{ 			
				$keys = "Density"."#".$row->{CROWNCLOS};
				$herror{$keys}++;						
			}
		}
		$CCHigh2 =$CCHigh;$CCLow2=$CCLow;
		if(!isempty($row->{MINCROWNCL}) && $row->{MINCROWNCL} )
		{

			if(($row->{MINCROWNCL} % 10) <5)
			{
				$CrownCl2=$row->{MINCROWNCL}-($row->{MINCROWNCL} % 10);
			}
			else
			{
				$CrownCl2=$row->{MINCROWNCL} + 10 -($row->{MINCROWNCL} % 10);
			} 
			$CCHigh2 = CCUpper($CrownCl2, 10);
			$CCLow2 = CCLower($CrownCl2, 10);
			if($CCHigh2  eq ERRCODE  ) 
			{ 	
				$keys = "Understory Density"."#".$row->{MINCROWNCL};
				$herror{$keys}++;				
			}
			if( $CCLow2  eq ERRCODE) 
			{ 	
				$keys = "Understory Density"."#".$row->{MINCROWNCL};
				$herror{$keys}++;		
			}
		}
	
		$SpeciesComp = Species($row->{SP1},$row->{SP1_PER},$row->{SP2},$row->{SP2PER},$row->{SP3},$row->{SP3PER},$row->{SP4},$row->{SP4PER}, $spfreq);  

		@SpecsPerList  = split(",", $SpeciesComp); 
	 	$Sp1Per= $SpecsPerList[1];

		if($SpecsPerList[0]  eq SPECIES_ERRCODE) 
		{ 
			$keys="Species1"."#".$row->{SP1};
			$herror{$keys}++;
		}
		if($SpecsPerList[2]  eq SPECIES_ERRCODE) 
		{
			$keys="Species2"."#".$row->{SP2};
			$herror{$keys}++;
		}
		if($SpecsPerList[4]  eq SPECIES_ERRCODE) 
		{
			$keys="Species3"."#".$row->{SP3};
			$herror{$keys}++;
		}
		if($SpecsPerList[6]  eq SPECIES_ERRCODE) 
		{ 
			$keys="Species4"."#".$row->{SP4};
			$herror{$keys}++;
		}
	 
		my $total=$SpecsPerList[1] + $SpecsPerList[3]+ $SpecsPerList[5] +$SpecsPerList[7];
	
		#if($total ==90){$SpecsPerList[1]=$SpecsPerList[1]+10; $total =100;}
		#elsif($total ==110){$SpecsPerList[1]=$SpecsPerList[1]-10; $total =100;}
		#elsif($total ==120){$SpecsPerList[1]=$SpecsPerList[1]-20; $total =100;}

		if($total != 100 && $total != 0){

				$keys="total perct !=100"."#$total#".$row->{SP1}.",".$row->{SP1_PER}.",".$row->{SP2}.",".$row->{SP2PER}.",".$row->{SP3}.",".$row->{SP3PER}.",".$row->{SP4}.",".$row->{SP4PER};
				$herror{$keys}++; 
				#$errspec=1;
		}

		$SpeciesComp = $SpeciesComp .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";

		$USpeciesComp = Species($row->{MINSP1},$row->{MINSP1PER},$row->{MINSP2},$row->{MINSP2PER},$row->{MINSP3},$row->{MINSP3PER},$row->{MINSP4},$row->{MINSP4PER},$spfreq);  

		@USpecsPerList  = split(",", $USpeciesComp); 
	 	$USp1Per= $USpecsPerList[1];

		if($USpecsPerList[0]  eq SPECIES_ERRCODE  ) 
		{ 
			$MSP1=$row->{MINSP1};
			$MSP1=~ tr/a-z/A-Z/;
			if($MSP1 eq "CS" || $MSP1 eq "SH" || $MSP1 eq "LG")
			{
				$USpeciesComp=-1;
				$StandStructureCode="M";
				$nblayers=2;
			}
			else 
			{
				$keys="understory Species1"."#".$row->{MINSP1}."#casid#".$CAS_ID;
				$herror{$keys}++;
				$StandStructureCode="M";
				$nblayers=2;
			}
		}

		if($USpecsPerList[2]  eq SPECIES_ERRCODE) 
		{ 
			$MSP2=$row->{MINSP2};
			$MSP2=~ tr/a-z/A-Z/;
			if($MSP2 eq "CS" || $MSP2 eq "SH" || $MSP2 eq "LG")
			{
				$USpeciesComp=-1;
				$StandStructureCode="M";
				$nblayers=2;
			}
			else 
			{
				$keys = "understory Species2"."#".$row->{MINSP2};
				$herror{$keys}++;
			}		
		}
		if($USpecsPerList[4]  eq SPECIES_ERRCODE ) 
		{ 
			$MSP3=$row->{MINSP3};
			$MSP3=~ tr/a-z/A-Z/;
			if($MSP3 eq "CS" || $MSP3 eq "SH" || $MSP3 eq "LG")
			{
				$USpeciesComp=-1;
				$StandStructureCode="M";
				$nblayers=2;
			}
			else 
			{
				$keys="understory Species3"."#".$row->{MINSP3};
				$herror{$keys}++;
			}
		}

		if($USpecsPerList[6]  eq SPECIES_ERRCODE  ) 
		{ 
			$MSP4=$row->{MINSP4};
			$MSP4=~ tr/a-z/A-Z/;
			if($MSP4 eq "CS" || $MSP4 eq "SH" || $MSP4 eq "LG")
			{
				$USpeciesComp = -1;
				$StandStructureCode="M";
				$nblayers=2;
			}
			else 
			{
				$keys =" understory Species4"."#".$row->{MINSP4};
				$herror{$keys}++;
			}
	 	}
		my $Utotal=$USpecsPerList[1] + $USpecsPerList[3]+ $USpecsPerList[5] +$USpecsPerList[7];
	
		#if($total ==90){$SpecsPerList[1]=$SpecsPerList[1]+10; $total =100;}
		#elsif($total ==110){$SpecsPerList[1]=$SpecsPerList[1]-10; $total =100;}
		#elsif($total ==120){$SpecsPerList[1]=$SpecsPerList[1]-20; $total =100;}

		if($Utotal != 100 && $Utotal != 0 ){
				$keys="Stotal perct !=100"."#$Utotal#".$row->{MINSP1}.",".$row->{MINSP1PER}.",".$row->{MINSP2}.",".$row->{MINSP2PER}.",".$row->{MINSP3}.",".$row->{MINSP3PER}.",".$row->{MINSP4}.",".$row->{MINSP4PER};
				$herror{$keys}++; 
				#$errspec=1;
		}

		if ($USpeciesComp ne "-1") {
					$USpeciesComp = $USpeciesComp .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";
		}
	  
		#####################################

		$Origin_aux = $row->{ORIGIN};
		$Origin_aux =~ s/\.([0-9]+)$//g;
	 
        #print "origin converted is  $Origin_aux from   $row->{ORIGIN} >>>>>>>>>>"; 
		$OriginHigh = UpperOrigin($Origin_aux);
		$OriginLow = LowerOrigin($Origin_aux);

		if (($OriginLow <1000 && $OriginLow>0) && !isempty($PHOTO_YEAR) && $PHOTO_YEAR ne "0" )
		{
	 		$OriginLow=$PHOTO_YEAR-$OriginLow;
			$OriginHigh=$PHOTO_YEAR-$OriginHigh;
			$aux=$OriginLow;
			$OriginLow=$OriginHigh;
			$OriginHigh=$aux;
		}

		if($OriginHigh  <0 || $OriginLow <0  || ($OriginHigh < $OriginLow )||($OriginLow <1600 && $OriginLow>0) || ($OriginHigh <1600 && $OriginHigh >0)) 
		{ 
			if ($row->{LANDCOV} ne "F" &&  (!isempty($row->{LANDCOV}) ))
			{
				$OriginHigh = MISSCODE;
				$OriginLow = MISSCODE;
			}
			else 
			{
				#$keys=" origin"."#".$Origin_aux."#ltypeclass is#".$row->{TYPECLAS}."#species1#".$row->{SP1}."#photyear is #".$PHOTO_YEAR."#High#".$OriginHigh."#Low#".$OriginLow;
				#$herror{$keys}++;
				$OriginHigh = ERRCODE;
				$OriginLow = ERRCODE;		 	
			}
	 	} 
		#print "origin from $OriginLow to $OriginHigh "; exit; 
		$UOrigin_aux = $row->{MINORIGIN};
		$UOrigin_aux =~ s/\.([0-9]+)$//g;
		 
        #print "origin converted is  $Origin_aux from   $row->{ORIGIN} >>>>>>>>>>"; 
		$UOriginHigh = UpperOrigin($UOrigin_aux);
		$UOriginLow = LowerOrigin($UOrigin_aux);

		if($UOriginHigh  <0   ||$UOriginLow <0  ||($UOriginLow <1600 && $UOriginLow>0) || ($UOriginHigh <1600 && $UOriginHigh >0))
		{ 
			if ($row->{LANDCOV} ne "F" &&  (!isempty($row->{LANDCOV}) ))
			{
				$UOriginHigh = MISSCODE;
				$UOriginLow = MISSCODE;
			}
			else 
			{
				$keys=" understory origin"."#".$row->{MINORIGIN}."#turn to#".$UOrigin_aux."#typeclassis#".$row->{MINTYPECLA}."#species1#".$row->{MINSP1};
				$herror{$keys}++;		 	
			}
	    } 
		$HeightHigh = StandHeightUp($row->{HEIGHT});
		$HeightLow = StandHeightLow($row->{HEIGHT});
	
		if($HeightHigh == 0   || $HeightLow == 0 ) 
		{ 
			if (($row->{LANDCOV} ne "F" &&  (!isempty($row->{LANDCOV}))) || $row->{TYPECLAS} eq "ST" || isempty($row->{SP1}))
			{
				$HeightHigh=UNDEF;
				$HeightLow =UNDEF;
			}
			else 
			{
				#$keys="null Height"."#".$row->{HEIGHT}."#landcov is#".$row->{LANDCOV}."#typeclass#".$row->{TYPECLAS}."#species1#".$row->{SP1}."#Disturbance#".$row->{DIS1CODE}."#landbase#".$row->{LANDBASE}."#INVPROJ_ID#".$row->{INVPROJ_ID};
				#$herror{$keys}++;
				$HeightHigh=MISSCODE;	
				$HeightLow=MISSCODE;
			}
	 	} 
	  
		$UHeightHigh = StandHeightUp($row->{MINHEIGHT});
		$UHeightLow = StandHeightLow($row->{MINHEIGHT});
	
		if($UHeightHigh  == 0  || $UHeightLow  ==0 ) 
		{ 
			if (($row->{LANDCOV} ne "F" &&  (!isempty($row->{LANDCOV}))) || $row->{MINTYPECLA} eq "ST" || isempty($row->{MINSP1}))
			{
				$UHeightHigh=UNDEF;
				$UHeightLow =UNDEF;
			}
			else 
			{
				#$keys="null understory  Height"."#".$row->{MINHEIGHT}."#landcov is#".$row->{LANDCOV}."#typeclass#".$row->{TYPECLAS}."#species1#".$row->{MINSP1};
				#$herror{$keys}++;	
			}
		} 

		if($UHeightHigh eq MISSCODE || $UHeightHigh eq "0"){$UHeightHigh=$HeightHigh;}
		if($UHeightLow eq MISSCODE || $UHeightLow eq "0"){$UHeightLow=$HeightLow;}

		$Ecosite=UNDEF;

		$Wetland = WetlandCodes ($row->{LANDPOS}, $row->{STRUCTUR}, $row->{MOISTURE}, $row->{TYPECLAS}, $row->{TYPECLAS}, $row->{SP1}, $row->{SP2}, $row->{SP1_PER}, $row->{CROWNCLOS}, $row->{HEIGHT}, $row->{WETLAND});

		if($Wetland  eq ERRCODE ) 
		{ 
			$keys="WETLAND"."#".$row->{LANDPOS}."#".$row->{TYPECLAS}."#".$row->{WETLAND};
			$herror{$keys}++;
		}
	 	
	  	# ===== Modifiers =====

	 	$Mod=$row->{DIS1CODE}; 
		$ModYr = $row->{DIS1YEAR};
		$ModYr =~ s/\.([0-9]+)$//g;

		if(isempty($ModYr) || $ModYr==0){$ModYr=MISSCODE;}
		if(!defined ($Mod)){$Mod="";}

		$Extent=$row->{DIS1EXT};
		if (isempty($Extent))
		{
			$Extent =0;
		}
		$create_sp_nfl=0;

		if($Mod eq "UN"){
			$Cd1=MISSCODE;
		}
		elsif($Mod eq "PO")
		{
	 		if ($StandStructureCode eq "C" || $StandStructureCode eq "M" ||$StandStructureCode eq "H" )
	 		{
				$Cd1=MISSCODE;
			}
			elsif ($StandStructureCode eq "S")
			{
				$Cd1=MISSCODE;
				$StandStructureCode="H";
				$create_sp_nfl=1;
			}
		}
		else 
		{
			$Dist1 = Disturbance($Mod, $ModYr);
		 	($Cd1, $Cd2)=split(",", $Dist1);
		 	if($Cd1  eq ERRCODE ) 
		 	{ 
		 		$keys="Disturbance"."#".$row->{DIS1CODE};
				$herror{$keys}++;
			}
	  		if($Cd2>0 &&  $Cd2<1600  ) 
	  		{ 
	  			$keys="DisturbanceYear"."#".$row->{DIS1YEAR};
				$herror{$keys}++;
			}
	 		if($Extent ==0)
	 		{
				$Ext1=MISSCODE;
				$Ext2=MISSCODE;
	 		}
		 	else 
		 	{
				$Ext1= DisturbanceExtUpper($Extent);
		  		$Ext2= DisturbanceExtLower($Extent);
		 		if($Ext1  eq ERRCODE || $Ext2 eq ERRCODE) 
		 		{ 
					$keys="DisturbanceExtent"."#".$Extent;
					$herror{$keys}++;
	  			}
			}
	  		$Dist2 = MISSCODE.",-1111"; 
	  		$Dist3 = MISSCODE.",-1111"; 
          	$Dist2 = $Dist2 . ","  . UNDEF . "," . UNDEF;
          	$Dist3 = $Dist3 . "," . UNDEF . "," . UNDEF;
          	$Dist = $Dist1 . "," .$Ext1.",".$Ext2.",". $Dist2 . "," . $Dist3;
		}
	 	# ===== Non-forested Land =====
	  	$UnProdFor = UNDEF; 

		$NatNonVeg = NaturallyNonVeg($row->{TYPECLAS});
		$NonVegAnth=Anthropogenic($row->{TYPECLAS});
		$NonForVeg=NonForestedVeg($row->{TYPECLAS});

		$UNatNonVeg = NaturallyNonVeg($row->{MINTYPECLA});
		$UNonVegAnth=Anthropogenic($row->{MINTYPECLA});
		$UNonForVeg=NonForestedVeg($row->{MINTYPECLA});
			

		if(($NatNonVeg  eq ERRCODE) &&  ($NonVegAnth eq ERRCODE) && ($NonForVeg  eq ERRCODE) ) 
		{ 
			if($row->{TYPECLAS} eq "TC" || $row->{TYPECLAS} eq "TB" || $row->{TYPECLAS} eq "TM" || $row->{TYPECLAS} eq "XX") 
			{  
				$NatNonVeg = MISSCODE; 
				$NonVegAnth = MISSCODE; 
				$NonForVeg = MISSCODE;   
				if (isempty($row->{SP1})) 
				{
					$create_lyr=1;
				}
			}
			elsif(isempty($row->{SP1}) && $row->{SP1_PER}==0) 
			{
				if(!defined $row->{SP1_PER}) {$row->{SP1_PER} ="";}
				$keys="NonForNonVeg"."#".$row->{TYPECLAS}."#SP1#".$row->{SP1}."#sp1per#".$row->{SP1_PER}."#distcode#".$row->{DIS1CODE}."#landbase#".$row->{LANDBASE}."#landcov#".$row->{LANDCOV}."#landpos#".$row->{LANDPOS};
				$herror{$keys}++;

				$NatNonVeg = MISSCODE; 
				$NonVegAnth = MISSCODE; 
				$NonForVeg = MISSCODE;   
				$create_lyr=1;
			}
		}
		else 
		{
			if ($NatNonVeg  eq ERRCODE) 
			{ 
				$NatNonVeg = MISSCODE;  				
			}
	 		if ($NonVegAnth  eq ERRCODE)
	 		{ 
				$NonVegAnth = MISSCODE;  				
	 		}
			if ($NonForVeg  eq ERRCODE) 
			{ 
				$NonForVeg = MISSCODE;  				
			}
		}

        if(($UNatNonVeg  eq ERRCODE) &&  ($UNonVegAnth eq ERRCODE) && ($UNonForVeg  eq ERRCODE) ) 
        { 
			if($row->{MINTYPECLA} eq "TC" || $row->{MINTYPECLA} eq "TB" || $row->{MINTYPECLA} eq "TM")
			{  
				$UNatNonVeg = MISSCODE; $UNonVegAnth = MISSCODE; 
				$UNonForVeg = MISSCODE;  
			}
			else 
			{
				$keys="Understory NonForNonVeg"."#".$row->{MINTYPECLA};
				$herror{$keys}++;
				$UNatNonVeg = MISSCODE; $UNonVegAnth = MISSCODE; 
				$UNonForVeg = MISSCODE;  
			}
		}
		else 
		{
			if ($UNatNonVeg  eq ERRCODE) 
			{ 
				$UNatNonVeg = MISSCODE;  				
			}
	 		if ($UNonVegAnth  eq ERRCODE) 
	 		{ 
				$UNonVegAnth = MISSCODE;  				
	 		}
			if ($UNonForVeg  eq ERRCODE) 
			{ 
				$UNonForVeg = MISSCODE;  				
			}
		}

	  	# ===== Output inventory info for overstory =====
		$Struct_perc = UNDEF;
	  	if (($StandStructureCode eq "S") || ($StandStructureCode eq "C")) 
	  	{
			$nblayers=1; $Struct_perc=UNDEF;$Struct_perc2=UNDEF;
	  	}
	  	elsif (($StandStructureCode eq "M") || ($StandStructureCode eq "H"))
	  	{
			$nblayers=2;$Struct_perc=UNDEF;$Struct_perc2=UNDEF;
			if ($StandStructureCode eq "H") 
			{
				if(isempty($row->{STRC_PER}))
				{
					$Struct_perc = MISSCODE;
					$Struct_perc2 = MISSCODE;
					$keys = "#structper is#".$Struct_perc."#structure is#"."$StandStructureCode";
					$herror{$keys}++; 
				}
				else
				{
					$Struct_perc=10*$row->{STRC_PER};
					if($Struct_perc >100){$Struct_perc=ERRCODE;$Struct_perc2=ERRCODE;}
					else
					{
	  					$Struct_perc2=100-$Struct_perc;
					}
					if($Struct_perc <0 || $Struct_perc2< 0)
					{
						#$Struct_perc=MISSCODE;
						#$Struct_perc2=MISSCODE;
						$keys="#bizarre structper#".$row->{STRC_PER}."#".$Struct_perc."#struc per2s#".$Struct_perc2;
						$herror{$keys}++; 
					}
				}
			}
	 	}


		my $prod_for="PF";
		my $lyr_poly=0;
		if(isempty($row->{SP1}))
		{
			$SpeciesComp ="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";

			if( ( !is_missing($CCHigh) ||  !is_missing($CCLow) || !is_missing($HeightHigh) || !is_missing($HeightLow)) && $CrownCl != 0)
			{
				$prod_for="PP";	
				$lyr_poly=1;
			}
			else
			{
				if($create_lyr !=0) 
				{
					$lyr_poly=1;
				}
			}
			if($lyr_poly)
			{
				$Sp1 = $row->{SP1};
				if(!defined $row->{SP1})
				{
					$Sp1 = "";
				}
				$keys="###check artificial lyr on #".$Sp1."#";
				$herror{$keys}++; 
			}	
		}
		if ($Cd1  eq "CO")
		{
			$prod_for="PF";
			$lyr_poly=1;
		}
		#output results
        $CAS_Record = $CAS_ID . "," . $StandID. "," . $StandStructureCode .",". $nblayers .",". $IdentifyID . "," . $MapSheetID . "," . $Area . "," . $Perimeter . ",".$row->{AREAHA}. ",".$PHOTO_YEAR;
	    print CASCAS $CAS_Record . "\n";
	    $nbpr=1;$$ncas++;$ncasprev++;
        #forested
	    if (!isempty($row->{SP1}) || $lyr_poly == 1) 
	    { 
	    	#UnprodFor is MISSCODE
	      	$LYR_Record1 = $row->{CAS_ID}  . "," . $SMR  . "," .  $Struct_perc .",1,1";  
	      	$LYR_Record2 = $CCHigh . "," . $CCLow . "," . $HeightHigh . "," . $HeightLow . "," . $prod_for. "," . $SpeciesComp;
	      	$LYR_Record3 = $OriginHigh . "," . $OriginLow . "," . $SiteClass . "," . $SiteIndex ;
	      	$Lyr_Record = $LYR_Record1 . "," . $LYR_Record2 . "," . $LYR_Record3;
	      	print CASLYR $Lyr_Record . "\n";
	      	$nbpr++; $$nlyr++;$nlyrprev++;
	    }
        #non-forested
	    elsif ($NatNonVeg ne MISSCODE || $NonVegAnth ne MISSCODE || $NonForVeg ne MISSCODE) 
	    {
	      	$NFL_Record1 = $row->{CAS_ID}  . "," . $SMR  . "," .$Struct_perc .",1,1";  
	      	$NFL_Record2 = $CCHigh . "," . $CCLow . ",-8888,-8888";
	      	$NFL_Record3 =$NatNonVeg.",".$NonVegAnth.",".$NonForVeg;
            $NFL_Record = $NFL_Record1 . "," . $NFL_Record2 . "," . $NFL_Record3;
	      	print CASNFL $NFL_Record . "\n";
	      	$nbpr++;$$nnfl++;$nnflprev++;
	    }

           
		#create a second .nfl layer of rank 2 and type LA, and have the extent of the layer 10%.
		if($create_sp_nfl)
		{
	      	$NFL_Record1 = $row->{CAS_ID}  . "," . $SMR2  . "," . "10,2,2";  
	      	$NFL_Record2 = $CCHigh2 . "," . $CCLow2 . ",-8888,-8888";
	      	$NFL_Record3 ="LA,-1111,-1111";
            $NFL_Record = $NFL_Record1 . "," . $NFL_Record2 . "," . $NFL_Record3;
	      	print CASNFL $NFL_Record . "\n";
	      	if($nbpr==1) {$nbpr++;$$nnfl++;$nnflprev++;}
		}
		#===============understorey
		if (($StandStructureCode eq "M") || ($StandStructureCode eq "H") )
		{
			if ($USpeciesComp eq "-1") 
			{
				#There will also be an .nfl record of code ST if  MINHEIGHT>2.0 and SL if MINHEIGHT <= 2.0 m or Missing.
				$NFL_Record1 = $row->{CAS_ID}  . "," . $SMR2  . "," .$Struct_perc2. ",2,2";  
		      	$NFL_Record2 = $CCHigh2 . "," . $CCLow2. ",-8888,-8888";
		      	if(!isempty($row->{MINHEIGHT})) 
		      	{
					if($row->{MINHEIGHT} >2 ){ $NFL_Record3 ="-1111,-1111,ST";}
					else {$NFL_Record3 ="-1111,-1111,SL";}
				}
				else {$NFL_Record3 ="-1111,-1111,SL";}     
	        	$NFL_Record = $NFL_Record1 . "," . $NFL_Record2 . "," . $NFL_Record3;
		   	 	print CASNFL $NFL_Record . "\n";
			}
			elsif (!isempty($row->{MINSP1})) 
			{
	      		$LYR_Record1 = $row->{CAS_ID}  . "," . $SMR2  . "," .$Struct_perc2. ",2,2";  
	      		$LYR_Record2 = $CCHigh2 . "," . $CCLow2 . "," . $UHeightHigh . "," . $UHeightLow  . "," . $prod_for. "," . $USpeciesComp;
	      		$LYR_Record3 = $UOriginHigh . "," . $UOriginLow . "," . $MSiteClass2 . "," . $MSiteIndex2;
	      		$Lyr_Record = $LYR_Record1 . "," . $LYR_Record2 . "," . $LYR_Record3;
	      		print CASLYR $Lyr_Record . "\n";
	    	}
	    	elsif ($UNatNonVeg ne MISSCODE || $UNonVegAnth ne MISSCODE || $UNonForVeg ne MISSCODE) 
	    	{
	      		$NFL_Record1 = $row->{CAS_ID}  . "," . $SMR2  . "," .$Struct_perc2. ",2,2"; 
	      		$NFL_Record2 = $CCHigh2 . "," . $CCLow2 . ",-8888,-8888";
	      		$NFL_Record3 =$UNatNonVeg.",".$UNonVegAnth.",".$UNonForVeg;
              	$NFL_Record = $NFL_Record1 . "," . $NFL_Record2 . "," . $NFL_Record3;
	      		print CASNFL $NFL_Record . "\n";
	    	}
		}
 	  	#Disturbance
	    if (!isempty($Mod) && $Cd1 ne MISSCODE) 
	    {
	      	$DST_Record = $row->{CAS_ID}  . "," . $Dist.",1";
	      	print CASDST $DST_Record . "\n";
			if($nbpr==1) {$$ndstonly++; $ndstonlyprev++;}
			$nbpr++;$$ndst++;$ndstprev++;
	    }
	    #Ecological 
	    if ($Wetland ne MISSCODE) 
	    {
			if ($Wetland eq "W") {$Wetland = $row->{CAS_ID}  . "," . $Wetland.",-,-,-,-";}
			else
	     	{
	     		$Wetland = $row->{CAS_ID}  . "," . $Wetland."-";
	     	}
	        print CASECO $Wetland . "\n";
			if($nbpr==1) {$$necoonly++;$necoonlyprev++;}
			$nbpr++;$$neco++;$necoprev++;
	    }
	  
		
		if($nbpr ==1 )
		{
			$ndrops++;
			if(isempty($row->{SP1})  &&  isempty($row->{TYPECLAS}) && $Wetland eq MISSCODE &&  isempty($Mod)) 
			{
				$keys ="MAY  DROP THIS>>>-bcse species,typeclass,wetland and dstb are null\n";
 				$herror{$keys}++; 
			}
			else 
			{
				if(!(isempty($row->{SP1}) && ($row->{TYPECLAS} eq "TC" || $row->{TYPECLAS} eq "TB" || $row->{TYPECLAS} eq "TM" || $row->{TYPECLAS} eq "XX"))) 
				{
					$keys ="!!! record may be dropped#"."specs=".$row->{SP1}."-nfordesc=".$row->{TYPECLAS}."-landpos=".$row->{LANDPOS}."-wetland=".$Wetland."-mod1=".$Mod;
 					$herror{$keys}++; 
					$keys ="#droppable#";
 					$herror{$keys}++; 
				}
				else
				{
					$keys ="MAY  DROP THIS bcse bcse SP=".$row->{SP1}."#typeclass=".$row->{TYPECLAS}."\n";
 					$herror{$keys}++; 
				}
			}
		}
    }

	$csv->eof or $csv->error_diag ();
  	close $NTinv;

	foreach my $k (sort {lc($a) cmp lc($b)} keys %$spfreq)
	{
		$_ = $k;
		tr/a-z/A-Z/;
		my $upk = $_;
	 	print SPERRSFILE "cumulative frequency of species " ,$upk,  " is ", $spfreq->{$k},"\n";
		#print "invalid code " ,$k,  " found ", $herror{$k}," times\n";
  	}
  	$keys="###check total nb of lyr #".$nlyrprev;
	$herror{$keys}++; 
	foreach my $k (keys %herror)
	{
	 	print ERRS "invalid code " ,$k,  " found ", $herror{$k}," times\n";
		#print "invalid code " ,$k,  " found ", $herror{$k}," times\n";
	}
	#close (NTinv);
	close (CASHDR);
	close (CASCAS);
	close (CASLYR);
	close (CASNFL);
	close (CASDST);
	close (CASECO);
	#close(INFOHDR); 
	close(ERRS);
	close(SPERRSFILE); close(SPECSLOGFILE); 

	$total=$nlyrprev+ $nnflprev+  $ndstprev;
	$total2=$nlyrprev+ $nnflprev+  $ndstonlyprev + $necoonlyprev;
	#if($total > $ncasprev) {print "must check this !!! \n";}
	#print "$$ncas, $$nlyr, $$nnfl,  $$ndst, $total\n";
	#print "nb records in casfile : $ncasprev, lyrfile : $nlyrprev, nflfile : $nnflprev,  dstfile : $ndstprev--- total(without .cas): $total\n";
	print " drops=$ndrops : $ncasprev, lyrfile : $nlyrprev, nflfile : $nnflprev,  dstfile : $ndstprev($ndstonlyprev), ecofile : $necoprev($necoonlyprev)--- total (without .cas): $total($total2)\n";
}


1;
#province eq "NT";

