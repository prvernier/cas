package ModulesV4::QC_conversion4th_04;


use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(&QC4inv_to_CAS );
our @EXPORT_OK = qw(@tabSpec);  # %nflfreq
#our @EXPORT_OK = qw();
#our @EXPORT_OK = qw(@tabSpec &SoilMoistureRegime1 &SoilMoistureRegime2  &CCUpper  &CCLower &StandHeightUp &StandHeightLow &UpperOrigin &UpperOriginCompl &LowerOrigin &LowerOriginCompl  &Disturbance &DisturbanceM );

use strict;
use Text::CSV;
our @tabSpec;
our @tabSpecv4;
our $Species_table;	
use constant 
{
	INFTY =>-1,
    ERRCODE => -9999,
	SPECIES_ERRCODE => "XXXX ERRC",
	MISSCODE => -1111,
	UNDEF=> -8888
};

use Cwd;
our $Glob_CASID;
our $Glob_filename;
our %empty_char = ("" => 1,
					"NULL", 1);

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

#Determine SoilMoistureRegime from CL_DRAI (CDR_CO) or TYPE_CO(TE_CO_TEC)
sub SoilMoistureRegime
{
	my %MoistRegList = ("0", 1, "1", 1, "2", 1, "3", 1, "4", 1, "5", 1, "6", 1, "16", 1);
	my %MoistRegListmodif = ("0", 1, "1", 1, "2", 1, "3", 1, "4", 1); 

	my $SoilMoistureReg;
	my $key;
	my $key2;

	my ($MoistReg) = shift(@_);
	if (!defined $MoistReg)  
	{
		$MoistReg = "";
	}
	if(isempty($MoistReg )) 
	{ 
		$SoilMoistureReg = MISSCODE; 
	}
	elsif (($MoistReg eq "16") ) 
	{ 
		$SoilMoistureReg = "D"; 
	}
	else 
	{ 
		$key = substr($MoistReg, 0,1); 
		if (!$MoistRegList {$key} ) 
		{
			$SoilMoistureReg = ERRCODE; 
			return $SoilMoistureReg;
		}

		if(length($MoistReg) >1 ) 
		{
			$key2 = substr($MoistReg, 1,1);
			if (!$MoistRegListmodif {$key2} )
			{
				$SoilMoistureReg = ERRCODE; 
				return $SoilMoistureReg;
			}
		}

		if (($key eq "0"))         
		{ 
			$SoilMoistureReg = "D"; 
		}
		elsif (($key eq "1"))         { $SoilMoistureReg = "D"; }
		elsif (($key eq "2"))         { $SoilMoistureReg = "F"; }
		elsif (($key eq "3"))         { $SoilMoistureReg = "F"; }
		elsif (($key eq "4"))         { $SoilMoistureReg = "M"; }
		elsif (($key eq "5"))         { $SoilMoistureReg = "W"; }
		elsif (($key eq "6"))         { $SoilMoistureReg = "W"; }	
	}
	return $SoilMoistureReg;
}

#Determine StandStructure from CAG_CO, ET1, ET1 and rank from ET_DOMI
#etapge principal-etage secondaire; ET_DOMI=0,1,2
sub StandStructure
{
	
	my ($Age) = shift(@_);
	my $StandStructure;

	if( $Age eq "" || $Age eq "NULL" || $Age =~ /\D/) 
	{
		$StandStructure = "S";
	}
	elsif( length($Age) >3 ) 
	{
		$StandStructure = "M";
	}
	elsif ( length($Age) >1 ) 
	{ 
		$StandStructure = "S"; 
	} 

	else 
	{ 
		$StandStructure = ERRCODE;
	}
	return $StandStructure;
}

#Determine CCUpper from Density  CL_DENS version NAIPF_1st
sub CCUpper 
{
	my $CCHigh;
	my %DensityList = ("a", 1, "b", 1, "c", 1, "d", 1,"i", 1, "h", 1, "A", 1, "B", 1, "C", 1, "D", 1, "I", 1, "H", 1);

	my ($Density) = shift(@_);

	if(isempty($Density)) 
	{ 
		$CCHigh = MISSCODE; 
	}
	elsif (!$DensityList {$Density} ) 
	{ 
		$CCHigh = ERRCODE; 
	}
	elsif (($Density eq "a") || ($Density eq "A"))            { $CCHigh = 99; }
	elsif (($Density eq "b") || ($Density eq "B"))            { $CCHigh = 79; }
	elsif (($Density eq "c") || ($Density eq "C"))            { $CCHigh = 59; }
	elsif (($Density eq "d") || ($Density eq "D"))            { $CCHigh = 39; }
	elsif (($Density eq "i") || ($Density eq "I"))            { $CCHigh = 59; }
	elsif (($Density eq "h") || ($Density eq "H"))            { $CCHigh = 100; }
	return $CCHigh;
}

#Determine CCLower from Density  CL_DENS version NAIPF_1st
sub CCLower 
{
	my $CCLow;
	my %DensityList = ("a", 1, "b", 1, "c", 1, "d", 1, "i", 1, "h", 1, "A", 1, "B", 1, "C", 1, "D", 1, "I", 1, "H", 1);

	my ($Density) = shift(@_);
	if(isempty($Density)) 
	{ 
		$CCLow = MISSCODE; 
	}
	elsif (!$DensityList {$Density} ) 
	{ 
		$CCLow = ERRCODE; 
	}
	elsif (($Density eq "a") || ($Density eq "A"))            { $CCLow = 80; }
	elsif (($Density eq "b") || ($Density eq "B"))            { $CCLow = 60; }
	elsif (($Density eq "c") || ($Density eq "C"))            { $CCLow = 40; }
	elsif (($Density eq "d") || ($Density eq "D"))            { $CCLow = 25; }
	elsif (($Density eq "i") || ($Density eq "I"))            { $CCLow = 0; }
	elsif (($Density eq "h") || ($Density eq "H"))            { $CCLow = 60; }
	return $CCLow;
}

#10% classes, except the first class (5%): 25 (25-29%), 35 (30-39%), 45 (40-49%), 55 (50-59%), 65 (60-69%), 75 (70-79%), 85 (80-89%),95 (90-100%). Assigned to each layer.
#Determine CCUpper from Density  ET1_DENS and ET2_DENS  version NAIPF
sub CCUpper2 
{
	my $CCHigh;
	my %DensityList = ("25", 1, "35", 1, "45", 1, "55", 1,"65", 1, "75", 1, "85", 1, "95", 1);

	my ($Density) = shift(@_);
	if(isempty($Density)) 
	{ 
		$CCHigh = MISSCODE; 
	}
	elsif (!$DensityList {$Density} ) 
	{ 
		$CCHigh = ERRCODE; 
	}
	elsif (($Density == 25))            { $CCHigh = 29; }
	elsif (($Density == 35))            { $CCHigh = 39; }
	elsif (($Density == 45))            { $CCHigh = 49; }
	elsif (($Density == 55))            { $CCHigh = 59; }
	elsif (($Density == 65))            { $CCHigh = 69; }
	elsif (($Density == 75))            { $CCHigh = 79; }
	elsif (($Density == 85))            { $CCHigh = 89; }
	elsif (($Density == 95))            { $CCHigh = 99; }
	return $CCHigh;
}

#Determine CCLower from Density  ET1_DENS and ET2_DENS  version NAIPF
sub CCLower2
{
	my $CCLow;
	my %DensityList = ("25", 1, "35", 1, "45", 1, "55", 1,"65", 1, "75", 1, "85", 1, "95", 1);

	my ($Density) = shift(@_);
	if(isempty($Density)) 
	{ 
		$CCLow = MISSCODE; 
	}
	elsif (!$DensityList {$Density} ) 
	{ 
		$CCLow = ERRCODE; 
	}
	elsif (($Density == 25))            { $CCLow = 25; }
	elsif (($Density == 35))            { $CCLow = 30; }
	elsif (($Density == 45))            { $CCLow = 40; }
	elsif (($Density == 55))            { $CCLow = 50; }
	elsif (($Density == 65))            { $CCLow = 60; }
	elsif (($Density == 75))            { $CCLow = 70; }
	elsif (($Density == 85))            { $CCLow = 80; }
	elsif (($Density == 95))            { $CCLow = 90; }
	return $CCLow;
}



#Determine upper stand origin from CAG_CO  by 10-120, ect

sub UpperOrigin
{
	my $Origin;
	my $OriginUpp;
	my @key=(10, 30, 50, 70, 90, 120);
	($Origin) = shift(@_);
	
	my $key1="10";
	if(isempty($Origin))                   { $OriginUpp = MISSCODE; }
 	elsif (($Origin =~ /^$key[0]/) || ($Origin =~ /$key[0]$/))   { $OriginUpp  = 20; }
	elsif (($Origin =~ /^$key[1]/) || ($Origin =~ /$key[1]$/))   { $OriginUpp  = 40; }
	elsif (($Origin =~ /^$key[2]/) || ($Origin =~ /$key[2]$/))   { $OriginUpp  = 60; }
	elsif (($Origin =~ /^$key[3]/) || ($Origin =~ /$key[3]$/))   { $OriginUpp  = 80; }
	elsif (($Origin =~ /^$key[4]/) || ($Origin =~ /$key[4]$/))   { $OriginUpp  = 100; }
	elsif (($Origin =~ /^$key[5]/) || ($Origin =~ /$key[5]$/))   { $OriginUpp  = INFTY; }
	elsif ($Origin eq  "JIN" || $Origin eq  "JIR") 	{ $OriginUpp  = 79; }
	elsif ($Origin eq  "VIN" || $Origin eq  "VIR")	{ $OriginUpp  = INFTY; }
	else { $OriginUpp  = ERRCODE; }
	return $OriginUpp;
}

sub LowerOrigin 
{
	my $Origin;
	my $OriginLow;
	my @key=(10, 30, 50, 70, 90, 120);
	($Origin) = shift(@_);
	
	my $key1="10";
	if(isempty($Origin))                 		     { $OriginLow = MISSCODE; }
 	elsif (($Origin =~ /^$key[0]/) || ($Origin =~ /$key[0]$/))   { $OriginLow  = 0; }
	elsif (($Origin =~ /^$key[1]/) || ($Origin =~ /$key[1]$/))   { $OriginLow  = 21; }
	elsif (($Origin =~ /^$key[2]/) || ($Origin =~ /$key[2]$/))   { $OriginLow  = 41; }
	elsif (($Origin =~ /^$key[3]/) || ($Origin =~ /$key[3]$/))   { $OriginLow  = 61; }
	elsif (($Origin =~ /^$key[4]/) || ($Origin =~ /$key[4]$/))   { $OriginLow  = 81; }
	elsif (($Origin =~ /^$key[5]/) || ($Origin =~ /$key[5]$/))   { $OriginLow  = 101; }
    elsif ($Origin eq  "JIN" || $Origin eq  "JIR") 	{ $OriginLow  = 1; }
	elsif ($Origin eq  "VIN" || $Origin eq  "VIR")  { $OriginLow  = 80; }
	else { $OriginLow  = ERRCODE; }
	return $OriginLow;	
}

#Determine upper bound stand height from CL_HAUT
sub StandHeightUp 
{
	my $Height;
	my %HeightList = ("1", 1, "2", 1, "3", 1, "4", 1, "5", 1, "6", 1, "7", 1);
	my $HUpp;

	($Height) = shift(@_);
	if(isempty($Height)) 
	{ 
		 $HUpp = MISSCODE; 
	}
	elsif (!$HeightList {$Height} ) 
	{ 
		 $HUpp = ERRCODE; 
	}
	elsif (($Height eq "1"))  		  { $HUpp = INFTY; }
	elsif (($Height eq "2"))                  { $HUpp = 22; }
	elsif (($Height eq "3"))                  { $HUpp = 17; }
	elsif (($Height eq "4"))                  { $HUpp = 12; }
	elsif (($Height eq "5"))                  { $HUpp = 7; }
	elsif (($Height eq "6"))                  { $HUpp = 4; }
	elsif (($Height eq "7"))                  { $HUpp = 2; }
	return $HUpp;
}

#Determine lower bound stand height from Height CL_HAUT
sub StandHeightLow 
{
	my $Height;
	my %HeightList = ("1", 1, "2", 1, "3", 1, "4", 1, "5", 1, "6", 1, "7", 1);
	my $HLow;

	($Height) = shift(@_);
	if(isempty($Height)) 
	{ 
		 $HLow = MISSCODE; 
	}
	elsif (!$HeightList {$Height} ) 
	{ 
		 $HLow = ERRCODE; 
	}
	elsif (($Height eq "1"))  	       { $HLow = 22; }
	elsif (($Height eq "2"))                  { $HLow = 17; }
	elsif (($Height eq "3"))                  { $HLow = 12; }
	elsif (($Height eq "4"))                  { $HLow = 7; }
	elsif (($Height eq "5"))                  { $HLow = 4; }
	elsif (($Height eq "6"))                  { $HLow = 2; }
	elsif (($Height eq "7"))                  { $HLow = 0; }
	return $HLow;	            		       
}


#Determine upper bound stand height from ET1_HAUT, ET2_HAUT
sub StandHeightUp2
{
	my $Height;
	my $HUpp;
	($Height) = shift(@_);
	if  ($Height eq "NULL")                    { $HUpp = MISSCODE; }
	elsif ($Height < 0)  { $HUpp = ERRCODE; }
	else   { $HUpp = 0.4 + $Height; }
	return $HUpp;
}

#Determine lower bound stand height from Height ET1_HAUT, ET2_HAUT
sub StandHeightLow2 
{
	my $Height;
	my $HLow;

	($Height) = shift(@_);
	if  ($Height eq "NULL")            	        { $HLow = MISSCODE; }
	elsif (($Height <0))  	     		{ $HLow = ERRCODE; }
	elsif (($Height == 0))                  { $HLow = 0.1; }
	else { $HLow = $Height-0.5; }
	return $HLow;            		       
}

#Dertermine Latine name of species
sub Latine 
{
	my $CurrentSpecies = shift(@_);
	my $GenusSpecies;

	$_ = $CurrentSpecies;
	tr/a-z/A-Z/;
	$CurrentSpecies = $_;

	if (isempty($CurrentSpecies))   { $GenusSpecies = MISSCODE; }

	elsif ($Species_table->{$CurrentSpecies}) { $GenusSpecies = $Species_table->{$CurrentSpecies}; }
	#elsif (grep{$CurrentSpecies  eq  $_} ( qw/M/)) { $GenusSpecies = UNDEF;}
	#elsif (grep{$CurrentSpecies  eq  $_} ( qw/P/)) { $GenusSpecies = UNDEF;}
	#elsif (grep{$CurrentSpecies  eq  $_} ( qw/MX/)) { $GenusSpecies = UNDEF;}
	else {$GenusSpecies = SPECIES_ERRCODE;  print SPECSLOGFILE "Illegal species code $CurrentSpecies,CAS_ID=$Glob_CASID,file=$Glob_filename\n";  }  
	return $GenusSpecies;
}
 

sub tabminus
{
	my $tab1= shift(@_);
	my $tab2= shift(@_);
	my @PC=(); 

	foreach my $elt1  (@$tab1){
		if (grep{$elt1 eq $_} @$tab2) {}
	 	 else {unshift (@PC, $elt1); }
	}
	return (@PC);
}

sub  cartesien_sign_after 
{
	my $tab1= shift(@_);
	my $tab2= shift(@_);
	my @PC=(); 

	foreach my $elt1  (@$tab1){
		foreach my $elt2  (@$tab2){
	 		 unshift (@PC, $elt1.$elt2."+"."#".$elt1."#".$elt2);
			 unshift (@PC, $elt1.$elt2."-"."#".$elt1."#".$elt2);
		}
	}
	return reverse(@PC);
}

sub  cartesien_sign_between 
{
	my $tab1= shift(@_);
	my $tab2= shift(@_);
	my @PC=(); 

	foreach my $elt1  (@$tab1){
		foreach my $elt2  (@$tab2){
	 		 unshift (@PC, $elt1."+".$elt2."#".$elt1."#".$elt2);
			 unshift (@PC, $elt1."-".$elt2."#".$elt1."#".$elt2);
		}
	}
	return reverse(@PC);
}


sub cartesien_split
{
	my $tab1= shift(@_);
	my $tab2= shift(@_);
	my @PC=(); 

	foreach my $elt1  (@$tab1){
		my ($p1, $p2, $p3)=split("#", $elt1);
		foreach my $elt2  (@$tab2){
	 		 unshift (@PC, $p1.$elt2."#".$p2."#".$p3."#".$elt2);
		}
	}
	return reverse(@PC);
}


sub cartesien
{
	my $tab1= shift(@_);
	my $tab2= shift(@_);
	my @PC=(); 

	foreach my $elt1  (@$tab1){
		foreach my $elt2  (@$tab2){
	 		 unshift (@PC, $elt1.$elt2."#".$elt1."#".$elt2);
		}
	}
	return reverse(@PC);
}

sub decomp_FR
{
	my $N ="F";
	my $A=$N."X";
	my @resf=($N."##", $N.$N."#$N#$N", $N.$N.$N."#$N#$N#$N", $N.$A."#$N#$A", $A.$N."#$A#$N", $N.$N.$A."#$N#$N#$A", $A.$N.$N."#$A#$N#$N");
	 $N ="R";
	 my $B=$N."X";
	my @resr=($N."##", $N.$N."#$N#$N", $N.$N.$N."#$N#$N#$N", $N.$B."#$N#$B", $B.$N."#$B#$N", $N.$N.$B."#$N#$N#$B", $B.$N.$N."#$B#$N#$N");
	my @res2=("FR#F#R","RF#R#F", "FRX#F#RX","RFX#R#FX", "FFR#F#F#R","RRF#R#R#F", "FRF#F#R#F","RFR#R#F#R", "FRR#F#R#R","RFF#R#F#F",
	$A."RF#".$A."#R#F",$B."FR#".$B."#F#R", "RF".$A."#R#F#".$A, "FR".$B."#F#R#".$B);
	my @result=join(@resf,@resr,@res2);
}

#Determine Species from GR_ESS
sub QCSpecies
{

	my @FR=qw /F  FF  R  RR/;
	my @FRX1=qw /F  R  RX/;
	my @FRX2=qw /F  R  FX/;
	my @Rlist=qw /S  E PG PB PR C PU ME/;
	my @Flist0=qw(FNC BJ FT FH EO ER);
	my @FIlist=qw(BB PE FI);


	# compute list of softwood species
	# @Rlist X  @Rlist
	# R X  @Rlist
	my @PCsoftwood= cartesien (\@Rlist, \@Rlist);
	my @tabR=('R');
	my @PCR= cartesien (\@tabR, \@Rlist);
	foreach my $elt2  (@PCR){
		 		 push (@PCsoftwood, $elt2);
			}

	# compute list of hardwood species

	# DELTA= @FIlist  X  @FIlist - $FI + BB1 + PE1
	my @LHardwood= cartesien (\@FIlist, \@FIlist);
	push (@LHardwood, 'BB1#BB#');
	push (@LHardwood, 'PE1#PE#');
	my @delFI = grep{'#FI$' eq $_} @LHardwood;
	@LHardwood= tabminus (\@LHardwood, \@delFI);
	my @Delta= @LHardwood;

	# @Flist0
	# @FIlist
	foreach my $elt2  (@Flist0){
		 		 push (@LHardwood, $elt2);
			}
	foreach my $elt2  (@FIlist){
		 		 push (@LHardwood, $elt2);
			}

	# ER X @FIlist + ER X @Flist0[1-2]

	my @tER=('ER');
	my @ListpER= cartesien (\@tER, \@FIlist);
	foreach my $elt2  (@ListpER){
		 		 push (@LHardwood, $elt2);
			}

	my @slicetab=@Flist0[1..2];
	@ListpER= cartesien (\@tER, \@slicetab);
	foreach my $elt2  (@ListpER){
		 		 push (@LHardwood, $elt2);
			}


	# compute list of mixedwood species with  intolerant hardwodd  (dominant Softwood)

	#  @Rlist[0-2] x @FIlist + R X @FIlist           commutatif

	@slicetab = @Rlist[0..2];
	my @Mixedwood= cartesien (\@slicetab, \@FIlist);
	my @PCR2= cartesien (\@tabR, \@FIlist);
	foreach my $elt2  (@PCR2){
		 		 push (@Mixedwood, $elt2);
			}

	#  @Rlist[3-4] +- @FIlist                       commutatif sans signe
	@slicetab = @Rlist[3..4];
	my @complexMix= cartesien_sign_between (\@slicetab, \@FIlist);
	foreach my $elt2  (@complexMix){
		 		 push (@Mixedwood, $elt2);
			}


	# compute list of mixedwood species with BJ

	#  @Rlist[3-4] +- (BJ) 
	my @BJtab= ('BJ');
	my @MixedwoodBJ= cartesien_sign_between (\@slicetab, \@BJtab);
	#  @Rlist[5-6] X BJ  +-  R X BJ  +-
	@slicetab = @Rlist[5..6];
	my @MixedwoodBJplus= cartesien_sign_after(\@slicetab, \@BJtab);

	foreach my $elt2  (@MixedwoodBJplus){
		 		 push (@MixedwoodBJ, $elt2);
			}
	push (@MixedwoodBJ, 'RBJ+#R#BJ');
	push (@MixedwoodBJ, 'RBJ-#R#BJ');



	# compute list of mixedwood species with FT  and FH
	#  @Rlist[3-4] +- (FT)
	@slicetab = @Rlist[3..4];
	my @FTtab= ('FT');
	my @MixedwoodFTFH= cartesien_sign_between (\@slicetab, \@FTtab);
	#  R X @Flist0 [2-5]				commutatif
	@slicetab = @Flist0 [2..5];
	my @PCR3= cartesien (\@tabR, \@slicetab);
	foreach my $elt2  (@PCR3){
		 		 push (@MixedwoodFTFH, $elt2);
			}



	# compute list of mixedwood species with  intolerant hardwodd  (dominant Hardwood)

	#  @FIlist X (@Rlist[0-2]+ R) -------------------------------------------

	@slicetab = @Rlist[0..2];
	push (@slicetab, 'R');
	my @MixedwoodHARD= cartesien (\@FIlist, \@slicetab);

	# DELTA X (@Rlist[0-4]+ R)  - BBPER - PEBBR
	@slicetab = @Rlist[0..4];
	push (@slicetab, 'R');

	my @MixedwoodH2= cartesien_split (\@Delta, \@slicetab);
	#my @delENDR=('BBPER#BB#PE#R', 'PEBBR#PE#BB#R');

	#@MixedwoodH2= tabminus (\@MixedwoodH2, \@delENDR);

	#  @FIlist X @Rlist[3-4] ---------------------------------------------

	@slicetab = @Rlist[3..4];
	my @MixedwoodH3= cartesien (\@FIlist, \@slicetab);

	foreach my $elt2  (@MixedwoodH2){
		 		 push (@MixedwoodHARD, $elt2);
			}
	foreach my $elt2  (@MixedwoodH3){
		 		 push (@MixedwoodHARD, $elt2);
			}

	# compute list of mixedwood species with  BJ  (dominant Hardwood)

	#  BJ  +- (@Rlist[3-6]+ R)
	@slicetab = @Rlist[3..6];
	push (@slicetab, 'R');
	my @MixedwoodHARDBJ= cartesien_sign_between (\@BJtab, \@slicetab);


	# compute list of mixedwood species with  FT and FH  (dominant Hardwood)

	# FT X @Rlist[3-4]
	@slicetab = @Rlist[3..4];
	my @MixedwoodHARDFTFH= cartesien(\@FTtab, \@slicetab);

	# @Flist0 [2-5] X  R  ----------------------------------------
	@slicetab = @Flist0 [2..5];
	my @RFtPC= cartesien(\@slicetab, \@tabR);
	foreach my $elt2  (@RFtPC){
		 		 push (@MixedwoodHARDFTFH, $elt2);
			}


	#my @Rlist=qw /S  E PG PB PR C PU ME/;
	#my @Flist0=qw(FNC BJ FT FH EO ER);
	#my @FIlist=qw(BB PE FI);

	# add island spruce codes

	@slicetab = qw /S  E PB PR ME/;
	my @pGtab= ('G');
	my @islandSP= cartesien(\@pGtab, \@slicetab);
	my @islandSPcommut= cartesien(\@slicetab, \@pGtab);
	foreach my $elt2  (@islandSPcommut){
		 		 push (@islandSP, $elt2);
			}
	push (@islandSP, 'GG#G#G');   #push (@islandSP, 'GG#GG#GG');
	push (@islandSP, 'RG#R#G');   #push (@islandSP, 'RG#RG#RG');

	my @islandSPsuiv=cartesien_split (\@Delta, \@pGtab);
	my @islandSP2= cartesien(\@pGtab, \@FIlist);


	# add plantation codes
	#ENS, P, PRR, REA, RIA
	my @PLRtab = qw /EPH  PIS PIG  EPL EPN PIR  MEL EPO MEJ  MEU PIB  PID PRU  R  RES  SAB THO/;
	my @plantationR= cartesien(\@PLRtab, \@PLRtab);

	my @FLtab = qw /BOJ  CHB  CHR  ERS  F  FEL  FRA  FRN  FRP   PED  PEH  PEU/;
	foreach my $elt2  (@FLtab){
		 		 push (@plantationR, $elt2);
			}

	foreach my $elt2  (@PLRtab){
		 		 push (@plantationR, $elt2);
			}


	my @F2tab=('F');
	my @MXplantation= cartesien(\@F2tab, \@PLRtab);
	my @MXplantationcommut= cartesien(\@PLRtab, \@F2tab);

	##########################################################  MORE
	my @pStab= ('S');
	my @sliceMS1 = @PLRtab[0..2];
	my @sliceMS2 = @PLRtab[3..6];
	my @addmore1= cartesien(\@sliceMS1, \@pStab);
	my @addmore2= cartesien(\@sliceMS2, \@pStab);
	my @addmore3= cartesien(\@pStab, \@sliceMS2);
	push (@addmore3, 'RESME#RES#ME#');
	###########################################################  OTHER CODES

	my @Mtab1= cartesien(\@PLRtab, \@FLtab);
	my @Mtab2= cartesien(\@FLtab, \@PLRtab);
	foreach my $elt2  (@Mtab2){
		 		 push (@Mtab1, $elt2);
			}

	my @Fltab2= cartesien(\@FLtab, \@FLtab);
	my @auxiltab=qw /PE  EO FI  BB FT  ER  PG  E PR  FNC  BJ  PB M  C FH/;  #PG, E
	my @auxilLIST1= cartesien(\@auxiltab, \@PLRtab);
	my @auxilLIST2= cartesien(\@PLRtab, \@auxiltab);
	my @auxilLIST3= cartesien(\@auxiltab, \@FLtab);
	my @auxilLIST4= cartesien(\@FLtab, \@auxiltab);

	foreach my $elt2  (@auxiltab){
		 		 push (@auxilLIST1, $elt2);
			}
	foreach my $elt2  (@auxilLIST2){
		 		 push (@auxilLIST1, $elt2);
			}
	foreach my $elt2  (@auxilLIST3){
		 		 push (@auxilLIST1, $elt2);
			}
	foreach my $elt2  (@auxilLIST4){
		 		 push (@auxilLIST1, $elt2);
			}
	push (@auxilLIST1, 'EEC#E#E#C');
	push (@auxilLIST1, 'BJS#BJ#S#');
	push (@auxilLIST1, 'SBJ#S#BJ#');
	push (@auxilLIST1, 'SC#S#C#');
	push (@auxilLIST1, 'CS#C#S#');
	push (@auxilLIST1, 'SSAB#S#SAB#');

	return (@PCsoftwood, @LHardwood, @Mixedwood, @MixedwoodBJ, @MixedwoodFTFH, @MixedwoodHARD, @MixedwoodHARDBJ, @MixedwoodHARDFTFH, @islandSP, @islandSPsuiv, @islandSP2, @plantationR, @MXplantation, @MXplantationcommut, @Mtab1, @Fltab2, @auxilLIST1, @addmore1, @addmore2, @addmore3);	

}

sub Species_complement
{
	my $GR_ESS=shift(@_);
	my @Nlist=qw /EPH EPO EPN EPL RES/;
	my @auxlist=qw /RR RRP RRG/;
	my $beg;
	my$end;
	my $Sp1="";my $Sp2="";my $Sp3="";
	my $signplus="\\+";

	my $SpecComp;
	
	$beg=(substr $GR_ESS, 0, 3);
	$end=(substr $GR_ESS, -3);
 	if ((grep { $beg eq $_}  @Nlist) && (length($GR_ESS) == 5) ) 
 	{
		$Sp1=$beg; 
		$Sp2=(substr $GR_ESS, -2);  
		#if((substr $GR_ESS, -5) ne $GR_ESS) {print "GR_ESS $GR_ESS has more than 5 chars \n"; exit(0);}
		$SpecComp=$GR_ESS."#".$Sp1."#".$Sp2; 
	}
	elsif ((grep { $end eq $_}  @Nlist) && (length($GR_ESS) == 5) ) 
	{	
		$Sp2=$end; 
		$Sp1=(substr $GR_ESS, 0, 2);  
		#if((substr $GR_ESS, -5) ne $GR_ESS) {print "GR_ESS $GR_ESS has more than 5 chars \n"; exit(0);}
		$SpecComp=$GR_ESS."#".$Sp1."#".$Sp2;
	}
	elsif (grep { $GR_ESS eq $_}  @auxlist) 
	{	
		$Sp2=(substr $GR_ESS, -1); 
		$Sp1="R"; $SpecComp=$GR_ESS."#".$Sp1."#".$Sp2;
	}
	else
	{ 
		if(length($GR_ESS) == 1 || length($GR_ESS) == 3) 
		{
			$Sp1=$GR_ESS;  $SpecComp=$GR_ESS."#".$Sp1; #$SpecComp=ERRCODE; print "GR_ESS $GR_ESS undef config\n"; exit(0);
		}
		elsif(length($GR_ESS) == 5) 
		{ 
			if($GR_ESS =~ m/\+$/ ) 
			{ 
				$Sp2=substr $GR_ESS, -3; $Sp1=substr $GR_ESS, 0, 2;
				if(Latine($Sp1) eq SPECIES_ERRCODE ) 
				{
					print SPECSLOGFILE " error on sign + with $GR_ESS\n";
				}
			}
			else 
			{ 
				$Sp2=substr $GR_ESS, -2; $Sp1=substr $GR_ESS, 0, 3;
				if(Latine($Sp2) eq SPECIES_ERRCODE ) 
				{
					$Sp1=substr $GR_ESS, 0, 2; $Sp2=substr $GR_ESS, 2, 3; 
					print SPECSLOGFILE " error corrected on $Sp2***$GR_ESS\n"; 
				}
			}
								 
			$SpecComp=$GR_ESS."#".$Sp1."#".$Sp2;					
		}
		else 
		{
			$GR_ESS =~ s/\s//;
			$Sp1=substr $GR_ESS, 0, 2;  $SpecComp=$GR_ESS."#".$Sp1;
			if(length($GR_ESS) > 3){$Sp2=substr $GR_ESS, 2, 2; $SpecComp=$GR_ESS."#".$Sp1."#".$Sp2;}  
			if(length($GR_ESS) > 5){$Sp3=substr $GR_ESS, 4, 2; $SpecComp=$GR_ESS."#".$Sp1."#".$Sp2."#".$Sp3;}
			elsif ( $GR_ESS ne "PRES" && ( grep { $beg eq $_}  @Nlist ||  grep { $end eq $_}  @Nlist ) )
			{
				$SpecComp=SPECIES_ERRCODE; print "GR_ESS *$GR_ESS* undef config 2\n";
			}
		}
	}	 
	return $SpecComp;
}


sub Species_test
{

	my $SPecies= shift(@_);
	my $plantation_list= shift(@_);
	my $spfreq=shift(@_);


	my $Sp1=MISSCODE;
	my $Sp2=MISSCODE;
	my $Sp3=MISSCODE;
	my $Sp1PER=0;
	my $Sp2PER=0;
	my $Sp3PER=0;

	my $speccode; my $p1; my $p2; my $p3;
	my $n=length($SPecies);
	my $nbc=0;

	if($n==2)
	{
		$Sp1=substr($SPecies, 0,2);
		$Sp2="";$Sp1PER=100;$Sp2PER=0;$Sp3PER=0;
		$Sp3="";
		$SPecies = Latine($Sp1) . "," . $Sp1PER . ",XXXX UNDF,0,XXXX UNDF,0" ;
	}
	elsif ($n==4)
	{
		$Sp1=substr($SPecies, 0,2);
		$Sp2=substr($SPecies, 2,2);
		$Sp3="";
		if($Sp1 eq $Sp2)
		{
			$Sp1PER=100;$Sp2PER=0;$Sp3PER=0;
			$SPecies = Latine($Sp1) . "," . $Sp1PER . ",XXXX UNDF,0,XXXX UNDF,0" ;
		}
		else 
		{
			$Sp1PER=80;$Sp2PER=20;$Sp3PER=0;	
			$SPecies = $SPecies = Latine($Sp1) . "," . $Sp1PER .",". Latine($Sp2) . "," . $Sp2PER . ",XXXX UNDF,0" ;
		}
	}
	elsif ($n==6)
	{
		$Sp1=substr($SPecies, 0,2);
		$Sp2=substr($SPecies, 2,2);
		$Sp3=substr($SPecies, 4,2);
		if($Sp1 eq $Sp2)
		{
			$Sp1PER=80;$Sp2PER=20;$Sp3PER=0;$Sp2=$Sp3;
			$SPecies = $SPecies = Latine($Sp1) . "," . $Sp1PER .",". Latine($Sp2) . "," . $Sp2PER . ",XXXX UNDF,0" ;
		}
		else 
		{
			$Sp1PER=60;$Sp2PER=20;$Sp3PER=20;	
			$SPecies = $SPecies = Latine($Sp1) . "," . $Sp1PER .",". Latine($Sp2) . "," . $Sp2PER . Latine($Sp3) . "," . $Sp3PER ;
		}
	}
	elsif($n==3)
	{
		$Sp1=substr($SPecies, 0,3);
		$Sp2="";$Sp1PER=100;$Sp2PER=0;$Sp3PER=0;
		$Sp3="";
		$SPecies = Latine($Sp1) . "," . $Sp1PER . ",XXXX UNDF,0,XXXX UNDF,0" ;
	}
	elsif($n==5)
	{
		$Sp1=substr($SPecies, 0,2);
		$Sp2=substr($SPecies, 2,2);$Sp1PER=100;$Sp2PER=0;$Sp3PER=0;
		$Sp3=substr($SPecies, 4,1);
		if($Sp1 eq $Sp2)
		{
			$Sp1PER=80;$Sp2PER=20;$Sp3PER=0;$Sp2=$Sp3;
			$SPecies = $SPecies = Latine($Sp1) . "," . $Sp1PER .",". Latine($Sp2) . "," . $Sp2PER . ",XXXX UNDF,0" ;
		}
		else 
		{
			$Sp1PER=60;$Sp2PER=20;$Sp3PER=20;	
			$SPecies = $SPecies = Latine($Sp1) . "," . $Sp1PER .",". Latine($Sp2) . "," . $Sp2PER . Latine($Sp3) . "," . $Sp3PER ;
		}
	}
	else
	{ 
		print SPECSLOGFILE " not translated $SPecies***\n"; print("species with length !=2,3,4,6  <<$SPecies>>\n"); 
	} 
}


sub Species
{
	my @Rlist=qw (S E PG PB PR C PU ME );


	my $SPecies= shift(@_);
	my $Speclist= shift(@_);
	my $spfreq=shift(@_);

	my $Sp1="XXXX UNDF";
	my $Sp2="XXXX UNDF";
	my $Sp3="XXXX UNDF";
	my $Sp1PER=0;
	my $Sp2PER=0;
	my $Sp3PER=0;

	my $speccode; my $p1; my $p2; my $p3;

	my $nbc=0;
	foreach my $elt (@$Speclist)
	{

		my (@SPcode) = split("#",$elt);
		#my ($speccode,$p1,$p2,$p3) = split("#",$elt);
		$speccode=$SPcode[0];  
		my $nbep=scalar(@SPcode);
		if($nbep>1) {$p1=$SPcode[1];} else {$p1="";}
		if($nbep>2) {$p2=$SPcode[2];} else {$p2="";}
		if($nbep>3) {$p3=$SPcode[3];} else {$p3="";}
		
		#$spfreq->{$p1}++;
		#if ($p2 ne "") { $spfreq->{$p2}++; }
		#if ($p3 ne "") { $spfreq->{$p3}++; }

		if ($SPecies eq $speccode) { $spfreq->{$elt}++; if($SPecies eq "RRG") {print "found  --$speccode--  with  --$SPecies--";}
			if ($p3 eq ""){  
				if ($p1 ne "") {
					$Sp1= Latine($p1); $Sp3="XXXX UNDF";$Sp3PER=0;  
					#print  "p1  is  --$p1--translation is --$Sp1--";
					my $sp1minus=$p1."-"; 
					my $sp1plus=$p1."\\+"; 
					my $sp1one=$p1."1"; 

					if ($speccode =~ m/^$sp1minus/) {
						$Sp2= Latine("R");  $Sp3= Latine($p2); 
						$Sp1PER=35; $Sp2PER=35;  $Sp3PER= 30;  
					}
					elsif (($speccode =~ m/^$sp1plus/) ||($speccode =~ m/^$sp1one/)){
						$Sp2= Latine($p2); 
						$Sp1PER=70; $Sp2PER=30; 
					}
					else {
						if ($p2 ne "") {
									$Sp2= Latine($p2);
									my $sp2minus=$p2."-"; 
									my $sp2plus=$p2."\\+"; 
									if ($speccode =~ m/$sp2minus$/) {
										$Sp1PER=70; $Sp2PER=30;   
									}
									elsif ($speccode =~ m/$sp2plus$/) {
										$Sp1PER=60; $Sp2PER=40;   
									}
									elsif($p2 eq $p1){$Sp1PER=100; $Sp2PER=0; $Sp2="XXXX UNDF";}
								   	else {
											if ($p1 ne "M")  {$Sp1PER=65; $Sp2PER=35; }
											else  {$Sp1PER=35; $Sp2PER=65; }
									}

						}
						else {$Sp2="XXXX UNDF"; $Sp1PER=100; $Sp2PER=0;  }
					}
					if ($p1 eq "R") {
						if(grep{$p2 eq $_} @Rlist) {
							$Sp1= Latine($p2); 
							$Sp2= Latine("R"); 
							$Sp3= Latine("R");   
							$Sp1PER=51; $Sp2PER=25;  $Sp3PER= 24; 
						}
					}
				}
				else {$Sp1= Latine($speccode);$Sp2= "XXXX UNDF";$Sp3="XXXX UNDF";$Sp1PER=100; $Sp2PER=0; $Sp3PER=0;} 
			}
			else
			{
				if (($p1 eq $p2) || ($p2 eq "")) {
						$Sp1= Latine($p1);
						$Sp2= Latine($p3); $Sp3="XXXX UNDF";
						$Sp1PER=65; $Sp2PER=35;$Sp3PER=0;
				}
				else {
						$Sp1= Latine($p1);
						$Sp2= Latine($p2);
						$Sp3= Latine($p3);
						$Sp1PER=51; $Sp2PER=25;  $Sp3PER= 24; 
				}
			}		
		last; 
		}
	}
	$SPecies = $Sp1 . "," . $Sp1PER . "," . $Sp2. "," . $Sp2PER. "," . $Sp3. "," . $Sp3PER;
	return $SPecies;
}									

# differents fiels in QC
#Determine Naturally non-vegetated stands from CO_TER
sub NaturallyNonVeg 
{
	my $Landcategory;
	my %LandcategoryList = ("EAU", 1, "INO", 1, "ILE", 1, "DH", 1, "DS", 1,         
"eau", 1, "ino", 1, "ile", 1,  "dh", 1, "ds", 1);                                                           
                                                                                                     
	($Landcategory) = shift(@_);
	if(isempty($Landcategory)) { $Landcategory = MISSCODE;}
	elsif (!$LandcategoryList {$Landcategory} ) { $Landcategory = ERRCODE; }
	elsif (($Landcategory eq "EAU") || ($Landcategory eq "eau"))	{ $Landcategory = "LA"; } 
	elsif (($Landcategory eq "INO") || ($Landcategory eq "ino"))	{ $Landcategory = "FL"; }
	elsif (($Landcategory eq "ILE") || ($Landcategory eq "ile"))	{ $Landcategory = "IS"; }
	elsif (($Landcategory eq "DH")   || ($Landcategory eq "DS")  )	{ $Landcategory = "EX"; }
	else { $Landcategory = ERRCODE; }
	return $Landcategory;
}
		

#Determine Non-forested anthropologocal stands
sub NonVegetatedAnth 
{
	my $Landcategory;
	my %LandcategoryList = ( "ANT", 1, "A", 1, "GR", 1, "RO", 1, "LTE", 1, "AF", 1, "NF", 1, "NX", 1, 
		"AEP", 1, "AER", 1, "BHE", 1, "BAS", 1, "BLE", 1, "CFO", 1, "CAM", 1, "CAR", 1, "CEX", 1, "CHE", 1, "CU", 1, "OBS", 1, "CV", 1, "CF", 1, "DEM", 1, "DEP", 1, "GOL", 1, "GR", 1,
		"HAB", 1, "VRG", 1, "CNE", 1, "LTE", 1, "MI", 1, "INC", 1, "PPN", 1, "CS", 1, "RO", 1, "SC", 1, "DEF", 1, "A", 1, "US", 1, "VIL", 1,  "CNE", 1, "CIM", 1, "AL", 1,);

	($Landcategory) = shift(@_);
	if(isempty($Landcategory)) { $Landcategory = MISSCODE;}
	elsif (!$LandcategoryList {$Landcategory} ) { $Landcategory = ERRCODE; }
	elsif (($Landcategory eq "ANT") || ($Landcategory eq "NF")|| ($Landcategory eq "NX"))	{ $Landcategory = "OT"; }
	elsif (($Landcategory eq "A") || ($Landcategory eq "AF"))	{ $Landcategory = "CL"; }
	elsif (($Landcategory eq "GR"))	{ $Landcategory = "IN"; }
	elsif (($Landcategory eq "RO") || ($Landcategory eq "LTE"))	{ $Landcategory = "FA"; }
	elsif (($Landcategory eq "AEP"))	{ $Landcategory = "OT"; }
	elsif (($Landcategory eq "CIM"))	{ $Landcategory = "OT"; }
	elsif (($Landcategory eq "AER"))	{ $Landcategory = "FA"; }
	elsif (($Landcategory eq "BHE"))	{ $Landcategory = "IN"; }
	elsif (($Landcategory eq "BAS"))	{ $Landcategory = "LG"; }
	elsif (($Landcategory eq "BLE"))	{ $Landcategory = "CL"; }
	elsif (($Landcategory eq "CFO"))	{ $Landcategory = "FA"; }
	elsif (($Landcategory eq "CAM"))	{ $Landcategory = "FA"; }
	elsif (($Landcategory eq "CAR"))	{ $Landcategory = "IN"; }
	elsif (($Landcategory eq "CEX"))	{ $Landcategory = "FA"; }
	elsif (($Landcategory eq "CHE"))	{ $Landcategory = "IN"; }
	elsif (($Landcategory eq "CU"))	{ $Landcategory = "SE"; }
	elsif (($Landcategory eq "OBS"))	{ $Landcategory = "FA"; }
	elsif (($Landcategory eq "CV"))	{ $Landcategory = "FA"; }
	elsif (($Landcategory eq "CF"))	{ $Landcategory = "OT"; }
	elsif (($Landcategory eq "DEM"))	{ $Landcategory = "IN"; }
	elsif (($Landcategory eq "DEP"))	{ $Landcategory = "IN"; }
	elsif (($Landcategory eq "GOL"))	{ $Landcategory = "FA"; }
	elsif (($Landcategory eq "GR"))	{ $Landcategory = "IN"; }
	elsif (($Landcategory eq "HAB"))	{$Landcategory = "SE"; }
	elsif (($Landcategory eq "VRG"))	{ $Landcategory = "CL"; }
	elsif (($Landcategory eq "LTE"))	{ $Landcategory = "FA"; }
	elsif (($Landcategory eq "MI" ))	{ $Landcategory = "IN"; }
	elsif (($Landcategory eq "INC"))	{ $Landcategory = "OT"; }
	elsif (($Landcategory eq "PPN"))	{ $Landcategory = "OT"; }
	elsif (($Landcategory eq "CS"))	{ $Landcategory = "SE"; }
	elsif (($Landcategory eq "RO"))	{ $Landcategory = "FA"; }
	elsif (($Landcategory eq "SC"))	{ $Landcategory = "IN"; }
	elsif (($Landcategory eq "DEF"))	{ $Landcategory = "OT"; }
	elsif (($Landcategory eq "A"))	{ $Landcategory = "CL"; }
	elsif (($Landcategory eq "US"))	{ $Landcategory = "IN"; }
	elsif (($Landcategory eq "VIL"))	{ $Landcategory = "FA"; }
	elsif (($Landcategory eq "CNE"))	{ $Landcategory = "FA"; }
	else { $Landcategory = ERRCODE; }
	return $Landcategory;
}

# to suppress
#Determine Non-forested vegetation stands
sub NonForestedVeg 
{
	my $Landcategory = shift(@_);
	my %LandcategoryList = ("AL", 1);

	if(isempty($Landcategory)) { $Landcategory = MISSCODE;}
	elsif (!$LandcategoryList {$Landcategory} ) { $Landcategory = ERRCODE; }
	elsif (($Landcategory eq "AL") )	{ $Landcategory = "ST"; }
	#elsif (($Landcategory eq "DH")   || ($Landcategory eq "DS")  )	{ $Landcategory = "EX"; }

	return $Landcategory;
}


#cpr, crs, cbt, cpe, ct, crb, etr=CO

#PER_CO_ORI	cpr, cph, crs, cbt, cba, cef, cpe, cpt, ct, crb, etr, prr, crr = CO				cht=WF	dt=OT	es=IK	br=BU	ver=WE	fr=OT		ens, enm, p, pln, plr, plb, rea, ria, rps, drm, drc, dr, enr, fer, rrb, rrn, rrr= SI			

#Determine Disturbance from PER_CO_ORI and PER_AN_ORI 

		
					

sub Disturbance 
{
	my $PER_CO;
	my $PER_AN;
	my $Disturbance;
	my $Mod;
	my %ModList = ("", 1, "NULL", 1, "CPR", 1, "CPH", 1, "CRS", 1, "CBT", 1, "CBA", 1, , "CDV", 1, "CEF", 1, "CPE", 1,  "CPT", 1, "CT", 1, "CRB", 1, "ETR", 1, 		
	"CHT", 1, "DT", 1, "ES", 1, "BR", 1, "FR", 1, "VER", 1, "ENS", 1, "ENM", 1, "P", 1, "PLN", 1, "PLR", 1, "PLB", 1, "REA", 1, "RIA", 1, "RPS", 1,   "DRM", 1, "DRC", 1, 
	"DR", 1, "ENR", 1, "FER", 1, "RRB", 1, "RRN", 1, "RRR", 1, "PRR", 1, "CRR", 1);
	   
	($PER_CO) = shift(@_); 
	($PER_AN) = shift(@_);

	$_ = $PER_CO; tr/a-z/A-Z/; $PER_CO = $_;
	
	if ($PER_AN eq "" || $PER_AN eq "NULL"  ) {$PER_AN=MISSCODE; }

	if ($ModList{$PER_CO} ) { 

	if ($PER_CO ne "" && $PER_CO ne "NULL" ) 
	{ 
 				if (($PER_CO  eq "CPR") || ($PER_CO eq "cpr")) { $Mod="CO"; }
				elsif (($PER_CO  eq "CPH")) { $Mod="CO"; }
				elsif (($PER_CO  eq "CRS")) { $Mod="CO"; }
				elsif (($PER_CO  eq "CBT")) { $Mod="CO"; }
				elsif (($PER_CO  eq "CBA")) { $Mod="CO"; }
				elsif (($PER_CO  eq "CEF")) { $Mod="CO"; }
				elsif (($PER_CO  eq "CPE")) { $Mod="CO"; }
				elsif (($PER_CO  eq "CPT")) { $Mod="CO"; }
				elsif (($PER_CO  eq "CT"))  { $Mod="CO"; }
				elsif (($PER_CO  eq "CRB")) { $Mod="CO"; }
				elsif (($PER_CO  eq "ETR")) { $Mod="CO"; }
				elsif (($PER_CO  eq "CDV")) { $Mod="CO"; }
				
				elsif (($PER_CO  eq "CHT")) { $Mod="WF"; }
				elsif (($PER_CO  eq "DT"))   { $Mod="OT"; }
				elsif (($PER_CO  eq "ES"))   { $Mod="IK"; }
				elsif (($PER_CO  eq "BR"))   { $Mod="BU"; }
				elsif (($PER_CO  eq "FR"))   { $Mod="OT"; }
				elsif (($PER_CO  eq "VER")) { $Mod="WE"; }

				elsif (($PER_CO  eq "ENS")) { $Mod="SI"; }
				elsif (($PER_CO  eq "ENM")) { $Mod="SI"; }
				elsif (($PER_CO  eq "P"))   { $Mod="SI"; }
				elsif (($PER_CO  eq "PLN")) { $Mod="SI"; }
				elsif (($PER_CO  eq "PLR")) { $Mod="SI"; }
				elsif (($PER_CO  eq "PLB")) { $Mod="SI"; }
				elsif (($PER_CO  eq "REA")) { $Mod="SI"; }
				elsif (($PER_CO  eq "RIA")) { $Mod="SI"; }
				elsif (($PER_CO  eq "RPS")) { $Mod="SI"; }

				elsif (($PER_CO  eq "DRM")) { $Mod="SI"; }
				elsif (($PER_CO  eq "DRC")) { $Mod="SI"; }
				elsif (($PER_CO  eq "DR")) { $Mod="SI"; }
				elsif (($PER_CO  eq "ENR")) { $Mod="SI"; }
				elsif (($PER_CO  eq "FER")) { $Mod="SI"; }
				elsif (($PER_CO  eq "RRB")) { $Mod="SI"; }
				elsif (($PER_CO  eq "RRN")) { $Mod="SI"; }
				elsif (($PER_CO  eq "RRR")) { $Mod="SI"; }
				elsif (($PER_CO  eq "PRR")) { $Mod="SI"; }
				
				elsif (($PER_CO  eq "CRR")) { $Mod="PC"; }
				

				$Disturbance = $Mod . "," . $PER_AN; 
	                  }
	   else { $Disturbance = MISSCODE.",-1111"; }
	} else { $Mod = ERRCODE; $Disturbance = $Mod . "," . $PER_AN;  }

	return $Disturbance;
}

#PER_CO_MOY	con, cdl, dld, cam, ca, cd, cj, cjg, cjp, cjt, cca, cb, ctr, cp, cpi, cps, ce, cpf, cpm, cpc, rbv, ecl, crr,epc, ece, ec, deg, esi, epr, rr, prr, rrg = PC  vep = WE	brp=BU	chp = WF	dp = DI	el = IK
#con, cdl, dld, cam, ca, cd, cj, cjg, cjp, cjt, cca, cb, cba, ctr, cp, cph, cpi, cps, ce, cea, cef, cpf, cpm, cpc, rbv, ecl, crr, epc, ece, ec, deg, esi, epr = PC						vep = WE	brp=BU	chp = WF	dp = DI	el = IK	drm, drc, dr, deg, enr, fer, rrb, rrn, rrr, prr, rrp, rrg, rr = SI			

#Determine Disturbance2 from PER_CO_MOY and PER_AN_MOY
sub DisturbanceMOY 
{
	my $PER_CO_MOY;
	my $PER_AN_MOY;
	my $Disturbance;
	my $Mod;
	my %ModList = ("", 1, "NULL", 1, "CON", 1, "CDL", 1, "DLD", 1, "CAM", 1, "CA", 1, "CD", 1, "CJ", 1, "CJG", 1, "CJP", 1, "CJT", 1, "CCA", 1, "CB", 1,"CBA", 1, "CTR", 1, "CP", 1, 
		"CPH", 1,"CPI", 1, "CPS", 1, "CE", 1, "CEA", 1, "CEF", 1, "CPF", 1, "CPM", 1, "CPC", 1, "RBV", 1, "ECL", 1, "CRR", 1, "EPC", 1, "ECE", 1, "EC", 1, "ESI", 1, 
		"EPR", 1, "VEP", 1, "BRP", 1, "CHP", 1, "DP", 1, "EL", 1, 
		"DRM", 1, "DRC", 1, "DR", 1,  "DEG", 1, "ENR", 1,  "ENP", 1, "FER", 1, "RRB", 1, 
		"RRN", 1, "RRR", 1,   "PRR", 1,"RRP", 1,  "RRG", 1,  "RR", 1);
	
	
	($PER_CO_MOY) = shift(@_);
	($PER_AN_MOY) = shift(@_);
	$_ = $PER_CO_MOY; tr/a-z/A-Z/; $PER_CO_MOY = $_;
	if ($PER_AN_MOY eq "" || $PER_AN_MOY eq "NULL") {$PER_AN_MOY=MISSCODE; }
	
	if ($ModList{$PER_CO_MOY} ) 
	{ 

	          if ($PER_CO_MOY ne "" && $PER_CO_MOY ne "NULL") 
	          { 
					
					if (($PER_CO_MOY  eq "CON") ) { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "CDL")) { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "DLD")) { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "CAM")) { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "CA"))  { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "CD"))  { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "CJ"))  { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "CJG") ) { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "CJP")) { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "CJT") ) { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "CCA")) { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "CB"))  { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "CTR")) { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "CP"))  { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "CPH")) { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "CPI")) { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "CPS")) { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "CE"))  { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "CEA"))  { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "CEF"))  { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "CPF")) { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "CPM")) { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "CPC")) { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "RBV")) { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "ECL")) { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "CRR")) { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "EPC")) { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "ECE")) { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "EC"))  { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "ESI")) { $Mod="PC"; }
					elsif (($PER_CO_MOY  eq "EPR")) { $Mod="PC"; }
					

					elsif (($PER_CO_MOY  eq "VEP") ) { $Mod="WE"; }
					elsif (($PER_CO_MOY  eq "BRP") ) { $Mod="BU"; }
					elsif (($PER_CO_MOY  eq "CHP")) { $Mod="WF"; }
					elsif (($PER_CO_MOY  eq "DP") ) { $Mod="DI"; }
					elsif (($PER_CO_MOY  eq "EL")) { $Mod="IK"; }
					elsif (($PER_CO_MOY  eq "DEG")) { $Mod="SI"; }
					elsif (($PER_CO_MOY  eq "DRM")  ||  ($PER_CO_MOY eq "DRC")||  ($PER_CO_MOY eq "DR")) { $Mod="SI"; }
					elsif (($PER_CO_MOY  eq "DEG")  ||  ($PER_CO_MOY eq "ENR")||  ($PER_CO_MOY eq "ENP") ||($PER_CO_MOY eq "FER")) { $Mod="SI"; }
					elsif (($PER_CO_MOY  eq "RRB")  ||  ($PER_CO_MOY eq "RRN")||  ($PER_CO_MOY eq "RRR")||  ($PER_CO_MOY eq "PRR")) { $Mod="SI"; }
					elsif (($PER_CO_MOY  eq "RRP")  ||  ($PER_CO_MOY eq "RRG")||  ($PER_CO_MOY eq "RR")) { $Mod="SI"; }
					$Disturbance = $Mod . "," . $PER_AN_MOY; 
				}
	           else { $Disturbance = MISSCODE.",-1111"; }
	 } else { $Mod = ERRCODE; $Disturbance = $Mod . "," . $PER_AN_MOY;}

	return $Disturbance;
}

sub cartesienPROD
{
	my $tab1= shift(@_);
	my $tab2= shift(@_);
	my @PC=(); 

	foreach my $elt1  (@$tab1){
		foreach my $elt2  (@$tab2){
	 		 unshift (@PC, $elt1.$elt2);
		}
	}
	return reverse(@PC);
}


# Determine wetland codes  from CDR_CO, ECOTYPE or TYPE DE DEPOT (DSU_CO?) // TO DO
#$Wetland = WetlandCodes ($RHY_CO, $SMR2, $TER_CO, $GR_ESS, $CDE_CO, $CHA_CO, $Sp1, $Sp2, $Sp1Per);
 #$Wetland=WetlandCodes($RHY_CO, $CDR_CO, $TER_CO, $GR_ESS, $CDE_CO, $CHA_CO, $TYPE_ECO)


sub WetlandCodes 
{
	my $Moisture1 = shift(@_);  
	# 04-08-2011  avoid undef variables
	if (!defined $Moisture1)  {$Moisture1="";}
	my $SoilCode =  shift(@_);

	my $Species = shift(@_);
	my $Density = shift(@_);
	my $Height = shift(@_);
	my $ecosite = shift(@_);

	my @list123=qw(1 2 3);
	my @list456=qw(4 5 6);
	my @listg1=qw(EC  EPU  EME  RME SE  ES  RE  MEE  MEC);
	my @listabc=qw(A B C);

	my @listg2=qw(CC  CPU  CE  CME RC  SC  CS  PUC  BBBB  EBB  BBBBE BBE  BB1E);
	my @listECO2=qw(FF10  FF20  FF30  FF50  FF60  FC10  MJ10  MS10  MS20 MS40  MS60  MS70   RB50  RP10  RS20 RS20S  RS40  RS50  RS70  RT10  RE20  RE40  RE70);
	my @listECO1=qw(RS37  RS39  RS18  RE37  RC38  MJ18  MF18);
	my @listHardw=qw(FNC  BJ FH FT  BB  BB1  PE  PE1  FI);
	my @listconif=qw(E S ME  C  PU  RS  RE  RC  RPU  RME);
	my $WetlandCode = MISSCODE;
	
	$_ = $Moisture1; tr/a-z/A-Z/; $Moisture1 = $_;
	$_ = $SoilCode; tr/a-z/A-Z/; $SoilCode = $_;
	$_ = $Species; tr/a-z/A-Z/; $Species = $_;
	$_ = $Density; tr/a-z/A-Z/; $Density = $_;
	$_ =  $Height; tr/a-z/A-Z/;  $Height = $_;

	my @listHardwMIX= cartesienPROD(\@listHardw, \@listHardw);
	my @listHardwMIXCON= cartesienPROD(\@listHardw, \@listconif);
	foreach my $elt2  (@listHardwMIX)
	{
	 	push (@listHardw, $elt2);
	}
	foreach my $elt2  (@listHardwMIXCON)
	{
	 	push (@listHardw, $elt2);
	}
	
	if (($Moisture1 eq "W") ){ $WetlandCode = "S,O,N,S,"; }
	if (($SoilCode eq "AL") && (($Moisture1 eq "W"))){ $WetlandCode = "S,O,N,S,"; }
	if ($SoilCode eq "DH") { $WetlandCode = "S,O,N,S,"; }

	if (($Moisture1 eq "W")){  

	  	if ( ($Species eq "EE") &&  ($Density eq "D") && (grep{$Height eq $_} @list456) )
	   		 { $WetlandCode = "B,T,N,N,"; }
	  	if ( (grep{$Species eq $_} @listg1) &&  (grep{$Density eq $_} @listabc) && (grep{$Height eq $_} @list123) )
	    		{ $WetlandCode = "S,T,N,N,"; }
 	  	if ( (($Species eq "EE") || ($Species eq "MEME"))  && (grep{$Density eq $_} @listabc) )
	   		 { $WetlandCode = "S,T,N,N,"; }
	  	if ( grep{$Species eq $_} @listg2)
	    		{ $WetlandCode = "S,T,N,N,"; }
	  	if ( (($Species eq "EME") || ($Species eq "MEE"))  && ($Density eq "D") )
	    		{ $WetlandCode = "F,T,N,N,"; }
	  	if ( ($Species eq "MEME")  &&  (grep{$Height eq $_} @list456) )
	    		{ $WetlandCode = "F,T,N,N,"; }

	  	if ( grep{$Species eq $_} @listHardw)
	    		{ $WetlandCode = "S,T,N,N,"; }

	  	if (grep{$ecosite eq $_} @listECO2 )
	    		{ $WetlandCode = "S,T,N,N,"; }
	  }

	  if (grep{$ecosite eq $_} @listECO1 )
	    { $WetlandCode = "S,T,N,N,"; }

	  if (($ecosite  eq  "RS38") || ($ecosite  eq  "RE38")  )
	    { $WetlandCode = "F,T,N,N,"; }

	  if ($ecosite  eq  "RE39" )
	    { $WetlandCode = "B,T,N,N,"; }

	  
	  return $WetlandCode;
	
}



sub QC4inv_to_CAS 
{

	my $QC_File = shift(@_);
	$Species_table = shift(@_);
	my $CAS_File = shift(@_);
	my $ERRFILE = shift(@_);
	my $nbiters = shift(@_);
	my $temp= shift(@_);
	my $optgroups= shift(@_);
	my $pathname=shift(@_);
	my $TotalIT=shift(@_);
	my $YEAROFPHOTO=shift(@_);
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

	my $SPECSLOG=shift(@_);
	my $hstd=shift(@_);
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
	my $key1; my $p1; my $p2; my $p3; my $p4;
	my $key2;
	my $key3;

	my $autre="others";
	my $cnull= "NULL";
	my $cempty = "";
	# if(isempty($autre}) {print "YES\n";}
	# else {print "NO\n";}
	# print "empty de vide = isempty($cempty} and empty de null = isempty($cnull} and empty de autre = isempty($autre} "; exit;

	#change this
	#if (!defined $YEAROFPHOTO) {$YEAROFPHOTO=0; print "non defined photoyear for file $QC_File\n"}
	#my (@tabSpec)= QCSpecies();
	my (@QC_plant_tabSpec);
	my (@QCtabSpec);
	if($nbiters==1){
		@tabSpecv4 = decomp_FR(); # QCSpecies();
		@tabSpec = QCSpecies();

	}
	# else
	# {		
	# 	@tabSpec=@$temp;
	# }

	foreach my $elt1 (@tabSpec) 
	{ 
		($p1, $p2, $p3, $p4)=split("#", $elt1); 
		if ($p1 eq "MEPH") {$elt1="MEPH#ME#PH";}
		if ($p1 eq "MEPL") {$elt1="MEPL#ME#PL";}
		
		if (!defined $p2) {$p2="";}   if (!defined $p3) {$p3="";} if (!defined $p4) {$p4="";}
		 push (@QCtabSpec, $p1); 
			if($p2 ne "M"	&& $p3 ne "M") { push (@QCtabSpec, $p1); # push (@QCtabSpec, $p1); #print "$elt1***";
							#print "$elt1\n";
			}
		if ($p1 eq "MF") {$elt1="MF#MF"; push (@QCtabSpec, $p1);}
		if ($p1 eq "MR") {$elt1="MR#MR"; push (@QCtabSpec, $p1);}

	}
	foreach my $elt1 (@tabSpecv4) 
	{ 
		 ($p1, $p2, $p3, $p4)=split("#", $elt1); 
		 if ($p1 eq "MEPH") {$elt1="MEPH#ME#PH";}
		 if ($p1 eq "MEPL") {$elt1="MEPL#ME#PL";}
		 if (!defined $p2) {$p2="";}   if (!defined $p3) {$p3="";} if (!defined $p4) {$p4="";}
			if($p2 ne "M"	&& $p3 ne "M") {  push (@QC_plant_tabSpec, $p1);  
												
							#print "$elt1\n";
			}

	}

		
	my $CAS_File_HDR = $CAS_File . ".hdr";
	my $CAS_File_CAS = $CAS_File . ".cas";
	my $CAS_File_LYR = $CAS_File . ".lyr";
	my $CAS_File_NFL = $CAS_File . ".nfl";
	my $CAS_File_DST = $CAS_File . ".dst";
	my $CAS_File_ECO = $CAS_File . ".eco";

	#open (QCinvo, "<$QC_File") || die "\n Error: Could not open QC input file $QC_File!\n";
	open (ERRS, ">>$ERRFILE") || die "\n Error: Could not open $ERRFILE file!\n";
	open (SPERRSFILE, ">>$SPERRS") || die "\n Error: Could not open $SPERRS file!\n";
	open (SPECSLOGFILE, ">>$SPECSLOG") || die "\n Error: Could not open $SPECSLOG file!\n";

	if($optgroups==1)
	{

	 	$CAS_File_HDR = $pathname."/QCtable.hdr";
	 	$CAS_File_CAS = $pathname."/QCtable.cas";
	 	$CAS_File_LYR = $pathname."/QCtable.lyr";
	 	$CAS_File_NFL = $pathname."/QCtable.nfl";
	 	$CAS_File_DST = $pathname."/QCtable.dst";
	 	$CAS_File_ECO = $pathname."/QCtable.eco";
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

	if(($optgroups==0) || ($optgroups==1 && $nbiters==1)|| ($optgroups==2 && $TotalIT==1)){
		open (CASHDR, ">$CAS_File_HDR") || die "\n Error: Could not open GROUPCAS header output file!\n";
		open (CASCAS, ">$CAS_File_CAS") || die "\n Error: Could not open GROUPCAS  output file!\n";
		open (CASLYR, ">$CAS_File_LYR") || die "\n Error: Could not open GROUPCAS layer output file!\n";
		open (CASNFL, ">$CAS_File_NFL") || die "\n Error: Could not open GROUPCAS non-forested  file!\n";
		open (CASDST, ">$CAS_File_DST") || die "\n Error: Could not open GROUPCAS disturbance  file!\n";
		open (CASECO, ">$CAS_File_ECO") || die "\n Error: Could not open GROUPCAS ecological  file!\n";
		
	print CASCAS "CAS_ID,ORIG_STAND_ID,STAND_STRUCTURE,NUM_OF_LAYERS,IDENTIFICATION_ID,MAP_SHEET_ID,GIS_AREA,GIS_PERIMETER,INVENTORY_AREA,PHOTO_YEAR\n";
	print CASLYR "CAS_ID,SOIL_MOIST_REG,STRUCTURE_PER,LAYER,LAYER_RANK,CROWN_CLOSURE_UPPER,CROWN_CLOSURE_LOWER,HEIGHT_UPPER,HEIGHT_LOWER,PRODUCTIVE_FOR,". 		"SPECIES_1,SPECIES_PER_1,SPECIES_2,SPECIES_PER_2,SPECIES_3,SPECIES_PER_3,SPECIES_4,SPECIES_PER_4,SPECIES_5,SPECIES_PER_5,SPECIES_6,SPECIES_PER_6,SPECIES_7,SPECIES_PER_7,".
	"SPECIES_8,SPECIES_PER_8,SPECIES_9,SPECIES_PER_9,SPECIES_10,SPECIES_PER_10,ORIGIN_UPPER,ORIGIN_LOWER,SITE_CLASS,SITE_INDEX\n";
	print CASNFL "CAS_ID,SOIL_MOIST_REG,STRUCTURE_PER,LAYER,LAYER_RANK,CROWN_CLOSURE_UPPER,CROWN_CLOSURE_LOWER,HEIGHT_UPPER,HEIGHT_LOWER,NAT_NON_VEG,NON_FOR_ANTH,NON_FOR_VEG\n";
	print CASDST "CAS_ID,DIST_1,DIST_YR_1,DIST_EXT_UPPER_1,DIST_EXT_LOWER_1,DIST_2,DIST_YR_2,DIST_EXT_UPPER_2,DIST_EXT_LOWER_2,DIST_3,DIST_YR_3,DIST_EXT_UPPER_3,DIST_EXT_LOWER_3,LAYER\n";
	print CASECO "CAS_ID,WETLAND_TYPE,WET_VEG_COVER,WET_LANDFORM_MOD,WET_LOCAL_MOD,ECO_SITE\n";
	print CASHDR 		"IDENTIFICATION_ID,JURISDICTION,COORDINATE_SYS,PROJECTION,DATUM,INVENTORY_OWNER,LAND_OWNER,PERMISSION,TENURE_TYPE,INV_TYPE,INV_VERSION,INV_START_YR,INV_FINISH_YR,INV_ACQ_ID,INV_ACQ_YR,INV_UPDATE_YR\n";

		# ===== Output to header file =====
#"IDENTIFICATION_ID,JURISDICTION,COORDINATE_SYS,PROJECTION,DATUM,INVENTORY_OWNER,LAND_OWNER,PERMISSION,TENURE_TYPE,INV_TYPE,INV_VERSION,INV_START_YR,INV_FINISH_YR,INV_ACQ_ID,INV_ACQ_YR,INV_UPDATE_YR\n";
		#print CASHDR 
#"HEADER_ID,JURISDICTION,COORD_SYS,PROJECTION,DATUM,INV_OWNER,LAND_OWNER,PERMISSION,TENURE_TYPE,INV_TYPE,INV_VERSION,INV_START_YR,INV_FINISH_YR,INV_ACQ_ID,INV_ACQ_YR,INV_UPDATE_YR,COMMENT\n";

		my $HDR_Record =  "1,QC,NTS,UTM,NAD83,PROV_GOV,MRNF,,,TIE,3rd,1990,2001,,,";
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

	my $CAS_ID; my $pr1; my $pr2; my $pr3; my $pr4; my $pr5;my $MapSheetID;my $IdentifyID;my $Area; my $Perimeter;
	my $SMR1;my $SMR2;my $SMR; my $CCHigh; my $CCLow; my $HeightHigh;my $HeightLow; 
	my $OriginHigh; my $OriginLow;  
	my $PolyNum; my $rank_info;

	my %herror=(); my $keys; my $CAS_Record; my $LYR_Record; my $LYR_Record1; my $LYR_Record2; my $LYR_Record3;
	my $NFL_Record; my $NFL_Record1; my $NFL_Record2; my $NFL_Record3; my $DST_Record; 
	my $StandStructureCode; my $StandStructureValue; my $SpeciesComp;my $Wetland;my $LYR_RecordNULL; my $NatNonVeg; my $NonForVeg; my $NonVegAnth;

	my $Dist1; my $Dist2; my $p1Dist1;my $p2Dist1;my $p1Dist2;my $p2Dist2; 
	my $Layer_rank; my $NumLayers; my $Layer; my $cl_age1; my $cl_age2;
	my @auxtabl; my $nbets; my $newvaltab;my $GR_ESS2;
	my $OriginHigh2; my $OriginLow2;
	my $cpterhy_co=0; my $std; 
	my $cpt4nulleco=0; my $nl2; my $CCHigh_et1; my $CCLow_et1; my $HeightHigh_et1; my $HeightLow_et1;
	my $layerInfo; my $layerInfo1; my $layerInfo2;
	#open (GESCOF, ">codegesco.txt") || die "\n Error: Could not open codegesco file!\n";
	#foreach my $elt1 (@QC_plant_tabSpec) { print GESCOF "$elt1 \n";}
	#close(GESCOF);

	#my $GR_ESS="BJ+R"; my $GR_ESS3=$GR_ESS;
	#if($GR_ESS =~ m/\+/){ #$GR_ESS3 =~ s/\+/\\+/; 
	#print "$GR_ESS3\n";}
	#if (grep{$GR_ESS3 eq $_} @QC_plant_tabSpec) {
			#print "FOUND BJ+R \n";
			#}
	#else {
			#print "CODE  NOT FOUND \n";
			#}
	#exit(0);

	#%is_blue = ();
	   # for (@blues) { $is_blue{$_} = 1 }

	 
	##############################################

	my $csv = Text::CSV_XS->new
	({  binary              => 1,
		sep_char    => ";" 
	});


	my %QCtable=();
	
	open my $QCinv, "<", $QC_File or die " \n Error: Could not open QC input file $QC_File: $!";
	
	#printf("file is  $QC_File\n");

	my @tfilename= split ("/", $QC_File);
	my $nps=scalar(@tfilename);
	$Glob_filename= $tfilename[$nps-1];

 	$csv->column_names ($csv->getline ($QCinv));

   	while (my $row = $csv->getline_hr ($QCinv)) 
   	{	

	# 04-08-2011  there  is a new codification of the CAS_ID
	 @auxtabl=split("-", $row->{CAS_ID});
	   $nbets=scalar(@auxtabl);
	 #  avec la nouvelle codification du CAS_ID Polynum se trouve à l'avant-dernière position dans le tableau
 	 #$PolyNum      =$auxtabl[$nbets-2];
     	 $Glob_CASID   =  $row->{CAS_ID};
	  $CAS_ID       =  $row->{CAS_ID}; 
	  ($pr1,$pr2,$pr3, $pr4, $pr5)     =  split("-", $row->{CAS_ID} ); 
	  $PolyNum = $pr4;   	    
      	$MapSheetID   =  $pr3; 
    	  $MapSheetID =~ s/x+//;
      	$IdentifyID   =  $row->{HEADER_ID};     	
     	 $Area         =  $row->{GIS_AREA};    
	  $Perimeter    = $row->{GIS_PERI};  
	#$YEAROFPHOTO  =  $QCtable{$CAS_ID};
	$YEAROFPHOTO = $row->{AN_PRO_SOU}; 
      
	#$std=$row->{NO_PRG};
	$std=$row->{VER_PRG}; 
	if(!defined $std){$std="";} $hstd->{$std}++;
	#if($std ne "INITIALE" &&  $std ne "") {
	if($hstd->{$std}==1 ) {
				print "found  version ---$std--- in casid $CAS_ID\n"; 
	}
#next;
	#if($std eq "INITIALE" || $std eq "") {}
	#elsif ($std eq "MIXTE") {}
	#elsif ($std eq "NAIPF2010") {}	

	#SMR not defined for Qc 4th; can be drived from CL_DRAI (or  CDR_CO) or TYPE_ECO (or  TYPE_ECO)
	$SMR = SoilMoistureRegime($row->{CL_DRAI});  
	if($SMR eq ERRCODE) { 
			$keys="CL_DRAI"."#".$row->{CL_DRAI};
			$herror{$keys}++;
	}
		
	#CrownClosure		 
	$CCHigh = CCUpper($row->{CL_DENS});
	if($CCHigh  eq ERRCODE ) { $keys="CL_DENS"."#".$row->{CL_DENS};
						   $herror{$keys}++;
	}
	$CCLow = CCLower($row->{CL_DENS});
	if($CCLow  eq ERRCODE) { $keys="CL_DENS"."#".$row->{CL_DENS};
						   $herror{$keys}++; 
	}
	#if the version is NAIPF, use different fields and function for CrownClosure
	if(defined $row->{ET1_DENS} ) {
		$CCHigh = $CCHigh_et1 = CCUpper2($row->{ET1_DENS});
		if($CCHigh_et1  eq ERRCODE ) { $keys="NAIPF-CL_DENS"."#".$row->{ET1_DENS};
						   $herror{$keys}++;
		}
		$CCLow = $CCLow_et1 = CCLower2($row->{ET1_DENS});
		if($CCLow_et1  eq ERRCODE) { $keys="NAIPF-CL_DENS"."#".$row->{ET1_DENS};
						   $herror{$keys}++; 
		}
	}
	 
	#Height
	$HeightHigh = StandHeightUp($row->{CL_HAUT});
	if($HeightHigh  eq ERRCODE) { $keys="CL_HAUT"."#".$row->{CL_HAUT}."#"; 
						     $herror{$keys}++; 
	 }
	$HeightLow = StandHeightLow($row->{CL_HAUT});
	if($HeightLow eq ERRCODE ) { $keys="CL_HAUT"."#".$row->{CL_HAUT}."#"; 
						     $herror{$keys}++; 
   	}
	#if the version is NAIPF, use different fields and function for Height 
	if(defined $row->{ET1_HAUT} ) {
		$HeightHigh = $HeightHigh_et1 = StandHeightUp2($row->{ET1_HAUT});
		if($HeightHigh_et1  eq ERRCODE) { $keys="CL_HAUT"."#".$row->{ET1_HAUT}."#"; 
						     $herror{$keys}++; 
		 }
		$HeightLow = $HeightLow_et1 = StandHeightLow2($row->{ET1_HAUT});
		if($HeightLow_et1 eq ERRCODE ) { $keys="CL_HAUT"."#".$row->{ET1_HAUT}."#"; 
						     $herror{$keys}++; 
   		}
	}
	
#if(defined ($row->{CHA_CO}) && $row->{CHA_CO} ne ""){

  # if ($row->{CHA_CO} <=4){
	 
	#if($row->{GR_ESS} ne ""){
		#$GR_ESS2=$row->{GR_ESS};						
		#if (grep{$GR_ESS2 eq $_} @QC_plant_tabSpec ) {
			#$SpeciesComp = Species($row->{GR_ESS}, \@tabSpec, $spfreq);
		#}
	#}
		#$spfreq->{$row->{GR_ESS}.$SpeciesComp}++;
   #}
#}

		if(!defined $row->{ET_DOMI}){$row->{ET_DOMI}="";}
 		if (!defined $row->{CL_AGE}){$row->{CL_AGE}="";}
		
		$StandStructureCode="S"; $Layer_rank=1; $NumLayers=1; $Layer=1;$layerInfo="1,1";$layerInfo1="1,1";
		$StandStructureCode = StandStructure($row->{CL_AGE});

		if(isempty($YEAROFPHOTO) )
		{
			$OriginHigh = MISSCODE;
			$OriginLow = MISSCODE;
		}
		if ($StandStructureCode eq ERRCODE){
							$keys="standstruct-CL_AGE"."#".$row->{CL_AGE};
							$herror{$keys}++; 
		}
		elsif ($StandStructureCode eq "S" && !isempty($YEAROFPHOTO)) {
					$OriginHigh = UpperOrigin($row->{CL_AGE});
	  				$OriginLow  = LowerOrigin($row->{CL_AGE});
		}

		elsif ($StandStructureCode eq "M" && !isempty($YEAROFPHOTO))
		{
					
					$cl_age1=substr $row->{CL_AGE}, 0, 2;
					if($cl_age1 == 12) {
								$cl_age1=substr $row->{CL_AGE}, 0, 3;
					}
					
					$OriginHigh = UpperOrigin($cl_age1);
	  				$OriginLow  = LowerOrigin($cl_age1);

	  				# we won't use information on co-dominant layer

	  				# $nl2=length($row->{CL_AGE}) - length($cl_age1);
					# if($nl2 <2 || $nl2 >3){
					# 	print ("error while extracting lenght ageclass2 and ageclass1\n"); exit; 
					# }
					# $cl_age2=substr $row->{CL_AGE}, -$nl2;


					# $OriginHigh2 = UpperOrigin($cl_age2);
	  				# $OriginLow2  = LowerOrigin($cl_age2);

					# if( ($OriginHigh2 eq ERRCODE)  || ($OriginLow2 eq ERRCODE) ) {
					# 		$keys="age_class2"."#".$cl_age2;
					# 		$herror{$keys}++;
					#  }
					# elsif(( ($OriginHigh2 ne MISSCODE) && ($OriginLow2 ne  MISSCODE) )) {  
					
					# 	###TURN AGE2 INTO ABSOLUTE YEAR VALUE ##########
					# 	if ($OriginHigh2 ne INFTY) {$OriginHigh2 = $YEAROFPHOTO-$OriginHigh2;}
	  				#	$OriginLow2  = $YEAROFPHOTO-$OriginLow2;
					# 	if ($OriginHigh2 > $OriginLow2) {  $keys="ORIGIN2#".$cl_age2."#original value is #".$row->{CL_AGE};
					# 						$herror{$keys}++; 
					# 	}
					# 	my $aux=$OriginHigh2;
					# 	$OriginHigh2=$OriginLow2;
					# 	$OriginLow2=$aux;
					# 	if ( ($OriginHigh2 > 0 && $OriginHigh2 < 1700) ||$OriginHigh2 > 2014 ||  ($OriginLow2 > 0 && $OriginLow2 < 1700) ||$OriginLow2 > 2014) 							{  $keys="CHEK ORIGIN2"."#".$cl_age2."#photoyear#".$YEAROFPHOTO;
					# 					$herror{$keys}++; 
					# 	}
					# 	####.­­­.END  OF  TURNING AGE INTO ABSOLUTE YEAR VALUE ###########
					# }
		}
		if($row->{ET_DOMI} eq "2") {$NumLayers = 2; $StandStructureCode = "M"; $layerInfo1 = "1,2"; $layerInfo2 = "2,1"; $layerInfo = "2,1";  $Layer = 2;}
		else {$NumLayers = 1; $StandStructureCode = "S"; $layerInfo1="1,1"; $layerInfo="1,1"; $layerInfo2="2,2";}
	

		if( ($OriginHigh eq ERRCODE)  || ($OriginLow eq ERRCODE) ) {
			$keys="CL_AGE"."#".$row->{CL_AGE};
			$herror{$keys}++;
		}
		elsif(( ($OriginHigh ne MISSCODE) && ($OriginLow ne  MISSCODE) )) 
		{  
			#############TURNING AGE INTO ABSOLUTE YEAR VALUE ##################ADDED ON MARCH 25TH OF 2009 ##########################
			if ($OriginHigh ne INFTY) {$OriginHigh = $YEAROFPHOTO-$OriginHigh;}
		  	$OriginLow  = $YEAROFPHOTO-$OriginLow;
			if ($OriginHigh > $OriginLow) {  $keys="yearphoto = $YEAROFPHOTO, originhigh is gt originlow --$OriginHigh-- *** --$OriginLow--CHEK ORIGINUPPER-CL_AGE"."#" .$row->{CL_AGE};
								$herror{$keys}++; 
					}
			my $aux=$OriginHigh;
			$OriginHigh=$OriginLow;
			$OriginLow=$aux;

			if ( ($OriginHigh > 0 && $OriginHigh < 1700) || $OriginHigh > 2014 ||  ($OriginLow > 0 && $OriginLow < 1700) ||$OriginLow > 2014) 				
			{ # $keys="CHEK ORIGIN"."#".$cl_age1}."#photoyear#".$YEAROFPHOTO;
					$keys="CHEK ORIGIN #$row->{CL_AGE}#"."#photoyear#".$YEAROFPHOTO;
					$herror{$keys}++; 
			}
			####.­­­.END  OF  TURNING AGE INTO ABSOLUTE YEAR VALUE ###########ADDED ON MARCH 25TH OF 2009 #####################
		}


		$Dist1 = Disturbance($row->{ORIGINE}, $row->{AN_ORIGINE});
		($p1Dist1,$p2Dist1) = split(/,/, $Dist1);
		if($p1Dist1 eq ERRCODE ) 
		{ 
			$keys="ORIGIN_DISTURBANCE"."#".$row->{ORIGINE} ;
			$herror{$keys}++;
		}
	
	    $Dist2 = DisturbanceMOY($row->{PERTURB}, $row->{AN_PERTURB});
	    ($p1Dist2,$p2Dist2) = split(/,/, $Dist2);
	    if($p1Dist2 eq ERRCODE ) 
	    { 
	    	$keys="AN_PERTURB"."#".$row->{AN_PERTURB} ;
			$herror{$keys}++;
		}


		$NatNonVeg=NaturallyNonVeg($row->{CO_TER});
		$NonForVeg=NonForestedVeg($row->{CO_TER});
		$NonVegAnth=NonVegetatedAnth($row->{CO_TER});
 		

		if(($NatNonVeg eq ERRCODE) &&  ($NonForVeg eq ERRCODE ) &&  ($NonVegAnth eq ERRCODE )) { 
					$keys="NatNonVeg"."#".$row->{CO_TER};
					$herror{$keys}++; 
					#$row->{CO_TER}="INC";$NonVegAnth="OT";
				}

	if(!isempty($row->{GR_ESS}))
	{
		$GR_ESS2=$row->{GR_ESS};	

		# if(length ($GR_ESS2) ne 2 && length ($GR_ESS2) ne 4 && length ($GR_ESS2) ne 6) {
		# 	$hstd->{$GR_ESS2."#".$std}++;
		# 	if($hstd->{$GR_ESS2."#".$std}==1 ) {
		# 		print "tracking species---$GR_ESS2 # $std--- in casid $CAS_ID \n"; 
		# 	}
		# }
		# next;  #carrefully verify this
							
		if (grep{$GR_ESS2 eq $_} @QC_plant_tabSpec ) {
								print("\n found plant code  $GR_ESS2 \n");	exit; #
		}
		elsif (grep{$GR_ESS2 eq $_} @QCtabSpec ) {	
		#	print("\n basic species");
				$SpeciesComp = Species($row->{GR_ESS}, \@tabSpec, $spfreq);
			#	print("\n end basic species");
				#$spfreq->{$row->{GES_CO}."##".$SpeciesComp}++;
		}
		else { # ($row->{GR_ESS} ne "") {				 

				if($row->{GR_ESS} eq "ALM" || $row->{GR_ESS} eq "ALF") {  
						#$keys="GR_ESS_CORRECTED_MOVED_AL_TO_TERCO"."#".$row->{GR_ESS}."#" ;$herror{$keys}++;
						$NonForVeg="ST";$row->{CO_TER}="AL";  $row->{GR_ESS}="";
						$SpeciesComp="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";
				}
				else {
						$newvaltab=Species_complement($row->{GR_ESS});
						if($newvaltab ne SPECIES_ERRCODE ){
							
							push (@tabSpec, $newvaltab);  #push (@QC_plant_tabSpec, $row->{GR_ESS});  
							push (@QCtabSpec, $row->{GR_ESS}); 
							#print("\n complement  species");
							$SpeciesComp = Species($row->{GR_ESS}, \@tabSpec,$spfreq);
						#	print("\n end complement species");
							#$spfreq->{$row->{GR_ESS}."##".$SpeciesComp}++;
						}
						else {
							$keys="GR_ESS"."#TOSEE".$row->{GR_ESS};$herror{$keys}++;
							$SpeciesComp=ERRCODE.",0,".ERRCODE.",0,".ERRCODE.",0";  #",,,,,";
							print "!!WARNING!!! NON TREATED SPECIES ERROR ! CHECK THIS ERROR IN SPECIES DECOMPSITION\n";
							#exit;
						}
				}
			    # #$herror{$keys}++;
	 				####$SpeciesComp = Species($row->{GR_ESS}, \@tabSpec, $spfreq);
   		}
	}
	else {$SpeciesComp="XXXX MISS,0,XXXX MISS,0,XXXX MISS,0";  
	}

	

	$Wetland = WetlandCodes($SMR, $row->{CO_TER}, $row->{GR_ESS}, $row->{CL_DENS}, $row->{CL_AGE}, $row->{TYPE_ECO});
	if(isempty($row->{TYPE_ECO} )) 
	{
		$row->{TYPE_ECO}="-";
	}

	my $forested_poly = 0;
	my $ProdFor = "PF";
	my ($Sp1, @Spreste)=split(",", $SpeciesComp); 
	if ($Sp1 eq "XXXX MISS" && ($CCLow >= 0  ||  $HeightLow >= 0)) 
	{ 
		$ProdFor = "PP";
		$forested_poly = 1;
	}
	if($p1Dist1 eq "CO" || $p1Dist2 eq "CO" ) 
	{ 
		$ProdFor = "PF";
		$forested_poly = 1;
	}
	# ===== Output inventory info =====

	#add to avoid mistmacth in the database which expects a smallint
	if(isempty($YEAROFPHOTO) )
	{
		$YEAROFPHOTO = MISSCODE;
	}

	$CAS_Record = $CAS_ID . "," . $PolyNum. "," . $StandStructureCode .",". $NumLayers .",". $IdentifyID . "," .  $MapSheetID . "," . $Area . "," . $Perimeter . ",". $Area. "," .$YEAROFPHOTO;
	 print CASCAS $CAS_Record . "\n";
	$nbpr=1;$$ncas++;$ncasprev++;

	#forested  
	      #print "species 1 is $Sp1 in list $SpeciesComp"; 
	    if ($Sp1 ne "XXXX MISS" || $forested_poly == 1) 
	    { 
	      $LYR_Record1 = $row->{CAS_ID} . "," .$SMR. "," .UNDEF. "," .$layerInfo ;
	      $LYR_Record2 = $CCHigh . "," . $CCLow . "," . $HeightHigh . "," . $HeightLow. "," .$ProdFor. "," .$SpeciesComp;
	      $LYR_RecordNULL="XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0,XXXX UNDF,0";  
	      $LYR_Record3 = $OriginHigh . "," . $OriginLow. "," .UNDEF. "," .UNDEF;
	      $LYR_Record = $LYR_Record1 . "," . $LYR_Record2 . "," . $LYR_RecordNULL . "," .$LYR_Record3;
	      print CASLYR $LYR_Record . "\n";
		  $nbpr++; $$nlyr++;$nlyrprev++;
	    }

        #non-forested
	    elsif ($NatNonVeg ne MISSCODE || $NonVegAnth ne MISSCODE || $NonForVeg ne MISSCODE) 
	    {
	      	$NFL_Record1 = $row->{CAS_ID} . "," . $SMR  . ",".  UNDEF. "," .$layerInfo;
	      	$NFL_Record2 = $CCHigh . "," . $CCLow . "," . $HeightHigh . "," . $HeightLow;
            $NFL_Record3 = $NatNonVeg . "," . $NonVegAnth . "," . $NonForVeg;   #v$NatNonVeg. "," .$NonForVeg. "," .UNDEF;
            $NFL_Record = $NFL_Record1 . "," . $NFL_Record2 . "," . $NFL_Record3;
	      	print CASNFL $NFL_Record . "\n";
			$nbpr++;$$nnfl++;$nnflprev++;
	    }
        #Disturbance
	    if ($p1Dist1 ne MISSCODE ||  $p1Dist2 ne MISSCODE) 
	    {
	      	$DST_Record = $row->{CAS_ID} . "," . $p1Dist1.",".$p2Dist1. "," . UNDEF. "," .UNDEF. "," .$p1Dist2.",".$p2Dist2. "," . UNDEF. "," .UNDEF. "," . UNDEF. "," .UNDEF. "," . UNDEF. "," .UNDEF;
	      	print CASDST $DST_Record . ",$Layer\n";
			if($nbpr==1) 
			{
				$$ndstonly++; 
				$ndstonlyprev++;
			}
			$nbpr++;
			$$ndst++;
			$ndstprev++;
 		}

	if  (defined $row->{TYPE_ECO}) 
	{

      	if ($Wetland ne MISSCODE) 
      	{
            $Wetland = $row->{CAS_ID} . "," . $Wetland.$row->{TYPE_ECO};
            print CASECO $Wetland . "\n";
			if($nbpr==1) 
			{
				$$necoonly++;
				$necoonlyprev++;
			}
			$nbpr++;$$neco++;$necoprev++;
        }          
        else  
       	{
            if( $row->{TYPE_ECO} ne "0" && $row->{TYPE_ECO} ne "" && $row->{TYPE_ECO} ne "NULL"  && $row->{TYPE_ECO} ne "-")  
            {
                $Wetland = $row->{CAS_ID} . "," . "-,-,-,-,".$row->{TYPE_ECO};
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
			if($nbpr==1) 
			{
				$$necoonly++;
				$necoonlyprev++;
			}
			$nbpr++;$$neco++;$necoprev++;
        }             
    }    

		if($nbpr ==1 )
		{
			$ndrops++;
			if($Sp1 eq "XXXX MISS" && isempty($row->{CO_TER}) &&  $p1Dist1 eq MISSCODE &&  $p1Dist2 eq MISSCODE) {
						if((defined $row->{TYPE_ECO})) {
							if($Wetland eq MISSCODE && !( $row->{TYPE_ECO} ne "0" && ($row->{TYPE_ECO} ne "" || $row->{TYPE_ECO} ne "NULL"  ) && $row->{TYPE_ECO} ne "-")){
								$keys ="MAY  DROP THIS>>>-\n";
 								$herror{$keys}++; 
							}
						}
						elsif($Wetland eq MISSCODE ) {
							$keys ="CERTAINLY DROP THIS EMPTY>>>-\n";
 							$herror{$keys}++; 
						}
			}
			else {
				$keys ="!!! record may be dropped#"."specs=".$row->{GR_ESS}."-terco=".$row->{CO_TER}."-teccotec=".$row->{TYPE_ECO}."-dist1=".$row->{ORIGINE}."-dist2=".$row->{PERTURB}."-wetland==".$Wetland."-smr1=".$SMR1."cldens=".$row->{CL_DENS}."-chaco=".$row->{CL_AGE};
 				$herror{$keys}++; 
				$keys ="#droppable#";
 				$herror{$keys}++; 
			}
		}     
    }   
	$csv->eof or $csv->error_diag ();
	close $QCinv;

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
  	}
 

	$$nflareatotal+=$nflarea;
	$total=$nlyrprev+ $nnflprev+  $ndstprev;
	$total2=$nlyrprev+ $nnflprev+  $ndstonlyprev + $necoonlyprev;
	#rint SPERRSFILE " ndrops =$ndrops, nb records in casfile : $ncasprev, lyrfile : $nlyrprev, nflfile : $nnflprev,  dstfile : $ndstprev($ndstonlyprev), ecofile : $necoprev($necoonlyprev)--- total (without .cas): $total($total2)\n";

	#close (QCinv);
	close (CASHDR);
	close (CASCAS);
	close (CASLYR);
	close (CASNFL);
	close (CASDST);
	close (CASECO);
	close (ERRS);close (SPERRSFILE);close(SPECSLOGFILE);  #close (SPERRSFILE);

	#return($qcnflfreq);
	#if($optgroups==1){
	#close (GRPCASHDR);
	#close (GRPCASCAS);
	#close (GRPCASLYR);
	#close (GRPCASNFL);
	#close (GRPCASDST);
	#close (GRPCASECO);	
	#}

}


1;
#province eq "QC";
