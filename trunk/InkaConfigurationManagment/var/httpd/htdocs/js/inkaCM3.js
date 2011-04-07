/*!
 * Copyright 2011, Juan Manuel Rodriguez
 * licensed under AGPL Version 2.
 * http://www.omilenitsolutions.com/
 * Date: 20-Ene-2010 
 */

var flArrayRelated = new Array(); 
flArrayRelated[1]  = new Array(); 
flArrayRelated[2]  = new Array(); 

var flArrayNoRelated = new Array(); 
flArrayNoRelated[1]  = new Array(); 
flArrayNoRelated[2]  = new Array();

var showInverseRelationsArray = new Array();

function initializeLinkSection(typeCount){
	jQuery( "#accordionRelation" ).accordion({ autoHeight: true});	
	jQuery( "#accordionRelation" ).accordion("activate" , typeCount-1 );
}

/*
 * params:
 * 	ci_id: id of the CI
 *  link_id: id of the "relation" type
 *  type: integer //1: "CI" or 2: "User"
 *  count: integer //how many relations has the CI selected for this particular type
 * */
function createRelationTable(ci_id,link_id,type,count){
		
	if(type == null || (type != 1 && type != 2)){
		type = 1;
	}
	if(count==null || count == 0){
		return setEmptyMessage('CIRelation_'+type+'_'+link_id);
	}
	
	if(type == 1){
		jQuery('#inputShow_'+type+'_'+link_id).attr('checked', false);
		jQuery('#inputShowContainer_'+type+'_'+link_id).show();
		flArrayRelated[type][link_id] = jQuery('#CIRelation_'+type+'_'+link_id).flexigrid
		({
			url: 'index.pl?Action=AgentInkaConfigurationItems&ajax=1&method=getRelatedConfigurationItems&id_ci='+ci_id+'&id_type='+link_id,		
			dataType: 'json',
			method: 'GET', // data sending method
			colModel : [
			    {display: dic["COL_5"], name : 'direction', 	  width : 100,  sortable : true, align: 'center'},
				{display: dic["COL_0"], name : 'unique_name', 	  width : 100,  sortable : true, align: 'center'},
				{display: dic["COL_1"], name : 'serial_number',   width : 100,  sortable : true, align: 'center'},
				{display: dic["COL_2"], name : 'category', 		  width : 100,  sortable : true, align: 'center'},
				{display: dic["COL_3"], name : 'state',    		  width : 100,  sortable : true, align: 'center'},
				{display: dic["COL_4"], name : 'provider', 		  width : 100,  sortable : true, align: 'center'}
				],
			searchitems : [
				{display: dic["COL_1"],  name : 'serial_number'},
				{display: dic["COL_2"],  name : 'c.name'},
				{display: dic["COL_3"],  name : 's.name'},
				{display: dic["COL_4"],  name : 'p.name'},			
				{display: dic["COL_0"],  name : 'unique_name', isdefault: true}
				],
			sortname: "unique_name",
			sortorder: "asc",
			usepager: true,
			title: dic["REL_CI"],
			useRp: true,
			rp: 15,
			showTableToggleBtn: true,			
			width: 600,	
			height: 100,		
			 pagestat: dic["FLEX_pagestat"],
			 pagetext: dic["FLEX_pagetext"],
			 outof: dic["FLEX_outof"],
			 findtext: dic["FLEX_findtext"],
			 procmsg: dic["FLEX_procmsg"],		 
			 nomsg: dic["FLEX_nomsg"]
		});
	
	}else{
		flArrayRelated[type][link_id] = jQuery('#CIRelation_'+type+'_'+link_id).flexigrid
		({
			url: 'index.pl?Action=AgentInkaConfigurationItems&ajax=1&method=getRelatedUsers&id_ci='+ci_id+'&id_type='+link_id,		
			dataType: 'json',
			method: 'GET', // data sending method
			colModel : [
				{display: dic["COL_USR_0"], name : 'login', 	   width : 100,  sortable : true, align: 'center'},
				{display: dic["COL_USR_1"], name : 'first_name',   width : 100,  sortable : true, align: 'center'},
				{display: dic["COL_USR_2"], name : 'last_name',    width : 100,  sortable : true, align: 'center'}				
				],
			searchitems : [				
				{display: dic["COL_USR_1"],  name : 'first_name'},
				{display: dic["COL_USR_2"],  name : 'last_name'},							
				{display: dic["COL_USR_0"],  name : 'login', isdefault: true}
				],
			sortname: "login",
			sortorder: "asc",
			usepager: true,
			title: dic["REL_USER"],
			useRp: true,
			rp: 15,
			showTableToggleBtn: true,
			width: 600,	
			height: 100,		
			 pagestat: dic["FLEX_pagestat"],
			 pagetext: dic["FLEX_pagetext"],
			 outof: dic["FLEX_outof"],
			 findtext: dic["FLEX_findtext"],
			 procmsg: dic["FLEX_procmsg"],		 
			 nomsg: dic["FLEX_nomsg"]
		});
		
	}
}

/*************
 * params:
 * 	 ci_id	 : id of the CI
 *   link_id : id of the "relation" type
 *   type	 : integer 	//1: "CI" or 2: "User"
 *   count	 : integer 	//how many relations has the CI selected for this particular type
 ****************************************************************************************/
function createNonRelatedTable(ci_id,link_id,type,count){
		
	if(type == null || (type != 1 && type != 2)){
		type = 1;
	}
	if(type == 1){
		
		flArrayNoRelated[type][link_id] = jQuery('#CINONRelated_'+type+'_'+link_id).flexigrid
		({
			url: 'index.pl?Action=AgentInkaConfigurationItems&ajax=1&method=getNonRelatedConfigurationItems&id_ci='+ci_id+'&id_type='+link_id,		
			dataType: 'json',
			method: 'GET', // data sending method
			colModel : [
				{display: dic["COL_0"], name : 'unique_name', 	  width : 100,  sortable : true, align: 'center'},
				{display: dic["COL_1"], name : 'serial_number',   width : 100,  sortable : true, align: 'center'},
				{display: dic["COL_2"], name : 'category', 		  width : 100,  sortable : true, align: 'center'},
				{display: dic["COL_3"], name : 'state',    		  width : 100,  sortable : true, align: 'center'},
				{display: dic["COL_4"], name : 'provider', 		  width : 100,  sortable : true, align: 'center'}
				],
			searchitems : [
				{display: dic["COL_1"],  name : 'serial_number'},
				{display: dic["COL_2"],  name : 'c.name'},
				{display: dic["COL_3"],  name : 's.name'},
				{display: dic["COL_4"],  name : 'p.name'},			
				{display: dic["COL_0"],  name : 'unique_name', isdefault: true}
				],
			sortname: "unique_name",
			sortorder: "asc",
			usepager: true,
			title: dic["NO_REL_CI"],
			useRp: true,
			rp: 15,
			showTableToggleBtn: true,
			width: 600,	
			height: 100,		
			 pagestat: dic["FLEX_pagestat"],
			 pagetext: dic["FLEX_pagetext"],
			 outof: dic["FLEX_outof"],
			 findtext: dic["FLEX_findtext"],
			 procmsg: dic["FLEX_procmsg"],		 
			 nomsg: dic["FLEX_nomsg"]
		});
	}else{
		flArrayNoRelated[type][link_id] = jQuery('#CINONRelated_'+type+'_'+link_id).flexigrid		
		({
			url: 'index.pl?Action=AgentInkaConfigurationItems&ajax=1&method=getNonRelatedUser&id_ci='+ci_id+'&id_type='+link_id,		
			dataType: 'json',
			method: 'GET', // data sending method
			colModel : [
				{display: dic["COL_USR_0"], name : 'login', 	   width : 100,  sortable : true, align: 'center'},
				{display: dic["COL_USR_1"], name : 'first_name',   width : 100,  sortable : true, align: 'center'},
				{display: dic["COL_USR_2"], name : 'last_name',    width : 100,  sortable : true, align: 'center'}				
				],
			searchitems : [				
				{display: dic["COL_USR_1"],  name : 'first_name'},
				{display: dic["COL_USR_2"],  name : 'last_name'},							
				{display: dic["COL_USR_0"],  name : 'login', isdefault: true}
				],
			sortname: "login",
			sortorder: "asc",
			usepager: true,
			title: dic["NO_REL_USER"],
			useRp: true,
			rp: 15,
			showTableToggleBtn: true,
			width: 600,	
			height: 100,		
			 pagestat: dic["FLEX_pagestat"],
			 pagetext: dic["FLEX_pagetext"],
			 outof: dic["FLEX_outof"],
			 findtext: dic["FLEX_findtext"],
			 procmsg: dic["FLEX_procmsg"],		 
			 nomsg: dic["FLEX_nomsg"]
		});
	}
}
/*
 * When there are no relations to show, we avoid draw the flexigrid which is expensive and print only a message
 * */
function setEmptyMessage(idTable){
	jQuery('#'+idTable).parent().append('<h3 style="text-align:center;" id="'+idTable+'Message">'+dic['NO_REL']+'.</h3>');	
}

/*
 * params:
 * 	ci_id: id of the CI
 *  link_id: id of the "relation" type
 *  type: integer //1: "CI" or 2: "User"
 *  count: integer //how many relations has the CI selected for this particular type
 * */
function editRelation(ci_id,link_id,type,count){
	
	if(count == 0){
		jQuery('#CIRelation_'+type+'_'+link_id+'Message').remove();
		createRelationTable(ci_id,link_id,type,1);		
	}
	jQuery('#addRemoveCIContainer_'+type+'_'+link_id).show();
	createNonRelatedTable(ci_id,link_id,type,count);
	jQuery('#editContent_'+type+'_'+link_id+'_1').hide();
	jQuery('#editContent_'+type+'_'+link_id+'_2').show();
	jQuery('#labelCount_'+type+'_'+link_id).remove();		
}

/*
 * params: * 	
 *  link_id: id of the "relation" type
 *  type: integer //1: "CI" or 2: "User"  
 * */
function cancelEditMode(link_id,type){
	
	jQuery('#CINONRelated_'+type+'_'+link_id+'_Container').replaceWith( '<table id="CINONRelated_'+type+'_'+link_id+'" style="display:none"></table>' );
	jQuery('#editContent_'+type+'_'+link_id+'_1').show();
	jQuery('#editContent_'+type+'_'+link_id+'_2').hide();
	jQuery('#addRemoveCIContainer_'+type+'_'+link_id).hide();
}

/*
 * params:
 * 	ci_id: id of the CI
 *  link_id: id of the "relation" type
 *  type: integer //1: "CI" or 2: "User"  
 * */
function updateRelation(ci_id,link_id,type,operation){
	var arrayOfId = new Array();
	var method = 'linkUnlinkCIs';
	var gridSelected = flArrayNoRelated[type][link_id];	
	if(operation == 'unlink'){
		gridSelected = flArrayRelated[type][link_id];
	}
	
	jQuery('.trSelected', gridSelected).each(function() {
		var id = jQuery(this).attr('id');		
		id = id.substring(id.lastIndexOf('row')+3);
		arrayOfId.push(id);		
	});	
	if(type == null || (type != 1 && type != 2)){
		type = 1;
	}
	
	if(type == 2){
		method = 'linkUnlinkCIToUsers';
	}
	
	 jQuery.ajax({
		    type: "GET",
		    url: "index.pl?Action=AgentInkaConfigurationItems&ajax=1&method="+method,
		    data: {'id_array':   JSON.stringify(arrayOfId), 'operation': operation,'id':ci_id,'link_type':link_id},// arrayOfFields			    
		    success: function(messageData) {		    	
		    	var message = jQuery.parseJSON(messageData);
		    	flArrayRelated[type][link_id].flexReload();
		    	flArrayNoRelated[type][link_id].flexReload();		    	
		    	document.getElementById('MessageError_'+type+'_'+link_id).innerHTML = message.error;		    	
		    },
		    error: function (XMLHttpRequest, textStatus, errorThrown) {
		    	document.getElementById('MessageError_'+type+'_'+link_id).innerHTML = dic["UNKNOWN_ERROR"];

		    }
	});	
}

function showInverseRelation(ci_id,link_id,type,operation){
	
	var showInverse = new Array();
	showInverse[0]= new Object;
	
	if (jQuery('#inputShow_'+type+'_'+link_id).attr('checked')) {		
		showInverse[0].value = 1;
		showInverse[0].name = 'showInverse';				
		jQuery('#CIRelation_'+type+'_'+link_id).flexOptions({params: showInverse}).flexReload();
	}
	else
	{
		showInverse[0].value = 0;
		showInverse[0].name = 'showInverse';				
		jQuery('#CIRelation_'+type+'_'+link_id).flexOptions({params: showInverse}).flexReload();
	}
}

//###########History section

function populateHistoryTable(ci_id){
	
	var cit = jQuery("#CITableContent").width();
	cit = cit - 50;
	jQuery('#CIHistoryTable').flexigrid		
	({
		url: 'index.pl?Action=AgentInkaConfigurationItems&ajax=1&method=getCIHistory&id_ci='+ci_id,		
		dataType: 'json',
		method: 'GET', // data sending method
		colModel : [
			{display: dic["COL_HST_0"], name : 'modification_date', width : 150,  sortable : true, align: 'center'},
			{display: dic["COL_HST_1"], name : 'login',    width : 200,  sortable : true, align: 'center'},
			{display: dic["COL_HST_2"], name : 'note',    			width : 150,  sortable : true, align: 'center'},				
			{display: dic["COL_HST_3"], name : 'state',    			width : 150,  sortable : true, align: 'center'}
			],
		searchitems : [		
			{display: dic["COL_HST_3"],  name : 'name', isdefault: true},							
			{display: dic["COL_HST_4"],  name : 'login'},	
			{display: dic["COL_HST_5"],  name : 'first_name'},
			{display: dic["COL_HST_6"],  name : 'last_name'}
			],
		sortname: "modification_date",
		sortorder: "asc",
		usepager: true,
		title: dic["HISTORY_TITLE"],
		useRp: true,
		rp: 15,
		showTableToggleBtn: true,
		width: cit,
		height: 350,
		 pagestat: dic["FLEX_pagestat"],
		 pagetext: dic["FLEX_pagetext"],
		 outof: dic["FLEX_outof"],
		 findtext: dic["FLEX_findtext"],
		 procmsg: dic["FLEX_procmsg"],		 
		 nomsg: dic["FLEX_nomsg"]
	});
	
}

function populateHistoryTicketTable(ci_id){
	
	var cit = jQuery("#CITableContent").width();
	cit = cit - 50;
	jQuery('#CITicketsTable').flexigrid		
	({
		url: 'index.pl?Action=AgentInkaConfigurationItems&ajax=1&method=getCITicketHistory&id_ci='+ci_id,		
		dataType: 'json',
		method: 'GET', // data sending method
		colModel : [
			{display: dic["COL_HST_T_0"], name : 'tn', 			width : 150,  sortable : true, align: 'center'},
			{display: dic["COL_HST_T_1"], name : 'title',    	width : 150,  sortable : true, align: 'center'},			
			{display: dic["COL_HST_T_2"], name : 'ts.name',    	width : 100,  sortable : true, align: 'center'},
			{display: dic["COL_HST_T_3"], name : 'create_time', width : 150,  sortable : true, align: 'center'},				
			{display: dic["COL_HST_T_4"], name : 'login',    	width : 200,  sortable : true, align: 'center'}
			],
		searchitems : [
			{display: dic["COL_HST_T_0"], name : 'tn', isdefault: true},
			{display: dic["COL_HST_T_1"], name : 'title'},
			{display: dic["COL_HST_T_2"], name : 'ts.name'}, 
			{display: dic["COL_HST_4"],  name : 'login'},
			{display: dic["COL_HST_5"],  name : 'first_name'},
			{display: dic["COL_HST_6"],  name : 'last_name'}
			],
		sortname: "create_time",
		sortorder: "asc",
		usepager: true,
		title: dic["TICKET_TITLE"],
		useRp: true,
		rp: 15,
		showTableToggleBtn: true,
		width: cit,
		height: 350,
		 pagestat: dic["FLEX_pagestat"],
		 pagetext: dic["FLEX_pagetext"],
		 outof: dic["FLEX_outof"],
		 findtext: dic["FLEX_findtext"],
		 procmsg: dic["FLEX_procmsg"],
		 nomsg: dic["FLEX_nomsg"]
	});
}