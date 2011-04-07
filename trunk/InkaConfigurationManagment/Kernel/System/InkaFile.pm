#--
#Kernel/System/InkaFile.pm - core module
# Copyright (C) 2011 Juan Manuel Rodriguez
#--
#$Id: InkaFile.pm
#--
#This software comes with ABSOLUTELY NO WARRANTY. For details, see
#the enclosed file COPYING for license information (AGPL). If you
#did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
#--
package Kernel::System::InkaFile;
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
=item GetFileByID()

Gets a File from the database 
parameters:
	'id' : integer. Id for the file

invoke:
	->GetFileByID('id' => 1);
			
returns:
	%file, which is a hash like:
	( 
    	id => 1 
    	filename  	=>  'file.txt'
    	content_type =>  'application/octet-stream'
    	content_size => 12243 #bytes
    	content => 'file content'
    	creation_date 	=> Database DateTime
    	modification_date => Database DateTime    	
	)

=cut

sub GetFileByID(){
	my ( $Self, %Param ) = @_;
	my %file = (); 
	my @columns = Kernel::System::InkaConfigurationItemsCtes::FILE_COLUMNS;

	my $SQL = Kernel::System::InkaConfigurationItemsCtes::GET_FILE_BY_ID;
	$Self->{DBObject}->Prepare(SQL => $SQL,
							   Bind => [\$Param{id}],
							   Limit => 1);
	
	if (my @Row = $Self->{DBObject}->FetchrowArray()) {
		for(my $j = 0; $j < @columns; $j++) {
			$file{($columns[$j])} = $Row[$j];
		}
	}
	
	return %file;
}

#Insert
=item CreateNew()

inserts a file into the table: inka_file
parameters:
	'file': a hash like:
	(
	    Filename 	=>  'file.txt'
    	ContentType =>  'application/octet-stream'
    	Content 	=>	'BLA BLA BLA...'
	)
	
	Is the same array that returns: {Request}->GetUploadAll();

	Common use and invoke:
	
	#First take the file from the REQUEST. Where "generic_7" is the field "name" for the input type:file in the HTML
	my %File = $Self->{ParamObject}->GetUploadAll(
                Param  => 'generic_7',
                Source => 'string',
     );     
     $Self->{FileObject}->CreateNew( 'file' => \%File);
		
returns:
	%message, which is an array like:
	(
		"ok" => "message to display is everithing is ok otherwise empy"
		"error" => "message to display in case error otherwise empty"
		"id" => 1 #last inserted id, -1 if not was able to get the file
	)

=cut

sub CreateNew(){
	my ( $Self, %Param ) = @_;
	my %message = (); 
	my $fileaux = $Param{file};
	my %file = %$fileaux;
	$message{"error"} = "";
	$message{"ok"} = "";
	$message{"id"} = -1;
	my $filesize;
	{ 	use bytes;
		$filesize = length($file{Content});
	}
	
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::INSERT_FILE;
	
	$Self->{DBObject}->Do(SQL => $SQL,
							   Bind => [\$file{Filename}, \$file{ContentType}, \$filesize, \$file{Content}]);

	if($Self->{DBObject}->Error() eq ""){
		$message{"ok"} = '$Text{"successfully created new file"}';
	}else{
		$message{"error"} = "".$Self->{DBObject}->Error();
		return %message;
	}
	##GET ID
	my $GET_SQL = Kernel::System::InkaConfigurationItemsCtes::GET_INSERTED_FILE;
	$Self->{DBObject}->Prepare(SQL => $GET_SQL,
							   Bind => [\$file{Filename}],
							   Limit => 1);

	if (my @Row = $Self->{DBObject}->FetchrowArray()) {
		$message{"id"} = $Row[0];
	}

	return %message;
}

#delete
=item DeleteFileByID()

Gets a File from the database 
parameters:
	'id' : integer. Id for the file

invoke:
	->GetFileByID('id' => 1);
			
returns:
	%message, which is a hash like:
	( 
    	"ok" => "message to display is everithing is ok otherwise empy"
		"error" => "message to display in case error otherwise empty"
	)
=cut

sub DeleteFileByID(){
	my ( $Self, %Param ) = @_;
	my %message = (); 	
	$message{"error"} = "";
	$message{"ok"} = "";
		
	my $SQL = Kernel::System::InkaConfigurationItemsCtes::DELETE_FILE_BY_ID;
	$Self->{DBObject}->Do(SQL => $SQL, Bind => [\$Param{id}]);
	
	if($Self->{DBObject}->Error() eq ""){						   	
		$message{"ok"} = '$Text{"successfully deleted file"}';
	}else{
		$message{"error"} = "".$Self->{DBObject}->Error();		
	}
	return %message;
}

=item compareFiles()

Gets a File from the database
 
parameters:
	'id' : integer. Id for the first file to compare
	'file': reference to hash. A hash with the followin items:
		'file':
			(
			    Filename 	=>  'file.txt'
		    	ContentType =>  'application/octet-stream'
		    	Content 	=>	'BLA BLA BLA...'
			)	 

invoke:
	{Object}->compareFiles('id' => 1, 'file'=> \%file);
			
returns:
	1 if both files are the same
	0 if dont
=cut
sub compareFiles(){
	my ( $Self, %Param ) = @_;
	my $fileaux = $Param{file};
	my %secondFile = %$fileaux;
	#0. get the first file from the database
	my %firstFile = $Self->GetFileByID( 'id'=> $Param{id});
	
	#1. check the names
	if($firstFile{filename} ne $secondFile{Filename}){
		return 0;
	}
	#2. check bytes size
	my $filesize;
	{ 	use bytes;
		$filesize = length($secondFile{Content});
	}
	if($firstFile{content_size} != $filesize){
		return 0;
	}
	#3. MD5 hash compare
	my $firstDigest = md5($firstFile{content});
	my $secondDigest = md5($secondFile{Content});
	if($firstDigest ne $secondDigest){
		return 0;
	}
	return 1;
}

1;