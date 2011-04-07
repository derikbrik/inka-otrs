# --
# Kernel/Language/es_InkaConfigurationManagment.pm - the english translation of InkaConfigurationManagment
# Copyright (C) 2011 Juan Manuel Rodriguez
# --
# $Id: es_InkaConfigurationManagment.pm $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::en_InkaConfigurationManagment;

use strict;
use warnings;

use vars qw(@ISA $VERSION);
$VERSION = qw($Revision: 0.1 $) [1];


sub Data {
    my $Self = shift;

    my $Lang = $Self->{Translation};

    return if ref $Lang ne 'HASH';

    $Lang->{'computer_attributes'}            = 'Computer attributes';
    $Lang->{'independent_components'}         = 'Independent component';
    $Lang->{'computer_description'}           = 'Computer description';
    
    return 1;
}

1;
