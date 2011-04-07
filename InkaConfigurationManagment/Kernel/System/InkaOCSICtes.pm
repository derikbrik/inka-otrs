#--
#Kernel/System/InkaOCSICtes.pm - core module
# Copyright (C) 2011 Juan Manuel Rodriguez
#--
#$Id: InkaOCSICtes.pm
#--
#This software comes with ABSOLUTELY NO WARRANTY. For details, see
#the enclosed file COPYING for license information (AGPL). If you
#did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
#--
package Kernel::System::InkaOCSICtes;
use strict;
use warnings;

use Kernel::System::DB;
use Digest::MD5 qw(md5);

sub new {
	my ( $Type, %Param ) = @_;
	#allocate new hash for object
	my $Self = {};
	bless ($Self, $Type);

	# check needed objects
    for (qw(DBObject ConfigObject LogObject)) {
        $Self->{$_} = $Param{$_} || die "Got no $_!";
    }
	return $Self;
}


use constant GET_ENABLED    		  	 => "SELECT value FROM inka_ocsi_config where keyname like 'enabled'";
use constant GET_ALL_CONFIG_OPTIONS   	 => "SELECT keyname,value FROM inka_ocsi_config";
use constant GET_ALL_CATEGORY_AVAILABLE  => "SELECT id,name,checksum_code,import,types,selected_type FROM inka_ocsi_category";
use constant OCS_CATEGORY_COLUMNS	     => qw(id name checksum_code import types selected_type);
use constant SAVE_WEB_SERVICE_OPTIONS 	 => "UPDATE inka_ocsi_config SET value=? where keyname like ?";
use constant GET_INSTALL_STATUS    	  	 => "SELECT value FROM inka_ocsi_config where keyname like 'progress'";
use constant SAVE_CATEGORY				 => "UPDATE inka_ocsi_category SET import=? , selected_type=? where name like ?";


1;