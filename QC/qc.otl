library(rpostgis)
library(tidyverse)
library(summarytools)

con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")
x = as_tibble(dbGetQuery(con, "SELECT * FROM rawfri.qc03 LIMIT 10000"))
dbDisconnect(con)

sink("QC/qc03.txt")
dfSummary(x, graph.col=FALSE)
#dfSummary(x$cl_age, graph.col=F, max.distinct.values=99)
sink()


H="CAS_ID"
CAS_ID
QC_0002-xPEU_ECOFOR_ORI-xxxxxxxxxx-0000600000-0000001
QC_0002-xPEU_ECOFOR_ORI-xxxxxxxxxx-0000600001-0000002
QC_0002-xPEU_ECOFOR_ORI-xxxxxxxxxx-0000600002-0000003
QC_0002-xPEU_ECOFOR_ORI-xxxxxxxxxx-0000600003-0000004
QC_0002-xPEU_ECOFOR_ORI-xxxxxxxxxx-0000600004-0000005
QC_0002-xPEU_ECOFOR_ORI-xxxxxxxxxx-0000600005-0000006
QC_0002-xPEU_ECOFOR_ORI-xxxxxxxxxx-0000600006-0000007
QC_0002-xPEU_ECOFOR_ORI-xxxxxxxxxx-0000600007-0000008
QC_0002-xPEU_ECOFOR_ORI-xxxxxxxxxx-0000600008-0000009
QC_0002-xPEU_ECOFOR_ORI-xxxxxxxxxx-0000600009-0000010


H="SOIL_MOIST_REG"
mapInt(cl_drai, {1,2,3,4,5,6}, {"D,F,F,M,W,W"})


sub SoilMoistureRegime
{
	my %MoistRegList,("0", 1, "1", 1, "2", 1, "3", 1, "4", 1, "5", 1, "6", 1, "16", 1);
	my %MoistRegListmodif,("0", 1, "1", 1, "2", 1, "3", 1, "4", 1); 

	my $SoilMoistureReg;
	my $key;
	my $key2;

	my ($MoistReg),shift(@_);
	if (!defined $MoistReg)  
	{
		$MoistReg,"";
	}
	if(isempty($MoistReg )) 
	{ 
		$SoilMoistureReg,MISSCODE; 
	}
	elsif (($MoistReg eq "16") ) 
	{ 
		$SoilMoistureReg,"D"; 
	}
	else 
	{ 
		$key,substr($MoistReg, 0,1); 
		if (!$MoistRegList {$key} ) 
		{
			$SoilMoistureReg,ERRCODE; 
			return $SoilMoistureReg;
		}

		if(length($MoistReg) >1 ) 
		{
			$key2,substr($MoistReg, 1,1);
			if (!$MoistRegListmodif {$key2} )
			{
				$SoilMoistureReg,ERRCODE; 
				return $SoilMoistureReg;
			}
		}

		if (($key eq "0"))         
		{ 
			$SoilMoistureReg,"D"; 
		}
		elsif (($key eq "1"))         { $SoilMoistureReg,"D"; }
		elsif (($key eq "2"))         { $SoilMoistureReg,"F"; }
		elsif (($key eq "3"))         { $SoilMoistureReg,"F"; }
		elsif (($key eq "4"))         { $SoilMoistureReg,"M"; }
		elsif (($key eq "5"))         { $SoilMoistureReg,"W"; }
		elsif (($key eq "6"))         { $SoilMoistureReg,"W"; }	
	}
	return $SoilMoistureReg;
}


H="STRUCTURE_PER"
structure_per,-8888 in CAS_04


H="LAYER"
layer,1 in CAS_04

H="LAYER_RANK"
layer_rank,1 in CAS_04

H="HEIGHT"
What should we use for min and max? Cosco has <4 and 22-INFINITY

mapInt(cl_haut, {1,2,3,4,5,6,7}, {4,7,12,17,22,100})
mapInt(cl_haut, {1,2,3,4,5,6,7}, {0,4,7,12,17,22})


16   cl_haut         1. 1                               610 ( 8.1%)            7567       2433      
     [character]     2. 2                              1262 (16.7%)            (75.67%)   (24.33%)  
                     3. 3                              1110 (14.7%)                                 
                     4. 4                              1668 (22.0%)                                 
                     5. 5                              2297 (30.4%)                                 
                     6. 6                               605 ( 8.0%)                                 
                     7. 7                                15 ( 0.2%)                                 


H="CROWN_CLOSURE"
The following is not consistent with CAS_04 tables

mapInt(cl_dens, {A,B,C,D}, {40,60,80,100})
mapInt(cl_dens, {A,B,C,D}, {25,40,60,80})

15   cl_dens         1. A                              2255 (32.5%)            6947       3053      
     [character]     2. B                              2572 (37.0%)            (69.47%)   (30.53%)  
                     3. C                              1171 (16.9%)                                 
                     4. D                               949 (13.7%)                                 


sub CCUpper2 
{
	my $CCHigh;
	my %DensityList,("25", 1, "35", 1, "45", 1, "55", 1,"65", 1, "75", 1, "85", 1, "95", 1);

	my ($Density),shift(@_);
	if(isempty($Density)) 
	{ 
		$CCHigh,MISSCODE; 
	}
	elsif (!$DensityList {$Density} ) 
	{ 
		$CCHigh,ERRCODE; 
	}
	elsif (($Density == 25))            { $CCHigh,29; }
	elsif (($Density == 35))            { $CCHigh,39; }
	elsif (($Density == 45))            { $CCHigh,49; }
	elsif (($Density == 55))            { $CCHigh,59; }
	elsif (($Density == 65))            { $CCHigh,69; }
	elsif (($Density == 75))            { $CCHigh,79; }
	elsif (($Density == 85))            { $CCHigh,89; }
	elsif (($Density == 95))            { $CCHigh,99; }
	return $CCHigh;
}

#Determine CCLower from Density  ET1_DENS and ET2_DENS  version NAIPF
sub CCLower2
{
	my $CCLow;
	my %DensityList,("25", 1, "35", 1, "45", 1, "55", 1,"65", 1, "75", 1, "85", 1, "95", 1);

	my ($Density),shift(@_);
	if(isempty($Density)) 
	{ 
		$CCLow,MISSCODE; 
	}
	elsif (!$DensityList {$Density} ) 
	{ 
		$CCLow,ERRCODE; 
	}
	elsif (($Density == 25))            { $CCLow,25; }
	elsif (($Density == 35))            { $CCLow,30; }
	elsif (($Density == 45))            { $CCLow,40; }
	elsif (($Density == 55))            { $CCLow,50; }
	elsif (($Density == 65))            { $CCLow,60; }
	elsif (($Density == 75))            { $CCLow,70; }
	elsif (($Density == 85))            { $CCLow,80; }
	elsif (($Density == 95))            { $CCLow,90; }
	return $CCLow;
}


H="PRODUCTIVE_FOR"
CAS_04 - based on sample, only takes 2 values: "PP" or "PF"

H="SPECIES_1-3"


H="SPECIES_PER_1-3"


H="ORIGIN"
friList,c("10","120","12050","30","3030","50","70","70JIN","90","9030","9050","90JIN","JIN","JIR","VIN","VIN10","VIN30","VIR")
mapInt(cl_age, {"10,120,12050,30,3030,50,70,70JIN,90,9030,9050,90JIN,JIN,JIR,VIN,VIN10,VIN30,VIR"}, {})

---------------------------------------------------------------------------
No   Variable   Stats / Values   Freqs (% of Valid)   Valid      Missing   
---- ---------- ---------------- -------------------- ---------- ----------
1    x          1. 10            1191 (15.7%)         7567       2433      
     [factor]   2. 120             97 ( 1.3%)         (75.67%)   (24.33%)  
                3. 12050            1 ( 0.0%)                              
                4. 30            3599 (47.6%)                              
                5. 3030             8 ( 0.1%)                              
                6. 50              70 ( 0.9%)                              
                7. 70             407 ( 5.4%)                              
                8. 70JIN            1 ( 0.0%)                              
                9. 90             217 ( 2.9%)                              
                10. 9030            1 ( 0.0%)                              
                11. 9050            3 ( 0.0%)                              
                12. 90JIN           5 ( 0.1%)                              
                13. JIN           511 ( 6.8%)                              
                14. JIR           489 ( 6.5%)                              
                15. VIN           527 ( 7.0%)                              
                16. VIN10           2 ( 0.0%)                              
                17. VIN30           1 ( 0.0%)                              
                18. VIR           437 ( 5.8%)                              
---------------------------------------------------------------------------

#Determine upper stand origin from CAG_CO  by 10-120, ect

sub UpperOrigin
{
	my $Origin;
	my $OriginUpp;
	my @key=(10, 30, 50, 70, 90, 120);
	($Origin),shift(@_);
	
	my $key1="10";
	if(isempty($Origin))                   { $OriginUpp,MISSCODE; }
 	elsif (($Origin =~ /^$key[0]/) || ($Origin =~ /$key[0]$/))   { $OriginUpp ,20; }
	elsif (($Origin =~ /^$key[1]/) || ($Origin =~ /$key[1]$/))   { $OriginUpp ,40; }
	elsif (($Origin =~ /^$key[2]/) || ($Origin =~ /$key[2]$/))   { $OriginUpp ,60; }
	elsif (($Origin =~ /^$key[3]/) || ($Origin =~ /$key[3]$/))   { $OriginUpp ,80; }
	elsif (($Origin =~ /^$key[4]/) || ($Origin =~ /$key[4]$/))   { $OriginUpp ,100; }
	elsif (($Origin =~ /^$key[5]/) || ($Origin =~ /$key[5]$/))   { $OriginUpp ,INFTY; }
	elsif ($Origin eq  "JIN" || $Origin eq  "JIR") 	{ $OriginUpp ,79; }
	elsif ($Origin eq  "VIN" || $Origin eq  "VIR")	{ $OriginUpp ,INFTY; }
	else { $OriginUpp ,ERRCODE; }
	return $OriginUpp;
}

sub LowerOrigin 
{
	my $Origin;
	my $OriginLow;
	my @key=(10, 30, 50, 70, 90, 120);
	($Origin),shift(@_);
	
	my $key1="10";
	if(isempty($Origin))                 		     { $OriginLow,MISSCODE; }
 	elsif (($Origin =~ /^$key[0]/) || ($Origin =~ /$key[0]$/))   { $OriginLow ,0; }
	elsif (($Origin =~ /^$key[1]/) || ($Origin =~ /$key[1]$/))   { $OriginLow ,21; }
	elsif (($Origin =~ /^$key[2]/) || ($Origin =~ /$key[2]$/))   { $OriginLow ,41; }
	elsif (($Origin =~ /^$key[3]/) || ($Origin =~ /$key[3]$/))   { $OriginLow ,61; }
	elsif (($Origin =~ /^$key[4]/) || ($Origin =~ /$key[4]$/))   { $OriginLow ,81; }
	elsif (($Origin =~ /^$key[5]/) || ($Origin =~ /$key[5]$/))   { $OriginLow ,101; }
    elsif ($Origin eq  "JIN" || $Origin eq  "JIR") 	{ $OriginLow ,1; }
	elsif ($Origin eq  "VIN" || $Origin eq  "VIR")  { $OriginLow ,80; }
	else { $OriginLow ,ERRCODE; }
	return $OriginLow;	
}


H="SITE_CLASS"
site_class,-8888 in CAS_04


H="SITE_INDEX"
site_index,-8888 in CAS_04
