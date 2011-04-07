#--
#Kernel/System/InkaCITemplatesVendor.pm - core module
# Copyright (C) 2011 Juan Manuel Rodriguez
#--
#$Id: InkaCITemplatesVendor.pm
#--
#This software comes with ABSOLUTELY NO WARRANTY. For details, see
#the enclosed file COPYING for license information (AGPL). If you
#did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
#--
package Kernel::System::InkaCITemplatesVendor;
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

sub GetVendorByCategoryIdArray {
	
	my ( $Self, %Param ) = @_;
	my @VendorArray = ();
	my $i = 0;
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_VENDOR_QUERY;
	my @listOfColumns = (Kernel::System::InkaConfigurationItemsCtes::VENDOR_COLUMNS);
	$Self->{DBObject}->Prepare(SQL => $SQL, 
							   Bind => [\$Param{id_category}]);
	
	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
		for(my $j = 0; $j < @listOfColumns; $j++) {
			$VendorArray[$i]{($listOfColumns[$j])} = $Row[$j];
		}
		$i++;
	}	
	return @VendorArray;
}

sub GetVendorByCategoryIdArray {
	
	my ( $Self, %Param ) = @_;
	my @VendorArray = ();
	my $i = 0;
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_VENDOR_QUERY;
	my @listOfColumns = (Kernel::System::InkaConfigurationItemsCtes::VENDOR_COLUMNS);
	$Self->{DBObject}->Prepare(SQL => $SQL, 
							   Bind => [\$Param{id_category}]);
	
	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
		for(my $j = 0; $j < @listOfColumns; $j++) {
			$VendorArray[$i]{($listOfColumns[$j])} = $Row[$j];
		}
		$i++;
	}	
	return @VendorArray;
}

sub GetVendorByCategoryIdArrayForCI {
	
	my ( $Self, %Param ) = @_;
	my @VendorArray = ();
	my $i = 0;
	my $catParentArray = $Param{categoryParentsArray}; #reference to array
	
	if($$catParentArray[0] != $Param{id_category}){
		unshift(@$catParentArray,$Param{id_category});
	}
		
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_VENDOR_QUERY01;
	my @listOfColumns = (Kernel::System::InkaConfigurationItemsCtes::VENDOR_COLUMNS);


	for(my $index = 0; $index < @$catParentArray; $index++) {
			$Self->{DBObject}->Prepare(SQL => $SQL,
									   Bind => [\$$catParentArray[$index]]);
			
			while (my @Row = $Self->{DBObject}->FetchrowArray()) {
				for(my $j = 0; $j < @listOfColumns; $j++) {
					$VendorArray[$i]{($listOfColumns[$j])} = $Row[$j];
				}
				$i++;
			}			
 	} 	 	
	return @VendorArray;
}

# Params:
# id_category: int
# name: string
sub GetVendorByCategoryIdAndName {
		
	my ( $Self, %Param ) = @_;
	my %message = (); 
	my @listOfColumns = (Kernel::System::InkaConfigurationItemsCtes::VENDOR_COLUMNS);
	my @VendorArray = ();
	my $i=0;
	
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_VENDOR_QUERY02;
	$Self->{DBObject}->Prepare(SQL => $SQL, 
							   Bind => [\$Param{id_category} , \$Param{name} ]);
	
	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
		for(my $j = 0; $j < @listOfColumns; $j++) {
			$VendorArray[$i]{($listOfColumns[$j])} = $Row[$j];
		}
		$i++;
	}	
	return @VendorArray;
}

#Inserts

# Params:
# id_category: int
# name: string
sub CreateNewVendor {
		
	my ( $Self, %Param ) = @_;
	my %message = (); 
	$message{"error"} = "";
	$message{"ok"} = "";
	
	my @arayOfVendors = $Self->GetVendorByCategoryIdAndName(id_category=>$Param{id_category}, name=>$Param{name});
	
	if(@arayOfVendors>0){
		$message{"error"} ='$Text{"Vendor already exists"}';
		return %message;
	}
		
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::INSERT_VENDOR_QUERY;
	$Self->{DBObject}->Prepare(SQL => $SQL, 
							   Bind => [\$Param{id_category} , \$Param{name} ]);
	
	
	if($Self->{DBObject}->Error() eq ""){						   	
		$message{"ok"} = '$Text{"successfully created new vendor"}';
	}else{
		$message{"error"} = "".$Self->{DBObject}->Error();
	}	
	return %message;
}

# Params:
# id: int
# id_category: int
# name: string
sub EditVendor {
	
	my ( $Self, %Param ) = @_;
	my %message = (); 
	
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::UPDATE_VENDOR_QUERY;
	$Self->{DBObject}->Prepare(SQL => $SQL, 
							   Bind => [\$Param{id_category} , \$Param{name} , \$Param{id} ]);
	
	$message{"error"} = "";
	$message{"ok"} = "";
	if($Self->{DBObject}->Error() eq ""){						   	
		$message{"ok"} = '$Text{"successfully updated vendor"}';
	}else{
		$message{"error"} = "".$Self->{DBObject}->Error();
	}	
	return %message;
}
    

sub DeleteVendor {
	
	my ( $Self, %Param ) = @_;
	my %message = (); 
	
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::DELETE_VENDOR_QUERY;
	$Self->{DBObject}->Do(SQL => $SQL, 
							   Bind => [\$Param{id} ]);
	$message{"error"} = "";
	$message{"ok"} = "";
	if($Self->{DBObject}->Error() eq ""){
		$message{"ok"} = '$Text{"successfully deleted vendor"}';
	}else{
		$message{"error"} = "".$Self->{DBObject}->Error();
	}
	return %message;
}

1;