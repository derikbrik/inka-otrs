# --
# Kernel/System/Stats/Static/InkaCIxCategory.pm - stats module
# Copyright (C) 2011 Juan Manuel Rodriguez
# --
# $Id: InkaCIxCategory.pm $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Stats::Static::InkaCIxCategory;

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
	return @Params;
}

sub Run {

	my ( $Self, %Param ) = @_;
	
	
	return  $Self->{StatsObject}->CIxCategoryReport();
}

1;