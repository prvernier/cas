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

# return into exported data
foreach my $elt (@flist){
my ($eltn)= split(/\./, $elt);
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
}
# If the lof file doesn't exist, create it
else 
{
 	open (ERRS, ">$errfile") || die "\n Error: Could not  create $errfile file!\n"; 
 	open (SPERRSFILE, ">$spfers") || die "\n Error: Could not open error file $spfers !\n";
 	open (SPECSLOGFILE, ">$specslogfile") || die "\n Error: Could not open error file $specslogfile !\n";
	open (MSTANDSLOG, ">$MSTANDSlogfile") || die "\n Error: Could not open error file $MSTANDSlogfile !\n";
} 

print ERRS "in file $In_inventory \n";
close(ERRS);
print SPERRSFILE "in file $In_inventory \n";
close (SPERRSFILE);
close(SPECSLOGFILE); 
close(MSTANDSLOG);

if($optiongroups==0  && $Out_CAS ne $k)
{  
	mkdir $Out_CAS, 0777;
 	chdir $Out_CAS or die "Wrong command of path >>$Out_CAS<<  \n";
}
elsif($optiongroups==2){$pathNgrp=$workingdir; }


# Here is where you call the module for every provinces
elsif ($province eq "BC") {
		$hPROVit{$province}++;
		$TotalPROVit++;
		BCinv_to_CAS($In_inventory, \%ProvSP_table, $Out_CAS, $errfile, $hPROVit{$province},$optiongroups, $pathNgrp, $TotalPROVit,  $spfers, \%spfreqprev, \$ncas, \$nlyr,\$nnfl,\$ndst, \$neco, \$ndstonly, \$necoonly, $specslogfile,$MSTANDSlogfile, $hdrinfos, 
\$missed_area);
$total= $nlyr+$nnfl+$ndst+$neco;
$total2=$nlyr+$nnfl+$ndstonly+$necoonly;
print "$ncas, $nlyr, $nnfl,  $ndst($ndstonly), $neco($necoonly), $total($total2)\n";
	}

chdir $testwhere;

}
my $lost= $ncas-$total2;

}
