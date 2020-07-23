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


# $Wetland = WetlandCodes ($NPdesc,$Nfor_desc, $LandCoverClassCode, $MoistReg, $Sp1, $Sp2, $Sp1Per, $CrownClosure, $Height);
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
