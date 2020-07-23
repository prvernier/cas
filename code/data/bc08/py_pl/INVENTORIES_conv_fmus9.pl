#!/usr/bin/perl -w

use strict;

use Carp ();
local $SIG{__WARN__} = \&Carp::cluck;


#including the conversion modules for the different inventories
#use Modules::QC_conversion11 qw(:DEFAULT @tabSpec); # %nflfreq
use ModulesV4::QC_conversion4th_04 qw(:DEFAULT @tabSpec); # %nflfreq
use ModulesV4::AB_conversion31;
use ModulesV4::MBFLI_LP_conversion15; # qw(:DEFAULT %spfreq); 
use ModulesV4::MBFLI_HR_conversion15;
use ModulesV4::MBPRE97_conversion11;
use ModulesV4::MB_frifli_gov_conversion09;
#use Modules::MBGOV_conversion08; #  qw(:DEFAULT $ncas $nlyr $nnfl $ndst);
use ModulesV4::YT_conversion08;
use ModulesV4::SK_conversion06;
use ModulesV4::SK_conversion06MISTIK;
use ModulesV4::SK_conversion06UTM;
#use ModulesV4::SK_conversion05UTM;
use ModulesV4::NL_conversion08;
#use ModulesV4::BC_conversion06;
#use ModulesV4::BC_conversion07;
use ModulesV4::BC_conversion11;
use ModulesV4::NT_conversion08;
use ModulesV4::ON_conversion24; # qw(:DEFAULT %onnflfreq); ;
use ModulesV4::WBNP_conversion07;
use ModulesV4::PANP_conversion06;
use ModulesV4::NS_conversion06;
use ModulesV4::PE_conversion07;
use ModulesV4::NB_conversion08;




use Cwd;
use Text::CSV;   


sub LoadSpeciesTable
{
	my $provcode=shift(@_);
	my $std=shift(@_);
	my $sptabdir=shift(@_);
	my %speciestable=();
	my $key;

	open (SPtab, "$sptabdir") || die "\n Error: Could not open mater species table file $sptabdir !\n";
		my $csv = Text::CSV_XS->new();
		my $nothing=<SPtab>;  #drop header line
 		while(<SPtab>) {
				if ($csv->parse($_)) 
				{
					my @SP_Record =();
        			@SP_Record = $csv->fields();  
					my $province=$SP_Record[0];
 					next if ($province =~ /^\*/);
 					$_ = $SP_Record[2];
 
					if ($SP_Record[2] =~ /^\*/)
					{
						#print "will skip this code $SP_Record[2] from prov  $province\n";
						next ;
					}
					tr/a-z/A-Z/;
					my $SPcode=$_;
					my $SPtransl=$SP_Record[3];

					if($province eq $provcode)
					{
 						my $version=$SP_Record[1]; 
						if($version eq "" || $version eq $std) 
						{
							$speciestable{$SPcode}=$SPtransl;	
							#print("fFILE no = $qckeys , age = $QCS_Record[1]\n");
						}
					}
				} 
				else 
				{
          			my $err = $csv->error_input;
         			print "Failed to parse line: $err"; exit(1);
      			}	
	 	}
	close(SPtab);
	return %speciestable;
}


#reading input file with or without options
#command line may be "./INVENTORIES_conv_fmus.pl infileqcnew"  or "./INVENTORIES_conv_fmus infileqcnew -p"
# option -m or no option ---> the results will be saved in different directories according to the mapshhets  (m==mapsheet)
# option -p or no option ---> the results will be saved in only one big directory for all the mapsheets	     (p==province)  
# option -c or no option ---> many inventories are listed in the input file and the results will be saved in only one big directory for all these inventories (c==Canada)


my $nbc1=0;
my $nbc2=0;
my %hstd=();
my $inventory_list = $ARGV[0];  #input file in csv format containing the path of the inventory, the inventory name, the version , and the photoyears file path for QC)
my $optiongroups = $ARGV[1];
my $nbargs=scalar(@ARGV);
my $std_version="";
my $frequencies;
#si le nom de l'inventaire est vide, tu sors
if ($inventory_list eq "") {
  print " \n Usage: ./INVENTORIES_conv_fmus.pl  \"file of inventories list\"   \n"; exit;
}


if($nbargs==1 ||  $optiongroups eq "-m"){$optiongroups=0;}
elsif($optiongroups eq "-p"){$optiongroups=1; printf("option p selected! one single result file for all mapsheets\n");}
elsif($optiongroups eq "-c"){$optiongroups=2;}
else {
  print " \n  unrecognised option  $optiongroups  \n"; exit;
}

open (inv_rep_list, "$inventory_list") || die "\n Error: on beginning Could not open  $inventory_list file!\n";


my %htable=(); 
my %hPROVit=();
my %qcftable=();  #hash table containing the mapsheet name as key and the PhotoYear as value
my %qcboreal=(); 
my %onboreal=(); 
my %abftable=();
my %onftable=();
my %borealfreq=();
my $TotalPROVit=0; 
my $workingdir = getcwd; #this is the current directory
my %hfmutable=();  #hash table containing the fmu names   eg QC_0001, QC_0002, QC_0003
my $In_rep; my $In_inventory; my $where; 
my $province; my $hdrinfos; my $testwhere;
my @flist; my $nbtab; my $provcod; 
my $numfmu; my $keys; my $iters_k;  my $rem_newcod;
my $errfile; my $Out_CAS; my $spfers; my $specslogfile; my $MSTANDSlogfile;
my $total=0;
my $borealtable;
my $ncas=0;
my $nlyr=0;
my $nnfl=0;
my $ndst=0;
my $neco=0;
my $ndstonly=0;
my $necoonly=0;
my $nbasprev=0;
my $nflareatotal=0;
my $total2=0;
my $freqname;
#processing the exported data  
my $nbngrprev=0;
my %ProvSP_table=();
my $nflfreqs;
my $speciestable;
my %spfreqprev=();
 $borealtable="";

my $missed_area=0;

$speciestable="H:/Melina/CAS/Conversion/Conversion/CASFRI_SpeciesTable_v4.csv";
#$speciestable="/home/kbenedicte/conversion_proc/NewModules082011/Modifs_NewCodingCASID/miseajour/masterqc4_species_table.csv";
while(<inv_rep_list>) {

	  #processing each line of the input file

	 

	  $In_rep= $_;
	  #chop ($In_rep);
	  my @inputdata=split(",", $In_rep);
	  ($where, $province, $std_version, $hdrinfos, $borealtable) = split(",", $In_rep);

	  next if ($where =~ /^\#/);

	  my $ct=scalar(@inputdata);

	  chdir $where or die "Wrong command of path >>$where<<  from >>$In_rep<<\n";
	  $testwhere = getcwd;

	  opendir(DIR, $where) || die "can't opendir $where: $!";
	  rewinddir DIR;

	  #now in the exported data directory ; @flist is the array of csv file in the inventory

	  @flist=();
	  %hfmutable=();
	  if ($province eq "YT"  || $province eq "SK" || $province eq "MB" || $province eq "NS" || $province eq "NL" || $province eq "BC" || $province eq "NT" || $province eq "ON" || $province eq "PANP"|| $province eq "PE"||$province eq "WBNP"|| $province eq "QC" || $province eq "AB"|| $province eq "NB") {
  	  				@flist = grep { !/photo\.csv$/ && !/\.doc$/ && !/^\./ && !/\.xml$/ && !/PhotoYear\.csv$/ && !/photoYear\.csv$/ && !/photoyear\.csv$/} readdir(DIR); print"read\n";
		}
	  elsif ($province eq "MBPRE97") {
  	  				@flist = grep { /\.csv$/ } readdir(DIR);
		}
	  else {			
					@flist = grep { /\.txt$/ } readdir(DIR);
		}
          closedir DIR;
	
	  $nbtab=scalar(@flist);
	  print("nb files = $nbtab first file to read = $flist[0] \n"); 

	  %ProvSP_table = LoadSpeciesTable($province, $std_version, $speciestable); 
	 #foreach my $spk (keys %ProvSP_table){
	 #	print  " species code " ,$spk,  " translation=", $ProvSP_table{$spk},"\n";
	 #}

	 if ($province eq "QC" ) 
	 { #reading the Photoyears file into the hash table  (%qcftable)
	
		#open (INVsheets, "$hdrinfos") || die "\n Error: Could not open file of QC sheets $hdrinfos !\n";
		#my $csv = Text::CSV_XS->new();
		#my $nothing=<INVsheets>;  #drop header line
 		#while(<INVsheets>) {
			#	if ($csv->parse($_)) {
				#	 my @QCS_Record =();
        			#	 @QCS_Record = $csv->fields();  
				#	 my $qckeys=$QCS_Record[0];
				#	 $qcftable{$qckeys}=$QCS_Record[1];	
				#		#print("fFILE no = $qckeys , age = $QCS_Record[1]\n");
				#} 
				#else {
          			#	my $err = $csv->error_input;
         			#	print "Failed to parse line: $err"; exit(1);
      				# }	
	 	#}
		#close(INVsheets);
		#boreal table
		#if($borealtable ne ""){
		if($ct == 6 ){
			open (INVsheets, "$borealtable") || die "\n Error: Could not open file of QC sheets $borealtable !\n";
			my $csv2 = Text::CSV_XS->new();
			my $nothing2=<INVsheets>;  #drop header line
 			while(<INVsheets>) {
				if ($csv2->parse($_)) {
					 my @QCS_Record2 =();
        				 @QCS_Record2 = $csv2->fields();  
					 my $qckeys2=$QCS_Record2[0];
					 $qcboreal{$qckeys2}++;
						#print("casid = $qckeys2 , occurs = $qcboreal{$qckeys2}\n");exit;
				} 
				else {
          				my $err2 = $csv2->error_input;
         				print "Failed to parse line: $err2"; exit(1);
      				 }	
	 		}
			close(INVsheets);
		}
	}

 if ( $province eq "ON") {
	
 	 
	$onftable{"MU012"}=2002;
	$onftable{"MU030"}=2004; 
	$onftable{"MU040"}=2004;
	$onftable{"MU060"}=2004;
	$onftable{"MU067"}=2002;
	$onftable{"MU120"}=2004;
	$onftable{"MU130"}=2002;
	$onftable{"MU140"}=2006;
	$onftable{"MU150"}=2003;
	$onftable{"MU175"}=1999;
	$onftable{"MU177"}=2004;
	$onftable{"MU178"}=2004;
	$onftable{"MU210"}=2004;
	$onftable{"MU220"}=2006;
	$onftable{"MU230"}=2002;
	$onftable{"MU260"}=2004;
	$onftable{"MU280"}=2006;
	$onftable{"MU350"}=2003;
	$onftable{"MU360"}=2006;
	$onftable{"MU370"}=2004;
	$onftable{"MU375"}=2004;
	$onftable{"MU390"}=2004;
	$onftable{"MU405"}=2000;
	$onftable{"MU415"}=2004;
	$onftable{"MU421"}=2004;
	$onftable{"MU438"}=2004;
	$onftable{"MU444"}=2004;
	$onftable{"MU451"}=2005;
	$onftable{"MU490"}=2004;
	$onftable{"MU509"}=2004;
	$onftable{"MU535"}=1999;
	$onftable{"MU565"}=2004;
	$onftable{"MU601"}=1999;
	$onftable{"MU615"}=2004;
	$onftable{"MU644"}=2004;
	$onftable{"MU680"}=2004;
	$onftable{"MU702"}=2004;
	$onftable{"MU754"}=2004;
	$onftable{"MU780"}=2006;
	$onftable{"MU796"}=2000;
	$onftable{"MU840"}=2003;
	$onftable{"MU851"}=2004;
	$onftable{"MU853"}=2004;
	$onftable{"MU889"}=2004;
	$onftable{"MU898"}=2004;
	$onftable{"MU930"}=2000;
	$onftable{"MU970"}=0;
	$onftable{"MU993"}=0;

	#if($borealtable ne ""){
	if($ct == 6 ){
		open (INVsheets, "$borealtable") || die "\n Error: Could not open file of ON sheets $borealtable !\n";
		my $csv3 = Text::CSV_XS->new();
		my $nothing3=<INVsheets>;  #drop header line
 		while(<INVsheets>) {
				if ($csv3->parse($_)) {
					 my @ON_Record3 =();
        				 @ON_Record3 = $csv3->fields();  
					 my $onkeys3=$ON_Record3[0];
					 $onboreal{$onkeys3}++;
						#print("casid = $qckeys2 , occurs = $qcboreal{$qckeys2}\n");exit;
				} 
				else {
          				my $err3 = $csv3->error_input;
         				print "Failed to parse line: $err3"; exit(1);
      				 }	
	 	}
		close(INVsheets);
	}	
}
	 
	# return into exported data
	foreach my $elt (@flist){
		my ($eltn)= split(/\./, $elt);
		# commented  on the 04-08-2011 because of the new CAS_ID coding
		#($provcod, $numfmu)= split(/_/, $eltn);   #keep only the 1st (PROV) and 2d parts (HEADER_ID) of the  name 
		#$keys=$provcod."_".$numfmu;
		($keys, $rem_newcod)= split(/-/, $eltn); 
		my $verif = split(/_/, $keys);
		if($verif >2)
		{
			#case MB_GOV, SK, QC
			my ($keys1, $keys2, $rem_newcod)= split(/_/, $keys); 
			$keys = join ("_", $keys1, $keys2);
		}
		$hfmutable{$keys}++; #incrementation hash table
	 }

	
	my $province_stdv=$province."_".$std_version;

	chdir $workingdir;
 	mkdir $province, 0777 unless chdir $province;     #create the directory $province if it does not exist
	chdir $province;
	mkdir $province_stdv, 0777; # create a standard folder in the province folder
 	chdir $province_stdv;
	my $CURworkingdir = getcwd;


	foreach my $k (keys %hfmutable)
	{ 	
		#for each fmu in the inventory , eg:  QC_0001, QC_0003
		my $prov_cod_name=$k;   
		$prov_cod_name=~ tr/a-z/A-Z/;  # converse as an uppercase

 		chdir $CURworkingdir;
 
		if($optiongroups==0)
		{
			#create the mapsheet result directory when optiongroups= "-m"
			mkdir $prov_cod_name, 0777;
			chdir $prov_cod_name;
		}
 		my $pathNgrp = getcwd;  #in which directory are we

		$iters_k=0;


    	foreach my $fname (@flist) 
    	{
 
			next if($fname !~ m/^$k/);   #skip this csv file if it does not belong to the current fmu
 			
			$In_inventory=$where."/".$fname;   #full path of the exported csv file
			 
			# Here you try to isolated the mapsheet by removing Prov, Header,...
	 		$Out_CAS = $fname;   #output directory
			$Out_CAS =~ s/\.txt$//g;   #in variable $Out_CAS substitute/replace (s) every ".txt" at the end($)  of the variable by nothing (//) 
			$Out_CAS =~ s/\.csv$//g; 
			 
			$_ = $Out_CAS ; tr/a-z/A-Z/; $Out_CAS  = $_;

			#next if( $province eq "QC" && $std_version eq "4th" && $Out_CAS  ne $k); 
	
			if($Out_CAS  ne $k)
			{   #see in QC and NL for eg

				$Out_CAS =~ s/^$k//;   #substracting the fmu name int that variable 
				$Out_CAS =~ s/^_//;
				# added on the 04-08-2011 because of the new CAS_ID coding
 			  	$Out_CAS =~ s/^-//;
			}
			print " \n $fname sera affiche dans $Out_CAS\n"; 
			$iters_k=$iters_k+1;
			$testwhere = getcwd;
			$freqname=$CURworkingdir."/frequencies-logs.txt";
	 		$errfile=$CURworkingdir."/errors-logs.txt"; 
	 		$specslogfile=$CURworkingdir."/Species_Translation_Errors.log"; 
			$MSTANDSlogfile=$CURworkingdir."/Missing_Stands.log"; 
			$spfers=$CURworkingdir."/Species_frequency_table.txt";
			# if ($province eq "QC" || $province eq "ON"  ) {$nflfreqs=$CURworkingdir."/Nfl_frequency-table.txt";}
	 		$htable{$errfile}++;
			
			# Add information in the log table	
	 		if($htable{$errfile} > 1) 
	 		{
				open (ERRS, ">>$errfile") || die "\n Error: Could not open error file $errfile !\n";	
				open (SPERRSFILE, ">>$spfers") || die "\n Error: Could not open error file $spfers !\n";
				# if ($province eq "QC" || $province eq "ON"  ) {
				#	open (NFLFREQFILE, ">>$nflfreqs") || die "\n Error: Could not open error file $nflfreqs !\n";
				# }
	 		}
	 		# If the lof file doesn't exist, create it
	  		else 
	  		{
			 	open (ERRS, ">$errfile") || die "\n Error: Could not  create $errfile file!\n"; 
			 	open (SPERRSFILE, ">$spfers") || die "\n Error: Could not open error file $spfers !\n";
			 	open (SPECSLOGFILE, ">$specslogfile") || die "\n Error: Could not open error file $specslogfile !\n";
 				open (MSTANDSLOG, ">$MSTANDSlogfile") || die "\n Error: Could not open error file $MSTANDSlogfile !\n";
			 	#if ($province eq "QC" || $province eq "ON"  ) {
				#open (NFLFREQFILE, ">$nflfreqs") || die "\n Error: Could not open error file $nflfreqs !\n";
 			 	#} 
	 		} 

	 		print ERRS "in file $In_inventory \n";
			close(ERRS);
			print SPERRSFILE "in file $In_inventory \n";
			close (SPERRSFILE);
			close(SPECSLOGFILE); 
			close(MSTANDSLOG);
			# if ($province eq "QC" || $province eq "ON"  ) {
			# 	print NFLFREQFILE "in file $In_inventory \n";
			#  	close (NFLFREQFILE);
			# } 

			if($optiongroups==0  && $Out_CAS ne $k)
			{  
				mkdir $Out_CAS, 0777;
			 	chdir $Out_CAS or die "Wrong command of path >>$Out_CAS<<  \n";
			}
			elsif($optiongroups==2){$pathNgrp=$workingdir; }


			# Here is where you call the module for every provinces
	 		 if ($province eq "QC" && $std_version eq "3rd") {
					$hPROVit{$province}++;
					$TotalPROVit++;
					my $photoYear=""; #$qcftable{$Out_CAS}; # if i want the result in only one table (6 extensions)
#print "$Out_CAS,,, $photoYear\n"; exit;
					#call to QC conversion module. You will need to add inofrmation about photoyear for provinces that did not have photoyear in the FI
					#%spfreqprev=
					QCinv_to_CAS($In_inventory, \%ProvSP_table, $Out_CAS, $errfile, $hPROVit{$province}, \@tabSpec,$optiongroups, $pathNgrp, $TotalPROVit, $photoYear, $spfers, \%spfreqprev, \$ncas, \$nlyr,\$nnfl,\$ndst, \$neco, \$ndstonly, \$necoonly,\$nflareatotal, $specslogfile); #\%spfreqprev for nfl freq table
$total= $nlyr+$nnfl+$ndst+$neco;
$total2=$nlyr+$nnfl+$ndstonly+$necoonly;
#print "$ncas, $nlyr, $nnfl,  $ndst($ndstonly), $neco($necoonly), $total($total2), TOTAL nfl area = $nflareatotal\n";
			}

 elsif ($province eq "QC" && $std_version eq "4th") {
					$hPROVit{$province}++;
					$TotalPROVit++;
					my $photoYear=""; #$qcftable{$Out_CAS}; 
					QC4inv_to_CAS($In_inventory, \%ProvSP_table, $Out_CAS, $errfile, $hPROVit{$province}, \@tabSpec,$optiongroups, $pathNgrp, $TotalPROVit, $photoYear, $spfers, \%spfreqprev, \$ncas, \$nlyr,\$nnfl,\$ndst, \$neco, \$ndstonly, \$necoonly,\$nflareatotal, $specslogfile, \%hstd); #\%spfreqprev for nfl freq table
$total= $nlyr+$nnfl+$ndst+$neco;
$total2=$nlyr+$nnfl+$ndstonly+$necoonly;
#print "$ncas, $nlyr, $nnfl,  $ndst($ndstonly), $neco($necoonly), $total($total2), TOTAL nfl area = $nflareatotal\n";
					}
        		elsif ($province eq "AB") {
					$hPROVit{$province}++;
					$TotalPROVit++;   my($provcodab, $numfmu)= split(/_/, $k);
					ABinv_to_CAS($In_inventory, \%ProvSP_table, $Out_CAS, $errfile, $hPROVit{$province},$optiongroups, $pathNgrp, $TotalPROVit, $numfmu, $iters_k, $hdrinfos, $std_version, $spfers, \%spfreqprev, \$ncas, \$nlyr,\$nnfl,\$ndst, \$neco, \$ndstonly, \$necoonly, $specslogfile);
          		}
			elsif ($province eq "MB" && $std_version eq "FLI") {
					$hPROVit{$province}++;
					$TotalPROVit++;
					#%spfreqprev=
					MBFLIinv_to_CAS($In_inventory, \%ProvSP_table, $Out_CAS, $errfile, $hPROVit{$province},$optiongroups, $pathNgrp, $TotalPROVit, $std_version,$spfers,\%spfreqprev, \$ncas, \$nlyr,\$nnfl,\$ndst, \$neco, \$ndstonly, \$necoonly, \$nbasprev, $specslogfile,$MSTANDSlogfile);
print "total nbas=$nbasprev\n";
$total= $nlyr+$nnfl+$ndst+$neco;
$total2=$nlyr+$nnfl+$ndstonly+$necoonly;
print "$ncas, $nlyr, $nnfl,  $ndst($ndstonly), $neco($necoonly), $total($total2)\n";
          		}
          		elsif ($province eq "MB" && $std_version eq "FLI7") {
					$hPROVit{$province}++;
					$TotalPROVit++;
					#%spfreqprev=
					MBFLIHRinv_to_CAS($In_inventory, \%ProvSP_table, $Out_CAS, $errfile, $hPROVit{$province},$optiongroups, $pathNgrp, $TotalPROVit, $std_version,$spfers,\%spfreqprev, \$ncas, \$nlyr,\$nnfl,\$ndst, \$neco, \$ndstonly, \$necoonly, \$nbasprev, $specslogfile,$MSTANDSlogfile);
print "total nbas=$nbasprev\n";
$total= $nlyr+$nnfl+$ndst+$neco;
$total2=$nlyr+$nnfl+$ndstonly+$necoonly;
print "$ncas, $nlyr, $nnfl,  $ndst($ndstonly), $neco($necoonly), $total($total2)\n";
          		}
			elsif ($province eq "MB" && $std_version eq "") {
					$hPROVit{$province}++;
					$TotalPROVit++;
					#%spfreqprev=
					MBfrifliinv_to_CAS($In_inventory, \%ProvSP_table, $Out_CAS, $errfile, $hPROVit{$province},$optiongroups, $pathNgrp, $TotalPROVit, $std_version,$spfers,\%spfreqprev, \$ncas, \$nlyr,\$nnfl,\$ndst, \$neco, \$ndstonly, \$necoonly, \$nbasprev, $specslogfile,$MSTANDSlogfile);
print "total nbas=$nbasprev\n";
$total= $nlyr+$nnfl+$ndst+$neco;
$total2=$nlyr+$nnfl+$ndstonly+$necoonly;
print "$ncas, $nlyr, $nnfl,  $ndst($ndstonly), $neco($necoonly), $total($total2)\n";
          		}
			elsif ($province eq "MB" && $std_version eq "PRE97") {  
					$hPROVit{$province}++;
					$TotalPROVit++;
					MBPRE97inv_to_CAS($In_inventory, \%ProvSP_table, $Out_CAS, $errfile, $hPROVit{$province},$optiongroups, $pathNgrp, $TotalPROVit, $spfers, \%spfreqprev, \$ncas, \$nlyr,\$nnfl,\$ndst, \$neco, \$ndstonly, \$necoonly, \$nbasprev, \$nbngrprev, $specslogfile,$MSTANDSlogfile);
print "total nbas=$nbasprev, nbngr=$nbngrprev\n";
$total= $nlyr+$nnfl+$ndst+$neco;
$total2=$nlyr+$nnfl+$ndstonly+$necoonly;
print "$ncas, $nlyr, $nnfl,  $ndst($ndstonly), $neco($necoonly), $total($total2)\n";
 
          		}
			elsif ($province eq "MB" && $std_version eq "FRI") {  
					$hPROVit{$province}++;
					$TotalPROVit++;
					MBGOVinv_to_CAS($In_inventory, \%ProvSP_table, $Out_CAS, $errfile, $hPROVit{$province},$optiongroups, $pathNgrp, $TotalPROVit, $spfers,$hdrinfos, \%spfreqprev, \$ncas, \$nlyr,\$nnfl,\$ndst, \$neco, \$ndstonly, \$necoonly, \$nbasprev, $specslogfile,$MSTANDSlogfile, \$nbc1,\$nbc2,);
print "total nbas=$nbasprev\n";
$total= $nlyr+$nnfl+$ndst+$neco;
$total2=$nlyr+$nnfl+$ndstonly+$necoonly;
print "$ncas, $nlyr, $nnfl,  $ndst($ndstonly), $neco($necoonly), $total($total2), upfcode =$nbc1, JP100=$nbc2\n";
          		}
			elsif ($province eq "BC") {
					$hPROVit{$province}++;
					$TotalPROVit++;
					BCinv_to_CAS($In_inventory, \%ProvSP_table, $Out_CAS, $errfile, $hPROVit{$province},$optiongroups, $pathNgrp, $TotalPROVit,  $spfers, \%spfreqprev, \$ncas, \$nlyr,\$nnfl,\$ndst, \$neco, \$ndstonly, \$necoonly, $specslogfile,$MSTANDSlogfile, $hdrinfos, 
\$missed_area);
$total= $nlyr+$nnfl+$ndst+$neco;
$total2=$nlyr+$nnfl+$ndstonly+$necoonly;
print "$ncas, $nlyr, $nnfl,  $ndst($ndstonly), $neco($necoonly), $total($total2)\n";
          		}
			elsif ($province eq "YT") {
					$hPROVit{$province}++;
					$TotalPROVit++;
					YTinv_to_CAS($In_inventory, \%ProvSP_table, $Out_CAS, $errfile, $hPROVit{$province},$optiongroups, $pathNgrp, $TotalPROVit, $spfers, \%spfreqprev, \$ncas, \$nlyr, \$nnfl,\$ndst, \$neco, \$ndstonly, \$necoonly, $specslogfile);
$total= $nlyr+$nnfl+$ndst+$neco;
$total2=$nlyr+$nnfl+$ndstonly+$necoonly;
#print "$ncas, $nlyr, $nnfl,  $ndst, $neco, $total\n";
print "$ncas, $nlyr, $nnfl,  $ndst($ndstonly), $neco($necoonly), $total($total2)\n";
          		}
			elsif ($province eq "SK"  && $std_version eq "SFVI") {
					$hPROVit{$province}++;
					$TotalPROVit++;
					SKinv_to_CAS($In_inventory, \%ProvSP_table, $Out_CAS, $errfile, $hPROVit{$province},$optiongroups, $pathNgrp, $TotalPROVit, $spfers, $std_version, \%spfreqprev, \$ncas, \$nlyr,\$nnfl,\$ndst, \$neco, \$ndstonly, \$necoonly, $specslogfile);
$total= $nlyr+$nnfl+$ndst+$neco;
$total2=$nlyr+$nnfl+$ndstonly+$necoonly;
print "$ncas, $nlyr, $nnfl,  $ndst($ndstonly), $neco($necoonly), $total($total2)\n";
          		}
          	elsif ($province eq "SK"  && $std_version eq "SFVI_MISTIK") {
					$hPROVit{$province}++;
					$TotalPROVit++;
					SKMISTIKinv_to_CAS($In_inventory, \%ProvSP_table, $Out_CAS, $errfile, $hPROVit{$province},$optiongroups, $pathNgrp, $TotalPROVit, $spfers, $std_version, \%spfreqprev, \$ncas, \$nlyr,\$nnfl,\$ndst, \$neco, \$ndstonly, \$necoonly, $specslogfile);
$total= $nlyr+$nnfl+$ndst+$neco;
$total2=$nlyr+$nnfl+$ndstonly+$necoonly;
print "$ncas, $nlyr, $nnfl,  $ndst($ndstonly), $neco($necoonly), $total($total2)\n";
          		}
			elsif ($province eq "SK"  && $std_version eq "UTM") {
					$hPROVit{$province}++;
					$TotalPROVit++;
					SKUTMinv_to_CAS($In_inventory, \%ProvSP_table, $Out_CAS, $errfile, $hPROVit{$province},$optiongroups, $pathNgrp, $TotalPROVit, $spfers, $std_version, \%spfreqprev, \$ncas, \$nlyr,\$nnfl,\$ndst, \$neco, \$ndstonly, \$necoonly, $specslogfile);
$total= $nlyr+$nnfl+$ndst+$neco;
$total2=$nlyr+$nnfl+$ndstonly+$necoonly;
print "$ncas, $nlyr, $nnfl,  $ndst($ndstonly), $neco($necoonly), $total($total2)\n";
          		}
			elsif ($province eq "NL") {
					$hPROVit{$province}++;
					$TotalPROVit++;
					NLinv_to_CAS($In_inventory, \%ProvSP_table, $Out_CAS, $errfile, $hPROVit{$province},$optiongroups, $pathNgrp, $TotalPROVit, $spfers,\%spfreqprev, \$ncas, \$nlyr,\$nnfl,\$ndst, \$neco, \$ndstonly, \$necoonly, $specslogfile);
          		}
			elsif ($province eq "NT") {
					$hPROVit{$province}++;
					$TotalPROVit++;
					NTinv_to_CAS($In_inventory, \%ProvSP_table, $Out_CAS, $errfile, $hPROVit{$province},$optiongroups, $pathNgrp, $TotalPROVit, $spfers,\%spfreqprev, \$ncas, \$nlyr,\$nnfl,\$ndst, \$neco, \$ndstonly, \$necoonly, $specslogfile);
$total= $nlyr+$nnfl+$ndst+$neco;
$total2=$nlyr+$nnfl+$ndstonly+$necoonly;
print "$ncas, $nlyr, $nnfl,  $ndst($ndstonly), $neco($necoonly), $total($total2)\n";
          		}
			elsif ($province eq "NS") {
					$hPROVit{$province}++;
					$TotalPROVit++;
					NSinv_to_CAS($In_inventory, \%ProvSP_table, $Out_CAS, $errfile, $hPROVit{$province},$optiongroups, $pathNgrp, $TotalPROVit, $spfers, \%spfreqprev, \$ncas, \$nlyr,\$nnfl,\$ndst, \$neco, \$ndstonly, \$necoonly, $specslogfile);
$total= $nlyr+$nnfl+$ndst+$neco;
$total2=$nlyr+$nnfl+$ndstonly+$necoonly;
print "$ncas, $nlyr, $nnfl,  $ndst($ndstonly), $neco($necoonly), $total($total2)\n";
          		}
			elsif ($province eq "PE") {
					$hPROVit{$province}++;
					$TotalPROVit++;
					PEinv_to_CAS($In_inventory, \%ProvSP_table, $Out_CAS, $errfile, $hPROVit{$province},$optiongroups, $pathNgrp, $TotalPROVit, $spfers, \%spfreqprev, \$ncas, \$nlyr, \$nnfl,\$ndst, \$neco, \$ndstonly, \$necoonly, $specslogfile);
$total= $nlyr+$nnfl+$ndst+$neco;
$total2=$nlyr+$nnfl+$ndstonly+$necoonly;
print "$ncas, $nlyr, $nnfl,  $ndst($ndstonly), $neco($necoonly), $total($total2)\n";
          		}
			elsif ($province eq "ON") {
					$hPROVit{$province}++;
					$TotalPROVit++;
					my $ON_Out_CAS=$Out_CAS;
					#$ON_Out_CAS=~ s/^(\D+)//g;
					my $PIYear=$onftable{$ON_Out_CAS};
					#(%spfreqprev)=
					ONinv_to_CAS($In_inventory, \%ProvSP_table, $Out_CAS, $errfile, $hPROVit{$province},$optiongroups, $pathNgrp, $TotalPROVit, $std_version,$PIYear, $spfers, \%spfreqprev,  \$ncas, \$nlyr,\$nnfl,\$ndst, \$neco, \$ndstonly, \$necoonly, \$nflareatotal,  $specslogfile,$hdrinfos);#\%onboreal, \%borealfreq, $nflfreqs,
$total= $nlyr+$nnfl+$ndst+$neco;
$total2=$nlyr+$nnfl+$ndstonly+$necoonly;
print "$ncas, $nlyr, $nnfl,  $ndst($ndstonly), $neco($necoonly), $total($total2)\n";
          		}
			elsif ($province eq "WBNP") {
					$hPROVit{$province}++;
					$TotalPROVit++;
					WBNPinv_to_CAS($In_inventory, \%ProvSP_table, $Out_CAS, $errfile, $hPROVit{$province},$optiongroups, $pathNgrp, $TotalPROVit,$spfers, \%spfreqprev, \$ncas, \$nlyr, \$nnfl,\$ndst, \$neco, \$ndstonly, \$necoonly, $specslogfile);
          		}
			elsif ($province eq "PANP") {
					$hPROVit{$province}++;
					$TotalPROVit++;
					PANPinv_to_CAS($In_inventory, \%ProvSP_table, $Out_CAS, $errfile, $hPROVit{$province},$optiongroups, $pathNgrp, $TotalPROVit,$spfers, \%spfreqprev, \$ncas, \$nlyr, \$nnfl,\$ndst, \$neco, \$ndstonly, \$necoonly, $specslogfile);
          		}
			elsif ($province eq "NB") {
					$hPROVit{$province}++;
					$TotalPROVit++;
					NBinv_to_CAS($In_inventory, \%ProvSP_table, $Out_CAS, $errfile, $hPROVit{$province},$optiongroups, $pathNgrp, $TotalPROVit, $spfers, \%spfreqprev, \$ncas, \$nlyr,\$nnfl,\$ndst, \$neco, \$ndstonly, \$necoonly, $specslogfile);
          		}
			chdir $testwhere;

		}
#foreach my $k (keys %spfreqprev){
	 	#print "frequency of " ,$k,  " is ", $spfreqprev{$k},"\n";
		#print "invalid code " ,$k,  " found ", $herror{$k}," times\n";
 # }
my $lost= $ncas-$total2;
#open (SPERRSFILE, ">>$spfers") || die "\n Error: Could not open error file $errfile !\n";
#print SPERRSFILE "nb records in .cas=$ncas, lyr=$nlyr, nfl=$nnfl,  dst=$ndst(uniq to dst=$ndstonly), eco=$neco(uniq to $necoonly), total $total(total uniq $total2) lost records = $lost\n";
#close (SPERRSFILE);

	}

 }

#if ($province eq "MB" && $std_version eq "FRI") {  
	#my $freqname=$errfile."freq";
	#open (ERRS, ">>$freqname") || die "\n Error: Could not open $freqname file!\n";

	#foreach my $k (keys %$frequencies){
	 #	print ERRS "found " ,$k,  " found ", $$frequencies{$k}," times\n";
		#print "invalid code " ,$k,  " found ", $herror{$k}," times\n";
	# }
	#close (ERRS);
#}

close(inv_rep_list);

