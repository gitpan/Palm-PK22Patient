package Palm::PK22Patient;
# Palm::PK22Patient.pm
#
# Perl class for dealing with Palm PatientKeeper 2.2 format databases.
#
# Copyright (c) 2003 William Herrera. All rights reserved.
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself. Also, see the CREDITS.
#

sub Version { $VERSION; }
$VERSION = sprintf("%d.%02d", q$Revision: 0.10 $ =~ /(\d+)\.(\d+)/);

use strict;
use Palm::Raw();
use vars qw( $VERSION @ISA );
@ISA = qw( Palm::Raw Palm::StdAppInfo );

sub import
{
	&Palm::PDB::RegisterPDBHandlers(__PACKAGE__,
		"pk22"
		);
}

sub new
{
	my $classname	= shift;
	my $self	= $classname->SUPER::new(@_);
			# Create a generic PDB. No need to rebless it,
			# though.

	$self->{name} = "PK22PatientDB";	# Default
	$self->{creator} = "pk22";
	$self->{type} = 0x0A;
	$self->{attributes}{resource} = 0;
				# The PDB is not a resource database by
				# default, but it's worth emphasizing,
				# since PK22PatientDB is explicitly not a PRC.
	$self->{appinfo} = Palm::StdAppInfo->newStdAppInfo();
					# Standard AppInfo block
	$self->{sort} = undef;	# Empty sort block

	$self->{records} = [];	# Empty list of records

	return $self;
}


sub new_Record
{
	my $classname = shift;
	my $retval = $classname->SUPER::new_Record(@_);
	my $record;
	my $record->{unknown_fixedformat12chars} = "\0\0\0\0\0\0\0\0\0\0\0\0";
	$record->{lastname} = undef;
	$record->{firstname} = undef;
	$record->{id} = undef;
	$record->{race} = undef;
	$record->{age} = undef;
	$record->{bed} = undef;
	$record->{diagnosis} = undef;

	$record->{CC} = undef;
	$record->{PMH} = undef;
	$record->{PSH} = undef;
	$record->{SH} = undef;

	$record->{assessment} = undef;
	$record->{plan} = undef;

	$record->{PE_Gen} = undef;
	$record->{PE_HEENT} = undef;
	$record->{PE_Neck} = undef;
	$record->{PE_Resp} = undef;
	$record->{PE_CV} = undef;
	$record->{PE_Abd} = undef;
	$record->{PE_GU} = undef;
	$record->{PE_Ext} = undef;
	$record->{PE_MusSk} = undef;
	$record->{PE_Breast} = undef;
	$record->{PE_Neuro} = undef;
	$record->{PE_Other} = undef;

	$record->{primaryMD}  = undef;
	$record->{consulting}  = undef;
	$record->{team}  = undef;
	$record->{xcover}  = undef;
	$record->{t_gt}  = undef;
	$record->{notes}  = undef;
	$record->{unknown_Z} = undef;

	return $retval;
}

# ParseAppInfoBlock
# Parse the AppInfo block for PK22Patient databases.
# There appears to be one byte of padding at the end.
sub ParseAppInfoBlock
{
	my $self = shift;
	my $data = shift;
	my $startOfWeek;
	my $i;
	my $appinfo = {};
	my $std_len;

	# Get the standard parts of the AppInfo block
	$std_len = &Palm::StdAppInfo::parse_StdAppInfo($appinfo, $data);

	$data = substr $data, $std_len;		# Remove the parsed part

	return $appinfo;
}

sub PackAppInfoBlock
{
	my $self = shift;
	my $retval;

	# Pack the standard part of the AppInfo block
	$retval = &Palm::StdAppInfo::pack_StdAppInfo($self->{appinfo});

	# And the application-specific stuff
	$retval .= pack("x2 C x", $self->{appinfo}{start_of_week});

	return $retval;
}

sub ParseRecord
{
	my $self = shift;
	my %record = @_;
	my $data = $record{data};
	$record{unknown_fixedformat12chars} = substr($data, 0, 12);
	$record{discharged} = 1 if substr($data, 0 , 1) & 0xC == 0xC;
	my $strings = substr($data, 12);
	(
	$record{lastname},
	$record{firstname},
	$record{id},
	$record{race},
	$record{age},
	$record{bed},
	$record{diagnosis},
	$record{CC},
	$record{PMH},
	$record{PSH},
	$record{SH},
	$record{assessment},
	$record{plan},
	$record{PE_Gen},
	$record{PE_HEENT},
	$record{PE_Neck},
	$record{PE_Resp},
	$record{PE_CV},
	$record{PE_Abd},
	$record{PE_GU},
	$record{PE_Ext},
	$record{PE_MusSk},
	$record{PE_Breast},
	$record{PE_Neuro},
	$record{PE_Other},
	$record{primaryMD},
	$record{consulting},
	$record{team},
	$record{xcover},
	$record{t_gt},
	$record{notes},
	$record{unknown_Z}
	) = split '\0', $strings;
    return \%record;
}

sub PackRecord
{
	my $self = shift;
	my $record = shift;
	my $packstr =
		"a12 " .
		"a* a* a* a* a* a* a* a* " .
		"a* a* a* a* a* a* a* a* " .
		"a* a* a* a* a* a* a* a* " .
		"a* a* a* a* a* a* a* a*";
	substr($record->{unknown_fixedformat12chars}, 0 , 1) |= 0xC if($record->{discharged});
	my $retval = pack $packstr,
	$record->{unknown_fixedformat12chars},
	$record->{lastname},
	$record->{firstname},
	$record->{id},
	$record->{race},
	$record->{age},
	$record->{bed},
	$record->{diagnosis},
	$record->{CC},
	$record->{PMH},
	$record->{PSH},
	$record->{SH},
	$record->{assessment},
	$record->{plan},
	$record->{PE_Gen},
	$record->{PE_HEENT},
	$record->{PE_Neck},
	$record->{PE_Resp},
	$record->{PE_CV},
	$record->{PE_Abd},
	$record->{PE_GU},
	$record->{PE_Ext},
	$record->{PE_MusSk},
	$record->{PE_Breast},
	$record->{PE_Neuro},
	$record->{PE_Other},
	$record->{primaryMD},
	$record->{consulting},
	$record->{team},
	$record->{cover},
	$record->{t_gt},
	$record->{notes},
	$record->{unknown_Z};
	return $retval;
}

# end of code in package
1;

__END__

=head1 NAME

Palm::PK22Patient -- interface to the PatientKeeper patient database

=head1 SYNOPSIS

    use Palm::PDB;
    use Palm::PK22Patient;

    $pdb = new Palm::PDB;
    $pdb->Load("/mypalmsyncdir/backup/PK22-PatientDB.pdb");

    # Manipulate records in $pdb

    $pdb->Write("myotherfile.pdb");

=head1 DESCRIPTION

Palm::PK22Patient -- interface to the PatientKeeper patient database

PatientKeeper is a Palm OS program for physician tracking of hospital patients. Much of this data is stored in the Palm PDB file PK22-PatientDB.pdb, which is backed up when the Palm is synced to the base computer. This perl module is for manipulation of such data.

An example program, PK22toCSV.pl, is included. This program converts PK22Patient data to a CSV file.

=head1 KNOWN PROBLEMS AND LIMITATIONS

Only interfaces with the Patient database, not the other PatientKeeper data.

This is ALPHA software. If it corrupts or destroys your data, do not be surprised. Under no circumstances should you trust data touched by this program to be trustworthy for clinical decision making. (There now, our malpractice carrier is smiling again :).


=head1 CREDITS

This is an add-on module for the Coldsync p5-Palm modules. If you find bugs, first make sure you have the latest version of Palm::PDB. Try http://cvs.coldsync.org for this.

=head1 AUTHOR

William Herrera <wherrera@skylightview.com>

=cut

