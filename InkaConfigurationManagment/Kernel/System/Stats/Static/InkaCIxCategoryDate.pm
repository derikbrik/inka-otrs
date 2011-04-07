# --
# Kernel/System/Stats/Static/InkaCIxCategoryDate.pm - stats module
# Copyright (C) 2011 Juan Manuel Rodriguez
# --
# $Id: InkaCIxCategoryDate.pm $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Stats::Static::InkaCIxCategoryDate;

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
    my @Params = ();

    # get current time
    my ($s,$m,$h, $D,$M,$Y) = $Self->{TimeObject}->SystemTime2Date(
        SystemTime => $Self->{TimeObject}->SystemTime(),
    );
    $D = sprintf("%02d", $D);
    $M = sprintf("%02d", $M);
    $Y = sprintf("%02d", $Y);

    # create possible time selections
    my %Year  = map { $_, $_ } ( $Y-10..$Y+1 );
    my %Month = map { sprintf("%02d", $_), sprintf("%02d", $_) } ( 1..12 );
    my %Day   = map { sprintf("%02d", $_), sprintf("%02d", $_) } ( 1..31 );
	my %DateType = ();
	$DateType{creation_date} = 'creation_date';
	$DateType{acquisition_day} = 'acquisition_day'; 

    push (@Params, {
            Frontend => 'StartDay',
            Name => 'StartDay',
            Multiple => 0,
            Size => 0,
            SelectedID => '01',
            Data => {
                %Day,
            },
        },
    );
    push (@Params, {
            Frontend => 'StartMonth',
            Name => 'StartMonth',
            Multiple => 0,
            Size => 0,
            SelectedID => $M,
            Data => {
                %Month,
            },
        },
    );
    push (@Params, {
            Frontend => 'StartYear',
            Name => 'StartYear',
            Multiple => 0,
            Size => 0,
            SelectedID => $Y,
            Data => {
                %Year,
            },
        },
    );
    push (@Params, {
            Frontend => 'EndDay',
            Name => 'EndDay',
            Multiple => 0,
            Size => 0,
            SelectedID => $D,
            Data => {
                %Day,
            },
        },
    );
    push (@Params, {
            Frontend => 'EndMonth',
            Name => 'EndMonth',
            Multiple => 0,
            Size => 0,
            SelectedID => $M,
            Data => {
                %Month,
            },
        },
    );
    push (@Params, {
            Frontend => 'EndYear',
            Name => 'EndYear',
            Multiple => 0,
            Size => 0,
            SelectedID => $Y,
            Data => {
                %Year,
            },
        },
    );
    push (@Params, {
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
	return  $Self->{StatsObject}->CIxCategoryDateReport( startDate => $Param{StartDay}.'/'.$Param{StartMonth}.'/'.$Param{StartYear}, endDate =>$Param{EndDay}.'/'.$Param{EndMonth}.'/'.$Param{EndYear}, dateType => $Param{DatetoUse});
}

1;