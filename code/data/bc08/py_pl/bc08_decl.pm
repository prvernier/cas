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
