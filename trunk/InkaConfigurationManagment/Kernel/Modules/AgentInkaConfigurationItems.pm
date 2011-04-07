# --
# Kernel/Modules/AgentInkaConfigurationItems.pm - Agent frontend to manage config items
# Copyright (C) 2011 Juan Manuel Rodriguez
# --
# $Id: AgentInkaConfigurationItems.pm $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentInkaConfigurationItems;

use strict;
use Data::Dumper;
use JSON;
use URI::Escape;
use Switch;


use Kernel::System::InkaConfigurationItemsCtes;
use Kernel::System::InkaCITemplates;
use Kernel::System::InkaConfigurationItems;
use Kernel::System::InkaCITemplatesCategory;
use Kernel::System::InkaCITemplatesVendor;
use Kernel::System::InkaCITemplatesState;
use Kernel::System::InkaCITemplatesGenericList;
use Kernel::System::InkaFile;
use Kernel::System::InkaCITemplatesLink;
use Kernel::System::InkaOCSInventory;

sub new {
    my $Type = shift;
    my %Param = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless ($Self, $Type);
    # get common objects
    foreach (keys %Param) {
        $Self->{$_} = $Param{$_};
    }
    # check needed Opjects
    foreach (qw(ParamObject DBObject ModuleReg LogObject ConfigObject)) {
        $Self->{LayoutObject}->FatalError(Message => "Got no $_!") if (!$Self->{$_});
    }
    # create needed objects
    $Self->{CITemplateObject} 	  = Kernel::System::InkaCITemplates->new(%Param);
    $Self->{CIObject}			  = Kernel::System::InkaConfigurationItems->new(%Param);
    $Self->{CICategoryObject} 	  = Kernel::System::InkaCITemplatesCategory->new(%Param);
    $Self->{CIVendorObject} 	  = Kernel::System::InkaCITemplatesVendor->new(%Param);
    $Self->{CIStateObject} 		  = Kernel::System::InkaCITemplatesState->new(%Param);
    $Self->{CIGenericListObject}  = Kernel::System::InkaCITemplatesGenericList->new(%Param);
    $Self->{FileObject}		      = Kernel::System::InkaFile->new(%Param);
    $Self->{CITemplateLinkObject} = Kernel::System::InkaCITemplatesLink->new(%Param);
    $Self->{OCSIObject} = Kernel::System::InkaOCSInventory->new(%Param);
    return $Self;
}

# --
sub Run {
    my $Self        = shift;
    my %Param       = @_;

	#if( $Self->{ParamObject}->GetParam( Param => 'ajax' ) eq '1' ) {
	if($Self->{ParamObject}->GetParam( Param => 'ajax' ) eq '1') {
		return $Self->ajaxResponse($Self,%Param);
	}elsif($Self->{ParamObject}->GetParam( Param => 'file' ) eq '1') {
		return $Self->sendFile($Self,%Param);
	}
	return $Self->generatePage($Self,%Param);
}

#Generate main Page

sub generatePage(){
	
	my $Self        = shift;
    my %Param       = @_;
    my $Output		= '';
    my %Data = ();
    my %DataHeader = ();
    my @MainMenuArray =();
    my $SelectedSection = "AgentInkaCIList";
    my $Header = "AgentInkaCIHeader";
    my $JsonResult;
       
	$MainMenuArray[0] = { 'URL' => 'index.pl?Action=AgentInkaConfigurationItems', 					  'Name' => 'Configuration Items'};
	$MainMenuArray[1] = { 'URL' => 'index.pl?Action=AgentInkaConfigurationItems&subaction=templates', 'Name' => 'Templates'};
	$MainMenuArray[2] = { 'URL' => 'index.pl?Action=AgentInkaConfigurationItems&subaction=ocs', 	  'Name' => 'OCS Inventory'};
	$MainMenuArray[3] = { 'URL' => 'index.pl?Action=AgentInkaConfigurationItems&subaction=help', 	  'Name' => 'Help'};

    $DataHeader{Title} = "Configuration Items";
    $DataHeader{MessageOk} = ""; #to show error messages or to indicate that an action executed properly
    $DataHeader{MessageError} = ""; #to show an error messages
    $Data{Title} = "Configuration Items";
    my %message = ();

	#Generate menu
	for(my $j = 0; $j < @MainMenuArray; $j++) {
		$Self->{LayoutObject}->Block(
				Name => 'MenuArray',
				Data => {Name => $MainMenuArray[$j]{Name},URL => $MainMenuArray[$j]{URL}}
			);
	}
    	
	#Execute any method?
	switch ($Self->{ParamObject}->GetParam( Param => 'method' )) {
		case 'saveCI'						  { %message = $Self->saveCI(\%Param); 	  }
	}

	if( keys %message ) {
	 	$DataHeader{MessageOk} 	  = $message{ok};
    	$DataHeader{MessageError} = $message{error};
	}

	#Detect Subsection	
	switch ($Self->{ParamObject}->GetParam( Param => 'subaction' )) {
		case 'templates'	{ $SelectedSection = "AgentInkaCITemplates"; 
							  $Header = "AdminInkaHeader"; 
							  %Data = $Self->generateTabSection();
						   	  #Constants
						      $DataHeader{LISTA_ID} = Kernel::System::InkaConfigurationItemsCtes::META_TYPE_LIST;
							}
		case 'ciform'		{ $SelectedSection = "AgentInkaCIForm";  %Data = $Self->generateCIFormSection();    }
		case 'links'		{ 	$SelectedSection = "AgentInkaCILinks";
								%Data 			 = $Self->generateCILinkSection();
								$Header 		 = "AgentInkaCILinksHeader";
								$DataHeader{typeCount} = $Data{typeCount};
							}
		case 'history'		{ 	$SelectedSection = "AgentInkaCIHistory";
								%Data 			 = $Self->generateCIHistorySection();
								$Header 		 = "AgentInkaCIHistoryHeader";
								$DataHeader{id} = $Data{id};
							}	
		case 'ocs'			{
								$SelectedSection = "AgentInkaOCSI";
								%Data 			 = $Self->generateOCSISection();
								$Header 		 = "AgentInkaOCSIHeader";								
								$DataHeader{enabled} = $Data{enabled};
								$DataHeader{step} = $Data{step};
							}
		case 'help'			{ $SelectedSection = "AgentInkaCIHelp"; $Data{Title} = "Configuration Items Help"; }
		else 				{ $SelectedSection = "AgentInkaCIList"; }
	}

	$DataHeader{Section} = $SelectedSection;
    # build output
    $Output .= $Self->{LayoutObject}->Output(
        Data => \%DataHeader,
        TemplateFile => $Header,
    );
    $Output .= $Self->{LayoutObject}->NavigationBar();
    $Output .= $Self->{LayoutObject}->Output(
        Data => \%Data,        
        TemplateFile => 'AgentInkaCIMenu',
    );
    $Output .= $Self->{LayoutObject}->Output(
        Data => \%Data,
        TemplateFile => $SelectedSection,
    );
    $Output .= $Self->{LayoutObject}->Footer();
    return $Output;
}

sub generateCIFormSection(){
	
	my $Self        = shift;
    my %Param       = @_;	    
    my %Data = ();
    my $jsonCurrentValues;
    $Data{Button} = "Save";
    	    
	my $id = $Self->{ParamObject}->GetParam( Param => 'id' );
	if($id == 0){
		$Data{Title} = "New Configuration Item";
		my ($s,$m,$h, $D,$M,$Y) = $Self->{TimeObject}->SystemTime2Date(
			SystemTime => $Self->{TimeObject}->SystemTime(),
		);
		$Data{acquisition_day} = $D.'/'.$M.'/'.$Y;
		$jsonCurrentValues = '0';
	}else{
		$Data{Title} = "Edit Configuration Item";
		my %CurrentValues = $Self->{CIObject}->GetFullCIbyID('id' => $id);	
		#my %CurrentValuesCopy = %{ clone (\%CurrentValues) };
		%Data = (%Data,%CurrentValues);
		my @columnsToExclude = (Kernel::System::InkaConfigurationItemsCtes::GET_CI_FULL_COLUMNS_VALUES_TO_EXCLUDE);
		for(my $j = 0; $j < @columnsToExclude; $j++) {
				delete $CurrentValues{($columnsToExclude[$j])};
		}
		$jsonCurrentValues = $Self->toJsonSafe('dataArray' => \%CurrentValues);
	}

	$Data{jsonCurrValues} = $jsonCurrentValues;
	
	my %Props = $Self->{CITemplateObject}->GetPropertiesGroupByNameOrId( 'id' => 1);
	$Data{Default_Properties_Group} = $Props{name};
	
	
			
#	my @StateArray = $Self->{CIStateObject}->GetMetaTypeArray();
#	for(my $j = 0; $j < @StateArray; $j++) {
#		$Self->{LayoutObject}->Block(
#				Name => 'State',
#				Data => {id => $StateArray[$j]{id},name => $StateArray[$j]{name}}
#			);
#	}
	return %Data;
}


sub generateOCSISection(){
	
	my $Self        = shift;
    my %Param       = @_;
    my %message = ();
    my @auxArray = ();

	##check if call method to save
	switch ($Self->{ParamObject}->GetParam( Param => 'method' )) {
		case 'configureOCSIWebService'			{ %message = $Self->configureOCSIWebService(\%Param);}
		case 'configureOCSICategoriesToImport'  { %message = $Self->configureOCSICategoriesToImport(\%Param);}
	}
	my %Data = $Self->{OCSIObject}->GetAllConfigOptions();
	$Data{step} = $Data{progress};

	switch($Data{step}){

		case 1 { @auxArray = $Self->{OCSIObject}->GetAllCategoriesToImport();
					for(my $j = 0; $j < @auxArray; $j++) {
						my $refAux = $auxArray[$j];
						my %hashAux = %$refAux;
						my $strHTMLimportTypeControlStatus = 'disabled="disabled"';
						$hashAux{HTMLcheckboxState} = '';
						if($hashAux{import} == 1){
							$hashAux{HTMLcheckboxState} = 'checked="checked"';
							$strHTMLimportTypeControlStatus = '';
						}
						my @types = split(/\|/,$hashAux{types});

							$hashAux{HTMLimportTypeControl} = '<select '.$strHTMLimportTypeControlStatus.' id="select_ocsicc_'.$hashAux{"id"}.'" class="ciformInputs" name="sel_'.$hashAux{"name"}.'" >';
							for(my $k=0;$k<@types;$k++){
								my $selected = '';
								if($hashAux{selected_type} == $types[$k] ){
									$selected = 'selected="selected"';
								}
									$hashAux{HTMLimportTypeControl} .= '<option '.$selected.' value="'.$types[$k].'">'.$Self->{OCSIObject}->GetImportTypeCode('importType'=>$types[$k]).'</option>';
							}
							$hashAux{HTMLimportTypeControl} .= '</select>';

						$Self->{LayoutObject}->Block(
								Name => 'Category',
								Data => \%hashAux,
						);
					}
				}
	}

    unless($Data{enabled}){
    	$Data{enabled} = 0;
    }
	$Data{Title} = "OCSI Inventory";
	$Data{Tab01} = "Do import";
	$Data{Tab02} = "Configure web service";
	$Data{Tab03} = "Select categories";

	$Data{message_ok} 	= $message{ok};
	$Data{message_eror} = $message{error};

	return %Data;
}

sub generateCIHistorySection(){
	
	my $Self        = shift;
    my %Param       = @_;
    my %Data;
    
	my $id = $Self->{ParamObject}->GetParam( Param => 'id' );	
	%Data = $Self->{CIObject}->GetConfigurationItemById('id' => $id);
	
	$Data{Title} = "Configuration Items History";
	$Data{Button} = "Save";
	$Data{Tab01} = "State history";
	$Data{Tab02} = "Ticket history";	
	return %Data;
}


sub generateCILinkSection(){
	
	my $Self        = shift;
    my %Param       = @_;
    my %Data = ();
    my $jsonCurrentValues;
    my @cilinkcis;
    my @cilinkusers;
    my %CurrentValues;
    my %linkTypes = ();
    my %linkCount;
    my @DataBlok = ();
    
	my $id = $Self->{ParamObject}->GetParam( Param => 'id' );
	
	$Data{Title} = "Configuration Items Relations";
	$Data{Button} = "Save";
	%CurrentValues = $Self->{CIObject}->GetConfigurationItemById('id' => $id);
	%Data = (%Data,%CurrentValues);

	%linkTypes = $Self->{CITemplateLinkObject}->GetAllLinks();
	my $ciAux = $linkTypes{ci};
	my @ci = @$ciAux;
	my $userAux = $linkTypes{user};
	my @user = @$userAux;
	
	#Get Count
	%linkCount = $Self->{CITemplateLinkObject}->GetRelationCountByCIbyType('id' => $id);
	my $ciCountAux = $linkCount{ci};
	my %ciCount = %$ciCountAux;
	my $userCountAux = $linkCount{user};
	my %userCount = %$userCountAux;
	
	for(my $j = 0; $j < @ci; $j++) {
		my $countAux = $ciCount{$ci[$j]{id}};
		if($countAux eq ""){
			$countAux = 0;
		}
		$DataBlok[@DataBlok] = {'id_ci' => $id, 'id' => $ci[$j]{id}, 'name' => $ci[$j]{name}, 'linktype' => 1, 'count' => $countAux };
	}
	for(my $j = 0; $j < @user; $j++) {
		my $countAux = $userCount{$user[$j]{id}};		
		unless($countAux){
			$countAux = 0;
		}
		$DataBlok[@DataBlok] = {'id_ci'=> $id, 'id' => $user[$j]{id}, 'name' => $user[$j]{name}, 'linktype' => 2, 'count' => $countAux };
		
	}
	$Data{typeCount} = @DataBlok;
	
	for(my $j = 0; $j < @DataBlok; $j++) {
		my $refAux = $DataBlok[$j];	
		my %hashAux = %$refAux;		
		$Self->{LayoutObject}->Block(
				Name => 'Links',				
				Data => \%hashAux, 
			);
	}
	
	for(my $j = 0; $j < @DataBlok; $j++) {
		my $refAux = $DataBlok[$j];	
		my %hashAux = %$refAux;		
		$Self->{LayoutObject}->Block(
				Name => 'LinksHeader',				
				Data => \%hashAux, 
			);
	}
	
	return %Data;
}

sub generateTabSection(){
	
	my $Self        = shift;
    my %Param       = @_;
    my %Data = ();

    $Data{Title} = "Configuration Items Template";
    $Data{Tab01} = "Templates";
    $Data{Tab02} = "Categories";
    $Data{Tab03} = "States";
    $Data{Tab04} = "Vendors";
    $Data{Tab05} = "Generic Lists";
    $Data{Tab06} = "Relations";
    $Data{Tab07} = "Help";

    # get the available metatypes
	my @MetatypeArray = $Self->{CITemplateObject}->GetMetaTypeArray();

	for(my $j = 0; $j < @MetatypeArray; $j++) {
		$Self->{LayoutObject}->Block(
				Name => 'Metatype',
				Data => {id => $MetatypeArray[$j]{id},name => $MetatypeArray[$j]{name}}
			);
	}
	return %Data;
}

#Ajax callback
sub ajaxResponse(){
	
	my $Self        = shift;
    my %Param       = @_;
    my $JsonResult	= '';
    my $Output		= '';
	my %Data = ();    

	switch ($Self->{ParamObject}->GetParam( Param => 'method' )) {

		case 'getConfigurationItems' 		  	{ $JsonResult = $Self->getConfigurationItems(\%Param);  }
		case 'getVendors'					  	{ $JsonResult = $Self->getVendors(\%Param);		 	    }
		case 'getCategoryParents' 		 	  	{ $JsonResult = $Self->getCategoryParents(\%Param); 	}
		case 'getStates'		 		 	  	{ $JsonResult = $Self->getStates(\%Param); 	  			}
		case 'validateUniqueName'			  	{ $JsonResult = $Self->validateUniqueName(\%Param); 	}
		case 'getTemplateFields'			  	{ $JsonResult = $Self->getTemplateFields(\%Param); 	    }
		case 'getGenericListItems'			  	{ $JsonResult = $Self->getGenericListItems(\%Param); 	}
		case 'saveCI'						  	{ $JsonResult = $Self->saveCI(\%Param); 	  			}
		case 'getRelatedConfigurationItems'   	{ $JsonResult = $Self->getRelatedConfigurationItems(\%Param); 	  }
		case 'getRelatedUsers'   				{ $JsonResult = $Self->getRelatedUsers(\%Param); 	 			  }
		case 'getNonRelatedConfigurationItems'  { $JsonResult = $Self->getNonRelatedConfigurationItems(\%Param);  }
		case 'getNonRelatedUser'                { $JsonResult = $Self->getNonRelatedUser(\%Param); 	  	 		  }
		case 'linkUnlinkCIs'				    { $JsonResult = $Self->linkUnlinkCIs(\%Param); 	  		          }
		case 'linkUnlinkCIToUsers'				{ $JsonResult = $Self->linkUnlinkCIToUsers(\%Param); 	          }
		case 'getCIHistory'						{ $JsonResult = $Self->getCIHistory(\%Param); 	 				  }
		case 'getCITicketHistory'				{ $JsonResult = $Self->getCITicketHistory(\%Param); 	 		  }
		case 'configureOCSIWebService'			{ $JsonResult = $Self->configureOCSIWebService(\%Param);	  	  }
		case 'testOCSIWebServiceConnection'		{ $JsonResult = $Self->testOCSIWebServiceConnection(\%Param); 	  }
		case 'getProgressStatusCode'			{ $JsonResult = $Self->getProgressStatusCode(\%Param); 	 		  }
		case 'createOCSINecessaryCategories' 	{ $JsonResult = $Self->{OCSIObject}->CreateNecessaryCategories(); }
		case 'createOCSINecessaryTemplates' 	{ $JsonResult = $Self->{OCSIObject}->createNecessaryTemplates();  }
	}
	#Encode
	$JsonResult = $Self->{EncodeObject}->Convert(
                Text => $JsonResult,
                From => Kernel::System::InkaConfigurationItemsCtes::INTERNAL_ENCODING,
                To   => $Self->{LayoutObject}->{UserCharset},
    );
   	$Data{json} = $JsonResult;

   	$Output .= $Self->{LayoutObject}->Output(
       Data => \%Data,
       TemplateFile => 'AdminInkaCIAjax',
    );
    return $Output;
}


# Params: This function will take the params from the GET / POST request. This paramas are the params used by flexigrid:
# 	page: Current page shown by the flexigrid 
# 	rp: rows per page
# 	sortname: field used to order the table
# 	sortorder: "asc" or "desc"
# 	query: the string used in the search (WHERE qtype like "%query%")
# 	qtype: the field used to search
# Return: This function will return a Json Str wich represent a hash needed by flexigrid in the form of a JSON
sub getConfigurationItems(){
	
	my $Self        = shift;
    my %Param       = @_;	    
    my %Data = ();
    
	my %Data =   	$Self->{CIObject}->GetConfigurationItemArray(
		'page'  		=> $Self->{ParamObject}->GetParam( Param => 'page' ),
		'rp' 			=> $Self->{ParamObject}->GetParam( Param => 'rp' ),
		'sortname'  	=> $Self->{ParamObject}->GetParam( Param => 'sortname' ),
		'sortorder' 	=> $Self->{ParamObject}->GetParam( Param => 'sortorder' ),
		'query' 		=> $Self->{ParamObject}->GetParam( Param => 'query' ),
		'qtype' 		=> $Self->{ParamObject}->GetParam( Param => 'qtype' ),
		'colWithLink' 	=> 0,
		'urlEdit' 		=> 'index.pl?Action=AgentInkaConfigurationItems&subaction=ciform',
		'urlLink' 		=> 'index.pl?Action=AgentInkaConfigurationItems&subaction=links',
		'urlHistory' 	=> 'index.pl?Action=AgentInkaConfigurationItems&subaction=history'
	);
	return $Self->toJsonSafe('dataArray' => \%Data);
}

sub toJsonSafe(){
	my $Self        = shift;
    my %Param       = @_;

    my $jsonDataStr = encode_json($Param{dataArray});
    $jsonDataStr =~ s/\{\\"/{\"/g;
	$jsonDataStr =~ s/\\"\}/\"}/g;
	return $jsonDataStr;
}

#ajax functions

#params: "id": which represents a category_id, integer
sub getCategoryParents(){
	
	my $Self        = shift;
    my %Param       = @_;
	my $id = $Self->{ParamObject}->GetParam( Param => 'id' );
	my @parents = $Self->{CICategoryObject}->GetCategoryParentsInArray(
    		'id' => $id
    	);	
	return $Self->toJsonSafe('dataArray' => \@parents);
}

sub getStates(){
	
	my $Self        = shift;
    my %Param       = @_;
    my @states = ();
    
    my $id_category = $Self->{ParamObject}->{Query}->{id_category}[0];
    my $arrayOfParents =  decode_json(uri_unescape($Self->{ParamObject}->GetParam( Param => 'parentsJsonArray')));
    
	@states = $Self->{CIStateObject}->GetStatesByCategoryIdArrayForCI(
			'id_category'		   => $id_category,
    		'categoryParentsArray' => $arrayOfParents
	);
	return $Self->toJsonSafe('dataArray' => \@states);  
}

#param: "unique_name"
sub validateUniqueName(){
	
	my $Self        = shift;
    my %Param       = @_;
    my %Result = ();

	my $unique_name = $Self->{ParamObject}->GetParam( Param => 'unique_name' );

	$unique_name = uri_unescape($unique_name);
    if ( !$Self->{EncodeObject}->EncodeInternalUsed() ) {
            $unique_name = $Self->{EncodeObject}->Convert(
                Text => $unique_name,
                From => Kernel::System::InkaConfigurationItemsCtes::INTERNAL_ENCODING,
                To   => $Self->{LayoutObject}->{UserCharset},
            );
    }
	my $id = $Self->{CIObject}->GetCIIdByUniqueName(
    		'unique_name' => $unique_name
    	);

    if($id == 0){
    	$Result{valid} = "true";
    }else{
    	$Result{valid} = "false";
    }
	return $Self->toJsonSafe('dataArray' => \%Result);
}

sub getVendors(){
	
	my $Self        = shift;
    my %Param       = @_;	
    my @vendors = ();
    my @categories = ();
    my %category = ();
    my $id_category = $Self->{ParamObject}->{Query}->{id_category}[0];
    my $arrayOfParents =  decode_json(uri_unescape($Self->{ParamObject}->GetParam( Param => 'parentsJsonArray')));
    
    @vendors = $Self->{CIVendorObject}->GetVendorByCategoryIdArrayForCI(
    		'id_category'		   => $id_category,
    		'categoryParentsArray' => $arrayOfParents
    );
   	return $Self->toJsonSafe('dataArray' => \@vendors);
}

sub configureOCSICategoriesToImport(){
	
	my $Self        = shift;
    my %Param       = @_;
    my @auxArray = $Self->{OCSIObject}->GetAllCategoriesToImport();
	for(my $j = 0; $j < @auxArray; $j++) {
		my $refAux = $auxArray[$j];
		my %hashAux = %$refAux;
		$hashAux{import}		= $Self->{ParamObject}->GetParam( Param => 'ck_'.$hashAux{name} );
		$hashAux{selected_type} = $Self->{ParamObject}->GetParam( Param => 'sel_'.$hashAux{name} );
		$auxArray[$j] = \%hashAux;
	}
	return $Self->{OCSIObject}->saveOCSICategorisToImport('catArray' => \@auxArray);
}

# This Functions call the function of OCSIObject to save OCSI Web Service Connection params
sub configureOCSIWebService(){

	my $Self        = shift;
    my %Param       = @_;    
	my %connectionParams = ();
	$connectionParams{URL} =       $Self->{ParamObject}->GetParam( Param => 'URL'      );
	$connectionParams{user} =  	   $Self->{ParamObject}->GetParam( Param => 'user' 	   );
	$connectionParams{password} =  $Self->{ParamObject}->GetParam( Param => 'password' );
	$connectionParams{protocol} =  $Self->{ParamObject}->GetParam( Param => 'protocol' );
	$connectionParams{enabled}  =  $Self->{ParamObject}->GetParam( Param => 'enabled'  );
	$connectionParams{path} 	=  $Self->{ParamObject}->GetParam( Param => 'path' 	   );
	$connectionParams{"progress"} = 1;
    return $Self->{OCSIObject}->saveOCSIWebServiceParameters('connectionParams' => \%connectionParams);    
}

sub testOCSIWebServiceConnection(){
	
	my $Self        = shift;
    my %Param       = @_;    
	my %connectionParams = ();
	$connectionParams{URL} =       uri_unescape($Self->{ParamObject}->GetParam( Param => 'URL'  ));
	$connectionParams{user} =  	   uri_unescape($Self->{ParamObject}->GetParam( Param => 'user' ));
	$connectionParams{password} =  uri_unescape($Self->{ParamObject}->GetParam( Param => 'password' ));
	$connectionParams{protocol} =  $Self->{ParamObject}->GetParam( Param => 'protocol' );
	$connectionParams{path} =   uri_unescape($Self->{ParamObject}->GetParam( Param => 'path' ));
	
	my %message = $Self->{OCSIObject}->testOCSIWebServiceConnection('connectionParams' => \%connectionParams);
	return $Self->toJsonSafe('dataArray' => \%message); 
}

#
#This function expect all the fields send by the CIForm.  
sub saveCI(){
	
	my $Self    = shift;
    my %Param   = @_;
    my %ci 		= ();
    my %message = ();
    my $fileToDelte = 0;
    my $newVendor = $Self->{ParamObject}->GetParam( Param => 'newVendor');
    # 	get current time

	my ($s,$m,$h, $D,$M,$Y) = $Self->{TimeObject}->SystemTime2Date(
		SystemTime => $Self->{TimeObject}->SystemTime(),
	);
    

    $ci{'id'}  = $Self->{ParamObject}->GetParam( Param => 'id');
	$ci{'id_category'} 	 	= $Self->{ParamObject}->GetParam( Param => 'id_category');
	$ci{'unique_name'} 		= $Self->{ParamObject}->GetParam( Param => 'unique_name');
	$ci{'serial_number'} 	= $Self->{ParamObject}->GetParam( Param => 'serial_number');
	$ci{'id_provider'}   	= $Self->{ParamObject}->GetParam( Param => 'id_provider');
	$ci{'id_state'} 	 	= $Self->{ParamObject}->GetParam( Param => 'id_state');
	$ci{'cost'} 	     	= $Self->{ParamObject}->GetParam( Param => 'cost');
	$ci{'acquisition_day'}  = $Self->{ParamObject}->GetParam( Param => 'acquisition_day');
	$ci{'creation_date'}  	= $D.'/'.$M.'/'.$Y;
	$ci{'description'} 		= $Self->{ParamObject}->GetParam( Param => 'Body');
	
	##Get all generic fields
	my @templateFieldArray = $Self->{CITemplateObject}->GetTemplateFieldArrayByCategoryId('id_category' => $ci{'id_category'} );

	$ci{'extra_fields_count'}	= ''.@templateFieldArray;
	
	for(my $i=0;$i<@templateFieldArray;$i++){
		my %ciproperty = ();
			$ciproperty{'value'} = $Self->{ParamObject}->GetParam( Param => 'generic_'.$templateFieldArray[$i]{id});
			$ciproperty{'id_metatype'} = $templateFieldArray[$i]{id_metatype};
			$ciproperty{'id_template_property'} = $templateFieldArray[$i]{id};
			$ciproperty{'name'} = $templateFieldArray[$i]{caption};
			##check for file
			if($ciproperty{'id_metatype'} == Kernel::System::InkaConfigurationItemsCtes::META_TYPE_FILE){
				%message = $Self->adminFiles( 'ciproperty'=>\%ciproperty, 'ci_id'=>$ci{'id'} );
				if($message{id} != -1){
					$ciproperty{'value'} = $message{id};
				}else{
					return %message;
				}
				$fileToDelte = $message{id_delete};
			}
			##########################
		$ci{'extra_fields_'.$i}  = \%ciproperty;
	}
	####end get generic fields####

	##Create New Vendor if "other" was selected
	if(($newVendor ne "") && ($ci{'id_provider'} == -1) ){
		my %messageResult = $Self->{CIVendorObject}->CreateNewVendor(id_category => $ci{'id_category'} , name=> $newVendor);
		if($messageResult{"error"} ne ""){
			return 	%messageResult;
		}
		my @vendor =  $Self->{CIVendorObject}->GetVendorByCategoryIdAndName(id_category=> $ci{'id_category'} , name=> $newVendor);
    	$ci{'id_provider'}  = $vendor[0]{id};
    }
    ##end create new Vendor

    if($ci{'id'} == 0){
		%message = $Self->{CIObject}->CreateNewCI('ci' => \%ci, 'userId' => $Self->{UserID});
    }else{
    	%message = $Self->{CIObject}->UpdateCI('ci' => \%ci, 'userId' => $Self->{UserID});
    }
        
    ##Delete OldFile
    if($fileToDelte){
    	my %auxmessage = $Self->{FileObject}->DeleteFileByID('id' => $fileToDelte);
			if($auxmessage{"error"} ne ""){
				$auxmessage{"id"} = -1;
				return %auxmessage;
			}
    }
	return %message;
}

#Expected GET params:
#   "id_list": integer
sub getGenericListItems(){
	my $Self        = shift;
    my %Param       = @_;
    	
	my @genericListItems =   $Self->{CIGenericListObject}->GetListElementArray(
				'id_list' => $Self->{ParamObject}->GetParam( Param => 'id_list')
	);	
	return $Self->toJsonSafe('dataArray' => \@genericListItems);
}

#params: "id_category", int
sub getTemplateFields(){
	
	my $Self        = shift;
    my %Param       = @_;	
	my @templateFieldArray = $Self->{CITemplateObject}->GetTemplateFieldArrayByCategoryId(
				'id_category' => $Self->{ParamObject}->GetParam( Param => 'id_category')
	);	
	return $Self->toJsonSafe('dataArray' => \@templateFieldArray);
}

## FILE
sub sendFile(){

	my $Self        = shift;
    my %Param       = @_;
	my $Output		= '';
    my %Data = ();

   	my %File =  $Self->{FileObject}->GetFileByID('id' => $Self->{ParamObject}->GetParam( Param => 'id'));

	if(%File){
		return $Self->{LayoutObject}->Attachment(
	        Type        => 'inline',
	        Filename    => $File{filename},
	        ContentType => $File{content_type},
	        Content     => $File{content},
	    );
	}else{
		return $Self->{LayoutObject}->Attachment(
	        Type        => 'inline',
	        Filename    => 'unkwnown.txt',
	        ContentType => 'text',
	        Content     => ''
	    );
	}
}

#
=item adminFiles()	
	This function stores a FILE in the database and return the id. Also delete an existing file and stores a new in case o edition
	This function will take the filename and content form the REQUEST (POST or GET) variables
parameters:
	'ciproperty': hash wich represent a ci property for metatype=FILE 
	'ci_id' : id integer

invoke:
	-> $Self->adminFiles(	'ciproperty'=>\%ciproperty, 
							'ci_id'=>1 );			
returns:
	%message, which is an array like:
	(
		"ok" => "message to display is everithing is ok otherwise empy"
		"error" => "message to display in case error otherwise empty"
		"id" => 1 #last inserted id, -1 if not was able to get the file
	)

=cut
sub adminFiles(){
	
	my $Self        = shift;
    my %Param       = @_;	
	my $id = $Param{ci_id};		
    my $ciaux = $Param{ciproperty};
	my %ciprop = %$ciaux;
	my %message;
	$message{"id"} = 0;	
	$message{"id_delete"} = 0;
	my $returned_id = 0; 
					
	my %File = $Self->{ParamObject}->GetUploadAll(
                Param  => 'generic_'.$ciprop{'id_template_property'}.'_name',
                Source => 'string',
    );    

	if($id == 0){
		#is new, always store file
		%message = $Self->{FileObject}->CreateNew('file'=>\%File);
	}else{
		#Get the old file ID From Database
		my %ciPropValues = $Self->{CIObject}->GetCIProperty('id_ci' => $id, 'id_template_property' => $ciprop{'id_template_property'});

		if($ciPropValues{id_file} != $ciprop{'value'}){			
			#Create new
			if($ciprop{'value'} == 0){				
				%message = $Self->{FileObject}->CreateNew('file'=>\%File);				
			}
			#Store the id to delete the previus old file
			$message{"id_delete"} = $ciPropValues{id_file};
		}else{
			$message{"id"} = $ciPropValues{id_file};
		}
	}
	return %message;
}

=item getRelatedConfigurationItems()

	Function used to populate the flexigrid in the Relation Section of CI 
=cut
sub getRelatedConfigurationItems(){
	
	my $Self        = shift;
    my %Param       = @_;	    
    my %Data = ();
    
    my $showInverse =  $Self->{ParamObject}->GetParam( Param => 'showInverse' );
    unless($showInverse){
    	$showInverse=0;
    }elsif($showInverse eq ""){
    	$showInverse=0;
    }
    
	my %Data =   $Self->{CITemplateLinkObject}->GetAllCILinkedTo(
		'id_ci'  		=> $Self->{ParamObject}->GetParam( Param => 'id_ci' ),
		'id_type'  		=> $Self->{ParamObject}->GetParam( Param => 'id_type' ),
		'page'  	=> $Self->{ParamObject}->GetParam( Param => 'page' ),
		'rp' 		=> $Self->{ParamObject}->GetParam( Param => 'rp' ),
		'sortname'  => $Self->{ParamObject}->GetParam( Param => 'sortname' ),
		'sortorder' => $Self->{ParamObject}->GetParam( Param => 'sortorder' ),
		'query' 	=> $Self->{ParamObject}->GetParam( Param => 'query' ),
		'qtype' 	=> $Self->{ParamObject}->GetParam( Param => 'qtype' ),
		'showInverse'	=> $showInverse
	);
	return $Self->toJsonSafe('dataArray' => \%Data);
}

=item getRelatedConfigurationItems()

	Function used to populate the flexigrid in the Relation Section of CI for Users
=cut
sub getRelatedUsers(){
	
	my $Self        = shift;
    my %Param       = @_;	    
    my %Data = ();
    
	my %Data =   $Self->{CITemplateLinkObject}->GetAllUserLinkedTo(
		'id_ci'  	=> $Self->{ParamObject}->GetParam( Param => 'id_ci' ),
		'id_type'  	=> $Self->{ParamObject}->GetParam( Param => 'id_type' ),
		'page'  	=> $Self->{ParamObject}->GetParam( Param => 'page' ),
		'rp' 		=> $Self->{ParamObject}->GetParam( Param => 'rp' ),
		'sortname'  => $Self->{ParamObject}->GetParam( Param => 'sortname' ),
		'sortorder' => $Self->{ParamObject}->GetParam( Param => 'sortorder' ),
		'query' 	=> $Self->{ParamObject}->GetParam( Param => 'query' ),
		'qtype' 	=> $Self->{ParamObject}->GetParam( Param => 'qtype' )
	);
	return $Self->toJsonSafe('dataArray' => \%Data);
}

sub getNonRelatedUser(){
	
	my $Self        = shift;
    my %Param       = @_;	    
    my %Data = ();
    
	my %Data =   $Self->{CITemplateLinkObject}->GetAllUserNotLinkedTo(
		'id_ci'  	=> $Self->{ParamObject}->GetParam( Param => 'id_ci' ),
		'id_type'  	=> $Self->{ParamObject}->GetParam( Param => 'id_type' ),
		'page'  	=> $Self->{ParamObject}->GetParam( Param => 'page' ),
		'rp' 		=> $Self->{ParamObject}->GetParam( Param => 'rp' ),
		'sortname'  => $Self->{ParamObject}->GetParam( Param => 'sortname' ),
		'sortorder' => $Self->{ParamObject}->GetParam( Param => 'sortorder' ),
		'query' 	=> $Self->{ParamObject}->GetParam( Param => 'query' ),
		'qtype' 	=> $Self->{ParamObject}->GetParam( Param => 'qtype' )
	);
	return $Self->toJsonSafe('dataArray' => \%Data);
} 


=item getRelatedConfigurationItems()

	Function used to populate the flexigrid in the Relation Section of CI whith all the NON CI
=cut
sub getNonRelatedConfigurationItems(){
	
	my $Self        = shift;
    my %Param       = @_;	    
    my %Data = ();
    
	my %Data =   $Self->{CITemplateLinkObject}->GetAllCINonLinkedTo(
		'id_ci'  		=> $Self->{ParamObject}->GetParam( Param => 'id_ci' ),
		'id_type'  		=> $Self->{ParamObject}->GetParam( Param => 'id_type' ),
		'page'  	=> $Self->{ParamObject}->GetParam( Param => 'page' ),
		'rp' 		=> $Self->{ParamObject}->GetParam( Param => 'rp' ),
		'sortname'  => $Self->{ParamObject}->GetParam( Param => 'sortname' ),
		'sortorder' => $Self->{ParamObject}->GetParam( Param => 'sortorder' ),
		'query' 	=> $Self->{ParamObject}->GetParam( Param => 'query' ),
		'qtype' 	=> $Self->{ParamObject}->GetParam( Param => 'qtype' )
	);
	return $Self->toJsonSafe('dataArray' => \%Data);
}

=item linkUnlinkCIs()

	This functions links or unlinks CI. Check all the parameters from the REQUEST

REQUEST parameteres:

	arrayOfCIIds : string json # like: ["1","2","3"]
	id : integer # id of the current CI
	operation : string # could be "unlink" or "link"
	link_type : integer # teh corresponding id of relation
=cut
sub linkUnlinkCIs(){

	my $Self        = shift;
    my %Param       = @_;
    my %dataaux = ();
    my $arrayOfCIIds = decode_json($Self->{ParamObject}->GetParam( Param => 'id_array' ));

    if( $Self->{ParamObject}->GetParam( Param => 'operation' )  eq 'unlink'){
    	%dataaux = $Self->{CITemplateLinkObject}->unlinkCIs(
										'id' 		   => $Self->{ParamObject}->GetParam( Param => 'id' ),
	    								'arrayOfCIIds' => $arrayOfCIIds,
	    								'link_type'    => $Self->{ParamObject}->GetParam( Param => 'link_type' )
	    							);

    }else{
		%dataaux = $Self->{CITemplateLinkObject}->linkCIs(
										'id' 		   => $Self->{ParamObject}->GetParam( Param => 'id' ),
	    								'arrayOfCIIds' => $arrayOfCIIds,
	    								'link_type'    => $Self->{ParamObject}->GetParam( Param => 'link_type' )
	    							);
    }
	return $Self->toJsonSafe('dataArray' => \%dataaux);
}

=item linkUnlinkCIToUsers()

	This functions links or unlinks CI to users. Check all the parameters from the REQUEST

REQUEST parameteres:

	user_id_array : string json # like: ["1","2","3"]
	id : integer # id of the current CI
	operation : string # could be "unlink" or "link"
	link_type : integer # teh corresponding id of relation
=cut
sub linkUnlinkCIToUsers(){

	my $Self        = shift;
    my %Param       = @_;
    my %dataaux = ();
    my $arrayOfUserId = decode_json($Self->{ParamObject}->GetParam( Param => 'id_array' ));

    if( $Self->{ParamObject}->GetParam( Param => 'operation' )  eq 'unlink'){
    	%dataaux = $Self->{CITemplateLinkObject}->unlinkCIToUser(
										'id' 		   => $Self->{ParamObject}->GetParam( Param => 'id' ),
	    								'userIdArray' => $arrayOfUserId,
	    								'link_type'    => $Self->{ParamObject}->GetParam( Param => 'link_type' )
	    							);

    }else{
		%dataaux = $Self->{CITemplateLinkObject}->linkCIToUser(
										'id' 		   => $Self->{ParamObject}->GetParam( Param => 'id' ),
	    								'userIdArray' => $arrayOfUserId,
	    								'link_type'    => $Self->{ParamObject}->GetParam( Param => 'link_type' )
	    							);
    }
	return $Self->toJsonSafe('dataArray' => \%dataaux);
}

#
=item GetCIHistory()

	Function used to populate the flexigrid in the History Section of CI
=cut
sub getCIHistory(){

	my $Self        = shift;
    my %Param       = @_;    
    my %Data = ();

	%Data =   $Self->{CIObject}->GetCIHistory(
		'id_ci'  		=> $Self->{ParamObject}->GetParam( Param => 'id_ci' ),
		'page'  	=> $Self->{ParamObject}->GetParam( Param => 'page' ),
		'rp' 		=> $Self->{ParamObject}->GetParam( Param => 'rp' ),
		'sortname'  => $Self->{ParamObject}->GetParam( Param => 'sortname' ),
		'sortorder' => $Self->{ParamObject}->GetParam( Param => 'sortorder' ),
		'query' 	=> $Self->{ParamObject}->GetParam( Param => 'query' ),
		'qtype' 	=> $Self->{ParamObject}->GetParam( Param => 'qtype' )
	);
	return $Self->toJsonSafe('dataArray' => \%Data);
}

=item GetCITicketHistory()

	Function used to populate the flexigrid in the History Ticket Section of CI
=cut
sub getCITicketHistory(){

	my $Self        = shift;
    my %Param       = @_;    
    my %Data = ();

	%Data =   $Self->{CIObject}->GetCITicketHistory(
		'id_ci'  	=> $Self->{ParamObject}->GetParam( Param => 'id_ci' ),
		'page'  	=> $Self->{ParamObject}->GetParam( Param => 'page' ),
		'rp' 		=> $Self->{ParamObject}->GetParam( Param => 'rp' ),
		'sortname'  => $Self->{ParamObject}->GetParam( Param => 'sortname' ),
		'sortorder' => $Self->{ParamObject}->GetParam( Param => 'sortorder' ),
		'query' 	=> $Self->{ParamObject}->GetParam( Param => 'query' ),
		'qtype' 	=> $Self->{ParamObject}->GetParam( Param => 'qtype' ),
		'colWithLink' 	=> 0,
		'urlEdit' 		=> 'index.pl?Action=AgentTicketZoom&TicketID=',
	);
	return $Self->toJsonSafe('dataArray' => \%Data);
}


=item getProgressStatusCode()

	Function used to return the status code for the compatibility between OTRS and OSCInventory
=cut
sub getProgressStatusCode(){
	my $Self        = shift;
    my %Param       = @_;    
    my $statusCode = ();

	$statusCode =   $Self->{OCSIObject}->GetStatusCode();
	return $Self->toJsonSafe('dataArray' => \$statusCode);	
}


1;