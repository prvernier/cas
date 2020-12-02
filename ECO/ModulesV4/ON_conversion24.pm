package ModulesV4::ON_conversion24;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(&ONinv_to_CAS);
#our @EXPORT_OK = qw(%onnflfreq);
use strict;
use Text::CSV;
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
    
  if(!defined ($val) || $val eq MISSCODE || $val eq ERRCODE || $val eq UNDEF) 
  {
    return 1;
  }
  else 
  {
    return 0;
  } 
}

#3 versions : FRI, FRI_FIM, FRI NBI
#VD, D=D       MF, F, VF=F MM, M, VM=M MW, W, VW=W
#SoilMoistureRegime  from Soil_Moisture_Regime $SMR  (version NBI)

sub SoilMoistureRegime
{
  my $MoistReg;
  my %MoistRegList = ("", 1, "VD", 1, "D", 1, "MF", 1, "F", 1, "VF", 1, "MM", 1, "M", 1, "VM", 1, "MW", 1, "W", 1, "VW", 1,
  "vd", 1, "d", 1, "mf", 1, "f", 1, "vf", 1, "mm", 1, "m", 1, "vm", 1, "mw", 1, "w", 1, "vw", 1);
  my $SoilMoistureReg;

  if ($INV_version eq "FRI"  || $INV_version eq "FRI_FIM")
  {
    return UNDEF;
  }
  elsif ($INV_version eq "FRI NBI") 
  {
    ($MoistReg) = shift(@_); 

    if (isempty($MoistReg)) { $SoilMoistureReg = MISSCODE; }
    elsif (!$MoistRegList {$MoistReg} ) { $SoilMoistureReg = ERRCODE; }
    elsif (($MoistReg eq "VD") || ($MoistReg eq "vd"))      { $SoilMoistureReg = "D"; }
    elsif (($MoistReg eq "D")|| ($MoistReg eq "d"))         { $SoilMoistureReg = "D"; }
    elsif (($MoistReg eq "MF")|| ($MoistReg eq "mf"))       { $SoilMoistureReg = "F"; }
    elsif (($MoistReg eq "F") || ($MoistReg eq "f"))        { $SoilMoistureReg = "F"; }
    elsif (($MoistReg eq "VF") || ($MoistReg eq "vf"))      { $SoilMoistureReg = "F"; }
    elsif (($MoistReg eq "MM") || ($MoistReg eq "mm"))      { $SoilMoistureReg = "M"; }
    elsif (($MoistReg eq "M") || ($MoistReg eq "m"))        { $SoilMoistureReg = "M"; }
    elsif (($MoistReg eq "VM") || ($MoistReg eq "vm"))      { $SoilMoistureReg = "M"; }
    elsif (($MoistReg eq "MW") || ($MoistReg eq "mw"))      { $SoilMoistureReg = "W"; }
    elsif (($MoistReg eq "W") || ($MoistReg eq "w"))        { $SoilMoistureReg = "W"; }
    elsif (($MoistReg eq "VW") || ($MoistReg eq "vw"))      { $SoilMoistureReg = "W"; }
    else  { $SoilMoistureReg = ERRCODE; }
    return $SoilMoistureReg;
  }
}

#StandStructure from   
sub StandStructure
{
 
  my $Struc;
  #my $INV_version;
  my %StrucList = ("", 1,  "S", 1, "M", 1, "VERT", 1, "s", 1, "m", 1, "vert", 1);
  my $StandStructure;

  ($Struc) = shift(@_);
  #$INV_version= shift(@_);
  if (isempty($Struc)) { $StandStructure = MISSCODE; }
  elsif (!$StrucList {$Struc} ) {  $StandStructure = ERRCODE; }
  elsif ($INV_version eq "FRI")  { $StandStructure = "S"; }
  elsif ($INV_version eq "FRI_FIM")        { $StandStructure = "S"; } #layer SI, SV, TT, MV, CX
  elsif($INV_version eq "FRI NBI")
  {
    if (($Struc eq "m") || ($Struc eq "M"))           { $StandStructure = "M"; }
    elsif (($Struc eq "s") || ($Struc eq "S"))        { $StandStructure = "S"; }
  }
  else {  $StandStructure = ERRCODE; }
  return $StandStructure;
}


#from $CC  (version FCI)  

sub CCUpper
{
  my $CCHigh;
  my $CC;

  ($CC) = shift(@_); 
  if ($INV_version eq "FRI")  { $CCHigh = UNDEF; }
  else 
  {
    if (isempty($CC)) { $CCHigh = MISSCODE; }
    elsif($CC <=100 && $CC >=0) {$CCHigh = $CC;}
    else { $CCHigh = ERRCODE; } 
  }
  return $CCHigh;
}


sub CCLower 
{
  my $CCLow;
  my $CC; 
  
  ($CC) = shift(@_);
  if ($INV_version eq "FRI")  { $CCLow = UNDEF; }
  else 
  {
    if (isempty($CC)) { $CCLow = MISSCODE; }
    elsif($CC <=100 && $CC >=0) {$CCLow =$CC;}
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
 
  if  (isempty($Height) || $Height  =~ m/^0\.?0*$/)     { $HUpp = MISSCODE; }
  elsif ($Height == 0) { $HUpp = MISSCODE;}
  elsif ($Height > 0.0) {$HUpp =$Height+0.5;}  # BK modified on 23-03-2012
  else { $HUpp = ERRCODE; }
 
 return $HUpp;
}

sub StandHeightLow 
{
  my $Height; 
  my $HLow;
  ($Height) = shift(@_);
 
  if  (isempty($Height) || $Height  =~  m/^0\.?0*$/ )  { $HLow = MISSCODE; }
  elsif ($Height == 0) { $HLow = MISSCODE;}
  elsif ($Height > 0.5) {$HLow = $Height-0.5;} # BK modified on 23-03-2012
  elsif ($Height > 0.0) {$HLow = $Height;}
  else { $HLow = ERRCODE; } 
  return $HLow;                     
}

#PW-Pinu stro,PR-Pinu resi,PJ-Pinu bank,SB-Pice mari,SW-Pice glau,BF-Abie bals,CE-Thuj occi,OC-Soft unkn,HE-Tsug cana,PO-Popu spp,PB-Popu balb,BW-Betu papy,MH-Acer sacc,QR,YB,OH-Hard unkn

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
    $CurrentSpecies=~s/\s//g;

    if ($Species_table->{$CurrentSpecies}) { $GenusSpecies = $Species_table->{$CurrentSpecies}; }
    else   {$GenusSpecies = SPECIES_ERRCODE;  print SPECSLOGFILE "Illegal species code $CurrentSpecies,CAS_ID=$Glob_CASID,file=$Glob_filename\n";  } 
  }
	return $GenusSpecies;
}


sub Species
{
  my $SPcomposition = shift(@_);
  my $spfreq = shift(@_);

  my $aux;
  my $Specs = "";
  my $actSpecs = "";
  my $singleSP;
  my $i = 0;
  my $j = 0;
  my @ListSp; 
  my $Sp1;
  my $k = 0;
  my $TotalPerctg = 0; 
  my $actTotalPerctg = 0;
  my $Speciescode;
  my $MULTIPLE = 0;
  my $nbsp = 0;
  my $SPcompositionsav;
  my $spec_transl;
  my $completion;

 
  $SPcomposition =~ s/\s//g;
  $SPcomposition =~  s/\W//g;

  if($SPcomposition eq "SB5B3PO1BW�1")
  {
		$SPcomposition="SB5B3PO1BW1";
  }

  $SPcompositionsav = $singleSP = $SPcomposition;  

  while ($singleSP ne "" ) 
  { 
    #&& $TotalPerctg <100
    # $singleSP=~ s/^\s//g; $singleSP=~ s/^\s//g;
    # while ($singleSP =~ /^\s/) 
    # {  
    #   $i=$i+1; 
    #   $singleSP=~ s/^\s//;
    # }
    while ($singleSP =~ /^\D/) 
    {  
      $i=$i+1; 
      $singleSP=~ s/^\D//;
    }
    #$Specs=$Specs.",".(substr $SPcomposition, $j, $i);
    $Speciescode = (substr $SPcomposition, $j, $i);
    #print " i= $i, j=$j species code is #$Speciescode# "; 
    # $Speciescode=~ s/\s//g;  
    # $Speciescode=~ s/\s$//; #print "species code is #$Speciescode# \n";
     
    $spfreq->{$Speciescode}++;
    $spec_transl=Latine($Speciescode);
    #print "result for -$Speciescode- = $spec_transl\n"; 
    #if($spec_transl eq SPECIES_ERRCODE  ) 
	  #{ 
	    #print "ERROR CODE FOUND while translating --$Speciescode--  taking from species orig=$SPcompositionsav \n";
		  #$completion="-1";
		  #return ($completion);
    #}
    $Specs=$Specs.",".$spec_transl;
    $actSpecs=$actSpecs.",".$spec_transl;
    $j=$j+$i; $i=0;

    $nbsp++;

    $aux="-1";   #added on 30-08-2011
    while ($singleSP =~ /^\d/) 
    {  
      $i=$i+1; 
      $singleSP=~ s/^\d//;
    }
    $aux=(substr $SPcomposition, $j, $i);
     
    if($aux eq "" || $aux eq "-1") 
    {
	   $aux=0;
     #print "look at $SPcomposition from pos $j with $i characters\n";  
    }

 	  $actTotalPerctg+=$aux;
	  $actSpecs=$actSpecs.",".$aux;

	  if($aux eq "0" && $nbsp==1) 
    {
	  $aux=10;
    #print "look2 at $SPcomposition\n";  
    }
	  if($aux eq "0" && $nbsp!=1) 
    {
		  $aux=10;
     	#print "have changed perctg from 0 to 10 in $SPcomposition\n";  
    }
    if($k == 0 && $aux > 10) 
		{
      $MULTIPLE=1;
    }

   	if( ($aux <= 9) || ($aux==10 && $singleSP eq "" && $k==0)) 
    {
		  $aux=$aux*10;
    }

    $TotalPerctg+=$aux;
    $Specs=$Specs.",".$aux;
    $j=$j+$i; $i=0;
     
    $k=$k+1; 
  }
  
  if($k > $MAXk){$MAXk=$k;}
  # print "actspec = $actSpecs total = $actTotalPerctg\n  spec = $Specs total = $TotalPerctg\n";
  if($actTotalPerctg == 100)
  {
	  $actSpecs=~ s/^//;
    $actSpecs=~ s/^,//;
	  return $actSpecs;
  }
  elsif($TotalPerctg != 100 || $singleSP ne "") 
  { 
    #print "err type 3 look at $SPcomposition\n"; 
	  $completion="-2";
		return ($completion);
  }   
 
  $Specs=~ s/^//;$Specs=~ s/^,//;
  #print "spcomp is #$SPcomposition# \n"; print $Specs."\n\n";

  #@ListSp=split(/,/, $Specs);
  #$Sp1=$ListSp[0];
  #print "$Sp1 \n";
  return $Specs;
}

 
#from $AGE,
#check with original data
sub UpperOrigin 
{
  my $Origin= shift(@_);

  if (isempty($Origin)) {$Origin = MISSCODE;}
  elsif ($Origin > 0) 
  {
    $Origin = $Origin;
  }
  else { $Origin = ERRCODE; }
  return $Origin;
}

sub LowerOrigin 
{
  my $Origin= shift(@_);

  if (isempty($Origin))  {$Origin = MISSCODE;}
  elsif ($Origin > 0) 
  {
    $Origin = $Origin;
  }
  else { $Origin = ERRCODE; }
  return $Origin;
}


sub Site 
{
  my $Site; my $INV_version;
  my $TPR;
  my %TPRList = ("", 1, "4", 1, "3", 1, "2", 1, "1", 1, "0", 1, "X", 1, "x", 1);
 
  ($TPR) = shift(@_);
  ($INV_version) = shift(@_);

  if (isempty($TPR)) { $Site = MISSCODE; }
  elsif (!$TPRList {$TPR} ){ $Site = ERRCODE; }
  elsif (($TPR eq "4") || ($TPR eq "3"))  { $Site = "P"; }
  elsif (($TPR eq "2"))                   { $Site = "M"; }
  elsif (($TPR eq "1"))                   { $Site = "G"; }
  elsif (($TPR eq "0") || ($TPR eq "X") || ($TPR eq "x")) { $Site = "G"; }
 
  return $Site;
}


#BFL, BSH, RRW, FOR, OMS, RCK, TMS, UCL, WAT
#Natnonveg ==== AP, LA, RI, OC, RK, SA, SI, SL, EX, BE, WS, FL, IS, TF
sub NaturallyNonVeg 
{
  my $NatNonVeg;
  my %NatNonVegList = ("0", 1, "", 1, "RCK", 1, "RK", 1, "R", 1, "L", 1, "LK", 1,  "I", 1, "ISL", 1, "WAT",1, "NF",1);
  
  ($NatNonVeg) = shift(@_);

  if (isempty($NatNonVeg)) {$NatNonVeg = MISSCODE;}
  else 
  {
    $_ = $NatNonVeg; 
    tr/a-z/A-Z/; 
    $NatNonVeg = $_;

    if (!$NatNonVegList {$NatNonVeg}) { $NatNonVeg = ERRCODE; }
    elsif ($NatNonVeg eq "0")     { $NatNonVeg = MISSCODE; }
    elsif (($NatNonVeg eq "R"))     { $NatNonVeg = "RI"; }
    elsif (($NatNonVeg eq "WAT"))   { $NatNonVeg = "RI"; }
    elsif (($NatNonVeg eq "RCK") )  { $NatNonVeg = "RK"; }
    elsif (($NatNonVeg eq "RK") )  { $NatNonVeg = "RK"; }
    elsif (($NatNonVeg eq "L") ||($NatNonVeg eq "LK") )     { $NatNonVeg = "LA"; }
    elsif (($NatNonVeg eq "I"))   { $NatNonVeg = "IS"; }
    elsif (($NatNonVeg eq "ISL"))   { $NatNonVeg = "IS"; }
    elsif (($NatNonVeg eq "NF"))    { $NatNonVeg = "IS"; }
    else  { $NatNonVeg = ERRCODE; }
  }
 
  return $NatNonVeg;
}  


#DAL=CL GR=HG UCL=OT I=IS L=LA R=RI
#Anthropogenic IN, FA, CL, SE, LG, BP, OT
sub Anthropogenic 
{
  my $NonVegAnth;
  my %NonVegAnthList = ("0", 1, "", 1, "DAL", 1, "UNK", 1, "OTH", 1, "RRW", 1, "BFL", 1, "BFW", 1, "BNS", 1, "UNS", 1, "UCL", 1);
 
  $NonVegAnth = shift(@_);
  if (isempty($NonVegAnth)) {$NonVegAnth = MISSCODE;}
  else
  {
    $_ = $NonVegAnth; 
    tr/a-z/A-Z/; 
    $NonVegAnth = $_;
    if (!$NonVegAnthList {$NonVegAnth}) { $NonVegAnth = ERRCODE; }
    elsif ( $NonVegAnth eq "0")   { $NonVegAnth = MISSCODE; }
    elsif(($NonVegAnth eq "DAL"))    { $NonVegAnth = "CL"; }
    elsif (($NonVegAnth eq "UCL"))    { $NonVegAnth = "OT"; }
    elsif (($NonVegAnth eq "UNK")|| ($NonVegAnth eq "OTH")|| ($NonVegAnth eq "BFW") ||($NonVegAnth eq "BNS") ||
          ($NonVegAnth eq "UNS"))    { $NonVegAnth = "OT"; }
    elsif (($NonVegAnth eq "RRW"))    { $NonVegAnth = "FA"; }
    elsif (($NonVegAnth eq "BFL"))    { $NonVegAnth = "FA"; }
    else  { $NonVegAnth = ERRCODE; }
  }
  return $NonVegAnth;
}
 
 
#NonForestedVeg ---ST, SL, HF, HE, HG, BR, OM, BT
sub NonForestedVeg 
{
  my $NonForVeg;
  my %NonForVegList = ("0", 1, "", 1, "GR", 1, "GRS", 1, "OMS", 1, "BSH", 1,  "BA", 1, "OM", 1);
 
  $NonForVeg = shift(@_);     #print "deb Nonforveg ==---$NonForVeg---\n ";
 
  if (isempty($NonForVeg))   {$NonForVeg = MISSCODE;}
  else
  {
    $_ = $NonForVeg; 
    tr/a-z/A-Z/; 
    $NonForVeg = $_;
    #if(defined $NonForVeg){} else {$NonForVeg="";}
    #print "end Nonforveg ==---$NonForVeg---\n ";
    if (!$NonForVegList {$NonForVeg})  {$NonForVeg = ERRCODE;}
    elsif ($NonForVeg eq "0")    {$NonForVeg = MISSCODE; }
    elsif (($NonForVeg eq "GR"))     { $NonForVeg = "HG"; }
    elsif (($NonForVeg eq "GRS"))    { $NonForVeg = "HG"; }
    elsif (($NonForVeg eq "OMS"))    { $NonForVeg = "OM"; }
    elsif (($NonForVeg eq "OM"))     { $NonForVeg = "OM"; }
    elsif (($NonForVeg eq "BSH") )   { $NonForVeg = "ST"; }
    elsif (($NonForVeg eq "BA") )    { $NonForVeg = "ST"; }
    else { $NonForVeg = ERRCODE; }
  }
  return $NonForVeg;
}
 
#UnProdForest TM,TR, AL, SD, SC, NP
sub UnProdForest 
{
 
  my $UnProdFor = shift(@_);

  if (isempty($UnProdFor)) {$UnProdFor = MISSCODE;}
  else
  {
    $UnProdFor = uc($UnProdFor); 
    my %UnProdForList = ("0", 1, "", 1, "TMS", 1, "TM", 1);

    if (!$UnProdForList {$UnProdFor} )  {$UnProdFor = ERRCODE;}
    elsif ($UnProdFor eq "0")           { $UnProdFor = MISSCODE; }
    elsif (($UnProdFor eq "TMS"))       { $UnProdFor = "TM"; }
    elsif (($UnProdFor eq "TM"))        { $UnProdFor = "TM"; }         
    else{ $UnProdFor = ERRCODE; }
  }
  return $UnProdFor;
}

#############################################       
sub NPCodetoNPDesc 
{
  my $NonForVeg = shift(@_);
  
  if (isempty($NonForVeg))           { $NonForVeg = ""; }
  elsif ($NonForVeg eq "315")        { $NonForVeg = "DAL"; }
  elsif ($NonForVeg eq "316")        { $NonForVeg = "GR"; }
  elsif ($NonForVeg eq "0"|| ($NonForVeg eq "300")|| ($NonForVeg eq ""))        { $NonForVeg = ""; }
  #elsif (($NonForVeg eq "317") || ($NonForVeg eq "302") || ($NonForVeg eq "308"))       { $NonForVeg = "UCL"; }
  elsif (($NonForVeg eq "317") || ($NonForVeg eq "302")|| ($NonForVeg eq "161"))       { $NonForVeg = "UCL"; }
  elsif (($NonForVeg eq "308") || ($NonForVeg eq "309")|| ($NonForVeg eq "6")|| ($NonForVeg eq "94"))       { $NonForVeg = "RRW"; }
  elsif (($NonForVeg eq "62")  || ($NonForVeg eq "266") )      { $NonForVeg = "I"; }
  elsif (($NonForVeg eq "64") || ($NonForVeg eq "265")|| ($NonForVeg eq "303")|| ($NonForVeg eq "305"))       { $NonForVeg = "L"; }
  elsif (($NonForVeg eq "152")|| ($NonForVeg eq "304"))      { $NonForVeg = "R"; }
  elsif (($NonForVeg eq "310"))      { $NonForVeg = "TM"; }
  elsif (($NonForVeg eq "311"))      { $NonForVeg = "OM"; }
  elsif (($NonForVeg eq "312"))      { $NonForVeg = "BA"; }
  elsif (($NonForVeg eq "313"))      { $NonForVeg = "RK"; }
  elsif (($NonForVeg eq "101")||($NonForVeg eq "102"))      { $NonForVeg = "LK"; }
  elsif (($NonForVeg eq "333") || ($NonForVeg eq "320")|| ($NonForVeg eq "314")|| ($NonForVeg eq "318")|| ($NonForVeg eq "666"))      { $NonForVeg = "UCL"; }
  else { $NonForVeg = ""; }
  return $NonForVeg;
}
    
#LOWMGMT, DEPHARV, NEWPLANT, NEWSEED, FTGPLANT, TTGSEED=CO                                                                                                                                                                                 LOWNAT, DEPNAT, FTGNAT=BU, STRIPCUT, FRSTPASS, SEEDTREE, PREPCUT, SEEDCUT, FIRSTCUT, LASTCUT, IMPROVE, SELECT=PC

sub Disturbance 
{
  my $ModCode;
  my $Mod;
  my $ModYr;
  my $Disturbance;
 
  my %ModList = ("", 1, "WF", 1, "BU", 1, "AK", 1, "IK", 1, "FL", 1,"CC", 1, "LOWMGMT", 1, "DEPHARV", 1, "NEWPLANT",1, "NEWSEED",1,"NEWNAT",1, "FTGPLANT",1, "TTGSEED",1,"FTGSEED",1,
    "THINPRE",1, "LOWNAT",1, "DEPNAT",1, "FTGNAT",1, "STRIPCUT",1, "FRSTPASS", 1, "SEEDTREE",1, "PREPCUT",1, "SEEDCUT",1, "FIRSTCUT",1, "LASTCUT",1, "IMPROVE",1, "SELECT",1, 
    "THINCOM",1, "DEPH",1, "DEPN",1,"FCUT",1,"FTGN",1,"FTGP",1, "FTGS",1, "IMPR",1,"LCUT",1,"LOWM",1,"LOWMGT",1, "MCUT",1, "MODCUT",1,"NEWN",1,"NEWP",1,"NEWS",1, "PCUT",1, 
    "SCUT",1,"SLCT",1,"THNC",1,"THNP",1,"DEPT",1, "LOWS",1,"SIPM",1,"TENA",1,"TENG",1,"CLAAG",1,"HARP",1,"SCAR",1);
  
  ($ModCode) = shift(@_);
  ($ModYr) = shift(@_);

  if(isempty($ModYr)) {$ModYr=MISSCODE;}

  if(isempty($ModCode)) {$Mod=MISSCODE; $Disturbance = $Mod . "," . $ModYr;}
  elsif ($ModList{$ModCode} ) 
  {
    if ($INV_version eq "FRI NBI") 
    {
      if (($ModCode  eq "BU") || ($ModCode eq "bu")) { $Mod="BU"; }
      elsif (($ModCode  eq "AK") || ($ModCode eq "ak")) { $Mod="OT"; }
      elsif (($ModCode  eq "WF") || ($ModCode eq "wf")) { $Mod="WF"; }
      elsif (($ModCode  eq "CC") || ($ModCode eq "cc")) { $Mod="CO"; }
      elsif (($ModCode  eq "IK") || ($ModCode eq "ik")) { $Mod="IK"; }
      elsif (($ModCode  eq "FL") || ($ModCode eq "fl")) { $Mod="FL"; }
      else  {   $Mod = ERRCODE; }
    }
    elsif ($INV_version eq "FRI_FIM") 
    {
      if ( $ModCode  eq "LOWMGMT" || $ModCode  eq "DEPHARV" || $ModCode  eq"NEWPLANT" )  { $Mod="CO"; }  #NEWNAT is guessed by SC
      elsif($ModCode  eq "NEWSEED" || $ModCode  eq "FTGPLANT" || $ModCode  eq "TTGSEED"|| $ModCode  eq "FTGSEED" )    { $Mod="CO"; }
      elsif ($ModCode  eq "LOWNAT" ||$ModCode  eq  "DEPNAT" || $ModCode  eq "FTGNAT" || $ModCode  eq "DEPN") { $Mod="BU"; }
      elsif ($ModCode  eq "STRIPCUT" ||$ModCode  eq "THINCOM"  ||$ModCode  eq "FRSTPASS"||$ModCode  eq "SEEDTREE" ){$Mod="PC"; }
      elsif ($ModCode  eq "PREPCUT" || $ModCode  eq "SEEDCUT" || $ModCode  eq "FIRSTCUT"){$Mod="PC"; }
      elsif ($ModCode  eq "LASTCUT"|| $ModCode  eq "IMPROVE" ||$ModCode  eq "SELECT") {$Mod="PC"; }
	    elsif ($ModCode  eq "LCUT" ||$ModCode  eq "SCAR"  ||$ModCode  eq "SLCT"  || $ModCode  eq "THINPRE") {$Mod="SI"; }
	    elsif ($ModCode  eq "PCUT"|| $ModCode  eq "THNP"|| $ModCode  eq "SCUT"|| $ModCode  eq "IMPR" ) {$Mod="SI"; }
	    elsif ($ModCode  eq "FCUT"||$ModCode  eq "HARP") {$Mod="PC"; }
 	    elsif ($ModCode  eq "THNC" || $ModCode  eq "MODCUT" || $ModCode  eq "MCUT") {$Mod="PC"; }
	    elsif ($ModCode  eq "DEPH" || $ModCode  eq "FTGP" || $ModCode  eq "FTGS"|| $ModCode  eq "LOWM"  || $ModCode  eq "LOWMGT"){ $Mod="CO"; }    
	    elsif ($ModCode  eq "NEWP"|| $ModCode  eq "NEWS" )    { $Mod="CO"; }    
	    elsif ($ModCode  eq "FTGN"|| $ModCode  eq "NEWN"|| $ModCode  eq"NEWNAT" ) {$Mod="BU"; }
      elsif ($ModCode  eq "DEPT"|| $ModCode  eq "LOWS"|| $ModCode  eq"SIPM" || $ModCode  eq "TENA"|| $ModCode  eq"TENG" || $ModCode  eq"CLAAG") {$Mod="OT"; }
    }
    else 
    {
      $Mod=UNDEF;
      $ModYr=UNDEF;
    }
    $Disturbance = $Mod . "," . $ModYr;
  } 
  else
  { 
    $Mod = ERRCODE; $Disturbance = $Mod . "," . $ModYr;  
  }
  return $Disturbance;
}


sub DisturbanceExtUpper 
{
  my $ModExt;
  my $DistExtUpper;
  my %DistExtList = ("", 1, "1", 1, "2", 1, "3", 1, "4",1, "5");

  ($ModExt) = shift(@_);

  if ($INV_version eq "FRI NBI") 
  {
    if (isempty($ModExt)) {$DistExtUpper = MISSCODE; }
    elsif (!$DistExtList{$ModExt} ) {$DistExtUpper = ERRCODE; }
    elsif ($ModExt == 1 )  { $DistExtUpper = 25; }
    elsif ($ModExt == 2)  { $DistExtUpper = 50; }
    elsif ($ModExt == 3)          { $DistExtUpper = 75; }
    elsif ($ModExt == 4)  { $DistExtUpper = 95; }
    elsif ($ModExt == 5)  { $DistExtUpper = 100; }
    else  {$DistExtUpper = ERRCODE; }
  }
  else
  {
    $DistExtUpper = UNDEF;
  }
  return $DistExtUpper;
}

sub DisturbanceExtLower 
{
  my $ModExt;
  my $DistExtLower;
  my %DistExtList = ("", 1, "1", 1, "2", 1, "3", 1, "4",1, "5",1);

  ($ModExt) = shift(@_);

  if ($INV_version eq "FRI NBI") 
  {
    if (isempty($ModExt)) {$DistExtLower = MISSCODE; }
    elsif (!$DistExtList{$ModExt} ) {$DistExtLower = ERRCODE; }
    elsif ($ModExt == 1 ) { $DistExtLower = 1; }
    elsif ($ModExt == 2)  { $DistExtLower = 26; }
    elsif ($ModExt == 3)  { $DistExtLower = 51; }
    elsif ($ModExt == 4)  { $DistExtLower = 76; }
    elsif ($ModExt == 5)  { $DistExtLower = 96; }
    else {$DistExtLower = MISSCODE; }
  }
  else
  {
    $DistExtLower = UNDEF;
  }
  return $DistExtLower;
}
 
# Determine wetland codes
sub WetlandCodes 
{
  my $UnProd;  
  my $Species1;
  my $Species2;
  my $Species3;
  my $SpeciesPerc;
  my $Ecosite;
  my $Wetland = "";
  my $MNRCode;

  $Ecosite = shift(@_);
  $MNRCode = shift(@_);
  $UnProd = shift(@_);
  $Species1 = shift(@_);
  $Species2 = shift(@_);
  $Species3 = shift(@_);
  $SpeciesPerc = shift(@_);
 
  #  print "ecosite is $Ecosite\n";exit;
  if (defined $Ecosite ) {$_ = $Ecosite; tr/a-z/A-Z/; $Ecosite = $_;} else { $Ecosite="";} 
  if (defined $Species1 ) {$_ = $Species1; tr/a-z/A-Z/; $Species1 = $_;} else {$Species1="";} 
  if (defined $Species2 ) {  $_ = $Species2; tr/a-z/A-Z/; $Species2 = $_;} else {$Species2="";} 
  if (defined $Species3 ) {$_ = $Species3; tr/a-z/A-Z/; $Species3 = $_;} else {$Species3="";} 


  if($INV_version eq "FRI" || $INV_version eq "FRI_FIM")
  {

    if(isempty($Ecosite) || $Ecosite eq "0")
    {
      if ($MNRCode eq "310" || $UnProd eq "TMS") {  $Wetland="F,T,N,N,"; } 
      elsif ($MNRCode eq "311" || ($UnProd eq "OMS")|| ($UnProd eq "OM")) {  $Wetland="F,O,N,S,"; }
      elsif ($MNRCode eq "312" || ($UnProd eq "BSH")|| ($UnProd eq "BA")) {  $Wetland="S,O,N,S,"; }
		  else 
      {
        if( ($Species1 eq "SB" && $Species2 eq "L") || ($Species1 eq "L" && $Species2 eq "SB") )  { $Wetland = "S,T,N,N,"; }
			  elsif( $Species1 eq "L" && $Species2 eq "SB" && $Species3 eq "CE" ) { $Wetland = "S,T,N,N,"; }
			  elsif( $Species1 eq "SB" && $Species2 eq "L" && $Species3 eq "CE" ) { $Wetland = "S,T,N,N,"; }

			  elsif( ($Species1 eq "CE" && $Species2 eq "L") || ($Species1 eq "L" && $Species2 eq "CE") ){ $Wetland = "S,T,N,N,"; }
			  elsif( $Species1 eq "CE" && $Species2 eq "L" && $Species3 eq "SB" ) { $Wetland = "S,T,N,N,"; }
			  elsif( $Species1 eq "CE" && $Species2 eq "SB" && $Species3 eq "L" ) { $Wetland = "S,T,N,N,"; }

			  elsif( ($Species1 eq "L" || $Species1 eq "AB" )&&  $SpeciesPerc ==100)    { $Wetland = "S,T,N,N,"; }

        elsif( $Species1 eq "BW" && ($Species2 eq "L" || $Species2 eq "CE")) { $Wetland = "S,T,N,N,"; }
        elsif( ($Species1 eq "L" || $Species1 eq "CE") && $Species2 eq "BW") { $Wetland = "S,T,N,N,"; }       
			  else {$Wetland = MISSCODE;} 		
		  }
 	  }
	  else 
    {
			if ($Ecosite eq "ES34")                                                                      {  $Wetland="B,T,N,N,"; }
			elsif ($Ecosite eq "ES35" || $Ecosite eq "ES36" || $Ecosite eq "ES37" || $Ecosite eq "ES38") {  $Wetland="S,T,N,N,"; }  
			elsif ($Ecosite eq "ES40")                                                                   {  $Wetland="F,T,N,N,"; }
			elsif ($Ecosite eq "ES41" || $Ecosite eq "ES42" )                                            {  $Wetland="F,O,N,S,"; }  
			elsif ($Ecosite eq "ES43" || $Ecosite eq "ES45" )                                            {  $Wetland="F,O,N,G,"; }  
			elsif ($Ecosite eq "ES44") {  $Wetland="S,O,N,S,"; }
			elsif ($Ecosite eq "ES46" || $Ecosite eq "ES47" || $Ecosite eq "ES48" || $Ecosite eq "ES49" || $Ecosite eq "ES50") {  $Wetland="M,O,N,G,"; } 
			elsif ($Ecosite eq "ES51" || $Ecosite eq "ES52" || $Ecosite eq "ES53")                       {  $Wetland="O,O,N,N,"; } 
			elsif ($Ecosite eq "ES54" || $Ecosite eq "ES55" || $Ecosite eq "ES56")                       {  $Wetland="O,O,N,N,"; } 

			elsif ($Ecosite eq "NW34")                                                                   {  $Wetland="B,T,N,N,"; }
			elsif ($Ecosite eq "NW35" || $Ecosite eq "NW36" || $Ecosite eq "NW37" || $Ecosite eq "NW38") {  $Wetland="S,T,N,N,"; }  
			elsif ($Ecosite eq "NW40")                                                                   {  $Wetland="F,T,N,N,"; }
			elsif ($Ecosite eq "NW41" || $Ecosite eq "NW42"  )                                           {  $Wetland="F,O,N,S,"; }  
			elsif ($Ecosite eq "NW43" || $Ecosite eq "NW45" )                                            {  $Wetland="F,O,N,G,"; }  
			elsif ($Ecosite eq "NW44") {  $Wetland="S,O,N,S,"; }
			elsif ($Ecosite eq "NW46" || $Ecosite eq "NW47" || $Ecosite eq "NW48" || $Ecosite eq "NW49" || $Ecosite eq "NW50") {  $Wetland="M,O,N,G,"; } 
			elsif ($Ecosite eq "NW51" || $Ecosite eq "NW52" || $Ecosite eq "NW53")                       {  $Wetland="O,O,N,N,"; } 
			elsif ($Ecosite eq "NW54" || $Ecosite eq "NW55" || $Ecosite eq "NW56")                       {  $Wetland="O,O,N,N,"; } 


			elsif ($Ecosite eq "ES11" || $Ecosite eq "ES14"  )                                           {  $Wetland="B,T,N,N,"; }  
			elsif ($Ecosite eq "ES13P") {  $Wetland="F,T,N,N,"; }
			elsif ($Ecosite eq "ES12" || $Ecosite eq "ES13R")                                            {  $Wetland="S,T,N,N,"; }

			elsif ($Ecosite eq "NE9P" || $Ecosite eq "NE11" || $Ecosite eq "NE12" || $Ecosite eq "NE13P" ) {  $Wetland="B,F,-,-,"; } 
			elsif ($Ecosite eq "NE14")                                                                   {  $Wetland="B,T,-,-,"; }

			elsif ($Ecosite eq "ES31")                                                                   {  $Wetland="F,T,N,N,"; }
			elsif ($Ecosite eq "ES32" ||$Ecosite eq "ES33" ||$Ecosite eq "ES34")                         {  $Wetland="S,T,N,N,"; }

			elsif ($Ecosite eq "CE31" ||$Ecosite eq "CE32" ||$Ecosite eq "CE33")                         {  $Wetland="B,F,-,-,"; }
			elsif ($Ecosite eq "CR31" ||$Ecosite eq "CR32" ||$Ecosite eq "CR33")                         {  $Wetland="B,F,-,-,"; }
 
			else {$Wetland = ERRCODE;} 
	 }
  }

  if ($Wetland eq "") {$Wetland = MISSCODE;}# MISSCODE.",".MISSCODE.",".MISSCODE.",".MISSCODE.",";
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


 
######################################################################################
###    Here is the main function  ####
######################################################################################

sub ONinv_to_CAS 
{
 	
  my $ON_File = shift(@_);
	$Species_table = shift(@_);
 	my $CAS_File = shift(@_);
 	my $ERRFILE = shift(@_);
 	my $nbiters = shift(@_);
 	my $optgroups= shift(@_);
 	my $pathname=shift(@_);
 	my $TotalIT=shift(@_);
  
 	my $temp=shift(@_);
	my $PIYear=shift(@_);

	my $SPERRS = shift(@_);
	my $spfreq=shift(@_);

	my $ncas=shift(@_);
	my $nlyr=shift(@_);
	my $nnfl=shift(@_);
	my $ndst=shift(@_);
	my $neco=shift(@_);
	my $ndstonly=shift(@_);
	my $necoonly=shift(@_);
	my $nflareatotal=shift(@_);
	#my $onboreal=shift(@_);
	#my $onnflfreq=shift(@_);
	#my $NFLFREQS=shift(@_);

	my $SPECSLOG=shift(@_);
	my $oncorrectionfile=shift(@_);

	my $nflarea=0;
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
 
	my $key1;
	my $key2;
	my $key3;

	print "PIyear == $PIYear\n";

  my $CAS_File_HDR = $CAS_File . ".hdr";
  my $CAS_File_CAS = $CAS_File . ".cas";
  my $CAS_File_LYR = $CAS_File . ".lyr";
  my $CAS_File_NFL = $CAS_File . ".nfl";
  my $CAS_File_DST = $CAS_File . ".dst";
  my $CAS_File_ECO = $CAS_File . ".eco";

	my %ON_SPcorrection = ();
	my $correctionfile= $oncorrectionfile;
 
 if(defined $correctionfile && $correctionfile ne "")
 {
	open( ON_SPC, "$correctionfile" )
	  || die "\n Error: Could not open species correction file $correctionfile !\n";
	my $csv2    = Text::CSV_XS->new ({
    binary          => 1,
    sep_char    => ";" 
  });
	while (<ON_SPC>) {
		if ( $csv2->parse($_) ) {
			my @ONSP_Record = ();
			@ONSP_Record = $csv2->fields();
			my $ONkeys = $ONSP_Record[0];
			$ON_SPcorrection{$ONkeys} = $ONSP_Record[1];
			#print("fFILE no = $MBkeys , age = @MBS_Record[1]\n"); #exit;
		}
		else {
			my $err = $csv2->error_input;
			print "Failed to parse line: $err";
			exit(1);
		}
	}
	close(ON_SPC);


}

  $INV_version=$temp; print "version $INV_version on $ON_File\n"; 
  #open (ONinv, "<$ON_File") || die "\n Error: Could not open ON input file $ON_File!\n";
  open (ERRS, ">>$ERRFILE") || die "\n Error: Could not open $ERRFILE file!\n";
  #open (SPERRS, ">>$SPERRFILE") || die "\n Error: Could not open $SPERRFILE file!\n";
  open (SPERRSFILE, ">>$SPERRS") || die "\n Error: Could not open $SPERRS file!\n";
  #open (NFLFREQFILE, ">>$NFLFREQS") || die "\n Error: Could not open $NFLFREQS file!\n";
  open (SPECSLOGFILE, ">>$SPECSLOG") || die "\n Error: Could not open $SPECSLOG file!\n";
  if($optgroups==1)
  {
    $CAS_File_HDR = $pathname."/ONLPtable.hdr";
    $CAS_File_CAS = $pathname."/ONLPtable.cas";
    $CAS_File_LYR = $pathname."/ONLPtable.lyr";
    $CAS_File_NFL = $pathname."/ONLPtable.nfl";
    $CAS_File_DST = $pathname."/ONLPtable.dst";
    $CAS_File_ECO = $pathname."/ONLPtable.eco";
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

 	  # printing table headers
    print CASCAS "CAS_ID,ORIG_STAND_ID,STAND_STRUCTURE,NUM_OF_LAYERS,IDENTIFICATION_ID,MAP_SHEET_ID,GIS_AREA,GIS_PERIMETER,INVENTORY_AREA,PHOTO_YEAR\n";
    print CASLYR "CAS_ID,SOIL_MOIST_REG,STRUCTURE_PER,LAYER,LAYER_RANK,CROWN_CLOSURE_UPPER,CROWN_CLOSURE_LOWER,HEIGHT_UPPER,HEIGHT_LOWER,PRODUCTIVE_FOR,".    
    "SPECIES_1,SPECIES_PER_1,SPECIES_2,SPECIES_PER_2,SPECIES_3,SPECIES_PER_3,SPECIES_4,SPECIES_PER_4,SPECIES_5,SPECIES_PER_5,SPECIES_6,SPECIES_PER_6,SPECIES_7,SPECIES_PER_7,".
    "SPECIES_8,SPECIES_PER_8,SPECIES_9,SPECIES_PER_9,SPECIES_10,SPECIES_PER_10,ORIGIN_UPPER,ORIGIN_LOWER,SITE_CLASS,SITE_INDEX\n";
    print CASNFL "CAS_ID,SOIL_MOIST_REG,STRUCTURE_PER,LAYER,LAYER_RANK,CROWN_CLOSURE_UPPER,CROWN_CLOSURE_LOWER,HEIGHT_UPPER,HEIGHT_LOWER,NAT_NON_VEG,NON_FOR_ANTH,NON_FOR_VEG\n";
    print CASDST "CAS_ID,DIST_1,DIST_YR_1,DIST_EXT_UPPER_1,DIST_EXT_LOWER_1,DIST_2,DIST_YR_2,DIST_EXT_UPPER_2,DIST_EXT_LOWER_2,DIST_3,DIST_YR_3,DIST_EXT_UPPER_3,DIST_EXT_LOWER_3,LAYER\n";
    print CASECO "CAS_ID,WETLAND_TYPE,WET_VEG_COVER,WET_LANDFORM_MOD,WET_LOCAL_MOD,ECO_SITE\n";
    print CASHDR "IDENTIFICATION_ID,JURISDICTION,COORDINATE_SYS,PROJECTION,DATUM,INVENTORY_OWNER,LAND_OWNER,PERMISSION,TENURE_TYPE,INV_TYPE,INV_VERSION,INV_START_YR,INV_FINISH_YR,INV_ACQ_ID,INV_ACQ_YR,INV_UPDATE_YR\n";

    my $HDR_Record =  "1,ON,OBM,UTM,NAD83,PROV_GOV,,,,FRI-FIM,FIM1,2006,,,,";
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
 
  my $Record; my @Fields;my $StandID; my $CAS_ID; my $MapSheetID; my $IdentifyID;my $Area; my $Perimeter;
  my $Mer;my $Rng;my $Twp;my $MoistReg; my $Height;my $UHeight;
  my $SpAss; my $Sp1;my $Sp2;my $Sp3; my $Sp4;my $Sp5;my $Sp6;my $Sp7;my $Sp8; my $Sp9;my $Sp10;my $USp1;my $USp2;my $USp3; my $USp4;my $USp5;
  my $Sp1Per;my $Sp2Per;my $Sp3Per;  my $Sp4Per; my $Sp5Per; my $Sp6Per;my $Sp7Per;my $Sp8Per; my $Sp9Per;my $Sp10Per;
  my $CrownClosure;
  my $Origin;
  my $Dist; my $Dist1; my $Dist2; my $Dist3;
  my $WetEco;  my $Ecosite;my $SMR;
  my $StandStructureCode;
  my $CCHigh;my $CCLow;
  my $SpeciesComp; my $SpComp; my $USpeciesComp; my $USpComp;
  my $SiteClass; my $SiteIndex;my $USiteClass;
  my $Wetland; 
  my $NatNonVeg;
  my %herror=();  
  #my %hsperror=();
  my $keys;
  my $PHOTOYEAR; my $Cd1; my $Cd2;
  my $HeightHigh ; my $UHeightHigh ; my  $UHeightLow;
  my  $HeightLow;  my  $OriginHigh; my $OriginLow;   my  $UOriginHigh; my $UOriginLow;  my @ListSp; my $Mod; my $ModYr; my $NonProd; my $Drain;
  my $CAS_Record; my $Lyr_Record; my $LYR_Record1; my $LYR_Record2; my $LYR_Record3; my $LYR_Record4;
  my $NFL_Record; my $NFL_Record1; my $NFL_Record2; my $NFL_Record3;my $NFL_Record4; my $DST_Record;
  my  @SpecsPerList; my  @USpecsPerList;my $pr1;my $pr2;my $pr3;my $pr4;my $pr5; my $SpAssoc; my $SiteCode; my $StandStructureVal;
  my $NonVegAnth; my $NonForVeg; my $UnProdFor; my $PHOTO_YEAR; my  $cpt_ind;
  my $INV_cod_stand; my $Struc; my $StrucPer;my $LayerRank;my $LayerId;my $NumLayers; my $NonVeg; my $NonVegCov; my $NPdesc; my $NPcode; my $Nfor_desc;
  my $LCC1; my $LCC2;my $LCC3; my $LCC4;my $LCC5; my $LandCoverCode;my $Mod1; my $Mod2;my $Mod1Ext; my $Mod1Yr; my $WetEcosite; my @SpecsInit;
   
  my $erkeys; my $cptl=0; my  $UOrigin;
  my $nblayers;
  my $NPcodedesc; my $NatNonVeg2;  my $NonVegAnth2; my $UnProdFor2; my $NonForVeg2; my $NatNonVegCor;my $SpeciesCode;
  my $USpeciesCode; my $MNRCode; my $nbelts=0; my $Unbelts=0;

  my $csv = Text::CSV_XS->new
  ({
    binary          => 1,
  	sep_char    => ";" 
  });
          
  open my $ONinv, "<", $ON_File or die " \n Error: Could not open ON input file $ON_File: $!";
  my @tfilename= split ("/", $ON_File);
  my $nps=scalar(@tfilename);
  $Glob_filename= $tfilename[$nps-1];

  $csv->column_names ($csv->getline ($ONinv));

  #my @codeparts=split("/", $ON_File);
  #my $ts="SB 5B  3PO 1BW�1";
  #$ts=~s/\s//g;
  #if($ts eq "SB5B3PO1BW�1"){print "test ok\n";} exit;
  #my $namec=$codeparts[$ts-1];
  #print "$namec\n";
  #my $part;

  while (my $row = $csv->getline_hr ($ONinv)) 
  { 

  	#my  $TESTV= Species("SB 50BF  30PO 10BW 10");
  	#print "$TESTV\n";
  	#exit;

    foreach my $colkeys (keys %$row) 
    {
      $row->{$colkeys} = "" if !$row->{$colkeys}; #$part=$row->{$colkeys}; print "$part,";
  	}
    #print Dumper(%$row) ."\n";
    #exit;
    $cptl++;
    $Glob_CASID   =  $row->{CAS_ID};
    ($pr1,$pr2,$pr3, $pr4, $pr5)     =  split("-", $row->{CAS_ID} ); 
    $CAS_ID       =  $row->{CAS_ID};  #print " $CAS_ID "; 
    $pr3 =~ s/x+//;
    $MapSheetID   =  $pr3;
    $IdentifyID   =  $row->{HEADER_ID};   
    $StandID = $pr4;  
    if(!defined $MapSheetID) 
    {
      print "undefined mapsheet id, cas id = $CAS_ID--$cptl \n"; 
      $keys = "mapsheet id"."#".$CAS_ID;
     	$herror{$keys}++;
      next; 
    }

    if(!defined $StandID) 
    {
      print "undefined standid id, cas id =$CAS_ID --$cptl\n";
      $keys="stand id"."#".$CAS_ID;
     	$herror{$keys}++; 
      next;
    }

    if(defined $row->{SHAPE_AREA}) 
    {
   		$Area  =  $row->{SHAPE_AREA};
    }  
    else 
    {
      $Area=0.;
    }  
    if(defined $row->{SHAPE_PERI}) 
    {
      $Perimeter    =  $row->{SHAPE_PERI};
    } 
    else 
    {
      $Perimeter=0.;
    }


    $NonVeg       =  $row->{POLYTYPE};    #natnonveg  POLYTYPE
    $MNRCode       =  $row->{MNR_CODE};
    $Origin       =  $row->{YRORG}; 
    $UOrigin       =  $row->{UYRORG}; 
    if (defined $row->{UYRORG}) {} else  {$UOrigin="";}
    #if (defined $row->{AGE}) {} else {print "  age not defined\n"; exit;}
    $Mod1         =  $row->{DEVSTAGE};   #DEVSTAGE
    $Mod1Yr       =  $row->{YRDEP};

    if(isempty($Mod1Yr))
    {
      $Mod1Yr = MISSCODE;
    }
    if(isempty($row->{YRUPD}))
    {
      $PHOTO_YEAR = MISSCODE;
    }
    else 
    {
      $PHOTO_YEAR = $row->{YRUPD};
    }

    $SpeciesCode          =  $row->{SPCOMP};  
    $SpeciesCode =~ s/\s//g; 
    $SpeciesCode =~ s/\W//g; 
    if( defined $ON_SPcorrection{$SpeciesCode}) 
    {
			$SpeciesCode=$ON_SPcorrection{$SpeciesCode};
    }

    if (defined $row->{USPCOMP}) 
    {  
      $USpeciesCode  =  $row->{USPCOMP};
    } 
    else  
    {
      $USpeciesCode  = "";
    }
    $USpeciesCode =~ s/\s//g; 
    if(defined $ON_SPcorrection{$USpeciesCode}) 
    {
			$USpeciesCode=$ON_SPcorrection{$USpeciesCode};
    }


    $Height   =  $row->{HT};  #HT
    $SiteIndex  =  MISSCODE; #$row->{USI}; #SiteIndex SI
    $SiteClass =  $row->{SC};
    $Ecosite      =  $row->{ECOSITE1};
  
    if (defined $row->{UHT}) {$UHeight   =  $row->{UHT};} else  {$UHeight   = "";}
   
    if (defined $row->{USC}) {  $USiteClass =  $row->{USC};} else  {$USiteClass   = "";}

    if($INV_version eq "FRI NBI") 
    {

      $SMR =  SoilMoistureRegime($MoistReg);
      if($SMR eq ERRCODE) 
      {
     		$keys="MoistReg"."#".$MoistReg;
     		$herror{$keys}++; 
      }
    }
    else 
    {
      $SMR = UNDEF;
    }

    $StandStructureVal     =  UNDEF;  #"";
    $CCHigh       =  MISSCODE; #CCUpper($CrownClosure);
    $CCLow        =  MISSCODE; #CCLower($CrownClosure);
  
    # ===== Modifiers =====   TODO
    $Dist1 = Disturbance($Mod1, $Mod1Yr);
    ($Cd1, $Cd2)=split(",", $Dist1);
    if($Cd1 eq ERRCODE) 
    {  
      if($Mod1 == 0 && ($Mod1Yr eq "0" || $Mod1Yr eq ""))
      {}
			else 
      {
				$keys="Disturbance"."#".$Mod1;
				$herror{$keys}++; 
			}
	  }
    $Dist2 = MISSCODE.","."-1111,".MISSCODE. "," . MISSCODE;
    $Dist3 = MISSCODE.","."-1111,".MISSCODE. "," . MISSCODE;
    $Dist1 = $Dist1 . "," . MISSCODE . "," . MISSCODE;
    $Dist = $Dist1 . "," . $Dist2 . "," . $Dist3;


    $HeightHigh   =  StandHeightUp($Height);
    $HeightLow    =  StandHeightLow($Height);
         
    if($HeightHigh  eq ERRCODE   || $HeightLow  eq ERRCODE) 
    { 
			$keys="Height"."#".$Height;
				$herror{$keys}++;									
	  }
    if($HeightHigh  eq MISSCODE   || $HeightLow  eq MISSCODE) 
    { 
  		if(!isempty($SpeciesCode) && $SpeciesCode ne "0")
      {
  		  #$keys="NULL Height"."#".$Height."#Distcode1#".$Cd1."#polytype#".$NonVeg;
  			$keys="NULL Height with valid species"."#".$Height."#polytype#".$NonVeg;
  			$herror{$keys}++;
  		}	
  		else 
      {
  			$HeightHigh = UNDEF;
  			$HeightLow = UNDEF;
  		}								
    }

    $UHeightHigh   =  StandHeightUp($UHeight);
    $UHeightLow    =  StandHeightLow($UHeight);
         
    if($UHeightHigh  eq ERRCODE   || $UHeightLow  eq ERRCODE) 
    { 
			$keys="understorey Height"."#".$UHeight;
			$herror{$keys}++;									
		}

		if($UHeightHigh  eq MISSCODE   || $UHeightLow  eq MISSCODE) 
    { 
			if(!isempty($USpeciesCode) && $USpeciesCode ne "0")
      {
				$keys = "NULL understorey  Height with Uspecies#".$UHeight; #."#speciescode".$USpeciesCode;
				$herror{$keys}++;
			}	
			else 
      {
				$UHeightHigh=UNDEF;
				$UHeightLow =UNDEF;
			}								
		}

    if ($SpeciesCode !~ /[A-Z]/) 
	  { 
      #print "null species code --$SpeciesCode--\n";  
		  $SpeciesComp  = "XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
		  #print "translation is --$SpeciesComp--\n";  
    	$Sp1=MISSCODE;$Sp2=MISSCODE;$Sp3=MISSCODE;$Sp4=MISSCODE;
	  }
    else
   	{
		  $SpeciesComp  =  Species($SpeciesCode, $spfreq);  
		  if($SpeciesComp eq "-1" || $SpeciesComp eq "-2")
      {
				$keys="invalid total percentage spcomp#".$SpeciesCode."#CAS casid=".$CAS_ID;
        $herror{$keys}++; 
				#$Sp1=MISSCODE;$Sp2=MISSCODE;$Sp3=MISSCODE;$Sp4=MISSCODE;
			}
		  #else {
			@SpecsPerList  = split(",", $SpeciesComp);  
			$nbelts= @SpecsPerList; 
			$nbelts=$nbelts/2; #print " $nbelts elements\n";
		
  		for($cpt_ind=0; $cpt_ind<10-$nbelts; $cpt_ind++)
      {
   			$SpeciesComp  =  $SpeciesComp.",XXXX UNDF,0";
  		}
   			#print "speciescomps is  $SpeciesComp\n";
   		@SpecsPerList  = split(",", $SpeciesComp); $Sp1=$SpecsPerList[0];$Sp2=$SpecsPerList[2];$Sp3=$SpecsPerList[4];$Sp4=$SpecsPerList[6];
   			
      for($cpt_ind=0; $cpt_ind<=3; $cpt_ind++)
			{  
				my $posi=$cpt_ind*2;
        if($SpecsPerList[$posi]  eq SPECIES_ERRCODE ) 
				{ 
					$keys="Species$cpt_ind"."#in#".$SpeciesCode;
					$herror{$keys}++; 
				}
   		}
		  #}
	  }
    $nblayers=1;
    if($INV_version eq "FRI_FIM") { $StandStructureCode   =  "S";} else {$StandStructureCode =UNDEF;}
    # understorey species

    if ($USpeciesCode !~ /[A-Z]/) 
	  { 
      #print "null species code --$SpeciesCode--\n";  
		  $USpeciesComp  = "XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
		  #print "translation is --$SpeciesComp--\n";  
    	$USp1=MISSCODE;$USp2=MISSCODE;$USp3=MISSCODE;$USp4=MISSCODE;
	  }
    else
   	{	
      $nblayers=2;
		  $StandStructureCode ="V";
		  $USpeciesComp  =  Species($USpeciesCode, $spfreq);  
		  if($USpeciesComp eq "-1" || $USpeciesComp eq "-2")
      {
				$keys="invalid understorey species in casid ".$CAS_ID.":".$USpeciesCode;
        $herror{$keys}++; 
				#$USp1=MISSCODE;$USp2=MISSCODE;$USp3=MISSCODE;$USp4=MISSCODE;
			}
		  #else {
			@USpecsPerList  = split(",", $USpeciesComp);  
			$Unbelts= @USpecsPerList; 
			$Unbelts=$Unbelts/2; #print " $nbelts elements\n";
  		for($cpt_ind=0; $cpt_ind<10-$Unbelts; $cpt_ind++)
      {
   			$USpeciesComp  =  $USpeciesComp .",XXXX UNDF,0";  #
  		}
   		#print "speciescomps is  $SpeciesComp\n";
   		@USpecsPerList  = split(",", $USpeciesComp); 
      $USp1=$USpecsPerList[0];$USp2=$USpecsPerList[2];$USp3=$USpecsPerList[4];$USp4=$USpecsPerList[6];
 
   		for($cpt_ind=0; $cpt_ind<=3; $cpt_ind++)
			{  
				my $uposi=$cpt_ind*2;
        if($USpecsPerList[$uposi]  eq SPECIES_ERRCODE ) 
				{ 
					$keys="USpecies$cpt_ind"."#in#".$USpeciesCode;
          $herror{$keys}++; 
				}
   		}
		  #}
    }

    ####

    $OriginHigh   =  UpperOrigin($Origin);
    $OriginLow    =  LowerOrigin($Origin);
	  my $modify_orig=0;
 	  if(($OriginHigh  eq MISSCODE   || $OriginLow  eq MISSCODE ) &&  $NonVeg eq "FOR" )
    { 
      #$Sp1 ne MISSCODE
			if (defined $row->{AGE}) 
      { 
				if($row->{AGE} ne "0" && !isempty($row->{AGE}) && !isempty($PIYear))
        { 
					$Origin = $PIYear-$row->{AGE}; 
					$OriginHigh   =  UpperOrigin($Origin);
        	$OriginLow    =  LowerOrigin($Origin);
					$modify_orig=1;
					if( $PHOTO_YEAR eq "0" || $PHOTO_YEAR eq MISSCODE || isempty($PHOTO_YEAR))
          {
            $PHOTO_YEAR = $PIYear;
          }
				} 
			}													
	  }

	  if(($OriginHigh  eq MISSCODE   || $OriginLow  eq MISSCODE ) &&  $NonVeg eq "FOR" )
    { 
      #$Sp1 ne MISSCODE
			if(!$modify_orig)
      {
				$keys="NULL Origin"."#".$Origin."#polytype#".$NonVeg."Distcode1#".$Cd1."#Age#".$row->{AGE}; #."mnr#".$MNRCode;
			}
			else 
      {
				$keys="NULL Origin_modified by PIYear"."#".$Origin."#polytype#".$NonVeg."Distcode1#".$Cd1."#Age#".$row->{AGE}; #."mnr#".$MNRCode;
			}
			$herror{$keys}++;														
	  }

    if( ($OriginHigh > 2014) || (($OriginHigh < 1700) && ($OriginHigh > 0)) ) 
    {
			$keys="OriginYear"."#".$OriginHigh."#speciescomp#".$SpeciesCode."#Age is#".$row->{AGE}."#and Photoyear is#".$PHOTO_YEAR."#modified photo_year#".$modify_orig;  $herror{$keys}++;
			$OriginHigh=ERRCODE; $OriginLow    =ERRCODE;
	  }

	  $UOriginHigh   =  UpperOrigin($UOrigin);
    $UOriginLow    =  LowerOrigin($UOrigin);

	  if( ($UOriginHigh > 2014) || (($UOriginHigh < 1700) && ($UOriginHigh > 0)) ) 
    {
			$keys="understorey OriginYear"."#".$UOriginHigh."#Age is#".$row->{AGE}."#and Photoyear is#".$PHOTO_YEAR;  $herror{$keys}++;
			$UOriginHigh=ERRCODE; $UOriginLow    = ERRCODE;
	  }
 	  if(($UOriginHigh  eq MISSCODE   || $UOriginLow  eq MISSCODE ) && ($USp1 ne MISSCODE) && ($USp1 ne "XXXX MISS")) 
    { 
		  $keys="understorey NULL Origin but nont null USP1"."#".$UOrigin;
			$herror{$keys}++;									
	  }
	
   	# $StrucVal     =  UNDEF;#"";
   	$SiteClass  =  Site($SiteClass);
    if($SiteClass eq ERRCODE)
    {
			$keys="Site#".$SiteClass;  $herror{$keys}++;
	  }    

	  $USiteClass  =  Site($USiteClass);
    if($USiteClass eq ERRCODE)
    {
			$keys="understorey Site#".$USiteClass;  $herror{$keys}++;
	  } 
 
	  $Wetland = WetlandCodes ($Ecosite, $MNRCode, $NonVeg, $Sp1, $Sp2, $Sp3, $Sp1Per);
    # if($Wetland eq ERRCODE){
		#$keys="Ecosite#".$Ecosite;  $herror{$keys}++;
	  #} 
    # ===== Non-forested Land =====
    #NaturallyNonVeg-Anthropogenic-NonForestedVeg-UnProdForest
  
    $NPcodedesc =  NPCodetoNPDesc($MNRCode );
    $NatNonVeg  =  NaturallyNonVeg($NPcodedesc);
    $NonVegAnth =  Anthropogenic($NPcodedesc);
    $UnProdFor  =  UnProdForest($NPcodedesc);
    $NonForVeg  =  NonForestedVeg($NPcodedesc);
    $NatNonVeg2  =  NaturallyNonVeg($NonVeg);   
    $NonVegAnth2 =  Anthropogenic($NonVeg);   
    $UnProdFor2  =  UnProdForest($NonVeg);
    $NonForVeg2  =  NonForestedVeg($NonVeg);  
   
    if(($NatNonVeg  eq ERRCODE) && ($NonVegAnth  eq ERRCODE) && ($UnProdFor eq ERRCODE) && ($NonForVeg eq ERRCODE) ) 
    {
      # if($NonVeg ne "FOR") {
      $keys="NatNonVeg-all"."#".$NPcodedesc."#mnrcodeis#".$MNRCode;  
      $herror{$keys}++;
      #}
    }
    if(($NatNonVeg2  eq ERRCODE) && ($NonVegAnth2  eq ERRCODE) && ($UnProdFor2 eq ERRCODE) && ($NonForVeg2 eq ERRCODE) ) 
    {
      if($NonVeg ne "FOR") 
      {
        $keys="NatNonVeg2-all"."#".$NonVeg;  
        $herror{$keys}++;
      }
    }  
  

    my ($ProdFor, $lyr_poly) = productive_code ($SpeciesCode, $CCHigh , $CCLow , $HeightHigh , $HeightLow,  0);
    if($lyr_poly)
    {
      $SpeciesComp ="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
      #$keys="###check artificial lyr1 on #".$Sp1;
      #$herror{$keys}++; 
    }

    if ($Cd1  eq "CO")
    {
      $ProdFor="PF";
      $lyr_poly=1;
    }
    # ===== Output inventory info =====
    $CAS_Record = $CAS_ID . "," . $StandID . "," . $StandStructureCode .",". $nblayers .",". $IdentifyID . "," . $MapSheetID . "," . $Area . "," . $Perimeter . "," . $Area. ",".$PHOTO_YEAR;
    print CASCAS $CAS_Record . "\n";
	  $nbpr=1;$$ncas++;$ncasprev++;
    if (!defined $Sp1 ) 
    {
      $Sp1=MISSCODE;
    }  
    if (!defined $Sp2 ) 
    {
      $Sp2=MISSCODE;
    }
    #if($NatNonVeg ne MISSCODE){ print "speciescoe $SpeciesCode and trns $SpeciesComp with species1 $Sp1 and $Sp2"; exit;}
    #layer 1
   
    if ((!is_missing($Sp1) && $Sp1 ne "XXXX MISS") || $lyr_poly) 
    {
      $LYR_Record1 = $CAS_ID . "," . $SMR  . "," .  $StandStructureVal . ",1,1";
      $LYR_Record2 = $CCHigh . "," . $CCLow . "," . $HeightHigh . "," . $HeightLow  . "," . $ProdFor. "," . $SpeciesComp;
      $LYR_Record3 = $OriginHigh . "," . $OriginLow . "," . $SiteClass . "," . $SiteIndex;
      $Lyr_Record = $LYR_Record1 . "," . $LYR_Record2 . "," . $LYR_Record3;
      print CASLYR $Lyr_Record . "\n";
	    $nbpr++; $$nlyr++;$nlyrprev++;
    }
    elsif($NonVeg ne "FOR") 
    {
      if (!is_missing($NatNonVeg) || !is_missing($NonVegAnth) || !is_missing($NonForVeg)) 
      {
  		 	$NFL_Record1 = $CAS_ID . "," . $SMR  . "," .  $StandStructureVal . ",1,1";
        $NFL_Record2 = $CCHigh . "," . $CCLow . "," . $HeightHigh . "," . $HeightLow;
        $NFL_Record3 = $NatNonVeg . "," . $NonVegAnth . "," . $NonForVeg;
        $NFL_Record = $NFL_Record1 . "," . $NFL_Record2 . "," . $NFL_Record3;
        print CASNFL $NFL_Record . "\n";
			  $nbpr++;$$nnfl++;$nnflprev++;    
      }
  		#else {print "NFL null --- codes2 ::: natnonveg---$NatNonVeg2--- NonvegAnth---$NonVegAnth2--- nonforveg---$NonForVeg2---\n";}
      else 
      {
  	 		# $keys= "NFL null mnr_code--$MNRCode-species-$SpeciesCode --uspecies--$USpeciesCode--polytype--$NonVeg\n";
			 # $herror{$keys}++;
		    if (!is_missing($NatNonVeg2) || !is_missing($NonVegAnth2) || !is_missing($NonForVeg2)) 
        {
          $NFL_Record1 = $CAS_ID . "," . $SMR  . "," .  $StandStructureVal .  ",1,1";
          $NFL_Record2 = $CCHigh . "," . $CCLow . "," . $HeightHigh . "," . $HeightLow;
          $NFL_Record3 = $NatNonVeg2 . "," . $NonVegAnth2 . "," . $NonForVeg2;
          $NFL_Record = $NFL_Record1 . "," . $NFL_Record2 . "," . $NFL_Record3;
          print CASNFL $NFL_Record . "\n";
			    $nbpr++;$$nnfl++;$nnflprev++;
     			# print "NFL null and polytype is --$NonVeg-- codes2 ::: natnonveg---$NatNonVeg2--- NonvegAnth---$NonVegAnth2--- nonforveg---$NonForVeg2---\n"
			    #if($onboreal->{$CAS_ID}){
				  #$nflarea+=$Area;
				  #$key1="NatNonVeg_".$NatNonVeg2;
				  #$key3="NonForVeg_".$NonForVeg2;
				  #$key2="NonVegAnth_".$NonVegAnth2;
				  #$onnflfreq->{$key1}++;$onnflfreq->{$key2}++;$onnflfreq->{$key3}++;
			    #}
   		  }
      }
    }

	  if(!isempty($USpeciesCode)) 
    {
  		if (!is_missing($USp1) && $USp1 ne "XXXX MISS") 
      {
        $LYR_Record1 = $CAS_ID . "," . $SMR  . "," .  $StandStructureVal .",2,2";
        $LYR_Record2 = $CCHigh . "," . $CCLow . "," . $UHeightHigh . "," . $UHeightLow. "," . $ProdFor . "," . $USpeciesComp;
        $LYR_Record3 = $UOriginHigh . "," . $UOriginLow . "," . $USiteClass . "," . $SiteIndex;
        $Lyr_Record = $LYR_Record1 . "," . $LYR_Record2 . "," . $LYR_Record3;
        print CASLYR $Lyr_Record . "\n";
  		}
	  }

    #Disturbance
    if (!isempty($Mod1) && $Mod1 ne MISSCODE && $Cd1 ne ERRCODE) 
    {
      $DST_Record = $CAS_ID . "," . $Dist . ",1";
      print CASDST $DST_Record . "\n";
	    if($nbpr==1) {$$ndstonly++; $ndstonlyprev++;}
			$nbpr++;$$ndst++;$ndstprev++;
    }
     
    if(isempty($Ecosite)) 
    {
			$Ecosite="-";
    }
    if ($Wetland ne MISSCODE && $Wetland ne ERRCODE) 
    {
      $Wetland = $CAS_ID . "," . $Wetland.$Ecosite;
      print CASECO $Wetland . "\n";
	    if($nbpr==1) {$$necoonly++;$necoonlyprev++;}
		  $nbpr++;$$neco++;$necoprev++;
    }             
     
	  if($nbpr ==1 )
    {
      $ndrops++;
			if(isempty($Sp1)  && $NPcodedesc eq "" && $Wetland eq MISSCODE && isempty($Mod1)) 
      {
				$keys ="MAY  DROP THIS>>>-\n";
 				$herror{$keys}++; 
			}
			else 
      {
				$keys ="!!! record may be dropped#"."specs=".$Sp1."-nfordesc=".$NPcodedesc."-wetland=".$Wetland."-Cd1=$Cd1"."-mod1=".$Mod1;
 				$herror{$keys}++; 
				$keys ="#droppable#";
 				$herror{$keys}++; 
			}
	  }     
  }       
  $csv->eof or $csv->error_diag ();
  close $ONinv;

  foreach my $k (keys %herror)
  {
    print ERRS "invalid code " ,$k,  " found ", $herror{$k}," times\n";
  }

  foreach my $k (sort {lc($a) cmp lc($b)} keys %$spfreq)
  {
		$_ = $k;
		tr/a-z/A-Z/;
		my $upk = $_;
	 	print SPERRSFILE "cumulative frequency of species " ,$upk,  " is ", $spfreq->{$k},"\n";
		#print "invalid code " ,$k,  " found ", $herror{$k}," times\n";
  }
  #foreach my $k (sort {lc($a) cmp lc($b)} keys %$onnflfreq){
	#$_ = $k;
	#tr/a-z/A-Z/;
	#my $upk = $_;
	#print NFLFREQFILE "cumulative frequency of species " ,$upk,  " is ", $onnflfreq->{$k},"\n";
	#print "invalid code " ,$k,  " found ", $herror{$k}," times\n";
  #}


  $$nflareatotal+=$nflarea;
  $total=$nlyrprev+ $nnflprev+  $ndstprev;
  $total2=$nlyrprev+ $nnflprev+  $ndstonlyprev + $necoonlyprev;
  print SPERRSFILE " ndrops =$ndrops, nb records in casfile : $ncasprev, lyrfile : $nlyrprev, nflfile : $nnflprev,  dstfile : $ndstprev($ndstonlyprev), ecofile : $necoprev($necoonlyprev)--- total (without .cas): $total($total2)\n";


  #close (ONinv);
  close (CASHDR);
  close (CASCAS);
  close (CASLYR);
  close (CASNFL);
  close (CASDST);
  close (CASECO);
  close(ERRS); 
  close (SPERRSFILE);close(SPECSLOGFILE); 
  #close (NFLFREQFILE);
  #$total=$nlyrprev+ $nnflprev+  $ndstprev;
  #$total2=$nlyrprev+ $nnflprev+  $ndstonlyprev + $necoonlyprev;
  #print " ndrops =$ndrops, nb records in casfile : $ncasprev, lyrfile : $nlyrprev, nflfile : $nnflprev,  dstfile : $ndstprev($ndstonlyprev), ecofile : $necoprev($necoonlyprev)--- total (without .cas): $total($total2)\n";

  #return($onnflfreq);
}

1;
