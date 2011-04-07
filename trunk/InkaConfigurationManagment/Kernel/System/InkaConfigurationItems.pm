#--
#Kernel/System/InkaConfigurationItems.pm - Module to manage the configuration Items with the flexigrid
# Copyright (C) 2011 Juan Manuel Rodriguez
#--
#$Id: InkaConfigurationItems.pm
#--
#This software comes with ABSOLUTELY NO WARRANTY. For details, see
#the enclosed file COPYING for license information (AGPL). If you
#did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
#--
package Kernel::System::InkaConfigurationItems;
use strict;
use warnings;

use Kernel::System::InkaConfigurationItemsCtes;
use Kernel::System::DB;
use Data::Dumper;
use Date::Parse;

sub new {
	my ( $Type, %Param ) = @_;
#allocate new hash for object
	my $Self = {};
	bless ($Self, $Type);

	# check needed objects
    for (qw(DBObject ConfigObject LogObject TimeObject)) {
        $Self->{$_} = $Param{$_} || die "Got no $_!";
    }
	return $Self;
}

=item GetConfigurationItemById()

Returns a hash which represents a basic configuration item: 

Params:
	id: integer

Invocation:
    my %ci = $Object->GetConfigurationItemById(
    		id_ci => 28
    );
    
Return:
	a hash map with all the columns as keys and values from the selected record. As the following:
	(
		id => 1,
		category => 'case', 
		state  => 'in use',
		provider  => 'Cannon',
		unique_name  => 'Case A01'
		serial_number  => '12121212'
		cost  => 12.1
		acquisition_day => '30/12/2001'
	)

=cut

sub GetConfigurationItemById {
	my ( $Self, %Param ) = @_;
	my @columns = (Kernel::System::InkaConfigurationItemsCtes::CI_BASIC_COLUMNS);
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_BASIC_CI;
	my %ci = ();
	$SQL .= " WHERE i.id=? ";
	
	$Self->{DBObject}->Prepare(SQL => $SQL, Bind => [\$Param{id}]);

	if (my @Row = $Self->{DBObject}->FetchrowArray()) {
		for(my $j = 0; $j < @columns; $j++) {
			$ci{($columns[$j])} = $Row[$j];
		}
	}
	return %ci;		
}

=item GetConfigurationItemByMultipleId()

Returns a hash array which represents a basic configuration item: 

Params:
	ids: array of integer

Invocation:
    my @ci = $Object->GetConfigurationItemByMultipleId(
    		ids => \@array;
    );
    
Return:
	a array of hashes with all the columns as keys and values from the selected record. As the following:
	[{
		id => 1,
		category => 'case', 
		state  => 'in use',
		provider  => 'Cannon',
		unique_name  => 'Case A01'
		serial_number  => '12121212'
		cost  => 12.1
		acquisition_day => '30/12/2001'
	},{},{}...]

=cut

sub GetConfigurationItemByMultipleId {
	my ( $Self, %Param ) = @_;
	my @columns = (Kernel::System::InkaConfigurationItemsCtes::CI_BASIC_COLUMNS);
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_BASIC_CI;
	my $arrayOfCIIds = $Param{ids};
	my @cis = ();
	my $i=0;
	
	if(@$arrayOfCIIds == 0){
		return @cis;
	}
	$SQL .= " WHERE 1=0 ";
	for(my $j = 0; $j < @$arrayOfCIIds; $j++) {
		
		$SQL .= " OR i.id=".@$arrayOfCIIds[$j];		
	}
	
	$Self->{DBObject}->Prepare(SQL => $SQL);

	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
		my %ci=();
		for(my $j = 0; $j < @columns; $j++) {
			$ci{($columns[$j])} = $Row[$j];
		}
		$cis[$i] = \%ci;
		$i++;
	}
	return @cis;
}

=item GetConfigurationItemArrayWithConditions()

Returns a hash array which represents a basic configuration item: 

Params:
	  unique_name	: string
	  serial_number : string 
	  id_category   : integer

Invocation:
    my @ci = $Object->GetConfigurationItemArrayWithConditions(
    		  unique_name	=> 'lala',
	  		  serial_number	=> '123', 
	 		  id_category  	=> 3
    );
    
Return:
	a array of hashes with all the columns as keys and values from the selected record. As the following:
	[{
		id => 1,
		category => 'case', 
		state  => 'in use',
		provider  => 'Cannon',
		unique_name  => 'Case A01'
		serial_number  => '12121212'
		cost  => 12.1
		acquisition_day => '30/12/2001'
	},{},{}...]

=cut

sub GetConfigurationItemArrayWithConditions {
	my ( $Self, %Param ) = @_;
	my @columns 	= (Kernel::System::InkaConfigurationItemsCtes::CI_BASIC_COLUMNS);
	my $SQL 		= Kernel::System::InkaConfigurationItemsCtes::GET_BASIC_CI;	
	my $unique_name    = $Param{unique_name} || '';
	my $serial_number  = $Param{serial_number} || '';
	my $id_category    = $Param{id_category};
	
	my @cis = ();
	my $i=0;

	$SQL .= " WHERE i.id_category=?";
	if($serial_number ne ""){
		$SQL .= " AND i.serial_number like ? ";
		$serial_number = '%'.$serial_number.'%';		
	}
	if($unique_name ne ""){
		$SQL .= " AND i.unique_name like ? ";
		$unique_name = '%'.$unique_name.'%';		
	}	
		
	if($unique_name eq '' && $serial_number eq ''){
		$Self->{DBObject}->Prepare(SQL => $SQL, Bind => [\$id_category],Limit => 20);
	}elsif($unique_name ne '' && $serial_number eq ''){
		$Self->{DBObject}->Prepare(SQL => $SQL, Bind => [\$id_category, \$unique_name],Limit => 20);
	}elsif($unique_name eq '' && $serial_number ne ''){
		$Self->{DBObject}->Prepare(SQL => $SQL, Bind => [\$id_category, \$serial_number],Limit => 20);
	}else{
		$Self->{DBObject}->Prepare(SQL => $SQL, 
							   Bind => [\$id_category, \$serial_number, \$unique_name ],
							   Limit => 20);
	}

	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
		my %ci=();
		for(my $j = 0; $j < @columns; $j++) {
			$ci{($columns[$j])} = $Row[$j];
		}
		$cis[$i] = \%ci;
		$i++;
	}
	return @cis;
}


#Gets
# Params: 
# 	page: Current page shown by the flexigrid 
# 	rp: rows per page
# 	sortname: field used to order the table
# 	sortorder: "asc" or "desc"
# 	query: the string used in the search (WHERE qtype like "%query%")
# 	qtype: the field used to search
# Return: This function will return the hash needed by flexigrid
sub GetConfigurationItemArray {
	
	my ( $Self, %Param ) = @_;
	
	my $urlEdit = $Param{urlEdit};
	my $urlLink = $Param{urlLink};
	my $urlHistory = $Param{urlHistory};
	my $colLink = $Param{colWithLink}; # number from 0 to 1 of the column with the access link to edit		
	my $page = $Param{page};
	my $rp = $Param{rp};
	my $sortname = $Param{sortname};
	my $sortorder = $Param{sortorder};
	my $query = $Param{query};
	my $qtype = $Param{qtype};
	my @listOfColumns = (Kernel::System::InkaConfigurationItemsCtes::CI_BASIC_COLUMNS);
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_BASIC_CI;
	my $SQLCount = Kernel::System::InkaConfigurationItemsCtes::GET_COUNT_BASIC_CI;
	my $columnsDate = Kernel::System::InkaConfigurationItemsCtes::GET_CI_BASIC_DATE_COLUMNS;
	my @rows = ();	
	my $i=0;
	my %Data = ();
	my $total = 0;
	
	#############
	unless($sortname){
		 $sortname = $listOfColumns[0];
	}
	unless($sortorder){
		$sortorder = 'asc';
	}
	my $sort = "ORDER BY ".$sortname." ".$sortorder;

	unless($page){
		$page = 1;
	}
	unless($rp){
		 $rp = Kernel::System::InkaConfigurationItemsCtes::DEFAULT_ROW_PER_PAGE;
	}
	my $start = (($page-1) * $rp);
	#my $limit = "LIMIT $start, $rp";
	my $where = "";
	if ($query) {
		$where = " WHERE ".$qtype." LIKE ? ";
	}
	$SQL .= $where." ".$sort;
	$SQLCount .= $where;
	if($query){
		$query = '%'.$query.'%';
	}
	##### GET COUNT ##########
	if ($query) {		
		$Self->{DBObject}->Prepare(
			SQL=> $SQLCount,			
			Limit => 1,
			Bind => [ \$query ],
		);
	}else{
		$Self->{DBObject}->Prepare(
			SQL=> $SQLCount,			
			Limit => 1			
		);
	}
	while (my @RowCount = $Self->{DBObject}->FetchrowArray()) {
			$total = $RowCount[0];
	}
	#######END GET COUNT #########
	unless ($query) {
		$Self->{DBObject}->Prepare(			
			SQL => $SQL,			
#			Start => $start+$rp,
			Limit => $rp+$start,			
		);		
	}else{
		$Self->{DBObject}->Prepare(
			SQL=> $SQL,
#			Start => $start,
			Limit => $rp+$start,
			Bind => [ \$query ],
		);
	}
	
	#HORRIBLE PATCH!!! 
	#TODO: FIX IT IN THE NEXT VERSION!
	#discount N first rows until the rows of the current page (the start doesn't work)
	for ( 1 .. $start ) {
		$Self->{DBObject}->FetchrowArray()
	}

	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
			my @cells = ();
			for(my $j = 1; $j < @listOfColumns; $j++) {
				if( ($$columnsDate{$listOfColumns[$j]} == 1) && ($Row[$j] != 0) ){
				my ($s,$m,$h, $D,$M,$Y) = $Self->{TimeObject}->SystemTime2Date(SystemTime => $Row[$j]);
					$cells[$j-1] = $D."/".$M."/".$Y;
				}else{
					$cells[$j-1] = $Row[$j];
				}
			}
			$cells[$colLink]="<a href=\"$urlEdit&id=".$Row[0]."\" class=\"edit_icon\" >".$cells[$colLink]."</a>";
			$cells[@listOfColumns-1]="<a href=\"$urlLink&id=".$Row[0]."\" ><div class=\"link_icon\"></div></a>";
			$cells[@listOfColumns]="<a href=\"$urlHistory&id=".$Row[0]."\" ><div class=\"history_icon\"></div></a>";
			$rows[$i]={ 'id'=> $Row[0],
						'cell'=>\@cells
					  };
			$i++;
	}

	%Data = (
	    page    => $page,
	    total   => $total,
	    rows    => \@rows
	);

	return %Data;
}

#Param: unique_name: string
sub GetCIIdByUniqueName {
	
	my ( $Self, %Param ) = @_;
	my $id=0;

	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_CIID_BY_UNIQUE_NAME;
	$Self->{DBObject}->Prepare(SQL => $SQL, 
							   Bind => [\$Param{unique_name}],
							   Limit => 1);
	my @Row = $Self->{DBObject}->FetchrowArray();
	if (@Row) {
			$id = $Row[0];
	}else{
			$id = 0;
	}
	return $id;
}

#Param: id: int
sub GetFullCIbyID {

	my ( $Self, %Param ) = @_;
	my @listOfBasicColumns = (Kernel::System::InkaConfigurationItemsCtes::GET_CI_FULL_BY_ID_COLUMNS_BASIC);
	my @extraColumns = (Kernel::System::InkaConfigurationItemsCtes::GET_CI_FULL_BY_ID_COLUMNS_EXTRA);
	my $columnsDate = Kernel::System::InkaConfigurationItemsCtes::GET_CI_BASIC_DATE_COLUMNS;
	my %CI = ();

	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_CI_FULL_BY_ID;
	$Self->{DBObject}->Prepare( SQL => $SQL, Bind => [\$Param{id}] );
	my $j =0;
	my @Row=();
	if (@Row = $Self->{DBObject}->FetchrowArray()) {
		for($j = 0; $j < @listOfBasicColumns; $j++) {
			if( ($$columnsDate{$listOfBasicColumns[$j]} == 1) && ($Row[$j] != 0) ){
				my ($s,$m,$h, $D,$M,$Y) = $Self->{TimeObject}->SystemTime2Date(SystemTime => $Row[$j]);
				$CI{($listOfBasicColumns[$j])} = $D."/".$M."/".$Y;
			}else{
				$CI{($listOfBasicColumns[$j])} = $Row[$j];
			}
		}
	}
	do {
 		if($Row[$j]){
 			$CI{'val_'.$Row[$j+3]} = $Row[$j+4] || $Row[$j+5] || $Row[$j+6] || $Row[$j+7] || $Row[$j+8] || $Row[$j+9];
 			$CI{'type_'.$Row[$j+3]} = $Row[$j+1];
 			if($Row[$j+1] == Kernel::System::InkaConfigurationItemsCtes::META_TYPE_DATE){
 				my ($s,$m,$h, $D,$M,$Y) = $Self->{TimeObject}->SystemTime2Date(SystemTime => $CI{'val_'.$Row[$j+3]});
 				if($D ne "" && $M ne "" && $Y ne ""){
					$CI{'val_'.$Row[$j+3]} = $D."/".$M."/".$Y;
 				}else{
 					$CI{'val_'.$Row[$j+3]} = "";
 				}
 			}elsif($Row[$j+1] == Kernel::System::InkaConfigurationItemsCtes::META_TYPE_FILE){
 				$CI{'name_'.$Row[$j+3]} =  $Row[$j+10];
 			}
		}
		@Row = $Self->{DBObject}->FetchrowArray();
 	} until (@Row == 0);
	return %CI;
}

=item GetCIProperty()

Description:
	gets the CI Propery record  

Params:
	id_ci : integer. the CI Id
	id_template_properties: The template property Id

Invocation:
    my %ciProperty = $Object->GetCIProperty(
    		id_ci => 28,
    		id_template_property => 59
    );
    
Return:
	a hash map with all the columns as keys and values from the selected record

=cut
sub GetCIProperty(){
	
	my ( $Self, %Param ) = @_;
	my %message = ();
	$message{"error"} = "";
	$message{"ok"} = "";
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_CI_PROPERTY_BY_CIID_AND_TEMPLATEPROP_ID;
	my @columns = Kernel::System::InkaConfigurationItemsCtes::CI_PROPERTY_COLUMNS;
	my %cih = ();

	$Self->{DBObject}->Prepare(SQL => $SQL,
							   Bind => [\$Param{id_ci}, \$Param{id_template_property}],
							   Limit => 1);

	if (my @Row = $Self->{DBObject}->FetchrowArray()) {
		for(my $j = 0; $j < @columns; $j++) {
			$cih{($columns[$j])} = $Row[$j];
		}
	}
	return %cih;
}

##end getters

# Params:
#	'userId' : integer. Usually: $Self->{UserID}
# 	'ci'=>HASH which represents a configurationItem-record. Must have all the fields as in database and all extra custom fields 
#   should be passed as a reference: CreateNewCI( 'ci'=> \%ci, 'userId' => $Self->{UserID} );
sub CreateNewCI(){

	my ( $Self, %Param ) = @_;
	my %message = ();
	my $ciaux = $Param{ci};
	my %ci = %$ciaux;
	my $SystemTime = 0;
	my $hashDateColumns = Kernel::System::InkaConfigurationItemsCtes::GET_CI_BASIC_DATE_COLUMNS;
	my @arrayOfDateColumns = keys(%$hashDateColumns);
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::INSERT_CI;
	$message{"error"} = "";
	$message{"ok"} = "";

	for(my $j = 0; $j < @arrayOfDateColumns; $j++) {
		$ci{$arrayOfDateColumns[$j]} = $Self->convertDateToLongInt(date=>$ci{$arrayOfDateColumns[$j]});
	}
	##Check the unique name
	my $ciId = $Self->GetCIIdByUniqueName(
    		'unique_name' => $ci{unique_name}
    	);
    if($ciId != 0){
    	$message{"error"} = '$Text{"Name alredy exists"}';
    	return %message;
    }

	#####
	$Self->{DBObject}->Do(SQL => $SQL,
							   Bind => [\$ci{id_category},
										\$ci{id_state},
										\$ci{id_provider},
										\$ci{unique_name},
										\$ci{serial_number},
										\$ci{description},
										\$ci{cost},
										\$ci{acquisition_day},
										\$ci{creation_date}]);

	if($Self->{DBObject}->Error() ne ""){
		$message{"error"} = '$Text{"Unable to create new configuration item. Error was:"}'.' '.$Self->{DBObject}->Error();
		return %message;
	}
	####
	$ciId = $Self->GetCIIdByUniqueName('unique_name' => $ci{unique_name});
	my $totalExtraFields = $ci{'extra_fields_count'};
	for(my $i=0;$i<$totalExtraFields;$i++){
		%message = $Self->CreateNewCIProperty('id'=>$ciId, 'ci' => $ci{'extra_fields_'.$i});
		if($message{"error"} ne ""){
			return %message;
		}
	}
	##Finally create the history record
	%message = $Self->CreateNewHistoryRecord('ci_id' => $ciId, 'user_id' => $Param{userId}, 'state_id' => $ci{id_state}, 'note' => Kernel::System::InkaConfigurationItemsCtes::CREATED_TEXT);
	if($message{"error"} eq ""){
		$message{"ok"} = '$Text{"Successfully created new configuration item"}';
	}
	return %message;
}

# Params:
#   'id'=> integer (configurationItem id)
# 	'ci'=>HASH which represents a configurationItemProperty-record. 
#    should be passed as a reference: CreateNewCI( 'ci'=> \%ci ) and must have the following values:
#		('value' => 123,
#		 'id_metatype' => 3,
#		 'id_template_property' => 12,
#		 'name' => 'My Field')
#
sub CreateNewCIProperty(){
	my ( $Self, %Param ) = @_;
	my %message = ();
	my $id = $Param{id}; 
	my $ciaux = $Param{ci};
	my %ci = %$ciaux;
	my %message = ();
	$message{"error"} = "";
	$message{"ok"} = "";
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::INSERT_CI_PROPERTY;
	my @maetatypeAndColumnsArray = Kernel::System::InkaConfigurationItemsCtes::CI_EXTRA_COLUMNS_VALUES;
	
	#	value_int, value_float, value_str, value_date, id_file, id_generic_item_list
	#		1			2			3			4           6                   7
	#       5
	$SQL .= ', '.$maetatypeAndColumnsArray[$ci{id_metatype}].') VALUES(?,?,?,?,?)';		
	if($ci{id_metatype} == Kernel::System::InkaConfigurationItemsCtes::META_TYPE_DATE){
		$ci{value} = $Self->convertDateToLongInt(date=>$ci{value});
	}
	$Self->{DBObject}->Do(SQL => $SQL,
							   Bind => [\$id,
										\$ci{id_metatype},
										\$ci{name},
										\$ci{id_template_property},
										\$ci{value} ]);

	if($Self->{DBObject}->Error() ne ""){
		$message{"error"} = '$Text{"Unable to create new configuration item. Error was:"}'.' '.$Self->{DBObject}->Error();		
	}
	return %message;										
}

# Params:
#	'userId' : integer. Usually: $Self->{UserID}
# 	'ci'=>HASH which represents a configurationItem-record. Must have all the fields as in database and all extra custom fields 
#   should be passed as a reference: CreateNewCI( 'ci'=> \%ci, 'userId' => $Self->{UserID} );
sub UpdateCI(){
	my ( $Self, %Param ) = @_;
	my %message = ();
	my $ciaux = $Param{ci};
	my %ci = %$ciaux;
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::UPDATE_CI;
	my $hashDateColumns = Kernel::System::InkaConfigurationItemsCtes::GET_CI_BASIC_DATE_COLUMNS;
	my @arrayOfDateColumns = keys(%$hashDateColumns);
	$message{"error"} = "";
	$message{"ok"} = "";
	
	##Check the unique name
	my $ciId = $Self->GetCIIdByUniqueName(
    		'unique_name' => $ci{unique_name}
    	);	
    if( ($ciId) && ($ciId != $ci{id}) ) {
    	$message{"error"} = '$Text{"Name alredy exists"}';
    	return %message;	
    }    
	#####
	for(my $j = 0; $j < @arrayOfDateColumns; $j++) {		
		$ci{$arrayOfDateColumns[$j]} = $Self->convertDateToLongInt(date=>$ci{$arrayOfDateColumns[$j]});
	}
	$Self->{DBObject}->Do(SQL => $SQL,
							   Bind => [\$ci{id_state},
										\$ci{id_provider},
										\$ci{unique_name},
										\$ci{serial_number},
										\$ci{description},
										\$ci{cost},
										\$ci{acquisition_day},
										\$ci{id}]);
										
	if($Self->{DBObject}->Error() ne ""){		
		$message{"error"} = '$Text{"Unable to update configuration item. Error was:"}'.' '.$Self->{DBObject}->Error();
		return %message;		
	}
		
	##Update all extra fields. In case of error try to create the property
	my $totalExtraFields = $ci{'extra_fields_count'};
	$Self->{LogObject}->Log(
				Priority => 'debug',
				Message => 'TotalExtraFields: -> '.$totalExtraFields
	);

	for(my $i=0;$i<$totalExtraFields;$i++){
		%message = $Self->UpdateCIProperty('id'=>$ci{id}, 'ci' => $ci{'extra_fields_'.$i});
		if($message{"error"} ne ""){
			##Try to create the property
			%message = $Self->CreateNewCIProperty('id'=>$ci{id}, 'ci' => $ci{'extra_fields_'.$i});
			if($message{"error"} ne ""){
				return %message;
			}
		}
	}
	
	##Finally create the history record
	%message = $Self->CreateNewHistoryRecord('ci_id' => $ci{id}, 'user_id' => $Param{userId}, 'state_id' => $ci{id_state}, 'note' => Kernel::System::InkaConfigurationItemsCtes::MODIFIED_TEXT); 
	if($message{"error"} eq ""){
		$message{"ok"} = '$Text{"Successfully updated configuration item"}';
	}
	##End		
	return %message;
}

# Params:
#   'id'=> integer (configurationItem id)
# 	'ci'=>HASH which represents a configurationItemProperty-record. 
#    should be passed as a reference: CreateNewCI( 'ci'=> \%ci ) and must have the following values:
#		('value' => 123,
#		 'id_metatype' => 3,
#		 'id_template_property' => 12,
#		 'name' => 'My Field')
#
sub UpdateCIProperty(){
	my ( $Self, %Param ) = @_;
	my %message = ();
	my $id = $Param{id}; 
	my $ciaux = $Param{ci};
	my %ci = %$ciaux;
	my %message = ();
	$message{"error"} = "";
	$message{"ok"} = "";
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::UPDATE_CI_PROPERTY00;
	my $SQL01 = Kernel::System::InkaConfigurationItemsCtes::UPDATE_CI_PROPERTY01;
	my @maetatypeAndColumnsArray = Kernel::System::InkaConfigurationItemsCtes::CI_EXTRA_COLUMNS_VALUES;

	$Self->{LogObject}->Log(
				Priority => 'debug',
				Message => 'Enter in UpdateCIProperty function'
	);

	#	value_int, value_float, value_str, value_date, id_file, id_generic_item_list
	#		1			2			3			4           6                   7
	#       5
	$SQL .= $maetatypeAndColumnsArray[$ci{id_metatype}].'=? '.$SQL01;
	if($ci{id_metatype} == Kernel::System::InkaConfigurationItemsCtes::META_TYPE_DATE){
		$ci{value} = $Self->convertDateToLongInt(date=>$ci{value});
	}
	$Self->{DBObject}->Do(SQL => $SQL,
							   Bind => [\$ci{value},
							   			\$id,				
										\$ci{id_template_property}]);

	if($Self->{DBObject}->Error() ne ""){
		$message{"error"} = '$Text{"Unable to update configuration item. Error was:"}'.' '.$Self->{DBObject}->Error();
	}
	return %message;
}

#Paramas: 'date' : string in format: dd/mm/yyyy
# returns: LONGINT (SO timestamp)
sub convertDateToLongInt(){
	my ( $Self, %Param ) = @_;	
	my $date = $Param{date};
	if($date==0 || $date eq '0' ){
	 	return 0;	
	}
	my ($dd, $mm, $yy) = split(/\//, $date);
	my $strDate = $yy.'-'.$mm.'-'.$dd.' 00:00:01';
	return $Self->{TimeObject}->TimeStamp2SystemTime(String => $strDate);
}

=item createNewHistoryRecord()

Creates a new record in table History

    my %message = $InkaConfigurationItemsObject->CreateNewHistoryRecord(
    	ci_id     => 28,   
        user_id   => 1,
        state_id  => 3,
        note 	  => 'CREATED'
    );

=cut
sub CreateNewHistoryRecord(){
	my ( $Self, %Param ) = @_;
	my %message = ();
	$message{"error"} = "";
	$message{"ok"} = "";
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::INSERT_HISTORY_CI;
	
	if($Param{note} eq  Kernel::System::InkaConfigurationItemsCtes::MODIFIED_TEXT){
		my %cih = $Self->GetLatestHistoryRecord(ci_id=>$Param{ci_id});
		if($cih{new_state} == $Param{state_id}){
				return %message;
		}
	}

	$Self->{DBObject}->Do(SQL => $SQL,
							   Bind => [\$Param{user_id},
							   			\$Param{ci_id},
										\$Param{state_id},
										\$Param{note}]);

	if($Self->{DBObject}->Error() ne ""){
		$message{"error"} = '$Text{"Unable to create history record"}'.' '.'$Text{"Error was"}'.': '.$Self->{DBObject}->Error();
		$Self->{LogObject}->Log(
				Priority => 'error',
				Message => $message{"error"}
		);
	}
	return %message;
}

=item createNewHistoryRecord()

gets the most recent HistoryReocrd for a given CI 

    my %ciHistoryRecord = $InkaConfigurationItemsObject->GetLatestHistoryRecord(
    	ci_id     => 28
    );

=cut
sub GetLatestHistoryRecord(){
	my ( $Self, %Param ) = @_;
	my %message = ();
	$message{"error"} = "";
	$message{"ok"} = "";
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_HISTORY_CI;
	my @columns = Kernel::System::InkaConfigurationItemsCtes::HISTORY_CI_COLUMNS;
	my %cih = ();

	$Self->{DBObject}->Prepare(SQL => $SQL,
							   Bind => [\$Param{ci_id}],
							   Limit => 1);
							   
	if (my @Row = $Self->{DBObject}->FetchrowArray()) {
		for(my $j = 0; $j < @columns; $j++) {
			$cih{($columns[$j])} = $Row[$j];
		}
	}
	
	return %cih;
}

#########History Section functions ##############################


=item GetCIHistory()

	Return the History Data for a given CI. The return value is the Hash used by flexigrid
		
parameters:
	id_ci: integer	  # CI id	
	page: integer 	  # Current page shown by the flexigrid 
	rp: integer		  # rows per page
	sortname: string  # field used to order the table
	sortorder: string # "asc" or "desc"
	query: string 	  # the string used in the search (WHERE qtype like "%query%")
	qtype: string 	  #	the field used to search

Inkvoke:
	->GetCIHistory(
		'id_ci' 	=> 1,		
		'page'  	=> 1,
		'rp' 		=> 15,
		'sortname'  => 'unique_name',
		'sortorder' => 'asc',
		'query' 	=> 'Home',
		'qtype' 	=> 'unique_name'
	);
	
returns: the hash used by flexigrid, with the form:

	{
			"page"=>"1",
			"total"=>"1",
			"rows"=>[
					{"id"=>"2",
					 "cell" =>["modification_date", "modificated_by", "new_state", "note", "statename", "login", "first_name", "last_name"]
					 },...]
	}
=cut

sub GetCIHistory(){

	my ( $Self, %Param ) = @_;
			
	my $id 	  	  = $Param{id_ci};	
	my $page 	  = $Param{page};
	my $rp 	 	  = $Param{rp};
	my $sortname  = $Param{sortname};
	my $sortorder = $Param{sortorder};
	my $query 	  = $Param{query};
	my $qtype 	  = $Param{qtype};
		
	my @listOfColumns = (Kernel::System::InkaConfigurationItemsCtes::HISTORY_COLUMNS);
	my $SQL 		  = Kernel::System::InkaConfigurationItemsCtes::GET_CI_HISTORY;
	my $SQLCount 	  = Kernel::System::InkaConfigurationItemsCtes::GET_COUNT_CI_HISTORY;

	my @rows = ();	
	my $i=0;
	my %Data = ();
	my $total = 0;
	
	##############################
	unless($sortname){
		 $sortname = $listOfColumns[1]; #unique_name
	}
	unless($sortorder){
		$sortorder = 'asc';
	}
	my $sort = "ORDER BY ".$sortname." ".$sortorder;

	unless($page){
		$page = 1;
	}
	unless($rp){
		 $rp = Kernel::System::InkaConfigurationItemsCtes::DEFAULT_ROW_PER_PAGE;
	}
	my $start = (($page-1) * $rp);

	my $where = "";
	if ($query) {
		$where = " AND ".$qtype." LIKE ? ";
	}
	$SQL .= $where." ".$sort;
	$SQLCount .= $where;
	if($query){
		$query = '%'.$query.'%';
	}
	
	##### GET COUNT ##########
	if ($query) {
		$Self->{DBObject}->Prepare(
				SQL=> $SQLCount,
				Limit => 1,
				Bind => [\$id, \$query]
				);

	}else{
		$Self->{DBObject}->Prepare(
				SQL=> $SQLCount,
				Limit => 1,
				Bind => [\$id]);
	}

	while (my @RowCount = $Self->{DBObject}->FetchrowArray()) {
			$total = $RowCount[0];
	}
	#######END GET COUNT #########
	if ($query) {
		$Self->{DBObject}->Prepare(
				SQL=> $SQL,
				Limit => $rp+$start,			
				Bind => [\$id, \$query]
		);
	}else{
		$Self->{DBObject}->Prepare(
				SQL=> $SQL,
				Limit => $rp+$start,			
				Bind => [\$id ]
		);
	}
	
	#HORRIBLE PATCH!!! 
	#TODO: FIX IT IN THE NEXT VERSION!
	#discount N first rows until the rows of the current page (the start doesn't work)
	for ( 1 .. $start ) {
		$Self->{DBObject}->FetchrowArray();
	}

	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
#Order of columns: id modification_date modificated_by new_state note statename login first_name last_name
#					0	1						2		3			4	5			6	7			8
			my @cells = ();
			$cells[0] = $Row[1];
			$cells[1] = " (".$Row[6].") ".$Row[7]." ".$Row[8];
			$cells[2] = $Row[4];
			$cells[3] = $Row[5];			

			$rows[$i]={ 'id'=> $Row[0],
						'cell'=>\@cells
					  };
			$i++;
	}
	%Data = (
	    page    => $page,
	    total   => $total,
	    rows    => \@rows
	);
	return %Data;
}

=item GetCITicketHistory()

	Return all the tickets linked to a given CI. The return value is the Hash used by flexigrid
		
parameters:
	id_ci: integer	  # CI id	
	page: integer 	  # Current page shown by the flexigrid 
	rp: integer		  # rows per page
	sortname: string  # field used to order the table
	sortorder: string # "asc" or "desc"
	query: string 	  # the string used in the search (WHERE qtype like "%query%")
	qtype: string 	  #	the field used to search

Inkvoke:
	->GetCITicketHistory(
		'id_ci' 	=> 1,		
		'page'  	=> 1,
		'rp' 		=> 15,
		'sortname'  => 'unique_name',
		'sortorder' => 'asc',
		'query' 	=> 'Home',
		'qtype' 	=> 'unique_name'
	);
	
returns: the hash used by flexigrid, with the form:

	{
			"page"=>"1",
			"total"=>"1",
			"rows"=>[
					{"id"=>"2",
					 "cell" =>["id", "tn", "title", "create_time", "user"]
					 },...]
	}
=cut

sub GetCITicketHistory(){

	my ( $Self, %Param ) = @_;
			
	my $id 	  	  = $Param{id_ci};	
	my $page 	  = $Param{page};
	my $rp 	 	  = $Param{rp};
	my $sortname  = $Param{sortname};
	my $sortorder = $Param{sortorder};
	my $query 	  = $Param{query};
	my $qtype 	  = $Param{qtype};
	my $colWithLink   = $Param{colWithLink};
	my $urlEdit 	  = $Param{urlEdit};
		
	my @listOfColumns = (Kernel::System::InkaConfigurationItemsCtes::HISTORY_TICKET_COLUMNS);
	my $SQL 		  = Kernel::System::InkaConfigurationItemsCtes::GET_CI_TICKET_HISTORY;
	my $SQLCount 	  = Kernel::System::InkaConfigurationItemsCtes::GET_COUNT_CI_TICKET_HISTORY;

	my @rows = ();	
	my $i=0;
	my %Data = ();
	my $total = 0;
	
	##################
	unless($sortname){
		 $sortname = $listOfColumns[3]; #create_time
	}
	unless($sortorder){
		$sortorder = 'asc';
	}
	my $sort = "ORDER BY ".$sortname." ".$sortorder;

	unless($page){
		$page = 1;
	}
	unless($rp){
		 $rp = Kernel::System::InkaConfigurationItemsCtes::DEFAULT_ROW_PER_PAGE;
	}
	my $start = (($page-1) * $rp);

	my $where = "";
	if ($query) {
		$where = " AND ".$qtype." LIKE ? ";
	}
	$SQL .= $where." ".$sort;
	$SQLCount .= $where;
	if($query){
		$query = '%'.$query.'%';
	}
	
	##### GET COUNT ##########
	if ($query) {
		$Self->{DBObject}->Prepare(
				SQL=> $SQLCount,
				Limit => 1,
				Bind => [\$id, \$query]
				);

	}else{
		$Self->{DBObject}->Prepare(
				SQL=> $SQLCount,
				Limit => 1,
				Bind => [\$id]);
	}

	while (my @RowCount = $Self->{DBObject}->FetchrowArray()) {
			$total = $RowCount[0];
	}
	#######END GET COUNT #########
	if ($query) {
		$Self->{DBObject}->Prepare(
				SQL=> $SQL,
				Limit => $rp+$start,			
				Bind => [\$id, \$query]
		);
	}else{
		$Self->{DBObject}->Prepare(
				SQL=> $SQL,
				Limit => $rp+$start,			
				Bind => [\$id ]
		);
	}
	
	#HORRIBLE PATCH!!! 
	#TODO: FIX IT IN THE NEXT VERSION!
	#discount N first rows until the rows of the current page (the start doesn't work)
	for ( 1 .. $start ) {
		$Self->{DBObject}->FetchrowArray();
	}

	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
	#Order of columns: id tn title state create_time login first_name last_name
	#					0	1	2	3		4		  5			6		7
			my @cells = ();
			$cells[0] = $Row[1];
			$cells[1] = $Row[2];
			$cells[2] = $Row[3];
			$cells[3] = $Row[4];
			$cells[4] = " (".$Row[5].") ".$Row[6]." ".$Row[7];			
			
			#create the link
			$cells[$colWithLink] = '<a href="'.$urlEdit.$Row[0].'" >'.$cells[$colWithLink].'</a>';
			
			$rows[$i]={ 'id'=> $Row[0],
						'cell'=>\@cells
					  };					  
			$i++;
	}
	%Data = (
	    page    => $page,
	    total   => $total,
	    rows    => \@rows
	);
	return %Data;
}
1;