# --
# Kernel/Modules/AdminInkaConfigurationItemsTemplates.pm - admin frontend to manage config items
# Copyright (C) 2011 Juan Manuel Rodriguez
# --
# $Id: AdminInkaConfigurationItemsTemplates.pm,v 0.1 2010/08/18 00:00:00 mh Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AdminInkaConfigurationItemsTemplates;

use strict;
use Kernel::System::InkaCITemplates;
use Kernel::System::InkaCITemplatesCategory;
use Kernel::System::InkaCITemplatesState;
use Kernel::System::InkaCITemplatesVendor;
use Kernel::System::InkaCITemplatesGenericList;
use Kernel::System::InkaCITemplatesLink;
use Kernel::System::InkaConfigurationItemsCtes;

use Data::Dumper;
use JSON;
use URI::Escape;
use Switch;

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
    $Self->{CITemplateObject}         = Kernel::System::InkaCITemplates->new(%Param);
    $Self->{CITemplateCategoryObject} = Kernel::System::InkaCITemplatesCategory->new(%Param);
    $Self->{CITemplateStateObject}    = Kernel::System::InkaCITemplatesState->new(%Param);
    $Self->{CITemplateVendorObject}   = Kernel::System::InkaCITemplatesVendor->new(%Param);
    $Self->{CITemplateGenericListObject}   = Kernel::System::InkaCITemplatesGenericList->new(%Param);
    $Self->{CITemplateLinkObject}   	   = Kernel::System::InkaCITemplatesLink->new(%Param);

    return $Self;
}
# --
sub Run {
    my $Self        = shift;
    my %Param       = @_;

	if( $Self->{ParamObject}->{Query}->{ajax}[0] eq '1' ) {
		return $Self->ajaxResponse($Self,%Param);
	} else {
		return $Self->generateTabsPage($Self,%Param);
	}
}


#Ajax callback
sub ajaxResponse(){
	
	my $Self        = shift;
    my %Param       = @_;
    my $JsonResult	= '';
    my $Output		= '';
	my %Data = ();
    

	switch ($Self->{ParamObject}->{Query}->{method}[0]) {

		case 'getCategory' 		  { $JsonResult = $Self->getCategory(\%Param); 	  		  }
		case 'saveCategory' 	  { $JsonResult = $Self->saveCategory(\%Param); 	  	  }
		case 'deleteCategory' 	  { $JsonResult = $Self->deleteCategory(\%Param); 	  	  }
		case 'getCategoryBranchs' { $JsonResult = $Self->getCategoryBranchArray(\%Param); }
		case 'getCategoryLeaf'	  { $JsonResult = $Self->getCategoryLeafArray(\%Param);   }
		case 'saveState' 		  { $JsonResult = $Self->insertState(\%Param); 	  		  }
		case 'getStates'	      { $JsonResult = $Self->getStateArray(\%Param);	  	  }
		case 'getCategories'	  { $JsonResult = $Self->getCategoryArray(\%Param);		  }
		case 'getTemplates' 	  { $JsonResult = $Self->getTemplateArray(\%Param);		  }
		case 'deleteState'		  { $JsonResult = $Self->deleteState(\%Param);			  }
		case 'getVendors'		  { $JsonResult = $Self->getVendors(\%Param);		 	  }
		case 'saveVendor'		  { $JsonResult = $Self->saveVendor(\%Param);		 	  }
		case 'deleteVendor'		  { $JsonResult = $Self->deleteVendor(\%Param);			  }
		case 'getGenericList'	  		  	{ $JsonResult = $Self->getGenericList(\%Param);			      }
		case 'getGenericListElement'	  	{ $JsonResult = $Self->getGenericListElement(\%Param);		  }
		case 'saveGenericList'	  		  	{ $JsonResult = $Self->saveGenericList(\%Param);			  }
		case 'saveGenericListElement'	  	{ $JsonResult = $Self->saveGenericListElement(\%Param);		  }
		case 'deleteGenericList'	  	  	{ $JsonResult = $Self->deleteGenericList(\%Param);			  }
		case 'deleteGenericListElement'	  	{ $JsonResult = $Self->deleteGenericListElement(\%Param);	  }
		case 'getTemplate' 		  		  	{ $JsonResult = $Self->getTemplate(\%Param); 	  		  	  }
		case 'getTemplateFields' 		  	{ $JsonResult = $Self->getTemplateFields(\%Param); 	  		  }
		case 'saveTemplate' 		  	  	{ $JsonResult = $Self->saveTemplate(\%Param); 	  		  	  }
		case 'saveTemplateField' 		  	{ $JsonResult = $Self->saveTemplateField(\%Param); 	  		  }
		case 'deleteTemplate' 		  	  	{ $JsonResult = $Self->deleteTemplate(\%Param); 	  		  }
		case 'deleteTemplateField' 		  	{ $JsonResult = $Self->deleteTemplateField(\%Param); 	  	  }
		case 'getPropertiesGroup' 		  	{ $JsonResult = $Self->getPropertiesGroup(\%Param); 	  	  }
		case 'deleteSelectedTemplateFields' { $JsonResult = $Self->deleteSelectedTemplateFields(\%Param); }
		case 'getRelations' 				{ $JsonResult = $Self->getRelations(\%Param); 	  			  }
		case 'saveLink' 					{ $JsonResult = $Self->saveLink(\%Param); 	  			  }
		case 'deleteLink' 					{ $JsonResult = $Self->deleteLink(\%Param); 	  			  }
		
	}
	
	##Encode
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

#ajax function
sub getCategory(){
	
	my $Self        = shift;
    my %Param       = @_;	
    my @categorie = ();
    my %Data = ();
    
    @categorie = $Self->{CITemplateCategoryObject}->GetCategoryByIdArray(
    		'Id' => $Self->{ParamObject}->{Query}->{id}[0]
    	);
	my %auxData = %{$categorie[0]};
	
	return $Self->toJsonSafe('dataArray' => \%auxData);   	
}

#ajax function
sub getCategoryBranchArray(){
	
	my $Self        = shift;
    my %Param       = @_;
    my %Data = ();
	my @categoryBranchs =  $Self->{CITemplateCategoryObject}->GetCategoryBranchsArray();  

#	use Time::HiRes qw(usleep);
#	usleep(5000000);

   	return $Self->toJsonSafe('dataArray' => \@categoryBranchs);
}

sub getCategoryLeafArray(){
	
	my $Self        = shift;
    my %Param       = @_;
	
    my %Data = ();
	my @categoryLeaf =  $Self->{CITemplateCategoryObject}->GetCategoryLeafArray(
			'id_parent' => $Self->{ParamObject}->{Query}->{id}[0]
	);  

#	use Time::HiRes qw(usleep);
#	usleep(5000000);
   	
   	return $Self->toJsonSafe('dataArray' => \@categoryLeaf);
}

#ajax function
sub getStateArray(){
	
	my $Self        = shift;
    my %Param       = @_;

    my %Data = ();    	
	my @states =  $Self->{CITemplateStateObject}->GetStateArray();   	
    
    return $Self->toJsonSafe('dataArray' => \@states);
}

#ajax function
sub getTemplateArray(){
	
	my $Self        = shift;
    my %Param       = @_;
	
    my %Data = ();
	my @templates =  $Self->{CITemplateObject}->GetTemplateArray();  

   return $Self->toJsonSafe('dataArray' => \@templates);
}

#ajax function
sub getCategoryArray(){
	
	my $Self        = shift;
    my %Param       = @_;
	
    my %Data = ();
	my @categories = $Self->{CITemplateCategoryObject}->GetCategoryArray();  

   	return $Self->toJsonSafe('dataArray' => \@categories);
   	   
}

#ajax function
sub deleteState(){
	
	my $Self        = shift;
    my %Param       = @_;

    my %Data = ();
    my %dataaux;
        
	%dataaux = $Self->{CITemplateStateObject}->DeleteState(
    								'id' => $Self->{ParamObject}->{Query}->{id}[0]
    							);

	return $Self->toJsonSafe('dataArray' => \%dataaux);	
}

#ajax function
sub saveCategory(){
	my $Self        = shift;
    my %Param       = @_;
   
    my %Data = ();
    my %dataaux;
    my $name = '';
	
    
    $name = uri_unescape($Self->{ParamObject}->{Query}->{name}[0]);
    if ( !$Self->{EncodeObject}->EncodeInternalUsed() ) {
            $name = $Self->{EncodeObject}->Convert(
                Text => $name,
                From => Kernel::System::InkaConfigurationItemsCtes::INTERNAL_ENCODING,
                To   => $Self->{LayoutObject}->{UserCharset},
            );
    }
	switch ($Self->{ParamObject}->{Query}->{id}[0]) {

		case 0 {
			%dataaux = $Self->{CITemplateCategoryObject}->CreateNewCategory(    		
    								'id_parent'   => $Self->{ParamObject}->{Query}->{id_parent}[0],    							
    								'name'        => $name,
    								'is_branch'   => $Self->{ParamObject}->{Query}->{is_branch}[0],    							
    								'id_template' => $Self->{ParamObject}->{Query}->{id_template}[0],
    						);
		}else {
			%dataaux = $Self->{CITemplateCategoryObject}->EditCategory(   		
									'id'		  => $Self->{ParamObject}->{Query}->{id}[0],
    								'id_parent'   => $Self->{ParamObject}->{Query}->{id_parent}[0],    							
    								'name' 		  => $name,
    								'is_branch'   => $Self->{ParamObject}->{Query}->{is_branch}[0],    							
    								'id_template' => $Self->{ParamObject}->{Query}->{id_template}[0],
    							);
		}
	}   
	
	return $Self->toJsonSafe('dataArray' => \%dataaux);	
		
}

#ajax function
sub deleteCategory(){
	
	my $Self        = shift;
    my %Param       = @_;
 
    my %Data = ();
    my %dataaux;
        
	%dataaux = $Self->{CITemplateCategoryObject}->DeleteCategory(    		
    								'id' => $Self->{ParamObject}->{Query}->{id}[0]    								
    							);

	
	return $Self->toJsonSafe('dataArray' => \%dataaux);		
}


#ajax function
sub insertState(){
	
	my $Self        = shift;
    my %Param       = @_;
   
    my %Data = ();
    my %dataaux;
    my $name = '';
            
    $name = uri_unescape($Self->{ParamObject}->{Query}->{name}[0]);
    if ( !$Self->{EncodeObject}->EncodeInternalUsed() ) {
            $name = $Self->{EncodeObject}->Convert(
                Text => $name,
                From => Kernel::System::InkaConfigurationItemsCtes::INTERNAL_ENCODING,
                To   => $Self->{LayoutObject}->{UserCharset},
            );
    }
    
	switch ($Self->{ParamObject}->{Query}->{id}[0]) {

		case 0 {
			%dataaux = $Self->{CITemplateStateObject}->CreateNewState(    		
    								'id_category' => $Self->{ParamObject}->{Query}->{id_category}[0],    							
    								'name' => $name,
    						);
		}
		else {
			%dataaux = $Self->{CITemplateStateObject}->EditState(    		
									'id' => $Self->{ParamObject}->{Query}->{id}[0],
    								'id_category' => $Self->{ParamObject}->{Query}->{id_category}[0],
									'name' => $name,
    							);
		}
	}

	return $Self->toJsonSafe('dataArray' => \%dataaux);	
	
}
########vendors#########
#ajax function
sub getVendors(){
	
	my $Self        = shift;
    my %Param       = @_;	
    my @vendors = ();
        
    @vendors = $Self->{CITemplateVendorObject}->GetVendorByCategoryIdArray(
    		'id_category' => $Self->{ParamObject}->{Query}->{id_category}[0]
    	);	

   	return $Self->toJsonSafe('dataArray' => \@vendors);
}


#ajax function
sub saveVendor(){
	
	my $Self        = shift;
    my %Param       = @_;
   
    my %dataaux;
    my $name = '';
           
    $name = uri_unescape($Self->{ParamObject}->{Query}->{name}[0]);
    if ( !$Self->{EncodeObject}->EncodeInternalUsed() ) {
            $name = $Self->{EncodeObject}->Convert(
                Text => $name,
                From => Kernel::System::InkaConfigurationItemsCtes::INTERNAL_ENCODING,
                To   => $Self->{LayoutObject}->{UserCharset},
            );
    }    
	switch ($Self->{ParamObject}->{Query}->{id}[0]) {

		case 0 {
			%dataaux = $Self->{CITemplateVendorObject}->CreateNewVendor(    		
    								'id_category' => $Self->{ParamObject}->{Query}->{id_category}[0],    							
    								'name' => $name,
    						);
		}
		else {
			%dataaux = $Self->{CITemplateVendorObject}->EditVendor(    		
									'id' => $Self->{ParamObject}->{Query}->{id}[0],
    								'id_category' => $Self->{ParamObject}->{Query}->{id_category}[0],
									'name' => $name,
    							);
		}
	}    

	return $Self->toJsonSafe('dataArray' => \%dataaux);	
}

#ajax function
sub deleteVendor(){
	
	my $Self        = shift;
    my %Param       = @_;
    my %dataaux;

	%dataaux = $Self->{CITemplateVendorObject}->DeleteVendor(
    								'id' => $Self->{ParamObject}->{Query}->{id}[0]
    							);

	return $Self->toJsonSafe('dataArray' => \%dataaux);
}
##############Generic Lists######################
sub getGenericList(){

	my $Self        = shift;
    my %Param       = @_;
	
	my @lists =  $Self->{CITemplateGenericListObject}->GetListArray();

   	return $Self->toJsonSafe('dataArray' => \@lists);
}	
sub getGenericListElement(){

	my $Self        = shift;
    my %Param       = @_;	
            
    my @listElements = $Self->{CITemplateGenericListObject}->GetListElementArray(
    		'id_list' => $Self->{ParamObject}->{Query}->{id_list}[0]
    	);	
   	
   	return $Self->toJsonSafe('dataArray' => \@listElements);
}
sub saveGenericList(){
	
	my $Self        = shift;
    my %Param       = @_;   
    my %dataaux;
        
    my $name = uri_unescape($Self->{ParamObject}->{Query}->{name}[0]);
    
    if ( !$Self->{EncodeObject}->EncodeInternalUsed() ) {
            $name = $Self->{EncodeObject}->Convert(
                Text => $name,
                From => Kernel::System::InkaConfigurationItemsCtes::INTERNAL_ENCODING,
                To   => $Self->{LayoutObject}->{UserCharset},
            );
    }
    
	switch ($Self->{ParamObject}->{Query}->{id}[0]) {

		case 0 {
			%dataaux = $Self->{CITemplateGenericListObject}->CreateNewList(
    								'name' => $name,
    						);
		}
		else {
			%dataaux = $Self->{CITemplateGenericListObject}->EditList(    		
									'id'   => $Self->{ParamObject}->{Query}->{id}[0],
									'name' => $name,
    							);
		}
	}

	return $Self->toJsonSafe('dataArray' => \%dataaux);
}

sub saveGenericListElement(){

	my $Self        = shift;
    my %Param       = @_;   
    my %dataaux;
        
    my $name  = uri_unescape($Self->{ParamObject}->{Query}->{name}[0]);
    my $value = uri_unescape($Self->{ParamObject}->{Query}->{value}[0]);
    
    if ( !$Self->{EncodeObject}->EncodeInternalUsed() ) {
            $name = $Self->{EncodeObject}->Convert(
                Text => $name,
                From => Kernel::System::InkaConfigurationItemsCtes::INTERNAL_ENCODING,
                To   => $Self->{LayoutObject}->{UserCharset},
            );
            
			$value = $Self->{EncodeObject}->Convert(
                Text => $value,
                From => Kernel::System::InkaConfigurationItemsCtes::INTERNAL_ENCODING,
                To   => $Self->{LayoutObject}->{UserCharset},
            );
    }
    
	switch ($Self->{ParamObject}->{Query}->{id}[0]) {

		case 0 {
			%dataaux = $Self->{CITemplateGenericListObject}->CreateNewListElement(
									'id_list' => $Self->{ParamObject}->{Query}->{id_list}[0],
    								'name' 	  => $name,
    								'value'   => $value,
    						);
		}
		else {
			%dataaux = $Self->{CITemplateGenericListObject}->EditListElement(    		
									'id' => $Self->{ParamObject}->{Query}->{id}[0],
    								'name' 	  => $name,
    								'value'   => $value,
    							);
		}
	}

	return $Self->toJsonSafe('dataArray' => \%dataaux);
}

sub deleteGenericList(){
	my $Self        = shift;
    my %Param       = @_;
    my %dataaux;
        
	%dataaux = $Self->{CITemplateGenericListObject}->DeleteList(
    								'id' => $Self->{ParamObject}->{Query}->{id}[0]
    							);    							    

	return $Self->toJsonSafe('dataArray' => \%dataaux);
}

sub deleteGenericListElement(){	
	my $Self        = shift;
    my %Param       = @_;
    my %dataaux;
        
	%dataaux = $Self->{CITemplateGenericListObject}->DeleteListElement(
    								'id' => $Self->{ParamObject}->{Query}->{id}[0]
    							);    							    

	return $Self->toJsonSafe('dataArray' => \%dataaux);
}
## Template functions:

sub getTemplate(){
	my $Self        = shift;
    my %Param       = @_;	
    my %Template = ();
       
    %Template = $Self->{CITemplateObject}->GetTemplateById(
    		'id' => $Self->{ParamObject}->{Query}->{id}[0]
    	);	
	
	return $Self->toJsonSafe('dataArray' => \%Template);   	
}

sub getTemplateFields(){
	my $Self        = shift;
    my %Param       = @_;
	
	my @lists =  $Self->{CITemplateObject}->GetTemplateFieldArray( 'idTemplate' => $Self->{ParamObject}->{Query}->{id_template}[0]);

   	return $Self->toJsonSafe('dataArray' => \@lists);

}

sub saveTemplate(){
	
	my $Self        = shift;
    my %Param       = @_;   
    my %dataaux;
        
    my $name = uri_unescape($Self->{ParamObject}->{Query}->{name}[0]);
    
    if ( !$Self->{EncodeObject}->EncodeInternalUsed() ) {
            $name = $Self->{EncodeObject}->Convert(
                Text => $name,
                From => Kernel::System::InkaConfigurationItemsCtes::INTERNAL_ENCODING,
                To   => $Self->{LayoutObject}->{UserCharset},
            );
    }
    
	switch ($Self->{ParamObject}->{Query}->{id}[0]) {

		case 0 {
			%dataaux = $Self->{CITemplateObject}->CreateNewTemplate(
    								'name' => $name,
    						);
		}
		else {
			%dataaux = $Self->{CITemplateObject}->EditTemplate(    		
									'id'   => $Self->{ParamObject}->{Query}->{id}[0],
									'name' => $name,
    							);
		}
	}

	return $Self->toJsonSafe('dataArray' => \%dataaux);
}

sub saveTemplateField(){
	my $Self        = shift;
    my %Param       = @_;   
    my %dataaux;
    my $display = 0;
    my $mandatory = 0;    
        
    my $caption = uri_unescape($Self->{ParamObject}->{Query}->{caption}[0]);
    my $propertiesGroupName = uri_unescape($Self->{ParamObject}->{Query}->{propertiesGroupName}[0]);
    unless($propertiesGroupName){
    	$propertiesGroupName = '';
    }
    
    if ( !$Self->{EncodeObject}->EncodeInternalUsed() ) {
            $caption = $Self->{EncodeObject}->Convert(
                Text => $caption,
                From => Kernel::System::InkaConfigurationItemsCtes::INTERNAL_ENCODING,
                To   => $Self->{LayoutObject}->{UserCharset},
            );
    }
    
    if( $Self->{ParamObject}->{Query}->{mandatory}[0] eq "true" ){
    	$mandatory = 1;
    }
    if($Self->{ParamObject}->{Query}->{display}[0] eq "true"){
    	$display = 1;
    }
    
	switch ($Self->{ParamObject}->{Query}->{id}[0]) {

		case 0 {
			%dataaux = $Self->{CITemplateObject}->CreateNewField(
    								'caption' => $caption,
    								'propertiesGroupName' =>$propertiesGroupName,
    								'id_metatype'   	=> $Self->{ParamObject}->{Query}->{id_metatype}[0],
    								'id_list'   		=> $Self->{ParamObject}->{Query}->{id_list}[0],
    								'mandatory'   		=> $mandatory,
    								'display'   		=> $display,
    								'idPropertiesGroup' => $Self->{ParamObject}->{Query}->{idPropertiesGroup}[0],
    								'id_template' => $Self->{ParamObject}->{Query}->{id_template}[0]
    						);
		}
		else {
			%dataaux = $Self->{CITemplateObject}->EditTemplateField(    		
									'id'   => $Self->{ParamObject}->{Query}->{id}[0],
									'caption' => $caption,
									'PropertiesGroupName' =>$propertiesGroupName,
									'id_metatype'   	=> $Self->{ParamObject}->{Query}->{id_metatype}[0],
    								'id_list'   		=> $Self->{ParamObject}->{Query}->{id_list}[0],
    								'mandatory'   		=> $mandatory,
    								'display'   		=> $display,
    								'idPropertiesGroup' => $Self->{ParamObject}->{Query}->{idPropertiesGroup}[0]
    							);
		}
	}

	return $Self->toJsonSafe('dataArray' => \%dataaux);

}
sub deleteTemplate(){
	my $Self        = shift;
    my %Param       = @_;
    my %dataaux;
        
	%dataaux = $Self->{CITemplateObject}->DeleteTemplate(
    								'id' => $Self->{ParamObject}->{Query}->{id}[0]
    							);    							    

	return $Self->toJsonSafe('dataArray' => \%dataaux);
}

sub deleteTemplateField(){
	
	my $Self        = shift;
    my %Param       = @_;
    my %dataaux;
        
	%dataaux = $Self->{CITemplateObject}->DeleteTemplateField(
    								'id' => $Self->{ParamObject}->{Query}->{id}[0]
    							);    							    

	return $Self->toJsonSafe('dataArray' => \%dataaux);
}

sub deleteSelectedTemplateFields(){
	
	my $Self        = shift;
    my %Param       = @_;
    my %dataaux = ();
    my $arrayOfFields = decode_json($Self->{ParamObject}->{Query}->{'fieldArray'}[0]);
    
    
	%dataaux = $Self->{CITemplateObject}->DeleteTemplateFieldArray(
    								'arrayOfFields' => $arrayOfFields    
    							);	 
	return $Self->toJsonSafe('dataArray' => \%dataaux);
}

sub getPropertiesGroup(){
	
	my $Self        = shift;
    my %Param       = @_;
	
	my @lists =  $Self->{CITemplateObject}->GetPropertiesGroupArray();

   	return $Self->toJsonSafe('dataArray' => \@lists);
	
}

##NO Ajax functions

#param: "dataArray": hash type
sub toJsonSafe(){
	my $Self        = shift;
    my %Param       = @_;
    
    my $jsonDataStr = encode_json($Param{dataArray}); 
    $jsonDataStr =~ s/\{\\"/{\"/g;
	$jsonDataStr =~ s/\\"\}/\"}/g;
	return $jsonDataStr;

}

sub generateTabsPage(){
	
	my $Self        = shift;
    my %Param       = @_;
    my $Output		= '';
    my %Data = ();
    my %DataHeader = ();
	
    $DataHeader{Title} = "Configuration Items Template";
    
    $Data{Title} = "Configuration Items Template";
    $Data{Tab01} = "Templates";
    $Data{Tab02} = "Categories";
    $Data{Tab03} = "States";
    $Data{Tab04} = "Vendors";
    $Data{Tab05} = "Generic Lists";
    $Data{Tab06} = "Relations";
    $Data{Tab07} = "Help";
    
    #Constants
    $DataHeader{LISTA_ID} = Kernel::System::InkaConfigurationItemsCtes::META_TYPE_LIST;    
       
    # get the available metatypes
	my @MetatypeArray = $Self->{CITemplateObject}->GetMetaTypeArray();
	for(my $j = 0; $j < @MetatypeArray; $j++) {
		$Self->{LayoutObject}->Block(
				Name => 'Metatype',
				Data => {id => $MetatypeArray[$j]{id},name => $MetatypeArray[$j]{name}}
			);
	}

    # build output
    $Output .= $Self->{LayoutObject}->Output(
        Data => \%DataHeader,
        TemplateFile => 'AdminInkaHeader',
    );
    $Output .= $Self->{LayoutObject}->NavigationBar();
    $Output .= $Self->{LayoutObject}->Output(
        Data => \%Data,
        TemplateFile => 'AdminInkaCITemplates',
    );
    $Output .= $Self->{LayoutObject}->Footer();
    return $Output;

}

##Relations

sub getRelations(){
	my $Self        = shift;
    my %Param       = @_;	
    my %links = ();
      
    %links = $Self->{CITemplateLinkObject}->GetAllLinks();    	
	
	return $Self->toJsonSafe('dataArray' => \%links);   	
}

sub saveLink(){
	
	my $Self        = shift;
    my %Param       = @_;   
    my %dataaux;
        
    my $name = uri_unescape($Self->{ParamObject}->GetParam( Param => 'name'));
    my $id   = 				$Self->{ParamObject}->GetParam( Param => 'id');
    my $type = 				$Self->{ParamObject}->GetParam( Param => 'type');
    
     if ( !$Self->{EncodeObject}->EncodeInternalUsed() ) {
            $name = $Self->{EncodeObject}->Convert(
                Text => $name,
                From => Kernel::System::InkaConfigurationItemsCtes::INTERNAL_ENCODING,
                To   => $Self->{LayoutObject}->{UserCharset},
            );
    }
           
	switch ($id) {

		case 0 {
			%dataaux = $Self->{CITemplateLinkObject}->CreateNew( 								
    								'type' 				  => $type,
    								'name' 			      => $name
    						);
		} else {
			%dataaux = $Self->{CITemplateLinkObject}->Edit(
									'id'				  => $id,
    								'type' 				  => $type,
    								'name' 			      => $name
    							);
		}
	}
	return $Self->toJsonSafe('dataArray' => \%dataaux);
}

sub deleteLink(){
	
	my $Self        = shift;
    my %Param       = @_;   
    my %dataaux;
    
    my $id   = 				$Self->{ParamObject}->GetParam( Param => 'id');
    my $type = 				$Self->{ParamObject}->GetParam( Param => 'type');
           
	
	%dataaux = $Self->{CITemplateLinkObject}->Delete(
			    								'type' 				  => $type,
			    								'id' 			      => $id);
	return $Self->toJsonSafe('dataArray' => \%dataaux);
}

1;