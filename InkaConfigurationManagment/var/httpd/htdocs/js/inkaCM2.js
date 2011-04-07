/*!
 * Copyright 2011, Juan Manuel Rodriguez
 * licensed under AGPL Version 2.
 * http://www.omilenitsolutions.com/
 * Date: 1-Dic-2010 * 
 */


var uniqueNameRequest = false;
var mapOfMandatoryFields = null;

function createCITable(){
	
	var cit = jQuery("#CITableContent").width();
	cit = cit - 50;
	jQuery("#CITable").flexigrid
	({
		url: 'index.pl?Action=AgentInkaConfigurationItems&ajax=1&method=getConfigurationItems',		
		dataType: 'json',
		method: 'GET', // data sending method
		colModel : [
			{display: dic["COL_0"], name : 'unique_name', 	  width : 150,  sortable : true, align: 'left'},
			{display: dic["COL_1"], name : 'serial_number',   width : 150,  sortable : true, align: 'left'},
			{display: dic["COL_2"], name : 'category', 		  width : 100,  sortable : true, align: 'center'},
			{display: dic["COL_3"], name : 'state',    		  width : 100,  sortable : true, align: 'center'},
			{display: dic["COL_4"], name : 'provider', 		  width : 100,  sortable : true, align: 'center'},
			{display: dic["COL_5"], name : 'cost', 			  width : 50,  sortable : true, align: 'right' },
			{display: dic["COL_6"], name : 'acquisition_day', width : 100,  sortable : true, align: 'right' },
			{display: dic["COL_7"], name : 'relations', width : 80,  sortable : false, align: 'right' },
			{display: dic["COL_8"], name : 'history', width : 50,  sortable : false, align: 'right' }
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
		title: dic["TABLE_TITLE"],
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

function initializeCIForm(){
		
	jQuery("#ciformBuyDate").datepicker({ dateFormat: 'dd/mm/yy' });
	populateCategory();
	var id_category = 1;
	if(currentValuesMap.id_category_parent != null && currentValuesMap.id_category_parent != undefined){
		id_category = currentValuesMap.id_category_parent;			
	}
	fillCategoryParentsArrayAndUpdate(id_category);
}


function populateCategory(){
	
	showloadDiv('ciformSelectCategoryContainer',true);
	//Remove Current Div
	jQuery('#ciformCategory').remove();
	jQuery('#ciformCategoryReload').remove();
	jQuery('#ciformSelectCategoryContainer').append('<select class="ciformSelects" id="ciformCategory" onchange="return fillCategoryParentsArrayAndUpdate(this.options[this.selectedIndex].value);">');
		
	jQuery.ajax({
		    type: "GET",
		    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=getCategoryBranchs",
		    data: {},
		    success: function(jsonCategoryList) {
		    	var categories = jQuery.parseJSON(jsonCategoryList);		    	
		    	for (i = 0; i < categories.length; i++) {
		    		jQuery("#ciformCategory").append('<option value="'+categories[i].id+'" >'+categories[i].name+'</option>');
		        }
		    	if(currentValuesMap.id_category_parent != null && currentValuesMap.id_category_parent != undefined){
		    		jQuery('#ciformCategory').val(currentValuesMap.id_category_parent);
		    		jQuery('#ciformCategory').attr('disabled', 'disabled');
	    		}
		    	hideloadDiv('ciformSelectCategoryContainer');		    	
		    },
		    error: function (XMLHttpRequest, textStatus, errorThrown) {		        
		        jQuery('#ciformCategory').hide();
		        jQuery("#ciformSelectCategoryContainer").append('<div id="ciformCategoryReload" class="reloadOnfault" onclick="populateCategory()">'+dic["NO_CAT_LIST"]+' '+dic['CLICK_REL']+'</div>');
		        hideloadDiv('ciformSelectCategoryContainer');
		    }
		});
}

function fillCategoryParentsArrayAndUpdate(category_id){

	var id = category_id;
	if(id == null || id == undefined){		
			id = jQuery('#ciformCategory').val();
	}
	jQuery.ajax({
	    type: "GET",
	    url: "index.pl?Action=AgentInkaConfigurationItems&ajax=1&method=getCategoryParents",
	    data: {'id':id },
	    success: function(data) {
	    	jQuery('#ciformCategoryParentsArray').attr('value', data);//.replace(/"/gi, "'")	    	
	    	populateSubCategory('ciformSubCategory',category_id,' updateForm(this.options[this.selectedIndex].value)',currentValuesMap.id_category);
	    	updateVendorList(currentValuesMap.id_category);
	    	toogleNewVendor(1);
	    	updateStateList(currentValuesMap.id_category);
	    	generateExtraFields(currentValuesMap.id_category);	    	
	    },
	    error: function (XMLHttpRequest, textStatus, errorThrown) {
	        alert(dic["NO_CAT_PARENTS"]);
	    }
	});	
}

function toogleNewVendor(id){
	if(id==-1){
		jQuery("#trCiformNewVendor").show();
	}else{
		jQuery("#trCiformNewVendor").hide();
	}
}

function updateStateList(category_id){
	
	showloadDiv('ciformStateContainer',true);

	//Remove Current Div
	jQuery('#ciformState').remove();
	jQuery('#ciformStateReload').remove();
	jQuery('#ciformStateContainer').append('<select class="ciformSelects" id="ciformState" name="id_state">');

	var loccategoryid = category_id;
	if(loccategoryid == null || loccategoryid == 0){
		loccategoryid = jQuery('#ciformSubCategory').val();
		if(loccategoryid == 0 || loccategoryid == null){
			loccategoryid = jQuery('#ciformCategory').val();
		}
	}
	jQuery.ajax({
		    type: "GET",
		    url: "index.pl?Action=AgentInkaConfigurationItems&ajax=1&method=getStates",
		    data: {'id_category': loccategoryid, 'parentsJsonArray':encodeURIComponent(jQuery('#ciformCategoryParentsArray').val())},
		    success: function(data) {
		    	var states = jQuery.parseJSON(data);
		    	for (i = 0; i < states.length; i++) {
		    		jQuery("#ciformState").append('<option value="'+states[i].id+'" >'+states[i].name+'</option>');
		        }
		    	if(currentValuesMap.id_state != null && currentValuesMap.id_state != undefined){
		    		jQuery('#ciformState').val(currentValuesMap.id_state);			
				}	
		    	hideloadDiv('ciformStateContainer');
		    },
		    error: function (XMLHttpRequest, textStatus, errorThrown) {		        
		        jQuery('#ciformState').hide();
		        jQuery("#ciformStateContainer").append('<div id="ciformStateReload" class="reloadOnfault" onclick="updateStateList('+category_id+')">'+dic["NO_STATES"]+' '+dic['CLICK_REL']+'</div>');
		        hideloadDiv('ciformStateContainer');
		    }
		});
}

function updateVendorList(category_id){
	
	showloadDiv('ciformVendorContainer',true);
	toogleNewVendor(1);
	//Remove Current Div
	jQuery('#ciformVendor').remove();
	jQuery('#ciformVendorReload').remove();
	jQuery('#ciformVendorContainer').append('<select class="ciformSelects" id="ciformVendor" name="id_provider" onchange="return toogleNewVendor(this.options[this.selectedIndex].value);" >');

	var loccategoryid = category_id;
	if(loccategoryid == null || loccategoryid == 0){
		loccategoryid = jQuery('#ciformSubCategory').val();
		if(loccategoryid == 0 || loccategoryid == null){
			loccategoryid = jQuery('#ciformCategory').val();
		}
	}
	jQuery.ajax({
		    type: "GET",
		    url: "index.pl?Action=AgentInkaConfigurationItems&ajax=1&method=getVendors",
		    data: {'id_category': loccategoryid, 'parentsJsonArray':encodeURIComponent(jQuery('#ciformCategoryParentsArray').val())},
		    success: function(vendorList) {
		    	var vendors = jQuery.parseJSON(vendorList);
		    	for (i = 0; i < vendors.length; i++) {
		    		jQuery("#ciformVendor").append('<option value="'+vendors[i].id+'" >'+vendors[i].name+'</option>');
		        }
		    	jQuery("#ciformVendor").append('<option value="-1" >--'+dic["OTHER"]+'--</option>');
		    	
		    	if(currentValuesMap.id_provider != null && currentValuesMap.id_provider != undefined){
		    		jQuery('#ciformVendor').val(currentValuesMap.id_provider);			
	    		}		    	
		    	hideloadDiv('ciformVendorContainer');
		    },
		    error: function (XMLHttpRequest, textStatus, errorThrown) {
		    	jQuery('#ciformVendor').hide();
		        jQuery("#ciformVendorContainer").append('<div id="ciformVendorReload" class="reloadOnfault" onclick="updateVendorList('+category_id+')">'+dic["NO_VENDOR_LIST"]+' '+dic['CLICK_REL']+'</div>');
		        hideloadDiv('ciformVendorContainer');
		    }
		});
}

function validateCIForm(){
	
	var mapOfElementsToValidate ={
			rules: {
				ciform_unique_name:"required",
				ciformSubCategory:"required"
		},
			messages: {
				ciform_unique_name:dic["CI_U_NAME"],
				ciformSubCategory:dic["CI_C"]
		}
	}; 
	if(mapOfMandatoryFields != null && mapOfMandatoryFields != undefined && mapOfMandatoryFields.length!=0 ){
		for (i = 0; i < mapOfMandatoryFields.length; i++) {    		
    		mapOfElementsToValidate.rules[mapOfMandatoryFields[i]]='required';
        }
	}
	return inkaValidateForm(mapOfElementsToValidate);	
}

/**
 * DELETE This function later
 * */
function submitCIForm(){
	
	if(!validateCIForm()){
		return false;
	}
	jQuery('#ciformSubCategory').removeAttr('disabled');
	return true;	
}

function validateUniqueName(unique_name){

	if(uniqueNameRequest===true || unique_name == null || unique_name == '') return;
	if(currentValuesMap.unique_name != null && currentValuesMap.unique_name != undefined && currentValuesMap.unique_name != ''){
		if(currentValuesMap.unique_name == unique_name) return;
	}
	uniqueNameRequest = true;
	var unique_name_encoded = encodeURIComponent(unique_name);
	jQuery.ajax({
	    type: "GET",
	    url: "index.pl?Action=AgentInkaConfigurationItems&ajax=1&method=validateUniqueName",
	    data: {'unique_name': unique_name_encoded},
	    success: function(data) {
	    	var results = jQuery.parseJSON(data);
	    	if(document.getElementById('ciform_unique_nameMessage') == null || document.getElementById('ciform_unique_nameMessage') == undefined){
				jQuery('#ciform_unique_name').parent().append('<div class="" id="ciform_unique_nameMessage"></div>');
			}

	    	if(results.valid == 'true'){
	    		 jQuery('#ciform_unique_name').removeClass('inputError');
	    		 jQuery('#ciform_unique_name').addClass('inputOk');
	    		 jQuery('#ciform_unique_nameMessage').removeClass('labelErrorMessage');
	    		 jQuery('#ciform_unique_nameMessage').addClass('labelOkMessage');
	    		 jQuery('#ciform_unique_nameMessage').html('');
	    	}else{
	    		 jQuery('#ciform_unique_name').removeClass('inputOk');
	    		 jQuery('#ciform_unique_name').addClass('inputError');
	    		 jQuery('#ciform_unique_nameMessage').removeClass('labelOkMessage');
	    		 jQuery('#ciform_unique_nameMessage').addClass('labelErrorMessage');
	    		 jQuery('#ciform_unique_nameMessage').html(dic["NAME_EXISTS"]);
	    	}
	    	uniqueNameRequest = false;
	    },
	    error: function (XMLHttpRequest, textStatus, errorThrown) {
	    	uniqueNameRequest = false;
	    }
	});
}

function updateForm(category_id){
	updateVendorList(category_id);
	generateExtraFields(category_id);
}
/*
currentValue can be nul
*/
function populateGenericList(select_id,list_id,mandatory,currentValue){
		
	var  generic = jQuery('#'+select_id);
	if(generic.length === 0 || list_id===0){
		return;
	}
	jQuery('#ciform'+select_id+'Reload').remove();
	showloadDiv(generic.parent().attr('id'),true);

	jQuery.ajax({
		    type: "GET",
		    url: "index.pl?Action=AgentInkaConfigurationItems&ajax=1&method=getGenericListItems",
		    data: {'id_list': list_id, 'mandatory':mandatory},
		    success: function(data) {
		    	var elementLists = jQuery.parseJSON(data);
		    	if(!mandatory){
		    		generic.append('<option value="0" > --'+dic['NONE']+'-- </option>');
		    	}
		    	for (i = 0; i < elementLists.length; i++) {
		    		generic.append('<option value="'+elementLists[i].id+'" >'+elementLists[i].name+'</option>');
		        }		    	
		    	hideloadDiv(generic.parent().attr('id'));		    
		    	if(currentValue!=undefined && currentValue!=null && currentValue !== 0) {
		    		generic.val(currentValue);
		    	}
		    },
		    error: function (XMLHttpRequest, textStatus, errorThrown) {		       
		        generic.hide();
		        generic.parent().append('<div id="ciform'+select_id+'Reload" class="reloadOnfault" onclick="populateGenericList(\''+select_id+'\','+list_id+','+mandatory+')">'+dic["NO_LIST_ITEMS"]+' '+dic['CLICK_REL']+'</div>');
		        hideloadDiv(generic.parent().attr('id'));
		    }
		});
}

/**
 * For a given category this method will create all NON-Default fields 
 * */
function generateExtraFields(category_id){

	var groupOfPropsToDelete = jQuery('[class="newGroupOfProperties"]');
	for(var i =0;i<groupOfPropsToDelete.length;i++){
		jQuery('#'+groupOfPropsToDelete[i].id).remove();
	}
	var elementos = jQuery('[class="ExtraField"]');
	for(var i =0;i<elementos.length;i++){	
		jQuery('#'+elementos[i].id).remove();
	}
	delete mapOfMandatoryFields;

	if(category_id == 0 || category_id == null){
		jQuery('#ciformTrLoading').hide();
    	jQuery('#ciformSubmit').show();
    	return;
	}
	jQuery('#ciformTrLoading').show();
	jQuery('#ciformSubmit').hide();	
	
	jQuery.ajax({
		    type: "GET",
		    url: "index.pl?Action=AgentInkaConfigurationItems&ajax=1&method=getTemplateFields",
		    data: {'id_category':category_id},
		    success: function(data) {
		    	var fields = jQuery.parseJSON(data);
		    	var inputHTMLelement = '';
		    	var todoAfter = '';
		    	var asterisco = '';
		    	var groupid = '1';
		    	var idContent = 'ciformBodyDefaultTable';
		    	mapOfMandatoryFields = new Array();
		    	for (var i = 0; i < fields.length; i++) {
		    		if(groupid!=fields[i].id_properties_group){
		    		   groupid=fields[i].id_properties_group;
		    		   idContent = generateNewPropertyGroup(fields[i].id_properties_group,fields[i].group_name);
		    		}
		    		switch (fields[i].id_metatype) {
					case '1': //integer
						inputHTMLelement = '<input onkeypress="return validateIntegerInput(event,this);" class="ciformInputs" type="text" value="" id="ciformG'+fields[i].id+'" name="generic_'+fields[i].id+'"/>';
						break;
					case '2': //float
						inputHTMLelement = '<input onkeypress="return validateFloatInput(event,this);" class="ciformInputs" type="text" value="" id="ciformG'+fields[i].id+'" name="generic_'+fields[i].id+'"/>';
						break;
					case '3': //string
						inputHTMLelement = '<input class="ciformInputs" type="text" value="" id="ciformG'+fields[i].id+'" name="generic_'+fields[i].id+'"/>';
						break;
					case '4': //Date time
						inputHTMLelement = '<input class="ciformInputs" type="text" value="" id="ciformG'+fields[i].id+'" name="generic_'+fields[i].id+'"/><small><i>dd/mm/yyyy</i></small>';
						todoAfter = todoAfter+'jQuery("#ciformG'+fields[i].id+'").datepicker({ dateFormat: \'dd/mm/yy\' }); ';
						break;
					case '5': //Boolean
						inputHTMLelement = '<input class="ciformInputs" type="checkbox" value="1" id="ciformG'+fields[i].id+'" name="generic_'+fields[i].id+'"/>';
						break;
					case '6': //File
						inputHTMLelement = '<input class="ciformInputs" type="file" id="ciformG'+fields[i].id+'_name" name="generic_'+fields[i].id+'_name"/><input type="hidden" value="" id="ciformG'+fields[i].id+'" name="generic_'+fields[i].id+'" />';						
						break;
					case '7': //Generric List
						inputHTMLelement = '<div id="ciformGTD'+fields[i].id+'"><select name="generic_'+fields[i].id+'" class="ciformSelects" id="ciformG'+fields[i].id+'"></select></div>';						
						todoAfter = todoAfter+'populateGenericList("ciformG'+fields[i].id+'",'+fields[i].id_list+','+fields[i].mandatory+','+currentValuesMap['val_'+fields[i].id]+'); ';
						break;					
					default:
						break;
					}
		    		if(fields[i].mandatory==1){
		    			asterisco='*';
		    			mapOfMandatoryFields.push('ciformG'+fields[i].id);
		    		}else{
		    			asterisco='';
		    		}
		    		jQuery("#"+idContent).append('<tr class="ExtraField" id="ciformGTR'+i+'" ><td class="tdCaptionForm"><label for="ciformG'+fields[i].id+'">'+asterisco+fields[i].caption+':</label></td>'+
		    				'<td colspan="2">'+inputHTMLelement+'</td></tr>');
		        }
		    	jQuery('#ciformTrLoading').hide();
		    	jQuery('#ciformSubmit').show();
		    	eval(todoAfter);
		    	setCurrentValues(fields);
		    },
		    error: function (XMLHttpRequest, textStatus, errorThrown) {
		        alert(dic["NO_FIELDS"]);
		        jQuery('#ciformTrLoading').hide();
		    	jQuery('#ciformSubmit').show();	
		    }
		});
}

function setCurrentValues(fields){

	for (var i = 0; i < fields.length; i++) {
		switch (fields[i].id_metatype) {
			case '5': //Boolean
				jQuery('#ciformG'+fields[i].id).attr('checked', (currentValuesMap['val_'+fields[i].id]=='1'));
				break;
			case '7': break;//Generic List
			case '6': //File				 
				 jQuery('#ciformG'+fields[i].id+"_name").parent().append('<a target="_blank" id="ciformG'+fields[i].id+'_filedownload" href="index.pl?Action=AgentInkaConfigurationItems&file=1&id='+currentValuesMap['val_'+fields[i].id]+'">'+currentValuesMap['name_'+fields[i].id]+'</a>');
				 jQuery('#ciformG'+fields[i].id+"_name").parent().append('&nbsp;&nbsp;<div id="ciformG'+fields[i].id+'_filedelete" class="DeleteIcon clickeable" onclick="return deleteCurrentFile('+fields[i].id+');">&nbsp;</div>');
				 jQuery('#ciformG'+fields[i].id+"_name").hide();
			default:
				 jQuery('#ciformG'+fields[i].id).val(currentValuesMap['val_'+fields[i].id]);
				break;
		}
    }
}

function deleteCurrentFile(idElement){

	if(idElement == null || idElement == undefined){
		return;
	}
	jQuery('#ciformG'+idElement).val(0);
	jQuery('#ciformG'+idElement+'_filedownload').remove();
	jQuery('#ciformG'+idElement+'_filedelete').remove();	
	jQuery('#ciformG'+idElement+'_name').show('fast');
	jQuery('#ciformG'+idElement+"_name").parent().append('<div style="display: inline-table;" class="fakeLink" id="ciformG'+idElement+'_fileundo" onclick="return undoFileDeletion('+idElement+');">'+dic['UNDO']+'</div>');
		
}
function undoFileDeletion(idElement){
	
	var field= new Array();
	field[0]= new Array();
	field[0]['id'] = idElement;
	field[0]['id_metatype'] = '6';		
	jQuery('#ciformG'+idElement+'_fileundo').remove();
	return setCurrentValues(field);
}

function generateNewPropertyGroup(group_id, group_name){

	var id='ciformBody'+group_id+'Table';
	jQuery("#ciform_content").append('<div class="newGroupOfProperties" style="width: 80%;" id="'+id+'Container">'+
									 '<table width="100%">'+
									 '<thead>'+
									 '	<tr style="background-color: #75c0c9;">'+
									 '		<th width="30%">'+dic['PROP_GROUP']+':</th>'+
									 '		<th colspan="2">'+group_name+'</th>'+
									 '	</tr>'+
									 '</thead>'+
									 '<tbody id="'+id+'"></tbody></table>'+
									 '</div>');
	return id;
}
