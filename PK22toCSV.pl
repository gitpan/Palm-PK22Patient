#!/usr/bin/perl -w

use DBI;
use Carp;
use strict;
use Palm::PDB;
use Palm::StdAppInfo;
use Palm::PK22Patient;

my $pdbfname = $ARGV[0] or
	croak "Usage: perl PK22toCSV.pl <filename, usually PK22-PatientDB.pdb>\n";

my $table = $ARGV[1] || 'PK22PatientCSV';

# set up CSV data table SQL data and query
# use current directory for the csv file
my $dbh = DBI->connect("DBI:CSV:");
$dbh->do("CREATE TABLE $table (
	lastname VARCHAR(100),
	firstname VARCHAR(100),
	id VARCHAR(20),
	race VARCHAR(40),
	age VARCHAR(15),
	bed VARCHAR(30),
	diagnosis VARCHAR(100),
	CC VARCHAR(100),
	PMH VARCHAR(500),
	PSH VARCHAR(500),
	SH VARCHAR(500),
	assessment VARCHAR(500),
	plan VARCHAR(500),
	PE_Gen VARCHAR(500),
	PE_HEENT VARCHAR(500),
	PE_Neck VARCHAR(500),
	PE_Resp VARCHAR(500),
	PE_CV VARCHAR(500),
	PE_Abd VARCHAR(500),
	PE_GU VARCHAR(500),
	PE_Ext VARCHAR(500),
	PE_MusSk VARCHAR(500),
	PE_Breast VARCHAR(500),
	PE_Neuro VARCHAR(500),
	PE_Other VARCHAR(500),
	primaryMD VARCHAR(100),
	consulting VARCHAR(200),
	team VARCHAR(500),
	xcover VARCHAR(100),
	t_gt VARCHAR(10),
	notes VARCHAR(500),
	discharged VARCHAR(2)
	) ");
# build paramaterized insertion query
my $store_query = "INSERT INTO $table VALUES (" .
	"?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, " .
	"?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

# set up Palm PDB
my $pdb = new Palm::PDB;
$pdb->Load($pdbfname);
foreach (@{$pdb->{records}}) {
	print "Storing record with last name $_->{lastname} , id $_->{id} \n";
	$dbh->do($store_query, undef,
	$_->{lastname},
	$_->{firstname},
	$_->{id},
	$_->{race},
	$_->{age},
	$_->{bed},
	$_->{diagnosis},
	$_->{CC},
	$_->{PMH},
	$_->{PSH},
	$_->{SH},
	$_->{assessment},
	$_->{plan},
	$_->{PE_Gen},
	$_->{PE_HEENT},
	$_->{PE_Neck},
	$_->{PE_Resp},
	$_->{PE_CV},
	$_->{PE_Abd},
	$_->{PE_GU},
	$_->{PE_Ext},
	$_->{PE_MusSk},
	$_->{PE_Breast},
	$_->{PE_Neuro},
	$_->{PE_Other},
	$_->{primaryMD},
	$_->{consulting},
	$_->{team},
	$_->{cover},
	$_->{t_gt},
	$_->{notes},
	$_->{discharged}
	);

}


print "\n\nTesting CSV database:\n";
my $last = 'LAST NAME';
my $first = 'FIRST NAME';
my $id = 'ID';
my $bed = 'LOCATION';
my $dc = 'DISCHARGED';
format STDOUT =
@<<<<<<<<<<<<<<< @<<<<<<<<<<<<<<< @<<<<<<<<<<< @<<<<<<<< @<<<<<<<<<<<<<
$last,                 $first,               $id,           $bed,       $dc ? 'DISCHARGED' : 'DISPLAYED'
.

write;
my $sql_query = "SELECT * from $table";
my($sth) = $dbh->prepare($sql_query)
	or die "prepare: " . $dbh->errstr();
$sth->execute
	or die "execute: " . $dbh->errstr();
$sth->bind_col(1, \$last);
$sth->bind_col(2, \$first);
$sth->bind_col(3, \$id);
$sth->bind_col(6, \$bed);
$sth->bind_col(32, \$dc);
while ($sth->fetch) { write }
$sth->finish();

