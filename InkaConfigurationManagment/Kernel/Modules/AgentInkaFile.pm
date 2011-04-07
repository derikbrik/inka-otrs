# --
# Kernel/Modules/AgentInkaFile.pm - module for download files
# Copyright (C) 2011 Juan Manuel Rodriguez
# --
# $Id: AgentInkaFile.pm $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentInkaFile;

use strict;
use warnings;
use Kernel::System::InkaFile;

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
    $Self->{FileObject} = Kernel::System::InkaFile->new(%Param);

    return $Self;
}
# --
sub Run {
	my ( $Self, %Param ) = @_;
	return $Self->generateFilePage($Self,%Param);
}

sub generateFilePage(){	
	my $Self        = shift;
    my %Param       = @_;
	my $Output		= '';
    my %Data = ();

   	my %File =  $Self->{FileObject}->GetFileByID('id' => $Self->{ParamObject}->GetParam( Param => 'id'));   
#    $Output .= $Self->{LayoutObject}->Output(
#       Data => \%Data,
#       TemplateFile => 'FileTemplate',
#    );
#    return $Output;
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

1;