# --
# Kernel/Modules/AdminInkaCITAjax.pm - ajax support for the admin frontend to manage config items
# Copyright (C) 2011 Juan Manuel Rodriguez
# --
# $Id: AdminInkaConfigurationItemsTemplates.pm $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AdminInkaCITAjax;

use strict;
use warnings;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.15.2.1 $) [1];

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
    $Self->{CITemplateObject} = Kernel::System::InkaConfigurationItemsTemplates->new(%Param);

    return $Self;
}
# --
sub Run {    
	my ( $Self, %Param ) = @_;
    my $JSON = '';


	if( $Self->{ParamObject}->{Query}->{ajax}[0] eq '1' ) {
		return $Self->ajaxResponse($Self,%Param);
	}else{
		return $Self->generateTabsPage($Self,%Param);
	}
}


#Ajax callback
sub ajaxResponse(){
	
	my $Self        = shift;
    my %Param       = @_;
    
    use Switch;
	switch ($Self->{ParamObject}->{Query}->{method}[0]) {

		case 'getCategory' 		  { return getCategory($Self,%Param); 	  }
		case 'getCategoryBranchs' { return getCategoryBranchArray($Self,%Param); }
		case 'insertState' 		  { return insertState($Self,%Param); 	  }
		case 'getStates'	      { return getStateArray($Self,%Param);	  }
		case 'getCategories'	  { return getCategoryArray($Self,%Param);}
		case 'getTemplates' 	  { return getTemplateArray($Self,%Param);}
		case 'deleteState'		  { return deleteState($Self,%Param);}
		
	}
   
}

#ajax function
sub getCategory(){
	
	my $Self        = shift;
    my %Param       = @_;
	my $Output		= '';
    my @categorie = ();
    my %Data = ();
    
    @categorie = $Self->{CITemplateObject}->GetCategoryByIdArray(
    		'Id' => $Self->{ParamObject}->{Query}->{id}[0]
    	);
	my %auxData = %{$categorie[0]};
   	$Data{json} = encode_json(\%auxData);
   
    $Output .= $Self->{LayoutObject}->Output(
       Data => \%Data,
       TemplateFile => 'AdminInkaCIAjax',
    );
    return $Output;
}

#ajax function
sub getCategoryBranchArray(){
	
	my $Self        = shift;
    my %Param       = @_;
	my $Output		= '';
    my %Data = ();
	my @categoryBranchs =  $Self->{CITemplateObject}->GetCategoryBranchsArray();  

   	$Data{json} = encode_json(\@categoryBranchs);
   
    $Output .= $Self->{LayoutObject}->Output(
       Data => \%Data,
       TemplateFile => 'AdminInkaCIAjax',
    );
    return $Output;
}

#ajax function
sub getStateArray(){
	
	my $Self        = shift;
    my %Param       = @_;
	my $Output		= '';
    my %Data = ();    	
	my @states =  $Self->{CITemplateObject}->GetStateArray();  

   	$Data{json} = encode_json(\@states);
   
    $Output .= $Self->{LayoutObject}->Output(
       Data => \%Data,
       TemplateFile => 'AdminInkaCIAjax',
    );
    return $Output;
}

#ajax function
sub getTemplateArray(){
	
	my $Self        = shift;
    my %Param       = @_;
	my $Output		= '';
    my %Data = ();
	my @templates =  $Self->{CITemplateObject}->GetTemplateArray();  

   	$Data{json} = encode_json(\@templates);
   
    $Output .= $Self->{LayoutObject}->Output(
       Data => \%Data,
       TemplateFile => 'AdminInkaCIAjax',
    );
    return $Output;
}

#ajax function
sub getCategoryArray(){
	
	my $Self        = shift;
    my %Param       = @_;
	my $Output		= '';
    my %Data = ();
	my @categories = $Self->{CITemplateObject}->GetCategoryArray();  

   	$Data{json} = encode_json(\@categories);
   
    $Output .= $Self->{LayoutObject}->Output(
       Data => \%Data,
       TemplateFile => 'AdminInkaCIAjax',
    );
    return $Output;
}

#ajax function
sub deleteState(){
	
	my $Self        = shift;
    my %Param       = @_;
    my $Output		= '';
    my %Data = ();
    my %dataaux;
        
	%dataaux = $Self->{CITemplateObject}->DeleteState(    		
    								'id' => $Self->{ParamObject}->{Query}->{id}[0]    								
    							);
    							    
	$Data{json} = encode_json(\%dataaux);
	$Output .= $Self->{LayoutObject}->Output(
       Data => \%Data,
       TemplateFile => 'AdminInkaCIAjax',
    );
    return $Output;
}

#ajax function
sub insertState(){
	
	my $Self        = shift;
    my %Param       = @_;
    my $Output		= '';
    my %Data = ();
    my %dataaux;
        
	use URI::Escape;
    use Switch;
    
	switch ($Self->{ParamObject}->{Query}->{id}[0]) {

		case 0 {
			%dataaux = $Self->{CITemplateObject}->CreateNewState(    		
    								'id_category' => $Self->{ParamObject}->{Query}->{id_category}[0],
#    								'name' => uri_unescape($Self->{ParamObject}->{Query}->{name}[0]),
    								'name' => $Self->{ParamObject}->{Query}->{name}[0],
    						);
		}		
		else {
			%dataaux = $Self->{CITemplateObject}->EditState(    		
									'id' => $Self->{ParamObject}->{Query}->{id}[0],
    								'id_category' => $Self->{ParamObject}->{Query}->{id_category}[0],
#    								'name' => uri_unescape($Self->{ParamObject}->{Query}->{name}[0]),
									'name' => $Self->{ParamObject}->{Query}->{name}[0],
    							);
		}
	}
    
	$Data{json} = encode_json(\%dataaux);
	$Output .= $Self->{LayoutObject}->Output(
       Data => \%Data,
       TemplateFile => 'AdminInkaCIAjax',
    );
    return $Output;
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
    $Data{Tab04} = "Generic Lists";
    $Data{Tab05} = "Help";
       
	
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

1;