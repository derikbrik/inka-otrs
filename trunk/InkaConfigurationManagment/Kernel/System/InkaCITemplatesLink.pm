#--
#Kernel/System/InkaCITemplatesLink.pm - core module
# Copyright (C) 2011 Juan Manuel Rodriguez
#--
#$Id: InkaFile.pm
#--
#This software comes with ABSOLUTELY NO WARRANTY. For details, see
#the enclosed file COPYING for license information (AGPL). If you
#did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
#--
package Kernel::System::InkaCITemplatesLink;
use strict;
use warnings;

use Kernel::System::InkaConfigurationItemsCtes;
use Kernel::System::DB;
use Digest::MD5 qw(md5);

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

#Get
=item GetAllLinks()

Gets a list of all links (relations) types,  

parameters:
		none

invoke:
	->GetAllLinks();
			
returns:
	%links, which is a hash like:
	( 
    	ci => [(
    				name => 'name',
    				id => 1
    			),...]
    	user => [(
    				name => 'name',
    				id => 1
    			),... ]   	
	)

=cut

sub GetAllLinks(){
	my ( $Self, %Param ) = @_;
	my %links = ();
	my @ci = ();
	my @user = ();
	my $i = 0; 
	my $k = 0;
	
	my @columns = Kernel::System::InkaConfigurationItemsCtes::LINK_COLUMNS;
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_ALL_LINKS;
	$Self->{DBObject}->Prepare(SQL => $SQL);
	
	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
		for(my $j = 0; $j < (@columns-1); $j++) {
			if($Row[2] == 1){
				$ci[$i]{($columns[$j])} = $Row[$j];
			}else{
				$user[$k]{($columns[$j])} = $Row[$j];
			}
		}
		if($Row[2] == 1){
				$i++;
			}else{
				$k++
			}
	}
	
	$links{ci} = \@ci;
	$links{user} = \@user;
	
	return %links;
}

=item GetRelationCountByCIbyType()

Gets a hash of all the relations (or links) for a given CI whith the count of relations  

parameters:
		id : integer # CI id

invoke:
	->GetRelationCountByCIbyType( id=>1);
			
returns:
	%hash, which is a hash like:
	( 
    	ci =>  {
    				'1' => 5 #link type 1, 5 is the cont for this relation 
    				'2' => 6
    		
    			},    	
    	user => {
    				'1' => 5
    				'2' => 6
    			}  	
	)

=cut

sub GetRelationCountByCIbyType(){
	my ( $Self, %Param ) = @_;
	my %linksCount = ();
	my %ci = ();
	my %user = ();
	
	my @columns = Kernel::System::InkaConfigurationItemsCtes::RELATION_COUNT_BY_TYPE_COLUMNS;
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_RELATION_COUNT_BY_TYPE;
	$Self->{DBObject}->Prepare(SQL => $SQL, Bind => [\$Param{id},\$Param{id}]);
	
	while (my @Row = $Self->{DBObject}->FetchrowArray()) {		
			if($Row[3] == 1){
				$ci{$Row[1]} = $Row[2];
			}else{				
				$user{$Row[1]} = $Row[2];
			}
	}
	
	$linksCount{ci} = \%ci;
	$linksCount{user} = \%user;
	
	return %linksCount;
}

=item GetAllCILinkedTo()

	Return an array of hashes, where each hash is a CI (with category,provider and state) linked to the CI id passed by parameter
		the hashes in the array will be ordered by linkType

parameters:
	id_ci: integer		  # CI id
	id_type  => 2,
	page: integer 	  # Current page shown by the flexigrid 
	rp: integer		  # rows per page
	sortname: string  # field used to order the table
	sortorder: string # "asc" or "desc"
	query: string 	  # the string used in the search (WHERE qtype like "%query%")
	qtype: string 	  #	the field used to search

Inkvoke:
	->GetAllCILinkedTo(
		'id_ci' 	=> 1,
		'id_type'	=> 2,
		'page'  	=> 1,
		'rp' 		=> 15,
		'sortname'  => 'unique_name',
		'sortorder' => 'asc',
		'query' 	=> 'Home',
		'qtype' 	=> 'unique_name'
	);
	
returns: the hash used by flexigrid, with the form:

	{
			"page"=>"1",
			"total"=>"1",
			"rows"=>[
					{"id"=>"2",
					 "cell" =>["Homero","1234-1242","Server","on maintenance","Unknown","300.00","1209610801","2","contains"]
					 },...]
	}
=cut

sub GetAllCILinkedTo(){
	my ( $Self, %Param ) = @_;
			
	my $id 	  	  = $Param{id_ci};			
	my $id_type	  = $Param{id_type};
	my $page 	  = $Param{page};
	my $rp 	 	  = $Param{rp};
	my $sortname  = $Param{sortname};
	my $sortorder = $Param{sortorder};
	my $query 	  = $Param{query};
	my $qtype 	  = $Param{qtype};
	my $showInverse = $Param{showInverse};
		
	my @listOfColumns   = (Kernel::System::InkaConfigurationItemsCtes::RELATED_CI_COLUMNS);
	my $SQL 		    = Kernel::System::InkaConfigurationItemsCtes::GET_ALL_RELATED_CI;
	my $SQLInverse 	    = Kernel::System::InkaConfigurationItemsCtes::GET_ALL_RELATED_CI_INVERSE;
	my $SQLCount 	    = Kernel::System::InkaConfigurationItemsCtes::GET_COUNT_RELATED_CI;
	my $SQLInverseCount = Kernel::System::InkaConfigurationItemsCtes::GET_COUNT_RELATED_CI_INVERSE;

	my @rows = ();	
	my $i=0;
	my %Data = ();
	my $total = 0;
		
	##############################
	unless($sortname){
		 $sortname = $listOfColumns[1]; #unique_name
	}
	unless($sortorder){
		$sortorder = 'asc';
	}
	my $sort = "ORDER BY ".$sortname." ".$sortorder;

	unless($page){
		$page = 1;
	}
	unless($rp){
		 $rp = Kernel::System::InkaConfigurationItemsCtes::DEFAULT_ROW_PER_PAGE;
	}
	my $start = (($page-1) * $rp);

	my $where = "";
	if ($query) {
		$where = " AND ".$qtype." LIKE ? ";
	}
	if($showInverse == 1){
		$SQL .= $where;
		$SQLInverse .= $where;
		$SQL .= " UNION ".$SQLInverse." ".$sort;
	}else{
		$SQL .= $where." ".$sort;
	}
	$SQLCount .= $where;
	$SQLInverseCount .= $where;
	if($query){
		$query = '%'.$query.'%';
	}
	
	##### GET COUNT ##########
	if ($query) {
		if($showInverse == 1){
			$Self->{DBObject}->Prepare(
					SQL=> $SQLCount." UNION ".$SQLInverseCount,
					Limit => 2,
					Bind => [\$id, \$id_type, \$query,\$id, \$id_type, \$query]
					);
		}else{
			$Self->{DBObject}->Prepare(
					SQL=> $SQLCount,
					Limit => 1,
					Bind => [\$id, \$id_type, \$query]
					);
		}

	}else{
		if($showInverse == 1){
			
			$Self->{DBObject}->Prepare(
					SQL=> $SQLCount." UNION ".$SQLInverseCount,
					Limit => 2,
					Bind => [\$id, \$id_type, \$id, \$id_type]
					);
		}else{
			$Self->{DBObject}->Prepare(
					SQL=> $SQLCount,
					Limit => 1,
					Bind => [\$id, \$id_type]);
		}
	}

	while (my @RowCount = $Self->{DBObject}->FetchrowArray()) {
			$total = $total+$RowCount[0];
	}
	#######END GET COUNT #########
	if ($query) {
		if($showInverse == 1){
			$Self->{DBObject}->Prepare(
					SQL=> $SQL,
					Limit => $rp+$start,			
					Bind => [\$id, \$id_type, \$query,\$id, \$id_type, \$query]
			);
		}else{
			$Self->{DBObject}->Prepare(
					SQL=> $SQL,
					Limit => $rp+$start,			
					Bind => [\$id, \$id_type, \$query]
			);	
		}
	}else{
		if($showInverse == 1){
			
			$Self->{DBObject}->Prepare(
					SQL=> $SQL,
					Limit => $rp+$start,			
					Bind => [\$id, \$id_type,\$id, \$id_type]
			);
		}else{
			$Self->{DBObject}->Prepare(
					SQL=> $SQL,
					Limit => $rp+$start,			
					Bind => [\$id, \$id_type]
			);
		}
	}
	
	#HORRIBLE PATCH!!! 
	#TODO: FIX IT IN THE NEXT VERSION!
	#discount N first rows until the rows of the current page (the start doesn't work)
	for ( 1 .. $start ) {
		$Self->{DBObject}->FetchrowArray()
	}

	my $direction = 1;
	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
			my @cells = ();
			for(my $j = 1; $j < @listOfColumns; $j++) {
				if($j==1){
					$cells[$j-1] = "<div class=\"arrow_".$Row[$j]."_icon\">&nbsp;&nbsp;</div>";
					if($Row[$j] eq 'in'){
						$direction = 1;
					}else{
						$direction  = -1;
					}
				}else{
					$cells[$j-1] = $Row[$j];
				}
			}		
			$rows[$i]={ 'id'=> $Row[0]*$direction,
						'cell'=>\@cells
					  };
			$i++;
	}
	%Data = (
	    page    => $page,
	    total   => $total,
	    rows    => \@rows
	);
	return %Data;
}

=item GetAllCINonLinkedTo()

	Return an array of hashes, where each hash is a CI (with category,provider and state) which is not currently 
	linked to the CI id passed by parameter.

parameters:
	id_ci: integer		  # CI id
	id_type  => 2,
	page: integer 	  # Current page shown by the flexigrid 
	rp: integer		  # rows per page
	sortname: string  # field used to order the table
	sortorder: string # "asc" or "desc"
	query: string 	  # the string used in the search (WHERE qtype like "%query%")
	qtype: string 	  #	the field used to search

Inkvoke:
	->GetAllCINonLinkedTo(
		'id_ci' 	=> 1,
		'id_type'	=> 2,
		'page'  	=> 1,
		'rp' 		=> 15,
		'sortname'  => 'unique_name',
		'sortorder' => 'asc',
		'query' 	=> 'Home',
		'qtype' 	=> 'unique_name'
	);
	
returns: the hash used by flexigrid, with the form:

	{	
			"page"=>"1",
			"total"=>"1",
			"rows"=>[
					{"id"=>"2",
					 "cell" =>["Homero","1234-1242","Server","on maintenance","Unknown","300.00","1209610801","2","contains"]
					 },...]
	}
=cut

sub GetAllCINonLinkedTo(){
	my ( $Self, %Param ) = @_;
			
	my $id 	  	  = $Param{id_ci};			
	my $id_type	  = $Param{id_type};
	my $page 	  = $Param{page};
	my $rp 	 	  = $Param{rp};
	my $sortname  = $Param{sortname};
	my $sortorder = $Param{sortorder};
	my $query 	  = $Param{query};
	my $qtype 	  = $Param{qtype};
		
	my @listOfColumns = (Kernel::System::InkaConfigurationItemsCtes::CI_BASIC_COLUMNS);
	my $SQL 		  = Kernel::System::InkaConfigurationItemsCtes::GET_ALL_NON_RELATED_CI;
	my $SQLCount 	  = Kernel::System::InkaConfigurationItemsCtes::GET_COUNT_NON_RELATED_CI;

	my @rows = ();	
	my $i	 = 0;
	my %Data = ();
	my $total= 0;
	
	##############################
	unless($sortname){
		 $sortname = $listOfColumns[1]; #unique_name
	}
	unless($sortorder){
		$sortorder = 'asc';
	}
	my $sort = "ORDER BY ".$sortname." ".$sortorder;

	unless($page){
		$page = 1;
	}
	unless($rp){
		 $rp = Kernel::System::InkaConfigurationItemsCtes::DEFAULT_ROW_PER_PAGE;
	}
	my $start = (($page-1) * $rp);

	my $where = "";
	if ($query) {
		$where = " AND ".$qtype." LIKE ? ";
	}
	$SQL .= $where." ".$sort;
	$SQLCount .= $where;
	if($query){
		$query = '%'.$query.'%';
	}
	
	##### GET COUNT ##########
	if ($query) {
		$Self->{DBObject}->Prepare(
				SQL=> $SQLCount,
				Limit => 1,
				Bind => [\$id,\$id, \$id_type,\$id, \$id_type, \$query]
				);

	}else{
		$Self->{DBObject}->Prepare(
				SQL=> $SQLCount,
				Limit => 1,
				Bind => [\$id,\$id, \$id_type,\$id, \$id_type]);
	}

	while (my @RowCount = $Self->{DBObject}->FetchrowArray()) {
			$total = $RowCount[0];
	}
	#######END GET COUNT #########
	if ($query) {
		$Self->{DBObject}->Prepare(
				SQL=> $SQL,
				Limit => $rp+$start,			
				Bind => [\$id,\$id, \$id_type,\$id, \$id_type, \$query]
		);
	}else{
		$Self->{DBObject}->Prepare(
				SQL=> $SQL,
				Limit => $rp+$start,			
				Bind => [\$id,\$id, \$id_type,\$id, \$id_type]
		);
	}
	
	#HORRIBLE PATCH!!! 
	#TODO: FIX IT IN THE NEXT VERSION!
	#discount N first rows until the rows of the current page (the start doesn't work)
	for ( 1 .. $start ) {
		$Self->{DBObject}->FetchrowArray()
	}

	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
			my @cells = ();
			for(my $j = 1; $j < @listOfColumns; $j++) {
				$cells[$j-1] = $Row[$j];
			}			
			$rows[$i]={ 'id'=> $Row[0],
						'cell'=>\@cells
					  };
			$i++;
	}
	%Data = (
	    page    => $page,
	    total   => $total,
	    rows    => \@rows
	);
	return %Data;
}


=item GetAllUserLinkedTo()

	Return an array of hashes, where each hash is a User linked to the CI id passed by parameter
		the hashes in the array will be ordered by linkType

parameters:
	id_ci: integer		  # CI id
	id_type  => 2,
	page: integer 	  # Current page shown by the flexigrid 
	rp: integer		  # rows per page
	sortname: string  # field used to order the table
	sortorder: string # "asc" or "desc"
	query: string 	  # the string used in the search (WHERE qtype like "%query%")
	qtype: string 	  #	the field used to search

Inkvoke:
	->GetAllUserLinkedTo(
		'id_ci' 	=> 1,
		'id_type'	=> 2,
		'page'  	=> 1,
		'rp' 		=> 15,
		'sortname'  => 'unique_name',
		'sortorder' => 'asc',
		'query' 	=> 'Home',
		'qtype' 	=> 'unique_name'
	);
	
returns: the hash used by flexigrid, with the form:

	{
			"page"=>"1",
			"total"=>"1",
			"rows"=>[
					{"id"=>"2",
					 "cell" =>["user","login","",..]
					 },...]
	}
=cut

sub GetAllUserLinkedTo(){

	my ( $Self, %Param ) = @_;
			
	my $id 	  	  = $Param{id_ci};			
	my $id_type	  = $Param{id_type};
	my $page 	  = $Param{page};
	my $rp 	 	  = $Param{rp};
	my $sortname  = $Param{sortname};
	my $sortorder = $Param{sortorder};
	my $query 	  = $Param{query};
	my $qtype 	  = $Param{qtype};
		
	my @listOfColumns = (Kernel::System::InkaConfigurationItemsCtes::RELATED_USER_COLUMNS);
	my $SQL 		  = Kernel::System::InkaConfigurationItemsCtes::GET_ALL_RELATED_USER;
	my $SQLCount 	  = Kernel::System::InkaConfigurationItemsCtes::GET_COUNT_RELATED_USER;

	my @rows = ();	
	my $i=0;
	my %Data = ();
	my $total = 0;
	
	##############################
	unless($sortname){
		 $sortname = $listOfColumns[1]; #unique_name
	}
	unless($sortorder){
		$sortorder = 'asc';
	}
	my $sort = "ORDER BY ".$sortname." ".$sortorder;

	unless($page){
		$page = 1;
	}
	unless($rp){
		 $rp = Kernel::System::InkaConfigurationItemsCtes::DEFAULT_ROW_PER_PAGE;
	}
	my $start = (($page-1) * $rp);

	my $where = "";
	if ($query) {
		$where = " AND ".$qtype." LIKE ? ";
	}
	$SQL .= $where." ".$sort;
	$SQLCount .= $where;
	if($query){
		$query = '%'.$query.'%';
	}
	
	##### GET COUNT ##########
	if ($query) {
		$Self->{DBObject}->Prepare(
				SQL=> $SQLCount,
				Limit => 1,
				Bind => [\$id, \$id_type, \$query]
				);

	}else{
		$Self->{DBObject}->Prepare(
				SQL=> $SQLCount,
				Limit => 1,
				Bind => [\$id, \$id_type]);
	}

	while (my @RowCount = $Self->{DBObject}->FetchrowArray()) {
			$total = $RowCount[0];
	}
	#######END GET COUNT #########
	if ($query) {
		$Self->{DBObject}->Prepare(
				SQL=> $SQL,
				Limit => $rp+$start,			
				Bind => [\$id, \$id_type, \$query]
		);
	}else{
		$Self->{DBObject}->Prepare(
				SQL=> $SQL,
				Limit => $rp+$start,			
				Bind => [\$id, \$id_type]
		);
	}
	
	#HORRIBLE PATCH!!! 
	#TODO: FIX IT IN THE NEXT VERSION!
	#discount N first rows until the rows of the current page (the start doesn't work)
	for ( 1 .. $start ) {
		$Self->{DBObject}->FetchrowArray()
	}

	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
			my @cells = ();
			for(my $j = 1; $j < @listOfColumns; $j++) {
				$cells[$j-1] = $Row[$j];
			}			
			$rows[$i]={ 'id'=> $Row[0],
						'cell'=>\@cells
					  };
			$i++;
	}
	%Data = (
	    page    => $page,
	    total   => $total,
	    rows    => \@rows
	);
	return %Data;
}


=item GetAllUserNotLinkedTo()

	Return an array of hashes, where each hash is a User not linked with the given CI id (passed by parameter)
		
parameters:
	id_ci: integer		  # CI id
	id_type  => 2,
	page: integer 	  # Current page shown by the flexigrid 
	rp: integer		  # rows per page
	sortname: string  # field used to order the table
	sortorder: string # "asc" or "desc"
	query: string 	  # the string used in the search (WHERE qtype like "%query%")
	qtype: string 	  #	the field used to search

Inkvoke:
	->GetAllUserNotLinkedTo(
		'id_ci' 	=> 1,
		'id_type'	=> 2,
		'page'  	=> 1,
		'rp' 		=> 15,
		'sortname'  => 'unique_name',
		'sortorder' => 'asc',
		'query' 	=> 'Home',
		'qtype' 	=> 'unique_name'
	);
	
returns: the hash used by flexigrid, with the form:

	{
			"page"=>"1",
			"total"=>"1",
			"rows"=>[
					{"id"=>"2",
					 "cell" =>["user","login","",..]
					 },...]
	}
=cut

sub GetAllUserNotLinkedTo(){

	my ( $Self, %Param ) = @_;
			
	my $id 	  	  = $Param{id_ci};			
	my $id_type	  = $Param{id_type};
	my $page 	  = $Param{page};
	my $rp 	 	  = $Param{rp};
	my $sortname  = $Param{sortname};
	my $sortorder = $Param{sortorder};
	my $query 	  = $Param{query};
	my $qtype 	  = $Param{qtype};
		
	my @listOfColumns = (Kernel::System::InkaConfigurationItemsCtes::RELATED_USER_COLUMNS);
	my $SQL 		  = Kernel::System::InkaConfigurationItemsCtes::GET_ALL_NON_RELATED_USER;
	my $SQLCount 	  = Kernel::System::InkaConfigurationItemsCtes::GET_COUNT_NON_RELATED_USER;

	my @rows = ();	
	my $i=0;
	my %Data = ();
	my $total = 0;
	
	##############################
	unless($sortname){
		 $sortname = $listOfColumns[1]; #unique_name
	}
	unless($sortorder){
		$sortorder = 'asc';
	}
	my $sort = "ORDER BY ".$sortname." ".$sortorder;

	unless($page){
		$page = 1;
	}
	unless($rp){
		 $rp = Kernel::System::InkaConfigurationItemsCtes::DEFAULT_ROW_PER_PAGE;
	}
	my $start = (($page-1) * $rp);

	my $where = "";
	if ($query) {
		$where = " AND ".$qtype." LIKE ? ";
	}
	$SQL .= $where." ".$sort;
	$SQLCount .= $where;
	if($query){
		$query = '%'.$query.'%';
	}
	
	##### GET COUNT ##########
	if ($query) {
		$Self->{DBObject}->Prepare(
				SQL=> $SQLCount,
				Limit => 1,
				Bind => [\$id, \$id_type, \$query]
				);

	}else{
		$Self->{DBObject}->Prepare(
				SQL=> $SQLCount,
				Limit => 1,
				Bind => [\$id, \$id_type]);
	}

	while (my @RowCount = $Self->{DBObject}->FetchrowArray()) {
			$total = $RowCount[0];
	}
	#######END GET COUNT #########
	if ($query) {
		$Self->{DBObject}->Prepare(
				SQL=> $SQL,
				Limit => $rp+$start,			
				Bind => [\$id, \$id_type, \$query]
		);
	}else{
		$Self->{DBObject}->Prepare(
				SQL=> $SQL,
				Limit => $rp+$start,			
				Bind => [\$id, \$id_type]
		);
	}
	
	#HORRIBLE PATCH!!! 
	#TODO: FIX IT IN THE NEXT VERSION!
	#discount N first rows until the rows of the current page (the start doesn't work)
	for ( 1 .. $start ) {
		$Self->{DBObject}->FetchrowArray()
	}

	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
			my @cells = ();
			for(my $j = 1; $j < (@listOfColumns-2); $j++) {
				$cells[$j-1] = $Row[$j];
			}			
			$rows[$i]={ 'id'=> $Row[0],
						'cell'=>\@cells
					  };
			$i++;
	}
	%Data = (
	    page    => $page,
	    total   => $total,
	    rows    => \@rows
	);
	return %Data;
}

#inserts

=item CreateNew()

Create a new "relation type" (or link) which be used to link CI with other CI or users  

parameters:
		type: integer (1: Users // 2: CI)
		name: string	

invoke:
	->CreateNew(
    			'type' 				  => $type,
    			'name' 			      => $name
    			);			
returns:
	%message: a hash like:
	(
    	error => "Error message"
    	ok => "Ok message"
	)
	one of them should be empty
=cut

sub CreateNew(){
	
	my ( $Self, %Param ) = @_;
	my %message = (); 
	my $SQL = "";
	$message{"error"} = "";
	$message{"ok"} = "";

	if($Param{type} == 1){
		$SQL = Kernel::System::InkaConfigurationItemsCtes::INSERT_LINK_TYPE_USER;
	}elsif($Param{type} == 2){
		$SQL = Kernel::System::InkaConfigurationItemsCtes::INSERT_LINK_TYPE_CI;
	}else{
		$message{"error"} = '$Text{"invalid type"}';
		return %message;
	}
	
	$Self->{DBObject}->Prepare(SQL => $SQL, Bind => [\$Param{name}]);
	
	
	if($Self->{DBObject}->Error() eq ""){						   	
		$message{"ok"} = '$Text{"successfully created new relation"}';
	}else{
		$message{"error"} = "".$Self->{DBObject}->Error();
	}
	
	return %message;
}

#Updates

=item Edit()

Update a "relation type" (or link) used to link CI with other CI or a user  

parameters:
		type: integer (1: Users // 2: CI)
		name: string
		id: integer	

invoke:
	->Edit(
				'id'				  => $id,
    			'type' 				  => $type,
    			'name' 			      => $name
    			);			
returns:
	%message: a hash like:
	(
    	error => "Error message"
    	ok => "Ok message"
	)
	one of them should be empty
=cut

sub Edit(){
	
	my ( $Self, %Param ) = @_;
	my %message = (); 
	my $SQL = "";
	$message{"error"} = "";
	$message{"ok"} = "";

	if($Param{type} == 1){
		$SQL = Kernel::System::InkaConfigurationItemsCtes::UPDATE_LINK_TYPE_USER;
	}elsif($Param{type} == 2){
		$SQL = Kernel::System::InkaConfigurationItemsCtes::UPDATE_LINK_TYPE_CI;
	}else{
		$message{"error"} = '$Text{"invalid type"}';
		return %message;
	}
	
	$Self->{DBObject}->Prepare(SQL => $SQL, Bind => [\$Param{name}, \$Param{id}]);
	
	
	if($Self->{DBObject}->Error() eq ""){						   	
		$message{"ok"} = '$Text{"successfully updated relation"}';
	}else{
		$message{"error"} = "".$Self->{DBObject}->Error();
	}
	
	return %message;
}

=item Delete()

Deletes a "relation type" (or link) used to link CI with other CI or a user  

parameters:
		type: integer (1: Users // 2: CI)		
		id: integer	

invoke:
	->Delete(
				'id'				  => $id,
    			'type' 				  => $type
    			);			
returns:
	%message: a hash like:
	(
    	error => "Error message"
    	ok => "Ok message"
	)
	one of them should be empty
=cut

sub Delete(){
	
	my ( $Self, %Param ) = @_;
	my %message = ();
	my $SQL_VERIF = ""; 
	my $SQL = "";
	$message{"error"} = "";
	$message{"ok"} = "";
	my $count = 0;

	if($Param{type} == 1){
		$SQL = Kernel::System::InkaConfigurationItemsCtes::DELETE_LINK_TYPE_USER;
		$SQL_VERIF = Kernel::System::InkaConfigurationItemsCtes::COUNT_LINKS_USER_CI;
	}elsif($Param{type} == 2){
		$SQL = Kernel::System::InkaConfigurationItemsCtes::DELETE_LINK_TYPE_CI;
		$SQL_VERIF = Kernel::System::InkaConfigurationItemsCtes::COUNT_LINKS_CI_CI;
	}else{
		$message{"error"} = '$Text{"invalid type"}';
		return %message;
	}
	#Check if deletion is possible
	$Self->{DBObject}->Prepare(SQL => $SQL_VERIF, Bind => [\$Param{id}]);	
	if (my @Row = $Self->{DBObject}->FetchrowArray()) {		
		$count = $Row[0];
	}
	if($count>0){
		$message{"error"} = '$Text{"Unable to delete. The relation is in used by"}'.' '.$count.' '.'$Text{"Configuration Items"}';
		return %message;
	}
	###
	$Self->{DBObject}->Prepare(SQL => $SQL, Bind => [\$Param{id}]);
		
	if($Self->{DBObject}->Error() eq ""){						   	
		$message{"ok"} = '$Text{"successfully deleted relation"}';
	}else{
		$message{"error"} = "".$Self->{DBObject}->Error();
	}	
	return %message;
}

=item unlinkCIToUser()

description:
	This functions receives an array referece of User "IDs" and a CI Id whit the relation type and delete
	all the relations in the corresponding table.  	

parameters:
	'id' : integer #current CI id
	'userIdArray': reference to array
	'link_type' : integer # the id of the selected relation

invocation:
	->unlinkCIToUser(
				'id' 		   =>  1,
				'userIdArray' =>  $arrayOfUserIds,
				'link_type' => 1				
			 );
returns:
	%message: a hash like:
	(
    	error => "Error message"
    	ok => "Ok message"
	)
	one of them should be empty

=cut
sub unlinkCIToUser(){
	
	my ( $Self, %Param ) = @_;
	my $userIdArray = $Param{userIdArray};
	my $id_ci = $Param{id};
	my $link_type = $Param{link_type};
	my %message = ();	
	$message{"error"} = "";
	$message{"ok"}	  = "";

	if(@$userIdArray == 0){
		$message{"error"} = '$Text{"No elements selected"}';
		return %message;
	}

	my $SQL = Kernel::System::InkaConfigurationItemsCtes::DELETE_CI_USER_RELATIONS;
	$SQL .= " id_ci=".$id_ci." and id_user_link_type=".$link_type." and ( ";
	for(my $j = 0; $j < @$userIdArray; $j++) {
		if($j != 0){
			$SQL = $SQL." OR ";
		}
		$SQL = $SQL." id_user=".@$userIdArray[$j]." ";
	}
	$SQL .= ") ";
	$Self->{DBObject}->Do(SQL => $SQL);

	if($Self->{DBObject}->Error() eq ""){
		$message{"ok"} = '$Text{"Successfully unlinked elements"}';
	}else{
		$message{"error"} = "".$Self->{DBObject}->Error();
	}
	return %message;
}


    
=item unlinkCIs()

description:
	This functions receives an array referece of CI "IDs" and a CI Id whit the relation types and deletes
	all the relations in the corresponding table.  	

parameters:
	'id' : integer #current CI id
	'arrayOfCIIds': reference to array
	'link_type' : integer # the id of the selected relation

invocation:
	->unlinkCIs(
				'id' 		   =>  1,
				'arrayOfCIIds' =>  $arrayOfCIIds,
				'link_type' => 1				
			 );
returns:
	%message: a hash like:
	(
    	error => "Error message"
    	ok => "Ok message"
	)
	one of them should be empty

=cut
sub unlinkCIs(){

	my ( $Self, %Param ) = @_;
	my $arrayOfCIIds = $Param{arrayOfCIIds};
	my $id_ci = $Param{id};
	my $link_type = $Param{link_type};
	my $flagQuery=0; 		#this is a flag in order to know if we have to execute the first wquery, to delete direct relations
	my $flagSecondQuery=0; #this is a flag in order to know if we have to execute a second query to delete inverse relations
	my %message = ();	
	$message{"error"} = "";
	$message{"ok"}	  = "";

	if(@$arrayOfCIIds == 0){
		$message{"error"} = '$Text{"No elements selected"}';
		return %message;
	}

	my $SQL = Kernel::System::InkaConfigurationItemsCtes::DELETE_CI_RELATIONS;
	my $SQLInverse = Kernel::System::InkaConfigurationItemsCtes::DELETE_CI_RELATIONS;
	$SQL .= " id_ci_up=".$id_ci." and id_link_type=".$link_type." and ( ";
	$SQLInverse.= " id_ci_down=".$id_ci." and id_link_type=".$link_type." and ( ";
	for(my $j = 0; $j < @$arrayOfCIIds; $j++) {
		
		if(@$arrayOfCIIds[$j]>0){
			if($flagQuery != 0){
				$SQL = $SQL." OR ";
			}
			$SQL = $SQL." id_ci_down=".@$arrayOfCIIds[$j]." ";
			$flagQuery = 1;
		}else{
			if($flagSecondQuery != 0){
				$SQLInverse = $SQLInverse." OR ";
			}
			$SQLInverse = $SQLInverse." id_ci_up=".(@$arrayOfCIIds[$j]*-1)." ";
			$flagSecondQuery = 1;
		}
	}
	$SQL .= ") ";
	$SQLInverse.= ") ";
	
	if($flagQuery){
		$Self->{DBObject}->Do(SQL => $SQL);
		if($Self->{DBObject}->Error() eq ""){
			$message{"ok"} = '$Text{"Successfully unlinked elements"}';
		}else{
			$message{"error"} = "".$Self->{DBObject}->Error();
			return %message;	
		}	
	}
	
	if($flagSecondQuery){
		
		$Self->{DBObject}->Do(SQL => $SQLInverse);
		if($Self->{DBObject}->Error() eq ""){
			$message{"ok"} = '$Text{"Successfully unlinked elements"}';
		}else{
			$message{"error"} = "".$Self->{DBObject}->Error();			
		}
	}
	return %message;
}

=item linkCIs()

description:
	This functions receives an array referece of CI "IDs" and a CI Id whit the relation types and makes
	all the inserts in the corresponding table.  	

parameters:
	'id' : integer #current CI id
	'arrayOfCIIds': reference to array
	'link_type' : integer # the id of the selected relation
	
invocation:
	->linkCIs(
				'id' 		   =>  1,
				'arrayOfCIIds' =>  $arrayOfCIIds,
				'link_type' => 1								
			 );
returns:
	%message: a hash like:
	(
    	error => "Error message"
    	ok => "Ok message"
	)
	one of them should be empty
=cut
sub linkCIs(){
	
	my ( $Self, %Param ) = @_;
	my $arrayOfCIIds = $Param{arrayOfCIIds};
	my $id_ci = $Param{id};
	my $link_type = $Param{link_type};
	my @relationColumns = (Kernel::System::InkaConfigurationItemsCtes::CI_RELATIONS_COLUMNS);
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::INSERT_CI_RELATIONS;
	
	my %message 	  = ();	
	$message{"error"} = "";
	$message{"ok"}	  = "";

	if(@$arrayOfCIIds == 0){
		$message{"error"} = '$Text{"No elements selected"}';
		return %message;
	}
	
	##Add the condition of the insert: The no existence of the values in the table
	my $SQLCheckCondition = Kernel::System::InkaConfigurationItemsCtes::INSERT_CI_RELATIONS_VALIDATOR;
	$SQLCheckCondition .= $relationColumns[0]."= ".$id_ci." AND ".$relationColumns[1]."= ".$link_type." AND (";
	for(my $j = 0; $j < @$arrayOfCIIds; $j++) {
		if($j != 0){
			$SQLCheckCondition .= " OR ";
		}
		$SQLCheckCondition .= $relationColumns[2]."=".@$arrayOfCIIds[$j]." ";		
	}
	$SQLCheckCondition.=" ) ";

		#Check that not exists the relation in the database: #
	$Self->{DBObject}->Prepare(SQL => $SQLCheckCondition);
	if (my @Row = $Self->{DBObject}->FetchrowArray()) {
			if($Row[0] > 0){
				$message{"error"} = '$Text{"Relation exists"}';
				return %message;
			}
	}
	##Make the inserts
	for(my $j = 0; $j < @$arrayOfCIIds; $j++) {
		$Self->{DBObject}->Do(SQL => $SQL, Bind => [\$id_ci,\@$arrayOfCIIds[$j],\$link_type]);
		if($Self->{DBObject}->Error() ne ""){
			$message{"error"} = "".$Self->{DBObject}->Error();
			return %message;	
		}
	}
	############End inserts###################	
	$message{"ok"} = '$Text{"Successfully linked elements"}';
	return %message;
}

=item linkCIToUser()

description:
	This functions receives an array referece of User "IDs" and a CI Id with the relation type and makes
	all the inserts in the corresponding table.  	

parameters:
	'id' : integer #current CI id
	'userIdArray': reference to array
	'link_type' : integer # the id of the selected relation
	
invocation:
	->linkCIToUser(
				'id' 		   =>  1,
				'userIdArray' =>  $userIdArray,
				'link_type' => 1								
			 );
returns:
	%message: a hash like:
	(
    	error => "Error message"
    	ok => "Ok message"
	)
	one of them should be empty
=cut
sub linkCIToUser(){

	my ( $Self, %Param ) = @_;
	my $arrayOfUserId = $Param{userIdArray};
	my $id_ci = $Param{id};
	my $link_type = $Param{link_type};
	my %message = ();	
	$message{"error"} = "";
	$message{"ok"}	  = "";
	my @relationColumns = (Kernel::System::InkaConfigurationItemsCtes::CI_USER_RELATIONS_COLUMNS);
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::INSERT_CI_USER_RELATIONS;
	
	if(@$arrayOfUserId == 0){
		$message{"error"} = '$Text{"No elements selected"}';
		return %message;
	}
		
	##Add the condition of the insert: The no existence of the values in the table
	my $SQLCheckCondition = Kernel::System::InkaConfigurationItemsCtes::INSERT_CI_USER_RELATIONS_VALIDATOR;
	$SQLCheckCondition .= $relationColumns[0]."= ".$id_ci." AND ".$relationColumns[1]."= ".$link_type." AND (";	
	for(my $j = 0; $j < @$arrayOfUserId; $j++) {
		if($j != 0){			
			$SQLCheckCondition .= " OR ";
		}	
		$SQLCheckCondition .= $relationColumns[2]."=".@$arrayOfUserId[$j]." ";
	}
	$SQLCheckCondition.=" ) ";	
	##Check that not exists the relation in the database:
	$Self->{DBObject}->Prepare(SQL => $SQLCheckCondition);
	if (my @Row = $Self->{DBObject}->FetchrowArray()) {
			if($Row[0] > 0){
				$message{"error"} = '$Text{"Relation exists"}';
				return %message;
			}
	}	
	##Make the inserts
	for(my $j = 0; $j < @$arrayOfUserId; $j++) {
		$Self->{DBObject}->Do(SQL => $SQL, Bind => [\$id_ci,\@$arrayOfUserId[$j],\$link_type]);
		if($Self->{DBObject}->Error() ne ""){
			$message{"error"} = "".$Self->{DBObject}->Error();
			return %message;	
		}
	}
	############End inserts###################	
	$message{"ok"} = '$Text{"Successfully linked elements"}';	
	return %message;
}

1;