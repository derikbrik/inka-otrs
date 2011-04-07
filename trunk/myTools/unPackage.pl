#!/bin/perl

# use module
use XML::Simple;
use Data::Dumper;
use MIME::Base64;

use constant PATH_BASE => '/usr/COSAS/Workspaces/perl/';

#Validacion de parametros

if($#ARGV < 0 ){
	print "Se esperaba el nombre y path del archivo del paquete de OTRS a desempaquetar \n";
	print "Ejemplo: unPackage.pl /usr/COSAS/paquete.opm\n";
	die();	
}
$Packagefile = $ARGV[0];
  
unless(-e $Packagefile) {
 	print "No existe el archivo \n";
 	die();
 }
  
unless($Packagefile =~ /opm$/)
{
	print "El archivo no termina en OPM, y pensamos que no es un paquete valido\n";
	die();
}
#fin de validacion

##Create directory for package
my $dirForPackage =substr($Packagefile,rindex($Packagefile,"/")+1,length($Packagefile)-rindex($Packagefile,"/")- 5);
mkdir(PATH_BASE.$dirForPackage);

# create object
$xml = new XML::Simple;

# read XML file
$data = $xml->XMLin($Packagefile);

for my $fileArray (@{$data->{'Filelist'}->{'File'}}) {
        @directories = split('/', $fileArray->{'Location'});
        $filecurrent = pop(@directories);
        $path = PATH_BASE.$dirForPackage;
        for my $directory (@directories) {
			unless($directory =~ /opm$/){
				   $path = $path.'/'.$directory;
				   unless(-e $path) {
			       	mkdir($path)
				   }
			}
        }
        ##
        open(FILE, "+>", $path."/".$filecurrent);
        print FILE decode_base64($fileArray->{'content'});
		close FILE;
}

print "finializado";