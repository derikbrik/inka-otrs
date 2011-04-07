# --
# Kernel/System/Stats/Static/InkaCICreatedxMonthCategory.pm - stats module
# Copyright (C) 2011 Juan Manuel Rodriguez
# --
# $Id: InkaCICreatedxMonthCategory.pm $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Stats::Static::InkaCICreatedxMonthCategory;

use strict;
use warnings;
use Kernel::System::InkaStats;

use vars qw(@ISA $VERSION);
$VERSION = qw($Revision: 1.30 $) [1];

sub new {
	my ( $Type, %Param ) = @_;
	# allocate new hash for object
	my $Self = { %Param };
	bless( $Self, $Type );
	# check all needed objects
	for (qw(ConfigObject EncodeObject LogObject DBObject)) {
		die "Got no $_" if ( !$Self->{$_} );
	}
	
    $Self->{StatsObject} = Kernel::System::InkaStats->new(%Param);
	    
	return $Self;
}

sub Param {
	my $Self = shift;

	# 	get current time
	my ($s,$m,$h, $D,$M,$Y) = $Self->{TimeObject}->SystemTime2Date(
		SystemTime => $Self->{TimeObject}->SystemTime(),
	);
	
	# get one month before
	my $SelectedYear = $M == 1 ? $Y - 1 : $Y;
	my $SelectedMonth = $M == 1 ? 12 : $M - 1;
	# 	create possible time selections
	my %Year = map { $_ => $_; } ( $Y - 10 .. $Y );
	my %Month = map { $_ => sprintf( "%02d", $_ ); } ( 1 .. 12 );
	my %DateType = ();
	$DateType{creation_date} = 'creation_date';
	$DateType{acquisition_day} = 'acquisition_day'; 
	my @Params = (
	{
		Frontend => 'Year',
		Name => 'Year',
		Multiple => 0,
		Size => 0,
		SelectedID => $SelectedYear,
		Data => {
				%Year,
			},
	},
	{
		Frontend => 'Month',
		Name => 'Month',
		Multiple => 0,
		Size => 0,
		SelectedID => $SelectedMonth,
		Data => {
			%Month,
			},
	},
	{
		Frontend => 'Date to use',
		Name => 'DatetoUse',
		Multiple => 0,
		Size => 0,
		SelectedID => 'creation_date',
		Data => {
				%DateType,
			},
	},
	);
	return @Params;	
}

sub Run {

	my ( $Self, %Param ) = @_;	
	return  $Self->{StatsObject}->CICreatedxMonthAndCategory( year => $Param{Year}, month => $Param{Month}, dateType => $Param{DatetoUse});
}

1;