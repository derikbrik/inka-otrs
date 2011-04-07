#--
#Kernel/System/InkaOCSInventory.pm - core module
# Copyright (C) 2011 Juan Manuel Rodriguez
#--
#$Id: InkaOCSInventory.pm
#--
#This software comes with ABSOLUTELY NO WARRANTY. For details, see
#the enclosed file COPYING for license information (AGPL). If you
#did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
#--
package Kernel::System::InkaOCSInventory;
use strict;
use warnings;

use Kernel::System::InkaOCSICtes;
use Kernel::System::DB;
use Digest::MD5 qw(md5);
use SOAP::Lite;
use XML::Entities;
use Data::Dumper;

use Kernel::System::InkaCITemplates;
use Kernel::System::InkaCITemplatesCategory;

sub new {
	my ( $Type, %Param ) = @_;
	#allocate new hash for object
	my $Self = {};
	bless ($Self, $Type);

	# check needed objects
    for (qw(DBObject ConfigObject LogObject)) {
        $Self->{$_} = $Param{$_} || die "Got no $_!";
    }
    
    $Self->{CICategoryObject} = Kernel::System::InkaCITemplatesCategory->new(%Param);
    $Self->{CITemplateObject} = Kernel::System::InkaCITemplates->new(%Param);
	return $Self;
}

=item IsEnabled()

Description: returns 1 or 0 if the OCS Compatibility is enabled or not 

Params:
	none

Invocation:
    my $enabled = $Object->IsEnabled();
    
Return:
	1 or 0

=cut
sub IsEnabled(){
	my ( $Self, %Param ) = @_;
	my $result;
	 
	my $SQL = Kernel::System::InkaOCSICtes::GET_ENABLED;
	
	$Self->{DBObject}->Prepare(SQL => $SQL,							   
							   Limit => 1);
	
	if (my @Row = $Self->{DBObject}->FetchrowArray()) {		
			$result = $Row[0];
		
	}	
	return $result;
}

=item GetAllConfigOptions()

Description:
	All rowf for the table of OCSI config

Params:
	none

Invocation:
    my %Values = $Object->GetAllConfigOptions();
    
Return:
	a hash with the form: {key => value, ...}

=cut
sub GetAllConfigOptions(){
	my ( $Self, %Param ) = @_;
	my %results = ();
	 
	my $SQL = Kernel::System::InkaOCSICtes::GET_ALL_CONFIG_OPTIONS;
	
	$Self->{DBObject}->Prepare(SQL => $SQL);
	
	while (my @Row = $Self->{DBObject}->FetchrowArray()) {		
			$results{$Row[0]} = $Row[1];			
		
	}	
	return %results;
}

=item GetAllCategoriesToImport()

Description:
	All rows for the table of OCSI: inka_ocsi_category

Params:
	none

Invocation:
    my %Values = $Object->GetAllCategoriesToImport();
    
Return:
	an array, of hashes. Where each hash is a tupla key=>value, for the fields

=cut
sub GetAllCategoriesToImport(){
	my ( $Self, %Param ) = @_;	
	my @listOfColumns = (Kernel::System::InkaOCSICtes::OCS_CATEGORY_COLUMNS);
	my @ResultArray = ();
	my $i = 0; 
	 
	my $SQL = Kernel::System::InkaOCSICtes::GET_ALL_CATEGORY_AVAILABLE;
	
	$Self->{DBObject}->Prepare(SQL => $SQL);
	
	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
			for(my $j = 0; $j < @listOfColumns; $j++) {
				$ResultArray[$i]{($listOfColumns[$j])} = $Row[$j];
			}
			$i++;
	}	
	return @ResultArray;
}

=item saveOCSICategorisToImport()

Params:
	an array of hashes, with the following information en each hash
	
	name => 'BIOS' #or the category name
	import => 1 #or cero if the category will be imported
	selected_type=> 0 # or 1, or 2 
Invocation:
	
    my %message = $Object->saveOCSICategorisToImport('catArray' => \@auxArray);
    
Return:
	a hash, like this: { error => "", ok => ""}

=cut
sub saveOCSICategorisToImport() {
	my ( $Self, %Param ) = @_;
	my $ref = $Param{catArray};
	my @auxArray = @$ref;
	my %message = ();
	$message{"error"} = "";
	$message{"ok"} = "";

	my $SQL = Kernel::System::InkaOCSICtes::SAVE_CATEGORY;

	for(my $j = 0; $j < @auxArray; $j++) {
		my $refHash = $auxArray[$j];
		my %hashCat = %$refHash;
		unless(defined($hashCat{'import'})){
			$hashCat{'import'} = 0;
		}
		$Self->{DBObject}->Do(  SQL  => $SQL,
							    Bind => [\$hashCat{'import'}, \$hashCat{'selected_type'}, \$hashCat{'name'}]);
		if($Self->{DBObject}->Error() ne ""){
			$message{"error"} = '$Text{"Unable to update categories to import. Error was:"}'.' '.$Self->{DBObject}->Error();
			return %message;
		}
	}
	$Self->SetStatusCode( statusCode => 2);
	$message{"ok"} = 'Successfully saved categories to import';#.Data::Dumper->Dump( \@auxArray )
	return %message;
}

=item saveOCSIWebServiceParameters()

Params:
	a hash called "params" with the following att
	
	%connectionParams = ()
	$connectionParams{URL} = 'http://ocsinventory/interface' # Web Service URL
	$connectionParams{user} = 'user' #string
	$connectionParams{password} = 'pass' #string
	$connectionParams{protocol} = 'http' | 'https' # string

Invocation:
	
    my %message = $Object->saveOCSIWebServiceParameters('connectionParams' => \%connectionParams);
    
Return:
	a hash called message, like this: { error => "", ok => ""}

=cut
sub  saveOCSIWebServiceParameters(){
	my ( $Self, %Param ) = @_;
	
	my %message = ();
	my $connectionParamsaux = $Param{connectionParams};
	my %connectionParams = %$connectionParamsaux;
	my $SQL = Kernel::System::InkaOCSICtes::SAVE_WEB_SERVICE_OPTIONS;
	$message{"error"} = "";
	$message{"ok"} = "";
	
	
	foreach my $key ( keys %connectionParams )
	{
  		$Self->{DBObject}->Do(	   SQL  => $SQL,
							   Bind => [\$connectionParams{$key},
										\$key]);
		if($Self->{DBObject}->Error() ne ""){		
			$message{"error"} = '$Text{"Unable to update configuration item. Error was:"}'.' '.$Self->{DBObject}->Error();
			return %message;		
		}	
	}
	$message{"ok"} = 'Successfully saved OCS Inevntory, Web Service configuration';
	return %message;	
}

=item testOCSIWebServiceConnection()

Params:
	a hash called "params" with the following att
	
	%connectionParams = ()
	$connectionParams{URL} = 'http://ocsinventory/interface' # Web Service URL
	$connectionParams{user} = 'user' #string
	$connectionParams{password} = 'pass' #string
	$connectionParams{protocol} = 'http' | 'https' # string

Invocation:
	
    my %message = $Object->testOCSIWebServiceConnection('connectionParams' => \%connectionParams);
    
Return:
	a hash called message, like this: { error => "", ok => ""}

=cut
sub testOCSIWebServiceConnection(){
	
	my ( $Self, %Param ) = @_;
	my $connParamAux = $Param{connectionParams};
	my %connectionParams = %$connParamAux;
	my %message = ();
	$message{"error"} = "";
	$message{"ok"} = "";
	
	my $u  = $connectionParams{user};
	my $pw = $connectionParams{password};
	#cambiar estos datos por ctes
	my $c = 131071;
	my $t ="META";
	my $o =0;
	my $w =131071;
	my $f = 'get_computers_V1';
	
	my @params=(<<EOF);

	<REQUEST>
	  <ENGINE>FIRST</ENGINE>
	  <ASKING_FOR>$t</ASKING_FOR>
	  <CHECKSUM>$c</CHECKSUM>
	  <OFFSET>$o</OFFSET>
	  <WANTED>$w</WANTED>
	</REQUEST>
	
EOF

	my $lite = SOAP::Lite->uri("$connectionParams{protocol}://$connectionParams{URL}$connectionParams{path}")
  				      ->proxy("$connectionParams{protocol}://$u".($u?':':'').($u?"$pw\@":'')."$connectionParams{URL}\n")
  					  ->$f(@params);

	if($lite->fault){
  		my $errAux = XML::Entities::decode( 'all', $lite->fault->{faultstring} );
		$message{"error"} = '$Text{"Unable to connect. Error was"}'.": ".$errAux;
#		use Data::Dumper;
#		$message{"error"} .= "$connectionParams{protocol}://$connectionParams{URL}$connectionParams{path}".
#							 "$connectionParams{protocol}://$u".($u?':':'').($u?"$pw\@":'')."$connectionParams{URL}\n".Data::Dumper->Dump( \@params );
	}else{
		$message{"ok"} = '$Text{"Connection Success!"}';
	}
	return %message;
}

=item CreateNecessaryCategories()

Desc:
	This function will create all necessary Categories for support full OCS Inventory compatibility
	ERROR CODE:
		-4: unable to create categories
		 4: categories created successfully
	
Params:
	none

Invocation:
	
    $Object->CreateNecessaryCategories();
    
Return:
	hash "message" like {"ok" => "", "error" => ""}
=cut
sub CreateNecessaryCategories(){
	my ( $Self, %Param ) = @_;
	my %message = ();
	my %arrayOfParams = ();
	my @names = ();
	$message{"error"} = "";
	$message{"ok"} = "";
	my %configParams = ();
	$Self->{CICategoryObject} = Kernel::System::InkaCITemplatesCategory->new(%Param);

	$arrayOfParams{is_branch} 	= 0;
	$arrayOfParams{id_parent} 	= 4; #component
	$arrayOfParams{id_template} = 1; #default for now

	push(@names,'Other Inputs');
	push(@names,'CPU');
	push(@names,'BIOS');
	push(@names,'Memory');
	push(@names,'Storage');
	push(@names,'Sound device');
	push(@names,'Video device');
	push(@names,'Network Interface');

	foreach (@names) {

		%message = $Self->{CICategoryObject}->CreateNewCategory(
    								'id_parent'   => $arrayOfParams{id_parent},
    								'is_branch'   => $arrayOfParams{is_branch},
    								'id_template' => $arrayOfParams{id_template},
    								'name'        => $_
    						);
		if($message{"error"} ne "") { return $Self->LogError('error'=>$message{"error"}, 'errNum' => -4);}
	}

	$configParams{progress} = 4;
    %message = $Self->saveOCSIWebServiceParameters('connectionParams' => \%configParams);
    if($message{'error'} eq ""){
    	$message{'ok'} = '$Text{"Categories created successfully!"}';
    }
	return %message;
}

=item createNecessaryTemplates()

Desc:
	This function will create all necessary templates for support full OCS Inventory compatibility
	ERROR CODE:
		-3: unable to create templates
		 3: templates created successfully
	
Params:
	none

Invocation:
	
    $Object->createNecessaryTemplates();
    
Return:
	hash "message" like {"ok" => "", "error" => ""}
=cut
sub createNecessaryTemplates(){
	my ( $Self, %Param ) = @_;
	my %message = ();
	my @categories;
	$message{"error"} = "";
	$message{"ok"} = "";
	
	@categories = $Self->GetAllCategoriesToImport();
	#Create Workstation Ans Server Template
	%message = $Self->{CITemplateObject}->CreateNewTemplate( 'name' => 'ws_template');
	if($message{"error"} ne "") { return %message; } 
		
	

	return %message;
}

=item LogError()

Desc:
	Write in the log the error reported and set the "progress" atribute in the database with the corresponded error ID 
	
Params:
	'error': String
	'errNum': integer
Invocation:
	
    $Self->LogError('error'=> 'error', 'errNum' => 1);
    
Return:
	none
=cut
sub LogError(){

	my ( $Self, %Param ) = @_;
	my %connectionParams = ();
	my %message = ();	
	$message{"error"} = '$Text{"Error while activating OCS Inventory compatibility"}'.': '.$Param{error};
	$message{"ok"} = "";
	
	$Self->{LogObject}->Log(
				Priority => 'error',
				Message => $message{"error"} 
		);
	
	$connectionParams{progress} = $Param{errNum};	
    $Self->saveOCSIWebServiceParameters('connectionParams' => \%connectionParams);
    
    return %message;
		
}


=item GetStatusCode()

Description: 
	returns an integer which means the progress status of the OCSI compatibility
	if status code returned < 0 ERROR
	if status code returned > 0 some progress level was completed
	if 0 nothing was made
	
	#Status Code Legend
	0: nothing, not enabled
	1: configuration parameters Saved
	2: category selection for import made
	3: Templated created
	4: Categories created
	5: Data imported
	
	-1: Error while saving connection parameters
	-2: Error while saving category selection criteria
	-3: Error while trying to create Templates
	-4: Error while trying o create new categories
	-5: Error while importing Data

Params:
	none

Invocation:
    my $status = $Object->GetStatusCode();
    
Return:
	integer, code status

=cut
sub GetStatusCode(){
	my ( $Self, %Param ) = @_;
	my $result;
	 
	my $SQL = Kernel::System::InkaOCSICtes::GET_INSTALL_STATUS;
	
	$Self->{DBObject}->Prepare(SQL => $SQL,							   
							   Limit => 1);
	
	if (my @Row = $Self->{DBObject}->FetchrowArray()) {		
			$result = $Row[0];
		
	}	
	return $result;
}

=item SetStatusCode()

Description: 
	Set the status code (an integer which means the progress status of the OCSI compatibility)
	if status code is < 0 ERROR
	if status code is > 0 some progress level was completed
	if 0 nothing was made 

Params:
	statusCode

Invocation:
    $Object->SetStatusCode( statusCode => 1);
    
Return:
	none

=cut
sub SetStatusCode(){
	my ( $Self, %Param ) = @_;
	my $result;
	my %params = (); 
	
	$params{progress} = $Param{statusCode};	
    $Self->saveOCSIWebServiceParameters('connectionParams' => \%params);
}

=item GetImportTypeCode()

Description:
	Returns a String translated text for each type of import 
		0:
		1:
		2:

Params:
	integer: importType # 0, 1 or 2

Invocation:
    my $description = $Object->GetImportTypeCode( importType => 1);
    
Return:
	String

=cut
sub GetImportTypeCode(){
	my ( $Self, %Param ) = @_;
	my $impnum = $Param{importType};

	if($impnum == 0){ 
		return '$Text{"computer_attributes"}';
	}elsif($impnum == 1){
		return '$Text{"independent_components"}';
	}elsif($impnum == 2){
		 return '$Text{"computer_description"}';
	}
	return "";
}

1;