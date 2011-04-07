#--
#Kernel/System/InkaConfigurationItemsCtes.pm - ctes module
# Copyright (C) 2011 Juan Manuel Rodriguez
#--
#$Id: InkaConfigurationItemsCtes.pm
#--
#This software comes with ABSOLUTELY NO WARRANTY. For details, see
#the enclosed file COPYING for license information (AGPL). If you
#did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
#--
package Kernel::System::InkaConfigurationItemsCtes;
use strict;
use warnings;

use constant GET_CATEGORY_QUERY            => 'SELECT id,id_parent,id_template,level,name,id_file,is_branch FROM inka_category order by level asc, is_branch desc, name asc';
use constant GET_CATEGORY_QUERY_2          => 'SELECT id,id_parent,id_template,level,name,id_file,is_branch FROM inka_category order by id_parent asc';
use constant CATEGORY_COLUMNS              => qw(id id_parent id_template level name id_file is_branch);
use constant GET_CATEGORY_BRANCHS_QUERY    => 'SELECT id,name FROM inka_category where is_branch = 1 order by level asc, name asc';
use constant CATEGORY_BRANCHS_COLUMNS      => qw(id name);
use constant GET_CATEGORY_BRANCHS_QUERY01  => 'SELECT id,id_parent FROM inka_category where is_branch=1';
use constant CATEGORY_BRANCHS_COLUMNS01    => qw(id id_parent);
use constant GET_CATEGORY_LEAF_QUERY       => 'SELECT id,name FROM inka_category where is_branch=0 and id_parent=? order by name asc';
use constant CATEGORY_LEAF_COLUMNS         => qw(id name);
use constant GET_CATEGORY_BY_ID_QUERY      => "SELECT i.id, i.id_parent,i.id_template,i.name,i.id_file,i.is_branch,f.filename FROM inka_category as i left join inka_file as f on i.id_file = f.id where i.id = ?";
use constant CATEGORY_BY_ID_COLUMNS        => qw(id id_parent id_template name id_file is_branch filename);
use constant GET_CATEGORY_BY_PARENTID_QUERY       => "SELECT id, id_parent,is_branch FROM inka_category where id_parent = ?";
use constant GET_CATEGORY_BY_PARENTID_SUBQUERY_01 => " and is_branch=1 ";
use constant GET_CATEGORY_BY_PARENTID_COLUMNS     => qw(id id_parent is_branch);
use constant CATEGORY_BY_ID_COLUMNS => qw(id id_parent id_template name id_file is_branch filename);
use constant CATEGORY_UPDATE_LEVEL  => "UPDATE inka_category SET level = ";
use constant GET_STATE_TREE_QUERY   => 'SELECT inka_category.id, inka_category.id_parent as id_category, inka_category.name, 1 as branch from inka_category where is_branch = 1 UNION SELECT inka_ci_state.id,inka_ci_state.id_category,inka_ci_state.name, 0 as branch FROM inka_ci_state';
use constant STATE_TREE_COLUMNS     => qw(id id_category name branch);
use constant INSERT_STATE_QUERY     => 'INSERT INTO inka_ci_state(id_category,name) VALUES(?,?)';
use constant UPDATE_STATE_QUERY     => "UPDATE inka_ci_state SET id_category= ?, name=? WHERE id=?";
use constant DELETE_STATE_QUERY     => "DELETE FROM inka_ci_state WHERE id=?";
use constant DELETE_CATEGORY_QUERY  => "DELETE FROM inka_category WHERE id=? OR id_parent=?";
use constant EDIT_CATEGORY_QUERY    => "UPDATE inka_category SET id_parent=?, id_template=?, level=?, name=?, is_branch=? where id=?";
use constant INSERT_CATEGORY_QUERY  => "INSERT INTO inka_category(id_parent,id_template,level,name,is_branch) VALUES(?,?,?,?,?)";
use constant GET_VENDOR_QUERY  	    => "SELECT id, id_category, name FROM inka_ci_provider_list where id_category=?";
use constant GET_VENDOR_QUERY01     => "SELECT id, id_category, name FROM inka_ci_provider_list where id_category=? ";
use constant GET_VENDOR_QUERY02    =>  "SELECT id, id_category, name FROM inka_ci_provider_list where id_category=? AND name=?";
use constant VENDOR_COLUMNS 	    => qw(id id_category name);
use constant INSERT_VENDOR_QUERY    => 'INSERT INTO inka_ci_provider_list(id_category,name) VALUES(?,?)';
use constant UPDATE_VENDOR_QUERY    => "UPDATE inka_ci_provider_list SET id_category= ?, name=? WHERE id=?";
use constant DELETE_VENDOR_QUERY    => "DELETE FROM inka_ci_provider_list WHERE id=?";
use constant GET_STATE_QUERY	    => "SELECT id,id_category,name FROM inka_ci_state";
use constant GET_STATE_COLUMNS	    => qw(id id_category name);

use constant GET_GENERIC_LIST_QUERY  			=> "SELECT id,id_category,name FROM inka_ci_generic_list";
use constant GENERIC_LIST_COLUMNS 				=> qw(id id_category name);
use constant GET_GENERIC_LIST_ELEMENT_QUERY 	=> "SELECT id,id_list,name,value FROM inka_ci_generic_list_element WHERE id_list=?";
use constant GENERIC_LIST_ELEMENT_COLUMNS 		=> qw(id id_list name value);
use constant INSERT_GENERIC_LIST_QUERY  		=> "INSERT INTO inka_ci_generic_list(id_category,name) VALUES(1,?)";
use constant INSERT_GENERIC_LIST_ELEMENT_QUERY  => "INSERT INTO inka_ci_generic_list_element(id_list,name,value) VALUES(?,?,?)";
use constant UPDATE_GENERIC_LIST_QUERY 			=> "UPDATE inka_ci_generic_list SET name=? where id=?";
use constant UPDATE_GENERIC_LIST_ELEMENT_QUERY  => "UPDATE inka_ci_generic_list_element SET name=?, value=? where id=?";
use constant DELETE_GENERIC_LIST_QUERY00  		=> "DELETE FROM inka_ci_generic_list_element WHERE id_list=?";
use constant DELETE_GENERIC_LIST_QUERY01  		=> "DELETE FROM inka_ci_generic_list WHERE id=?";
use constant DELETE_GENERIC_LIST_ELEMENT_QUERY  => "DELETE FROM inka_ci_generic_list_element WHERE id=?";

use constant GET_TEMPLATES_QUERY  => "SELECT id, name, hasDefaultFields FROM inka_ci_template ";
use constant GET_TEMPLATES_QUERY_BY_NAME  => "SELECT id, name, hasDefaultFields FROM inka_ci_template where name like ?";
use constant ORDER_BY_NAME => "order by name asc";
use constant TEMPLATE_COLUMNS => qw(id name hasDefaultFields);
use constant GET_TEMPLATE_FIELDS_QUERY => "SELECT id, id_template, id_metatype, id_list, id_properties_group, caption, mandatory, display FROM inka_ci_template_property WHERE ";
use constant GET_TEMPLATE_FIELDS_QUERY01 => "SELECT A.id, A.id_template, A.id_metatype, A.id_list, A.id_properties_group, A.caption, A.mandatory, A.display, C.name as group_name FROM inka_ci_template_property A inner join inka_category B on A.id_template = B.id_template inner join inka_ci_properties_group C on C.id=A.id_properties_group where B.id=? order by id_properties_group asc";
use constant TEMPLATE_FIELD_COLUMNS => qw(id id_template id_metatype id_list id_properties_group caption mandatory display);
use constant TEMPLATE_FIELD_COLUMNS01 => qw(id id_template id_metatype id_list id_properties_group caption mandatory display group_name);
use constant GET_TEMPLATE_FIELDS_QUERY_COND01 => " id = ? ";
use constant GET_TEMPLATE_FIELDS_QUERY_COND02 => " id_template = ? ";
use constant INSERT_TEMPLATE_QUERY => "INSERT INTO inka_ci_template(name,hasDefaultFields) VALUES(?,1)";
use constant UPDATE_TEMPLATE_QUERY => "UPDATE inka_ci_template SET name=? WHERE id=?";
use constant INSERT_TEMPLATE_FIELD_QUERY => "INSERT INTO inka_ci_template_property(id_template,id_metatype,id_list,id_properties_group,caption,mandatory,display) VALUES(?,?,?,?,?,?,?)";
use constant UPDATE_TEMPLATE_FIELD_QUERY => "UPDATE inka_ci_template_property SET id_metatype=?, id_list=?, id_properties_group=?, caption=?, mandatory=?, display=? WHERE id=?";
use constant DELETE_TEMPLATE_QUERY => "DELETE FROM inka_ci_template WHERE id=?";
use constant DELETE_TEMPLATE_FIELD_QUERY => "DELETE FROM inka_ci_template_property WHERE id=? or id_template=?";
use constant DELETE_TEMPLATE_FIELD_QUERY01 => "DELETE FROM inka_ci_template_property WHERE ";

use constant GET_ALL_PROPERTIES_GROUP_QUERY => "SELECT id, name FROM inka_ci_properties_group";
use constant GET_PROPERTIES_GROUP_QUERY => "SELECT id, name FROM inka_ci_properties_group where id=? or name=?";
use constant PROPERTIES_GROUP_COLUMNS => qw(id name);
use constant INSERT_PROPERTIES_GROUP_QUERY => "INSERT INTO inka_ci_properties_group(name) VALUES(?)";

use constant GET_METATYPE_QUERY => "SELECT id,name FROM inka_metatype";
use constant METATYPE_COLUMNS => qw(id name);

##CI
use constant CI_BASIC_COLUMNS => qw(id unique_name serial_number category state provider cost acquisition_day);
use constant GET_BASIC_CI => "SELECT i.id, i.unique_name, i.serial_number, c.name as category, s.name as state, p.name as provider, i.cost, i.acquisition_day FROM inka_ci i inner join inka_category c on i.id_category=c.id inner join inka_ci_state s on i.id_state=s.id left join inka_ci_provider_list p on i.id_provider = p.id";
use constant GET_COUNT_BASIC_CI => "SELECT count(i.id) as countCis FROM inka_ci i inner join inka_category c on i.id_category=c.id inner join inka_ci_state s on i.id_state=s.id left join inka_ci_provider_list p on i.id_provider = p.id";
use constant GET_CATEGORY_PARENTS => "SELECT a1.id as a1,a2.id as a2, a3.id as a3, a4.id as a4 FROM inka_category a1 left join inka_category a2 on a1.id_parent=a2.id left join inka_category a3 on a2.id_parent=a3.id left join inka_category a4 on a3.id_parent=a4.id where a1.id=?";
use constant GET_CIID_BY_UNIQUE_NAME => "SELECT id FROM inka_ci where unique_name like ?";
use constant GET_CI_FULL_BY_ID => "SELECT A.id, A.id_category, A.id_state, A.id_provider, A.unique_name, A.serial_number, A.description, A.cost, A.acquisition_day, C.id_parent as id_category_parent, B.id as idExtraProp, B.id_metatype, B.name, B.id_template_properties, B.value_int, B.value_float, B.value_str, B.value_date, B.id_generic_item_list, B.id_file, D.filename FROM inka_ci A inner join inka_category C on C.id = A.id_category left join inka_ci_property B ON A.id = B.id_ci  left join inka_file D on B.id_file = D.id WHERE A.id=?";
use constant GET_CI_FULL_BY_ID_COLUMNS_BASIC => qw(id id_category id_state id_provider unique_name serial_number description cost acquisition_day id_category_parent);
use constant GET_CI_BASIC_DATE_COLUMNS => {'acquisition_day' => 1, 'creation_date' => 1};
use constant GET_CI_FULL_BY_ID_COLUMNS_EXTRA => qw(idExtraProp id_metatype name id_template_properties value_int value_float value_str value_date id_generic_item_list id_file);
use constant GET_CI_FULL_COLUMNS_VALUES_TO_EXCLUDE => qw(description unique_name serial_number);#qw(id id_category id_state id_provider id_category_parent unique_name);
use constant INSERT_CI => "INSERT INTO inka_ci(id_category,id_state,id_provider,unique_name,serial_number,description,cost,acquisition_day,creation_date) VALUES(?,?,?,?,?,?,?,?,?)";
use constant UPDATE_CI => "UPDATE inka_ci SET id_state=? , id_provider=? ,unique_name=? ,serial_number=? ,description=? ,cost=? , acquisition_day=? where id=?";
use constant INSERT_CI_PROPERTY => "INSERT INTO inka_ci_property(id_ci, id_metatype,name, id_template_properties";
use constant UPDATE_CI_PROPERTY00 => "UPDATE inka_ci_property SET ";
use constant UPDATE_CI_PROPERTY01 => "WHERE id_ci=? and id_template_properties=?";
use constant CI_EXTRA_COLUMNS_VALUES => qw(nothing value_int value_float value_str value_date value_int id_file id_generic_item_list);
use constant GET_CI_PROPERTY_BY_CIID_AND_TEMPLATEPROP_ID => 'SELECT id,id_ci,id_metatype,name,id_template_properties,value_int,value_float,value_str,value_date,id_generic_item_list,id_file FROM inka_ci_property where id_ci=? and id_template_properties=?';
use constant CI_PROPERTY_COLUMNS => qw(id id_ci id_metatype name id_template_properties value_int value_float value_str value_date id_generic_item_list id_file);

##Ci History
use constant INSERT_HISTORY_CI => "INSERT INTO inka_ci_history(modification_date,modificated_by,id_ci,new_state,note) VALUES(current_timestamp,?,?,?,?)";
use constant GET_HISTORY_CI => "SELECT modification_date,modificated_by,id_ci,new_state,note FROM inka_ci_history where id_ci=? order by modification_date desc";
use constant HISTORY_CI_COLUMNS => qw(modification_date modificated_by id_ci new_state note);

#File
use constant INSERT_FILE => "INSERT INTO inka_file(filename,content_type,content_size,content,creation_date,modification_date) VALUES(?,?,?,?,current_timestamp,current_timestamp)";
use constant GET_INSERTED_FILE => "SELECT id FROM inka_file where filename like ? order by creation_date desc";
use constant GET_FILE_BY_ID => "SELECT id, filename, content_type, content_size, content, creation_date, modification_date FROM inka_file where id=?";
use constant DELETE_FILE_BY_ID => "DELETE FROM inka_file where id=?";
use constant FILE_COLUMNS => qw(id filename content_type content_size content creation_date modification_date);

#Links (Relations)
use constant GET_ALL_LINKS => "SELECT id,name,1 as linktype FROM inka_ci_link_type UNION SELECT id,name,2 as linktype FROM  inka_ci_user_link_type";
use constant LINK_COLUMNS => qw(id name linktype);
use constant INSERT_LINK_TYPE_USER => "INSERT INTO inka_ci_user_link_type(name) VALUES(?)";
use constant INSERT_LINK_TYPE_CI   => "INSERT INTO inka_ci_link_type(name) VALUES(?)";
use constant UPDATE_LINK_TYPE_USER => "UPDATE inka_ci_user_link_type SET name=? where id=?"; 
use constant UPDATE_LINK_TYPE_CI   => "UPDATE inka_ci_link_type SET name=? where id=?";
use constant DELETE_LINK_TYPE_CI   => "DELETE FROM inka_ci_link_type where id=?";
use constant DELETE_LINK_TYPE_USER => "DELETE FROM inka_ci_user_link_type where id=?";
use constant COUNT_LINKS_USER_CI   =>  "SELECT count(*) as linkcount FROM inka_ci_user_link where id_user_link_type=?";
use constant COUNT_LINKS_CI_CI     =>  "SELECT count(*) as linkcount FROM inka_ci_ci_link where id_link_type=?";
use constant GET_ALL_RELATED_CI    =>  "SELECT i.id, 'in' as direction, i.unique_name, i.serial_number, c.name as category, s.name as state, p.name as provider, i.cost, i.acquisition_day,t.id as idType, t.name as nameType FROM inka_ci i inner join inka_category c on i.id_category=c.id inner join inka_ci_state s on i.id_state=s.id left join inka_ci_provider_list p on i.id_provider = p.id INNER JOIN inka_ci_ci_link l ON i.id=l.id_ci_down INNER JOIN inka_ci_link_type t ON l.id_link_type=t.id where l.id_ci_up=? and t.id=? "; #order by t.id, i.unique_name
use constant GET_ALL_RELATED_CI_INVERSE     => "SELECT i.id, 'out' as direction, i.unique_name, i.serial_number, c.name as category, s.name as state, p.name as provider, i.cost, i.acquisition_day,t.id as idType, t.name as nameType FROM inka_ci i inner join inka_category c on i.id_category=c.id inner join inka_ci_state s on i.id_state=s.id left join inka_ci_provider_list p on i.id_provider = p.id INNER JOIN inka_ci_ci_link l ON i.id=l.id_ci_up INNER JOIN inka_ci_link_type t ON l.id_link_type=t.id where l.id_ci_down=? and t.id=?";
use constant GET_ALL_NON_RELATED_CI 		=> "SELECT i.id, i.unique_name, i.serial_number, c.name as category, s.name as state, p.name as provider, i.cost, i.acquisition_day FROM inka_ci i inner join inka_category c on i.id_category=c.id inner join inka_ci_state s on i.id_state=s.id left join inka_ci_provider_list p on i.id_provider = p.id WHERE  i.id!=? and i.id not in (select id_ci_down from inka_ci_ci_link where id_ci_up=? and id_link_type=?) and i.id not in (select id_ci_up from inka_ci_ci_link where id_ci_down=? and id_link_type=?)";
use constant GET_COUNT_NON_RELATED_CI 		=> "SELECT count(i.id) as cicount FROM inka_ci i inner join inka_category c on i.id_category=c.id inner join inka_ci_state s on i.id_state=s.id left join inka_ci_provider_list p on i.id_provider = p.id WHERE  i.id!=? and i.id not in (select id_ci_down from inka_ci_ci_link where id_ci_up=? and id_link_type=?)  and i.id not in (select id_ci_up from inka_ci_ci_link where id_ci_down=? and id_link_type=?)";
use constant GET_COUNT_RELATED_CI 			=> "SELECT count(i.id) as cicount FROM inka_ci i inner join inka_category c on i.id_category=c.id inner join inka_ci_state s on i.id_state=s.id left join inka_ci_provider_list p on i.id_provider = p.id INNER JOIN inka_ci_ci_link l ON i.id=l.id_ci_down INNER JOIN inka_ci_link_type t ON l.id_link_type=t.id where l.id_ci_up=? and t.id=?  ";
use constant GET_COUNT_RELATED_CI_INVERSE   => "SELECT count(i.id) as cicount FROM inka_ci i inner join inka_category c on i.id_category=c.id inner join inka_ci_state s on i.id_state=s.id left join inka_ci_provider_list p on i.id_provider = p.id INNER JOIN inka_ci_ci_link l ON i.id=l.id_ci_up INNER JOIN inka_ci_link_type t ON l.id_link_type=t.id where l.id_ci_down=? and t.id=?"; 
use constant RELATED_CI_COLUMNS 			=> qw(id direction unique_name serial_number category state provider cost acquisition_day idType nameType);
use constant GET_ALL_RELATED_USER 			=> "SELECT u.id, u.login, u.first_name, u.last_name,t.id as idType, t.name as nameType FROM users u inner join inka_ci_user_link l on u.id=l.id_user inner join inka_ci_user_link_type t on t.id=l.id_user_link_type where l.id_ci=? and t.id=? ";# order by t.id, u.id
use constant GET_COUNT_RELATED_USER			=> "SELECT count(u.id) as cicount FROM users u inner join inka_ci_user_link l on u.id=l.id_user inner join inka_ci_user_link_type t on t.id=l.id_user_link_type where l.id_ci=? and t.id=? ";# order by t.id, u.id
use constant RELATED_USER_COLUMNS 			=> qw(id login first_name last_name idType nameType);
use constant GET_ALL_NON_RELATED_USER 		=>   "SELECT u.id, u.login, u.first_name, u.last_name FROM users u where u.id not in (select id_user from inka_ci_user_link where id_ci=? and id_user_link_type=?)";
use constant GET_COUNT_NON_RELATED_USER 	=> "SELECT count(u.id) as usercount FROM users u where u.id not in (select id_user from inka_ci_user_link where id_ci=? and id_user_link_type=?)";
use constant GET_RELATION_COUNT_BY_TYPE 	=>  " SELECT id_ci_up as id_ci, id_link_type, count(id_ci_down) as relation_count,1 as linktype FROM inka_ci_ci_link where id_ci_up=? group by id_link_type ".
											" UNION ".
											" SELECT id_ci,id_user_link_type as id_link_type, count(id_user) as relation_count,2 as linktype FROM inka_ci_user_link where id_ci=? group by id_link_type ";
use constant RELATION_COUNT_BY_TYPE_COLUMNS => qw(id_ci id_link_type relation_count linktype);
use constant INSERT_CI_RELATIONS => "INSERT INTO inka_ci_ci_link(id_ci_up,id_ci_down,id_link_type) VALUES(?,?,?)";
use constant INSERT_CI_RELATIONS_VALIDATOR => "SELECT count(id_ci_up) as cicount FROM inka_ci_ci_link WHERE ";
use constant CI_RELATIONS_COLUMNS => qw(id_ci_up id_link_type id_ci_down);
use constant INSERT_CI_USER_RELATIONS => "INSERT INTO inka_ci_user_link(id_ci,id_user,id_user_link_type) VALUES(?,?,?)";
use constant INSERT_CI_USER_RELATIONS_VALIDATOR => "SELECT count(id_ci) as cicount FROM inka_ci_user_link WHERE ";
use constant CI_USER_RELATIONS_COLUMNS => qw(id_ci id_user_link_type id_user);
use constant DELETE_CI_RELATIONS => "DELETE FROM inka_ci_ci_link WHERE";
use constant DELETE_CI_USER_RELATIONS => "DELETE FROM inka_ci_user_link WHERE";


#History Section
use constant GET_CI_HISTORY 	   => "SELECT A.id,A.modification_date,A.modificated_by,A.new_state,A.note,B.name as statename,C.login,C.first_name,C.last_name FROM inka_ci_history A inner join inka_ci_state B ON A.new_state=B.id inner join users C ON A.modificated_by=C.id where A.id_ci = ?";
use constant GET_COUNT_CI_HISTORY  => "SELECT count(A.id) as cicount FROM inka_ci_history A inner join inka_ci_state B ON A.new_state=B.id inner join users C ON A.modificated_by=C.id where A.id_ci = ?";
use constant HISTORY_COLUMNS 	   => qw(id modification_date modificated_by new_state note statename login first_name last_name);
use constant GET_CI_TICKET_HISTORY 		 => "SELECT t.id,t.tn,t.title,ts.name as state, l.create_time,u.login,u.first_name,u.last_name FROM ticket t INNER JOIN link_relation l ON t.id = l.target_key INNER JOIN users u ON l.create_by = u.id INNER JOIN link_object lo ON lo.id=l.source_object_id  INNER JOIN ticket_state ts ON t.ticket_state_id =ts.id where lo.name='InkaConfigurationItem' AND l.source_key=?";  
use constant GET_COUNT_CI_TICKET_HISTORY => "SELECT COUNT(t.id) as cicount FROM ticket t INNER JOIN link_relation l ON t.id = l.target_key INNER JOIN users u ON l.create_by = u.id INNER JOIN link_object lo ON lo.id=l.source_object_id  INNER JOIN ticket_state ts ON t.ticket_state_id =ts.id where lo.name='InkaConfigurationItem' AND l.source_key=?";
use constant HISTORY_TICKET_COLUMNS 	 => qw(id tn title state create_time login first_name last_name);
 
#Other constants not SQL
use constant INTERNAL_ENCODING => "utf-8";
use constant LOG_ERROR_HEADER_01 => "INKA_CIT ->";
use constant DEFAULT_ROW_PER_PAGE => "15";
use constant META_TYPE_INT	 => 1;
use constant META_TYPE_FLOAT => 2;
use constant META_TYPE_STR	 => 3;
use constant META_TYPE_DATE	 => 4;
use constant META_TYPE_FILE	 => 6;
use constant META_TYPE_LIST	 => 7;
use constant META_TYPE_BOOL	 => 5; #But it's stored in the same as int
	#columnName:	value_int, value_float, value_str, value_date, id_file, id_generic_item_list
	#metatype:			1, 5			2			3			4        6                 7

use constant CREATED_TEXT => 'CREATED';
use constant MODIFIED_TEXT => 'MODIFIED';


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