package ModulesV4::NB_conversion08;


use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(&NBinv_to_CAS );
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
#Moisture is not defined
#structure is S

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

#Site is not defined in the CAS doc but it is defined in the document provided by Melina field is SITE1
sub Site 
{
	my $Site;
	my $TPR; my $isComFor;
	my %TPRList = ("", 1, "p", 1, "f", 1, "w", 1, "d", 1,  "P", 1, "F", 1, "W", 1,  "D",1); #w,b=r,d

	($TPR) = shift(@_);
	($isComFor) = shift(@_);

	if  (isempty($TPR))                                      { $Site = MISSCODE; }
	elsif (!$TPRList {$TPR} ) { $Site = ERRCODE; }
	elsif (($TPR eq "p") || ($TPR eq "P"))                   { $Site = "P"; }
	elsif (($TPR eq "f") || ($TPR eq "F"))                   { $Site = "P"; }
	elsif (($TPR eq "w") || ($TPR eq "W"))                   { $Site = "P"; }
	elsif (($TPR eq "d") || ($TPR eq "D"))                   { $Site = "P"; }
	
	return $Site;
}
 
#Determine CCUpper from Crown Closure 
#2003 standard
sub CCUpper 
{
	my $CCHigh="";
	my $Density;
	my $ComFor;my $Wkg;
	my %DensityList = ("", 1, "0", 1, "1", 1, "2", 1, "3", 1, "4", 1, "5", 1, "6",1, "61", 1, "62", 1, "63", 1, "64", 1);

	($Density) = shift(@_); 
	 

	if (isempty($Density))               { $CCHigh = MISSCODE; }
	elsif (!$DensityList {$Density} )  {$CCHigh= ERRCODE; }
	
	elsif (($Density eq "5") || ($Density eq "6") )         { $CCHigh = 100; }
	elsif (($Density eq "4") ||($Density eq "64"))         { $CCHigh = 90; }
	elsif (($Density eq "3") ||($Density eq "63"))         { $CCHigh = 70; }
	elsif (($Density eq "2") ||($Density eq "62"))         { $CCHigh = 50; }
	elsif (($Density eq "1") ||($Density eq "61"))         { $CCHigh = 30; }
	elsif (($Density eq "0") )         { $CCHigh = MISSCODE; } #$CCHigh = 10;
	else   { $CCHigh = ERRCODE; }
	
	return $CCHigh;
}

#Determine CCLower from CC
sub CCLower 
{
	my $CCLow="";
	my $Density;
	my $ComFor; my $Wkg;
	my %DensityList = ("", 1, "0", 1, "1", 1, "2", 1, "3", 1, "4", 1, "5", 1, "6",1, "61", 1, "62", 1, "63", 1, "64", 1);

	($Density) = shift(@_); 
	
	if (isempty($Density))               { $CCLow = MISSCODE; }
	elsif (!$DensityList {$Density} )  {$CCLow = ERRCODE; }

	elsif (($Density eq "5")|| ($Density eq "6"))         { $CCLow = 91; }
	elsif (($Density eq "4") ||($Density eq "64"))         { $CCLow = 71; }
	elsif (($Density eq "3") ||($Density eq "63"))         { $CCLow = 51; }
	elsif (($Density eq "2") ||($Density eq "62"))         { $CCLow = 31; }
	elsif (($Density eq "1") ||($Density eq "61"))         { $CCLow = 11; }
	elsif (($Density eq "0") )         { $CCLow = MISSCODE; } #$CCLow = 1;
	else   { $CCLow = ERRCODE; }
	return $CCLow;
}


#Determine stand height
#pre2003 incorporated in site and age class data
#2003 actual value
sub StandHeightUp 
{
	my $Height;
	my $Height2;
	my $HeightHigh;
	
	($Height) = shift(@_);
	($Height2) = shift(@_);
	
	if  (isempty($Height) || $Height eq "0")    { $HeightHigh  = MISSCODE; }
	elsif ($Height <0 ){ $HeightHigh = ERRCODE; }
	elsif  ($Height == 0)    { $HeightHigh  = MISSCODE; }
	else
	{
		$HeightHigh = $Height+0.5; 
	}

	if($HeightHigh  eq MISSCODE) 
	{

		if  (isempty($Height2) || $Height2 eq "0")    { $HeightHigh  = MISSCODE; }
		elsif ($Height2 == 1) { $HeightHigh = 1; }
		elsif ($Height2 == 2) { $HeightHigh = 3; }
		elsif ($Height2 == 3) { $HeightHigh = 5; }
		elsif ($Height2 == 4) { $HeightHigh = 7; }
		elsif ($Height2 == 5) { $HeightHigh = INFTY; }
	}
	return $HeightHigh;
}



#Determine lower stand origin from L1HT
sub StandHeightLow 
{
	my $Height;my $Height2;my $HeightLow;
	
	($Height) = shift(@_);
	($Height2) = shift(@_);

	if  (isempty($Height) || $Height eq "0")    { $HeightLow  = MISSCODE; }
	elsif ($Height <0 ) { $HeightLow =ERRCODE; }
	elsif  ($Height == 0)    { $HeightLow  = MISSCODE; }
	elsif  ( $Height < 0.5)    { $HeightLow  = 0; }
	else
	{
		$HeightLow= $Height-0.5; 
	}
	if($HeightLow  eq MISSCODE) 
	{
		if  (isempty($Height2) || $Height2 eq "0")    { $HeightLow  = MISSCODE; }
		elsif ($Height2 == 1) { $HeightLow = 0; }
		elsif ($Height2 == 2) { $HeightLow = 1; }
		elsif ($Height2 == 3) { $HeightLow = 3; }
		elsif ($Height2 == 4) { $HeightLow = 5; }
		elsif ($Height2 == 5) { $HeightLow = 7; }
	}
	
	return $HeightLow;
}

#Age for 2003 standard                                    121-INFINITY			
#Determine upper stand origin from Age
#
sub match
{

	my $species = shift(@_);
	#the following have been added by SGC
	
	my %match_rule =
	(

		"AL" => "IH",
		"AP" => "JP",
		"AS" => "TH",
		"BE" => "TH",
		"BI" => "IH",
		"EB" => "IH",
		"EL" => "TL",
		"JL" => "TL",
		"NS" => "WS",
		"O" => "TH",
		"OH" => "TH",
		"OS" => "EH",
		"PI" => "JP",
		"PO" => "IH",
		"PS" => "JP",
		"SF" => "BS",
		"SM" => "RM",
		"SP" => "BS",
		"WB" => "IH",
		"YB" => "TH",
		"SM" => "TH",
		"SP" => "BS",
		"WB" => "IH",
		"YB" => "TH",
		"FD" => "WS",
		"NC" => "IH",
	);	

	if(exists $match_rule{$species})
	{
		$species = $match_rule{$species}; 
	}
	return $species;

		
}

sub ULOrigin
{
	my $Origin;
	my $species;
	my $OriginHigh="";
	my %OriginList = ("R", 1, "S", 1, "Y", 1, "I", 1, "M", 1, "O", 1); 
	my $search_val;
	my $OriginLow;



	my %bound_origin = 
	(
		"BF_R" => "0-12",
		"BF_S" => "10-25",
		"BF_Y" => "20-35",
		"BF_I" => "30-50",
		"BF_M" => "45-70",	
		"BF_O" => "65-INFTY",

		"FS_R" => "0-12",
		"FS_S" => "10-25",
		"FS_Y" => "20-35",
		"FS_I" => "30-50",
		"FS_M" => "45-70",	
		"FS_O" => "65-INFTY",

		"RS_R" => "0-12",
		"RS_S" => "10-30",
		"RS_Y" => "25-45",
		"RS_I" => "40-70",
		"RS_M" => "65-110",
		"RS_O" => "105-INFTY",


		"BS_R" => "0-12",
		"BS_S" => "10-30",
		"BS_Y" => "25-45",
		"BS_I" => "40-70",
		"BS_M" => "65-110",
		"BS_O" => "105-INFTY",

		"WS_R" => "0-10",
		"WS_S" => "8-20",
		"WS_Y" => "15-40",
		"WS_I" => "35-60",
		"WS_M" => "55-110",
		"WS_O" => "105-INFTY",

		"WP_R" => "0-12",
		"WP_S" => "10-30",
		"WP_Y" => "25-50",
		"WP_I" => "45-90",
		"WP_M" => "85-160",
		"WP_O" => "155-INFTY",


		"JP_R" => "0-10",
		"JP_S" => "8-20",
		"JP_Y" => "15-40",
		"JP_I" => "35-70",
		"JP_M" => "65-110",
		"JP_O" => "105-INFTY",


		"RP_R" => "0-10",
		"RP_S" => "8-20",
		"RP_Y" => "15-40",
		"RP_I" => "35-70",
		"RP_M" => "65-110",
		"RP_O" => "105-INFTY",

		"EC_R" => "0-12",
		"EC_S" => "10-30",
		"EC_Y" => "25-45",
		"EC_I" => "40-70",
		"EC_M" => "65-110",
		"EC_O" => "105-INFTY",

		"EH_R" => "0-12",
		"EH_S" => "10-30",
		"EH_Y" => "25-50",
		"EH_I" => "45-90",
		"EH_M" => "85-140",
		"EH_O" => "135-INFTY",

		"TL_R" => "0-10",
		"TL_S" => "8-20",
		"TL_Y" => "15-45",
		"TL_I" => "40-70",
		"TL_M" => "65-110",
		"TL_O" => "105-INFTY",

		"TH_R" => "0-12",
		"TH_S" => "10-30",
		"TH_Y" => "25-50",
		"TH_I" => "45-80",
		"TH_M" => "75-160",
		"TH_O" => "155-INFTY",


		"RM_R" => "0-12",
		"RM_S" => "10-25",
		"RM_Y" => "20-45",
		"RM_I" => "40-70",
		"RM_M" => "65-110",
		"RM_O" => "105-INFTY",


		"IH_R" => "0-10",
		"IH_S" => "8-20",
		"IH_Y" => "15-35",
		"IH_I" => "30-50",
		"IH_M" => "45-70",
		"IH_O" => "65-INFTY",

		"GB_R" => "0-8",
		"GB_S" => "5-15",
		"GB_Y" => "10-25",
		"GB_I" => "20-40",
		"GB_M" => "35-50",
		"GB_O" => "45-INFTY",
	);

	($Origin) = shift(@_);
	($species) = shift(@_);

	if (isempty($species)) {$species = "";}

	if(isempty($Origin)) {return (MISSCODE, MISSCODE); }

	elsif ($OriginList {$Origin} )   
	{
		

		$search_val = match($species)."_".uc($Origin);
		if(exists $bound_origin{$search_val} )
		{
			($OriginLow, $OriginHigh) = split("-", $bound_origin{$search_val});
			return ($OriginLow, $OriginHigh);
		}
		else 
		{
			return (UNDEF, UNDEF); 
		}
	}
	else
	{
		return (ERRCODE, ERRCODE); 
	}
}


sub OriginUpper 
{
	my $Origin;
	my $species;
	my $OriginHigh="";
	my %OriginList = ( "2", 1, "3", 1, "4", 1, "5", 1, "6",1, "7", 1, "8", 1, "9", 1); #

	($Origin) = shift(@_);
	($species) = shift(@_);

	if (isempty($species)) {$species = "";}

	if(isempty($Origin)) {$OriginHigh  = MISSCODE; }
	
	elsif ($OriginList {$Origin} )  #list from Melina SP, bS, rS, NS, RP, SF, SP and wS  ///////////////Spruce (bS, wS, rS, NS, RP, SF, SP)
	{ 
		
		if( $species eq "BS" || $species eq "DS" || $species eq "NS" || $species eq "RS" || $species eq "SF" || $species eq "SP" || $species eq "WS" || $species eq "RP") #|| $species eq "FS"
		{
			if  ($Origin eq "2" )   { $OriginHigh  = 30; }
			elsif ($Origin eq "3" ) { $OriginHigh = 45; }
			elsif ($Origin  eq "4") { $OriginHigh = 60; }
			elsif ($Origin  eq "5") { $OriginHigh = 75; }
			elsif ($Origin  eq "6") { $OriginHigh = 90; }
			elsif ($Origin  eq "7") { $OriginHigh = 105; }
			elsif ($Origin  eq "8") { $OriginHigh = 120; }
			elsif ($Origin  eq "9") { $OriginHigh = INFTY; }
			else {$OriginHigh  = MISSCODE; }
		}
		elsif( $species eq "BF"  || $species eq "FS") 
		{
			if ($Origin eq "3" ) { $OriginHigh = 30; }
			elsif ($Origin  eq "4") { $OriginHigh = 40; }
			elsif ($Origin  eq "5") { $OriginHigh = 50; }
			elsif ($Origin  eq "6") { $OriginHigh = 60; }
			elsif ($Origin  eq "7") { $OriginHigh = 70; }
			elsif ($Origin  eq "8") { $OriginHigh = INFTY; }
			# elsif ($Origin  eq "R") { $OriginHigh = 12; }
			# elsif ($Origin  eq "S") { $OriginHigh = 25; }
			# elsif ($Origin  eq "Y") { $OriginHigh = 35; }
			# elsif ($Origin  eq "I") { $OriginHigh = 50; }
			# elsif ($Origin  eq "M") { $OriginHigh = 70; }
			# elsif ($Origin  eq "O") { $OriginHigh = INFTY; }
				
			else {$OriginHigh  = MISSCODE; }	 
		}
    } 
    else 
    {
    	$OriginHigh  = ERRCODE; 
    }
	return $OriginHigh;
}

#2 Age class (years) for spruce of 16 to 30
#3 Age class (years) for balsam fir of 21 to 30 and for spruce of 31 to 45
#4 Age class (years) for balsam fir of 31 to 40 and for spruce of 46 to 60
#5 Age class (years) for balsam fir of 41 to 50 and for spruce of 61 to 75
#6 Age class (years) for balsam fir of 51 to 60 and for spruce of 76 to 90
#7 Age class (years) for balsam fir of 61 to 70 and for spruce of 91 to 105
#8 Age class (years) for balsam fir of 71+ and for spruce of 106 to 120
#9 Age class (years) for spruce of 121+

#Determine lower stand origin from L1HT
sub OriginLower 
{
	my $Origin; my $species;my $OriginLow;
	
	my %OriginList = (  "2", 1, "3", 1, "4", 1, "5", 1, "6",1, "7", 1, "8", 1, "9", 1); #

	($Origin) = shift(@_);
	($species) = shift(@_);	

	if (isempty($species)) {$species = "";}

	if (isempty($Origin)) {$OriginLow  = MISSCODE; }
	elsif ($OriginList {$Origin} ) 
	{ 
		if( $species eq "BS" || $species eq "DS" || $species eq "NS" || $species eq "RS" || $species eq "SF" || $species eq "SP" || $species eq "WS"  || $species eq "RP") #|| $species eq "FS"
		{
			if  ($Origin eq "2")   { $OriginLow  = 16; }
			elsif ($Origin eq "3") { $OriginLow = 31; }
			elsif ($Origin eq "4") { $OriginLow = 46; }
			elsif ($Origin eq "5") { $OriginLow = 61; }
			elsif ($Origin eq "6") { $OriginLow = 76; }
			elsif ($Origin eq "7") { $OriginLow = 91; }
			elsif ($Origin eq "8") { $OriginLow = 106; }
			elsif ($Origin eq "9") { $OriginLow = 121; }
			else {$OriginLow  = MISSCODE; }
		}
		elsif( $species eq "BF" || $species eq "FS") 
		{
			if ($Origin eq "3") { $OriginLow = 21; }
			elsif ($Origin eq "4") { $OriginLow = 31; }
			elsif ($Origin eq "5") { $OriginLow = 41; }
			elsif ($Origin eq "6") { $OriginLow = 51; }
			elsif ($Origin eq "7") { $OriginLow = 61; }
			elsif ($Origin eq "8") { $OriginLow = 71; }
			else {$OriginLow  = MISSCODE; }
		}
		else 
		{
			$OriginLow  = ERRCODE; 
		}
   	}
	else 
	{
	   $OriginLow  = ERRCODE; 
	}
	return $OriginLow;
}

sub UpperOrigin 
{
	my $Origin;
	my $OriginHigh;
	($Origin) = shift(@_);
	
	if  (isempty($Origin) || $Origin eq "0") { $OriginHigh  = MISSCODE; }
	elsif (($Origin >1))  	          { $OriginHigh = $Origin; }
	else   { $OriginHigh = ERRCODE; }

	return $OriginHigh;
}


sub LowerOrigin 
{
	my $Origin;
	my $OriginLow;
	
	($Origin) = shift(@_);
	

	if  (isempty($Origin) || $Origin eq "0")     { $OriginLow  = MISSCODE; }
	elsif (($Origin > 1))  	          { $OriginLow = $Origin; }
	else   { $OriginLow = ERRCODE }
	 
	return $OriginLow;
}


sub Latine 
{
	my $CurrentSpecies = shift(@_);
	my $GenusSpecies;

	

	if (isempty($CurrentSpecies))   
	{ 
		$GenusSpecies = "XXXX MISS"; 
	}
	else 
	{
		$_ = $CurrentSpecies;
		tr/a-z/A-Z/; s/\s//g;
		$CurrentSpecies = $_;
		$CurrentSpecies =~ s/\s//g;

		if ($Species_table->{$CurrentSpecies}) { $GenusSpecies = $Species_table->{$CurrentSpecies}; }
		else {$GenusSpecies = SPECIES_ERRCODE;  print SPECSLOGFILE "Illegal species code -$CurrentSpecies-,CAS_ID=$Glob_CASID,file=$Glob_filename\n";  } 
	}

	return $GenusSpecies;
}


#Determine Species from the 5 Species fields
#5 Species	FST1 (all merchantable)  FST2 (with unmerchantable understory)  FST3 (no merchantable component), non-productive forest does not identify species beyond hardwood/ softwood	
									
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
	my $spfreq =shift(@_);

	my $Species;
	my $CurrentSpec; my $Totalperctg=0;

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
	

	my $spper1=$Sp1Per*10;my $spper2=$Sp2Per*10;my $spper3=$Sp3Per*10;my $spper4=$Sp4Per*10;my $spper5=$Sp5Per*10;

	$Totalperctg=$spper1 + $spper2 +$spper3+$spper4+$spper5;
	
	if(($Totalperctg ==100 || $Totalperctg ==90 )){
						#$Sp1 = Latine($Sp1); $Sp2 = Latine($Sp2); $Sp3 = Latine($Sp3); $Sp4 = Latine($Sp4); $Sp5 = Latine($Sp5);
						if($Totalperctg ==90 ){
									$spper1=$spper1+10;
						}					
	}
	elsif($Totalperctg ==60 && $Sp1 eq "BF" && $Sp2 eq "RM" && $spper1==20 && $spper2==0){
				$spper1=40;
				$spper2=20;
	}
	elsif($Totalperctg ==70 && $Sp1 eq "BS" && $Sp2 eq "TL" && $spper1==40 && $spper2==0){
				$spper1=40;
				$spper2=30;
	}
	elsif($Totalperctg ==80 && $spper1==80){
				$spper1=100;	 
	}
	elsif($Totalperctg ==80 && $Sp1 eq "SP" && $Sp2 eq "BF" && $spper1==50 && $spper2==30){
				$spper1=70;
				$spper2=30;  #SP#5#BF#3##0##0##0,8, found 9 times,,SP#7#BF#3##0##0##0
	}
	elsif($Totalperctg ==80 && $spper1==40 && $spper2==40){
				$spper1=60;	 
	}
	elsif($Totalperctg ==80 && $spper1==30 && $spper2==30 && $spper2==20){
				$spper1=50;	 
	}
	elsif($Totalperctg ==80){
				$spper1=$spper1+10;	
				$spper2=$spper2+10;	 
	}
	elsif($Totalperctg ==120 &&  $spper3==20 && $spper4==20 && $spper5==0){
				$spper3=10; 
				$spper4=10; 
	}
	elsif($Totalperctg ==110)
	{
		if( $spper5>10)
		{
			$spper5=$spper5-10; 
		}
		elsif( $spper4>10)
		{
			$spper4=$spper4-10; 
		}
		elsif( $spper3>10)
		{
			$spper3=$spper3-10; 
		}
		elsif( $spper1>10)
		{
			$spper1=$spper1-10; 
		}
	}
	else 
	{
		return (-1);
	}

	#if($Totalperctg ==100 && $spper5==0){$Sp5= "XXXX UNDF";}

	$spfreq->{$Sp1}++;$spfreq->{$Sp2}++;$spfreq->{$Sp3}++;$spfreq->{$Sp4}++;$spfreq->{$Sp5}++;
	$Sp1 = Latine($Sp1); $Sp2 = Latine($Sp2); $Sp3 = Latine($Sp3); $Sp4 = Latine($Sp4); $Sp5 = Latine($Sp5);
	$Species = $Sp1 . "," . $spper1 . "," . $Sp2 . "," . $spper2 . "," . $Sp3 . "," . $spper3 . "," . $Sp4 . "," . $spper4. "," . $Sp5 . "," . $spper5 ;
	return $Species;
}

#Site is UNDEF
#height is nearest 1m

 #Natnonveg ==== AP, LA, RI, OC, RK, SA, SI, SL, EX, BE, WS, FL, IS, TF

 #LK=LA     SL=LA       PN=LA  
#ON=OC    AB=WS RF=WS DU=SD 
#RK =RK RO=RK
#RV= RI 
#BC=BE	 
#FW=FL	
#TF=TF                
#SB=SL
#BL=EX

#AI-AR-BA-BL-CB-CG-CH-CL-CO-CS-CT-EA-FD-FP-FW-GC-GP-IP-IZ-LE-LF-MI-PA-PB-PP-PR-QU-RD-RF-RO-RR-RU-RY-SG-SK-TM-TR-UR-WR
#WATER_CODE LK-ON-AQ-PN-RB-RT-RV-SL-WA
sub NaturallyNonVeg
{
	my $NatNonVeg;my $NatNonVegRes;
	my %NatNonVegList = ("", 1, "LK", 1, "SL", 1, "RT", 1,"PN", 1, "WA", 1, "AQ", 1, "RB", 1, "ON", 1, "AB", 1, "RF", 1,"DU", 1, "RK", 1, "RO", 1,"RV", 1, "BC", 1, "FW", 1, "TF", 1, "SB", 1, "BL", 1);

	($NatNonVeg) = shift(@_);
	if  (isempty($NatNonVeg))					{ $NatNonVegRes = MISSCODE; }
	elsif (!$NatNonVegList {$NatNonVeg} )  { $NatNonVegRes = ERRCODE; }

	elsif (($NatNonVeg eq "LK")||($NatNonVeg eq "SL")||($NatNonVeg eq "PN")||($NatNonVeg eq "AQ"))	{ $NatNonVegRes = "LA"; }
	elsif (($NatNonVeg eq "RB")||($NatNonVeg eq "RT")||($NatNonVeg eq "WA"))	{ $NatNonVegRes = "LA"; }
	elsif (($NatNonVeg eq "ON"))	{ $NatNonVegRes = "OC"; }
	elsif (($NatNonVeg eq "AB")||($NatNonVeg eq "RF"))	{ $NatNonVegRes = "WS"; } 
	elsif (($NatNonVeg eq "RK")||($NatNonVeg eq "RO"))	{ $NatNonVegRes = "RK"; } 
	elsif (($NatNonVeg eq "RV"))	{ $NatNonVegRes = "RI"; }
	elsif (($NatNonVeg eq "BC"))	{ $NatNonVegRes = "BE"; }
	elsif (($NatNonVeg eq "FW"))	{ $NatNonVegRes = "FL"; }
	elsif (($NatNonVeg eq "TF"))	{ $NatNonVegRes = "TF"; }
	elsif (($NatNonVeg eq "SB"))	{ $NatNonVegRes = "SL"; }
	elsif (($NatNonVeg eq "BL"))	{ $NatNonVegRes = "EX"; }
	else 				{ $NatNonVegRes = ERRCODE; }
	return $NatNonVegRes;
}
#Anthropogenic IN, FA, CL, SE, LG, BP, OT

#BA=FA   AI=FA  EA=FA   RD=FA   TR=FA  TM=FA    IZ=FA  PP=FA   SK=FA	AR=FA   CG=FA    PA=FA	   GC=FA CS=FA   RR=FA      LE=FA          RY=FA
#UR=SE	 RU=SE         	 	                          
#IP=IN     GP=IN     QU=IN  LF=IN     MI=IN   PB=IN                                             	                                                           
#SG=LG
#CO=CL    FP=CL   FD=CL    CB=CL    CL=CL     CH=CL   CT=CL

#must verify PR code with Steve
sub Anthropogenic 
{
	my $NonForAnth = shift(@_); my $NonForAnthRes;
	my %NonForAnthList = ("", 1, "BA", 1, "AI", 1, "EA", 1, "RD", 1, "WR",1, "TR", 1, "TM", 1, "IZ", 1, "PP", 1, "SK", 1, "AR", 1, "CG", 1, "PA", 1, "GC", 1, "CS", 1, "RR", 1,"LE", 1,"RY", 1,"UR", 1,"RU",1,"IP",1,"GP", 1, "QU", 1, "LF", 1, "MI", 1, "PB", 1, "SG", 1, "CO", 1, "FP", 1, "FD", 1, "CB", 1,"CL", 1, "CH", 1, "CT", 1, "PR", 1); #


	if  (isempty($NonForAnth))					{ $NonForAnthRes = MISSCODE; }
	elsif (!$NonForAnthList {$NonForAnth} )  { $NonForAnthRes = ERRCODE; }
	
	elsif (($NonForAnth eq "BA")||($NonForAnth eq "AI")||($NonForAnth eq "EA")||($NonForAnth eq "RD")||($NonForAnth eq "WR")||($NonForAnth eq "TR")) 	{ $NonForAnthRes = "FA"; }
	elsif (($NonForAnth eq "TM")||($NonForAnth eq "IZ")||($NonForAnth eq "PP")||($NonForAnth eq "SK")) 							{ $NonForAnthRes = "FA"; }
	elsif (($NonForAnth eq "AR")||($NonForAnth eq "CG")||($NonForAnth eq "PA")||($NonForAnth eq "GC")||($NonForAnth eq "PR")) 				{ $NonForAnthRes = "FA"; }
	elsif (($NonForAnth eq "CS")||($NonForAnth eq "LE")||($NonForAnth eq "RY")||($NonForAnth eq "RR")) 							{ $NonForAnthRes = "FA"; }
	elsif (($NonForAnth eq "UR")||($NonForAnth eq "RU"))													{ $NonForAnthRes = "SE"; }
	elsif (($NonForAnth eq "IP")||($NonForAnth eq "GP")||($NonForAnth eq "QU")||($NonForAnth eq "LF")) 							{ $NonForAnthRes = "IN"; }
	elsif (($NonForAnth eq "MI")||($NonForAnth eq "PB")) 													{ $NonForAnthRes = "IN"; }
	elsif (($NonForAnth eq "SG"))																{ $NonForAnthRes = "LG"; }
	elsif (($NonForAnth eq "CO")||($NonForAnth eq "FP")||($NonForAnth eq "FD")||($NonForAnth eq "CB")) 							{ $NonForAnthRes = "CL"; }
	elsif (($NonForAnth eq "CL")||($NonForAnth eq "CH")||($NonForAnth eq "CT")) 										{ $NonForAnthRes = "CL"; }
	else 																			{ $NonForAnthRes = ERRCODE; }
	return $NonForAnthRes;
}

#NonForestedVeg ---ST, SL, HF, HE, HG, BR, OM, TN
#AL=ST	SV=ST                 	                             	                                    
#FM=HG	CM=HG 
#BO=OM	FE=OM

  

	
sub NonForestedVeg
{
    my $NonForVeg = shift(@_);my $NonForVegRes; 
	my %NonForVegList = ("", 1, "AL", 1, "SV", 1, "FM", 1, "CM", 1, "BO", 1, "FE", 1);

	my $Mod= shift(@_);


	if  (isempty($NonForVeg))			{ $NonForVegRes = MISSCODE; }
	elsif (!$NonForVegList {$NonForVeg} )  { $NonForVegRes = ERRCODE; }

	elsif (($NonForVeg eq "AL" && $Mod eq "SV"))	{ $NonForVegRes = "ST"; }
	elsif (($NonForVeg eq "FM" && $Mod eq "CM"))	{ $NonForVegRes = "HG"; }
	elsif (($NonForVeg eq "BO" && $Mod eq "FE"))	{ $NonForVegRes = "OM"; }
	else 						{ $NonForVegRes = ERRCODE; }
	return $NonForVegRes;
}


#UnProdForest TM,TR, AL, SD, SC, NP, 
#Natnonveg ==== AP, LA, RI, OC, RK, SA, SI, SL, EX, BE, WS, FL, IS, TF
#NonForestedVeg ---ST, SL, HF, HE, HG, BR, OM, BT
#Anthropogenic IN, FA, CL, SE, LG, BP, OT

sub UnProdForest 
{
    my $NonForVeg = shift(@_); my $NonForVegRes;
	my %NonForVegList = ("", 1,  "DU", 1);

	if  (isempty($NonForVeg))	{ $NonForVegRes = MISSCODE; }
	elsif (!$NonForVegList {$NonForVeg} )  { $NonForVegRes = ERRCODE; }
	
	elsif (($NonForVeg eq "DU"))	{ $NonForVegRes = "SD"; } 
	return $NonForVegRes;
}



#2003  field L1  TRT	Year of Treatment	extent No Field
#CT=PC  GS=PC	PC=PC  PA=PC	SC=PC  ST=PC	ST=PC  CV=PC	TP=PC  RC=PC	SH=PC  FW=PC	SR=PC  SA=PC	PA=PC	PB=BU  BB=BU	Can identify blowdown from origin=W
#CT=PC  GS=PC	PC=PC  PA=PC	SC=PC  ST=PC	ST=PC  CV=PC	TP=PC  RC=PC	SH=PC  FW=PC	SR=PC  SA=PC	PA=PC	PB=BU  BB=BU  CC=CO TI=PC 
 #CC =Clear cut; CL=Plantation cleaning;FP=Fill planting;FT=Family test;IT=Intermediate/semi-commercial thinning;
#PL=Planting; PT=Progeny test; TI=Pre-commercial thinning; 
 
 
#CC = CO
#IT  = PC
#CL,FP,PL,TI = SI
#FT,PT = OT

#ask for RR
sub Disturbance 
{
	my $Mod;
	my $ModYr; my $Sylvc;
	my $Disturbance;

	($Sylvc) =shift(@_);
	($ModYr) = shift(@_);
	$_ = $Sylvc;tr/a-z/A-Z/; $Sylvc = $_;
	
	my %ModList = ("", 1, "CT", 1,  "GS", 1, "PC",1, "PA",1, "SC",1, "ST",1, "CV",1, "TP",1, "RC",1, "SH",1, "FW",1, "SR",1, "SA",1, "PA",1, "PB",1, "BB",1, "CC",1, "CL",1, "FP",1, "FT",1, "IT",1, "PL",1, "PT",1, "TI",1,  , "B",1, "C",1, "F",1, "N",1, "W",1, "RR",1);# 
	if (isempty($ModYr) || $ModYr eq "0") {$ModYr = MISSCODE; }

	if(isempty($Sylvc))
	{
		$Mod = MISSCODE; 	 
	}
	elsif ($ModList{$Sylvc}) 
	{ 

		if ($Sylvc ne "") 
		{ 
 			if (($Sylvc  eq "CT") || ($Sylvc eq "GS") || ($Sylvc  eq "PC") || ($Sylvc eq "PA") || ($Sylvc eq "SC")) { $Mod="PC"; }
			elsif (($Sylvc  eq "ST") || ($Sylvc eq "CV") || ($Sylvc  eq "TP") || ($Sylvc eq "RC")) { $Mod="PC"; }
			elsif (($Sylvc  eq "SH") || ($Sylvc eq "FW") || ($Sylvc  eq "SR") || ($Sylvc eq "SA")|| ($Sylvc eq "PA")){$Mod="PC"; }
			elsif (($Sylvc  eq "PB") || ($Sylvc eq "BB")|| ($Sylvc eq "B"))  { $Mod="BU"; }
			elsif (($Sylvc  eq "TI") )  { $Mod="SI"; } #from  Steve
			elsif (($Sylvc  eq "CC") || ($Sylvc eq "C"))  { $Mod="CO"; } #from Steve
			elsif (($Sylvc  eq "IT") )  { $Mod="PC"; }#from Steve
			elsif (($Sylvc  eq "W") )  { $Mod="WF"; } 
			elsif (($Sylvc  eq "RR") )  { $Mod="OT"; } 
			elsif (($Sylvc  eq "FT") || ($Sylvc eq "PT") || ($Sylvc eq "F")) { $Mod="OT"; }#from Steve
			elsif (($Sylvc  eq "F") || ($Sylvc eq "N") || ($Sylvc eq "F")) { $Mod="OT"; } 
			elsif (($Sylvc  eq "CL") || ($Sylvc eq "FP") || ($Sylvc eq "PL")){$Mod="SI"; }#from Steve
			else {print "unexpected in Disturbance"; exit;}
		}
	  	else 
	  	{ 
			$Mod = MISSCODE; 
		}
	} 
	else 
	{
		$Mod = ERRCODE; 	 
	}
	$Disturbance = $Mod . "," . $ModYr.",".UNDEF.",".UNDEF;  
	return $Disturbance;
}

# 2005
#BO + veg type FS = Btnn  
#BO + veg type SV = Bons 
#FE + veg type FH or FS= Ftnn  
#FE + veg type AW or SV = Fons 
#AB = Oonn  
#FM = Mong = 
#FW = Stnn  
#FW + Impoundment Modifier BP = Oonn 
#SB = Sons   
#CM = Mcng  
#TF = Tmnn  
# from MEl AI AR BA BL CB CG CH CL CO CS CT EA FD FP FW GC GP IP IZ LE LF MI PA PB PP PR QU RD RF RO RR RU RY SG SK TM TR UR WR
#from doc AB BC BO CM DU FE FM FW NP RK SB TF WL
#from source  AB BO CM FE FM FW NP SB WC WL

sub WetlandCodes
{
	my $wetcode = shift(@_);
	my $vegtype =  shift(@_);
	my $ImpMod  =  shift(@_);
	my $WetlandCode = "";
	
	if(isempty($wetcode))
	{
		$wetcode = ""; 	 
	}
	if(isempty($vegtype))
	{
		$vegtype = ""; 	 
	}
	if(isempty($ImpMod))
	{
		$ImpMod = ""; 	 
	}
	 
	$_ = $wetcode;tr/a-z/A-Z/; $wetcode = $_;
	$_ = $vegtype; tr/a-z/A-Z/; $vegtype = $_;
	$_ = $ImpMod; tr/a-z/A-Z/; $ImpMod = $_;
	
	if( $wetcode eq  "BO" &&   $vegtype eq "FS")  
	{ $WetlandCode = "B,T,N,N,"; }
	elsif($wetcode eq  "BO" &&   $vegtype eq "SV")  
	{ $WetlandCode = "B,O,N,S,"; }
	elsif($wetcode eq  "FE" &&  ($vegtype eq "FH"||$vegtype eq "FS"))  
	{ $WetlandCode = "F,T,N,N,"; }
	elsif($wetcode eq  "FE" &&  ($vegtype eq "AW"||$vegtype eq "SV"))  
	{ $WetlandCode = "F,O,N,S,"; }
	elsif($wetcode eq  "AB")  
	{ $WetlandCode = "O,O,N,N,"; }
	elsif($wetcode eq  "FM")  
	{ $WetlandCode = "M,O,N,G,"; }
	elsif($wetcode eq  "FW")  
	{ $WetlandCode = "S,T,N,N,"; }
	elsif($wetcode eq  "FW" &&  $ImpMod eq "BP")  
	{ $WetlandCode = "O,F,-,B,"; }
	elsif($wetcode eq  "SB")  
	{ $WetlandCode = "S,O,N,S,"; }
	elsif($wetcode eq  "CM")  
	{ $WetlandCode = "M,C,N,G,"; }
	elsif($wetcode eq  "TF")  
	{ $WetlandCode = "T,M,N,N,"; }
	elsif( $wetcode eq  "FE" &&   $vegtype eq "EV" && $ImpMod eq "BP")  
	{ $WetlandCode = "F,O,-,B,"; }
	elsif( $wetcode eq  "FE" &&   $vegtype eq "EV")  
	{ $WetlandCode = "F,O,-,-,"; }
	elsif( $wetcode eq  "FE" &&   $vegtype eq "OV")  
	{ $WetlandCode = "O,O,-,-,"; }
	elsif( $wetcode eq  "FE" &&   $vegtype eq "OW")  
	{ $WetlandCode = "O,-,-,-,"; }
	elsif( $wetcode eq  "FE" &&   $vegtype eq "EV" && $ImpMod eq "MI")  
	{ $WetlandCode = "F,O,-,-,"; }
	elsif( $wetcode eq  "FE" &&   $vegtype eq "EV" && $ImpMod eq "DI")  
	{ $WetlandCode = "F,O,-,-,"; }
	elsif( $wetcode eq  "FE" &&   $vegtype eq "OV" && $ImpMod eq "MI")  
	{ $WetlandCode = "O,O,-,-,"; }


	elsif( $wetcode eq  "BO" &&   $vegtype eq "EV" && $ImpMod eq "BP")  
	{ $WetlandCode = "B,O,-,B,"; }
	elsif( $wetcode eq  "BO" &&   $vegtype eq "EV" && $ImpMod eq "DI")  
	{ $WetlandCode = "B,O,-,-,"; }
	elsif( $wetcode eq  "BO" &&   $vegtype eq "AW" && $ImpMod eq "BP")  
	{ $WetlandCode = "B,T,-,B,"; }
	elsif( $wetcode eq  "BO" &&   $vegtype eq "OV" && $ImpMod eq "BP")  
	{ $WetlandCode = "O,O,-,B,"; }

	elsif( $wetcode eq  "BO" &&   $vegtype eq "EV")  
	{ $WetlandCode = "B,O,-,-,"; }
	elsif( $wetcode eq  "BO" &&   $vegtype eq "AW")  
	{ $WetlandCode = "B,T,-,-,"; }
	elsif( $wetcode eq  "BO" &&   $vegtype eq "OW")  
	{ $WetlandCode = "O,-,-,-,"; }
	elsif( $wetcode eq  "BO" &&   $vegtype eq "OV")  
	{ $WetlandCode = "O,O,-,-,"; }

 	elsif( $wetcode eq  "NP")  
	{ $WetlandCode = "W,-,-,-,"; }
	elsif( $wetcode eq  "WL")  
	{ $WetlandCode = "W,-,-,-,"; }
	
	else{ $WetlandCode = ERRCODE; }
	if ($WetlandCode eq "") {$WetlandCode = MISSCODE;}# MISSCODE.",".MISSCODE.",".MISSCODE.",".MISSCODE.",";
	return $WetlandCode;
	
	
}


sub NBinv_to_CAS 

{
	my $NB_File = shift(@_);
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
	my $total1=0;
	my $total2=0;
	my $ndrops=0;
	my $total;
	#####

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
	 	$CAS_File_HDR = $pathname."/NBtable.hdr";
	 	$CAS_File_CAS = $pathname."/NBtable.cas";
	 	$CAS_File_LYR = $pathname."/NBtable.lyr";
	 	$CAS_File_NFL = $pathname."/NBtable.nfl";
	 	$CAS_File_DST = $pathname."/NBtable.dst";
	 	$CAS_File_ECO = $pathname."/NBtable.eco";
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
		#open (INFOHDR, "<$INFOHDR_File") || die "\n Error: Could not open file $INFOHDR_File !\n";

		# Declare the name of the column that you want into every file. Always the same structure for all the province. Refere to documentation John Cosco
	
		print CASCAS "CAS_ID,ORIG_STAND_ID,STAND_STRUCTURE,NUM_OF_LAYERS,IDENTIFICATION_ID,MAP_SHEET_ID,GIS_AREA,GIS_PERIMETER,INVENTORY_AREA,PHOTO_YEAR\n";
		print CASLYR "CAS_ID,SOIL_MOIST_REG,STRUCTURE_PER,LAYER,LAYER_RANK,CROWN_CLOSURE_UPPER,CROWN_CLOSURE_LOWER,HEIGHT_UPPER,HEIGHT_LOWER,PRODUCTIVE_FOR,". 		
		"SPECIES_1,SPECIES_PER_1,SPECIES_2,SPECIES_PER_2,SPECIES_3,SPECIES_PER_3,SPECIES_4,SPECIES_PER_4,SPECIES_5,SPECIES_PER_5,SPECIES_6,SPECIES_PER_6,SPECIES_7,SPECIES_PER_7,".
		"SPECIES_8,SPECIES_PER_8,SPECIES_9,SPECIES_PER_9,SPECIES_10,SPECIES_PER_10,ORIGIN_UPPER,ORIGIN_LOWER,SITE_CLASS,SITE_INDEX\n";
		print CASNFL "CAS_ID,SOIL_MOIST_REG,STRUCTURE_PER,LAYER,LAYER_RANK,CROWN_CLOSURE_UPPER,CROWN_CLOSURE_LOWER,HEIGHT_UPPER,HEIGHT_LOWER,NAT_NON_VEG,NON_FOR_ANTH,NON_FOR_VEG\n";
		print CASDST "CAS_ID,DIST_1,DIST_YR_1,DIST_EXT_UPPER_1,DIST_EXT_LOWER_1,DIST_2,DIST_YR_2,DIST_EXT_UPPER_2,DIST_EXT_LOWER_2,DIST_3,DIST_YR_3,DIST_EXT_UPPER_3,DIST_EXT_LOWER_3,LAYER\n";
		print CASECO "CAS_ID,WETLAND_TYPE,WET_VEG_COVER,WET_LANDFORM_MOD,WET_LOCAL_MOD,ECO_SITE\n";
		print CASHDR "IDENTIFICATION_ID,JURISDICTION,COORDINATE_SYS,PROJECTION,DATUM,INVENTORY_OWNER,LAND_OWNER,PERMISSION,TENURE_TYPE,INV_TYPE,INV_VERSION,INV_START_YR,INV_FINISH_YR,INV_ACQ_ID,INV_ACQ_YR,INV_UPDATE_YR\n";


		my $HDR_Record =  "1,NB,,NAD_1983_CSRS_New_Brunswick_Stereographic,NAD83,PROV_GOV,New Brunswick Natural Resources,RESTRICTED,,,With Revisions,1993,2008,,2012,,";
		print CASHDR $HDR_Record . "\n";
		#close(INFOHDR);  
	}
	else 	
	{
		open (CASCAS, ">>$CAS_File_CAS") || die "\n Error: Could not open GROUPCAS  output file!\n";
		open (CASLYR, ">>$CAS_File_LYR") || die "\n Error: Could not open GROUPCAS layer output file!\n";
		open (CASNFL, ">>$CAS_File_NFL") || die "\n Error: Could not open GROUPCAS non-forested file!\n";
		open (CASDST, ">>$CAS_File_DST") || die "\n Error: Could not open GROUPCAS disturbance  file!\n";
		open (CASECO, ">>$CAS_File_ECO") || die "\n Error: Could not open GROUPCAS ecological  file!\n";
		open (CASHDR, ">>$CAS_File_HDR") || die "\n Error: Could not open CAS header output file!\n";
		#open (INFOHDR, "<$INFOHDR_File") || die "\n Error: Could not open file $INFOHDR_File !\n";
	}

	my $Record; my @Fields;my $PolyNum; my $CAS_ID; my $MapSheetID; my $IdentifyID;my $Area; my $Perimeter;
	my $Mer;my $Rng;my $Twp;my $MoistReg; my $Height;
	my $SpAss; my $Sp1;my $Sp2;my $Sp3; my $Sp4;my $Sp5;
	my $Sp1Per;my $Sp2Per;my $Sp3Per;  my $Sp4Per; my $Sp5Per; 
	my $CrownClosure;
	my $Origin;
	my $Dist; my $Dist1; my $Dist2; my $Dist3; 
	my $WetEco;  my $Ecosite;my $SMR;my $StandStructureCode;
	my $CCHigh;my $CCLow;my $UCCHigh;my $UCCLow;
	my $SpeciesComp; my $SpComp; 
	my $SiteClass; my $SiteIndex;
	my $Wetland;  
	my $NatNonVeg; 
	my $NonForAnth;  my $UnProdForLand; 
	my %herror=();
	my $keys;
	my @USpecsPerList; my $particular;

	my $PHOTOYEAR; my $UDist1;my $UDist2;my $UDist3;my $UDist;   my  $UOriginHigh; my $UOriginLow;
	my $NUMBER_OF_LAYERS;
	my $Orig_Mod; my $Orig_Cd1; my $USp1;my $USp2;my $USp3; my $USp4;my $USp5; my $USpeciesComp; my $UOrig_Mod; my $UOrig_Cd1;
	my $USp1Per;my $USp2Per;my $USp3Per;  my $USp4Per; my $USp5Per; my $UMod; my $UModYr;my $UCanopy;my $UDensity;my $UCrownClosure;my $UHeight;
  	my $HeightHigh ;
    my  $HeightLow;  my  $OriginHigh; my $OriginLow;    my @ListSp; my $Mod; my $ModYr; my $NonProd; my $Drain;
	my $UHeightHigh ;  my $Height2; my $UHeight2;
    my  $UHeightLow; 
	my $CAS_Record; my $Lyr_Record; my $LYR_Record1; my $LYR_Record2; my $LYR_Record3; my $UOrigin ;
	my $NFL_Record; my $NFL_Record1; my $NFL_Record2; my $NFL_Record3; my $DST_Record; 
	my  @SpecsPerList;my $pr1;my $pr2;my $pr3;my $pr4;my $pr5; my $SpAssoc; my $SiteCode; my $Modsylv; my $ModsylvYr;
	my $Wkg;my $isComFor; my $NonVegAnth; my $NonForVeg; my $UnProdFor; my$PRV, my $TRorL; my $Canopy;my $Density;
	my $WetCode; my $Vegtype; my $Impound_Modif; my $SpPer1; my $SpPer2; my $SpPer3; my $SpPer4; my $SpPer5;
 	my $USpPer1; my $USpPer2; my $USpPer3; my $USpPer4; my $USpPer5;
	my $Cd1; my $Cd2; my $UCd1; my $UCd2;  my $utotal; my $NonProd2; my $NonProdCode; my $Forested;
	#CAS_ID,HEADER_ID,SHAPE_AREA,SHAPE_PERI,STDLAB,DATASRC,DATAYR,SITEI,VOLI,FST,L1TRTI,L1ORIG,L1ESTYR,L1TRT,L1TRTYR,L1S1,L1DS1,L1PR1,L1S2,L1DS2,L1PR2,L1S3,L1DS3,L1PR3,L1S4,L1DS4,L1PR4,L1S5,L1DS5,L1PR5,L1DS,L1CCI,L1CC,L1STOCK,L1VS,L1HT,L1ACS,L1DC,L1SC,L1FUNA,L2TRTI,L2ORIG,L2ESTYR,L2TRT,L2TRTYR,L2S1,L2DS1,L2PR1,L2S2,L2DS2,L2PR2,L2S3,L2DS3,L2PR3,L2S4,L2DS4,L2PR4,L2S5,L2DS5,L2PR5,L2DS,L2CCI,L2CC,L2STOCK,L2VS,L2HT,L2ACS,L2DC,L2SC,L2FUNA,HARV_ID,PLANT_ID,THIN_ID,LIC_KEY,INTERPID,VOLN,SHAPE_LEN,PLU,SLU,STATUS,LC,AREA
	#CAS_ID,HEADER_ID,SHAPE_AREA,SHAPE_PERI,STDLAB,DATASRC,DATAYR,SITEI,VOLI,FST,L1TRTI,L1ORIG,L1ESTYR,L1TRT,L1TRTYR,L1S1,L1DS1,L1PR1,L1S2,L1DS2,L1PR2,L1S3,L1DS3,L1PR3,L1S4,L1DS4,L1PR4,L1S5,L1DS5,L1PR5,L1DS,L1CCI,L1CC,L1STOCK,L1VS,L1HT,L1ACS,L1DC,L1SC,L1FUNA,L2TRTI,L2ORIG,L2ESTYR,L2TRT,L2TRTYR,L2S1,L2DS1,L2PR1,L2S2,L2DS2,L2PR2,L2S3,L2DS3,L2PR3,L2S4,L2DS4,L2PR4,L2S5,L2DS5,L2PR5,L2DS,L2CCI,L2CC,L2STOCK,L2VS,L2HT,L2ACS,L2DC,L2SC,L2FUNA,HARV_ID,PLANT_ID,THIN_ID,LIC_KEY,INTERPID,VOLN,SHAPE_LEN,PLU,SLU,STATUS,LC,OBJECTID,WATER_CODE,BUFFER_COD,NAME,WATER_NAME,WATER_ID,NBWLID,WLOC,WC,WRI,IM,VT,SPVC,WLPOLYID,SHAPE_Leng,AREA
	my $nbnulorig=0; my $nbforested=0; my $nbnulforested=0; 
	my $OriginV; my $UOriginV;
	my $AgeHigh;my $AgeLow; my $UAgeHigh;my $UAgeLow; my $original; my $StandStructureVal; my $isundef1;my $isundef2;	


	my $csv = Text::CSV_XS->new
	({
		binary          => 1,
		sep_char    => ";" 
	});
   	open my $NBinv, "<", $NB_File or die " \n Error: Could not open NB input file $NB_File: $!";

	my @tfilename = split ("/", $NB_File);
	my $nps = scalar(@tfilename);
	$Glob_filename = $tfilename[$nps-1];
  
   	$csv->column_names ($csv->getline ($NBinv));

   	while (my $row = $csv->getline_hr ($NBinv)) 
   	{	
   		#print "CAS_ID is $row->{CAS_ID}  and AREA is $row->{OBJECTID_1} \n"; exit(0);

        $particular = 0;
		$CAS_ID       =  $row->{CAS_ID};
		$Glob_CASID   =  $row->{CAS_ID};
		$IdentifyID   =  $row->{HEADER_ID};
		($pr1,$pr2,$pr3,$pr4,$pr5)     =  split("-", $CAS_ID);  	
        $MapSheetID   =  UNDEF; #$pr3;  Melina says it is not defined in this inventory; pr3=xxxxxxxx
        $PolyNum      =  $pr4; 
		$PolyNum =~ s/^0+//;
        $Area         =  $row->{GIS_AREA};
	 	$Perimeter    =  $row->{GIS_PERI};

 		$OriginV       =  $row->{L1DS1};
		if (!defined $OriginV ) { $OriginV = "";}
		$UOriginV       =  $row->{L2DS1};
		#will use this if  $OriginV is empty
		$Origin       =  $row->{L1ESTYR};

		#if  ($Origin eq "0" || $Origin eq ""){$nbnulorig++;}
		$UOrigin       =  $row->{L2ESTYR};

		$Sp1=  $row->{L1S1};
		if (!defined $Sp1 )	  { $Sp1 = "";}
		$Sp2 =  $row->{L1S2};
		$Sp3 =  $row->{L1S3};
		$Sp4 =  $row->{L1S4};
		$Sp5 =  $row->{L1S5};
		$SpPer1 =  $row->{L1PR1};
		$SpPer2 =  $row->{L1PR2};
		$SpPer3 =  $row->{L1PR3};
		$SpPer4 =  $row->{L1PR4};
		$SpPer5 =  $row->{L1PR5};

		#second layer data
 		$USp1 =  $row->{L2S1};
		$USp2 =  $row->{L2S2};
		$USp3 =  $row->{L2S3};
		$USp4 =  $row->{L2S4};
		$USp5 =  $row->{L2S5};
		$USpPer1 =  $row->{L2PR1};
		$USpPer2 =  $row->{L2PR2};
		$USpPer3 =  $row->{L2PR3};
		$USpPer4 =  $row->{L2PR4};
		$USpPer5 =  $row->{L2PR5};

		$UOrig_Mod =  $row->{L2ORIG};
 		$UMod =  $row->{L2TRT};
		$UModYr =  $row->{L2TRTYR};

		$PHOTOYEAR = $row->{DATAYR}; #from Steve
		$UDensity = $row->{L2DC};
		$UHeight = $row->{L2HT};
 		$UHeight2 = $row->{L2SC};
		$UCrownClosure = $row->{L2CC};
 		$UCanopy =  $row->{L2VS};
		#end second layer

	 	$SiteCode     =  $row->{SITEI};
    	$NonProd =  $row->{SLU};#	WATER_CODE;
 		$NonProd2 =  $row->{WATER_CODE};#	;
		$WetCode = $row->{WC};
		$Vegtype = $row->{VT};
		$Impound_Modif = $row->{IM};

		$Orig_Mod =  $row->{L1ORIG};
 		$Mod =  $row->{L1TRT};
		$ModYr =  $row->{L1TRTYR};

		$Density = $row->{L1DC};
		$Height = $row->{L1HT};
		$Height2 = $row->{L1SC};
		$CrownClosure = $row->{L1CC};
 		$Canopy =  $row->{L1VS};

		$Forested = $row->{FST};
		$SMR =  UNDEF; 
		############## translations

		# ===== Site =====
		$SiteClass = Site($SiteCode); 
		if($SiteClass  eq ERRCODE) 
		{  
			$keys="Sitecode"."#".$SiteCode;
			$herror{$keys}++; 
	  	}
		$SiteIndex = UNDEF;
	
		# ===== Crown closure =====
		$CCHigh = CCUpper($CrownClosure);
		$CCLow = CCLower($CrownClosure);
 	
		if($CCHigh  eq ERRCODE || $CCLow  eq ERRCODE ) 
		{ 
			$keys="Density"."#".$CrownClosure;
			$herror{$keys}++;			
		}

		#if($UCanopy >0){

		$UCCHigh = CCUpper($UCrownClosure);
		$UCCLow = CCLower($UCrownClosure);
 	
		if($UCCHigh  eq ERRCODE || $UCCLow  eq ERRCODE ) 
		{ 
			$keys="understorey Density"."#".$UCrownClosure;
			$herror{$keys}++;		
		}

		#}
		# ===== Species composition =====
		$SpeciesComp="";
		if (!isempty($Sp1))
		{
			$nbforested++;

			$SpeciesComp = Species($Sp1, $SpPer1, $Sp2, $SpPer2, $Sp3, $SpPer3, $Sp4, $SpPer4, $Sp5, $SpPer5,$spfreq);  

			if($SpeciesComp eq "-1")
			{
				$total = $SpPer1+$SpPer2+$SpPer3+$SpPer4+$SpPer5;
				$keys = "!!Species percentage !=100 in "."#".$Sp1."#". $SpPer1."#". $Sp2."#". $SpPer2."#".$Sp3."#". $SpPer3."#".$Sp4."#". $SpPer4."#".$Sp5."#". $SpPer5.", Total pct=".$total;
				$herror{$keys}++;
			}
			else
			{
				@SpecsPerList  = split(",", $SpeciesComp); 
	 			$Sp1Per = $SpecsPerList[1];

				if($SpecsPerList[0]  eq SPECIES_ERRCODE && $Sp1 ne "NR" ) 
				{ 
					$keys="Species1"."#".$Sp1;
					$herror{$keys}++;
				}
				if($SpecsPerList[2]  eq SPECIES_ERRCODE) 
				{ 
					$keys="Species2"."#".$Sp2;
					$herror{$keys}++;
				}
				if($SpecsPerList[4]  eq SPECIES_ERRCODE  ) 
				{ 
					$keys="Species3"."#".$Sp3;
					$herror{$keys}++;
				}
				if($SpecsPerList[6]  eq SPECIES_ERRCODE) 
				{ 
					$keys="Species4"."#".$Sp4;
					$herror{$keys}++;
				}
				if($SpecsPerList[8]  eq SPECIES_ERRCODE  ) 
				{ 
					$keys="Species5"."#".$Sp5;
					$herror{$keys}++;
				}
				$SpeciesComp = $SpeciesComp .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";
			}
		}

		$USpeciesComp="";
		if (!isempty($USp1))
		{
			$USpeciesComp = Species($USp1, $USpPer1, $USp2, $USpPer2, $USp3, $USpPer3, $USp4, $USpPer4, $USp5, $USpPer5, $spfreq);  
			if($USpeciesComp eq "-1" && $USp1 ne "C" && $USp1 ne "J")
			{
				$utotal = $USpPer1+$USpPer2+$USpPer3+$USpPer4+$USpPer5;
				$keys = "!!understorey Species percentage !=100 in "."#".$USp1."#". $USpPer1."#". $USp2."#". $USpPer2."#".$USp3."#". $USpPer3."#".$USp4."#". $USpPer4."#".$USp5."#". $USpPer5.", Total pct=".$utotal;
				$herror{$keys}++;
			}
			elsif($USpeciesComp ne "-1") 
			{
				@USpecsPerList  = split(",", $USpeciesComp); 
 				$USp1Per = $USpecsPerList[1];

				if($USpecsPerList[0]  eq SPECIES_ERRCODE  && $USp1 ne "NR" ) 
				{ 
					$keys = "understorey Species1"."#".$USp1;
					$herror{$keys}++;
				}
				if($USpecsPerList[2]  eq SPECIES_ERRCODE) 
				{ 
					$keys = "Species2"."#".$USp2;
					$herror{$keys}++;
				}
				if($USpecsPerList[4]  eq SPECIES_ERRCODE  ) 
				{ 
					$keys = "Species3"."#".$USp3;
					$herror{$keys}++;
				}
				if($USpecsPerList[6]  eq SPECIES_ERRCODE) 
				{ 
					$keys = "Species4"."#".$USp4;
					$herror{$keys}++;
				}
				if($USpecsPerList[8]  eq SPECIES_ERRCODE  ) 
				{ 
					$keys = "Species5"."#".$USp5;
					$herror{$keys}++;
				}
		   		$USpeciesComp = $USpeciesComp .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";
			}
		}

	 	$original=1;
	 	$OriginLow = MISSCODE;
  	 	$OriginHigh = MISSCODE;
 	 	$UOriginLow = MISSCODE;
  	 	$UOriginHigh = MISSCODE;

		if ($PHOTOYEAR <= 0 || $PHOTOYEAR >2014) 
		{
			print "check this photoyear $PHOTOYEAR \n";
			#exit;
			$keys="photoyear "."#".$PHOTOYEAR."#taken from#".$row->{DATAYR};
			$herror{$keys}++;
	  	}

		# ===== Origin Year =====
		$isundef1=0;	
		$isundef2=0;	
		if(!isempty($OriginV) && $OriginV ne "0" && !isempty($Sp1))
		{

			if($OriginV =~ /\d/)
			{
				$AgeHigh = OriginUpper($OriginV, $Sp1);    
				$AgeLow = OriginLower($OriginV, $Sp1);
			}
			else
			{
				($AgeLow, $AgeHigh) = ULOrigin($OriginV, $Sp1);  
				 
			}
			if($AgeHigh  eq MISSCODE || $AgeHigh  eq ERRCODE   || $AgeLow  eq MISSCODE || $AgeLow  eq ERRCODE  ) 
			{ 
				$keys=" show L1SD1 Age"."#".$OriginV."#species#".$Sp1;
				$herror{$keys}++;									
			}
			if($AgeHigh  eq UNDEF || $AgeLow  eq UNDEF ) 
			{ 
				$keys=" show L1SD1 Age"."#".$OriginV."#species#".$Sp1."# will be translated as UNDEF";
				$herror{$keys}++;	
				$isundef1=1;								
			}
			if( $AgeHigh ne INFTY && $AgeHigh ne "INFTY") 
			{ 				  									
  				if(!is_missing($AgeHigh)) 
  				{ 
					if ($PHOTOYEAR >0)
					{ 
						$OriginHigh=$PHOTOYEAR-$AgeHigh; 
					}
				}
				else 
				{ 
					$OriginHigh=MISSCODE; 
				}
			}
			else 
			{ 
				$OriginHigh=INFTY; 
			}

			if(!is_missing($AgeLow))
			{
				if ($PHOTOYEAR >0)
				{
					$OriginLow = $PHOTOYEAR-$AgeLow;
				}
			}
			else 
			{ 
				$OriginLow=MISSCODE; 
				
			}

			if(!isempty($UOriginV) && $UOriginV ne "0" && !isempty($USp1))
			{
				if($UOriginV =~ /\d/)
				{
					$UAgeHigh = OriginUpper($UOriginV, $USp1);    
					$UAgeLow = OriginLower($UOriginV, $USp1);
				}
				else
				{
					($UAgeLow, $UAgeHigh) = ULOrigin($UOriginV, $USp1);  
					 
				}
				if($UAgeHigh  eq MISSCODE || $UAgeHigh  eq ERRCODE   || $UAgeLow  eq MISSCODE || $UAgeLow  eq ERRCODE ) 
				{ 
					$keys="show understorey L2SD1 Age"."#".$UOriginV."#species#".$USp1;
					$herror{$keys}++;									
				}
				if($UAgeHigh  eq UNDEF ||  $UAgeLow  eq UNDEF ) 
				{ 
					$keys="show understorey L2SD1 Age"."#".$UOriginV."#species#".$USp1."# will be translated as UNDEF";;
					$herror{$keys}++;	
					$isundef2=1;								
				}
				#if( $UAgeHigh  eq ERRCODE   || $UAgeLow  eq ERRCODE) 
				#{ 
					#   $keys="understorey L2SD1 Age"."#".$UOriginV;
					#	$herror{$keys}++;									
				#}

				if( $UAgeHigh ne INFTY && $UAgeHigh ne "INFTY") 
				{ 				  									
  			
					if(!is_missing($UAgeHigh))
					{ 
						if ($PHOTOYEAR >0)
						{
							$UOriginHigh=$PHOTOYEAR-$UAgeHigh;
						} 
					}
					else 
					{ 
						$UOriginHigh=MISSCODE; 
					}
				}
				else 
				{ 
					$UOriginHigh=INFTY; 
				}	
				if(!is_missing($UAgeLow))
				{
					if ($PHOTOYEAR >0)
					{
						$UOriginLow = $PHOTOYEAR-$UAgeLow;
					}
				}
				else 
				{ 
					$UOriginLow=MISSCODE; 
				}
			}	
			else 
			{
				$UOriginLow = MISSCODE;$UOriginHigh = MISSCODE;
			}
		}
		else 
		{
			$OriginLow = MISSCODE;$OriginHigh = MISSCODE;$UOriginLow = MISSCODE;$UOriginHigh = MISSCODE;
		}

		#BK permutation to keep OriginLow < OriginHigh
		my $aux=$OriginHigh;
		$OriginHigh=$OriginLow;
		$OriginLow=$aux;

		if($OriginLow eq ERRCODE  || $OriginHigh eq ERRCODE) 
		{
			print "error check\n "; exit;
		}

		if($OriginLow > $OriginHigh) 
		{
			print "error check2 low $OriginLow  greater than high  $OriginHigh, photoyear is $PHOTOYEAR, ageheigh = $AgeHigh, agelow = $AgeLow\n "; exit;
		}

		if($OriginLow eq MISSCODE  || $OriginHigh eq MISSCODE) 
		{
			$original=2;
			$OriginHigh = UpperOrigin($Origin);
			$OriginLow = LowerOrigin($Origin);
		}
		if($UOriginLow eq MISSCODE  || $UOriginHigh eq MISSCODE) 
		{
			$original=2;
			$UOriginHigh = UpperOrigin($UOrigin);
			$UOriginLow = LowerOrigin($UOrigin);
		}
		if(($OriginHigh  eq MISSCODE   || $OriginLow  eq MISSCODE) && !isempty($Sp1)) 
		{ #."#L1DS1#".$OriginV;
				
			if($OriginV ne "R" && $OriginV ne "S" && $OriginV ne "Y" && $OriginV ne "M" && $OriginV ne "O" && $OriginV ne "I" && $OriginV ne "0" && $OriginV ne "1" )
			{  
				$keys = "NULL Age "."#".$Origin."#L1DS1=".$OriginV."#Step".$original."#species1=".$Sp1;
				$herror{$keys}++;
			}
			else
			{  
				$keys = "NULL Age "."#".$Origin."#Step".$original;
				$herror{$keys}++;
			}						
		}
		if($OriginHigh  eq ERRCODE   || $OriginLow  eq ERRCODE|| $OriginHigh >2014 || ($OriginLow <1700 && $OriginLow >0)) 
		{ 
			$keys = "Origin"."#".$Origin."#Step".$original."#L1DS1#".$OriginV;;
			$herror{$keys}++;									
		}

		if(($UOriginHigh  eq MISSCODE   || $UOriginLow  eq MISSCODE) && !isempty($USp1)) 
		{ #."#L2DS1#".$UOriginV;

 			if($UOriginV ne "R" && $UOriginV ne "S" && $UOriginV ne "Y" && $UOriginV ne "M" && $UOriginV ne "O" && $UOriginV ne "I" && $UOriginV ne "0" && $UOriginV ne "1" )
			{ 
				$keys="understorey NULL Age"."#".$UOrigin."#L2DS1#".$UOriginV."#Step".$original."#species1#".$USp1;
				$herror{$keys}++;		
			}	
			else
			{ 
				$keys="understorey NULL Age"."#".$UOrigin."#Step".$original;
				$herror{$keys}++;		
			}						
		}
		if($UOriginHigh  eq ERRCODE   || $UOriginLow  eq ERRCODE  || $UOriginHigh >2014 || ($UOriginLow <1700 && $UOriginLow >0) ) 
		{ 
			$keys="understorey Origin"."#".$UOrigin."#Step".$original."#L2DS1#".$UOriginV;;
			$herror{$keys}++;									
		}

		if($OriginLow > $OriginHigh) 
		{
			print "error check3 low greater than high\n "; exit;
		}


		# ===== Height =====
		$HeightHigh = StandHeightUp($Height, $Height2);
		$HeightLow = StandHeightLow($Height, $Height2);
		if($HeightHigh  eq ERRCODE   || $HeightLow  eq ERRCODE) 
		{ 
			$keys="Height"."#".$Height;
			$herror{$keys}++;									
		}
		if($HeightHigh  eq MISSCODE   || $HeightLow  eq MISSCODE) 
		{ 
			if(!isempty($Sp1) && $Sp1 ne "0")
			{
				$keys="NULL Height1"."#".$Height."#Height2"."#".$Height2;
				$herror{$keys}++;
			}									
		}

		$UHeightHigh = StandHeightUp($UHeight, $UHeight2);
		$UHeightLow = StandHeightLow($UHeight, $UHeight2);
		if($UHeightHigh  eq ERRCODE   || $UHeightLow  eq ERRCODE)
		{ 
			$keys="understorey Height"."#".$UHeight."#2".$UHeight2;
			$herror{$keys}++;									
		}

		# ===== Wetlands =====
	  	$Ecosite=UNDEF;
		if( !defined($WetCode) || isempty($WetCode)) {$Wetland = MISSCODE;}  #$Vegtype,$Impound_Modif
	  	else 
	  	{
			$Wetland = WetlandCodes ($WetCode,$Vegtype,$Impound_Modif);
	  		if($Wetland  eq ERRCODE ) 
	  		{ 
	  			$keys="WETLAND"."#".$WetCode."#".$Vegtype."#".$Impound_Modif;
				$herror{$keys}++;
			}
		}
	 
	  	# ===== Modifiers =====
		#$Dist1 = Disturbance($Orig_Mod, -1111);  #original disturbance
	  	 
	  	#($Orig_Cd1, $Cd2)=split(",", $Dist1);
	 	# if($Orig_Cd1 eq ERRCODE) {  
						#$keys="Disturbance 1"."#".$Orig_Mod;
						#$herror{$keys}++; 
	  		#}


		$Mod =~ s/\s//g; 
		$Dist1 = Disturbance($Mod, $ModYr);
		($Cd1, $Cd2)=split(",", $Dist1);
	 	if($Cd1 eq ERRCODE) 
	 	{  
			$keys="Disturbance 1 found on original value "."#".$Mod."#";
			$herror{$keys}++; 
	  	}	
		$Dist2 = UNDEF.",0," . UNDEF . "," . UNDEF;
	  	$Dist3 = UNDEF.",0," . UNDEF . "," . UNDEF;
        $Dist = $Dist1 . "," . $Dist2 . "," . $Dist3;
		#--------------

		#$UDist1 = Disturbance($UOrig_Mod, -1111);  #original disturbance  	 
	  	#($UOrig_Cd1, $UCd2)=split(",", $UDist1);
	 	# if($UOrig_Cd1 eq ERRCODE) {  
		#	$keys="understorey Disturbance 1"."#".$UOrig_Mod;
		#	$herror{$keys}++; 
	  	#}
		$UMod =~ s/\s//g;
		$UDist1 = Disturbance($UMod, $UModYr);
		($UCd1, $UCd2)=split(",", $UDist1);
	 	if($UCd1 eq ERRCODE)
	 	{  
			$keys="understorey Disturbance 2 found on original value "."#".$UMod."#";
			$herror{$keys}++; 
	  	}
	 	$UDist2 = UNDEF.",0," . UNDEF . "," . UNDEF;
	  	$UDist3 = UNDEF.",0," . UNDEF . "," . UNDEF;

        $UDist = $UDist1 . "," . $UDist2 . "," . $UDist3;

	 	# ===== Non-forested Land =====

	  	$NonProdCode="";
	
	 	if(defined($NonProd2) && !isempty($NonProd2))
	 	{
	 		$NonProdCode=$NonProd2; #print "Nonprodcode isWATER  $NonProd2"; #exit;
		}
	 	if(defined($NonProd) && !isempty($NonProd))
	 	{
	 		$NonProdCode=$NonProd; #print "Nonprodcode is np  $NonProd";# exit;
		}
		

	  	if(!isempty($NonProdCode))
	  	{
	  		$NatNonVeg = NaturallyNonVeg($NonProdCode);
	  		$NonVegAnth=Anthropogenic($NonProdCode);
	  		$NonForVeg=NonForestedVeg($NonProdCode);
	  		$UnProdFor=UnProdForest($NonProdCode);

	  		if(($NatNonVeg  eq ERRCODE) &&  ($NonVegAnth eq ERRCODE) && ($NonForVeg  eq ERRCODE) &&  ($UnProdFor eq ERRCODE)) 
	  		{ 
				$keys="NonForNonVeg"."#".$NonProdCode."#nonprod=".$NonProd."#nonprod2=".$NonProd2;
				$herror{$keys}++;
				$NatNonVeg = UNDEF; $NonVegAnth = UNDEF;  $NonForVeg = UNDEF;  	
	   		}
	  		else 
	  		{
				if ($NatNonVeg  eq ERRCODE) 
				{ 
					$NatNonVeg = UNDEF;  				
				}
	 			if ($NonVegAnth  eq ERRCODE) 
	 			{ 
					$NonVegAnth =  UNDEF;  				
	 			}
				if ($NonForVeg  eq ERRCODE) 
				{ 
					$NonForVeg =  UNDEF;  				
				}
	 			if ($UnProdFor  eq ERRCODE) 
	 			{ 
					$UnProdFor =  UNDEF;  				
	 			}
	   		}
		}
		else 
		{
			$NatNonVeg = UNDEF; $NonVegAnth =  UNDEF; $NonForVeg = UNDEF; 
			$UnProdFor =  UNDEF; #print "Nonprodcode is null  <<<$NonProd>>>---<<<$NonProd2>>>"; #exit;
		}


		# ===== Output inventory info for layer 1 =====


		#  if (($StandStructureCode eq "S" )) {
	           
		$NUMBER_OF_LAYERS = 1;
		$StandStructureCode = "S";

		if ($Forested != 0) 
		{ 
			#Only these should be forested stands
	 		if ($Canopy >=1)
			{  #L1VS >= 1

	   			if ($UCanopy ==0 || isempty($UCanopy))
				{  
					#  (L2VS ==0 !! is.null(L2VS)) {
	     			$NUMBER_OF_LAYERS = 1;
	    			# LAYER 1 has LAYER RANK 1 and attirbutes defined by the various L1 fields L1S1 L1PR1,     L1HT, etc.
	     			$StandStructureCode = "S";
	   			}
	   			else 
				{ 
					#L2Vs > 0
	     			$NUMBER_OF_LAYERS = 2;
	     			#LAYER 1 has LAYER RANK 1 and attirbutes defined by the various L1 fields L1S1 L1PR1,     L1HT, etc.
	     			#LAYER 2 has LAYER RANK 2 and attirbutes defined by the various L2 fields L2S1 L2PR1,     L2HT, etc.
	     			if ($Canopy >1 && $UCanopy >1) 
					{ 
						#(L1VS > 1 && L2VS > 1)
	       				$StandStructureCode = "C";  
					}
	    			else
					{
	      				$StandStructureCode = "M"; 
					}
	  			}
	 		}
	 		elsif($UCanopy == 0 || isempty($UCanopy)) 
			{ # L1VS == 0 or NULL && L2VS == 0 or NULL
	    
	   			if (!isempty($Sp1)) 
				{ #(L1S1 != NULL)
	    			if (!isempty($USp1))
					{ #(L2S1 != NULL) # We have two layers anyway.
	       				$NUMBER_OF_LAYERS =2;
	       				#LAYER 1 has LAYER RANK 1 and attirbutes defined by the various L1 fields L1S1 L1PR1,     L1HT, etc.
	      				#LAYER 2 has LAYER RANK 2 and attirbutes defined by the various L2 fields L2S1 L2PR1,     L2HT, etc.
	       				$StandStructureCode = "M";
	     			}
	     			else
					{
	       				$NUMBER_OF_LAYERS =  1;
	       				#LAYER 1 has LAYER RANK 1 and attirbutes defined by the various L1 fields L1S1 L1PR1,     L1HT, etc.
	       				$StandStructureCode = "S";
	     			}
	    		}
	    		else 
				{
					$NUMBER_OF_LAYERS =1;
					$particular=1;
					$StandStructureCode = "S";
					#$keys="particular null species and nblayer=1";
					#$herror{$keys}++;
	    			#LAYER 1 has LAYER RANK 1, but origin, height, density and species composition are "Missing"
	    			#If there is no .DST record, create one with type and other attributes coded Missing
				}
	  		}
			else 
			{
				$keys="l1VS==0 and L2VS !=0"."#".$Canopy."#".$UCanopy;
				$herror{$keys}++;
			}
		}

		# ======================================================= WRITING Output inventory info IN CAS FILES =======================================================================================================
		my $prod_for="PF";
		my $lyr_poly=1;
		if(isempty($Sp1) || $SpeciesComp eq "-1" || $SpeciesComp eq "")
		{
			$SpeciesComp ="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
			if ($UnProdFor ne MISSCODE && $UnProdFor ne ERRCODE && $UnProdFor ne UNDEF)
			{
				$prod_for=$UnProdFor;
			}
			elsif ( !is_missing($CCHigh) ||  !is_missing($CCLow) || !is_missing($HeightHigh) || !is_missing($HeightLow))
			{
				$prod_for="PP";	
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

	 	$CAS_Record = $CAS_ID . "," . $PolyNum . "," . $StandStructureCode .",". $NUMBER_OF_LAYERS.",". $IdentifyID . "," . $MapSheetID . "," . $Area . "," . $Perimeter . ",".$Area. ",".$PHOTOYEAR;
		print CASCAS $CAS_Record . "\n";  
		$StandStructureVal=UNDEF;

		if ($isundef1)
		{
			$OriginLow = UNDEF;
			$OriginHigh = UNDEF;
		}

		if ($isundef2)
		{
			$UOriginLow = UNDEF;
			$UOriginHigh = UNDEF;
		}
		#forested
		# if ((!isempty($Sp1) && $SpeciesComp ne "-1") || $particular==1  || ($UnProdFor ne MISSCODE && $UnProdFor ne ERRCODE && $UnProdFor ne UNDEF)) {
	 	if (!isempty($Sp1) ||  $lyr_poly ) 
		{
		    $LYR_Record1 = $CAS_ID . "," . $SMR  . "," . $StandStructureVal . ",1,1";
		    $LYR_Record2 = $CCHigh . "," . $CCLow . "," . $HeightHigh . "," . $HeightLow .",".$prod_for.",".$SpeciesComp;
		    $LYR_Record3 = $OriginHigh . "," . $OriginLow . "," . $SiteClass . "," . $SiteIndex ;
		    $Lyr_Record = $LYR_Record1 . "," . $LYR_Record2 . "," . $LYR_Record3;
		    print CASLYR $Lyr_Record . "\n";
		}
		elsif ($NatNonVeg ne  UNDEF || $NonVegAnth ne  UNDEF || $NonForVeg ne  UNDEF) 	#non-forested
		{
		    #if ($UnProdFor ne MISSCODE || $NonForAnth ne MISSCODE || $UnProdFor ne MISSCODE) {
		    $NFL_Record1 = $CAS_ID . "," . $SMR  . "," . $StandStructureVal . ",1,1";
		    $NFL_Record2 = $CCHigh . "," . $CCLow . "," . $HeightHigh . "," . $HeightLow;
		    $NFL_Record3 =$NatNonVeg.",".$NonVegAnth.",".$NonForVeg;
	        $NFL_Record = $NFL_Record1 . "," . $NFL_Record2 . "," . $NFL_Record3;
		    print CASNFL $NFL_Record . "\n";
		}
		if (!isempty($Mod)) 	 #Disturbance
		{
		    $DST_Record = $CAS_ID . "," . $Dist.",1";
		    print CASDST $DST_Record . "\n";
		}
		elsif ($particular==1) 
		{
		    $DST_Record = $CAS_ID . ",-1111,-1111,-1111,-1111,-1111,-1111,-1111,-1111,-1111,-1111,-1111,-1111,1";
		    print CASDST $DST_Record . "\n";
		}
		   
		if ($Wetland ne MISSCODE && $Wetland ne ERRCODE)    #Ecological 
		{  
		    $Wetland = $CAS_ID . "," . $Wetland."-";
		    print CASECO $Wetland . "\n";
		}
		# elsif($Wetland eq MISSCODE && $particular==1){
		      #$Wetland = $CAS_ID . ",-,-,-,-,-";
		      #print CASECO $Wetland . "\n";
		#}
	 
		if($NUMBER_OF_LAYERS == 2 || ($USpeciesComp eq "-1"  && $USp1 eq "NR" )|| ($SpeciesComp eq "-1" && $Sp1 eq "NR")) 
		{

			if((isempty($Sp1) && isempty($USp1)) || $USpeciesComp eq "-1" || $USpeciesComp eq "" || $SpeciesComp eq "-1" ) 
			{  #new rule from SC
				$keys="--- possible error to report to the data contributor- this 2nd layer will be ignored - understorey species null but nblayers=2"."#L1VS=".$Canopy."#L2VS=".$UCanopy."#FST=".$Forested."#acsid =".$CAS_ID;
				$herror{$keys}++;
				#$UnProdFor="UF";
				#$USpeciesComp="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
			}
			if (!isempty($USp1) && $USpeciesComp ne "-1") 
			{
		    	$LYR_Record1 = $CAS_ID . "," . $SMR  . "," . $StandStructureVal .",2,2";
		      	$LYR_Record2 = $UCCHigh . "," . $UCCLow . "," . $UHeightHigh . "," . $UHeightLow . "," . $prod_for.",".$USpeciesComp;
		        $LYR_Record3 = $UOriginHigh . "," . $UOriginLow . "," . $SiteClass . "," . $SiteIndex ;
		     	$Lyr_Record = $LYR_Record1 . "," . $LYR_Record2 . "," . $LYR_Record3;
		      	print CASLYR $Lyr_Record . "\n";
				#$keys="check this uspeciescomp $USpeciesComp";
				#$herror{$keys}++;
		    }

			#18-09-2012 at this time understory disturbance is not reported
			#if ($NUMBER_OF_LAYERS ==2 && ($UMod ne "" || $UOrig_Mod ne "" )) {
		    #	$DST_Record = $CAS_ID . "," . $UDist. ",2";
		    #	print CASDST $DST_Record . "\n";
		    #}
			#BK july 2014
			if ($NUMBER_OF_LAYERS ==2 && (!isempty($UMod)))
			{
		      	$DST_Record = $CAS_ID . "," . $UDist.",2";
		      	print CASDST $DST_Record . "\n";
		    }
		}
	}

	# Close csv file
	$csv->eof or $csv->error_diag ();
	close $NBinv;

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

	close (CASHDR);
	close (CASCAS);
	close (CASLYR);
	close (CASNFL);
	close (CASDST);
	close (CASECO);
	close(SPERRSFILE); 
	close(SPECSLOGFILE); 
	close(ERRS);
}


1;
#province eq "NB";

