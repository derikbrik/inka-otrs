#--
#Kernel/System/InkaCITemplatesGenericList.pm - core module
# Copyright (C) 2011 Juan Manuel Rodriguez
#--
#$Id: InkaCITemplatesGenericList.pm
#--
#This software comes with ABSOLUTELY NO WARRANTY. For details, see
#the enclosed file COPYING for license information (AGPL). If you
#did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
#--
package Kernel::System::InkaCITemplatesGenericList;
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
# no params
sub GetListArray {
	
	my ( $Self, %Param ) = @_;
	my @ListArray = ();
	my $i = 0;
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_GENERIC_LIST_QUERY;
	my @listOfColumns = (Kernel::System::InkaConfigurationItemsCtes::GENERIC_LIST_COLUMNS);
	$Self->{DBObject}->Prepare(SQL => $SQL);
	
	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
		for(my $j = 0; $j < @listOfColumns; $j++) {
			$ListArray[$i]{($listOfColumns[$j])} = $Row[$j];
		}
		$i++;
	}
	return @ListArray;
}

#Gets
#params:
#id_list: int
sub GetListElementArray {
	
	my ( $Self, %Param ) = @_;
	my @ListElementArray = ();
	my $i = 0;
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_GENERIC_LIST_ELEMENT_QUERY;
	my @listOfColumns = (Kernel::System::InkaConfigurationItemsCtes::GENERIC_LIST_ELEMENT_COLUMNS);
	$Self->{DBObject}->Prepare(SQL => $SQL, 
							   Bind => [\$Param{id_list}]);
	
	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
		for(my $j = 0; $j < @listOfColumns; $j++) {
			$ListElementArray[$i]{($listOfColumns[$j])} = $Row[$j];
		}
		$i++;
	}	
	return @ListElementArray;
}


#Inserts

# Params:
# name: string
sub CreateNewList {
		
	my ( $Self, %Param ) = @_;
	my %message = (); 
	
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::INSERT_GENERIC_LIST_QUERY;
	$Self->{DBObject}->Prepare(SQL => $SQL, 
							   Bind => [ \$Param{name} ]);
	
	$message{"error"} = "";
	$message{"ok"} = "";
	if($Self->{DBObject}->Error() eq ""){						   	
		$message{"ok"} = '$Text{"successfully created new list"}';
	}else{
		$message{"error"} = "".$Self->{DBObject}->Error();
	}	
	return %message;
}

#Inserts

#Params:
# id_list : int
# name  : string
# value : string
sub CreateNewListElement {
		
	my ( $Self, %Param ) = @_;
	my %message = (); 
	
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::INSERT_GENERIC_LIST_ELEMENT_QUERY;
	$Self->{DBObject}->Prepare(SQL => $SQL, 
							   Bind => [\$Param{id_list} , \$Param{name}, \$Param{value} ]);
	
	$message{"error"} = "";
	$message{"ok"} = "";
	if($Self->{DBObject}->Error() eq ""){						   	
		$message{"ok"} = '$Text{"successfully created new item in the list"}';
	}else{
		$message{"error"} = "".$Self->{DBObject}->Error();
	}	
	return %message;
}


# Params:
# id: int
# name: string
sub EditList {
	
	my ( $Self, %Param ) = @_;
	my %message = (); 
	
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::UPDATE_GENERIC_LIST_QUERY;
	$Self->{DBObject}->Prepare(SQL => $SQL, 
							   Bind => [\$Param{name} , \$Param{id} ]);
	
	$message{"error"} = "";
	$message{"ok"} = "";
	if($Self->{DBObject}->Error() eq ""){						   	
		$message{"ok"} = '$Text{"successfully updated list"}';
	}else{
		$message{"error"} = "".$Self->{DBObject}->Error();
	}	
	return %message;
}

# Params:
# id: int
# name  : string
# value : string
sub EditListElement {
	
	my ( $Self, %Param ) = @_;
	my %message = (); 
	
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::UPDATE_GENERIC_LIST_ELEMENT_QUERY;
	$Self->{DBObject}->Prepare(SQL => $SQL, 
							   Bind => [\$Param{name} , \$Param{value} , \$Param{id} ]);
	
	$message{"error"} = "";
	$message{"ok"} = "";
	if($Self->{DBObject}->Error() eq ""){						   	
		$message{"ok"} = '$Text{"successfully updated item list"}';
	}else{
		$message{"error"} = "".$Self->{DBObject}->Error();
	}	
	return %message;
}
    
#params:
# id: integer
sub DeleteList {
	
	my ( $Self, %Param ) = @_;
	my %message = (); 
	$message{"error"} = "";
	$message{"ok"} = "";
	
	if($Param{id} == 1){
		$message{"error"} = '$Text{"Unable to delete default list"}';
		return %message;
	}
	
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::DELETE_GENERIC_LIST_QUERY00;
	$Self->{DBObject}->Do(SQL => $SQL,Bind => [\$Param{id} ]);
	
	if($Self->{DBObject}->Error() ne ""){
		$message{"error"} = "".$Self->{DBObject}->Error();
	}
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::DELETE_GENERIC_LIST_QUERY01;
	$Self->{DBObject}->Do(SQL => $SQL,Bind => [\$Param{id} ]);	
	if($Self->{DBObject}->Error() eq ""){
		$message{"ok"} = '$Text{"successfully deleted list"}';
	}else{
		$message{"error"} = $message{"error"}." ".'$Text{"and"}'." ".$Self->{DBObject}->Error();
	}
	return %message;
}

#params:
# id: integer
sub DeleteListElement {
	
	my ( $Self, %Param ) = @_;
	my %message = (); 
	
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::DELETE_GENERIC_LIST_ELEMENT_QUERY;
	$Self->{DBObject}->Do(SQL => $SQL, 
							   Bind => [\$Param{id} ]);
	$message{"error"} = "";
	$message{"ok"} = "";
	if($Self->{DBObject}->Error() eq ""){
		$message{"ok"} = '$Text{"successfully deleted item"}';
	}else{
		$message{"error"} = "".$Self->{DBObject}->Error();
	}
	return %message;
}

1;