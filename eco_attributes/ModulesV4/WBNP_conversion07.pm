package ModulesV4::WBNP_conversion07;


use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(&WBNPinv_to_CAS );
our @EXPORT_OK = qw(@tabSpec);      

#our @EXPORT_OK = qw(@tabSpec &SoilMoistureRegime1 &SoilMoistureRegime2  &CCUpper  &CCLower &StandHeightUp &StandHeightLow &UpperOrigin &UpperOriginCompl &LowerOrigin &LowerOriginCompl  &Disturbance &DisturbanceM );

use strict;
use Text::CSV;
our @tabSpec;
our $Species_table;	
use constant {
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
#up to 3 layers  TODO
sub StandStructure
{
	my $Age;
	my $StandStructure;

	($Age) = shift(@_);

	if(isempty($Age)) {$StandStructure = MISSCODE;}
	elsif( length($Age) >3 ) {
				$StandStructure = "M";
			      }
	elsif ( length($Age) >1 ) { $StandStructure = "S"; } 

	else                 { $StandStructure = ERRCODE; }
	
	return $StandStructure;
}

#from v#moi
sub SoilMoistureRegime
{
	my $MoistReg;
	my %MoistRegList = ("", 1, "1", 1, "2", 1, "3", 1, "0", 1);

	my $SoilMoistureReg;

	($MoistReg) = shift(@_);  
	
	if  (isempty($MoistReg))            { $SoilMoistureReg = MISSCODE; }
	elsif (!$MoistRegList {$MoistReg} ) { $SoilMoistureReg = ERRCODE; }

	elsif (($MoistReg eq "1") )           { $SoilMoistureReg = "W"; }
	elsif (($MoistReg eq "2"))         { $SoilMoistureReg = "F"; }
	elsif (($MoistReg eq "3"))         { $SoilMoistureReg = "D"; }
	elsif (($MoistReg eq "0"))         { $SoilMoistureReg = MISSCODE; }
	else                               { $SoilMoistureReg = ERRCODE; }
	
	return $SoilMoistureReg;
}

#Determine CCUpper from Density  v#PCT

sub CCUpper 
{
	my $CCHigh;
	my $CC; 
	($CC) = shift(@_);  
	if (defined $CC){} else {$CC ="";}
	
    if (isempty($CC)) { $CCHigh = MISSCODE; }
	elsif ($CC == 0)  { $CCHigh = 9; }
	elsif ($CC == 1)  { $CCHigh = 19; }
	elsif ($CC == 2)  { $CCHigh = 29; }
	elsif ($CC == 3)  { $CCHigh = 39; }
    elsif ($CC == 4)  { $CCHigh = 49; }
	elsif ($CC == 5)  { $CCHigh = 59; }
	elsif ($CC == 6)  { $CCHigh = 69; }
	elsif ($CC == 7)  { $CCHigh = 79; }
    elsif ($CC == 8)  { $CCHigh = 89; }
	elsif ($CC == 9)  { $CCHigh = 100; }
	else { $CCHigh = ERRCODE; }

	return $CCHigh;
}

sub CCLower 
{
	my $CCLow;
	my $CC;
    ($CC) = shift(@_); 
	if (defined $CC){} else {$CC ="";}

	if (isempty($CC)) { $CCLow = MISSCODE; }
	elsif ($CC == 0)  { $CCLow = 0; }
	elsif ($CC == 1)  { $CCLow = 10; }
	elsif ($CC == 2)  { $CCLow = 20; }
	elsif ($CC == 3)  { $CCLow = 30; }
    elsif ($CC == 4)  { $CCLow = 40; }
	elsif ($CC == 5)  { $CCLow = 50; }
	elsif ($CC == 6)  { $CCLow = 60; }
	elsif ($CC == 7)  { $CCLow = 70; }
    elsif ($CC == 8)  { $CCLow = 80; }
	elsif ($CC == 9)  { $CCLow = 90; }
	else { $CCLow = ERRCODE; }

	return $CCLow;
}

#Determine upper bound stand height from v#HTC
sub StandHeightUp 
{
	my $Height;
	my %HeightList = ("", 1, "1", 1,  "2", 1, "3", 1, "0", 1, "13", 1,  "14", 1, "23", 1, "24", 1, "34", 1,  "35", 1, "45", 1);
	my $HUpp;

	($Height) = shift(@_);
	

	if  (isempty($Height))           { $HUpp = MISSCODE; }
	elsif (!$HeightList {$Height} ) { $HUpp = ERRCODE; }
	elsif (($Height eq "0"))  		  			{ $HUpp = MISSCODE; } 
	elsif (($Height eq "1"))                  { $HUpp = 5; } 
	elsif (($Height eq "2"))                  { $HUpp = 10; }
	elsif (($Height eq "3"))                  { $HUpp = 15; }
	elsif (($Height eq "13"))  		  			{ $HUpp = 15; } 
	elsif (($Height eq "14"))                  { $HUpp = 20; } 
	elsif (($Height eq "23"))                  { $HUpp = 10; }
	elsif (($Height eq "24"))                  { $HUpp = 15; }	
	elsif (($Height eq "34"))  		  { $HUpp = 20; } 
	elsif (($Height eq "35"))                  { $HUpp = 20; } 
	elsif (($Height eq "45"))                  { $HUpp = 26; }
	
	return $HUpp;
}


#Determine lower bound stand height from Height v#HTC
sub StandHeightLow {
	my $Height;
	my %HeightList = ("", 1, "1", 1,  "2", 1, "3", 1, "0", 1, "13", 1,  "14", 1, "23", 1, "24", 1, "34", 1,  "35", 1, "45", 1);
	my $HLow;

	($Height) = shift(@_);
	
	if  (isempty($Height))                    { $HLow = MISSCODE; }
	elsif (!$HeightList {$Height} )   { $HLow = ERRCODE; }

	elsif (($Height eq "0"))  	       	  { $HLow = MISSCODE; } 
	elsif (($Height eq "1"))                  { $HLow = 1; } 
	elsif (($Height eq "2"))                  { $HLow = 6; }
	elsif (($Height eq "3"))                  { $HLow = 11; }	
	elsif (($Height eq "13"))  	          { $HLow = 1; } 
	elsif (($Height eq "14"))                 { $HLow = 1; } 
	elsif (($Height eq "23"))                 { $HLow = 6; }
	elsif (($Height eq "24"))                 { $HLow = 6; }
	elsif (($Height eq "34"))  	          { $HLow = 11; } 
	elsif (($Height eq "35"))                 { $HLow = 11; } 
	elsif (($Height eq "45"))                 { $HLow = 16; }

	return $HLow;
	            		       
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

 
#Determine Species from the 4 species v#SP# 

sub Species
{
	#my $Spec    = shift(@_);
	my $Sp1Per=0;my $Sp2Per=0;my $Sp3Per=0;my $Sp4Per=0;
	my $Sp1c= shift(@_); 
	my $Sp2c= shift(@_); 
	my $Sp3c= shift(@_);
	my $Sp4c= shift(@_);
	my $spfreq=shift(@_);

	if(defined $Sp1c && !isempty($Sp1c)){} else {$Sp1c="";}	
	if(defined $Sp2c && !isempty($Sp2c)){} else {$Sp2c="";}
	if(defined $Sp3c && !isempty($Sp3c)){} else {$Sp3c="";} 
	if(defined $Sp4c && !isempty($Sp4c)){} else {$Sp4c="";}

	my $Species;
	my $notnull=0;
		
	my $Sp1;my $Sp2;my $Sp3;my $Sp4;

	#$Sp1c=(substr $Spec, 0, 2);
	#my $lt= length($Spec);
	#if($lt >2){
			#$Sp2c=(substr $Spec, 2, 2);
	#}
	#if($lt >4){ 
			#$Sp3c=(substr $Spec, 4, 2);
	#}
 

	if(!isempty($Sp1c)){$notnull++; $spfreq->{$Sp1c}++;}
	if(!isempty($Sp2c)){$notnull++; $spfreq->{$Sp2c}++;}
	if(!isempty($Sp3c)){$notnull++; $spfreq->{$Sp3c}++;}
	if(!isempty($Sp4c)){$notnull++; $spfreq->{$Sp4c}++;}

		if($notnull==1)
			{
					$Sp1Per=100;$Sp2Per=0;
			}
		elsif($notnull==2) {  
					$Sp1Per=70;$Sp2Per=30;
					
			}
		elsif($notnull==3) {  
					$Sp1Per=40;$Sp2Per=30;$Sp3Per=30;
					
			}
		elsif($notnull==4 ){  
					
					$Sp1Per=35;$Sp2Per=35;$Sp3Per=15;$Sp4Per=15;		
			}
 
	$Sp1 = Latine($Sp1c); 
	if($Sp1 eq SPECIES_ERRCODE) {
				if( $Sp1c eq "ER" ||  $Sp1c eq "GR" || $Sp1c eq "GC"  ){}
				else {print "unrecognised species 1 $Sp1c\n"; }
	}

	$Sp2 = Latine($Sp2c); 
	if($Sp2 eq SPECIES_ERRCODE) {
				if( $Sp2c eq "ER" ||  $Sp2c eq "GR" || $Sp2c eq "GC"  ){}
				else {print "unrecognised species 2 $Sp2c (SP1= $Sp1)\n"; } 
	}

	$Sp3 = Latine($Sp3c); 
	if($Sp3 eq SPECIES_ERRCODE) {
				if( $Sp3c eq "ER" ||  $Sp3c eq "GR" || $Sp3c eq "GC"  ){}
				else{print "unrecognised species 3 $Sp3c (SP1= $Sp1)\n"; } 	
	}	
	 
	$Sp4 = Latine($Sp4c); 
	if($Sp4 eq SPECIES_ERRCODE) {
				if( $Sp4c eq "ER" ||  $Sp4c eq "GR" || $Sp4c eq "GC" ){}
				else{print "unrecognised species 4 $Sp4c (SP1= $Sp1)\n"; } 
	}
	
	$Species = $Sp1 . "," . $Sp1Per . "," . $Sp2 . "," . $Sp2Per. "," . $Sp3 . "," . $Sp3Per. "," . $Sp4 . "," . $Sp4Per;

	return $Species;
}



#No Age Field. 
 
#v#PCM    

#NonForestedVeg ---ST, SL, HF, HE, HG, BR, OM, TN
    # * Ericaceous Shrubs=ER=SL(CAS)
    #* Graminoids (grasses)=GR=HG(CAS)
   # * Herb/Graminoids=GC=HE(CAS)
   # * BC does not show in the metadata list. Is this an error? How often does it appear?
   # * Alder=AL=ST(CAS). Alder in WBNP is a shrub species and should be considered in the NonVegNonFor CAS field.
   # * Willow=WW=ST(CAS). Willow in WBNP is a shrub species and should be considered in the NonVegNonFor CAS field.
    
#these are new rules from SC
sub NonForestedVeg 
{

    my $NonForVeg = shift(@_);  #my $SP1 = shift(@_); my $SP2 = shift(@_); my $SP3 = shift(@_); my $SP4= shift(@_);
	my %NonForVegList = ("", 1, "1", 1, "2", 1, "3", 1, "4", 1, "5", 1,  "98", 1, "7", 1, "13", 1, "17", 1, "18", 1, "6", 1, "99", 1,"0", 1);
	my $NonForVegRes;

	
	if  (isempty($NonForVeg))					{ $NonForVegRes = MISSCODE; }
	elsif (!$NonForVegList {$NonForVeg} )  { $NonForVegRes = ERRCODE; }

	elsif (($NonForVeg eq "1") || ($NonForVeg eq "2")|| ($NonForVeg eq "3")) { $NonForVegRes = "HG"; }
	elsif (($NonForVeg eq "4") || ($NonForVeg eq "5")|| ($NonForVeg eq "6")) { $NonForVegRes = "HG"; }
	elsif (($NonForVeg eq "98"))	{ $NonForVegRes = "SL"; }
	elsif (($NonForVeg eq "7"))	{ $NonForVegRes = "ST"; }
	elsif (($NonForVeg eq "17"))	{ $NonForVegRes = "BR"; }
	elsif (($NonForVeg eq "13"))	{ $NonForVegRes = "HE"; }
	elsif (($NonForVeg eq "18") )	{ $NonForVegRes = "OM"; }
	elsif (($NonForVeg eq "99") )	{ $NonForVegRes = "HG"; }
	elsif (($NonForVeg eq "0") )	{ $NonForVegRes = "EX"; }
	else 				{ $NonForVegRes = ERRCODE; }
	return $NonForVegRes;

}

#disturbance from   v#PCM      v#STR            erob#     eros#
# extent from v#PCT

#Need to access more than one field. Erosion (eros#): A, F, G, K, S, W, KA, FG = OT; M, MG, MF = SL. Severe fire use v#PCM code 13 = BU or v#STR code D = BU
sub Disturbance_old {
	my $Mod;
	my $Disturbance;
	my $ModYr;
	my %ModList = ("", 1, "A", 1, "F", 1, "G", 1, "K", 1, "S", 1,"W", 1, "KA", 1, "FG", 1, "M", 1, "MG", 1, "MF", 1,"13", 1, "D", 1);

	my ($eros) = shift(@_);
	my ($vPCM) = shift(@_);
	my ($vSTR) = shift(@_);
	
	$ModYr=UNDEF;  

	if ($ModList{$eros} ||  $ModList{$vPCM} || $ModList{$vSTR}) { 

		if ($eros ne "" || $vPCM ne "" || $vSTR ne "") { 

 				if (($eros  eq "A") || ($eros eq "F")|| ($eros eq "G")|| ($eros eq "K")) { $Mod="OT"; }
				elsif (($eros  eq "S") || ($eros eq "W")  || ($eros eq "KA") || ($eros eq "FG")) { $Mod="OT"; }
				elsif (($eros  eq "M") || ($eros eq "MG") || ($eros eq "MF")) { $Mod="SL"; }
				elsif (($vPCM  eq "13")) { $Mod="BU"; }	
				elsif (($vSTR  eq "D")) { $Mod="BU"; }

				$Disturbance = $Mod . "," . $ModYr; 
	        }
	 	else { $Disturbance = MISSCODE. "," . $ModYr; }

	} else { $Mod = ERRCODE; $Disturbance = $Mod . "," . $ModYr;  }

	return $Disturbance;
}

sub Disturbance
{
	 
	my $Mod;
	my $ModYr;
	my $Disturbance;
	
	my %ModList = ("D", 1);

	my ($vSTR) = shift(@_);
	if(defined $vSTR){} else {$vSTR="";}
	
	$ModYr=UNDEF;  

	if(isempty($vSTR)) { $Disturbance = MISSCODE. "," . $ModYr; }
	elsif ($ModList{$vSTR}) 
	{ 
		$Mod = "BU";
		$Disturbance = $Mod . "," . $ModYr; 
	} 
	 
	else { $Mod = ERRCODE; $Disturbance = $Mod . "," . $ModYr;  }

	return $Disturbance;
}


#v#pct  if v#PCM has been used in Disturbance function
sub DisturbanceExtUpper 
{
    my $ModExt;
    my $DistExtUpper;
	my %DistExtList = ("", 1, "0", 1, "1", 1, "2", 1, "3", 1, "4", 1, "5", 1, "6", 1, "7", 1, "8", 1, "9", 1);


    ($ModExt) = shift(@_);

	
	if (isempty($ModExt)) { $DistExtUpper = 0; }
	elsif (!$DistExtList{$ModExt} )  {$DistExtUpper = UNDEF; }

	elsif ($ModExt == 0)  { $DistExtUpper = 9; }
	elsif ($ModExt == 1)  { $DistExtUpper = 19; }
	elsif ($ModExt == 2)  { $DistExtUpper = 29; }
	elsif ($ModExt == 3)  { $DistExtUpper = 39; }
    elsif ($ModExt == 4)  { $DistExtUpper = 49; }
	elsif ($ModExt == 5)  { $DistExtUpper = 59; }
	elsif ($ModExt == 6)  { $DistExtUpper = 69; }
	elsif ($ModExt == 7)  { $DistExtUpper = 79; }
	elsif ($ModExt == 8)  { $DistExtUpper = 89; }
	elsif ($ModExt == 9)  { $DistExtUpper = 100; }
	 
    return $DistExtUpper;
}

sub DisturbanceExtLower 
{
    my $ModExt;
    my $DistExtLower;

	my %DistExtList = ("", 1, "0", 1, "1", 1, "2", 1, "3", 1, "4",1,"5",1, "6", 1, "7", 1, "8", 1, "9", 1);


    ($ModExt) = shift(@_);

	
	if (isempty($ModExt)) { $DistExtLower = 0; }
	elsif (!$DistExtList{$ModExt} )  {$DistExtLower = UNDEF; }

	elsif ($ModExt == 0)  { $DistExtLower = 0; }
	elsif ($ModExt == 1)  { $DistExtLower = 10; }
	elsif ($ModExt == 2)  { $DistExtLower = 20; }
	elsif ($ModExt == 3)  { $DistExtLower = 30; }
    elsif ($ModExt == 4)  { $DistExtLower = 40; }
	elsif ($ModExt == 5)  { $DistExtLower = 50; }
	elsif ($ModExt == 6)  { $DistExtLower = 60; }
	elsif ($ModExt == 7)  { $DistExtLower = 70; }
	elsif ($ModExt == 8)  { $DistExtLower = 80; }
    elsif ($ModExt == 9)  { $DistExtLower = 90; }

    return $DistExtLower;
}


#v#PCM:7(willow-alder thicket); 98(ericaceous shrubland); 99 (meadows); 1,2,3,4,5,6(meadows);17(wet muskeg); 18(shrub muskeg); 20,21(b-spruce)

#v#STR:ST(shrubland thicket);M(graminoid/sedge prairie);N(fen);P(treed peatbog);PG(wet graminoid muskeg);PGC(wet graminoid-herb muskeg);PST(shrub muskeg); MST(gr & shr)

#can derive wetland from v#PCM and v#STR  v#moi

sub WetlandCodes 
{
	my $vPCM = shift(@_);
	my $vSTR = shift(@_);
	my $WetlandCode = "";	 
	
	
	if(isempty $vPCM ){$vPCM="";}
	if(isempty $vSTR ) {$vSTR="";}
	$_ = $vSTR;tr/a-z/A-Z/; $vSTR = $_;

	 if($vPCM eq  "7" )  
	    { $WetlandCode = "S,O,N,S,"; }
	 elsif($vPCM eq "1" || $vPCM eq "2" ||$vPCM eq "3" ||$vPCM eq "4" ||$vPCM eq "5" ||$vPCM eq "6" )  
	    { $WetlandCode = "M,O,N,G,"; }
	 elsif($vPCM eq  "98" )  
	    { $WetlandCode = "S,O,N,S,"; }
	 elsif($vPCM eq  "99" )  
	    { $WetlandCode = "M,O,N,G,"; }
	 elsif($vPCM eq  "17" )  
	    { $WetlandCode = "F,O,N,G,"; }
	 elsif($vPCM eq  "18" )  
	    { $WetlandCode = "S,O,N,S,"; }#?Sons
	 elsif($vPCM eq  "20")  
	    { $WetlandCode = "B,T,N,N,"; }  #?Stnn
	 elsif($vPCM eq  "21"  )  
	    { $WetlandCode = "F,T,N,N,"; }
	 elsif( $vPCM eq  "22"  )  
	    { $WetlandCode = "S,T,N,N,"; }


 	 elsif($vSTR eq  "ST" )  
	    { $WetlandCode = "S,O,N,S,"; }
	 elsif($vSTR eq  "M" )  
	    { $WetlandCode = "M,O,N,G,"; }
	 elsif($vPCM eq  "19" && $vSTR eq  "N" )  
	    { $WetlandCode = "F,T,N,N,"; }
	 elsif($vPCM eq  "19" &&  $vSTR eq  "P" )  
	    { $WetlandCode = "B,T,N,N,"; }
 	 elsif($vSTR eq  "PG" )  
	    { $WetlandCode = "F,O,N,G,"; }
	 elsif($vSTR eq  "PGC" )  
	    { $WetlandCode = "M,O,N,G,"; }
	 elsif($vSTR eq  "PST" )  
	    { $WetlandCode = "F,O,N,S,"; }
	 elsif($vSTR eq  "MST" )  
	    { $WetlandCode = "S,O,N,S,"; }
	
	 else {$WetlandCode = ERRCODE;}


	if ($WetlandCode eq "") {$WetlandCode = MISSCODE;}# MISSCODE.",".MISSCODE.",".MISSCODE.",".MISSCODE.",";
	return $WetlandCode;
	
}																																																																																																																																																																																																														
  


sub WBNPinv_to_CAS 
{

	my $WBNP_File = shift(@_);
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

	if($optgroups==1){

	 	$CAS_File_HDR = $pathname."/WBNPtable.hdr";
	 	$CAS_File_CAS = $pathname."/WBNPtable.cas";
	 	$CAS_File_LYR = $pathname."/WBNPtable.lyr";
	 	$CAS_File_NFL = $pathname."/WBNPtable.nfl";
	 	$CAS_File_DST = $pathname."/WBNPtable.dst";
	 	$CAS_File_ECO = $pathname."/WBNPtable.eco";
	}
	elsif($optgroups==2){

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
	print CASLYR "CAS_ID,SOIL_MOIST_REG,STRUCTURE_PER,LAYER,LAYER_RANK,CROWN_CLOSURE_UPPER,CROWN_CLOSURE_LOWER,HEIGHT_UPPER,HEIGHT_LOWER,PRODUCTIVE_FOR,". 		
	"SPECIES_1,SPECIES_PER_1,SPECIES_2,SPECIES_PER_2,SPECIES_3,SPECIES_PER_3,SPECIES_4,SPECIES_PER_4,SPECIES_5,SPECIES_PER_5,SPECIES_6,SPECIES_PER_6,SPECIES_7,SPECIES_PER_7,".
	"SPECIES_8,SPECIES_PER_8,SPECIES_9,SPECIES_PER_9,SPECIES_10,SPECIES_PER_10,ORIGIN_UPPER,ORIGIN_LOWER,SITE_CLASS,SITE_INDEX\n";
	print CASNFL "CAS_ID,SOIL_MOIST_REG,STRUCTURE_PER,LAYER,LAYER_RANK,CROWN_CLOSURE_UPPER,CROWN_CLOSURE_LOWER,HEIGHT_UPPER,HEIGHT_LOWER,NAT_NON_VEG,NON_FOR_ANTH,NON_FOR_VEG\n";
	print CASDST "CAS_ID,DIST_1,DIST_YR_1,DIST_EXT_UPPER_1,DIST_EXT_LOWER_1,DIST_2,DIST_YR_2,DIST_EXT_UPPER_2,DIST_EXT_LOWER_2,DIST_3,DIST_YR_3,DIST_EXT_UPPER_3,DIST_EXT_LOWER_3,LAYER\n";
	print CASECO "CAS_ID,WETLAND_TYPE,WET_VEG_COVER,WET_LANDFORM_MOD,WET_LOCAL_MOD,ECO_SITE\n";
	print CASHDR "IDENTIFICATION_ID,JURISDICTION,COORDINATE_SYS,PROJECTION,DATUM,INVENTORY_OWNER,LAND_OWNER,PERMISSION,TENURE_TYPE,INV_TYPE,INV_VERSION,INV_START_YR,INV_FINISH_YR,INV_ACQ_ID,INV_ACQ_YR,INV_UPDATE_YR\n";


	my $HDR_Record =  "2,PC,,,NAD27,FED_GOV (WoodBuffalo National Park),,RESTRICTED,,,,1975,1979,,,";
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

	my $CAS_ID; my $IdentifyID;my $StandID;my $MapSheetID;my $Area; my $Perimeter;
	my $pr1; my $pr2; my $pr3; my $pr4; my $pr5;
	my $SMR1; my $SMR2; my $SMR3; my $SMR4; my $SMR5; my $SMR6; my $SMR7; 
	my $StandStructureCode;my $StandStructureVal1; my $StandStructureVal2; my $StandStructureVal3;
	my $StandStructureVal4; my $StandStructureVal5; my $StandStructureVal6;my $StandStructureVal7;
	my $CCHigh1;my $CCLow1; my $HeightHigh1; my $HeightLow1;
	my $CCHigh2;my $CCLow2; my $HeightHigh2; my $HeightLow2;
	my $CCHigh3;my $CCLow3; my $HeightHigh3; my $HeightLow3;
	my $CCHigh4;my $CCLow4; my $HeightHigh4; my $HeightLow4;
	my $CCHigh5;my $CCLow5; my $HeightHigh5; my $HeightLow5;
	my $CCHigh6;my $CCLow6; my $HeightHigh6; my $HeightLow6;
	my $CCHigh7;my $CCLow7; my $HeightHigh7; my $HeightLow7;
	my $Wetland1; my $Wetland2; my $Wetland3; my $Wetland4; my $Wetland5; my $Wetland6; my $Wetland7;
	my $SpeciesComp;
	my $SpeciesComp1; my $SpeciesComp2;my $SpeciesComp3;my $SpeciesComp4; my $SpeciesComp5;my $SpeciesComp6;my $SpeciesComp7;
	my $SiteClass; my $SiteIndex; my $StrucVal;
	my $OriginHigh; my $OriginLow; 
	my $NonForVeg1; my $NonForVeg2;my $NonForVeg3;my $NonForVeg4;my $NonForVeg5;my $NonForVeg7;my $NonForVeg6;
	my $NonForAnth; my $NatNonVeg;# my $NonForAnth2; my $NatNonVeg2; my $NonForAnth3; my $NatNonVeg3;
	 #my $NonForAnth4; my $NatNonVeg4; my $NonForAnth5; my $NatNonVeg5; my $NonForAnth6; my $NatNonVeg6;
	 #my $NonForAnth7; my $NatNonVeg7;   
	my %herror=();
	my $keys;

	my $AREA1; my $AREA2; my $AREA3; my $AREA4; my $AREA5; my $AREA6;my $AREA7;
	my $CAS_Record;
	#my $CAS_Record1; my $CAS_Record2; my $CAS_Record3; my $CAS_Record4; my $CAS_Record5; my $CAS_Record6;  my $CAS_Record7; 
	 my $LYR_Record11; my $LYR_Record21; my $LYR_Record31;my $Lyr_Record41;
	 my $LYR_Record12; my $LYR_Record22; my $LYR_Record32;my $Lyr_Record42;
	 my $LYR_Record13; my $LYR_Record23; my $LYR_Record33;my $Lyr_Record43;
	 my $LYR_Record14; my $LYR_Record24; my $LYR_Record34;my $Lyr_Record44;
	 my $LYR_Record15; my $LYR_Record25; my $LYR_Record35;my $Lyr_Record45;
	 my $LYR_Record16; my $LYR_Record26; my $LYR_Record36;my $Lyr_Record46;
	 my $LYR_Record17; my $LYR_Record27; my $LYR_Record37;my $Lyr_Record47;
	#my $Lyr_Record51; my $LYR_Record61; my $LYR_Record71;  
	#my $Lyr_Record52; my $LYR_Record62; my $LYR_Record72;  
	#my $Lyr_Record53; my $LYR_Record63; my $LYR_Record73; 

	my $NFL_Record1; my $NFL_Record11; my $NFL_Record21; my $NFL_Record31; 
	my $NFL_Record2; my $NFL_Record12; my $NFL_Record22; my $NFL_Record32;
	my $NFL_Record3; my $NFL_Record13; my $NFL_Record23; my $NFL_Record33;
	my $NFL_Record4; my $NFL_Record14; my $NFL_Record24; my $NFL_Record34;
	my $NFL_Record5; my $NFL_Record15; my $NFL_Record25; my $NFL_Record35;
	my $NFL_Record6; my $NFL_Record16; my $NFL_Record26; my $NFL_Record36; 
	my $NFL_Record7; my $NFL_Record17; my $NFL_Record27; my $NFL_Record37; 

	my $DST_Record1; my $DST_Record2; my $DST_Record3; my $DST_Record4; my $DST_Record5; my $DST_Record6; my $DST_Record7; 


	my  $CC1;my $CC2; my $CC3;my  $CC4;my $CC5; my $CC6;my $CC7;
	my $Dist1;my $Dist2;my $Dist3;my $Dist4;my $Dist5;my $Dist6;my $Dist7;
	my $Dist1ExtHigh; my $Dist1ExtLow;my $Dist2ExtHigh; my $Dist2ExtLow;my $Dist3ExtHigh; my $Dist3ExtLow;my $Dist4ExtHigh; my $Dist4ExtLow;my $Dist5ExtHigh; my $Dist5ExtLow;my $Dist6ExtHigh; my $Dist6ExtLow;my $Dist7ExtHigh; my $Dist7ExtLow;
	my @SpecsPerList1=(); my $cpt_ind;
	my @SpecsPerList2=();my @SpecsPerList3=();my @SpecsPerList4=();my @SpecsPerList5=();my @SpecsPerList6=();my @SpecsPerList7=();

	my $IsNFL1=0; my $IsNFL2=0; my $IsNFL3=0; my $IsNFL4=0; my $IsNFL5=0; my $IsNFL6=0; my $IsNFL7=0; 
	my $csv = Text::CSV_XS->new({  binary              => 1,
				       sep_char => ";"   });
        open my $WBNPinv, "<", $WBNP_File or die " \n Error: Could not open QC input file $WBNP_File: $!";
	
	my @tfilename= split ("/", $WBNP_File);
	my $nps=scalar(@tfilename);
	$Glob_filename= $tfilename[$nps-1];


 	$csv->column_names ($csv->getline ($WBNPinv));

	#CAS_ID	HEADER_ID	class	area	perimeter	parkn	oldtyno	squkm	mapno	diSTR	systm	subsy	shrln	pfrst	depth	perd1	perd2	petr1	petr2	formg	krost	ocrop	ufeat	feat1	feat2	eleV1	eleV2	wildl	bveg1	bveg2	bveg3	bveg4	bveg5	bveg6	bveg7	bveg8	bveg9	spare1	slm01	slr01	sld01	sls01	slp01	slm02	slr02	sld02	sls02	slp02	slm03	slr03	sld03	sls03	slp03	matr1	eros1	pcnt1	STRt1	bedr1	erob1	slop1	aspc1	matr2	eros2	pcnt2	STRt2	bedr2	erob2	slop2	aspc2	matr3	eros3	pcnt3	STRt3	bedr3	spare2	vegct	moict	
	#V1PCM	V1STR	V1SP1	V1SP2	V1SP3	V1SP4	spare3	V1HTC	V1pct	V1moi	
	#V2PCM	V2STR	V2SP1	V2SP2	V2SP3	V2SP4		V2HTC	V2pct	V2moi	
	#V3PCM	V3STR	V3SP1	V3SP2	V3SP3	V3SP4		V3HTC	V3pct	V3moi	
	#V4PCM	V4STR	V4SP1	V4SP2	V4SP3	V4SP4		V4HTC	V4pct	V4moi	
	#V5PCM	V5STR	V5SP1	V5SP2	V5SP3	V5SP4		V5HTC	V5pct	V5moi	
	#V6PCM	V6STR	V6SP1	V6SP2	V6SP3	V6SP4		V6HTC	V6pct	V6moi	
	#V7PCM	V7STR	V7SP1	V7SP2	V7SP3	V7SP4		V7HTC	V7pct	V7moi	diSTR_na 	#systm_na																																																																																																																	


	while (my $row = $csv->getline_hr ($WBNPinv)) 
	{	 
	 
		$IsNFL1=0;
		$IsNFL2=0; 
		$IsNFL3=0; 
		$IsNFL4=0; 
		$IsNFL5=0; 
		$IsNFL6=0;
		$IsNFL7=0; 
		$Glob_CASID   =  $row->{CAS_ID};
		($pr1,$pr2,$pr3, $pr4, $pr5)     =  split("-", $row->{CAS_ID} );  
		$CAS_ID = $row->{CAS_ID}; 	
	    $MapSheetID   =  $pr3;
	    $MapSheetID =~ s/x+//;
		$IdentifyID = $row->{HEADER_ID};  
		# faut-t-il supprimer les 0 du d/but? si oui faire la ligne suivante, sinon la supprimer
		$StandID = $pr4;
		$StandID =~ s/^0+//;
		  
	        
		
		$Area    =  $row->{GIS_AREA};
		$Perimeter =  $row->{GIS_PERI};	


		$SMR1 = SoilMoistureRegime($row->{V1MOI});	 $SMR2 = SoilMoistureRegime($row->{V2MOI});	 $SMR3 = SoilMoistureRegime($row->{V3MOI});
		$SMR4 = SoilMoistureRegime($row->{V4MOI});	 $SMR5 = SoilMoistureRegime($row->{V5MOI});	 $SMR6 = SoilMoistureRegime($row->{V6MOI}); 
		$SMR7 = SoilMoistureRegime($row->{V7MOI});
		
	 	if($SMR1 eq ERRCODE || $SMR2 eq ERRCODE || $SMR3 eq ERRCODE || $SMR4 eq ERRCODE || $SMR5 eq ERRCODE || $SMR6 eq ERRCODE || $SMR7 eq ERRCODE )	{ 
						$keys="soilmoisture1to7"."#".$row->{V1MOI}."#".$row->{V2MOI}."#".$row->{V3MOI}."#".$row->{V4MOI}."#".$row->{V5MOI}."#".$row->{V6MOI}."#".$row->{V7MOI}."#";
				 		$herror{$keys}++;
		}


		$StandStructureCode = "H"; 
		$StandStructureVal1     =  $row->{V1PCT}*10;  #or $row->{pcnt1}
	 	$StandStructureVal2     =  $row->{V2PCT}*10;  
	 	$StandStructureVal3     =  $row->{V3PCT}*10; 
	 	$StandStructureVal4     =  $row->{V4PCT}*10;   
	 	$StandStructureVal5     =  $row->{V5PCT}*10;   
	 	$StandStructureVal6     =  $row->{V6PCT}*10;  
	 	$StandStructureVal7     =  $row->{V7PCT}*10; 

 		if($StandStructureVal1 >100 || $StandStructureVal1 <0) 
		{		$keys="standSTRuctureval1"."#".$StandStructureVal1."#";
			 		$herror{$keys}++;
		}
 	  	if($StandStructureVal2 >100 || $StandStructureVal2 <0) 
		{		$keys="standSTRuctureval2"."#".$StandStructureVal2."#";
			 		$herror{$keys}++;
		} 
 	  	if($StandStructureVal3 >100 || $StandStructureVal3 <0)  
		{		$keys="standSTRuctureval3"."#".$StandStructureVal3."#";
			 		$herror{$keys}++;
		}
    	if($StandStructureVal4 >100 || $StandStructureVal4 <0)  
		{		$keys="standSTRuctureval4"."#".$StandStructureVal4."#";
			 		$herror{$keys}++;
		}
 	  	if($StandStructureVal5 >100 || $StandStructureVal5 <0)  
		{		$keys="standSTRuctureval5"."#".$StandStructureVal5."#";
			 		$herror{$keys}++;
		}
 	  	if($StandStructureVal6 >100 || $StandStructureVal6 <0)  
		{		$keys="standSTRuctureval6"."#".$StandStructureVal6."#";
			 		$herror{$keys}++;
		}
	  	if($StandStructureVal7 >100 || $StandStructureVal7 <0)  
		{		$keys="standSTRuctureval7"."#".$StandStructureVal7."#";
			 		$herror{$keys}++;
		}
		my $totalpct=$StandStructureVal1 +$StandStructureVal2+$StandStructureVal3+$StandStructureVal4+$StandStructureVal5+$StandStructureVal6+$StandStructureVal7;


		#if($totalpct == 90 || $totalpct == 80){ 
				#if($row->{V1SP1} ne "" && $StandStructureVal1 ==0){$StandStructureVal1=100-$totalpct;}
				#elsif($row->{V2SP1} ne "" && $StandStructureVal2 ==0){$StandStructureVal2=100-$totalpct;}
				#elsif($row->{V3SP1} ne "" && $StandStructureVal3 ==0){$StandStructureVal3=100-$totalpct;}
				#elsif($row->{V4SP1} ne "" && $StandStructureVal4 ==0){$StandStructureVal4=100-$totalpct;}
				#elsif($row->{V5SP1} ne "" && $StandStructureVal5 ==0){$StandStructureVal5=100-$totalpct;}
				#elsif($row->{V6SP1} ne "" && $StandStructureVal6 ==0){$StandStructureVal6=100-$totalpct;}
				#elsif($row->{V7SP1} ne "" && $StandStructureVal7 ==0){$StandStructureVal7=100-$totalpct;}
		#}

		#my $totalpct=$StandStructureVal1 +$StandStructureVal2+$StandStructureVal3+$StandStructureVal4+$StandStructureVal5+$StandStructureVal6+$StandStructureVal7;



 		#if($totalpct !=100 && $totalpct !=0  )  {
			#	$keys="stand percentage !=100"."#".$totalpct. "#standpct1#".$row->{V1pct}."#leading species#".$row->{V1SP1}."#standpct2#".$row->{V2pct}."#leading species#".$row->{V2SP1}."#standpct3#".$row->{V3pct}."#leading species#".$row->{V3SP1}. "#standpct4#".$row->{V4pct}."#leading species#".$row->{V4SP1}."#standpct5#".$row->{V5pct}."#leading species#".$row->{V5SP1}."#standpct6#".$row->{V6pct}."#leading species#".$row->{V6SP1}. "#standpct7#".$row->{V7pct}."#leading species#".$row->{V7SP1};
			 	#	$herror{$keys}++;
		#}


	  	if(defined $row->{V1PCT}) {$CC1=$row->{V1PCT};} else {$CC1="";}
	  	if(defined $row->{V2PCT}) {$CC2=$row->{V2PCT};} else {$CC2="";}
	  	if(defined $row->{V3PCT}) {$CC3=$row->{V3PCT};} else {$CC3="";}
	  	if(defined $row->{V4PCT}) {$CC1=$row->{V4PCT};} else {$CC4="";}
	  	if(defined $row->{V5PCT}) {$CC2=$row->{V5PCT};} else {$CC5="";}
	  	if(defined $row->{V6PCT}) {$CC3=$row->{V6PCT};} else {$CC6="";}
	  	if(defined $row->{V7PCT}) {$CC1=$row->{V7PCT};} else {$CC7="";}

	 	# if($CC1 eq "0"){$CC1="";} if($CC2 eq "0"){$CC2="";} if($CC3 eq "0"){$CC3="";}
	 	# if($CC4 eq "0"){$CC4="";} if($CC5 eq "0"){$CC5="";} if($CC6 eq "0"){$CC6="";}
 	 	# if($CC7 eq "0"){$CC7="";}

	  	$CCHigh1       =  CCUpper( $CC1);  
        $CCHigh2       =  CCUpper( $CC2); 
        $CCHigh3       =  CCUpper( $CC3);
	  	$CCHigh4       =  CCUpper( $CC4);  
        $CCHigh5       =  CCUpper( $CC5); 
        $CCHigh6       =  CCUpper( $CC6); 
 	  	$CCHigh7       =  CCUpper( $CC7); 

        $CCLow1        =  CCLower( $CC1); 
        $CCLow2        =  CCLower( $CC2); 
        $CCLow3        =  CCLower( $CC3);
	  	$CCLow4        =  CCLower( $CC4); 
        $CCLow5        =  CCLower( $CC5); 
        $CCLow6        =  CCLower( $CC6);
     	$CCLow7        =  CCLower( $CC7);

 	  	if($CCHigh1 eq ERRCODE || $CCLow1 eq ERRCODE ||$CCHigh2  eq ERRCODE   || $CCLow2  eq ERRCODE || $CCHigh3  eq ERRCODE || $CCLow3  eq ERRCODE)
 	  	{ 
			$keys="CrownClosure1-3"."#".$CC1."#".$CC2."#".$CC3."#";
			$herror{$keys}++;
		}
	  	if($CCHigh4 eq ERRCODE || $CCLow4 eq ERRCODE ||$CCHigh5  eq ERRCODE   || $CCLow5  eq ERRCODE || $CCHigh6  eq ERRCODE || $CCLow6  eq ERRCODE || $CCHigh7  eq ERRCODE || $CCLow7  eq ERRCODE)
	  	{ 
			$keys="CrownClosure4-7"."#".$CC4."#".$CC5."#".$CC6."#".$CC7."#";
			 $herror{$keys}++;
		}


	  	$HeightHigh1   =  StandHeightUp( $row->{V1HTC}); 
	  	$HeightHigh2   =  StandHeightUp( $row->{V2HTC});
        $HeightHigh3   =  StandHeightUp( $row->{V3HTC});
	  	$HeightHigh4   =  StandHeightUp( $row->{V4HTC}); 
	  	$HeightHigh5   =  StandHeightUp( $row->{V5HTC});
        $HeightHigh6   =  StandHeightUp( $row->{V6HTC});
	  	$HeightHigh7   =  StandHeightUp( $row->{V7HTC});
          
        $HeightLow1    =  StandHeightLow($row->{V1HTC});
        $HeightLow2    =  StandHeightLow($row->{V2HTC});
        $HeightLow3    =  StandHeightLow($row->{V3HTC});
	  	$HeightLow4    =  StandHeightLow($row->{V4HTC});
        $HeightLow5    =  StandHeightLow($row->{V5HTC});
        $HeightLow6    =  StandHeightLow($row->{V6HTC});
	  	$HeightLow7    =  StandHeightLow($row->{V7HTC});

	  	if($HeightHigh1 eq ERRCODE || $HeightLow1 eq ERRCODE ||$HeightHigh2  eq ERRCODE   || $HeightLow2  eq ERRCODE || $HeightHigh3  eq ERRCODE || $HeightLow3  eq ERRCODE)
	  	{ 
			$keys="height1-3"."#".$row->{V1HTC}."#".$row->{V2HTC}."#".$row->{V3HTC}."#";
			$herror{$keys}++;
		}

		if(($HeightHigh1 eq MISSCODE && !isempty($row->{V1SP1}) && $row->{V1SP1} ne "GR" && $row->{V1SP1} ne "GC" && $row->{V1SP1} ne "ER" && $row->{V1SP1} ne "WW" && $row->{V1SP1} ne "AL"))
		{ 
			$keys="null or missing height1"."#".$row->{V1HTC}."#SPecies1#".$row->{V1SP1};
			$herror{$keys}++;
		}


	 	$SpeciesComp1  =  Species($row->{V1SP1},$row->{V1SP2},$row->{V1SP3},$row->{V1SP4},$spfreq);
	 	@SpecsPerList1 = split(",", $SpeciesComp1);  
		for($cpt_ind=0; $cpt_ind<=3; $cpt_ind++)
		{  
			my $posi=$cpt_ind*2;
        	if($SpecsPerList1[$posi]  eq SPECIES_ERRCODE) 
			{ 
				$keys="Species layer 1#".$cpt_ind."#SP1=#".$row->{V1SP1}."#SP2=#".$row->{V1SP2}."#SP3=#".$row->{V1SP2}."#SP4=#".$row->{V1SP4};
              	$herror{$keys}++; 
			}
   		}
		my $total1=$SpecsPerList1[1] + $SpecsPerList1[3]+ $SpecsPerList1[5] +$SpecsPerList1[7];
	
		if($total1 != 100 && $total1 != 0 )
		{
			$keys="total perct1 !=100 "."#$total1#".$SpeciesComp1."#original#".$row->{V1SP1}.",".$row->{V1SP2}.",".$row->{V1SP3}.",".$row->{V1SP4};
			$herror{$keys}++; 
		}
	 	$SpeciesComp1  =  $SpeciesComp1 .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";

	 	$SpeciesComp2  =  Species($row->{V2SP1},$row->{V2SP2},$row->{V2SP3},$row->{V2SP4},$spfreq);
	 	@SpecsPerList2 = split(",", $SpeciesComp2);  
		for($cpt_ind=0; $cpt_ind<=3; $cpt_ind++)
		{  
			my $posi=$cpt_ind*2;
        	if($SpecsPerList2[$posi]  eq SPECIES_ERRCODE) 
			{ 
				$keys = "Species layer 2#".$cpt_ind."#SP1=#".$row->{V2SP1}."#SP2=#".$row->{V2SP2}."#SP3=#".$row->{V2SP2}."#SP4=#".$row->{V2SP4};
              	$herror{$keys}++; 
			}
   		}
		my $total2=$SpecsPerList2[1] + $SpecsPerList2[3]+ $SpecsPerList2[5] +$SpecsPerList2[7];
	
		if($total2 != 100 && $total2 != 0 ){
			$keys="total perct2 !=100 "."#$total2#".$SpeciesComp2."#original#".$row->{V2SP1}.",".$row->{V2SP2}.",".$row->{V2SP3}.",".$row->{V2SP4};
			$herror{$keys}++; 
		}
	 	$SpeciesComp2  =  $SpeciesComp2 .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";



	 	$SpeciesComp3  =  Species($row->{V3SP1},$row->{V3SP2},$row->{V3SP3},$row->{V3SP4},$spfreq);
	 	@SpecsPerList3 = split(",", $SpeciesComp3);  
		for($cpt_ind=0; $cpt_ind<=3; $cpt_ind++)
		{  
			my $posi=$cpt_ind*2;
        	if($SpecsPerList3[$posi]  eq SPECIES_ERRCODE) 
			{ 
				$keys="Species layer 3#".$cpt_ind."#SP1=#".$row->{V3SP1}."#SP2=#".$row->{V3SP2}."#SP3=#".$row->{V3SP2}."#SP4=#".$row->{V3SP4};
              	$herror{$keys}++; 
			}
   		}
		my $total3=$SpecsPerList3[1] + $SpecsPerList3[3]+ $SpecsPerList3[5] +$SpecsPerList3[7];
	
		if($total3 != 100 && $total3 != 0 )
		{
			$keys="total perct3 !=100 "."#$total3#".$SpeciesComp3."#original#".$row->{V3SP1}.",".$row->{V3SP2}.",".$row->{V3SP3}.",".$row->{V3SP4};
			$herror{$keys}++; 
		}
	 	$SpeciesComp3  =  $SpeciesComp3 .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";

	 	$SpeciesComp4  =  Species($row->{V4SP1},$row->{V4SP2},$row->{V4SP3},$row->{V4SP4},$spfreq);
	 	@SpecsPerList4 = split(",", $SpeciesComp4);  
		for($cpt_ind=0; $cpt_ind<=3; $cpt_ind++)
		{  
			my $posi=$cpt_ind*2;
        	if($SpecsPerList4[$posi]  eq SPECIES_ERRCODE) 
			{ 
				$keys="Species layer 4#".$cpt_ind."#SP1=#".$row->{V4SP1}."#SP2=#".$row->{V4SP2}."#SP3=#".$row->{V4SP2}."#SP4=#".$row->{V4SP4};
              	$herror{$keys}++; 
			}
   		}
		my $total4=$SpecsPerList4[1] + $SpecsPerList4[3]+ $SpecsPerList4[5] +$SpecsPerList4[7];
	
		if($total4 != 100 && $total4 != 0 )
		{
			$keys="total perct4 !=100 "."#$total4#".$SpeciesComp4."#original#".$row->{V4SP1}.",".$row->{V4SP2}.",".$row->{V4SP3}.",".$row->{V4SP4};
			$herror{$keys}++; 
		}
	 	$SpeciesComp4  =  $SpeciesComp4 .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";

	 	$SpeciesComp5  =  Species($row->{V5SP1},$row->{V5SP2},$row->{V5SP3},$row->{V5SP4},$spfreq);
	 	@SpecsPerList5 = split(",", $SpeciesComp5);  
		for($cpt_ind=0; $cpt_ind<=3; $cpt_ind++)
		{  
			my $posi=$cpt_ind*2;
        	if($SpecsPerList5[$posi]  eq SPECIES_ERRCODE) 
			{ 
				$keys="Species layer 5#".$cpt_ind."#SP1=#".$row->{V5SP1}."#SP2=#".$row->{V5SP2}."#SP3=#".$row->{V5SP2}."#SP4=#".$row->{V5SP4};
              	$herror{$keys}++; 
			}
   		}
		my $total5=$SpecsPerList5[1] + $SpecsPerList5[3]+ $SpecsPerList5[5] +$SpecsPerList5[7];
	
		if($total5 != 100 && $total5 != 0 )
		{
			$keys="total perct5 !=100 "."#$total5#".$SpeciesComp5."#original#".$row->{V5SP1}.",".$row->{V5SP2}.",".$row->{V5SP3}.",".$row->{V5SP4};
			$herror{$keys}++; 
		}
	 	$SpeciesComp5  =  $SpeciesComp5 .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";

	 	$SpeciesComp6  =  Species($row->{V6SP1},$row->{V6SP2},$row->{V6SP3},$row->{V6SP4},$spfreq);
	 	@SpecsPerList6 = split(",", $SpeciesComp6);  
		for($cpt_ind=0; $cpt_ind<=3; $cpt_ind++)
		{  
			my $posi=$cpt_ind*2;
        	if($SpecsPerList6[$posi]  eq SPECIES_ERRCODE) 
			{ 
				$keys="Species layer 6#".$cpt_ind."#SP1=#".$row->{V6SP1}."#SP2=#".$row->{V6SP2}."#SP3=#".$row->{V6SP2}."#SP4=#".$row->{V6SP4};
            	$herror{$keys}++; 
			}
   		}
		my $total6=$SpecsPerList6[1] + $SpecsPerList6[3]+ $SpecsPerList6[5] +$SpecsPerList6[7];
	
		if($total6 != 100 && $total6 != 0 )
		{
			$keys="total perct6 !=100 "."#$total6#".$SpeciesComp6."#original#".$row->{V6SP1}.",".$row->{V6SP2}.",".$row->{V6SP3}.",".$row->{V6SP4};
			$herror{$keys}++; 
		}
	 	$SpeciesComp6  =  $SpeciesComp6 .",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";

	 	$SpeciesComp7  =  Species($row->{V7SP1},$row->{V7SP2},$row->{V7SP3},$row->{V7SP4},$spfreq);
	 	@SpecsPerList7 = split(",", $SpeciesComp7);  
		for($cpt_ind=0; $cpt_ind<=3; $cpt_ind++)
		{  
			my $posi=$cpt_ind*2;
        	if($SpecsPerList7[$posi]  eq SPECIES_ERRCODE) 
			{ 
				$keys="Species layer 7#".$cpt_ind."#SP1=#".$row->{V7SP1}."#SP2=#".$row->{V7SP2}."#SP3=#".$row->{V7SP2}."#SP4=#".$row->{V7SP4};
        		$herror{$keys}++; 
			}
   		}
		my $total7=$SpecsPerList7[1] + $SpecsPerList7[3]+ $SpecsPerList7[5] +$SpecsPerList7[7];
	
		if($total7 != 100 && $total7 != 0 )
		{
			$keys="total perct7 !=100 "."#$total7#".$SpeciesComp7."#original#".$row->{V7SP1}.",".$row->{V7SP2}.",".$row->{V7SP3}.",".$row->{V7SP4};
			$herror{$keys}++; 
		}
	 	$SpeciesComp7  =  $SpeciesComp7.",XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";

        $OriginHigh   = MISSCODE;
        $OriginLow    = MISSCODE;
	  	$StrucVal     =  UNDEF;
	  	$SiteClass 	=  UNDEF;
	  	$SiteIndex 	=  UNDEF;
         

          #use only one layer
		  $Wetland1 = WetlandCodes ($row->{V1PCM},  $row->{V1STR}); 
		  $Wetland2 = WetlandCodes ($row->{V2PCM},  $row->{V2STR});  
		  $Wetland3 = WetlandCodes ($row->{V3PCM},  $row->{V3STR});
		  $Wetland4 = WetlandCodes ($row->{V4PCM},  $row->{V4STR}); 
		  $Wetland5 = WetlandCodes ($row->{V5PCM},  $row->{V5STR});  
		  $Wetland6 = WetlandCodes ($row->{V6PCM},  $row->{V6STR});
		  $Wetland7 = WetlandCodes ($row->{V7PCM},  $row->{V7STR});

	

	  	# ===== Non-forested Land =====
		$NatNonVeg = UNDEF;
		$NonForAnth = UNDEF;
	 	#if(!defined $row->{shrln} ) {  $row->{shrln}="";}
	    if(!defined $row->{V1PCM} ) 
	    {  
	    	$row->{V1PCM}="";
	    }
		$NonForVeg1 	=  NonForestedVeg($row->{V1PCM});	
		if($NonForVeg1 ne MISSCODE &&  $NonForVeg1 ne ERRCODE)
		{
			$IsNFL1=1;
		}

	    if(!defined $row->{V2PCM} ) 
	    {  
	    	$row->{V2PCM}="";
	    }
		$NonForVeg2 	=  NonForestedVeg($row->{V2PCM});
	 	if($NonForVeg2 ne MISSCODE &&  $NonForVeg2 ne ERRCODE)
	 	{
			$IsNFL2=1;
		}	 

	    if(!defined $row->{V3PCM} )
	    { 
	    	$row->{V3PCM}="";
	    }
		$NonForVeg3 	=  NonForestedVeg($row->{V3PCM});
	 	if($NonForVeg3 ne MISSCODE &&  $NonForVeg3 ne ERRCODE)
	 	{
			$IsNFL3=1;
		}	

		if(!defined $row->{V4PCM} ) 
		{  
			$row->{V4PCM}="";
		}
		$NonForVeg4 	=  NonForestedVeg($row->{V4PCM});
		if($NonForVeg4 ne MISSCODE &&  $NonForVeg4 ne ERRCODE)
		{
			$IsNFL4=1;
		}	 
	        
	    if(!defined $row->{V5PCM} ) 
	    {  
	    	$row->{V5PCM}="";
	    }
		$NonForVeg5 	=  NonForestedVeg($row->{V5PCM});	 
	    if($NonForVeg5 ne MISSCODE &&  $NonForVeg5 ne ERRCODE)
	    {
			$IsNFL5=1;
		}

	 	if(!defined $row->{V6PCM} ) 
	 	{  
	 		$row->{V6PCM}="";
	 	}	
	 	$NonForVeg6 	=  NonForestedVeg($row->{V6PCM});	 
	    if($NonForVeg6 ne MISSCODE &&  $NonForVeg6 ne ERRCODE)
	    {
			$IsNFL6=1;
		}

		if(!defined $row->{V7PCM} ) 
		{  
			$row->{V7PCM}="";
		}
		$NonForVeg7 	=  NonForestedVeg($row->{V7PCM});	 
	 	if($NonForVeg7 ne MISSCODE &&  $NonForVeg7 ne ERRCODE)
	 	{
			$IsNFL7=1;
		}


		#if($totalpct ==170 ){ if(isempty($row->{V7SP1}) && $StandStructureVal7 ==70){$StandStructureVal7=0;}
		#}
		$totalpct=$StandStructureVal1 +$StandStructureVal2+$StandStructureVal3+$StandStructureVal4+$StandStructureVal5+$StandStructureVal6+$StandStructureVal7;



	 	if($totalpct !=100 && $totalpct !=0  )  
	 	{
			$keys="stand percentage !=100"."#".$totalpct."\n". "#standpct1==".$row->{V1PCT}."#leading species==".$row->{V1SP1}."#Nonforveg1==".$NonForVeg1."\n"."#standpct2==".$row->{V2PCT}."#leading species==".$row->{V2SP1}."#Nonforveg2==".$NonForVeg2."\n"."#standpct3==".$row->{V3PCT}."#leading species==".$row->{V3SP1}."#Nonforveg3==".$NonForVeg3. "\n"."#standpct4==".$row->{V4PCT}."#leading species==".$row->{V4SP1}."#Nonforveg4==".$NonForVeg4."\n"."#standpct5==".$row->{V5PCT}."#leading species==".$row->{V5SP1}."#Nonforveg5==".$NonForVeg5."\n"."#standpct6==".$row->{V6PCT}."#leading species==".$row->{V6SP1}."#Nonforveg6==".$NonForVeg6. "\n"."#standpct7==".$row->{V7PCT}."#leading species==".$row->{V7SP1}."#Nonforveg7==".$NonForVeg7;
			$herror{$keys}++;
		}
		
	 	

		# ===== Modifiers =====
	    #$Dist1 = Disturbance($row->{eros1}, $row->{V1PCM}, $row->{V1STR});
	    #$Dist2 = Disturbance($row->{eros2}, $row->{V2PCM}, $row->{V2STR});
	    #$Dist3 = Disturbance($row->{eros3}, $row->{V3PCM}, $row->{V3STR});

 	    $Dist1 = Disturbance($row->{V1STR});
	  	$Dist2 = Disturbance($row->{V2STR});
	  	$Dist3 = Disturbance($row->{V3STR});
	  	$Dist4 = Disturbance($row->{V4STR});
	  	$Dist5 = Disturbance($row->{V5STR});
	  	$Dist6 = Disturbance($row->{V6STR});
   	  	$Dist7 = Disturbance($row->{V7STR});

	 	# if($Dist1 =~ ERRCODE  || $Dist2 =~ ERRCODE || $Dist3 =~ ERRCODE) { 
	  		#$keys="disturbance1to3"."#". $row->{eros1}."#".$row->{V1PCM}."#".$row->{V1STR}."#". $row->{eros2}."#".$row->{V2PCM}."#".$row->{V2STR}."#". $row->{eros3}."#".$row->{V3PCM}."#".$row->{V3STR};
			#$herror{$keys}++;  	
		#}

	  	if( $row->{V1STR} eq "D" ) 
	  	{
			$Dist1ExtHigh  =  DisturbanceExtUpper($row->{V1PCT});
         	$Dist1ExtLow   =  DisturbanceExtLower($row->{V1PCT});
			if($Dist1ExtHigh eq ERRCODE || $Dist1ExtLow eq ERRCODE) 
			{ 
				$keys="disturbance1Extent"."#". $row->{V1PCT};
				$herror{$keys}++;	
			}
	  	}
	  	else 
	  	{	
	  		$Dist1ExtHigh  =  MISSCODE; $Dist1ExtLow   =  MISSCODE;
	  	}
	
	  	if($row->{V2STR} eq "D" ) 
	  	{
				$Dist2ExtHigh  =  DisturbanceExtUpper($row->{V2PCT});
         		$Dist2ExtLow   =  DisturbanceExtLower($row->{V2PCT});
				if($Dist2ExtHigh eq ERRCODE || $Dist2ExtLow eq ERRCODE)
				{ 
					$keys="disturbance2Extent"."#". $row->{V2PCT};
					$herror{$keys}++;	
				}
	  	}
	  	else 
	  	{	
	  		$Dist2ExtHigh  =  MISSCODE; $Dist2ExtLow   =  MISSCODE;
	 	}

	 	if($row->{V3STR} eq "D" ) 
	 	{
			$Dist3ExtHigh  =  DisturbanceExtUpper($row->{V3PCT});
         	$Dist3ExtLow   =  DisturbanceExtLower($row->{V3PCT});
			if($Dist3ExtHigh eq ERRCODE || $Dist3ExtLow eq ERRCODE)
			{ 
				$keys="disturbance3Extent"."#". $row->{V3PCT};
				$herror{$keys}++;	
			}
	  	}
	  	else 
	  	{	
	  		$Dist3ExtHigh  =  MISSCODE; $Dist3ExtLow   =  MISSCODE;
	  	}

	  	if($row->{V4STR} eq "D" ) 
	  	{
			$Dist4ExtHigh  =  DisturbanceExtUpper($row->{V4PCT});
         	$Dist4ExtLow   =  DisturbanceExtLower($row->{V4PCT});
			if($Dist4ExtHigh eq ERRCODE || $Dist4ExtLow eq ERRCODE) 
			{ 
				$keys="disturbance4Extent"."#". $row->{V4PCT};
				$herror{$keys}++;	
			}
	  	}
	  	else 
	  	{	
	  		$Dist4ExtHigh  =  MISSCODE; $Dist4ExtLow   =  MISSCODE;
	    }
	 	if($row->{V5STR} eq "D" ) 
	 	{
				$Dist5ExtHigh  =  DisturbanceExtUpper($row->{V5PCT});
         			$Dist5ExtLow   =  DisturbanceExtLower($row->{V5PCT});
				if($Dist5ExtHigh eq ERRCODE || $Dist5ExtLow eq ERRCODE) { 
						$keys="disturbance5Extent"."#". $row->{V5PCT};
						$herror{$keys}++;	
				}
	  	}
	  	else 
	  	{	
	  		$Dist5ExtHigh  =  MISSCODE; $Dist5ExtLow   =  MISSCODE;
	  	}

	 	if($row->{V6STR} eq "D" ) 
	 	{
			$Dist6ExtHigh  =  DisturbanceExtUpper($row->{V6PCT});
         	$Dist6ExtLow   =  DisturbanceExtLower($row->{V6PCT});
			if($Dist6ExtHigh eq ERRCODE || $Dist6ExtLow eq ERRCODE)
			{ 
				$keys="disturbance6Extent"."#". $row->{V6PCT};
				$herror{$keys}++;	
			}
	  	}
	  	else 
	  	{	
	  		$Dist6ExtHigh  =  MISSCODE; $Dist6ExtLow   =  MISSCODE;
	 	}

	 	if($row->{V7STR} eq "D" )
	 	{
			$Dist7ExtHigh  =  DisturbanceExtUpper($row->{V7PCT});
         	$Dist7ExtLow   =  DisturbanceExtLower($row->{V7PCT});
			if($Dist7ExtHigh eq ERRCODE || $Dist7ExtLow eq ERRCODE) 
			{ 
				$keys="disturbance7Extent"."#". $row->{V7PCT};
				$herror{$keys}++;	
			}
	  	}
	  	else 
	  	{	
	  		$Dist7ExtHigh  =  MISSCODE; $Dist7ExtLow   =  MISSCODE;
	 	}
		
	    $Dist1 = $Dist1 . "," . $Dist1ExtHigh . "," . $Dist1ExtLow.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF;
	    $Dist2 = $Dist2 . "," . $Dist2ExtHigh . "," . $Dist2ExtLow.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF;
	 	$Dist3 = $Dist3 . "," . $Dist3ExtHigh . "," . $Dist3ExtLow.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF;
	    $Dist4 = $Dist4 . "," . $Dist4ExtHigh . "," . $Dist4ExtLow.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF;
		$Dist5 = $Dist5 . "," . $Dist5ExtHigh . "," . $Dist5ExtLow.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF;
	 	$Dist6 = $Dist6 . "," . $Dist6ExtHigh . "," . $Dist6ExtLow.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF;
	    $Dist7 = $Dist7 . "," . $Dist7ExtHigh . "," . $Dist7ExtLow.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF.",".UNDEF;
	         
 	  
	 
		# ======================================================= WRITING Output inventory info IN CAS FILES =================================================================================================
		my $prod_for1="PF";
		my $lyr_poly1=1;
		if(isempty($row->{V1SP1}))
		{
			$SpeciesComp1="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
			if ( !is_missing($CCHigh1) ||  !is_missing($CCLow1) || !is_missing($HeightHigh1) || !is_missing($HeightLow1))
			{
				$prod_for1="PP";
			}
			else
			{
				$lyr_poly1=0;
			}

		}
		if((substr $Dist1,0,2) eq "CO")
		{
			$prod_for1="PF";
			$lyr_poly1=1;
		}
	
		#if(defined $row->{V1PCT})	{$AREA1=$row->{area}  * $row->{V1PCT}/10;} 	else {$AREA1=0.0;}
		#if(defined $row->{V2PCT})	{$AREA2=$row->{area}  * $row->{V2PCT}/10;} 	else {$AREA2=0.0;}
		#if(defined $row->{V3PCT})	{$AREA3=$row->{area}  * $row->{V3PCT}/10;} 	else {$AREA3=0.0;}
		#if(defined $row->{V4PCT})	{$AREA4=$row->{area}  * $row->{V4PCT}/10;}	else {$AREA4=0.0;}
		#if(defined $row->{V5PCT})	{$AREA5=$row->{area}  * $row->{V5PCT}/10;} 	else {$AREA5=0.0;}
		#if(defined $row->{V6PCT})	{$AREA6=$row->{area}  * $row->{V6PCT}/10;}  	else {$AREA6=0.0;}
		#if(defined $row->{V7PCT})	{$AREA7=$row->{area}  * $row->{V7PCT}/10;} 	else {$AREA7=0.0;}




		#if(defined $IdentifyID){} else {print "cas nb $CAS_ID  header undef $IdentifyID \n"; exit;}

	    #layer 1
	 	$CAS_Record = $CAS_ID . "," . $StandID . ",". $StandStructureCode . ",7," . $IdentifyID . "," . $MapSheetID . "," . $Area . "," . $Perimeter . ",". $Area. ",1975";
		print CASCAS $CAS_Record . "\n";
		$nbpr=1;$$ncas++;$ncasprev++;

	            #if (!$IsNFL1 && (substr $SpeciesComp1, 0,4) ne "XXXX") {
		if ((!$IsNFL1 || $lyr_poly1==1))
		{
		    $LYR_Record11 = $row->{CAS_ID} . "," . $SMR1  . ","  . $StandStructureVal1 . ",1,1";
		   	$LYR_Record21 = $CCHigh1 . "," . $CCLow1 . "," . $HeightHigh1 . "," . $HeightLow1 . "," . $prod_for1.",".$SpeciesComp1;
		    $LYR_Record31 = $OriginHigh . "," . $OriginLow . "," . $SiteClass . "," . $SiteIndex;
		    $Lyr_Record41 = $LYR_Record11 . "," . $LYR_Record21 . "," . $LYR_Record31;
		    print CASLYR $Lyr_Record41 . "\n";
			$nbpr++; $$nlyr++;$nlyrprev++;
		}
		elsif(!is_missing($NonForVeg1) &&  $StandStructureVal1 >0)
		{
	             		 $NFL_Record11 = $row->{CAS_ID} . "," . $SMR1  . "," . $StandStructureVal1 . ",1,1";
	            		 $NFL_Record21 = $CCHigh1 . "," . $CCLow1 . "," . $HeightHigh1 . "," . $HeightLow1;
	             		 $NFL_Record31 = $NatNonVeg . "," . $NonForAnth . "," . $NonForVeg1;
	             		 $NFL_Record1 = $NFL_Record11 . "," . $NFL_Record21 . "," . $NFL_Record31;
	             		 print CASNFL $NFL_Record1 . "\n";
				$nbpr++;$$nnfl++;$nnflprev++;
		}
	            
	            #layer 2
		   # $CAS_Record2 = $row->{CAS_ID} . "," . $row->{class}. "," . $row->{mapno}. "," . $row->{HEADER_ID} . "," . $AREA2 . "," . $row->{perimeter}. ",". $AREA2. ",".MISSCODE. ",".MISSCODE;
		    #print CASCAS $CAS_Record2 . "\n";
		my $prod_for2="PF";
		my $lyr_poly2=1;
		if(isempty($row->{V2SP1}))
		{
			$SpeciesComp2="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
			if ( !is_missing($CCHigh2) ||  !is_missing($CCLow2) || !is_missing($HeightHigh2) || !is_missing($HeightLow2))
			{
				$prod_for2="PP";
			}
			else
			{
				$lyr_poly2=0;
			}

		}
		if((substr $Dist2,0,2) eq "CO")
		{
			$prod_for2="PF";
			$lyr_poly2=1;
		}

	             #if (!$IsNFL2 && (substr $SpeciesComp2, 0,4) ne "XXXX") {
		if ((!$IsNFL2 || $lyr_poly2==1)) {
		      $LYR_Record12 = $row->{CAS_ID} . "," . $SMR2  . "," .  $StandStructureVal2 . ",2,2";
		      $LYR_Record22 = $CCHigh2 . "," . $CCLow2 . "," . $HeightHigh2 . "," . $HeightLow2 . "," .$prod_for2.",". $SpeciesComp2;
		      $LYR_Record32 = $OriginHigh . "," . $OriginLow . "," . $SiteClass . "," . $SiteIndex;
		      $Lyr_Record42 = $LYR_Record12 . "," . $LYR_Record22 . "," . $LYR_Record32;
		      print CASLYR $Lyr_Record42 . "\n";
			if($nbpr==1){$nbpr++; $$nlyr++;$nlyrprev++;}
			}
	       elsif(!is_missing($NonForVeg2) &&  $StandStructureVal2 >0)
	       {
	             	
	             	 $NFL_Record12 = $row->{CAS_ID} . "," . $SMR2  . "," . $StandStructureVal2 . ",2,2";
	            	  $NFL_Record22 = $CCHigh2 . "," . $CCLow2 . "," . $HeightHigh2 . "," . $HeightLow2;
	            	  $NFL_Record32 = $NatNonVeg . "," . $NonForAnth . "," . $NonForVeg2;
	            	 $NFL_Record2 = $NFL_Record12 . "," . $NFL_Record22 . "," . $NFL_Record32;
	              	print CASNFL $NFL_Record2 . "\n";
			if($nbpr==1){$nbpr++;$$nnfl++;$nnflprev++;}
		   }
	             
	            #layer 3
	 		#$CAS_Record3 = $row->{CAS_ID} . "," . $row->{class}. "," . $row->{mapno}. "," . $row->{HEADER_ID} . "," . $AREA3 . "," . $row->{perimeter}. ",". $AREA3. ",".MISSCODE. ",".MISSCODE;
		    #	print CASCAS $CAS_Record3 . "\n";
		my $prod_for3="PF";
		my $lyr_poly3=1;
		if(isempty($row->{V3SP1}))
		{
			$SpeciesComp3="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
			if ( !is_missing($CCHigh3) ||  !is_missing($CCLow3) || !is_missing($HeightHigh3) || !is_missing($HeightLow3))
			{
				$prod_for3="PP";
			}
			else
			{
				$lyr_poly3=0;
			}

		}
		if((substr $Dist3,0,2) eq "CO")
		{
			$prod_for3="PF";
			$lyr_poly3=1;
		}

	           # if (!$IsNFL3 && (substr $SpeciesComp3, 0,4) ne "XXXX") {
		if ((!$IsNFL3 || $lyr_poly3==1)) {
		      $LYR_Record13 = $row->{CAS_ID} . "," . $SMR3  . "," .  $StandStructureVal3 . ",3,3";
		      $LYR_Record23 = $CCHigh3 . "," . $CCLow3 . "," . $HeightHigh3 . "," . $HeightLow3 . "," . $prod_for3.",".$SpeciesComp3;
		      $LYR_Record33 = $OriginHigh . "," . $OriginLow . "," . $SiteClass . "," . $SiteIndex;
		      $Lyr_Record43 = $LYR_Record13 . "," . $LYR_Record23 . "," . $LYR_Record33;
		      print CASLYR $Lyr_Record43 . "\n";
			if($nbpr==1){$nbpr++; $$nlyr++;$nlyrprev++;}
		}

	    elsif(!is_missing($NonForVeg3) &&  $StandStructureVal3 >0)
	      {
	         	  $NFL_Record13 = $row->{CAS_ID} . "," . $SMR3  . "," . $StandStructureVal3 . ",3,3";
	          	  $NFL_Record23 = $CCHigh3 . "," . $CCLow3 . "," . $HeightHigh3 . "," . $HeightLow3;
	            	  $NFL_Record33 = $NatNonVeg . "," . $NonForAnth . "," . $NonForVeg3;
	            	  $NFL_Record3 = $NFL_Record13 . "," . $NFL_Record23 . "," . $NFL_Record33;
	             	 print CASNFL $NFL_Record3 . "\n";
			if($nbpr==1){$nbpr++;$$nnfl++;$nnflprev++;}
		    }
	             
	 

	 	   #layer 4
	 		#$CAS_Record4 = $row->{CAS_ID} . "," . $row->{class}. "," . $row->{mapno}. "," . $row->{HEADER_ID} . "," . $AREA4 . "," . $row->{perimeter}. ",". $AREA4. ",".MISSCODE. ",".MISSCODE;
		    	#print CASCAS $CAS_Record4 . "\n";
		my $prod_for4="PF";
		my $lyr_poly4=1;
		if(isempty($row->{V4SP1}))
		{
			$SpeciesComp4="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
			if ( !is_missing($CCHigh4) ||  !is_missing($CCLow4) || !is_missing($HeightHigh4) || !is_missing($HeightLow4))
			{
				$prod_for4="PP";
			}
			else
			{
				$lyr_poly4=0;
			}

		}
		if((substr $Dist4,0,2) eq "CO")
		{
			$prod_for4="PF";
			$lyr_poly4=1;
		}

	             #if (!$IsNFL4 && (substr $SpeciesComp4, 0,4) ne "XXXX") {
			if ((!$IsNFL4 || $lyr_poly4==1)) {
		      $LYR_Record14 = $row->{CAS_ID} . "," . $SMR4  . "," . $StandStructureVal4 . ",4,4";
		      $LYR_Record24 = $CCHigh4 . "," . $CCLow4 . "," . $HeightHigh4 . "," . $HeightLow4 . "," .$prod_for4.",". $SpeciesComp4;
		      $LYR_Record34 = $OriginHigh . "," . $OriginLow . "," . $SiteClass . "," . $SiteIndex;
		      $Lyr_Record44 = $LYR_Record14 . "," . $LYR_Record24 . "," . $LYR_Record34;
		      print CASLYR $Lyr_Record44 . "\n";
				if($nbpr==1){$nbpr++; $$nlyr++;$nlyrprev++;}
	         }
	           
			elsif(!is_missing($NonForVeg4)&&  $StandStructureVal4 >0)
	       {   	  $NFL_Record14 = $row->{CAS_ID} . "," . $SMR4  . "," .$StandStructureVal4 . ",4,4";
	          	  $NFL_Record24 = $CCHigh4 . "," . $CCLow4 . "," . $HeightHigh4 . "," . $HeightLow4;
	            	  $NFL_Record34 = $NatNonVeg . "," . $NonForAnth . "," . $NonForVeg4;
	            	  $NFL_Record4 = $NFL_Record14 . "," . $NFL_Record24 . "," . $NFL_Record34;
	             	 print CASNFL $NFL_Record4 . "\n";
			if($nbpr==1){$nbpr++;$$nnfl++;$nnflprev++;}
		    }
	            
	 

	 	#layer 5
	 		#$CAS_Record5 = $row->{CAS_ID} . "," . $row->{class}. "," . $row->{mapno}. "," . $row->{HEADER_ID} . "," . $AREA5 . "," . $row->{perimeter}. ",". $AREA5. ",".MISSCODE. ",".MISSCODE;
		    	#print CASCAS $CAS_Record5 . "\n";
			my $prod_for5="PF";
			my $lyr_poly5=1;
			if(isempty($row->{V5SP1}))
			{
				$SpeciesComp5="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
				if ( !is_missing($CCHigh5) ||  !is_missing($CCLow5) || !is_missing($HeightHigh5) || !is_missing($HeightLow5))
				{
					$prod_for5="PP";
				}
				else
				{
					$lyr_poly5=0;
				}

			}
			if((substr $Dist5,0,2) eq "CO")
			{
				$prod_for5="PF";
				$lyr_poly5=1;
			}

	         # if (!$IsNFL5 && (substr $SpeciesComp5, 0,4) ne "XXXX") {
			if ((!$IsNFL5 || $lyr_poly5==1)) {
			      $LYR_Record15 = $row->{CAS_ID} . "," . $SMR5  . "," . $StandStructureVal5 . ",5,5";
			      $LYR_Record25 = $CCHigh5 . "," . $CCLow5 . "," . $HeightHigh5 . "," . $HeightLow5 . "," . $prod_for5.",".$SpeciesComp5;
			      $LYR_Record35 = $OriginHigh . "," . $OriginLow . "," . $SiteClass . "," . $SiteIndex;
			      $Lyr_Record45 = $LYR_Record15 . "," . $LYR_Record25 . "," . $LYR_Record35;
			      print CASLYR $Lyr_Record45 . "\n";
			if($nbpr==1){$nbpr++; $$nlyr++;$nlyrprev++;}
			}
	            
			elsif(!is_missing($NonForVeg5)&&  $StandStructureVal5 >0)
	        { 
	         	  $NFL_Record15 = $row->{CAS_ID} . "," . $SMR5  . "," . $StandStructureVal5 . ",5,5";
	          	  $NFL_Record25 = $CCHigh5 . "," . $CCLow5 . "," . $HeightHigh5 . "," . $HeightLow5;
	            	  $NFL_Record35 = $NatNonVeg . "," . $NonForAnth . "," . $NonForVeg5;
	            	  $NFL_Record5 = $NFL_Record15 . "," . $NFL_Record25 . "," . $NFL_Record35;
	             	 print CASNFL $NFL_Record5 . "\n";
			if($nbpr==1){$nbpr++;$$nnfl++;$nnflprev++;}
		    }
	            

		

		#layer 6
	 		#$CAS_Record6 = $row->{CAS_ID} . "," . $row->{class}. "," . $row->{mapno}. "," . $row->{HEADER_ID} . "," . $AREA6 . "," . $row->{perimeter}. ",". $AREA6. ",".MISSCODE. ",".MISSCODE;
		    #	print CASCAS $CAS_Record6 . "\n";
		my $prod_for6="PF";
		my $lyr_poly6=1;
		if(isempty($row->{V6SP1}))
		{
			$SpeciesComp6="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
			if ( !is_missing($CCHigh6) ||  !is_missing($CCLow6) || !is_missing($HeightHigh6) || !is_missing($HeightLow6))
			{
				$prod_for6="PP";
			}
			else
			{
				$lyr_poly6=0;
			}

		}
		if((substr $Dist6,0,2) eq "CO")
		{
			$prod_for6="PF";
			$lyr_poly6=1;
		}

	          #  if (!$IsNFL6 && (substr $SpeciesComp6, 0,4) ne "XXXX") {
		if ((!$IsNFL6 || $lyr_poly6==1)) 
		{
		    $LYR_Record16 = $row->{CAS_ID} . "," . $SMR6  . ","  . $StandStructureVal6 . ",6,6";
		    $LYR_Record26 = $CCHigh6 . "," . $CCLow6 . "," . $HeightHigh6 . "," . $HeightLow6 . "," .$prod_for6.",". $SpeciesComp6;
		    $LYR_Record36 = $OriginHigh . "," . $OriginLow . "," . $SiteClass . "," . $SiteIndex;
		    $Lyr_Record46 = $LYR_Record16 . "," . $LYR_Record26 . "," . $LYR_Record36;
		    print CASLYR $Lyr_Record46 . "\n";
			if($nbpr==1){$nbpr++; $$nlyr++;$nlyrprev++;}
		}
	    elsif(!is_missing($NonForVeg6)&&  $StandStructureVal6 >0)
	    {
	        $NFL_Record16 = $row->{CAS_ID} . "," . $SMR6  . "," . $StandStructureVal6 . ",6,6";
	        $NFL_Record26 = $CCHigh6 . "," . $CCLow6 . "," . $HeightHigh6 . "," . $HeightLow6;
	        $NFL_Record36 = $NatNonVeg . "," . $NonForAnth . "," . $NonForVeg6;
	        $NFL_Record6 = $NFL_Record16 . "," . $NFL_Record26 . "," . $NFL_Record36;
	        print CASNFL $NFL_Record6 . "\n";
			if($nbpr==1){$nbpr++;$$nnfl++;$nnflprev++;}
		}
	            


		#layer 7
	 		#$CAS_Record7 = $row->{CAS_ID} . "," . $row->{class}. "," . $row->{mapno}. "," . $row->{HEADER_ID} . "," . $AREA7 . "," . $row->{perimeter}. ",". $AREA7. ",".MISSCODE. ",".MISSCODE;
		    	#print CASCAS $CAS_Record7 . "\n";
		my $prod_for7="PF";
		my $lyr_poly7=1;
		if(isempty($row->{V7SP1}))
		{
			$SpeciesComp7="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
			if ( !is_missing($CCHigh7) ||  !is_missing($CCLow7) || !is_missing($HeightHigh7) || !is_missing($HeightLow7))
			{
				$prod_for7="PP";
			}
			else
			{
				$lyr_poly7=0;
			}

		}
		if((substr $Dist7,0,2) eq "CO")
		{
			$prod_for7="PF";
			$lyr_poly7=1;
		}

	           # if (!$IsNFL7 && (substr $SpeciesComp7, 0,4) ne "XXXX") {
		if ((!$IsNFL7 || $lyr_poly7==1)) 
		{
		    $LYR_Record17 = $row->{CAS_ID} . "," . $SMR7  . "," . $StandStructureVal7 . ",7,7";
		    $LYR_Record27 = $CCHigh7 . "," . $CCLow7 . "," . $HeightHigh7 . "," . $HeightLow7 . "," .$prod_for7.",". $SpeciesComp7;
		    $LYR_Record37 = $OriginHigh . "," . $OriginLow . "," . $SiteClass . "," . $SiteIndex;
		    $Lyr_Record47 = $LYR_Record17 . "," . $LYR_Record27 . "," . $LYR_Record37;
		    print CASLYR $Lyr_Record47 . "\n";
			if($nbpr==1){$nbpr++; $$nlyr++;$nlyrprev++;}
		}
	    elsif(!is_missing($NonForVeg7) &&  $StandStructureVal7 >0)
	    {
	        $NFL_Record17 = $row->{CAS_ID} . "," . $SMR7  . "," . $StandStructureVal7 . ",7,7";
	        $NFL_Record27 = $CCHigh7 . "," . $CCLow7 . "," . $HeightHigh7 . "," . $HeightLow7;
	        $NFL_Record37 = $NatNonVeg . "," . $NonForAnth . "," . $NonForVeg7;
	        $NFL_Record7 = $NFL_Record17 . "," . $NFL_Record27 . "," . $NFL_Record37;
	        print CASNFL $NFL_Record7 . "\n"; 
			if($nbpr==1){$nbpr++;$$nnfl++;$nnflprev++;}
		}
	            


		    #Disturbance
	            #Disturbance year is UNDEF
		if((substr $Dist1,0,1) ne "-")
		{
		    $DST_Record1 = $row->{CAS_ID} .",". $Dist1.",1";
		    print CASDST $DST_Record1 . "\n";
			if($nbpr==1) {$$ndstonly++; $ndstonlyprev++;}
			$nbpr++;$$ndst++;$ndstprev++;
		}
	 	if((substr $Dist2,0,1) ne "-")
	 	{
			$DST_Record2 = $row->{CAS_ID} .",". $Dist2.",2";
		   	print CASDST $DST_Record2 . "\n";
		}
		if((substr $Dist3,0,1) ne "-")
		{
	 		$DST_Record3 = $row->{CAS_ID} .",". $Dist3.",3";
		    print CASDST $DST_Record3 . "\n";
		}
		if((substr $Dist4,0,1) ne "-")
		{
			$DST_Record4 = $row->{CAS_ID} .",". $Dist4.",4";
		    print CASDST $DST_Record4 . "\n";
		}
	 	if((substr $Dist5,0,1) ne "-")
	 	{
			$DST_Record5 = $row->{CAS_ID} .",". $Dist5.",5";
		    print CASDST $DST_Record5 . "\n";
		}
	 	if((substr $Dist6,0,1) ne "-")
	 	{
			$DST_Record6 = $row->{CAS_ID} .",". $Dist6.",6";
		    print CASDST $DST_Record6 . "\n";
		}
	 	if((substr $Dist7,0,1) ne "-")
	 	{
			$DST_Record7 = $row->{CAS_ID} .",". $Dist7.",7";
		   	print CASDST $DST_Record7 . "\n";
		}
		     

	    #Ecological, which layer for other info
		if ($Wetland1 ne MISSCODE && $Wetland1 ne ERRCODE) 
		{
		    $Wetland1 = $row->{CAS_ID} . "," . $Wetland1."1";
		    print CASECO $Wetland1 . "\n";
		}
			
		if($nbpr ==1 )
		{
			$ndrops++;		
		}
		
	}	 
	$csv->eof or $csv->error_diag ();
	close $WBNPinv;

	  foreach my $k (keys %herror){
		 	print ERRS "invalid code " ,$k,  " found ", $herror{$k}," times\n";
			#print "invalid code " ,$k,  " found ", $herror{$k}," times\n";
	  }
	foreach my $k (sort {lc($a) cmp lc($b)} keys %$spfreq)
	{
		$_ = $k;
		tr/a-z/A-Z/;
		my $upk = $_;
	 	print SPERRSFILE "cumulative frequency of species " ,$upk,  " is ", $spfreq->{$k},"\n";
		#print "invalid code " ,$k,  " found ", $herror{$k}," times\n";
  	}
	close (CASHDR);
	close (CASCAS);
	close (CASLYR);
	close (CASNFL);
	close (CASDST);
	close (CASECO);
	close(ERRS);	 close(SPERRSFILE);close(SPECSLOGFILE); 
	$total=$nlyrprev+ $nnflprev+  $ndstprev;
	$total2=$nlyrprev+ $nnflprev+  $ndstonlyprev + $necoonlyprev;
	print " ndrops =$ndrops, nb records in casfile : $ncasprev, lyrfile : $nlyrprev, nflfile : $nnflprev,  dstfile : $ndstprev($ndstonlyprev), ecofile : $necoprev($necoonlyprev)--- total (without .cas): $total($total2)\n";
}
1;
#province eq "WBNP";

