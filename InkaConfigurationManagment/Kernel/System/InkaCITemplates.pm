#--
#Kernel/System/InkaCITemplates.pm - core module
# Copyright (C) 2011 Juan Manuel Rodriguez
#--
#$Id: InkaCITemplates.pm
#--
#This software comes with ABSOLUTELY NO WARRANTY. For details, see
#the enclosed file COPYING for license information (AGPL). If you
#did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
#--
package Kernel::System::InkaCITemplates;
use strict;
use warnings;

use Kernel::System::InkaConfigurationItemsCtes;
use Kernel::System::DB;
use Data::Dumper;

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


#Gets

#params
# none
sub GetTemplateArray {
	
	my ( $Self, %Param ) = @_;
	my @TemplateArray = ();
	my $i = 0;
	
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_TEMPLATES_QUERY;
	my @listOfColumns = (Kernel::System::InkaConfigurationItemsCtes::TEMPLATE_COLUMNS);

	$SQL = $SQL.Kernel::System::InkaConfigurationItemsCtes::ORDER_BY_NAME;
	
	
	$Self->{DBObject}->Prepare(SQL => $SQL);
	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
			for(my $j = 0; $j < @listOfColumns; $j++) {
				$TemplateArray[$i]{($listOfColumns[$j])} = $Row[$j];
			}
			$i++;
	}
	return @TemplateArray;
}

#params
# 'id'
sub GetTemplateById {
	
	my ( $Self, %Param ) = @_;
	my %Template = ();
	
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_TEMPLATES_QUERY;
	my @listOfColumns = (Kernel::System::InkaConfigurationItemsCtes::TEMPLATE_COLUMNS);
		
	$SQL = $SQL." WHERE ".Kernel::System::InkaConfigurationItemsCtes::GET_TEMPLATE_FIELDS_QUERY_COND01;
	$Self->{DBObject}->Prepare(SQL => $SQL, Bind => [\$Param{id}] );

	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
			for(my $j = 0; $j < @listOfColumns; $j++) {
				$Template{($listOfColumns[$j])} = $Row[$j];
			}			
	}
	
#	$Self->{LogObject}->Log(
#				Priority => 'error',
#				Message => 'Template  : '.Dumper(%Template),
#		);
		
	return %Template;
}

# params: 
# 'idTemplate': int
sub GetTemplateFieldArray {
	
	my ( $Self, %Param ) = @_;
	my @TemplateFieldArray = ();
	my $i = 0;	
	my @listOfColumns = (Kernel::System::InkaConfigurationItemsCtes::TEMPLATE_FIELD_COLUMNS);
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_TEMPLATE_FIELDS_QUERY;
	$SQL = $SQL.Kernel::System::InkaConfigurationItemsCtes::GET_TEMPLATE_FIELDS_QUERY_COND02;
	
	$Self->{DBObject}->Prepare( SQL => $SQL, Bind => [\$Param{idTemplate}] );

	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
		for(my $j = 0; $j < @listOfColumns; $j++) {
			$TemplateFieldArray[$i]{($listOfColumns[$j])} = $Row[$j];
		}
		$i++;
	}
	return @TemplateFieldArray;
}

# params: 
# 'id_category': int
sub GetTemplateFieldArrayByCategoryId {
	
	my ( $Self, %Param ) = @_;
	my @TemplateFieldArray = ();
	my $i = 0;	
	my @listOfColumns = (Kernel::System::InkaConfigurationItemsCtes::TEMPLATE_FIELD_COLUMNS01);
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_TEMPLATE_FIELDS_QUERY01;
	
	$Self->{DBObject}->Prepare( SQL => $SQL, Bind => [\$Param{id_category}] );

	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
		for(my $j = 0; $j < @listOfColumns; $j++) {
			$TemplateFieldArray[$i]{($listOfColumns[$j])} = $Row[$j];
		}
		$i++;
	}
	return @TemplateFieldArray;
}

# params: 
# none
# array of PropertiesGroup
sub GetPropertiesGroupArray {
	
	my ( $Self, %Param ) = @_;
	my @PropertiesGroupArray = ();
	my $i = 0;	
	my @listOfColumns = (Kernel::System::InkaConfigurationItemsCtes::PROPERTIES_GROUP_COLUMNS);
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_ALL_PROPERTIES_GROUP_QUERY;
	
	$Self->{DBObject}->Prepare( SQL => $SQL);
	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
		for(my $j = 0; $j < @listOfColumns; $j++) {
			$PropertiesGroupArray[$i]{($listOfColumns[$j])} = $Row[$j];
		}
		$i++;
	}
	return @PropertiesGroupArray;	
}

# params 
#	'id': int
# returns only one field as hash
sub GetTemplateFieldById {
	
	my ( $Self, %Param ) = @_;
	my %TemplateField = ();
	
	my @listOfColumns = (Kernel::System::InkaConfigurationItemsCtes::TEMPLATE_FIELD_COLUMNS);
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_TEMPLATE_FIELDS_QUERY;
	$SQL = $SQL.Kernel::System::InkaConfigurationItemsCtes::GET_TEMPLATE_FIELDS_QUERY_COND01;
	
	$Self->{DBObject}->Prepare( SQL => $SQL, Limit => 1, Bind => [\$Param{id}] );

	if (my @Row = $Self->{DBObject}->FetchrowArray()) {
		for(my $j = 0; $j < @listOfColumns; $j++) {
			$TemplateField{($listOfColumns[$j])} = $Row[$j];
		}
	}
	return %TemplateField;
}

#Inserts

#params
# 'name': string
# 'extendDefault': boolean 1 or 0 (not uded by now)
sub CreateNewTemplate {
		
	my ( $Self, %Param ) = @_;
	my %message = (); 
	
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::INSERT_TEMPLATE_QUERY;
	$Self->{DBObject}->Prepare(SQL => $SQL, 
							   Bind => [ \$Param{name} ]);
	
	$message{"error"} = "";
	$message{"ok"} = "";
	if($Self->{DBObject}->Error() eq ""){						   	
		$message{"ok"} = '$Text{"successfully created new template"}';
	}else{
		$message{"error"} = "".$Self->{DBObject}->Error();
	}	
	return %message;
}

#params
#  id_template: int
# 'caption': string
# 'id_metatype': int
# 'id_list': int (could be null)
# 'mandatory': boolean	
# 'display'  : boolean
# 'idPropertiesGroup'   : int (could be null) 
# 'propertiesGroupName' : string (could be null)
sub CreateNewField {
		
	my ( $Self, %Param ) = @_;
	my %message = ();
	my $propGroupId = 1;
	my %prop = ();
	
	$message{"error"} = "";
	$message{"ok"} = "";
	
	#Property Group Validation and Creation
	if(exists($Param{propertiesGroupName}) && ($Param{propertiesGroupName} ne "" )){
			$propGroupId = $Self->validatePropertyGroup('PropertiesGroupName' => $Param{propertiesGroupName});
			if($propGroupId == -1){
				$message{"error"} = '$Text{"Unable to create the group of properties"}'.' '.'$Text{"Check the Log"}';
				return %message;
			}
	}else{
			$propGroupId = $Param{idPropertiesGroup};
			if($propGroupId == 0){
				$message{"error"} = '$Text{"you must specify a name for the group of properties"}';
				return %message;
			}
	}
	
	##-->Do insert<--
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::INSERT_TEMPLATE_FIELD_QUERY;
	$Self->{DBObject}->Prepare(SQL => $SQL, 
							   Bind => [ \$Param{id_template},
							   			 \$Param{id_metatype},
							   			 \$Param{id_list},
							   			 \$propGroupId,
							   			 \$Param{caption},
							   			 \$Param{mandatory},
							   			 \$Param{display} ] );
	
	if($Self->{DBObject}->Error() eq ""){
		$message{"ok"} = '$Text{"successfully created new template field"}';
	}else{
		$message{"error"} = "".$Self->{DBObject}->Error();
	}	
	return %message;
}

#params
# 'name': string	
# 'id': int
sub EditTemplate {		
	my ( $Self, %Param ) = @_;
	my %message = (); 
	
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::UPDATE_TEMPLATE_QUERY;
	$Self->{DBObject}->Prepare(SQL => $SQL, 
							   Bind => [ \$Param{name}, \$Param{id} ]);
	
	$message{"error"} = "";
	$message{"ok"} = "";
	if($Self->{DBObject}->Error() eq ""){						   	
		$message{"ok"} = '$Text{"successfully updated new template"}';
	}else{
		$message{"error"} = "".$Self->{DBObject}->Error();
	}
	
	return %message;	
}

#params
# 'caption': string
# 'idMetaType': int
# 'idList': int (could be null)
# 'mandatory': boolean	
# 'display'  : boolean
# 'idPropertiesGroup'   : int (could be null) 
# 'PropertiesGroupName' : string (could be null)
# 'id' : int
sub EditTemplateField {
	
	my ( $Self, %Param ) = @_;
	my %message = ();
	my $propGroupId = 1;
	my %prop = ();
	
	$message{"error"} = "";
	$message{"ok"} = "";
	
	#Property Group Validation and Creation
	if(exists($Param{PropertiesGroupName}) && ($Param{PropertiesGroupName} ne "" )){
			$propGroupId = $Self->validatePropertyGroup('PropertiesGroupName' => $Param{PropertiesGroupName});
			if($propGroupId == -1){
				$message{"error"} = '$Text{"Unable to create the group of properties"}'.' '.'$Text{"Check the Log"}';
				return %message;
			}
	}else{
			$propGroupId = $Param{idPropertiesGroup};
			if($propGroupId == 0){
				$message{"error"} = '$Text{"you must specify a name for the group of properties"}';
				return %message;
			}
	}
	
	##-->Do Update<--
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::UPDATE_TEMPLATE_FIELD_QUERY;
	$Self->{DBObject}->Prepare(SQL => $SQL, 
							   Bind => [ \$Param{id_metatype},
							   			 \$Param{id_list},
							   			 \$propGroupId,
							   			 \$Param{caption},
							   			 \$Param{mandatory},
							   			 \$Param{display},
							   			 \$Param{id} ] );
	
	if($Self->{DBObject}->Error() eq ""){
		$message{"ok"} = '$Text{"successfully updated template field"}';
	}else{
		$message{"error"} = "".$Self->{DBObject}->Error();
	}	
	return %message;
}

#params
# 'id' : int
sub DeleteTemplate {
	
	my ( $Self, %Param ) = @_;
	my %message = (); 
	$message{"error"} = "";
	$message{"ok"} = "";
	my $invalidId = -1;
	
	if($Param{id} == 1){
		$message{"error"} = '$Text{"The default template could not be deleted"}';
	}
	
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::DELETE_TEMPLATE_FIELD_QUERY;
	$Self->{DBObject}->Do(SQL => $SQL, Bind => [\$invalidId, \$Param{id} ]);
	if($Self->{DBObject}->Error() ne ""){		
		$message{"error"} = '$Text{"Unable to deleted template fields"}'.' '.'$Text{"Cause"}'.': '.$Self->{DBObject}->Error();
		return %message;
	}	
	
	$SQL = Kernel::System::InkaConfigurationItemsCtes::DELETE_TEMPLATE_QUERY;	
	$Self->{DBObject}->Do(SQL => $SQL, Bind => [\$Param{id} ]);
	
	if($Self->{DBObject}->Error() eq ""){
		$message{"ok"} = '$Text{"successfully deleted template"}';
	}else{
		$message{"error"} = "".$Self->{DBObject}->Error();
	}	
	return %message;
}

#params
# 'id' : int
sub DeleteTemplateField {
	
	my ( $Self, %Param ) = @_;
	my %message = (); 
	$message{"error"} = "";
	$message{"ok"} = "";
	my $invalidId = -1;
		
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::DELETE_TEMPLATE_FIELD_QUERY;
	$Self->{DBObject}->Do(SQL => $SQL, Bind => [\$Param{id}, \$invalidId ]);
	
	if($Self->{DBObject}->Error() eq ""){
		$message{"ok"} = '$Text{"successfully deleted template field"}';
	}else{
		$message{"error"} = "".$Self->{DBObject}->Error();
	}	
	return %message;
}

#parmas
# arrayOfFields: array of ids, of templateFields
sub DeleteTemplateFieldArray {
	
	my ( $Self, %Param ) = @_;
	my $arrayOfFields = $Param{arrayOfFields};
	my %message = ();
	my $invalidId = -1;
	$message{"error"} = "";
	$message{"ok"}	  = "";

	if(@$arrayOfFields == 0){
		$message{"error"} = '$Text{"No elements selected"}';
		return %message;
	}

	my $SQL = Kernel::System::InkaConfigurationItemsCtes::DELETE_TEMPLATE_FIELD_QUERY01." 1=0 ";
	for(my $j = 0; $j < @$arrayOfFields; $j++) {
		$SQL = $SQL." OR id=".@$arrayOfFields[$j];
	}
	$Self->{DBObject}->Do(SQL => $SQL);

	if($Self->{DBObject}->Error() eq ""){
		$message{"ok"} = '$Text{"Successfully deleted selected elements"}';
	}else{
		$message{"error"} = "".$Self->{DBObject}->Error();
	}
	return %message;
}

##Group of Properties

#Desc: this function returns the id for the given property group name passed as param. 
#	   if not exist then it will be created  	    
# params: 'PropertiesGroupName': string
# returns: The id of the PropertyGroup, id error happens returns -1
sub validatePropertyGroup {
	
	my ( $Self, %Param ) = @_;
	my %message = (); 
	my %prop = ();
	
	#first check if exits
		%prop = $Self->GetPropertiesGroupByNameOrId('name'=>$Param{PropertiesGroupName});
		unless( $prop{id} ){
			 %message = $Self->CreateNewPropertiesGroup('name'=>$Param{PropertiesGroupName});
			 if($message{"error"} ne ""){	
				
				$Self->{LogObject}->Log(
							Priority => 'error',
							Message => Kernel::System::InkaConfigurationItemsCtes::LOG_ERROR_HEADER_01.
							'Unable to create Property Group: "'.$Param{PropertiesGroupName}.'" in Database. Error :'.
							$message{"error"},
					);
					
			 	return -1;
			 }
			 %prop = $Self->GetPropertiesGroupByNameOrId('name'=>$Param{PropertiesGroupName});
			 
		}
		
		return $prop{id};		
}


# params 
#	'id': int (optional)
#	'name': str (optional)
sub GetPropertiesGroupByNameOrId {
	
	my ( $Self, %Param ) = @_;
	my %PropertieGroup = ();
	my $id=-1;
	my $name = '';
	
	if(exists($Param{id})){
		$id = $Param{id};
	}
	
	if(exists($Param{name}) && ($Param{name} ne "")){
		$name = $Param{name};
	}
	
	my @listOfColumns = (Kernel::System::InkaConfigurationItemsCtes::PROPERTIES_GROUP_COLUMNS);
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_PROPERTIES_GROUP_QUERY;
		
	$Self->{DBObject}->Prepare( SQL => $SQL, Limit => 1, Bind => [\$id, \$name] );

	if (my @Row = $Self->{DBObject}->FetchrowArray()) {
		for(my $j = 0; $j < @listOfColumns; $j++) {
			$PropertieGroup{($listOfColumns[$j])} = $Row[$j];
		}
	}
	return %PropertieGroup;
}

# params
#	'name': str (optional)
sub CreateNewPropertiesGroup {
	
	my ( $Self, %Param ) = @_;
	my %message = (); 
	
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::INSERT_PROPERTIES_GROUP_QUERY;
	$Self->{DBObject}->Prepare(SQL => $SQL, 
							   Bind => [ \$Param{name} ]);
	
	$message{"error"} = "";
	$message{"ok"} = "";
	if($Self->{DBObject}->Error() eq ""){						   	
		$message{"ok"} = '$Text{"successfully created new properties group"}';
	}else{
		$message{"error"} = "".$Self->{DBObject}->Error();
	}	
	return %message;
}

####METATYPE FUNCTIONS ###########

# params: none 
sub GetMetaTypeArray {
	
	my ( $Self, %Param ) = @_;
	my @MetaTypeArray = ();
	my $i = 0;	
	my @listOfColumns = (Kernel::System::InkaConfigurationItemsCtes::METATYPE_COLUMNS);
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_METATYPE_QUERY;
	
	$Self->{DBObject}->Prepare( SQL => $SQL);
	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
		for(my $j = 0; $j < @listOfColumns; $j++) {
			$MetaTypeArray[$i]{($listOfColumns[$j])} = $Row[$j];
		}
		$i++;
	}
	return @MetaTypeArray;	
}


1;