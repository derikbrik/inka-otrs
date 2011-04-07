#--
#Kernel/System/InkaStatsCtes.pm - ctes module for Stats
# Copyright (C) 2011 Juan Manuel Rodriguez
#--
#$Id: InkaStatsCtes.pm
#--
#This software comes with ABSOLUTELY NO WARRANTY. For details, see
#the enclosed file COPYING for license information (AGPL). If you
#did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
#--
package Kernel::System::InkaStatsCtes;
use strict;
use warnings;

##REPORT01: InkaCIxCategory.pm

use constant GET_CATEGORIES_QUERY    => 'SELECT id,name FROM inka_category where is_branch = 0 order by name';
use constant GET_STATE_QUERY 	 	 => 'SELECT id,name FROM inka_ci_state order by name';
use constant REPORT_01_MAIN_QUERY    => 'SELECT count(i.id) as cicount, c.id as category_id, s.id as state_id FROM inka_ci i inner join inka_category c on i.id_category=c.id inner join inka_ci_state s on i.id_state=s.id left join inka_ci_provider_list p on i.id_provider = p.id group by c.name, s.name';
use constant REPORT_01_TITLE    	 => 'Configuration items per Category and State.';
use constant REPORT_02_TITLE    	 => 'Configuration items %s in a selected month per category';
use constant REPORT_02_MAIN_QUERY_00 => "SELECT count(id) as cicount, id_category, '%s' as day FROM inka_ci where creation_date >= %s and creation_date < %s group by id_category";
use constant REPORT_02_MAIN_QUERY_01 => "SELECT count(id) as cicount, id_category, '%s' as day FROM inka_ci where acquisition_day >= %s and acquisition_day < %s group by id_category";
use constant REPORT_03_TITLE    	 => 'Configuration items %s in a selected month per state';
use constant REPORT_03_MAIN_QUERY_00 => "SELECT count(id) as cicount, id_state, '%s' as day FROM inka_ci where creation_date >= %s and creation_date < %s group by id_state";
use constant REPORT_03_MAIN_QUERY_01 => "SELECT count(id) as cicount, id_state, '%s' as day FROM inka_ci where acquisition_day >= %s and acquisition_day < %s group by id_state";
use constant REPORT_04_TITLE    	 => 'Configuration Items per Category and State %s in a specific time period';
use constant REPORT_04_MAIN_QUERY_00 => "SELECT count(id) as cicount, id_category, id_state FROM inka_ci where creation_date   >= ? and creation_date   < ? group by id_category, id_state";
use constant REPORT_04_MAIN_QUERY_01 => "SELECT count(id) as cicount, id_category, id_state FROM inka_ci where acquisition_day >= ? and acquisition_day < ? group by id_category, id_state";



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

1;