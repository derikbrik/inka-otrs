# --
# Kernel/System/LinkObject/InkaConfigurationItem.pm - to link ConfigurationItem objects
# Copyright (C) 2011 Juan Manuel Rodriguez
# --
# $Id: InkaConfigurationItem.pm $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see http://www.gnu.org/licenses/gpl-2.0.txt.
# --

package Kernel::System::LinkObject::InkaConfigurationItem;

use strict;
use warnings;

use Kernel::System::InkaConfigurationItems;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.12 $) [1];

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    for (qw(DBObject ConfigObject LogObject MainObject EncodeObject TimeObject UserID)) {
        $Self->{$_} = $Param{$_} || die "Got no $_!";
    }

   $Self->{CIObject} = Kernel::System::InkaConfigurationItems->new( %{$Self} );
   return $Self;
}

sub LinkListWithData {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(LinkList UserID)) {
        if ( !$Param{$Argument} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    # check link list
    if ( ref $Param{LinkList} ne 'HASH' ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'LinkList must be a hash reference!',
        );
        return;
    }

    for my $LinkType ( keys %{ $Param{LinkList} } ) {

       for my $Direction ( keys %{ $Param{LinkList}->{$LinkType} } ) {

       		my @Idarray = ( keys %{ $Param{LinkList}->{$LinkType}->{$Direction} } );
 			my @ci = $Self->{CIObject}->GetConfigurationItemByMultipleId(ids => \@Idarray);
			for(my $j = 0; $j < @ci; $j++) {
				$Param{LinkList}->{$LinkType}->{$Direction}->{$ci[$j]{id}} = $ci[$j];
			}
		}
    }
    return 1;
}

sub ObjectDescriptionGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(Object Key UserID)) {
        if ( !$Param{$Argument} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    # create description
    my %Description = (
        Normal => 'InkaConfigurationItem',
        Long   => 'Inka Configuration Item',
    );
    return %Description;
}

sub ObjectSearch {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{UserID} ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'Need UserID!',
        );
        return;
    }
   
    
    my @ci = $Self->{CIObject}->GetConfigurationItemArrayWithConditions(
    		  unique_name	=> $Param{SearchParams}->{InkaCIuniqueName},
	  		  serial_number	=> $Param{SearchParams}->{InkaCIserialNumber}, 
	 		  id_category  	=> $Param{SearchParams}->{InkaCIcategory}[0]
    );    

	my %SearchList;
	for(my $j = 0; $j < @ci; $j++) {
  
		$SearchList{NOTLINKED}->{Source}->{$ci[$j]{id}} = $ci[$j];
	}
    return \%SearchList;
}

sub LinkAddPre {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(Key Type State UserID)) {
        if ( !$Param{$Argument} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    return 1 if $Param{State} eq 'Temporary';

    return 1;
}

sub LinkAddPost {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(Key Type State UserID)) {
        if ( !$Param{$Argument} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    return 1 if $Param{State} eq 'Temporary';

    return 1;
}

sub LinkDeletePre {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(Key Type State UserID)) {
        if ( !$Param{$Argument} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    return 1 if $Param{State} eq 'Temporary';

    return 1;
}

sub LinkDeletePost {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(Key Type State UserID)) {
        if ( !$Param{$Argument} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    return 1 if $Param{State} eq 'Temporary';

    return 1;
}

1;
