package ModulesV4::BC_conversion11;


use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(&BCinv_to_CAS );

use strict;
use Text::CSV;

use Math::Round;
use Data::Dumper;
our $INV_version;
our $Species_table;	
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

#3 versions : F, V, I

## VX 	X	SX	SM	M	SG	HG	SD		HD			VX, X, SX = D  	SM, M=F  	SG, HG=M  	SD, HD=W
## 0=VX, 1=X, 2=SX, 3= SM, 4=M, 5=SG, 6=HG, 7=SD, and 8=HD.
## SoilMoistureRegime  from $SMR  (version V or I)

sub SoilMoistureRegime
{
	my $MoistReg;
	my %MoistRegList = ("",1, "0", 1, "1", 1, "2", 1, "3", 1, "4", 1, "5", 1, "6", 1, "7", 1, "8", 1, "9", 1);
	my $stdnum;
	my $SoilMoistureReg;


    ($MoistReg) = shift(@_);  
    $stdnum = shift(@_);

	if ($stdnum eq "0001"){return UNDEF;}
	else {
			

			if  (isempty($MoistReg))        { $SoilMoistureReg = MISSCODE; }
			elsif (!$MoistRegList {$MoistReg})   { $SoilMoistureReg = ERRCODE; }
			
			elsif (($MoistReg eq "0"))         { $SoilMoistureReg = "D"; }
			elsif (($MoistReg eq "1"))         { $SoilMoistureReg = "D"; }
			elsif (($MoistReg eq "2"))         { $SoilMoistureReg = "D"; }
			elsif (($MoistReg eq "3"))         { $SoilMoistureReg = "F"; }
 			elsif (($MoistReg eq "4"))         { $SoilMoistureReg = "F"; }
			elsif (($MoistReg eq "5"))         { $SoilMoistureReg = "M"; }
			elsif (($MoistReg eq "6"))         { $SoilMoistureReg = "M"; }
			elsif (($MoistReg eq "7"))         { $SoilMoistureReg = "W"; }
			elsif (($MoistReg eq "8"))         { $SoilMoistureReg = "W"; }
			elsif (($MoistReg eq "9"))         { $SoilMoistureReg = "W"; }  #last decision to avoid error on data source field =9
			

			return $SoilMoistureReg;
	}
}


#V or I Layer_cnt	Layers_id 0-9,V	1,2,3-9

#from $CC  (version F)   

sub CCUpper
{
	my $CCHigh;
	my $CC; 
	
	($CC) = shift(@_);  

	if (isempty($CC)) { $CCHigh = MISSCODE; }
	
	#elsif ($INV_version eq "F" ){
	else
	{
		if ($CC == 0)  { $CCHigh = 5; }
		elsif ($CC == 1)  { $CCHigh = 15; }
		elsif ($CC == 2)  { $CCHigh = 25; }
		elsif ($CC == 3)  { $CCHigh = 35; }
       	elsif ($CC == 4)  { $CCHigh = 45; }
		elsif ($CC == 5)  { $CCHigh = 55; }
		elsif ($CC == 6)  { $CCHigh = 65; }
		elsif ($CC == 7)  { $CCHigh = 75; }
        elsif ($CC == 8)  { $CCHigh = 85; }
		elsif ($CC == 9)  { $CCHigh = 95; }
		elsif ($CC == 10) { $CCHigh = 100;}
		#elsif ($CC > 0 && $CC <94) { $CCHigh = $CC - ($CC % 5) +10; }
		#elsif ($CC > 94 && $CC <=100) { $CCHigh = 100;}
		else { $CCHigh = ERRCODE; }					
	}
	#elsif ($INV_version eq "V" || $INV_version eq "I"){ 
	#					if($CC <=100 && $CC >=0) {$CCHigh =$CC;}
	#					else { $CCHigh = ERRCODE; }
	#}

	return $CCHigh;
}

#0-5	6-15	16-25	26-35	36-45	46-55	56-65	66-75	76-85	86-95	96-100

sub CCLower {
	my $CCLow;
	my $CC;  
		
	($CC) = shift(@_); 

	if (isempty($CC)) { $CCLow = MISSCODE; }
	
	else 
	{							
		if ($CC == 0)  { $CCLow = 0; }
		elsif ($CC == 1)  { $CCLow = 6; }
		elsif ($CC == 2)  { $CCLow = 16; }
		elsif ($CC == 3)  { $CCLow = 26; }
        elsif ($CC == 4)  { $CCLow = 36; }
		elsif ($CC == 5)  { $CCLow = 46; }
		elsif ($CC == 6)  { $CCLow = 56; }
		elsif ($CC == 7)  { $CCLow = 66; }
        elsif ($CC == 8)  { $CCLow = 76; }
		elsif ($CC == 9)  { $CCLow = 86; }
		elsif ($CC == 10)  { $CCLow = 96; }
		#elsif ($CC > 0 && $CC <100) {  $CCLow = $CC - ($CC % 5) +1;}
		#elsif ($CC ==100) {  $CCLow = 96;}
		else { $CCLow = ERRCODE; }
	}
	
	return $CCLow;
}

#from $HT (F)   

sub StandHeightUp
{
	my $Height; #my $isCF;
	my %HeightList = ("",1, "1", 1, "2", 1, "3", 1, "4", 1, "5", 1, "6", 1, "7", 1, "8", 1);
	my $HUpp;

	($Height) = shift(@_);
	#($isCF) = shift(@_);

	if  (isempty($Height) || $Height eq "0")                  	  { $HUpp = MISSCODE; }
	elsif (!$HeightList {$Height} )   { $HUpp = ERRCODE; }
	else 
	{		
		if (($Height eq "1"))  		  { $HUpp = 10.4; }
		elsif (($Height eq "2"))                  { $HUpp = 19.4; }
		elsif (($Height eq "3"))                  { $HUpp = 28.4; }
		elsif (($Height eq "4"))                  { $HUpp = 37.4; }
		elsif (($Height eq "5"))                  { $HUpp = 46.4; }
		elsif (($Height eq "6"))                  { $HUpp = 55.4; }
		elsif (($Height eq "7"))                  { $HUpp = 64.4; }
		elsif (($Height eq "8"))                  { $HUpp = INFTY; }
		#elsif (($Height >=0 && $Height<70))                  { $HUpp = round($Height)+0.5; }
		else {$HUpp = ERRCODE;}
	}

	return $HUpp;
}

#1                     0-10.4	2                10.5-19.4	3                      19.5-28.4	4                          28.5-37.4	5                      37.5-46.4	6                    46.5-55.4	7                       55.5-64.4	8                                   64.5-INFINITY	

#Determine lower bound stand height from HEIGHT  
sub StandHeightLow 
{
	my $Height;  
	my %HeightList = ("",1, "1", 1, "2", 1, "3", 1, "4", 1, "5", 1, "6", 1, "7", 1, "8", 1);
	my $HLow;

	($Height) = shift(@_);
	
	if  (isempty($Height) || $Height eq "0" )                    { $HLow = MISSCODE; }
	#elsif ($INV_version eq "V" || $INV_version eq "I"){ 
	#					if($Height >=0.06) {$HLow =$Height-0.05;}
	#					elsif($Height >=0.01) {$HLow =0;}
	#					else { $HLow = ERRCODE; }
	#}
	#elsif ($INV_version eq "F"){	
	elsif (!$HeightList {$Height} ) { $HLow = ERRCODE; }
	else 
	{						
		if (($Height eq "1"))  	          { $HLow = 0; }
		elsif (($Height eq "2"))                  { $HLow = 10.5; }
		elsif (($Height eq "3"))                  { $HLow = 19.5; }
		elsif (($Height eq "4"))                  { $HLow = 28.5; }
		elsif (($Height eq "5"))                  { $HLow = 37.5; }
		elsif (($Height eq "6"))                  { $HLow = 46.5; }
		elsif (($Height eq "7"))                  { $HLow = 55.5; }
		elsif (($Height eq "8"))                  { $HLow = 64.5; }
		#elsif (($Height >=0.5 && $Height<70))                  { $HLow = round($Height)-0.5; }
		#elsif (($Height >=0 && $Height<0.5))                  { $HLow = 0; }
		else {$HLow = ERRCODE;}
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
		if ($Species_table->{$CurrentSpecies}) { $GenusSpecies = $Species_table->{$CurrentSpecies}; }
		else 	 {$GenusSpecies = SPECIES_ERRCODE;  print SPECSLOGFILE "Illegal species code $CurrentSpecies, CAS_ID=$Glob_CASID, file=$Glob_filename\n";  } 
	}
	
	return $GenusSpecies;
}

#6 Species fields  SP#  and SP#PER  (from $CC)
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
	my $spfreq=shift(@_);
	
 	if(defined $Sp1Per){} else {$Sp1Per=0;} if(defined $Sp2Per){} else {$Sp2Per=0;} if(defined $Sp3Per){} else {$Sp3Per=0;}
	if(defined $Sp4Per){} else {$Sp4Per=0;} if(defined $Sp5Per){} else {$Sp5Per=0;} if(defined $Sp6Per){} else {$Sp6Per=0;}

	if(defined $Sp1){} else {$Sp1="";} if(defined $Sp2){} else {$Sp2="";} if(defined $Sp3){} else {$Sp3="";}
	if(defined $Sp4){} else {$Sp4="";} if(defined $Sp5){} else {$Sp5="";} if(defined $Sp6){} else {$Sp6="";}
	
	
	my $Species;
	my $CurrentSpec;

	$spfreq->{$Sp1}++;
	$spfreq->{$Sp2}++;
	$spfreq->{$Sp3}++;
	$spfreq->{$Sp4}++;
	$spfreq->{$Sp5}++;
	$spfreq->{$Sp6}++;
	$Sp1 = Latine($Sp1); $Sp2 = Latine($Sp2); $Sp3 = Latine($Sp3); $Sp4 = Latine($Sp4); $Sp5 = Latine($Sp5); $Sp6 = Latine($Sp6);
	$Species = $Sp1 . "," . $Sp1Per . "," . $Sp2 . "," . $Sp2Per . "," . $Sp3 . "," . $Sp3Per . "," . $Sp4 . "," . $Sp4Per . "," . $Sp5 . "," . $Sp5Per . "," . $Sp6 . "," . $Sp6Per;

	return $Species;
}



#from $AGE, 
#check with original data
#rules changed by SC


sub UpperOrigin 
{
	my %OriginList = ("",1, "1", 1, "2", 1, "3", 1, "4", 1, "5", 1, "6", 1, "7", 1, "8", 1, "9",1);
	my $Origin=shift(@_);
	my $OriginUpp;

	

	if (isempty($Origin))  		  	  { $OriginUpp =MISSCODE; }
	elsif (!$OriginList {$Origin})  { $OriginUpp = ERRCODE; }
	elsif (($Origin eq "1"))  		  { $OriginUpp = 20; }
	elsif (($Origin eq "2"))                  { $OriginUpp = 40; }
	elsif (($Origin eq "3"))                  { $OriginUpp = 60; }
	elsif (($Origin eq "4"))                  { $OriginUpp = 80; }
	elsif (($Origin eq "5"))                  { $OriginUpp = 100; }
	elsif (($Origin eq "6"))                  { $OriginUpp = 120; }
	elsif (($Origin eq "7"))                  { $OriginUpp = 140; }
	elsif (($Origin eq "8"))                  { $OriginUpp = 250; }
	elsif (($Origin eq "9"))                  { $OriginUpp = INFTY; }
	else {$OriginUpp = ERRCODE;}

	return $OriginUpp;	
}

sub LowerOrigin
{
	my %OriginList = ("",1, "1", 1, "2", 1, "3", 1, "4", 1, "5", 1, "6", 1, "7", 1, "8", 1, "9",1);
	my $Origin=shift(@_);
	my $OriginLow;

	
	if (isempty($Origin))  		  	  { $OriginLow =MISSCODE; }
	elsif (!$OriginList {$Origin} )   { $OriginLow =ERRCODE; }
	elsif (($Origin eq "1"))  		  { $OriginLow = 1; }
	elsif (($Origin eq "2"))                  { $OriginLow = 21; }
	elsif (($Origin eq "3"))                  { $OriginLow = 41; }
	elsif (($Origin eq "4"))                  { $OriginLow = 61; }
	elsif (($Origin eq "5"))                  { $OriginLow = 81; }
	elsif (($Origin eq "6"))                  { $OriginLow = 101; }
	elsif (($Origin eq "7"))                  { $OriginLow = 121; }
	elsif (($Origin eq "8"))                  { $OriginLow = 141; }
	elsif (($Origin eq "9"))                  { $OriginLow = 251; }
	else {$OriginLow = ERRCODE;}

	return $OriginLow;	
}

sub Site 
{
	my $Site; my $INV_version;
	my $TPR; 
	my %TPRList = ("",1, "p", 1, "m", 1, "g", 1, "l", 1, "P", 1, "M", 1, "G", 1, "L", 1); 

	($TPR) = shift(@_);
	($INV_version) = shift(@_);

	if($INV_version eq "F" ) 
	{
		if  (isempty($TPR))                                      { $Site = MISSCODE; }
		elsif (!$TPRList {$TPR} ) { $Site = ERRCODE; }
		elsif (($TPR eq "l") || ($TPR eq "L"))                   { $Site = "P"; }
		elsif (($TPR eq "p") || ($TPR eq "P"))                   { $Site = "P"; }
		elsif (($TPR eq "m") || ($TPR eq "M"))                   { $Site = "M"; }
		elsif (($TPR eq "g") || ($TPR eq "G"))                   { $Site = "G"; }
	}
	else { $Site = UNDEF; }
	
	return $Site;
}
	
   
#F  A=AP                     	R=RK               	Claybank = EX                  	Slide = SL                                  NPB=SD	Gravel Bar=WS                                          NP=NP	Lake = LA	River=RI
#GL=SI  RM=EX  LA=LA	PN=SI  BE=BE  RE=LA BR=RK   LL=EX  RI=RI  TA=RK    BI=RK  MU=WS    CB=EX   LB=RK    MN=EX  EL=EX   RS=WS ES=EX LS=WS  SI=SI RO=RK OC=OC
#from ref doc.  TC, TB, TM, ST, SL, HE, HF, HG,BY, BM, BL, SI, RO, EL
#DE, OP, SP   CL, OP, GL, PN, BR, TA, BI, MZ, LB, RS, ES, LS, RM, BE, LL, BU, RZ, MU, CB, RN, GP, TZ, RN,UR, AP, MI,OT, LA, RE, RI, OC
 #restant    RZ=FA 	MZ-IN  	GP=IN   TZ=IN  	RN=FA   UR=SE  AP=FA  MI=IN  OT=OT        
#Natnonveg ==== AP, LA, RI, OC, RK, SA, SI, SL, EX, BE, WS, FL, IS, TF   

sub NaturallyNonVeg 
{
    my $NatNonVeg;
    my %NatNonVegList = ("",1,"A", 1, "R", 1, "CL", 1, "SLIDE", 1, "G", 1, "L", 1, "RIV", 1,"OP", 1, "ICE", 1,"SAND", 1,"TIDE", 1,
	"SL", 1, "OC", 1, "NA", 1, "GL", 1, "PN", 1, "SC", 1, "SI", 1, "RM", 1, "BU", 1, "LL", 1, "CB", 1, "MN", 1,  "EL", 1,  "ES", 1,  "LA", 1, "BE", 1, "RE", 1, "BR", 1, "TA", 1, "BI", 1, "RT", 1,  "LB", 1, "RO", 1, "RI", 1, "MU", 1, "MUD", 1, "RS", 1,  "LS", 1);#"S", 1,
 	
	($NatNonVeg) = shift(@_);
	
    if  (isempty($NatNonVeg))  { $NatNonVeg = MISSCODE; }
    else 
    {
    	$_ = $NatNonVeg; tr/a-z/A-Z/; $NatNonVeg = $_;
		if (!$NatNonVegList {$NatNonVeg} ) { $NatNonVeg = ERRCODE; }
		elsif($INV_version eq "F")
		{
	      	if (($NatNonVeg eq "A"))     { $NatNonVeg = "AP"; }
	      	elsif (($NatNonVeg eq "R"))     { $NatNonVeg = "RK"; }
	        elsif (($NatNonVeg eq "CL") || ($NatNonVeg eq "MUD") )     { $NatNonVeg = "EX"; }#09 CL
			elsif (($NatNonVeg eq "SLIDE"))     { $NatNonVeg = "SL"; } #|| ($NatNonVeg eq "S")
	        elsif (($NatNonVeg eq "G"))     { $NatNonVeg = "WS"; }
			elsif (($NatNonVeg eq "L"))     { $NatNonVeg = "LA"; }
			elsif (($NatNonVeg eq "RIV"))     { $NatNonVeg = "RI"; }
	 		elsif (($NatNonVeg eq "ICE"))     { $NatNonVeg = "SI"; }
			elsif (($NatNonVeg eq "SAND"))     { $NatNonVeg = "SA"; }
			elsif (($NatNonVeg eq "TIDE"))     { $NatNonVeg = "TF"; }	
			else  { $NatNonVeg = ERRCODE; }		  
		}
		elsif($INV_version eq "V" || $INV_version eq "I") 
		{		
			if(($NatNonVeg eq "SL"))     { $NatNonVeg = "SL"; }
			elsif(($NatNonVeg eq "OC") || ($NatNonVeg eq "NA") )     { $NatNonVeg = "OC"; }
			elsif(($NatNonVeg eq "GL") || ($NatNonVeg eq "ICE")  || ($NatNonVeg eq "PN") || ($NatNonVeg eq "SC") || ($NatNonVeg eq "SI"))   { $NatNonVeg = "SI"; }
	 		elsif(($NatNonVeg eq "RM") || ($NatNonVeg eq "BU") || ($NatNonVeg eq "LL") || ($NatNonVeg eq "CB") || ($NatNonVeg eq "MN"))     { $NatNonVeg = "EX"; }
			elsif(($NatNonVeg eq "EL") || ($NatNonVeg eq "ES") || ($NatNonVeg eq "SAND")|| ($NatNonVeg eq "OP"))     						{ $NatNonVeg = "EX"; }
			elsif(($NatNonVeg eq "LA") || ($NatNonVeg eq "RE"))     { $NatNonVeg = "LA"; }
	 		elsif(($NatNonVeg eq "BE"))  { $NatNonVeg = "BE"; }
			elsif(($NatNonVeg eq "BR") || ($NatNonVeg eq "TA") || ($NatNonVeg eq "BI") || ($NatNonVeg eq "RT"))     { $NatNonVeg = "RK"; }
			elsif(($NatNonVeg eq "LB") || ($NatNonVeg eq "RO"))     												{ $NatNonVeg = "RK"; }
			elsif(($NatNonVeg eq "RI"))     { $NatNonVeg = "RI"; }
	 		elsif(($NatNonVeg eq "MU") || ($NatNonVeg eq "MUD") || ($NatNonVeg eq "TIDE")|| ($NatNonVeg eq "RS") || ($NatNonVeg eq "LS"))     { $NatNonVeg = "WS"; }
	 		else  { $NatNonVeg = ERRCODE; }		
		}
		else  
		{ 
			$NatNonVeg = ERRCODE; 
		}
	}
	return $NatNonVeg;
}		

#F  U=SE  C=CL	
#AP=FA                 	            TZ=IN MI=IN     RN=FA        UR=SE    RZ=FA      MZ-IN   GP=IN  	OT=OT  
#Anthropogenic IN, FA, CL, SE, LG, BP, OT
#Non vegetated  anthropologocal 
 
sub Anthropogenic 
{
	my $NonVegAnth; 
	#my $INV_version= shift(@_);
	my %NonVegAnthList = ("",1,"U", 1, "C", 1, "P", 1, "RZ", 1, "RP", 1, "MZ", 1, "GP", 1, "GR", 1, "TZ", 1, "TS", 1, "RN", 1, "RR", 1, "UR", 1, "BP", 1, "AP", 1, "MI", 1,"OT", 1);

	$NonVegAnth = shift(@_);

	
    if  (isempty($NonVegAnth))					{ $NonVegAnth = MISSCODE; }
    else 
    {
    	$_ = $NonVegAnth; tr/a-z/A-Z/; $NonVegAnth = $_;

		if (!$NonVegAnthList {$NonVegAnth} ) { $NonVegAnth = ERRCODE; }
		elsif($INV_version eq "F")
		{
			if (($NonVegAnth eq "U")) 	 	{ $NonVegAnth = "FA"; } #old { $NonVegAnth = "SE"; }
			elsif (($NonVegAnth eq "C")||($NonVegAnth eq "P"))				{ $NonVegAnth = "CL"; }
			elsif (($NonVegAnth eq "GR"))				{ $NonVegAnth = "IN"; }
			else { $NonVegAnth = ERRCODE; }
		}
		elsif($INV_version eq "V" || $INV_version eq "I") 
		{	
			if (($NonVegAnth eq "RZ") || ($NonVegAnth eq "RP") || ($NonVegAnth eq "RN") || ($NonVegAnth eq "RR")  ||($NonVegAnth eq "AP")) { $NonVegAnth = "FA"; }
			elsif (($NonVegAnth eq "MZ")|| ($NonVegAnth eq "GP")|| ($NonVegAnth eq "TZ")|| ($NonVegAnth eq "TS") ||($NonVegAnth eq "MI"))  { $NonVegAnth = "IN"; }
			elsif (($NonVegAnth eq "UR") || ($NonVegAnth eq "BP"))				{ $NonVegAnth = "SE"; }
			elsif (($NonVegAnth eq "OT"))				{ $NonVegAnth = "OT"; }
			else { $NonVegAnth = ERRCODE; }
		}
		else  { $NonVegAnth = ERRCODE; }
    }
	return $NonVegAnth;
}
 

#nf_descr	ST=ST	SL=SL	HE=HE	HF=HF	HG=HG	BY=BR	BM-BR	BL=BR

#Non Forested Vegetated	Several Options: LAND_CD_1, BCLCS_LV_4 and 5, HERB_TYP	ST=ST	SL=SL	HE=HE	HF=HF	HG=HG	BY=BR	BM=BR	BL=BR

 #F OR=HG  NP Br=ST  Swamp=SL	Muskeg=OM  M=HG  Slide = SL   
#NonForestedVeg ---ST, SL, HF, HE, HG, BR, OM, BT #A=AP /                     OR=HG/	R=RK                U=SE/	Claybank = EX                  NP Br=ST	Slide = SL/                                  NPB=SD	Gravel Bar=WS                                          NP=NP/	Lake = LA	River=RI	Swamp=SL/	Muskeg=OM/	C=CL/	M=HG/
sub NonForestedVeg
{

    my $NonForVeg; 
	#my $INV_version= shift(@_);
    my %NonForVegList = ("",1, "OR", 1, "NPBR", 1, "M", 1, "MUSKEG", 1,  "ST", 1, "HE", 1, "HF", 1, "HG", 1,  "BY", 1, "BM", 1, "BL", 1, "SL", 1,"SWAMP", 1,"S", 1);#"S", 1,"SLIDE", 1

	$NonForVeg = shift(@_);				 #print "deb Nonforveg ==---$NonForVeg---\n ";
	
    if (isempty($NonForVeg))    {$NonForVeg = MISSCODE; }
    else
    {
    	$_ = $NonForVeg; tr/a-z/A-Z/; $NonForVeg = $_;
		#if(defined $NonForVeg){} else {$NonForVeg="NULL";} 
		#print "end Nonforveg ==---$NonForVeg---\n ";
 		if (!$NonForVegList {$NonForVeg})    {$NonForVeg = ERRCODE;}

		elsif($INV_version eq "F")
		{
	       	if (($NonForVeg eq "OR"))       { $NonForVeg = "HG"; }
	 		elsif (($NonForVeg eq "NPBR"))       { $NonForVeg = "ST"; }
			elsif (($NonForVeg eq "M") )       { $NonForVeg = "HG"; }
			elsif (($NonForVeg eq "MUSKEG") )       { $NonForVeg = "OM"; }	
			elsif (($NonForVeg eq "SWAMP") )       { $NonForVeg = "SL"; }	#SWAMP
			elsif (($NonForVeg eq "S") )       { $NonForVeg = "SL"; }	#SWAMP
			else {$NonForVeg = ERRCODE;}
			#elsif (($NonForVeg eq "SLIDE") ||($NonForVeg eq "S") )       { $NonForVeg = "SL"; }
		}
		elsif($INV_version eq "V" || $INV_version eq "I")
		{
			if (($NonForVeg eq "ST"))       { $NonForVeg = "ST"; }
	 		elsif (($NonForVeg eq "HE"))       { $NonForVeg = "HE"; }
			elsif (($NonForVeg eq "HF"))       { $NonForVeg = "HF"; }
			elsif (($NonForVeg eq "SL"))       { $NonForVeg = "SL"; }
			elsif (($NonForVeg eq "HG"))       { $NonForVeg = "HG"; }	
	 		elsif (($NonForVeg eq "BY"))       { $NonForVeg = "BR"; }
	 		elsif (($NonForVeg eq "BM"))       { $NonForVeg = "BR"; }
			elsif (($NonForVeg eq "BL"))       { $NonForVeg = "BR"; }
			else {$NonForVeg = ERRCODE;}
		}
		else
		{ 
			$NonForVeg = ERRCODE; 
		}
	}
    return $NonForVeg;
}

#OC=OC??????????????
#UnProdForest TM,TR,  AL, SD, SC, NP,  ?P
sub UnProdForest 
{
	 
    my $NonForVeg = shift(@_); #my $INV_version= shift(@_);
	
    my %NonForVegList = ("",1, "AF", 1, "NP", 1, "NPL", 1,  "GRAVELNP", 1, "NC", 1, "NTA", 1, "NCBR", 1, "NSR", 1, "NPBU", 1, "NA", 1);
 	
    if (isempty($NonForVeg))                                   { $NonForVeg = MISSCODE; }
    else
    {
    	$_ = $NonForVeg; tr/a-z/A-Z/; $NonForVeg = $_;

		if (!$NonForVegList {$NonForVeg} ) {$NonForVeg = ERRCODE;}
    	elsif (($NonForVeg eq "AF"))       { $NonForVeg = "AL"; }
		elsif (($NonForVeg  eq "NPBU"))     { $NonForVeg  = "SD"; }#************ask John as for BU
	    elsif (($NonForVeg eq "NP")|| ($NonForVeg eq "NPL"))       { $NonForVeg = "NP"; }
	 	elsif (($NonForVeg eq "NC")|| ($NonForVeg eq "NTA")|| ($NonForVeg eq "NCBR")|| ($NonForVeg eq "NSR"))  { $NonForVeg = "PP"; }
		elsif (($NonForVeg eq "GRAVELNP"))       { $NonForVeg = "NP"; }
		elsif (($NonForVeg eq "NA"))    { $NonForVeg = "PP"; }#**********ask John   ?UNDEF
		else { $NonForVeg = ERRCODE; }
    }
   
    return $NonForVeg;
}

sub NPCodetoNPDesc 
{
	
    my $NonForVeg = shift(@_); 
	 
 	if(isempty($NonForVeg)) { $NonForVeg = MISSCODE; }
 	elsif ($NonForVeg eq "15")                                   { $NonForVeg = "L"; }
	elsif ($NonForVeg eq "00" || ($NonForVeg eq "0"))         { $NonForVeg = MISSCODE; }
	elsif (($NonForVeg eq "01") || ($NonForVeg eq "1"))       { $NonForVeg = "ICE"; }
 	elsif (($NonForVeg eq "02") || ($NonForVeg eq "2"))       { $NonForVeg = "A"; }
	elsif (($NonForVeg eq "03") || ($NonForVeg eq "3"))       { $NonForVeg = "R"; }
	elsif (($NonForVeg eq "06") || ($NonForVeg eq "6"))       { $NonForVeg = "GR"; }
 	elsif (($NonForVeg eq "07") || ($NonForVeg eq "7"))       { $NonForVeg = "SAND"; }
	elsif (($NonForVeg eq "09") || ($NonForVeg eq "9"))       { $NonForVeg = "CL"; }#
  	elsif (($NonForVeg eq "10"))       { $NonForVeg = "AF"; }
 	elsif (($NonForVeg eq "11"))       { $NonForVeg = "NPBR"; }
	elsif (($NonForVeg eq "12"))       { $NonForVeg = "NP"; }
	elsif (($NonForVeg eq "13"))       { $NonForVeg = "NPBU"; }
	elsif (($NonForVeg eq "15"))       { $NonForVeg = "L"; }
    elsif (($NonForVeg eq "16"))       { $NonForVeg = "TIDE"; }
 	elsif (($NonForVeg eq "18"))       { $NonForVeg = "G"; }
	elsif (($NonForVeg eq "25"))       { $NonForVeg = "RIV"; }
	elsif (($NonForVeg eq "26"))       { $NonForVeg = "MUD"; }
 	elsif (($NonForVeg eq "35"))       { $NonForVeg = "SWAMP"; }
	elsif (($NonForVeg eq "42"))       { $NonForVeg = "C"; }
  	elsif (($NonForVeg eq "50"))       { $NonForVeg = "U"; }
 	elsif (($NonForVeg eq "54"))       { $NonForVeg = "U"; }
	elsif (($NonForVeg eq "60"))       { $NonForVeg = "P"; }
	elsif (($NonForVeg eq "62"))       { $NonForVeg = "M"; }
 	elsif (($NonForVeg eq "63"))       { $NonForVeg = "OR"; }
	elsif (($NonForVeg eq "64"))       { $NonForVeg = "NA"; }
	else	{ $NonForVeg = ERRCODE; }
	return $NonForVeg;
}
         
#15 L 16 TIDE 18 G25 RIV26 MUD35 S42 C50 U54 U60 P62 M63 OR64 NA
#B (wildfire), BE (escaped burn), BG (ground burn), BR (range
#burn), BW (wildlife burn), D (disease), F (flooding), I (insect), K (fume kill), L (logging), L% (logged with
#percentage), R (site rehabilitation), S (slide), and W (wind throw).

#from  $Activity_cd and $Disturbance_Start_Date
#L=CO         B=BU	W=W         D=D	  K=OT                   S=SL	F=FL                    I = IK

sub Disturbance 
{
	my $ModCode;
	my $Mod;
	my $ModYr;
	my $Disturbance;
	
	my %ModList = ("L", 1, "B", 1, "W", 1, "D", 1, "K", 1,"S", 1, "F", 1, "I", 1, "R", 1, "U", 1, "A", 1, "C", 1, "T", 1, "V", 1, "N", 1,"G", 1, "Y", 1, "i", 1, "r", 1,
	"l", 1, "b", 1, "w", 1, "d", 1, "k", 1,"s", 1, "f",1);
   
	($ModCode) = shift(@_);
	($ModYr) = shift(@_);
	if (isempty($ModYr)) {$ModYr=MISSCODE; }

	if (isempty($ModCode)) { $Disturbance = MISSCODE.",".$ModYr; }
	elsif ($ModList{$ModCode} ) 
	{ 
 		if (($ModCode  eq "L") || ($ModCode eq "l")) { $Mod="CO"; }
		elsif (($ModCode  eq "B") || ($ModCode eq "b")) { $Mod="BU"; }
		elsif (($ModCode  eq "W") || ($ModCode eq "w")) { $Mod="W"; }
		elsif (($ModCode  eq "D") || ($ModCode eq "d")) { $Mod="D"; }
		elsif (($ModCode  eq "K") || ($ModCode eq "k")) { $Mod="OT"; }
		elsif (($ModCode  eq "S") || ($ModCode eq "s"))   { $Mod="SL"; }
		elsif (($ModCode  eq "F") || ($ModCode eq "f")) { $Mod="FL"; }
		elsif (($ModCode  eq "I") || ($ModCode eq "i"))   { $Mod="IK"; }
		elsif (($ModCode  eq "R") || ($ModCode eq "r"))   { $Mod="SI"; }
		elsif (($ModCode  eq "G") || ($ModCode eq "Y"))   { $Mod="WE"; }
		elsif (($ModCode  eq "A") || ($ModCode eq "C")|| ($ModCode eq "T")|| ($ModCode eq "U")|| ($ModCode eq "V"))   { $Mod="OT"; }
		elsif (($ModCode  eq "N") )   { $Mod="UK"; } #new disturbance code defined by SC
		$Disturbance = $Mod . "," . $ModYr;          
	} 
	else 
	{ 
		$Mod = ERRCODE; 
		$Disturbance = $Mod . "," . $ModYr;  
	}

	return $Disturbance;
}



sub DisturbanceExtUpper 
{
    my $ModExt;
    my $DistExtUpper;
	my %DistExtList = ("", 1, "1", 1, "2", 1, "3", 1, "4",1, "5",1, "6", 1, "7", 1, "8",1,"9",1);


    ($ModExt) = shift(@_);

	
	if (isempty($ModExt)) { $DistExtUpper = MISSCODE; }
	elsif (!$DistExtList{$ModExt} )  {$DistExtUpper = ERRCODE; }

	elsif ($ModExt == 1 || $ModExt == 2)  { $DistExtUpper = 20; }
	elsif ($ModExt == 3 || $ModExt == 4)  { $DistExtUpper = 40; }
	elsif ($ModExt == 5)  		      { $DistExtUpper = 50; }
	elsif ($ModExt == 6 || $ModExt == 7)  { $DistExtUpper = 70; }
	elsif ($ModExt == 8 || $ModExt == 9)  { $DistExtUpper = 90; }

    return $DistExtUpper;
}

sub DisturbanceExtLower 
{
    my $ModExt;
    my $DistExtLower;

	my %DistExtList = ("", 1, "1", 1, "2", 1, "3", 1, "4",1, "5",1, "6", 1, "7", 1, "8",1,"9",1);


    ($ModExt) = shift(@_);

	if (isempty($ModExt)) { $DistExtLower = MISSCODE; }
	elsif (!$DistExtList{$ModExt} ) {$DistExtLower = ERRCODE; }

	elsif ($ModExt == 1 || $ModExt == 2)  { $DistExtLower = 10; }
	elsif ($ModExt == 3 || $ModExt == 4)  { $DistExtLower = 30; }
	elsif ($ModExt == 5)  		      { $DistExtLower = 50; }
	elsif ($ModExt == 6 || $ModExt == 7)  { $DistExtLower = 60; }
	elsif ($ModExt == 8 || $ModExt == 9)  { $DistExtLower = 80; }

    return $DistExtLower;
}



# Determine wetland codes 
sub WetlandCodes 
{
    my $WetlandCodeUnProd;  #== $NP;
	my $WetlandCodeNonFor;
	my $Wetland="";
	my $SMR;
	my $Species1;
	my $Species2;
	my $SpeciesPerc;
	my $CC;
	my $Height;
	my $landcoverCode;
	#my $INV_version;

 	$WetlandCodeUnProd=shift(@_);
	$WetlandCodeNonFor=shift(@_);
	$landcoverCode=shift(@_);
	$SMR=shift(@_);

	$Species1=shift(@_);
	$Species2=shift(@_);
	$SpeciesPerc=shift(@_);
	$CC=shift(@_);
	$Height=shift(@_);

	if(defined $Species1) {} else {print "sp1 is not defined \n";$Species1="";}
	if(defined $Species2) {} else {print "sp2 is not defined \n"; $Species2="";}
	
	if(defined $Height) 
	{
		if(isempty($Height)) 
		{
			$Height=0;
		}
	} 
	else { $Height=0;}
	
	$_ = $Species1; tr/a-z/A-Z/; $Species1 = $_;

#print("verif values CC=#$CC#-- height=#$Height#----Sp1=#$SpeciesPerc#--------smr=#$SMR#\n");
	if($INV_version eq "F")
	{
	 
		if (($Species1 eq  "SB" || $Species1 eq  "CW" || $Species1 eq  "YC" )) 
		{  

   			if ($WetlandCodeUnProd eq "S")  {  $Wetland="S,T,N,N,";  } #SWAMP 
			if ($WetlandCodeUnProd eq "NP")  {$Wetland="S,T,N,N,"; }   
		}
		elsif ($WetlandCodeNonFor eq "NPBR")  {  $Wetland="S,T,N,N,";  }
		elsif ($WetlandCodeNonFor eq "S")  {  $Wetland="S,O,N,S,";  } #SWAMP
		elsif ($WetlandCodeNonFor eq "MUSKEG")    { $Wetland = "S,T,N,N,"; }#MUSKEG
	}
	elsif($INV_version eq "V" || $INV_version eq "I")
	{

		$_ = $Species2; tr/a-z/A-Z/; $Species2 = $_;
		if($landcoverCode eq  "W" ) {  $Wetland="W,-,-,-,"; } 

		elsif($SMR eq "7" || $SMR eq "8") 
		{
			if($Species1 eq "SB" &&  $SpeciesPerc ==100.0 && $CC == 50 && $Height == 12)    { $Wetland = "B,T,N,N,"; }
			elsif(  ($Species1 eq "SB" || $Species1 eq "LT") && $SpeciesPerc ==100.0  && $CC >= 50 && $Height >= 12) { $Wetland = "S,T,N,N,"; }
			elsif(  ($Species1 eq "SB" || $Species1 eq "LT") &&  ($Species2 eq "SB" || $Species2 eq "LT") && $CC >= 50 && $Height >= 12) { $Wetland = "S,T,N,N,"; }
			elsif($Species1 eq "EP" || $Species1 eq "EA" || $Species1 eq "CW" || $Species1 eq "YC" || $Species1 eq "PI" )  { $Wetland = "S,T,N,N,"; }
			elsif(  ($Species1 eq "SB" || $Species1 eq "LT") &&  ($Species2 eq "SB" || $Species2 eq "LT") && $CC < 50 ) { $Wetland = "F,T,N,N,"; }
			elsif($Species1 eq "LT" &&  $SpeciesPerc ==100 &&  $Height < 12)  { $Wetland = "F,T,N,N,"; }
		}
		if($SMR eq "7" || $SMR eq "8") 
		{
			if($landcoverCode eq  "ST" || $landcoverCode eq  "SL" ) {  $Wetland="S,O,N,S,"; } 
			elsif($landcoverCode eq  "HE" || $landcoverCode eq  "HF" || $landcoverCode eq  "HG" ) {  $Wetland="M,O,N,G,"; } 
			elsif($landcoverCode eq  "BY" || $landcoverCode eq  "BM" ) {  $Wetland="F,O,N,N,"; } 
			elsif($landcoverCode eq  "BL") {  $Wetland="B,O,N,N,"; } 
			elsif($landcoverCode eq  "MU" ) {  $Wetland="T,M,N,N,"; } 
		}
    }

 	if (isempty($Wetland)) {$Wetland = MISSCODE;}# MISSCODE.",".MISSCODE.",".MISSCODE.",".MISSCODE.",";
 	return $Wetland;
}



###########################################

###    Here is the main program   ####

###########################################


sub BCinv_to_CAS 
{
	# Must be in the same order que les arguments pass\E9es dans la fonction principale
	my $BC_File = shift(@_);
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
	my $MstandsLOG=shift(@_);
	my $temp2=shift(@_);
	my $temp3=shift(@_);

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

	#print "version $INV_version \n";  
	#print "version $INV_version and file is  $BC_File\n";  


	open (ERRS, ">>$ERRFILE") || die "\n Error: Could not open $ERRFILE file!\n";
	open (SPERRSFILE, ">>$SPERRS") || die "\n Error: Could not open $SPERRS file!\n";	
	open (SPECSLOGFILE, ">>$SPECSLOG") || die "\n Error: Could not open $SPECSLOG file!\n";
	open (MISSING_STANDS, ">>$MstandsLOG") || die "\n Error: Could not open $MstandsLOG file!\n";

	if($optgroups==1)
	{

	 	$CAS_File_HDR = $pathname."/BCLPtable.hdr";
	 	$CAS_File_CAS = $pathname."/BCLPtable.cas";
	 	$CAS_File_LYR = $pathname."/BCLPtable.lyr";
	 	$CAS_File_NFL = $pathname."/BCLPtable.nfl";
	 	$CAS_File_DST = $pathname."/BCLPtable.dst";
	 	$CAS_File_ECO = $pathname."/BCLPtable.eco";
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


		 #print CASHDR $HDR_Record . "\n";

	}
	else 	
	{
		open (CASCAS, ">>$CAS_File_CAS") || die "\n Error: Could not open GROUPCAS  output file!\n";
		open (CASLYR, ">>$CAS_File_LYR") || die "\n Error: Could not open GROUPCAS layer output file!\n";
		open (CASNFL, ">>$CAS_File_NFL") || die "\n Error: Could not open GROUPCAS non-forested file!\n";
		open (CASDST, ">>$CAS_File_DST") || die "\n Error: Could not open GROUPCAS disturbance  file!\n";
		open (CASECO, ">>$CAS_File_ECO") || die "\n Error: Could not open GROUPCAS ecological  file!\n";
	}

	
	my $Record; my @Fields;my $StandID; my $CAS_ID; my $MapSheetID; my $IdentifyID;my $Area; my $Perimeter;
	my $Mer;my $Rng;my $Twp;my $MoistReg; 
	my $SpAss; my $Sp1;my $Sp2;my $Sp3; my $Sp4;my $Sp5;my $Sp6;my $Sp7;my $Sp8; my $Sp9;my $Sp10;
	my $Sp1Per;my $Sp2Per;my $Sp3Per;  my $Sp4Per; my $Sp5Per; my $Sp6Per;my $Sp7Per;my $Sp8Per; my $Sp9Per;my $Sp10Per;
	my $CrownClosure; my $isNFL; my $ucsp1;
	
	my $Dist; my $Dist1; my $Dist2; my $Dist3; 
	my $WetEco;  my $Ecosite;my $SMR;my $SMR_L2;my $SMR_L3;
	my $StandStructureCode;
	my $CCHigh;my $CCLow;
	my $SpeciesComp; my $SpComp; 
	my $SiteClass; my $SiteIndex;
	my $Wetland;  my $HDR_RecordV; my $HDR_RecordF;  my $HDR_RecordI; my $Hdr_I_set=0; my $Hdr_F_set=0; my $Hdr_V_set=0;
	my $NatNonVeg; 
	my %herror=();
	my $keys;
	my $PHOTO_YEAR; my $PROJECTED_YEAR;
	my $Height;my $Height_L2;my $Height_L3; my $HeightHigh ; my  $HeightLow; my $HeightHigh_L2 ; my  $HeightLow_L2; my $HeightHigh_L3 ; my  $HeightLow_L3;
	my $Origin; my $Origin_L2; my $Origin_L3; my $OriginHigh; my $OriginLow; my  $OriginHigh_L2; my $OriginLow_L2; my  $OriginHigh_L3; my $OriginLow_L3; 

	my @ListSp; my $Mod; my $ModYr; my $NonProd; my $Drain;
	my $CAS_Record; my $Lyr_Record; my $LYR_Record1; my $LYR_Record2; my $LYR_Record3; my $LYR_Record4;
	my $NFL_Record; my $NFL_Record1; my $NFL_Record2; my $NFL_Record3;my $NFL_Record4; my $DST_Record; 
	my  @SpecsPerList;my $pr1;my $pr2;my $pr3; my $pr4;my $pr5;my $SpAssoc; my $SiteCode; my $StandStructureVal;
	my $NonVegAnth; my $NonForVeg; my $UnProdFor; my  $cpt_ind;
	my $INV_cod_stand; my $Struc; my $StrucPer;my $LayerRank; my $LayerId; my $NumLayers; my $NonVeg; my $NonVegCov; my $NPdesc; my $NPcode; my $Nfor_desc;
	my $LCC1; my $LCC2;my $LCC3; my $LCC4;my $LCC5; my $LandCoverCode;my $Mod1; my $Mod2;my $Mod3;my $Mod1Ext; my $Mod1Yr; my $Mod2Yr; my $Mod3Yr; my $WetEcosite; my @SpecsInit;
	my $invstd;
	my $NPcodedesc; my $NatNonVeg2; my $NatNonVeg3; my $NonVegAnth2; my $NonVegAnth3; my $UnProdFor2; my $NonForVeg2; my $NonForVeg3; my $NatNonVegCor;
	my $LandCoverClassCode;my $LandCoverClassCode_L2;my $LandCoverClassCode_L3; my $Dist1ExtHigh; my $Dist1ExtLow;
	my $totalpct; my $Cd1; my $Cd2; my $Cd12; my $Cd22; my $Mod2Ext;
	my $REF_YEAR; my $lblpolyId; my $sz; my $Total_pct; my$P1; my $P2; my $juridname; my $std_num;
	my $missing_area=0; my $SUBS_REFYEAR;

	my $NonVegPct; my $NonVegPct_L2;my $NonVegPct_L3; 
	my $NonVeg_L2; my $NonVeg_L3;

	my $csv = Text::CSV_XS->new({binary          => 1, 
					sep_char    => ";" });
   	open my $BCinv, "<", $BC_File or die " \n Error: Could not open British Columbia input file $BC_File: $!";
   	$csv->column_names ($csv->getline ($BCinv));

	$HDR_RecordI="1,BC,,,,PROV_GOV,MOF,,,I,,,,,,";
	$HDR_RecordF="2,BC,,,,PROV_GOV,MOF,,,F,,,,,,";
	$HDR_RecordV="3,BC,,,,PROV_GOV,MOF,,,V,,,,,,";

	my @tfilename= split ("/", $BC_File);
	my $nps=scalar(@tfilename);
	$Glob_filename= $tfilename[$nps-1];

	#################################3

	my %BC_Areatracking = ();
	my $missingcasfile= $temp2;
 	if($temp2 ne "")
 	{
		open( BC_MS, "$missingcasfile" )
		  || die "\n Error: Could not open species correction file --*$missingcasfile*--- !\n";
		my $csv2    = Text::CSV_XS->new();
		my $nothing2 = <BC_MS>;            #drop header line
		while (<BC_MS>) 
		{
			if ( $csv2->parse($_) ) {
				my @BCcas_Record = ();
				@BCcas_Record = $csv2->fields();
				my $BCkeys = $BCcas_Record[0];
				$BC_Areatracking{$BCkeys} = 1;
				#print("fFILE no = $MBkeys , age = @MBS_Record[1]\n"); #exit;
			}
			else {
				my $err = $csv2->error_input;
				print "Failed to parse line: $err";
				exit(1);
			}
		}
		close(BC_MS);
	}
	################

	while (my $row = $csv->getline_hr ($BCinv)) 
   	{	
  
		#$INV_cod_stand = $row->{INVENTORY_STANDARD_CD}; #INVENTORY_
		$CAS_ID       =  $row->{CAS_ID}; 
		$Glob_CASID   =  $row->{CAS_ID};
		($pr1,$pr2,$pr3, $pr4, $pr5)     =  split("-", $row->{CAS_ID} );    	    
	    $MapSheetID   =  $pr3; 
	    $MapSheetID =~ s/x+//;
	    $StandID = $pr4;
		$StandID =~ s/^0+//;
	     
	    $IdentifyID   =  $row->{HEADER_ID};     	
	    $Area         =  $row->{GIS_AREA};    
		$Perimeter    =  $row->{GIS_PERI};  

		($P1, $P2)=split("-",  $CAS_ID);
		($juridname, $std_num)=split ("_", $P1);

		if($std_num eq "0007")
		{
			$INV_version="V";
			$invstd="V";
		}
		else 
		{
			$invstd=$row->{INVENTORY_STANDARD_CD}; 
			$INV_version=$invstd;
		}
	 	 
		if ( $std_num ne "0007" && $INV_version ne $invstd)
		{
			print "standard mistmatch : _inventory field is $invstd --- computed is $INV_version from $P1 \n";
			exit;
		} 

	  	if (defined $row->{REFERENCE_YEAR}) {$SUBS_REFYEAR=$row->{REFERENCE_YEAR};}
		elsif ( defined $row->{REFERENCE_YR}) {$SUBS_REFYEAR=$row->{REFERENCE_YR};}
		else { print "ref_year not found in source data\n"; exit;}

	 	$PROJECTED_YEAR= substr $row->{PROJECTED_DATE}, 0, 4;

		if(isempty($SUBS_REFYEAR))
		{
			$REF_YEAR=MISSCODE;
			#print "look for this refyear $SUBS_REFYEAR \n"; #exit;
		}
		else 
		{	  
			$REF_YEAR = $SUBS_REFYEAR; #  substr $row->{REFERENCE_YEAR}, 0, 4 ; #substr $row->{REF_DATE}, 0, 4 ; 
		 
	        if ($REF_YEAR <=0) 
	        {
				print "want to see this one  $REF_YEAR from ".$SUBS_REFYEAR. " \n"; exit;
				$REF_YEAR = MISSCODE;
				$keys="ref_year negative value"."#".$REF_YEAR;
				$herror{$keys}++;
		 	}
		}
		# REFERENCE_DATE  
		$PHOTO_YEAR=0;

	 	if(isempty($row->{REFERENCE_DATE})  && !isempty($SUBS_REFYEAR))
	 	{
			$PHOTO_YEAR=$SUBS_REFYEAR;
		}
		elsif(isempty($row->{REFERENCE_DATE}))
		{
			$PHOTO_YEAR=MISSCODE;
		}
		else
		{
		 	my $nl=length ($row->{REFERENCE_DATE});
		  	if($nl >=4)
		  	{
		  		$PHOTO_YEAR = substr $row->{REFERENCE_DATE}, 0, 4 ;  #$PHOTO_YEAR = substr $row->{REFERENCE_DATE}, $nl-4, 4 ;
		  	}
		  	# if(defined $PHOTO_YEAR){}else {$PHOTO_YEAR=0;}
		 	
		  	if ($PHOTO_YEAR <=0 || $PHOTO_YEAR >2014) 
		  	{
				$PHOTO_YEAR = MISSCODE;
				$keys="photoyear "."#".$PHOTO_YEAR."#taken from#".$row->{REFERENCE_DATE};
				$herror{$keys}++;
		  	}
		}
    	
		$MoistReg     =  $row->{SOIL_MOISTURE_REGIME_1}; 

		#if($std_num eq "0007"){
					$LayerRank=1;
					$Struc="S";  
					$NumLayers=1;
					$LayerId=1;
		#}
		#else {
		 	
	  	#  	$LayerRank	= $row->{FOR_COVER_RANK_CD}; #RANK_CD, FOR_COVER_
		#		        if($LayerRank ne "" && $LayerRank ne "1" && $LayerRank ne "NULL") {$keys="rank_cd"."#".$LayerRank;
		#						     $herror{$keys}++;   
		#		  	} 
		#			if ($LayerRank eq "NULL") {$LayerRank=MISSCODE;}
		#	$Struc="M";  
		#	$NumLayers=1; #temporaire
		 # 	$LayerId	= $row->{LAYER_ID};
		#	$keys="LayerID***" .$LayerId;
		#	$herror{$keys}++;	
		#	if ($LayerId ne "NULL" && $LayerRank eq MISSCODE) { $keys="BIZARRE layer_id not null but rankcd is"."#".$LayerId;
		#						    		 $herror{$keys}++;   
		#	}
		#	if ($LayerId eq "NULL") {$LayerId=MISSCODE;}
		#}


		#if($INV_version eq "F" ){   #$INV_cod_stand   USE THIS FOT BCTFL48
		#  	$CrownClosure =  $row->{CROWN_CLOSURE_CLASS_CD};   #$row->{CROWN_CL_1};  or $row->{CR_CLOSURE};	
		#	#if(!$row->{CROWN_CLOSURE_CLASS_CD}) {$CrownClosure ="";}
		#} 
		#elsif($std_num eq "0004" || $std_num eq "0005" || $std_num eq "0006"){   #$INV_cod_stand   USE THIS FOT BCTFL48
		#  	$CrownClosure =  $row->{CROWN_CLOSURE};   #$row->{CROWN_CL_1};  or $row->{CR_CLOSURE};	
		#	#if(!$row->{CROWN_CLOSURE_CLASS_CD}) {$CrownClosure ="";}
		#} 
		
		$CrownClosure =  $row->{CROWN_CLOSURE_CLASS_CD};
	 	$CCHigh       =  CCUpper($CrownClosure); 
	    $CCLow        =  CCLower($CrownClosure);
	   
	 	if($CCHigh  eq ERRCODE   || $CCLow  eq ERRCODE || $CCHigh  >100   || $CCLow >100) 
	 	{ 
			$keys="CrownClosure"."#".$CrownClosure;
		    $herror{$keys}++; 
		}

		$Sp1          =  $row->{SPECIES_CD_1}; #SPEC_CD_1
	    $Sp2          =  $row->{SPECIES_CD_2}; #SPEC_CD_2
	    $Sp3          =  $row->{SPECIES_CD_3}; #SPEC_CD_3
	    $Sp4          =  $row->{SPECIES_CD_4}; #SPEC_CD_4
	    $Sp5          =  $row->{SPECIES_CD_5}; #SPEC_CD_5
	    $Sp6          =  $row->{SPECIES_CD_6}; #SPEC_CD_6
	         
	    $Sp1Per       =  $row->{SPECIES_PCT_1};  #SPEC_PCT_1
	    $Sp2Per       =  $row->{SPECIES_PCT_2} ;  #SPECIES__2
	    $Sp3Per       =  $row->{SPECIES_PCT_3} ;  #SPEC_PCT_3
	    $Sp4Per       =  $row->{SPECIES_PCT_4} ;  #SPEC_PCT_4
	    $Sp5Per       =  $row->{SPECIES_PCT_5}  ;  #SPEC_PCT_5
	    $Sp6Per       =  $row->{SPECIES_PCT_6} ; #SPEC_PCT_6

		if(!defined $Sp1Per || isempty($Sp1Per)){$Sp1Per=0;}
		if(!defined $Sp2Per || isempty($Sp2Per)){$Sp2Per=0;}
		if(!defined $Sp3Per || isempty($Sp3Per)){$Sp3Per=0;}
		if(!defined $Sp4Per || isempty($Sp4Per)){$Sp4Per=0;}
		if(!defined $Sp5Per || isempty($Sp5Per)){$Sp5Per=0;}
		if(!defined $Sp6Per || isempty($Sp6Per)){$Sp6Per=0;}

		$Sp1Per =~ s/\.([0-9]+)$//g;$Sp2Per =~ s/\.([0-9]+)$//g;$Sp3Per =~ s/\.([0-9]+)$//g;$Sp4Per =~ s/\.([0-9]+)$//g;$Sp5Per =~ s/\.([0-9]+)$//g;
		$Sp6Per =~ s/\.([0-9]+)$//g;

        $Total_pct=$Sp1Per+$Sp2Per+$Sp3Per+$Sp4Per+$Sp5Per+$Sp6Per;
	
		if(  $Total_pct >100) 
		{
			$keys="Perctg_Species >100"."#".$Sp1."___". $Sp1Per."####".$Sp2."___". $Sp2Per."####".$Sp3."___". $Sp3Per."####".$Sp4."___". $Sp4Per."####".$Sp5."___". $Sp5Per."####".$Sp6."___". $Sp6Per;
			$herror{$keys}++;
		}
		$NonVeg       =  $row->{NON_VEG_COVER_TYPE_1};   #NVEG_TYP_1,  NON_VEG__2
	  	$NonVegPct    =  $row->{NON_VEG_COVER_PCT_1};   #NVEG_TYP_1,  NON_VEG__2
	  	

		$NPdesc	=  $row->{NON_PRODUCTIVE_DESCRIPTOR_CD}; #NP_DESC, NON_PRODUC
		$NPcode	=  $row->{NON_PRODUCTIVE_CD};    #NP_CODE, NON_PROD_1
		if(defined $row->{NON_FOREST_DESCRIPTOR}) 
		{
			$Nfor_desc= $row->{NON_FOREST_DESCRIPTOR};
		} #NFOR_DESC, NON_FOREST
		else {$Nfor_desc="";}   

 	
	  
	 	$SiteClass	=  $row->{EST_SITE_INDEX_SOURCE_CD}; #HIST_S_CD, EST_SITE_I
		#$SiteIndex 	=  $row->{SITE_INDEX}; 
        if (!isempty($row->{SITE_INDEX}))
        {
  			$SiteIndex  = sprintf("%.1f", $row->{SITE_INDEX});
  			#print "siteindex is $SiteIndex\n";
	   	}
	  	else {$SiteIndex  = MISSCODE;} 

 	  	$LandCoverClassCode  =  $row->{LAND_COVER_CLASS_CD_1}; #LAND_CD_1, LAND_COVER
       	 
	  	$SMR =  SoilMoistureRegime($row->{SOIL_MOISTURE_REGIME_1}, $std_num);
	  	if($SMR eq ERRCODE) 
	  	{ 
			$keys="MoistReg"."#".$row->{SOIL_MOISTURE_REGIME_1};
			$herror{$keys}++;	
	  	}

        $StandStructureCode   =  $Struc; # BK- july 2014 StandStructure($Struc);#StandStructure($Struc, $INV_version);
        $StandStructureVal     =  UNDEF;  #"";

	  	$Height   =  $row->{PROJ_HEIGHT_CLASS_CD_1};
	  	if($Height eq "0.0" || isempty($Height)){$Height=0;}
	  	$HeightHigh   =  StandHeightUp($Height);
        $HeightLow    =  StandHeightLow($Height);

	  	if($HeightHigh  eq ERRCODE   || $HeightLow  eq ERRCODE) 
	  	{ 
	  		$keys="Height"."#".$Height; #."#comment#".$row->{MD_COMMENT};
			$herror{$keys}++; 
		}

		#if($HeightHigh  eq MISSCODE   || $HeightLow  eq MISSCODE) { 
		#					if($Sp1 ne "" && $Sp1 ne "0" && $Sp1 ne "NULL" && $LayerRank eq "1"){
		#						       $keys="NULL Height"."#".$Height."#species1#".$Sp1."#LandCC#".$LandCoverClassCode;
		#				     			$herror{$keys}++;
		#					}	
														
		#}

		$SpComp=$Sp1."#".$Sp1Per."#".$Sp2."#".$Sp2Per."#".$Sp3."#".$Sp3Per."#".$Sp4."#".$Sp4Per."#".$Sp5."#".$Sp5Per."#".$Sp6."#".$Sp6Per;

		$SpeciesComp  =  Species($Sp1, $Sp1Per, $Sp2, $Sp2Per, $Sp3, $Sp3Per, $Sp4, $Sp4Per, $Sp5, $Sp5Per, $Sp6, $Sp6Per, $spfreq);
		@SpecsPerList  = split(",", $SpeciesComp); 
		@SpecsInit=($Sp1, $Sp2, $Sp3, $Sp4, $Sp5, $Sp6);
		$totalpct=$SpecsPerList[1]+$SpecsPerList[3]+$SpecsPerList[5]+$SpecsPerList[7]+$SpecsPerList[9]+$SpecsPerList[11];
		my $nbf=0;
		my $pos_inc=0;
	 	if(  $totalpct>=80 &&  $totalpct<100) 
	 	{ 

			for($cpt_ind=0; $cpt_ind<6; $cpt_ind++)
			{  
				my $posi=$cpt_ind*2;
	 	 		if($SpecsPerList[$posi] ne "XXXX MISS"  && $SpecsPerList[$posi+1]==0 ) 
	 	 		{ 
					$nbf++;	
					$pos_inc=$posi+1;	  
				}
		  	}
			if($nbf>1)
			{
				$keys="CORRECTION nb P=0#".$nbf;
				$herror{$keys}++; 
			}
			elsif($nbf==1)
			{
					
				if( (100-$totalpct) > $SpecsPerList[$pos_inc-2])
				{
					$SpecsPerList[$pos_inc]=$SpecsPerList[$pos_inc-2];
					$SpecsPerList[$pos_inc-2]=100-$totalpct;
				}
				else
				{
					$SpecsPerList[$pos_inc]=100-$totalpct;
				}
	 			#$totalpct=$SpecsPerList[1]+$SpecsPerList[3]+$SpecsPerList[5]+$SpecsPerList[7]+$SpecsPerList[9]+$SpecsPerList[11];
				#$SpeciesComp=join(",", @SpecsPerList );
			}
			else 
			{
				$SpecsPerList[1]=$SpecsPerList[1] + 100-$totalpct;
				#$totalpct=$SpecsPerList[1]+$SpecsPerList[3]+$SpecsPerList[5]+$SpecsPerList[7]+$SpecsPerList[9]+$SpecsPerList[11];
			}
			$totalpct=$SpecsPerList[1]+$SpecsPerList[3]+$SpecsPerList[5]+$SpecsPerList[7]+$SpecsPerList[9]+$SpecsPerList[11];
			$SpeciesComp=join(",", @SpecsPerList );
	 	}
	
		if(  $totalpct!=100 &&  $totalpct!= 0) 
		{ 
			$keys="nbf=$nbf  total pctg != 100#"."(".$totalpct.")#".$SpeciesComp;
			$herror{$keys}++; 
		}

	  	for($cpt_ind=0; $cpt_ind<6; $cpt_ind++)
	  	{  
	  		my $posi=$cpt_ind*2;
 	 		if($SpecsPerList[$posi]  eq SPECIES_ERRCODE ) 
 	 		{
 	 		 	$keys="Species$cpt_ind"."#".$SpecsInit[$cpt_ind]."#casid=".$CAS_ID;
				$herror{$keys}++; 
			}
	  	}	
 	  	$SpeciesComp  =  $SpeciesComp .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";		#

  	  	$Origin       =  $row->{PROJ_AGE_CLASS_CD_1}; 
        $OriginHigh   =  UpperOrigin($Origin);
        $OriginLow    =  LowerOrigin($Origin);

	 
	  	if($std_num ne "0007")
	  	{ 
			$Mod1         = $row->{LINE_7B_DISTURBANCE_HISTORY};
 			$Mod2         = $row->{LINE_6_SITE_PREP_HISTORY}; 
	 		$Mod3         = $row->{LINE_8_PLANTING_HISTORY};
	 		if (!isempty($Mod2))
	 		{
				$keys="valid other 2nd disturbance----*".$Mod2;
				$herror{$keys}++;
			}
			if (!isempty($Mod3))
			{
				$keys="valid other 3rd disturbance----*".$Mod3;
				$herror{$keys}++;
			}
	 	}
	 	else 
	 	{
	 		$Mod1=MISSCODE;$Mod1Yr=MISSCODE;
	 	}
	
	 	#if(($OriginHigh  eq MISSCODE   || $OriginLow  eq MISSCODE ) &&  $Sp1 ne "" &&  $Sp1 ne "NULL" && $LayerRank eq "1" ) { 
			#						       $keys="NULL Age"."#".$Origin."#species1#".$Sp1."#LandCC#".$LandCoverClassCode."#disturb#".$Mod1;
		#					     			$herror{$keys}++;									
		#	}
		if($OriginHigh  eq ERRCODE   || $OriginLow  eq ERRCODE) 
		{ 
		    $keys="Origin"."#".$Origin;
			$herror{$keys}++;									
		}
    
		#############TURNING AGE INTO ABSOLUTE YEAR VALUE ################## ##########################
		if ($OriginHigh ne ERRCODE && $OriginHigh ne MISSCODE && $PROJECTED_YEAR ne MISSCODE && $PROJECTED_YEAR ne "0" && !isempty($PROJECTED_YEAR)) 
		{

			if ($OriginHigh ne INFTY ) {$OriginHigh = $PROJECTED_YEAR-$OriginHigh;}
	  		$OriginLow  = $PROJECTED_YEAR-$OriginLow;
			if ($OriginHigh > $OriginLow)
			{ 
				$keys="CHEK ORIGINUPPER-"."#".$Origin."#high=".$OriginHigh."#low=".$OriginLow."#photoyear=".$REF_YEAR."#number".$pr3;
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
		#############      ........\AD\AD\AD.END  OF  TURNING AGE INTO ABSOLUTE YEAR VALUE ###########  #####################
	  
 		if($OriginHigh  >2014     || ($OriginLow <1700 && $OriginLow >0)) 
 		{ 
			print "check origin Year hight = $OriginHigh , low = $OriginLow, both from $Origin\n"; exit;
			$keys="invalid age  "."#originhigh#".$OriginHigh."#originlow#".$OriginLow."#origin#".$Origin."#photoyear#".$REF_YEAR;
			$herror{$keys}++;									
		}

	  	$SiteClass 	=  Site($SiteClass, $INV_version);
	 
	  	$Wetland = WetlandCodes ($NPdesc,$Nfor_desc, $LandCoverClassCode, $MoistReg, $Sp1, $Sp2, $Sp1Per, $CrownClosure, $Height);

	  	# ===== Non-forested Land =====

	  	#NaturallyNonVeg-Anthropogenic-NonForestedVeg-UnProdForest
	  
 	  	#$NPcodedesc	=  NPCodetoNPDesc($NPcode); $NatNonVeg3 =  NaturallyNonVeg($NPcodedesc);$NonVegAnth3  =  Anthropogenic($NPcodedesc); $UnProdFor2 	=  UnProdForest($NPcodedesc); $NonForVeg3 	=  NonForestedVeg($NPcodedesc);

	  	my $IS_NFOR=0;
	  	my $bclcs4=$row->{BCLCS_LEVEL_4};
		$NonVegAnth2=MISSCODE;$NonVegAnth3=MISSCODE;$NatNonVeg2=MISSCODE;$NatNonVeg3=MISSCODE;$NonForVeg2=MISSCODE;$NonForVeg3=MISSCODE;
 	  	if($INV_version eq "V" || $INV_version eq "I") 
 	  	{

			$UnProdFor 	=  MISSCODE;
			
			if(!isempty($Sp1) && ($LandCoverClassCode eq "TM") || ($LandCoverClassCode eq "TC")|| ($LandCoverClassCode eq "TB")|| ($LandCoverClassCode eq "ST")|| ($LandCoverClassCode eq "SL")) 
	  		{$NonForVeg 	= MISSCODE; $NatNonVeg =MISSCODE;  $NonVegAnth=MISSCODE; $UnProdFor 	= "PF";}

			elsif(!isempty($Sp1) && ($bclcs4 eq "TM") || ($bclcs4 eq "TC")|| ($bclcs4 eq "TB")|| ($bclcs4 eq "ST")|| ($bclcs4 eq "SL")) 
	  		{$NonForVeg 	= MISSCODE; $NatNonVeg =MISSCODE;  $NonVegAnth=MISSCODE; $UnProdFor 	= "PF";}

			elsif(isempty($Sp1) && (!isempty($LandCoverClassCode) || !isempty($NonVeg) || !isempty($bclcs4)) ) 	
			{ 
				$NonForVeg 	=  NonForestedVeg($LandCoverClassCode);
				$NatNonVeg2 	=  NaturallyNonVeg($LandCoverClassCode);   
  		 		$NonVegAnth2	=  Anthropogenic($LandCoverClassCode);   

				$NonForVeg2 	=  NonForestedVeg($NonVeg);
				$NatNonVeg 	=  NaturallyNonVeg($NonVeg);   
	  		 	$NonVegAnth	=  Anthropogenic($NonVeg);   

				$NonForVeg3 	=  NonForestedVeg($bclcs4);
				$NatNonVeg3 	=  NaturallyNonVeg($bclcs4);   
	  		 	$NonVegAnth3	=  Anthropogenic($bclcs4); 

		
	 		 	if((($NatNonVeg  eq ERRCODE) && ($NonVegAnth  eq ERRCODE) && ($NonForVeg  eq ERRCODE) && ($NatNonVeg2 eq ERRCODE) && ($NonVegAnth2  eq ERRCODE) && ($NonForVeg2  eq ERRCODE) && ($NatNonVeg3 eq ERRCODE) && ($NonVegAnth3  eq ERRCODE) && ($NonForVeg3  eq ERRCODE)) || (($NatNonVeg  eq MISSCODE) && ($NonVegAnth  eq MISSCODE) && ($NonForVeg  eq MISSCODE) && ($NatNonVeg2  eq MISSCODE) && ($NonVegAnth2  eq MISSCODE) && ($NonForVeg2  eq MISSCODE) && ($NatNonVeg3  eq MISSCODE) && ($NonVegAnth3  eq MISSCODE) && ($NonForVeg3  eq MISSCODE)))
	 		 	{ 

	  				if (defined $Sp1 ) {} else {$Sp1="";}
					$keys="NatNonVeg-NonvegetatedAnth-Nonfor"."#".$NonVeg."#LCCC"."#".$LandCoverClassCode."#bclcs4".$row->{BCLCS_LEVEL_4}."#species is ".$Sp1." and npdesc=".$NPdesc;
					$herror{$keys}++;	
					$NatNonVeg=UNDEF;$NonForVeg =UNDEF;$NonVegAnth=UNDEF;
	  			}
					#if($NonVeg eq "BL" || $NonVeg eq "I" || $NonVeg eq "ER" )
					#{
					#	 $NatNonVeg 	=  MISSCODE;   
	  				#	 $NonVegAnth	=  MISSCODE;   
					#} 
			}
			
			else  {$NonForVeg 	= MISSCODE; $NatNonVeg =MISSCODE;  $NonVegAnth=MISSCODE;}

	  	}
	  	else
	  	{

			$UnProdFor 	=  UnProdForest($Nfor_desc);
			$NonForVeg = MISSCODE; $NatNonVeg= MISSCODE; $NonVegAnth= MISSCODE ;
			
			if ($UnProdFor eq ERRCODE || $UnProdFor eq MISSCODE)
			{
				if(!isempty($Nfor_desc))
				{	
					$keys="Nonfordesc"."#".$Nfor_desc;  $herror{$keys}++;
				}
 				$UnProdFor 	=  UnProdForest($NPdesc);
				$NonForVeg	=  NonForestedVeg($NPdesc);
				$NatNonVeg	=  NaturallyNonVeg($NPdesc);
				$NonVegAnth	=  Anthropogenic($NPdesc);
				
 				if(($UnProdFor  eq ERRCODE) && ($NatNonVeg  eq ERRCODE) && ($NonVegAnth  eq ERRCODE)&& ($NonForVeg  eq ERRCODE) ) 
 				{ 
		 			$keys="UnProdFor-and NN2"."#".$Nfor_desc."#NPdesc".$NPdesc;  $herror{$keys}++;
					#$NatNonVeg=UNDEF;$NonForVeg =UNDEF;$NonVegAnth=UNDEF;$UnProdFor=UNDEF;
				}
			}
			#new to find dropped stands
			if( (($NatNonVeg  eq ERRCODE) && ($NonVegAnth  eq ERRCODE) && ($NonForVeg  eq ERRCODE) && ($UnProdFor  eq ERRCODE)) || (($NatNonVeg  eq MISSCODE) && ($UnProdFor  eq MISSCODE) &&($NonVegAnth  eq MISSCODE) && ($NonForVeg  eq MISSCODE))){ 
	  			if (defined $Sp1 ) {} else {$Sp1="";}

				if(($bclcs4 eq "ST")|| ($bclcs4  eq "SL")) 
	  			{
					$NonForVeg 	= MISSCODE; $NatNonVeg =MISSCODE;  $NonVegAnth=MISSCODE; 
				}

				if(($bclcs4 eq "TM") || ($bclcs4 eq "TC")|| ($bclcs4 eq "TB")|| ($bclcs4 eq "ST")|| ($bclcs4  eq "SL")) 
	  			{
					$NonForVeg 	= MISSCODE; $NatNonVeg =MISSCODE;  $NonVegAnth=MISSCODE; $UnProdFor = "PF";
				}
				elsif(isempty($Sp1))
				{
					$keys="NatNonVeg-nonfordesc="."#".$Nfor_desc."#bclcs4".$row->{BCLCS_LEVEL_4}."#STANDARD F, invversion=".$INV_version." and species is nulland NPdesc=".$NPdesc."*";  								$herror{$keys}++;
				}
	  		}	
			#end new
			if ($NatNonVeg eq ERRCODE) {$NatNonVeg=UNDEF;} if ( $NonForVeg eq ERRCODE) {$NonForVeg =UNDEF;} if ($NonVegAnth eq ERRCODE) {$NonVegAnth=UNDEF;}
 			if ($UnProdFor eq ERRCODE) {$UnProdFor=UNDEF;}
		}

      	if (($NatNonVeg ne MISSCODE && $NatNonVeg ne UNDEF) || ($NonVegAnth ne MISSCODE && $NonVegAnth ne UNDEF) || ($NonForVeg ne MISSCODE && $NonForVeg ne UNDEF)) 
      	{ 
			$IS_NFOR=1;
		}

	  # ===== Modifiers =====   TODO
 
	  	$Mod1Ext      =  UNDEF;  
	
		if ($std_num eq "0007") 
		{
			$Mod1 ="";
			$Mod1Yr="";
		}
		else 
		{
			$Mod1         = $row->{LINE_7B_DISTURBANCE_HISTORY};
			if(length $Mod1 >=3 && !isempty($Mod1))
			{
		 		$Mod1         =  substr $row->{LINE_7B_DISTURBANCE_HISTORY}, 0, 1;
				$Mod1Yr       =  substr $row->{LINE_7B_DISTURBANCE_HISTORY}, 1, 2; 

				if($row->{LINE_7B_DISTURBANCE_HISTORY} =~ /L\%/)
				{
					$keys="Extent1 not handled#"."#".$row->{LINE_7B_DISTURBANCE_HISTORY};
					$herror{$keys}++;
				}
		 		if($Mod1Yr =~ /\D/){
					$Mod1Yr="";
					$Mod1=-1;
					$keys="disturbance"."#".$row->{LINE_7B_DISTURBANCE_HISTORY};
					$herror{$keys}++;
				}
				else { 
					if($Mod1Yr >10) {
							$Mod1Yr= "19".$Mod1Yr;
					}
					else {
							$Mod1Yr= "20".$Mod1Yr;
					}
				}
			}
			elsif(length $row->{LINE_7B_DISTURBANCE_HISTORY} ==1) {
				
				$Mod1 =$row->{LINE_7B_DISTURBANCE_HISTORY};
				$Mod1Yr="";
			}
			elsif($row->{LINE_7B_DISTURBANCE_HISTORY} ne "NULL") {
				$Mod1 ="";
				$Mod1Yr="";
				$keys="disturbance length <3"."#".$row->{LINE_7B_DISTURBANCE_HISTORY};
				$herror{$keys}++;
			}
			else {
			
				$Mod1 ="";
				$Mod1Yr="";
			}
		}

		#second disturbance 

		#if(length $row->{LINE_8_PLA} >=3){
		#	$Mod2         =  substr $row->{LINE_8_PLA}, 0, 1; 
		 #	$Mod2Yr       =  substr $row->{LINE_8_PLA}, 1, 2; 
		#
		#	if($row->{LINE_8_PLA} =~ /L\%/){
		#					$keys="Extent2 not handled#"."#".$row->{LINE_8_PLA};
		#					$herror{$keys}++;
		#	}
		# 	if($Mod2Yr =~ /\D/){
		#		$Mod2Yr="";
		#		$Mod2=-1;
		#		$keys="disturbance"."#".$row->{LINE_8_PLA};
		#		$herror{$keys}++;
		#	}
		#	else { 
		#		if($Mod2Yr >10) {
		#					$Mod2Yr= "19".$Mod2Yr;
		#		}
		#		else {
		#					$Mod2Yr= "20".$Mod2Yr;
		#		}
		#	}
		#}
		#elsif(length $row->{LINE_8_PLA} ==1) {
		#	$Mod2 =$row->{LINE_8_PLA};
		#	$Mod2Yr="";
		#}
		#elsif($row->{LINE_8_PLA} ne "") {
		#	$Mod2 ="";
		#	$Mod2Yr="";
		#	$keys="disturbance length <3"."#".$row->{LINE_8_PLA};
		#	$herror{$keys}++;
		#}
		#else {
		#	$Mod2 ="";
		#	$Mod2Yr="";
		#}
	 
		#$Mod2 =UNDEF; $Mod1 =UNDEF;
		#$Mod2Yr=UNDEF;	$Mod1Yr=UNDEF;	
		# $Mod1="";
		#if($Mod1 eq "N" && defined $row->{EARLIEST_NONLOGGING_DIST_TYPE} && length $row->{EARLIEST_NONLOGGING_DIST_TYPE} >1){  #EARLIEST_N
		#	$Mod1= substr $row->{EARLIEST_NONLOGGING_DIST_TYPE}, 1,1;
		#}
		
	  	$Dist1 = Disturbance($Mod1, $Mod1Yr);
	  	($Cd1, $Cd2)=split(",", $Dist1);
	 	if($Cd1 eq ERRCODE) 
	 	{  
			$keys="Disturbance1"."#---".$Mod1."***earliest#".$row->{HARVEST_DATE};
			$herror{$keys}++; 
	  	}
	
		$Dist1ExtHigh  =  UNDEF;
		$Dist1ExtLow   =  UNDEF;
        # $Dist1ExtHigh  =  DisturbanceExtUpper($Mod1Ext);
        # $Dist1ExtLow   =  DisturbanceExtLower($Mod1Ext);
        $Dist1 = $Dist1 . "," . $Dist1ExtHigh . "," . $Dist1ExtLow;
        $Dist2 = UNDEF . "," .UNDEF. "," .UNDEF . "," .UNDEF;
        # $Dist3 = $Dist3 . "," . $Dist3ExtHigh . "," . $Dist3ExtLow;
        $Dist = $Dist1 . "," . $Dist2. "," . UNDEF. "," .UNDEF. "," .UNDEF. "," .UNDEF;


		# ======================================================= WRITING Output inventory info IN CAS FILES =======================================================================================================
		my $prod_for="PF";
		my $lyr_poly=1;
		if(isempty($Sp1) || $SpeciesComp eq "-1" || $SpeciesComp eq "")
		{
			$SpeciesComp="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
			if ( !is_missing($CCHigh) ||  !is_missing($CCLow) || !is_missing($HeightHigh) || !is_missing($HeightLow))  
			{
				$prod_for="PP";
				$SpeciesComp="UNDEF,0,UNDEF,0,UNDEF,0,UNDEF,0,UNDEF,0,UNDEF,0,UNDEF,0,UNDEF,0,UNDEF,0,UNDEF,0";
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
		if (!is_missing($UnProdFor))
		{
			#new rule from Melina and Steve
			$prod_for="PP";
			if($UnProdFor eq "SD")
			{
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
		if($ucsp1 eq "XC" || $ucsp1 eq "XH" || $ucsp1 eq "ZC" || $ucsp1 eq "ZH")
		{
			if(isempty($Nfor_desc))
			{
				$prod_for = "PP";
			}
			else 
			{
				$prod_for = "NP";
			}
		}

		if ($invstd eq "F" && $Hdr_F_set==0)
		{
			$Hdr_F_set=1;
			print CASHDR $HDR_RecordF . "\n";
		}
		elsif ($invstd eq "V" && $Hdr_V_set==0)
		{
			#print "invent is $invstd and hdrset = $Hdr_V_set\n"; 
			$Hdr_V_set=1;
			print CASHDR $HDR_RecordV . "\n";
		}
		elsif ($invstd eq "I" && $Hdr_I_set==0)
		{
			$Hdr_I_set=1;
			print CASHDR $HDR_RecordI . "\n";
		}



        $CAS_Record = $CAS_ID . "," . $StandID . "," . $StandStructureCode. "," .$NumLayers.",". $IdentifyID . "," . $MapSheetID . "," . $Area . "," . $Perimeter . ",".$Area. ",".$PHOTO_YEAR;
	    print CASCAS $CAS_Record . "\n";
		$nbpr=1;$$ncas++;$ncasprev++;


	    $isNFL=1;
	    if ($invstd eq "V" || $invstd eq "I")
	    {
 			if (($NatNonVeg ne MISSCODE && $NatNonVeg ne UNDEF) || ($NonVegAnth ne MISSCODE && $NonVegAnth ne UNDEF) || ($NonForVeg ne MISSCODE && $NonForVeg ne UNDEF)){
			#if ($NatNonVeg ne MISSCODE || $NonVegAnth ne MISSCODE || $NonForVeg ne MISSCODE){
				$NFL_Record3 = $NatNonVeg . "," . $NonVegAnth . "," . $NonForVeg;
			}
			elsif (($NatNonVeg2 ne MISSCODE && $NatNonVeg2 ne UNDEF) || ($NonVegAnth2 ne MISSCODE && $NonVegAnth2 ne UNDEF) || ($NonForVeg2 ne MISSCODE && $NonForVeg2 ne UNDEF)){
			#elsif ($NatNonVeg2 ne MISSCODE || $NonVegAnth2 ne MISSCODE || $NonForVeg2 ne MISSCODE){
				$NFL_Record3 = $NatNonVeg2 . "," . $NonVegAnth2 . "," . $NonForVeg2;
			}
			elsif (($NatNonVeg3 ne MISSCODE && $NatNonVeg3 ne UNDEF) || ($NonVegAnth3 ne MISSCODE && $NonVegAnth3 ne UNDEF) || ($NonForVeg3 ne MISSCODE && $NonForVeg3 ne UNDEF)){
			#elsif ($NatNonVeg3 ne MISSCODE || $NonVegAnth3 ne MISSCODE || $NonForVeg3 ne MISSCODE){
				$NFL_Record3 = $NatNonVeg3 . "," . $NonVegAnth3 . "," . $NonForVeg3;
			}
			else {$isNFL=0;}
	    }
	    elsif ($invstd eq "F" )
	    {
 		
			if (($NatNonVeg ne MISSCODE && $NatNonVeg ne UNDEF) || ($NonVegAnth ne MISSCODE && $NonVegAnth ne UNDEF) || ($NonForVeg ne MISSCODE && $NonForVeg ne UNDEF)){
			#if ($NatNonVeg ne MISSCODE || $NonVegAnth ne MISSCODE || $NonForVeg ne MISSCODE){
				$NFL_Record3 = $NatNonVeg . "," . $NonVegAnth . "," . $NonForVeg;
			}
			else {$isNFL=0;}
	    }
	    else {print "standard not V,I nor F; check it!\n"; exit;}



	    if (defined $Sp1 ) {} else {$Sp1="";}  if (defined $Sp2 ) {} else {$Sp2="";}
        #layer 1
        #if (!isempty($Sp1) || ($UnProdFor ne MISSCODE && $UnProdFor ne ERRCODE && $UnProdFor ne UNDEF)) {
		if (!isempty($Sp1) || $lyr_poly==1) 
		{
	     	$LYR_Record1 = $CAS_ID . "," . $SMR  . "," . $StandStructureVal . "," .$LayerId.",". $LayerRank;  #old ",1,1"  -change on july 2014
	      	$LYR_Record2 = $CCHigh . "," . $CCLow . "," . $HeightHigh . "," . $HeightLow . "," . $prod_for.",".$SpeciesComp;
	      	$LYR_Record3 = $OriginHigh . "," . $OriginLow . "," . $SiteClass . "," . $SiteIndex;
	      	$Lyr_Record = $LYR_Record1 . "," . $LYR_Record2 . "," . $LYR_Record3;
	      	print CASLYR $Lyr_Record . "\n";
 			$nbpr++; $$nlyr++;$nlyrprev++;
 			#print "voici $LYR_Record3\n";
		}

        elsif ( $isNFL==1) 
        { 
            $NFL_Record1 = $CAS_ID . "," . $SMR  . "," . $StandStructureVal . "," .$LayerId.",". $LayerRank;  #old ",1,1"  -change on july 2014
            $NFL_Record2 = $CCHigh . "," . $CCLow . "," . MISSCODE . "," . MISSCODE;
            $NFL_Record3 = $NatNonVeg . "," . $NonVegAnth . "," . $NonForVeg;
            $NFL_Record = $NFL_Record1 . "," . $NFL_Record2 . "," . $NFL_Record3;
            print CASNFL $NFL_Record . "\n";
	      	$nbpr++;$$nnfl++;$nnflprev++;
		}
		#else {print "NFL null --- codes2 ::: natnonveg---$NatNonVeg2--- NonvegAnth---$NonVegAnth2--- nonforveg---$NonForVeg2---\n"}
               # elsif ($Sp1 eq "") {print "NFL null ---  ::: species 1 null--$CAS_ID\n"; }
		######################## other layer
		######################end 

	   	if (!isempty($Mod1) && $Cd1 ne ERRCODE) 
	   	{
		    $DST_Record = $CAS_ID . "," . $Dist. ",". $LayerId;  #June 2014 --- newly added, layer fiel in .dst record
		    print CASDST $DST_Record . "\n";
			if($nbpr==1) {$$ndstonly++; $ndstonlyprev++;}
			$nbpr++;$$ndst++;$ndstprev++;
	   	}

		$Ecosite="-";
		if(defined $row->{BEC_ZONE_CODE} )
		{
			if( !isempty($row->{BEC_ZONE_CODE}))
			{
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
	    if ($Wetland ne MISSCODE) 
	    {
	    	$Wetland = $CAS_ID . "," . $Wetland.$Ecosite;
	      	print CASECO $Wetland . "\n";
			if($nbpr==1) {$$necoonly++;$necoonlyprev++;}
			$nbpr++;$$neco++;$necoprev++;
	    }

		if($nbpr ==1 )
		{

			$ndrops++;
			if($temp2 ne "")
			{
				if($INV_version eq "V" || $INV_version eq "I") 
				{
			 		if(defined $BC_Areatracking{$CAS_ID}) 
			 		{
						$$temp3+=$Area; $missing_area+=$Area;
						print MISSING_STANDS "$CAS_ID, LYR from $$SpComp, NFL from $LandCoverClassCode and $NonVeg, wetland= $Wetland, DST from $Mod1 >>>file=$Glob_filename \n"; 
					}
		    	}
		    	else 
		    	{	
		    		if(defined $BC_Areatracking{$CAS_ID})
		    		{
						$$temp3+=$Area; $missing_area+=$Area;
						print MISSING_STANDS "$CAS_ID, LYR from $$SpComp, NFL from $NPdesc, wetland= $Wetland, DST from $Mod1 >>>file=$Glob_filename \n";
					}
		    	}
			}
        }
	}

  	$csv->eof or $csv->error_diag ();
 	 close $BCinv;

	print MISSING_STANDS "###########total area missed in this file = $missing_area,  cumul= $$temp3\n";

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
	 
    #close (BCinv);
	close (CASHDR);
	close (CASCAS);
	close (CASLYR);
	close (CASNFL);
	close (CASDST);
	close (CASECO);
	close(ERRS);	
	close(SPECSLOGFILE); 
	close(SPERRSFILE);
	close(MISSING_STANDS);

	$total=$nlyrprev+ $nnflprev+  $ndstprev;
	$total2=$nlyrprev+ $nnflprev+  $ndstonlyprev + $necoonlyprev;
	print " ndrops =$ndrops, nb current records in: casfile = $ncasprev, lyrfile = $nlyrprev, nflfile = $nnflprev,  dstfile = $ndstprev($ndstonlyprev), ecofile = $necoprev($necoonlyprev)--- total (without .cas): $total($total2)\n";
}

1;

