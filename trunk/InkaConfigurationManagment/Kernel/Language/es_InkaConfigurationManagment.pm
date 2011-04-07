# --
# Kernel/Language/es_InkaConfigurationManagment.pm - the spanish translation of InkaConfigurationManagment
# Copyright (C) 2011 Juan Manuel Rodriguez
# --
# $Id: es_InkaConfigurationManagment.pm,v 0.1 2010$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::es_InkaConfigurationManagment;

use strict;
use warnings;

use vars qw(@ISA $VERSION);
$VERSION = qw($Revision: 0.1 $) [1];


sub Data {
    my $Self = shift;

    my $Lang = $Self->{Translation};

    return if ref $Lang ne 'HASH';

    $Lang->{'Configuration Items Template'}            = 'Templates para Elementos de Configuraci�n (CI)';
    $Lang->{'IT'}            = 'TI';
	$Lang->{'Non IT'}        = 'No TI';
	$Lang->{'Component'}     = 'Componente';
	$Lang->{'Desk'}          = 'Escritorio';
	$Lang->{'Chair'}         = 'Silla';
	$Lang->{'Projector'}     = 'Proyector';
	$Lang->{'Access Point'}  = 'Access Point';
	$Lang->{'Printer'}       = 'Impresora';
	$Lang->{'Router'}        = 'Router';
	$Lang->{'Switch'}        = 'Switch';
	$Lang->{'Server'}        = 'Servidor';
	$Lang->{'Workstation'}   = 'Estaci�n de Trabajo';
	$Lang->{'Keyboard'}      = 'Teclado';
	$Lang->{'Mouse'}         = 'Mouse';
	$Lang->{'Monitor'}       = 'Monitor';
	$Lang->{'Case'}          = 'Gabinete';	
	$Lang->{'available on stock'}          = 'disponible en stock';
	$Lang->{'in use'}        			   = 'en uso';
	$Lang->{'on maintenance'}       	   = 'en mantenimiento';
	$Lang->{'not available'}          	   = 'no disponible';	
	$Lang->{'Categories'}          		   = 'Categor�as';
	$Lang->{'States'}          	   		   = 'Estados';
	$Lang->{'Generic Lists'}        	   = 'Listas Genericas';
	$Lang->{'Help'}        				   = 'Ayuda';
	$Lang->{'open all'}        			   = 'expandir todo';
	$Lang->{'close all'}        		   = 'contraer todo';
	$Lang->{'Translated as'}    		   = 'Traducido como';	 	
	$Lang->{'available on stock'}    	   = 'disponible en stock';
	$Lang->{'in use'}    = 'en uso';
	$Lang->{'not available'}     = 'no disponible';
	$Lang->{'on maintenance'}    = 'en mantenimiento';
	$Lang->{'Create New'}   	 = 'Crear Nuevo';
	$Lang->{'Create New List'}   = 'Crear Nueva Lista';
	$Lang->{'Vendors'}   		 = 'Fabricantes';
	$Lang->{'Lists'}     		 = 'Listas';
	$Lang->{"List"}     		 = 'Lista';
	$Lang->{"Relations"}   		 = 'Relaciones';
	$Lang->{'New List'}    		 = 'Nueva Lista';
	$Lang->{'Edit List'}   		 = 'Editar Lista';
	$Lang->{'List Elements'}   	   = 'Elementos de la lista';
	$Lang->{'New Element List'}    = 'Nuevo elemento de lista';
	$Lang->{'Edit Element List'}   = 'Editar elemento de lista';
    $Lang->{'Is parent?'}   = "�Es padre?";

	$Lang->{'elements in the list'} = "elementos de la lista";
	$Lang->{'vendor list'}        	= "lista de fabricantes";
	$Lang->{'states'}        		= "estados";
	$Lang->{'categories'}        	= "categor�as";
	$Lang->{'elements'}        		= "lista de elementos";
	$Lang->{'category data'}		= "datos de categor�a";
	$Lang->{'category list'}        = "lista de categor�as";
	$Lang->{'category sublist'}     = "sublista de categor�as";
	$Lang->{'category parent list'} = "lista de padres de categor�as";
	$Lang->{'template list'}   		= "lista de templates";
	$Lang->{'Unknown error.Please try again'} = "Error desconocido. Por favor intente de nuevo"; 
	
	
	$Lang->{'Unable to retrive operation status'} = "Imposible obtener el estado de la operaci�n";
	$Lang->{'none'} = "ninguno";
	$Lang->{"field name can't be empty"}         		 = "el campo: nombre no puede estar vac�o";
	$Lang->{"fields name and value can't be empty"}      = "los campos: nombre y valor no pueden estar vac�os";
	$Lang->{'Unable to delete element'}       			 = "Imposible borrar elemento";
	$Lang->{'Unable to delete state'}        			 = "Imposible borrar estado";
	$Lang->{'Unable to delete selected list'}      		 = "Imposible borrar lista seleccionada";
	$Lang->{'Unable to delete category root'}		 = "Imposible borrar category ra�z";
	$Lang->{'Are you sure you want to remove this element and all its children?'}        = "�Est� seguro de que quiere borrar este elemento y todos sus hijos?";
	$Lang->{'Are you sure you want to remove this element?'}      					 	 = "�Est� seguro de que quiere borrar este elemento?";
	$Lang->{'Are you sure you want to remove this element from the list?'}        		 = "�Est� seguro de que quiere borrar este elemento de la lista?";
	$Lang->{'Are you sure you want to remove this list with all its elements?'}        	 = "�Est� seguro de que quiere borrar esta lista con todos sus elementos?";
	$Lang->{"Are you sure you want to remove all selected elements?"} 					 = "�Est� seguro de que quiere borrar todos los elementos seleccionados?";
	$Lang->{'Unable to get elements in the list'}       								 = "Imposible obtener elementos de la lista";
	$Lang->{'Unable to get vendor list'}        										 = "Imposible obtener lista de fabricantes";
	$Lang->{'Unable to get states'}        												 = "Imposible obtener estados";
	$Lang->{'Unable to get categories'}        											 = "Imposible obtener categor�as";
	$Lang->{'Unable to get list elements'}        										 = "Imposible obtener lista de elementos";
	$Lang->{'Unable to get category data'}			= "Imposible obtener datos de categor�a";
	$Lang->{'Unable to get category list'}        	= "Imposible obtener lista de categor�as";
	$Lang->{'Unable to get category sublist'}       = "Imposible obtener lista de subcategor�as";
	$Lang->{'Unable to get category parent list'}   = "Imposible obtener lista de padres de categor�as";
	$Lang->{'Unable to get template list'}   		= "Imposible obtener lista de templates";
	$Lang->{'There are no vendors for this category.  (parent vendors would be used)'}     = "No hay fabricantes en esta categor�a.(se usar�n los fabricantes del padre)";
	$Lang->{'There are no elements in this list'}     									   = "No hay elementos en esta lista";
	$Lang->{"successfully created new state"} = "Nuevo estado creado correctamente";
	$Lang->{"successfully updated state"} 	  = "Estado actualizado correctamente";
	$Lang->{"successfully deleted state"} 	  = "Estado borrado correctamente";	
	$Lang->{"Unable to delete category because it contains an elements group"} 	  = "Imposible eliminar categor�a porque contiene un grupo de elementos";
	$Lang->{"successfully deleted category"} 	  	  = "Categor�a eliminada correctamente";
	$Lang->{"successfully created new category"} 	  = "Nueva categor�a creada correctamente";
	$Lang->{"The category parent is itself!"} 	  	  = "La categor�a padre es ella misma";
	$Lang->{"Unable to change category, because it contains an elements group"} 	  = "Imposible cambiar categor�a porque contiene un grupo de elementos";
	$Lang->{"Unable to update category"} 	 		  = "Imposible actualizar categor�a";
	$Lang->{"successfully updated category"} 	  	  = "Categor�a actualizada correctamente";
	$Lang->{"unable to update levels, check log"} 	  = "Imposible actualizar niveles. Revise el Log";
	$Lang->{"successfully created new list"} =	"Nueva lista creada correctamente";
	$Lang->{"successfully created new item in the list"} =	"Nuevo �tem en la lista, creado correctamente";
	$Lang->{"successfully updated list"} = "Lista actualizada correctamente";
	$Lang->{"successfully updated item list"} = "�tem en la lista actualizado correctamente";
	$Lang->{"successfully deleted list"} = "Lista borrada correctamente";
	$Lang->{"successfully deleted item"} = "�tem borrado correctamente";
	$Lang->{"and"} = "y";
	$Lang->{"successfully created new vendor"} = "Nuevo fabricante creado correctamente";
	$Lang->{"successfully updated vendor"} 	   = "Fabricante actualizado correctamente";
	$Lang->{"successfully deleted vendor"} 	   = "Fabricante borrado correctamente";
	$Lang->{"Edit template"} = "Editar template";
	$Lang->{"Create new template"} = "Crear nuevo template";
	$Lang->{"Template fields"} = "Campos del template";
	$Lang->{"Field"} = "Campo";
	$Lang->{"Field name"} = "Nombre del Campo";
	$Lang->{"New template"} = "Nuevo template";
	$Lang->{"New field"} = "Nuevo campo";
	$Lang->{"Edit field"} = "Editar campo";
	$Lang->{"Caption"} = "T�tulo";
	$Lang->{"Properties Group"} = "Grupo de propiedades";
	$Lang->{"Unable to get template data"} = "Imposible obtener los datos del template";
	$Lang->{"Unique name"} = "Nombre �nico";
	$Lang->{"Serial number"} = "N�mero de serie";
	$Lang->{"Description"} = "Descripci�n";
	$Lang->{"State"} = "Estado";
	$Lang->{"Vendor"} = "Fabricante";
	$Lang->{"New Vendor"} = "Nuevo Fabricante";
	$Lang->{"Cost"} = "Costo";
	$Lang->{"Day of acquisition"} = "D�a de adquisici�n";
	$Lang->{'Category'}			  = "Categor�a";
	$Lang->{"Sub category"} = "Sub categor�a";
	
	$Lang->{"successfully created new template"} 		 = "Template creado correctamente";
	$Lang->{"successfully created new template field"}   = "Campo de template creado correctamente";
	$Lang->{"successfully created new properties group"} = "Grupo de propiedades creado correctamente";
	$Lang->{"successfully updated new template"} 		 = "Template actualizado correctamente";
	$Lang->{"successfully updated template field"} 		 = "Campo de template actualizado correctamente";
	$Lang->{"The default template could not be deleted"} = "El template default no puede ser borrado";
	$Lang->{"successfully deleted template"} 			 = "Template borrado correctamente";
	$Lang->{"Unable to deleted template fields"} 		 = "Imposible borrar los campos del template";
	$Lang->{"successfully deleted template field"} 		 = "Campo de template borrado correctamente";
	$Lang->{"Cause"} = "Causa";
	$Lang->{"Unable to delete default list"} 		 	 = "Imposible borrar lista default";
	$Lang->{"other"} 		 	 = "otro";
	$Lang->{"Unable to get properties groups"} = "Imposible obtener grupos de propiedades";
	$Lang->{"Type"} ="Tipo";
	$Lang->{"New Properties Group"} = "Nuevo grupo de propiedades";
	$Lang->{"Unable to get lists"} = "Imposible obtener listas";
	$Lang->{"Mandatory"} = "Obligatorio";
	$Lang->{"Display"} = "Mostrar";
	$Lang->{"field caption can't be empty"} = "el campo: t�tulo no puede estar vac�o";
	$Lang->{"properties group name can't be empty"} = "el campo: nombre de grupo de propiedades no puede estar vac�o";
	$Lang->{"you must specify a name for the group of properties"} = "debe especificar un nombre para el grupo de propiedades";
	$Lang->{"Unable to create the group of properties"} = "Imposible crear el grupo de propiedades";
	$Lang->{"Check the Log"} = "Verifique el Log";
	$Lang->{"Hide/Show Default fields"} = "Ocultar/Mostrar Campos default";
	$Lang->{"Unable to delete template"} = "Imposible borrar template";
	$Lang->{"Delete Selected"} = "Borrar Seleccionados";
	$Lang->{"No elements selected"} = "No se seleccionaron elementos";
	$Lang->{"Successfully deleted selected elements"} = "Elementos seleccionados borrados correctamente";
	
#Relations
	$Lang->{"Configuration items and"} = "Elementos de configuraci�n y";
	$Lang->{"successfully created new relation"} = "Nueva relaci�n creada correctamente";
	$Lang->{"successfully deleted relation"} = "Relaci�n borrada correctamente";
	$Lang->{"invalid type"} = "tipo invalido";
	$Lang->{"successfully updated relation"} = "relaci�n actualizada correctamente";
	$Lang->{"Configuration Items Relations"} = "Relaciones entre elementos de configuraci�n";
	$Lang->{"Unable to delete. The relation is in used by"} = "Imposible borrar. La relaci�n es utilizada por";
	$Lang->{"connected with"} = "Conectado con"; 
	$Lang->{"used by"} =  "Usado por";
	$Lang->{"connected to"} =  "Conectado a";
	$Lang->{"includes"} =  "Incluye";
	$Lang->{"depends on"} =  "Depende de";
	$Lang->{"relevant to"} =  "relevante para";
	$Lang->{"alternative to"} =  "alternativo a";
	$Lang->{"There are no relations"} =  "No hay relaciones";
	$Lang->{"Close edit mode"} =  "Cancelar modo de edici�n";
	$Lang->{"Related Configuration Items"} =  "Elementos de Configuraci�n Relacionados";
	$Lang->{"Not Related Configuration Items"} =  "Elementos de Configuraci�n No Relacionados";
	$Lang->{"Remove"} =  "Remover";
	$Lang->{"Relation exists"} =  "La relaci�n ya existe";
	$Lang->{"Show inverse relations"} =  "Mostrar relaciones inversas";
	$Lang->{"Direction"} =  "Direcci�n";


#Configuration Items
	$Lang->{"Configuration Managment"} = "Administraci�n de la configuraci�n";
	$Lang->{"Configuration Manager"} = "Administrador de la configuraci�n";
	$Lang->{"Configuration Items"} = "Elementos de Configuraci�n";
	$Lang->{"Configuration Items Templates"} = "Templates para Elementos de Configuraci�n";
	$Lang->{"New Configuration Item"}  = "Nuevo �tem de Configuraci�n";
	$Lang->{"Edit Configuration Item"} = "Editar �tem de Configuraci�n";
	$Lang->{"Unable to obtain category parents"} = "Imposible obtener categorias padres";
	$Lang->{"This field is requiered"} = "Este campo es requerido";
	$Lang->{"Name alredy exists"} = "El nombre ya existe";
	$Lang->{"All configuration items must have a unique name"} = "Todo elemento de configuraci�n debe tener un nombre unico";
	$Lang->{"All configuration items must have a category"} = "Todo elemento de configuraci�n debe tener una categor�a";
	$Lang->{"Please wait while loading all fields..."} = "Por favor, espere mientras se cargan todos los campos....";
	$Lang->{"Unable to get form fields"} = "Imposible obtener los campos del formulario"; 
	$Lang->{"Please reload the form"} = "Por favor recargue el formulario";
	$Lang->{"Unable to get list items"}="Imposible obtener �tems de lista";
	$Lang->{"Successfully created new configuration item"} = "�tem de configuraci�n creado correctamente";
	$Lang->{"Unable to create new configuration item. Error was:"} = "Fue imposible crear el nuevo �tem de configuraci�n. El error fue:";
	$Lang->{"Click to reload"}="Haga clic para recargar";
	$Lang->{"Vendor already exists"}="El fabricante ya existe";
	$Lang->{"Unable to update configuration item. Error was:"} = "Fue imposible actualizar el �tem de configuraci�n. El error fue:";
	$Lang->{"Successfully updated configuration item"} = "�tem de configuraci�n actualizado correctamente";
	$Lang->{"Unable to create history record"} = "Imposible crear registro hist�rico";
	$Lang->{"Error was"} = "El error fue";
	
#files
	$Lang->{"successfully created new file"} = "Archivo creado correctamente";
	$Lang->{"successfully deleted file"} = "Archivo borrado correctamente";
	
#Flexigrid
	$Lang->{"Displaying {from} to {to} of {total} items"}  = "Mostrando {from} hasta {to} de {total} �tems";
 	$Lang->{"Page"}  = "P�gina";
 	$Lang->{"of"}  = "de";
 	$Lang->{"Find"}  = "Buscar";
 	$Lang->{"Processing, please wait ..."}  = "Procesando, por favor espere ...";		 
 	$Lang->{"No items"}  = "Sin �tems";
 	
#History
 	$Lang->{"Configuration Items History"} = "Historial de Elementos de Configuraci�n";
 	$Lang->{"Modification Date"} = "Fecha de modiciaci�n";
 	$Lang->{"Modificated by user"} = "Modificado por usuario";	 ;	
 	$Lang->{"First name"} = "Primer Nombre";
 	$Lang->{"Last name"}  = "Apellido";
 	$Lang->{"State history"}  = "Historial de estados";
	$Lang->{"Ticket history"}  = "Historial de tickets";
	$Lang->{"Tickets linked with configuration items"}  = "Tickets vinculados a elementos de configuraci�n";	
	$Lang->{"Ticket title"}   = "Titulo del ticket";
	$Lang->{"Created time"}   = "Fecha de creaci�n";
	$Lang->{"Linked by user"} = "Vinculado por";
 		
#OCSI
	$Lang->{"Successfully saved OCS Inevntory, Web Service configuration"} = "La configuraci�n del Web Service de OCS Inventory se guard� correctamente";
	$Lang->{"Test Connection"} = "Probar conexi�n";
	$Lang->{"Unable to connect. Error was"} = "Imposible conectar. El error fue";
	$Lang->{"Connection Success!"} = "�Conexi�n exitosa!";
	$Lang->{"Error while activating OCS Inventory compatibility"} = "Error mientras se activaba la compatibilidad con OCS Inventory";
	$Lang->{"Do import"} = "Realizar importaci�n";
	$Lang->{"Configure web service"} = "Configuraci�n del web Service";
	$Lang->{"Select categories"} = "Selecci�n de categor�as";
	$Lang->{"Import this field?"} = "�Importar este campo?";
	$Lang->{"Import as"} = "Importar como";
    $Lang->{'computer_attributes'}            = 'Atributos de computadora';
    $Lang->{'independent_components'}         = 'Componente independiente';
    $Lang->{'computer_description'}           = 'Descripci�n de computadora';
    $Lang->{'Unable to update categories to import. Error was:'}    = 'Imposible actualizar las categorias a importar. El error fue:';
    $Lang->{'Successfully saved categories to import'}           	= 'Categorias a importar correctamente actualizadas';
    $Lang->{'Creating new templates'} = "Creando nuevos templates";
 		
#Help
	$Lang->{"Description"}   = "Descripci�n";
	$Lang->{"Use"} = "Uso";
	
	$Lang->{"TEMPLATE_DESCRIPTION"} = "Un template o plantilla es un formulario pre-armado, cuya finalidad es ayudar a mantener unificada la informaci�n sobre elementos de configuraci�n (configuration items). Consta de varios campos como precio, nombre, n�mero de serie, etc.";
	$Lang->{"TEMPLATE_HELP"} = 'En la secci�n "Templates" se pueden dar de alta nuevos templates para distintas categor�as de elementos de configuraci�n. Cada template tiene una serie de campos asociados que se muestran abajo en una tabla. De estos campos, hay 7 que son comunes a todos: Nombre �nico, N�mero de serie, Descripci�n, Estado, Fabricante, Costo y D�a de adquisici�n. Opcionalmente se pueden agregar m�s campos.';
	$Lang->{"CATEGORY_DESCRIPTION"} = 'Una categor�a es un conjunto de elementos de configuraci�n de caracter�sticas similares. Una categor�a puede ser tan gen�rica o especifica como se necesite, ejemplo: "Componentes de TI" es gen�rica porque agrupa muchos elementos de configuraci�n distintos. "Mouse" es especifica ya que solo agrupa a este tipo de componentes. Una categor�a a su vez puede contener a otras sub-categor�as o categor�as hijas.';
	$Lang->{"CATEGORY_HELP"} = 'En el �rbol de la izquierda se muestran de forma jer�rquica todas las categor�as.
	<p><strong>Nueva categor�a</strong>: Se debe hacer clic en el bot�n: "Crear Nuevo". Se desplegar� un formulario con los siguientes campos:<br/>
    <b>Nombre</b>: Nombre de la nueva categor�a<br/>
    <b>�Es padre?</b>: Este campo indica si la categor�a tendr� o no categor�as hijas.<br/>
    <b>Padre</b>: Indica que categor�a ser� la que contenga a esta nueva.<br/>
    <b>Template</b>: Indica el template asociado a esta nueva categor�a.<br/>
</p>';
	
	
		
    return 1;
}

1;
