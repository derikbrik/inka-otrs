# --
# Kernel/System/LinkObject/LinkObjectInkaConfigurationItem.pm - to link ConfigurationItem objects
# Copyright (C) 2011 Juan Manuel Rodriguez
# --
# $Id: LinkObjectInkaConfigurationItem.pm $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see http://www.gnu.org/licenses/gpl-2.0.txt.
# --

package Kernel::Output::HTML::LinkObjectInkaConfigurationItem;

use strict;
use warnings;

use Kernel::Output::HTML::Layout;
use Kernel::System::InkaCITemplatesCategory;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.7 $) [1];

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    for my $Object (
        qw(ConfigObject LogObject MainObject DBObject UserObject EncodeObject
        QueueObject GroupObject ParamObject TimeObject LanguageObject UserLanguage UserID)
        )
    {
        $Self->{$Object} = $Param{$Object} || die "Got no $Object!";
    }

    $Self->{LayoutObject} = Kernel::Output::HTML::Layout->new( %{$Self} );
    $Self->{CICategoryObject} = Kernel::System::InkaCITemplatesCategory->new(%Param);
    # define needed variables
    $Self->{ObjectData} = {
        Object   => 'InkaConfigurationItem',
        Realname => 'Configuration Item',
    };
    return $Self;
}

sub TableCreateComplex {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ObjectLinkListWithData} || ref $Param{ObjectLinkListWithData} ne 'HASH' ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'Need ObjectLinkListWithData!',
        );
        return;
    }
	
    # convert the list
    my %LinkList;
    for my $LinkType ( keys %{ $Param{ObjectLinkListWithData} } ) {

        # extract link type List
        my $LinkTypeList = $Param{ObjectLinkListWithData}->{$LinkType};

        for my $Direction ( keys %{$LinkTypeList} ) {

            # extract direction list
            my $DirectionList = $Param{ObjectLinkListWithData}->{$LinkType}->{$Direction};

            for my $CIID ( keys %{$DirectionList} ) {

                $LinkList{$CIID}->{Data} = $DirectionList->{$CIID};
            }
        }
    }

    # create the item list
    my @ItemList;
    for my $CIID ( sort { $a <=> $b } keys %LinkList ) {

        # extract faq data
        my $CI = $LinkList{$CIID}->{Data};

        my @ItemColumns = (
            {
                Type    => 'Link',
                Key     => $CIID,
                Content => $CI->{unique_name},
                Link    => '$Env{"Baselink"}Action=AgentInkaConfigurationItems&subaction=ciform&id=1='.$CIID,
            },
            {
                Type      => 'Text',
                Content   => $CI->{serial_number},
                MaxLength => 50,
            },
            {
                Type      => 'Text',
                Content   => $CI->{category},
                Translate => 1,
            },
            {
                Type    => 'Text',
                Content => $CI->{state},
            },
            {
                Type    => 'Text',
                Content => $CI->{provider},
            },
        );
        push @ItemList, \@ItemColumns;
    }

    return if !@ItemList;

    # define the block data

    my %Block   = (
        Object    => $Self->{ObjectData}->{Object},
        Blockname => $Self->{ObjectData}->{Realname},
        Headline  => [
            {
                Content => 'Unique name',
                Width   => 130,
            },
            {
                Content => 'Serial number',
            },
            {
                Content => 'Category',
                Width   => 110,
            },
            {
                Content => 'State',
                Width   => 110
            },
            {
                Content => 'Vendor',
                Width   => 110
            }
        ],
        ItemList => \@ItemList,
    );
    return ( \%Block );
}

sub TableCreateSimple {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ObjectLinkListWithData} || ref $Param{ObjectLinkListWithData} ne 'HASH' ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'Need ObjectLinkListWithData!',
        );
        return;
    }

    #my $FAQHook = $Self->{ConfigObject}->Get('FAQ::FAQHook');
    my %LinkOutputData = ();
#    for my $LinkType ( keys %{ $Param{ObjectLinkListWithData} } ) {
#
#        # extract link type List
#        my $LinkTypeList = $Param{ObjectLinkListWithData}->{$LinkType};
#
#        for my $Direction ( keys %{$LinkTypeList} ) {
#
#            # extract direction list
#            my $DirectionList = $Param{ObjectLinkListWithData}->{$LinkType}->{$Direction};
#
#            my @ItemList;
#            for my $FAQID ( sort { $a <=> $b } keys %{$DirectionList} ) {
#
#                # extract tickt data
#                my $FAQ = $DirectionList->{$FAQID};
#
#                # define item data
#                my %Item = (
#                    Type    => 'Link',
#                    Content => 'F:' . $FAQ->{Number},
#                    Title   => "$FAQHook$FAQ->{Number}: $FAQ->{Title}",
#                    Link    => '$Env{"Baselink"}Action=AgentFAQ&ItemID=' . $FAQID,
#                );
#                push @ItemList, \%Item;
#            }
#
#            # add item list to link output data
#            $LinkOutputData{ $LinkType . '::' . $Direction }->{FAQ} = \@ItemList;
#        }
#    }

    return %LinkOutputData;
}

sub ContentStringCreate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ContentData} ) {
        $Self->{LogObject}->Log( Priority => 'error', Message => 'Need ContentData!' );
        return;
    }

    return;
}

sub SelectableObjectList {
    my ( $Self, %Param ) = @_;

    my $Selected;
    if ( $Param{Selected} && $Param{Selected} eq $Self->{ObjectData}->{Object} ) {
        $Selected = 1;
    }

    # object select list
    my @ObjectSelectList = (
        {
            Key      => $Self->{ObjectData}->{Object},
            Value    => $Self->{ObjectData}->{Realname},
            Selected => $Selected,
        },
    );

    return @ObjectSelectList;
}

sub SearchOptionList {
    my ( $Self, %Param ) = @_;

	my @SearchOptionList = (
        {
            Key  => 'InkaCIcategory',
            Name => 'Category',
            Type => 'List',
        },
        {
            Key  => 'InkaCIserialNumber',
            Name => 'Serial number',
            Type => 'Text',
        },
        {
            Key  => 'InkaCIuniqueName',
            Name => 'Unique name',
            Type => 'Text',
        },
    );

    # add formkey
    for my $Row (@SearchOptionList) {
        $Row->{FormKey} = 'SEARCH::' . $Row->{Key};
    }

    # add form data and input string
    ROW:
    for my $Row (@SearchOptionList) {

        # prepare text input fields
        if ( $Row->{Type} eq 'Text' ) {

            # get form data
            $Row->{FormData} = $Self->{ParamObject}->GetParam( Param => $Row->{FormKey} );

            # parse the input text block
            $Self->{LayoutObject}->Block(
                Name => 'InputText',
                Data => {
                    Key => $Row->{FormKey},
                    Value => $Row->{FormData} || '',
                },
            );

            # add the input string
            $Row->{InputStrg} = $Self->{LayoutObject}->Output(
                TemplateFile => 'LinkObject',
            );

            next ROW;
        }

        # prepare list boxes
        if ( $Row->{Type} eq 'List' ) {

            # get form data
            my @FormData = $Self->{ParamObject}->GetArray( Param => $Row->{FormKey} );
            $Row->{FormData} = \@FormData;

            my %ListData = ();
            my %ListDataAux = ();
            my @CategoryArray = $Self->{CICategoryObject}->GetCategoryArrayOrderByParentId();
            for(my $i =0; $i<@CategoryArray;$i++){
            	if($CategoryArray[$i]{is_branch}==0){
            		$ListData{$CategoryArray[$i]{id}} = $ListDataAux{$CategoryArray[$i]{id_parent}}."::".$CategoryArray[$i]{name};
            	}else{
            		$ListDataAux{$CategoryArray[$i]{id}} = $CategoryArray[$i]{name};
            		if($CategoryArray[$i]{id_parent} != 0){
            			$ListDataAux{$CategoryArray[$i]{id}} = $ListDataAux{$CategoryArray[$i]{id_parent}}."::".$ListDataAux{$CategoryArray[$i]{id}};
            		}
            	}
            }

            # add the input string
            $Row->{InputStrg} = $Self->{LayoutObject}->BuildSelection(
                Data       => \%ListData,
                Name       => $Row->{FormKey},
                SelectedID => $Row->{FormData},
                Size       => 1,
                Multiple   => 0,
            );
            next ROW;
        }
    }
    return @SearchOptionList;    
}

1;
