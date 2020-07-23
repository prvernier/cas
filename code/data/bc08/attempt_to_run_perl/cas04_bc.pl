#!/usr/bin/perl -w
use strict;
use Carp ();
local $SIG{__WARN__} = \&Carp::cluck;
use lib 'BC_conversion11';
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
my $inventory_list = "infileBC";  #input file in csv format containing the path of the inventory, the inventory name, the version , and the photoyears file path for QC)
my $optiongroups= "-p";
my $nbargs=1;
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
my $province="BC"; my $hdrinfos; my $testwhere;
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

$speciestable="CASFRI_SpeciesTable_v4.csv";


%ProvSP_table = LoadSpeciesTable($province, $std_version, $speciestable);
#print(%ProvSP_table);

#$In_rep= $_;
#chop ($In_rep);
#my @inputdata=split(",", $In_rep);
#($where, $province, $std_version, $hdrinfos, $borealtable) = split(",", $In_rep);
