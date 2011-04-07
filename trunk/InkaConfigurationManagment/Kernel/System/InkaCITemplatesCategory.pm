#--
#Kernel/System/InkaCITemplatesCategory.pm - core module
# Copyright (C) 2011 Juan Manuel Rodriguez
#--
#$Id: InkaCITemplatesCategory.pm
#--
#This software comes with ABSOLUTELY NO WARRANTY. For details, see
#the enclosed file COPYING for license information (AGPL). If you
#did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
#--
package Kernel::System::InkaCITemplatesCategory;
use strict;
use warnings;

use Kernel::System::InkaConfigurationItemsCtes;
use Kernel::System::DB;

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

sub GetCategoryArray {
	
	my ( $Self, %Param ) = @_;
	
	my @listOfColumns = (Kernel::System::InkaConfigurationItemsCtes::CATEGORY_COLUMNS);	
	my @CategoryArray = ();
	my $i = 0;
	
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_CATEGORY_QUERY;
	$Self->{DBObject}->Prepare(SQL => $SQL);

	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
		for(my $j = 0; $j < @listOfColumns; $j++) {
			$CategoryArray[$i]{($listOfColumns[$j])} = $Row[$j];
		}
		$i++;
	}
	return @CategoryArray;
}

sub GetCategoryArrayOrderByParentId {
	
	my ( $Self, %Param ) = @_;
	
	my @listOfColumns = (Kernel::System::InkaConfigurationItemsCtes::CATEGORY_COLUMNS);	
	my @CategoryArray = ();
	my $i = 0;
	
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_CATEGORY_QUERY_2;
	$Self->{DBObject}->Prepare(SQL => $SQL);

	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
		for(my $j = 0; $j < @listOfColumns; $j++) {
			$CategoryArray[$i]{($listOfColumns[$j])} = $Row[$j];
		}
		$i++;
	}
	return @CategoryArray;
}


sub GetCategoryByIdArray {
	
	my ( $Self, %Param ) = @_;
	
	my @listOfColumns = (Kernel::System::InkaConfigurationItemsCtes::CATEGORY_BY_ID_COLUMNS);	
	my @CategoryArray = ();
	my $i = 0;

	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_CATEGORY_BY_ID_QUERY;
	
# 	use Data::Dumper;
#	$Data::Dumper::Terse = 1;     	
#	$Self->{LogObject}->Log(
#				Priority => 'error',
#				Message => 'JMR: ->  EJEMPLO '.$Param{Id}
#		);
	#//.Data::Dumper->Dump( \%Param )
	
	
	$Self->{DBObject}->Prepare( SQL => $SQL, Limit => 1, Bind => [\$Param{Id}] );

	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
		for(my $j = 0; $j < @listOfColumns; $j++) {
			$CategoryArray[$i]{($listOfColumns[$j])} = $Row[$j];
		}
		$i++;
	}	
	return @CategoryArray;
}

#returns the children of a category branch that are not branh itself
#params: id_parent
sub GetCategoryLeafArray {
	
	my ( $Self, %Param ) = @_;
	my @CategoryArray = ();
	my $i = 0;
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_CATEGORY_LEAF_QUERY;
	$Self->{DBObject}->Prepare(SQL => $SQL, Bind => [\$Param{id_parent}]);
	
	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
			$CategoryArray[$i]{(Kernel::System::InkaConfigurationItemsCtes::CATEGORY_LEAF_COLUMNS)[0]} = $Row[0];
			$CategoryArray[$i]{(Kernel::System::InkaConfigurationItemsCtes::CATEGORY_LEAF_COLUMNS)[1]} = $Row[1];
			$i++;
	}
	return @CategoryArray;
}

sub GetCategoryBranchsArray {
	
	my ( $Self, %Param ) = @_;
	my @CategoryArray = ();
	my $i = 0;
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_CATEGORY_BRANCHS_QUERY;
	$Self->{DBObject}->Prepare(SQL => $SQL);
	
	while (my @Row = $Self->{DBObject}->FetchrowArray()) {		
			$CategoryArray[$i]{(Kernel::System::InkaConfigurationItemsCtes::CATEGORY_BRANCHS_COLUMNS)[0]} = $Row[0];
			$CategoryArray[$i]{(Kernel::System::InkaConfigurationItemsCtes::CATEGORY_BRANCHS_COLUMNS)[1]} = $Row[1];
			$i++;
	}
	return @CategoryArray;
}

#params "category_id"
#returs an array where the firs element is the parent_id of the given category, the second is the parent_id of the first element
#       and so on
sub GetCategoryParentsInArray {
	my ( $Self, %Param ) = @_;
	my @ParentArray = ();
	my @resultArray = ();
	my $id = $Param{id};
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_CATEGORY_BRANCHS_QUERY01;
	my @columns = (Kernel::System::InkaConfigurationItemsCtes::CATEGORY_BRANCHS_COLUMNS01);
	$Self->{DBObject}->Prepare(SQL => $SQL);

	my $i =0 ;
	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
			$ParentArray[$i]{$columns[0]} = $Row[0];
			$ParentArray[$i]{$columns[1]} = $Row[1];
			$i++;
	}
	##****##
	my $flag = 1;
	my $break = 0;
	push(@resultArray, $id);
	while($flag == 1){
		$break = 0;
		for(my $j = 0; $j < @ParentArray; $j++) {
			if($id == $ParentArray[$j]{$columns[0]}){
				$id = $ParentArray[$j]{$columns[1]};
				push(@resultArray, $id);
				if($id == 1){
					$flag=0;
				}
					$break = 1;
					last;
			}
		}
		if($break == 0){
			$flag=0;
		}
	}
	return @resultArray;
}


#Insert, update and delete
    
sub DeleteCategory {
	
	my ( $Self, %Param ) = @_;
	my %message = ();
	$message{"error"} = "";
	$message{"ok"} = ""; 
	
	if($Param{id} == 1){
		$message{"error"} = '$Text{"Unable to delete category root"}';
		return %message;
	}
	
	#Bring category
	my @category = $Self->GetCategoryByIdArray(Id => $Param{id}); 
	my %catOriginal = %{$category[0]};
	##First validate that the Category do not have a branch son
	if($catOriginal{is_branch} == 1){
		
		my $SQL_branch = Kernel::System::InkaConfigurationItemsCtes::GET_CATEGORY_BY_PARENTID_QUERY.
						 Kernel::System::InkaConfigurationItemsCtes::GET_CATEGORY_BY_PARENTID_SUBQUERY_01;
		
		$Self->{DBObject}->Prepare(SQL => $SQL_branch, Bind=> [\$Param{id}]);	
		if (my @Row = $Self->{DBObject}->FetchrowArray()) {
			$message{"error"} = '$Text{"Unable to delete category because it contains an elements group"}';
			return %message;
		}
	}	
	
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::DELETE_CATEGORY_QUERY;
	$Self->{DBObject}->Do(SQL => $SQL, 
							   Bind => [\$Param{id}, \$Param{id} ]);
	$message{"error"} = "";
	$message{"ok"} = "";
	if($Self->{DBObject}->Error() eq ""){
		$message{"ok"} = '$Text{"successfully deleted category"}';
	}else{
		$message{"error"} = "".$Self->{DBObject}->Error();
	}
	return %message;
}
##Category

sub CreateNewCategory {
	
	my ( $Self, %Param ) = @_;
	my %message = ();
	
	#hack, for now is not necessary the ID_file
	$Param{id_file} = 0;
	if($Param{is_branch} eq ""){
		$Param{is_branch} = 0;
	}

	my $SQL = Kernel::System::InkaConfigurationItemsCtes::INSERT_CATEGORY_QUERY;
	my $level = $Self->CalculateCategoryLevel(\$Param{id_parent});
	$Self->{DBObject}->Prepare(SQL => $SQL, 
							   Bind => [\$Param{id_parent}, 
							   			\$Param{id_template}, 
							   			\$level, 
							   			\$Param{name},
							   			\$Param{is_branch} ]);
#\$Param{id_file},
	
	$message{"error"} = "";
	$message{"ok"} = "";
	if($Self->{DBObject}->Error() eq ""){						   	
		$message{"ok"} = '$Text{"successfully created new category"}';
	}else{
		$message{"error"} = "".$Self->{DBObject}->Error();
	}	
	return %message;
	
}

sub EditCategory {
	
	my ( $Self, %Param ) = @_;
	my %message = ();	
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::EDIT_CATEGORY_QUERY;	
	my @category = $Self->GetCategoryByIdArray(Id => $Param{id}); 
	my %catOriginal = %{$category[0]};
	my $updateLevels = 0;
	my $level = 0;
	my $SQL_branch = "";
	$message{"error"} = "";
	$message{"ok"} = "";
	
	#hack, for now is not necessary the ID_file
	$Param{id_file} = 0;
	
	#validate that the parent_id is not itself
#	$Self->{LogObject}->Log(
#				Priority => 'error',
#				Message => "INKA_CIT : Param id_parent = ".$Param{id_parent}." Param id =".\$Param{id}
#		);
	if( $Param{id_parent} == $Param{id} ){
		$message{"error"} = '$Text{"The category parent is itself!"}';
		return %message;
	}
	
	#validate if its able to change the is_branch property
	if($catOriginal{is_branch} == 1 && $Param{is_branch} == 0){
		
		$SQL_branch = Kernel::System::InkaConfigurationItemsCtes::GET_CATEGORY_BY_PARENTID_QUERY;
		$Self->{DBObject}->Prepare(SQL => $SQL_branch, Bind=> [\$Param{id}]);	
		if (my @Row = $Self->{DBObject}->FetchrowArray()) {
			$message{"error"} = '$Text{"Unable to change category, because it contains an elements group"}';
			return %message;
		}
	}
	
	if( ($catOriginal{id_parent} != $Param{id_parent} ) && $Param{is_branch} == 1 ){
		
		$updateLevels = 1;
	}
	
	$level = $Self->CalculateCategoryLevel(\$Param{id_parent});
	
	$Self->{DBObject}->Prepare(SQL => $SQL, 
							   Bind => [\$Param{id_parent}, 
							   			\$Param{id_template}, 
							   			\$level, 
							   			\$Param{name}, 
#							   			\$Param{id_file}, 
							   			\$Param{is_branch},
							   			\$Param{id},  ]);
	
	if($Self->{DBObject}->Error() ne ""){

		$Self->{LogObject}->Log(
				Priority => 'error',
				Message => Kernel::System::InkaConfigurationItemsCtes::LOG_ERROR_HEADER_01.$Self->{DBObject}->Error()
		);		
		$message{"error"} = '$Text{"Unable to update category"}';
		return %message;
	}	
	
	#if($updateLevels == 1){		
	#	%message = $Self->UpdateLevels($Param{id},$level);		
	#}
	
	
	if($message{"error"} eq ""){						   	
		$message{"ok"} = '$Text{"successfully updated category"}';
	}
		
	return %message;
	
}

##aux functions

#
# params: "id" : category parent Id
#
sub CalculateCategoryLevel {
	
	my ( $Self, %Param ) = @_;
	
	if($Param{id} == 0){
		return 0;
	}	
	my @category = $Self->GetCategoryByIdArray(Id => $Param{id}); 
	my %auxData = %{$category[0]};
	return $auxData{'level'}+1;
}

#
# params:  "id"   		: updated category id (updated)
#          "level" 		: updated category current level 
# NOTE: not in use, the field: "level" is not useful and its very hard to maintain updated 
sub UpdateLevels {
	
	my ( $Self, %Param ) = @_;
	my %message = (); 
	
	my @listOfColumns = (Kernel::System::InkaConfigurationItemsCtes::GET_CATEGORY_BY_PARENTID_COLUMNS);	
	my @CategoryArray = ();
	my $i = 0;
	my $listOfIds = "";
	my $newlevel = $Param{level}+1;

	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_CATEGORY_BY_PARENTID_QUERY;
	$Self->{DBObject}->Prepare( SQL => $SQL, Limit => 1, Bind => [\$Param{id}] );

	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
		for(my $j = 0; $j < @listOfColumns; $j++) {
			$CategoryArray[$i]{($listOfColumns[$j])} = $Row[$j];
		}
		if( $CategoryArray[$i]{is_branch} == 1 ){
			%message = $Self->UpdateLevels( id => $CategoryArray[$i]{id}, level => $newlevel );
			if($message{"error"} ne ""){
				return %message;
			} 
		}
		$i++;
		if($listOfIds eq ""){
			$listOfIds = " WHERE id= ".$CategoryArray[$i]{id};
		}else{
			$listOfIds = $listOfIds." OR id= ".$CategoryArray[$i]{id};
		}
	}
	
	my $SQL2 = Kernel::System::InkaConfigurationItemsCtes::CATEGORY_UPDATE_LEVEL.$newlevel." ".$listOfIds;
	$Self->{DBObject}->Do(SQL => $SQL2);
	
	$message{"error"} = "";
	$message{"ok"} = "";
	if($Self->{DBObject}->Error() eq ""){
		$message{"ok"} = "1";
	}else{
		$message{"error"} = '$Text{"unable to update levels, check log"}';
		$Self->{LogObject}->Log(
				Priority => 'error',
				Message => Kernel::System::InkaConfigurationItemsCtes::LOG_ERROR_HEADER_01.
				" unable to update levels for son of category, with ID:  ".$Param{id}." cause: ".$Self->{DBObject}->Error()
		);
	}
	return %message;	
}

1;