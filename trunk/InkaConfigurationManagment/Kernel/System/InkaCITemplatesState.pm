#--
#Kernel/System/InkaCITemplatesState.pm - core module
# Copyright (C) 2011 Juan Manuel Rodriguez
#--
#$Id: InkaCITemplatesState.pm
#--
#This software comes with ABSOLUTELY NO WARRANTY. For details, see
#the enclosed file COPYING for license information (AGPL). If you
#did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
#--
package Kernel::System::InkaCITemplatesState;
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

sub GetStateArray {
	
	my ( $Self, %Param ) = @_;
	my @StateArray = ();
	my $i = 0;
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_STATE_TREE_QUERY;
	$Self->{DBObject}->Prepare(SQL => $SQL);
		
	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
			$StateArray[$i]{(Kernel::System::InkaConfigurationItemsCtes::STATE_TREE_COLUMNS)[0]} = $Row[0];
			$StateArray[$i]{(Kernel::System::InkaConfigurationItemsCtes::STATE_TREE_COLUMNS)[1]} = $Row[1];
			$StateArray[$i]{(Kernel::System::InkaConfigurationItemsCtes::STATE_TREE_COLUMNS)[2]} = $Row[2];
			$StateArray[$i]{(Kernel::System::InkaConfigurationItemsCtes::STATE_TREE_COLUMNS)[3]} = $Row[3];
			$i++;
	}
	return @StateArray;
}

#
#Params:
#	"id_category"			: int
#   "categoryParentsArray"  : reference to array with all the category parents's id.
sub GetStatesByCategoryIdArrayForCI {
	
	my ( $Self, %Param ) = @_;
	my @StateArray = ();
	my $i = 0;
	my $catParentArray = $Param{categoryParentsArray}; #reference to array
	
	if($$catParentArray[0] != $Param{id_category}){
		unshift(@$catParentArray,$Param{id_category});
	}
		
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_STATE_QUERY;
	for(my $index = 0; $index < @$catParentArray; $index++) {
		if($index == 0){
			$SQL .= " WHERE ";
		}else{
			$SQL .= " OR ";	
		}
		$SQL .= " id_category = ".$$catParentArray[$index];
	}
	
	my @listOfColumns = (Kernel::System::InkaConfigurationItemsCtes::GET_STATE_COLUMNS);
	$Self->{DBObject}->Prepare(SQL => $SQL);	
	
	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
		for(my $j = 0; $j < @listOfColumns; $j++) {
			$StateArray[$i]{($listOfColumns[$j])} = $Row[$j];
		}
		$i++;
	}
	return @StateArray;
}


#Inserts

#@params: id_category: int, name: string 	
#       
sub CreateNewState {
		
	my ( $Self, %Param ) = @_;
	my %message = (); 

	my $SQL = Kernel::System::InkaConfigurationItemsCtes::INSERT_STATE_QUERY;
	$Self->{DBObject}->Prepare(SQL => $SQL, 
							   Bind => [\$Param{id_category} , \$Param{name} ]);
	
	$message{"error"} = "";
	$message{"ok"} = "";
	if($Self->{DBObject}->Error() eq ""){						   	
		$message{"ok"} = '$Text{"successfully created new state"}';
	}else{
		$message{"error"} = "".$Self->{DBObject}->Error();
	}
	
	return %message;
}

sub EditState {
	
	my ( $Self, %Param ) = @_;
	my %message = (); 
	
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::UPDATE_STATE_QUERY;
	$Self->{DBObject}->Do(SQL => $SQL, 
							   Bind => [\$Param{id_category}, \$Param{name}, \$Param{id} ]);	
	
	$message{"error"} = "";
	$message{"ok"} = "";
	if($Self->{DBObject}->Error() eq ""){
		$message{"ok"} = '$Text{"successfully updated state"}';
	}else{
		$message{"error"} = "".$Self->{DBObject}->Error();
	}
	
	return %message;	
}
    

sub DeleteState {
	
	my ( $Self, %Param ) = @_;
	my %message = (); 
	
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::DELETE_STATE_QUERY;
	$Self->{DBObject}->Do(SQL => $SQL, 
							   Bind => [\$Param{id} ]);
	$message{"error"} = "";
	$message{"ok"} = "";
	if($Self->{DBObject}->Error() eq ""){
		$message{"ok"} = '$Text{"successfully deleted state"}';
	}else{
		$message{"error"} = "".$Self->{DBObject}->Error();
	}
	return %message;
}

1;