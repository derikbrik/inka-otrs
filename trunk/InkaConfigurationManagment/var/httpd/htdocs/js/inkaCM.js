/*!
 * Copyright 2011, Juan Manuel Rodriguez
 * licensed under AGPL Version 2.
 * http://www.omilenitsolutions.com/
 * Date: 8-Sep-2010 
 */



function openCategoryForm(categoryId){
	 jQuery("#categoryForm").show("fast");
	 if(categoryId == null || categoryId == 0){
		 //New
		 jQuery("#titleEditCategory").hide();
	     jQuery("#titleNewCategory").show();
	     
		 jQuery('#categoryName').attr('value', '');	    	
	     jQuery('#categoryGroup').attr('checked', false);
	     jQuery('#categoryId').attr('value', '0');
	     jQuery('#categoryTemplateCT').val(0);
	     jQuery('#categoryParentCT').val(1);
		 
	 }else{
		 showloadDiv('categoryForm');
		 jQuery("#titleNewCategory").hide();
		 jQuery("#titleEditCategory").show();	     
		 jQuery.ajax({
			    type: "GET",
			    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=getCategory",
			    data: {'id': categoryId},
			    success: function(jsonCategory) {
			    	var categoryjson = jQuery.parseJSON(jsonCategory);
			    	jQuery('#categoryName').attr('value', categoryjson.name);
			    	jQuery('#categoryId').attr('value', categoryId);
			    	
			    	jQuery('#categoryTemplateCT').val(categoryjson.id_template);
			    	jQuery('#categoryParentCT').val(categoryjson.id_parent);
			    	
			    	if(categoryjson.is_branch == 1){
			    		jQuery('#categoryGroup').attr('checked', true);
			    	}else{
			    		jQuery('#categoryGroup').attr('checked', false);
			    	}
			    		jQuery('#categoryTranslatedAs').attr('value', categoryjson.translated);

			 		hideloadDiv('categoryForm');
			    },
			    error: function (XMLHttpRequest, textStatus, errorThrown) {
			        alert(dic["NO_CAT_DATA"]);
			        hideloadDiv('categoryForm');
			    }
			});	

		}
		document.getElementById('MessageOkCT').innerHTML = '';
	 	document.getElementById('MessageErrorCT').innerHTML = '';
}

function openStateForm(stateId,category_id,name){
	 jQuery("#stateForm").show("fast");
	 if(stateId == null || stateId == 0){
		 //New
		 jQuery('#stateName').attr('value', '');
	     jQuery('#stateId').attr('value', '0');
	     jQuery("#titleEditState").hide();
	     jQuery("#titleNewState").show();
	     jQuery("#deleteStateButton").hide();
		 
	 }else{
		 jQuery("#titleNewState").hide();
	     jQuery("#titleEditState").show();
		 jQuery('#stateName').attr('value', name);
	     jQuery('#stateId').attr('value', stateId);		 	
	     jQuery('#stateCategory').val(category_id);
	     jQuery("#deleteStateButton").show();
	    
	}
	document.getElementById('MessageOkST').innerHTML = '';
 	document.getElementById('MessageErrorST').innerHTML = '';
}

function openVendorForm(vendorId,categoryId,name){
	 
	 jQuery("#vendorForm").show("fast");
	 if(vendorId == null || vendorId == 0){
		 //New
		 categoryId = jQuery('#vendorSubCategory').val();
		 if(categoryId == 0){
			 categoryId = jQuery('#vendorCategory').val();
		 }
		 
		 jQuery('#vendorName').attr('value', '');
	     jQuery('#vendorId').attr('value', '0');	     	     
	     jQuery("#titleEditVendor").hide();
	     jQuery("#titleNewVendor").show();
	     jQuery("#deleteVendorButton").hide();
		 
	 }else{
		 jQuery("#titleNewVendor").hide();
	     jQuery("#titleEditVendor").show();
		 jQuery('#vendorName').attr('value', name);
	     jQuery('#vendorId').attr('value', vendorId);
	     jQuery('#vendorCategoryId').attr('value', categoryId);	    
	     jQuery("#deleteVendorButton").show();	    
	}
	 
	if(jQuery('#vendorSubCategory').val() == 0){
		 jQuery('#categoryNameVendor').html(jQuery("#vendorCategory option[value='"+categoryId+"']").text());
		 jQuery('#vendorCategoryId').attr('value', jQuery('#vendorCategory').val());
	}else{
		 jQuery('#categoryNameVendor').html(jQuery("#vendorSubCategory option[value='"+categoryId+"']").text());
		 jQuery('#vendorCategoryId').attr('value', jQuery('#vendorSubCategory').val());
	}	
	document.getElementById('MessageOkVT').innerHTML = '';
	document.getElementById('MessageErrorVT').innerHTML = '';
}

function openLinkForm(id,name){
	
	var edit = id;
	jQuery("#linkForm").show("fast");	 
	if(edit == null || edit == 0){
		 //New			 
		 jQuery('#linkName').attr('value', '');
		 jQuery('#linkId').attr('value', '0');
		 jQuery("#titleEditLink").hide();
	     jQuery("#titleNewLink").show();		 
		 jQuery("#deleteLinkButton").hide();	     		 
	}else{
		 jQuery('#linkName').attr('value', name);
		 jQuery('#linkId').attr('value', id);
		 jQuery("#titleEditLink").show();
	     jQuery("#titleNewLink").hide();
	     jQuery("#deleteLinkButton").show();	    
	}	
	document.getElementById('MessageOkLT').innerHTML = '';
	document.getElementById('MessageOkLT').innerHTML = '';
	
}

function closeLinkForm(){	
	jQuery("#linkForm").hide("fast");	 
}

function deleteLink(){
	
	var type = jQuery('#linkSelectHumanCI').val(); //1: users 2: CI 
	var id   = jQuery('#linkId').val();
	if(id == null || type==null){
			return;
	}
	if (confirm(dic["CONFIRM_ELEM"])) {
	        
			 jQuery.ajax({
				    type: "GET",
				    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=deleteLink",
				    data: {"id": id, "type": type},
				    success: function(messageData) {
				    	closeLinkForm();
				    	var message = jQuery.parseJSON(messageData);
				    	document.getElementById('MessageOkLT').innerHTML = message.ok;
				    	document.getElementById('MessageErrorLT').innerHTML = message.error;			    	
				    	populateRelationList();
				    },
				    error: function (XMLHttpRequest, textStatus, errorThrown) {
				        alert(dic["NO_DEL_ELE"]);
				    }
			});		 
	}
}

function submitLinkForm(){
	
	 var type = jQuery('#linkSelectHumanCI').val(); //1: users 2: CI 
	 var id   = jQuery('#linkId').val();
	 var name = encodeURIComponent(jQuery('#linkName').val());
	 
	 if( name.length === 0 ) {
		 document.getElementById('MessageErrorLT').innerHTML = dic["NAME_EMPTY"];
		 return;
	 }
	 
	 if(id == null){
		 id = 0;
	 }
	 jQuery.ajax({
		    type: "GET",
		    contentType: "application/json; charset="+CHARSET,
		    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=saveLink",		   
		    data: {'id': id, 'type': type, 'name': name},
		    success: function(jsonMessage) {
		    	var message = jQuery.parseJSON(jsonMessage);
		    	document.getElementById('MessageOkLT').innerHTML = message.ok;
		    	document.getElementById('MessageErrorLT').innerHTML = message.error;
		    	populateRelationList();
		    	if(id == 0){
		    		closeLinkForm();
		    	}
		    },
		    error: function (XMLHttpRequest, textStatus, errorThrown) {
		        alert(dic["NO_STATUS"]);
		    
		    }
	});
}


function openListForm(edit){
	 
	jQuery("#listElementForm").hide();
	 jQuery("#listForm").show("fast");	 
	 if(edit == null || edit == 0){
		 //New			 
		 jQuery('#listName').attr('value', '');
	     jQuery('#listId').attr('value', '0');	     	     
	     jQuery("#titleEditList").hide();
	     jQuery("#titleNewList").show();
	     jQuery("#deleteListButton").hide();
		 
	 }else{
		 //Edit
		 jQuery("#titleNewList").hide();
	     jQuery("#titleEditList").show();
		 jQuery('#listName').attr('value',jQuery("#listList option:selected").text());
	     jQuery('#listId').attr('value',   jQuery('#listList').val());	   
	     jQuery("#deleteListButton").show();	    
	}	
	document.getElementById('MessageOkGLT').innerHTML = '';
	document.getElementById('MessageErrorGLT').innerHTML = '';
}

function openElementListForm(id,name,value){
	 
	 jQuery("#listForm").hide();	
	 jQuery("#listElementForm").show("fast");	 
	 if(id == null || id == 0){
		 //New			 
		 jQuery('#listElementName').attr('value', '');
		 jQuery('#listElementValue').attr('value', '');
	     jQuery('#listElementId').attr('value', '0');	     	     
	     jQuery("#titleEditListElement").hide();
	     jQuery("#titleNewListElement").show();
	     jQuery("#deleteListElementButton").hide();
		 
	 }else{
		 //Edit
		 jQuery("#titleNewListElement").hide();
	     jQuery("#titleEditListElement").show();
	     jQuery('#listElementName').attr('value', name);
		 jQuery('#listElementValue').attr('value', value);
	     jQuery('#listElementId').attr('value', id);
	     jQuery("#deleteListElementButton").show();	    
	}	
	document.getElementById('MessageOkGLT').innerHTML = '';
	document.getElementById('MessageErrorGLT').innerHTML = '';
}

function closeListForm(){
	jQuery("#listForm").hide("fast");
	jQuery("#listElementForm").hide();
}

function closeTemplateForm(){
	jQuery("#templateForm").hide("fast");
	jQuery("#templateFieldForm").hide();
}

function closeStateForm(){
	jQuery("#stateForm").hide("fast");	
}

function closeCategoryForm(){
	jQuery("#categoryForm").hide("fast");	
}

function closeVendorForm(){
	jQuery("#vendorForm").hide("fast");	
}

function deleteListElement(){
	
	var id = jQuery('#listElementId').val();
	 if(id == null){
			return;
	 }
	 if (confirm(dic["CONFIRM_ELEM"])) {
	        
			 jQuery.ajax({
				    type: "GET",
				    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=deleteGenericListElement",
				    data: {"id": id},
				    success: function(messageData) {
				    	closeListForm();
				    	var message = jQuery.parseJSON(messageData);
				    	document.getElementById('MessageOkGLT').innerHTML = message.ok;
				    	document.getElementById('MessageErrorGLT').innerHTML = message.error;			    	
				    	updateListList();
				    },
				    error: function (XMLHttpRequest, textStatus, errorThrown) {
				        alert(dic["NO_DEL_LIST"]);
				    }
			});		 
	    }
	
}

function deleteList(){
	
	 var id = jQuery('#listId').val();
	 if(id == null){
			return;
	 }
	 if (confirm(dic['CONFIRM_CHILD'])) {
	        
			 jQuery.ajax({
				    type: "GET",
				    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=deleteGenericList",
				    data: {"id": id},
				    success: function(messageData) {
				    	closeListForm();
				    	var message = jQuery.parseJSON(messageData);
				    	document.getElementById('MessageOkGLT').innerHTML = message.ok;
				    	document.getElementById('MessageErrorGLT').innerHTML = message.error;			    	
				    	tabsCITLoadGenericLists();
				    },
				    error: function (XMLHttpRequest, textStatus, errorThrown) {
				        alert(dic["NO_DEL_LIST"]);
				    }
			});		 
	    }
}


function submitListElementForm(){
	
	 var id = jQuery('#listElementId').val();
	 var name  = encodeURIComponent(jQuery('#listElementName').val());
	 var value = encodeURIComponent(jQuery('#listElementValue').val());
	 var id_list = jQuery('#listList').val(); 
	 
	 if(id == null){
		 id = 0;
	 }	 
	 if( name == '' || value == '' ) {
		 document.getElementById('MessageErrorGLT').innerHTML = dic["NAME_VALUE_EMPTY"];
		 return;
	 }
	 jQuery.ajax({
		    type: "GET",
		    contentType: "application/json; charset="+CHARSET,
		    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=saveGenericListElement",		   
		    data: {'id': id,'id_list': id_list, 'name': name,'value': value},
		    success: function(data) {
		    	var message = jQuery.parseJSON(data);
		    	document.getElementById('MessageOkGLT').innerHTML = message.ok;
		    	document.getElementById('MessageErrorGLT').innerHTML = message.error;
		    	updateListList(id_list);
		    	if(id == 0){
		    		closeListForm(id_list);
		    	}
		    },
		    error: function (XMLHttpRequest, textStatus, errorThrown) {
		        alert(dic["NO_STATUS"]);		    
		    }
	});
}


function submitListForm(){
	 var id = jQuery('#listId').val();
	 var name = encodeURIComponent(jQuery('#listName').val());
	 if( jQuery('#listName').val().length === 0 ) {
		 document.getElementById('MessageErrorGLT').innerHTML = dic["NAME_EMPTY"];
		 return;
	 }
	 
	 if(id == null){
		 id = 0;
	 }
	 
	 jQuery.ajax({
		    type: "GET",
		    contentType: "application/json; charset="+CHARSET,
		    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=saveGenericList",		   
		    data: {'id': id, 'name': name},
		    success: function(data) {
		    	var message = jQuery.parseJSON(data);
		    	document.getElementById('MessageOkGLT').innerHTML = message.ok;
		    	document.getElementById('MessageErrorGLT').innerHTML = message.error;
		    	tabsCITLoadGenericLists(id);
		    	if(id == 0){
		    		closeListForm();
		    	}
		    },
		    error: function (XMLHttpRequest, textStatus, errorThrown) {
		        alert(dic["NO_STATUS"]);		    
		    }
	});
	
}

function submitVendorForm(){
	
	 var id = jQuery('#vendorId').val(); 
	 var id_category = jQuery('#vendorCategoryId').val();
	 var name = encodeURIComponent(jQuery('#vendorName').val());	 
	 if( jQuery('#vendorName').val().length === 0 ) {
		 document.getElementById('MessageErrorVT').innerHTML = dic["NAME_EMPTY"];
		 return;
	 }
	 
	 if(id == null){
		 id = 0;
	 }
	 jQuery.ajax({
		    type: "GET",
		    contentType: "application/json; charset="+CHARSET,
		    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=saveVendor",		   
		    data: {'id': id, 'id_category': id_category, 'name': name},
		    success: function(jsonVendor) {
		    	var message = jQuery.parseJSON(jsonVendor);
		    	document.getElementById('MessageOkVT').innerHTML = message.ok;
		    	document.getElementById('MessageErrorVT').innerHTML = message.error;
		    	updateVendorList(id_category);
		    	if(id == 0){
		    		closeVendorForm();
		    	}
		    },
		    error: function (XMLHttpRequest, textStatus, errorThrown) {
		        alert(dic["NO_STATUS"]);		    
		    }
	});
}

function submitStateForm(){
	 
	 var id = jQuery('#stateId').val(); 
	 var id_category = jQuery('#stateCategory').val();
	 var name = encodeURIComponent(jQuery('#stateName').val());
	 if( jQuery('#stateName').val().length === 0 ) {
		 document.getElementById('MessageErrorST').innerHTML = dic["NAME_EMPTY"];
		 return;
	 }
	 
	 if(id == null){
		 id = 0;
	 }
	 jQuery.ajax({
		    type: "GET",
		    contentType: "application/json; charset="+CHARSET,
		    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=saveState",		   
		    data: {'id': id, 'id_category': id_category, 'name': name},
		    success: function(jsonCategory) {
		    	var message = jQuery.parseJSON(jsonCategory);
		    	document.getElementById('MessageOkST').innerHTML = message.ok;
		    	document.getElementById('MessageErrorST').innerHTML = message.error;
		    	updateStateTree();
		    	if(id == 0){
		    		closeStateForm();
		    	}
		    },
		    error: function (XMLHttpRequest, textStatus, errorThrown) {
		        alert(dic["NO_STATUS"]);
		    
		    }
	});
}

function deleteState(){
	 
	 var id = jQuery('#stateId').val();
	 if(id == null){
		return;
	 }
	 if (confirm(dic["CONFIRM_ELEM"])) {         
		 jQuery.ajax({
			    type: "GET",
			    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=deleteState",
			    data: {"id": id},
			    success: function(deletedStateMessage) {
			    	closeStateForm();
			    	var message = jQuery.parseJSON(deletedStateMessage);
			    	document.getElementById('MessageOkST').innerHTML = message.ok;
			    	document.getElementById('MessageErrorST').innerHTML = message.error;			    	
			    	updateStateTree();
			    },
			    error: function (XMLHttpRequest, textStatus, errorThrown) {
			        alert(dic["NO_DEL_ELE"]);
			    }
		});
     }
}

function deleteVendor(){
	 
	 var id = jQuery('#vendorId').val();
	 if(id == null){
		return;
	 }
	 if (confirm(dic['CONFIRM_ELEM'])) {
        
		 jQuery.ajax({
			    type: "GET",
			    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=deleteVendor",
			    data: {"id": id},
			    success: function(deletedVendorMessage) {
			    	closeVendorForm();
			    	var message = jQuery.parseJSON(deletedVendorMessage);
			    	document.getElementById('MessageOkVT').innerHTML = message.ok;
			    	document.getElementById('MessageErrorVT').innerHTML = message.error;			    	
			    	updateVendorList(jQuery('#vendorCategoryId').val());
			    },
			    error: function (XMLHttpRequest, textStatus, errorThrown) {
			        alert(dic["NO_DEL_ELE"]);
			    }
		});		 
    }
}

function deleteCategory(){
	 
	 var id = jQuery('#categoryId').val();
	 if(id == null){
		return;
	 }
	 if (confirm(dic['CONFIRM_CHILD'])) {
        
		 jQuery.ajax({
			    type: "GET",
			    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=deleteCategory",
			    data: {"id": id},
			    success: function(deletedCategoryMessage) {			    	
			    	closeCategoryForm();
			    	var message = jQuery.parseJSON(deletedCategoryMessage);
			    	document.getElementById('MessageOkCT').innerHTML = message.ok;
			    	document.getElementById('MessageErrorCT').innerHTML = message.error;			    	
			    	updateCategoryTree(true);
			    	populateSelectCategoryInCategoryTab();
			    },
			    error: function (XMLHttpRequest, textStatus, errorThrown) {
			        alert(dic["NO_DEL_ELE"]);			    
			    }
		});		 
    }
}

function populateRelationList(){
	
	showloadDiv('linkInnerLeft');
	//Ask for the State List
	jQuery.ajax({
		    type: "GET",
		    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=getRelations",
		    data: {},
		    success: function(json) {
		    	var relations = jQuery.parseJSON(json);		    	
		    	jQuery('#relationCIList').html("");
		    	jQuery('#relationUserList').html("");
		    	for (i = 0; i < relations.ci.length; i++) {		    		
		    		jQuery("#relationCIList").append('<li class="list" onclick="return openLinkForm('+relations.ci[i].id+',\''+relations.ci[i].name+'\');">'+relations.ci[i].name+'</li>');
		        }
		    	for (i = 0; i < relations.user.length; i++) {
		    		jQuery("#relationUserList").append('<li class="list" onclick="return openLinkForm('+relations.user[i].id+',\''+relations.user[i].name+'\');">'+relations.user[i].name+'</li>');
		        }
		    	hideloadDiv('linkInnerLeft');		    	
		    },
		    error: function (XMLHttpRequest, textStatus, errorThrown) {
		        alert(dic["NO_ELEM_LIST"]);
		        hideloadDiv('linkInnerLeft');
		    }
		});
}

function switchLinkCIUser(selected){
	
	switch (selected) {
	case '1':
		jQuery('#relationCIList').hide();
    	jQuery('#relationUserList').show();
		break;
	case '2':
		jQuery('#relationCIList').show();
    	jQuery('#relationUserList').hide();
		break;
	}
}

function populateSelectCategoryInStateTab(showLoading){

	if(showLoading == null || showLoading == undefined){
		showLoading = true;
	}
	if(showLoading){
		showloadDiv('stateForm');
	}
	//Remove Current Div
	jQuery('#stateCategory').remove();
	
	//Ask for the State List
	jQuery.ajax({
		    type: "GET",
		    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=getCategoryBranchs",
		    data: {},
		    success: function(jsonCategoryList) {
		    	var categories = jQuery.parseJSON(jsonCategoryList);
		    	jQuery('#stateSelectCategoryContainer').append('<select name="categoryParent" id="stateCategory">');
		    	for (i = 0; i < categories.length; i++) {
		    		jQuery("#stateCategory").append('<option value="'+categories[i].id+'" >'+categories[i].name+'</option>');
		        }
		    	if(showLoading){
		    		hideloadDiv('stateForm');
		    	}
		    },
		    error: function (XMLHttpRequest, textStatus, errorThrown) {
		        alert(dic["NO_STATUS"]);
		        hideloadDiv('stateForm');
		    }
		});
}

function submitCategoryForm(){

	 var id = jQuery('#categoryId').val(); 
	 var id_parent = jQuery('#categoryParentCT').val();
	 var name = encodeURIComponent(jQuery('#categoryName').val());
	 
	 if( jQuery('#categoryName').val().length === 0 ) {
		 document.getElementById('MessageErrorCT').innerHTML = dic["NAME_EMPTY"];
		 return;
	 }
	 
	 var is_branch = '0';
	 var id_template = jQuery('#categoryTemplateCT').val();
	 
	 if(id == null){
		 id = 0;
	 }
	 if(jQuery('#categoryGroup').is(':checked')){
		 is_branch = '1';
	 }
	 
	 jQuery.ajax({
		    type: "GET",
		    contentType: "application/json; charset="+CHARSET,
		    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=saveCategory",		   
		    data: {'id': id, 'id_parent': id_parent, 'name': name,'is_branch': is_branch, 'id_template': id_template},
		    success: function(jsonCategory) {
		    	var message = jQuery.parseJSON(jsonCategory);
		    	if(message.ok != null){
		    		document.getElementById('MessageOkCT').innerHTML = message.ok;
		    	}
		    	if(message.error != null){
		    		document.getElementById('MessageErrorCT').innerHTML = message.error;
		    	}
		    	updateCategoryTree(true);
		    	populateSelectCategoryInCategoryTab();
		    	if(id == 0){
		    		closeCategoryForm();
		    	}
		    },
		    error: function (XMLHttpRequest, textStatus, errorThrown) {
		    	 alert(dic["NO_STATUS"]);
		    }
	});
}

function tabsCITLoadVendors(){
	
	populateSelectCategoryInVendorTab();
	updateVendorListAndSubCategory(1);
	jQuery('#vendorForm').hide();
	document.getElementById('MessageOkVT').innerHTML = '';
	document.getElementById('MessageErrorVT').innerHTML = '';
}

function tabsCITLoadTemplates(id_template){
	
	if(id_template == null || id_template == undefined){
		id_template = 1;
	}	
	updateTemplateList(id_template);
	populateSelectTemplatesInTemplateTab(id_template);
	populateSelectPropertiesGroupInTemplateTab();
	populateSelectListInTemplateTab();
}

function tabsCITLoadCategories(){
		 
	 updateCategoryTree(true);
	 populateSelectCategoryInCategoryTab(false);
	 populateSelectTemplateInCategoryTab(false);
	 jQuery('#categoryForm').hide();
	 document.getElementById('MessageOkCT').innerHTML = '';
	 document.getElementById('MessageErrorCT').innerHTML = '';
	 
}

function tabsCITLoadLinks(){
	populateRelationList();	
}

function tabsCITLoadStates(){
	
	 updateStateTree(true);
	 populateSelectCategoryInStateTab(false);
	 jQuery('#stateForm').hide();
	 document.getElementById('MessageOkST').innerHTML = '';
	 document.getElementById('MessageErrorST').innerHTML = '';
}

function tabsCITLoadGenericLists(id_list){
	
	if(id_list == null || id_list == undefined){
		id_list = 1;
	}	
	updateListList(id_list);
	populateSelectListsInListTab(id_list);
	
}

function updateListList(list_id){
		
	var local_list_id = list_id;
	if(local_list_id == null || local_list_id == 0){
		local_list_id = jQuery('#listList').val();
	}
	
	closeListForm();
	showloadDiv('listInnerLeft');
	//Remove Current Div
	jQuery('#listElements').remove();
	jQuery('#listInnerLeft').append('<ul id="listElements">');
	
	//Ask for the Vendor List
	jQuery.ajax({
		    type: "GET",
		    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=getGenericListElement",
		    data: {'id_list': local_list_id},
		    success: function (data) {
		    	var listelements = jQuery.parseJSON(data);
		    	if(listelements.length !== 0){
			    	for (i = 0; i < listelements.length; i++) {
			    		jQuery('#listElements').append('<li class="list" onclick="return openElementListForm('+listelements[i].id+',\''+listelements[i].name+'\',\''+listelements[i].value+'\');">'+listelements[i].name+'</li>');
			    	}
		    	}else{
		    			jQuery('#listElements').append('<li class="listEmpty">'+dic['NO_ELEM_LIST2']+'</li>');		    		
		    	}
		    	hideloadDiv('listInnerLeft');		    	
		    },
		    error: function (XMLHttpRequest, textStatus, errorThrown) {
		        alert(dic["NO_ELEM_LIST"]);
		        hideloadDiv('listInnerLeft');
		    }
		});
}

//State Tab update functions
function updateVendorList(category_id){
		
	var loccategoryid = category_id;
	if(loccategoryid == null || loccategoryid == 0){
		loccategoryid = jQuery('#vendorCategory').val();
	}
	
	closeVendorForm();
	showloadDiv('vendorInnerLeft');
	//Remove Current Div
	jQuery('#vendorList').remove();
	jQuery('#vendorInnerLeft').append('<ul id="vendorList">');
	
	//Ask for the Vendor List
	jQuery.ajax({
		    type: "GET",
		    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=getVendors",
		    data: {'id_category': loccategoryid},
		    success: function (data) {
		    	var vendors = jQuery.parseJSON(data);
		    	if(vendors.length !== 0){
			    	for (i = 0; i < vendors.length; i++) {
			    		jQuery('#vendorList').append('<li class="vendors" onclick="return openVendorForm('+vendors[i].id+','+vendors[i].id_category+',\''+vendors[i].name+'\');">'+vendors[i].name+'</li>');
			    	}
		    	}else{
		    			jQuery('#vendorList').append('<li class="vendorsEmpty">'+dic['NO_VENDORES_MESS']+'</li>');		    		
		    	}
		    	hideloadDiv('vendorInnerLeft');		    	
		    },
		    error: function (XMLHttpRequest, textStatus, errorThrown) {
		        alert(dic["NO_VENDOR_LIST"]);
		        hideloadDiv('vendorInnerLeft');
		    }
		});
}

function updateVendorListAndSubCategory(category_id){
		
	 updateVendorList(category_id);
	 populateSubCategory('vendorSubCategory',category_id,' updateVendorList(this.options[this.selectedIndex].value)');
}


function updateStateTree(showloaddiv){
	
	if(showloaddiv == null){
		showloaddiv = true;
	}
	if(showloaddiv){
		showloadDiv('stateInnerLeft');
	}
	//Remove Current Div
	jQuery('#stateTree').remove();
	jQuery('#stateInnerLeft').append('<div id="stateTree">');
	
	//Ask for the State List
	jQuery.ajax({
		    type: "GET",
		    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=getStates",
		    success: function (data) {
		    	var states = jQuery.parseJSON(data);
		    	var maxId = 0;
		    	stateTree = new dTree('stateTree', JAVASCRIPT_PATH+'dtree/');
		    	stateTree.add(0,-1,'categories','');
				for (i = 0; i < states.length; i++) {
					if(states[i].branch == 1){
						if(states[i].id > maxId){ maxId = states[i].id;}
						stateTree.add(states[i].id,states[i].id_category,states[i].name,'','','',JAVASCRIPT_PATH+'dtree/img/folder.gif');
					}else{
						stateTree.add(maxId+1,states[i].id_category,states[i].name,'javascript: openStateForm('+states[i].id+','+states[i].id_category+',\''+states[i].name+'\');','','',IMAGE_PATH+'state.gif');
						maxId++;
					}
				}
				document.getElementById('stateTree').innerHTML = stateTree;
				if(showloaddiv){
					hideloadDiv('stateInnerLeft');
				}
		    },
		    error: function (XMLHttpRequest, textStatus, errorThrown) {
		        alert(dic["NO_STATES"]);
		        hideloadDiv('stateInnerLeft');
		    }
		});
}

//Category Tab update functions
function updateCategoryTree(showloaddiv){
	
	if(showloaddiv == null){
		showloaddiv = true;
	}
	if(showloaddiv){
		showloadDiv('categoryInnerLeft');
	}
	//Remove Current Div
	jQuery('#categoryTree').remove();
	jQuery('#categoryInnerLeft').append('<div id="categoryTree">');
	
	//Ask for the State List
	jQuery.ajax({
		    type: "GET",
		    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=getCategories",		    
		    success: function(data) {
		    	var categories = jQuery.parseJSON(data);		    	
		    	categoryTree = new dTree('categoryTree', JAVASCRIPT_PATH+'dtree/');				
		    	categoryTree.add(0,-1,'categories','');		    	
				for (i = 0; i < categories.length; i++) {
					if(categories[i].is_branch == 1){
						categoryTree.add(categories[i].id,categories[i].id_parent,categories[i].name,'javascript: openCategoryForm('+categories[i].id+');','','',JAVASCRIPT_PATH+'dtree/img/folder.gif');
					}else{
						categoryTree.add(categories[i].id,categories[i].id_parent,categories[i].name,'javascript: openCategoryForm('+categories[i].id+');');
					}
				}
				document.getElementById('categoryTree').innerHTML = categoryTree;
				if(showloaddiv){
					hideloadDiv('categoryInnerLeft');
				}	
		    },
		    error: function (XMLHttpRequest, textStatus, errorThrown) {
		        alert(dic["NO_CAT"]);
		        hideloadDiv('categoryInnerLeft');
		    }
		});
}


function populateSelectTemplateInCategoryTab(showLoadDiv){
	
	if(showLoadDiv == null || showLoadDiv == undefined){
		showLoadDiv = true;
	}

	if(showLoadDiv){
		showloadDiv('categoryForm');
	}
	//Remove Current Div
	jQuery('#categoryTemplateCT').remove();
	
	//Ask for the State List
	jQuery.ajax({
		    type: "GET",
		    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=getTemplates",
		    data: {},
		    success: function(data) {
		    	var templates = jQuery.parseJSON(data);
		    	jQuery('#tdCategoryTemplate').append('<select name="categoryTemplate" id="categoryTemplateCT">');
		    	for (i = 0; i < templates.length; i++) {
		    		jQuery("#categoryTemplateCT").append('<option value="'+templates[i].id+'" >'+templates[i].name+'</option>');
		        }
		    	if(showLoadDiv){
		    		hideloadDiv('categoryForm');
		    	}
		    },
		    error: function (XMLHttpRequest, textStatus, errorThrown) {
		        alert(dic["NO_TEMP_LIST"]);
		        hideloadDiv('categoryForm');
		    }
		});
}

function populateSelectListsInListTab(id_list){
	
	if(id_list == null || id_list == undefined){
		id_list=-1;
	}
	
	showloadDiv('listSelectContainer',true);
	//Remove Current Div
	jQuery('#listList').remove();
	
	//Ask for the State List
	jQuery.ajax({
		    type: "GET",
		    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=getGenericList",
		    data: {},
		    success: function(jsonList) {
		    	var lists = jQuery.parseJSON(jsonList);
		    	jQuery('#listSelectContainer').append('<select id="listList" onchange="return updateListList(this.options[this.selectedIndex].value);">');
		    	for (i = 0; i < lists.length; i++) {
		    		if(id_list == lists[i].id ){
		    			jQuery("#listList").append('<option selected="selected" value="'+lists[i].id+'" >'+lists[i].name+'</option>');
		    		}else{
		    			jQuery("#listList").append('<option value="'+lists[i].id+'" >'+lists[i].name+'</option>');
		    		}
		        }
		    	hideloadDiv('listSelectContainer');
		    },
		    error: function (XMLHttpRequest, textStatus, errorThrown) {
		        alert(dic["NO_ELEM_LIST"]);
		        hideloadDiv('listSelectContainer');
		    }
		});
}

function populateSelectCategoryInVendorTab(){
	
	showloadDiv('vendorSelectCategoryContainer',true);
	//Remove Current Div
	jQuery('#vendorCategory').remove();
	
	//Ask for the State List
	jQuery.ajax({
		    type: "GET",
		    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=getCategoryBranchs",
		    data: {},
		    success: function(jsonCategoryList) {
		    	var categories = jQuery.parseJSON(jsonCategoryList);
		    	jQuery('#vendorSelectCategoryContainer').append('<select id="vendorCategory" onchange="return updateVendorListAndSubCategory(this.options[this.selectedIndex].value);">');
		    	for (i = 0; i < categories.length; i++) {
		    		jQuery("#vendorCategory").append('<option value="'+categories[i].id+'" >'+categories[i].name+'</option>');
		        }
		    	hideloadDiv('vendorSelectCategoryContainer');
		    },
		    error: function (XMLHttpRequest, textStatus, errorThrown) {
		        alert(dic["NO_CAT_LIST"]);
		        hideloadDiv('vendorSelectCategoryContainer');
		    }
		});
}



function populateSelectCategoryInCategoryTab(showLoadDiv){

	if(showLoadDiv == null || showLoadDiv == undefined){
		showLoadDiv = true;
	}
	if(showLoadDiv){
		showloadDiv('categoryForm');
	}
	//Remove Current Div
	jQuery('#categoryParentCT').remove();
	
	//Ask for the State List
	jQuery.ajax({
		    type: "GET",
		    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=getCategoryBranchs",
		    data: {},
		    success: function(jsonCategoryList) {
		    	var categories = jQuery.parseJSON(jsonCategoryList);
		    	jQuery('#tdCategoryParent').append('<select name="categoryParent" id="categoryParentCT">');
		    	for (i = 0; i < categories.length; i++) {
		    		jQuery("#categoryParentCT").append('<option value="'+categories[i].id+'" >'+categories[i].name+'</option>');
		        }
		    	if(showLoadDiv){
		    		hideloadDiv('categoryForm');
		    	}
		    },
		    error: function (XMLHttpRequest, textStatus, errorThrown) {
		        alert(dic["NO_CAT_PARENT"]);
		        hideloadDiv('categoryForm');
		    }
		});
}

//Templates
function openTemplateFieldForm(id,id_metatype,id_list,id_properties_group,caption,mandatory,display){
		
	jQuery("#templateForm").hide();
	jQuery("#templateFieldForm").show("fast");	
	if(id==null || id==undefined){
		id=0;
	}
	var template_id = jQuery('#listTemplates').val();
	jQuery("#templateFieldId").attr('value', id);
	jQuery('#templateNameTemplateField').html(jQuery("#listTemplates option[value='"+template_id+"']").text());
	
	
	if(id==0){
		//new
		jQuery("#titleNewTemplateField").show();
	    jQuery("#titleEditTemplateField").hide();	    
	    
	    jQuery("#templateFieldCaption").attr('value', '');	    
   		jQuery("#templateFieldMetaType").val(1);;
		jQuery("#listTemplate").attr('value', '1');
		jQuery("#templateFieldMandatory").attr('checked', false);
		jQuery("#templateFieldDisplay").attr('checked', true);
		jQuery("#propertiesGroupTemplate").val(1);
        jQuery("#templateFieldGroupText").attr('value', '');
		
		
	}else{
		//edit
		jQuery("#titleNewTemplateField").hide();
	    jQuery("#titleEditTemplateField").show();

	    jQuery("#templateFieldCaption").attr('value', caption);	    
   		jQuery("#templateFieldMetaType").val(id_metatype);;
		jQuery("#listTemplate").attr('value', id_list);
		jQuery("#templateFieldMandatory").attr('checked', mandatory);
		jQuery("#templateFieldDisplay").attr('checked', display);
		jQuery("#propertiesGroupTemplate").val(id_properties_group);
        jQuery("#templateFieldGroupText").attr('value', '');       
        jQuery("#templateFieldGroupTextContainer").hide();		
	}
	checkMetaType(id_metatype);
	document.getElementById('MessageOkTT').innerHTML = '';
	document.getElementById('MessageErrorTT').innerHTML = '';
	
}

function openTemplateForm(edit){
	
	jQuery("#templateFieldForm").hide();
	jQuery("#templateForm").show("fast");	 
	if(edit == null || edit == 0){
		 //New			 
		jQuery('#templateName').attr('value', '');
	    jQuery('#templateId').attr('value', '0');
	    jQuery("#titleEditTemplate").hide();
	    jQuery("#titleNewTemplate").show();
	    jQuery("#deleteTemplateButton").hide();
//	    jQuery('#templateExtendDefaultTR').show();
		 
	}else{
		 //Edit
		var id = jQuery('#listTemplates').val();
			
		jQuery("#titleNewTemplate").hide();
	    jQuery("#titleEditTemplate").show();
		jQuery('#templateName').attr('value',jQuery("#listTemplates option:selected").text());
	    jQuery('#templateId').attr('value', id);
	    if(id != 1){
	    	
//	    	showloadDiv('templateForm');
//		    jQuery.ajax({
//			    type: "GET",
//			    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=getTemplate",
//			    data: {'id': id },
//			    success: function(dataResult) {
//			    	var templateHash = jQuery.parseJSON(dataResult);
//			    	if(templateHash.hasDefaultFields == 1){
//			    		jQuery('#templateExtendDefault').attr('checked', true);
//			    	}else{
//			    		jQuery('#templateExtendDefault').attr('checked', false);
//			    	}
//			 		hideloadDiv('templateForm');
//			    },
//			    error: function (XMLHttpRequest, textStatus, errorThrown) {
//			        alert(dic["NO_TEMP_DATA"]);
//			        hideloadDiv('templateForm');
//			    }
//			});
		    jQuery("#deleteTemplateButton").show();
//		    jQuery('#templateExtendDefaultTR').show();
		    
	    }else{
	    	//Default can't not be deleted 
//	    	jQuery('#templateExtendDefaultTR').hide();
	    	jQuery("#deleteTemplateButton").hide();
	    	
	    }
	}
	document.getElementById('MessageOkTT').innerHTML = '';
	document.getElementById('MessageErrorTT').innerHTML = '';
}

function populateSelectListInTemplateTab(){
		
	//showloadDiv('listTemplateContainer',true);
	//Remove Current Div
	jQuery('#listTemplate').remove();
	jQuery('#listTemplateContainer').append('<select id="listTemplate">');
	
	//Ask for the Vendor List
	jQuery.ajax({
		    type: "GET",
		    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=getGenericList",
		    data: {},
		    success: function (data) {
		    	var lists = jQuery.parseJSON(data);		    	
			    for (i = 0; i < lists.length; i++) {
			    		jQuery('#listTemplate').append('<option value="'+lists[i].id+'" >'+lists[i].name+'</option>');
			    }		    	
		    	//hideloadDiv('listTemplateContainer');		    	
		    },
		    error: function (XMLHttpRequest, textStatus, errorThrown) {
		        alert(dic["NO_LIST"]);
		       // hideloadDiv('listTemplateContainer');
		    }
		});
}

function populateSelectPropertiesGroupInTemplateTab(id_property){
	
	if(id_property == null || id_property == undefined){
		id_property=-1;
	}
	jQuery('#propertiesGroupTemplate').remove();
	jQuery('#propertiesGroupTemplateContainer').append('<select id="propertiesGroupTemplate"  onchange="return checkPropertyGroupSelect(this.options[this.selectedIndex].value);">');
	jQuery.ajax({
	    type: "GET",
	    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=getPropertiesGroup",
	    data: {},
	    success: function(data) {
	    	var propGroup = jQuery.parseJSON(data);	    	
	    	for (i = 0; i < propGroup.length; i++) {	    		
	    			jQuery("#propertiesGroupTemplate").append('<option value="'+propGroup[i].id+'" >'+propGroup[i].name+'</option>');
	        }
	    	jQuery("#propertiesGroupTemplate").append('<option value="0" >--'+dic["OTHER"]+'--</option>');
	    	if(id_property != -1){
	    		jQuery('#propertiesGroupTemplate').val(id_property);
	    	}
	    },
	    error: function (XMLHttpRequest, textStatus, errorThrown) {
	        alert(dic["NO_PROPG"]);
	    }
	});
}

function  checkMetaType(id){	
	if(id==LISTA_ID){
		jQuery("#templateFieldListContainer").show();
	}else{
		jQuery("#templateFieldListContainer").hide();
	}
}

function checkPropertyGroupSelect(id){
	if(id==0){
		jQuery("#templateFieldGroupTextContainer").show();
	}else{
		jQuery("#templateFieldGroupTextContainer").hide();	    
	}
}

function populateSelectTemplatesInTemplateTab(id_template){
	
	if(id_template == null || id_template == undefined){
		id_template=-1;
	}
	
	showloadDiv('templateSelectContainer',true);
	//Remove Current Select
	jQuery('#listTemplates').remove();
	jQuery('#templateSelectContainer').append('<select id="listTemplates"  onchange="return updateTemplateList(this.options[this.selectedIndex].value);">');
	
	//Ask for the Template List
	jQuery.ajax({
	    type: "GET",
	    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=getTemplates",
	    data: {},
	    success: function(data) {
	    	var templates = jQuery.parseJSON(data);	    	
	    	for (i = 0; i < templates.length; i++) {	    		
	    			jQuery("#listTemplates").append('<option value="'+templates[i].id+'" >'+templates[i].name+'</option>');
	        }
	    	jQuery('#listTemplates').val(id_template);	    
	    	hideloadDiv('templateSelectContainer');
	    
	    	
	    },
	    error: function (XMLHttpRequest, textStatus, errorThrown) {
	        alert(dic["NO_TEMP_LIST"]);
	        hideloadDiv('templateSelectContainer');
	    }
	});
}

function submitTemplateFieldForm(){
	
	var id = jQuery('#templateFieldId').val();
	var caption   = encodeURIComponent(jQuery('#templateFieldCaption').val());
	var propGroup = encodeURIComponent(jQuery('#templateFieldGroupText').val());
		
	//Check caption not to be empty
	if( caption.length === 0 ) {
		 document.getElementById('MessageErrorTT').innerHTML = dic["CAPTION_EMPTY"];
		 return;
	}
	//Check properties group name and properties slect not to be empty and zero
	if(jQuery('#propertiesGroupTemplate').val()===0 && propGroup.length === 0 ) {
		 document.getElementById('MessageErrorTT').innerHTML = dic["PROP_EMPTY"];
		 return;
	}
	
	if(id == null || id==undefined){
		 id = 0;
	}
	 
	 jQuery.ajax({
		    type: "GET",
		    contentType: "application/json; charset="+CHARSET,
		    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=saveTemplateField",		   
		    data: { 'id': id, 
				 	'caption' : caption,
					'propertiesGroupName' : propGroup,
					'id_metatype'   	  : jQuery('#templateFieldMetaType').val(),
					'id_list'   		  : jQuery('#listTemplate').val(),
					'mandatory'   		  : jQuery('#templateFieldMandatory').is(':checked'),
					'display'   		  : jQuery('#templateFieldDisplay').is(':checked'),
					'idPropertiesGroup'   : jQuery('#propertiesGroupTemplate').val(),
					'id_template'   	  : jQuery('#listTemplates').val(),
				  },
		    success: function(data) {
		    	var message = jQuery.parseJSON(data);
		    	document.getElementById('MessageOkTT').innerHTML = message.ok;
		    	document.getElementById('MessageErrorTT').innerHTML = message.error;    
		    	updateTemplateList();
		    	populateSelectPropertiesGroupInTemplateTab();
		    },
		    error: function (XMLHttpRequest, textStatus, errorThrown) {
		        alert(dic["NO_STATUS"]);		    
		    }
	});
	
	
}

function submitTemplateForm(){
	
	 var id = jQuery('#templateId').val();
	 var name = encodeURIComponent(jQuery('#templateName').val());
	 if( jQuery('#templateName').val().length === 0 ) {
		 document.getElementById('MessageErrorTT').innerHTML = dic["NAME_EMPTY"];
		 return;
	 }	 
	 if(id == null || id==undefined){
		 id = 0;
	 }
	 
	 jQuery.ajax({
		    type: "GET",
		    contentType: "application/json; charset="+CHARSET,
		    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=saveTemplate",		   
		    data: {'id': id, 'name': name},
		    success: function(data) {
		    	var message = jQuery.parseJSON(data);
		    	document.getElementById('MessageOkTT').innerHTML = message.ok;
		    	document.getElementById('MessageErrorTT').innerHTML = message.error;    
		    	tabsCITLoadTemplates();
		    	if( id == 0 ){
		    		closeTemplateForm();
		    	}
		    	
		    },
		    error: function (XMLHttpRequest, textStatus, errorThrown) {
		        alert(dic["NO_STATUS"]);		    
		    }
	});
}

function updateTemplateList(template_id){
	
	var local_template_id = template_id;
	if(local_template_id == null || local_template_id == 0){
		local_template_id = jQuery('#listTemplates').val();
	}	
	closeTemplateForm();
	showloadDiv('templateInnerLeft');
	//Remove Current TableBody for custom fields
	jQuery('#templateFieldsBody').remove();
	jQuery('#templateFields').append('<tbody id="templateFieldsBody"></tbody>');
	
	//Ask for Template Fields
	jQuery.ajax({
		    type: "GET",
		    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=getTemplateFields",
		    data: {'id_template': local_template_id},
		    success: function (data) {
		    	var listelements = jQuery.parseJSON(data);
		    	var mandatoryCheckInputHTML = '';
		    	var displayCheckInputHTML = '';
		    	if(listelements.length !== 0){
			    	for (i = 0; i < listelements.length; i++) {
			    		if(listelements[i].mandatory=='1'){
			    			mandatoryCheckInputHTML = 'checked="checked"';
			    		}else{mandatoryCheckInputHTML = '';}
			    		
			    		if(listelements[i].display=='1'){
			    			displayCheckInputHTML = 'checked="checked"';
			    		}else{displayCheckInputHTML = '';}
			    		
			    		jQuery('#templateFieldsBody').append('<tr><td class="percent10" ><input name="tempField" value="'+listelements[i].id+'" type="checkbox"/></td><td class="percent40"><a href="javascript: openTemplateFieldForm('+
			    				listelements[i].id+
			    				','+listelements[i].id_metatype+ 
			    				','+listelements[i].id_list+ 
			    				','+listelements[i].id_properties_group+ 
			    				',\''+listelements[i].caption+'\''+ 
			    				','+listelements[i].mandatory+ 
			    				','+listelements[i].display+
			    				');">'+listelements[i].caption+'</a></td>'+
			    				'<td class="percent30">'+jQuery("#templateFieldMetaType option[value='"+listelements[i].id_metatype+"']").text()+'</td>'+
			    				'<td class="percent10"><input disabled="disabled" type="checkbox" '+mandatoryCheckInputHTML+'/></td>'+
			    				'<td class="percent10"><input disabled="disabled" type="checkbox" '+displayCheckInputHTML+'/></td></tr>');
			    	}
		    	}
		    	hideloadDiv('templateInnerLeft');		    	
		    },
		    error: function (XMLHttpRequest, textStatus, errorThrown) {
		        alert(dic["NO_ELEM_LIST"]);
		        hideloadDiv('templateInnerLeft');
		    }
		});
}

function deleteTemplate(){
	 var id = jQuery('#templateId').val();
	 if(id == null){
			return;
	 }
	 if (confirm(dic['CONFIRM_CHILD'])) {

			 jQuery.ajax({
				    type: "GET",
				    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=deleteTemplate",
				    data: {"id": id},
				    success: function(messageData) {
				    	tabsCITLoadTemplates();
				    	var message = jQuery.parseJSON(messageData);
				    	document.getElementById('MessageOkTT').innerHTML = message.ok;
				    	document.getElementById('MessageErrorTT').innerHTML = message.error;				    	
				    },
				    error: function (XMLHttpRequest, textStatus, errorThrown) {
				        alert(dic["NO_DEL_TEMP"]);
				    }
			});
	    }
}

function deleteFieldTemplateElement(){
	 var id = jQuery('#templateFieldId').val();
	 if(id == null){
			return;
	 }
	 if (confirm(dic['CONFIRM_ELEM'])) {

			 jQuery.ajax({
				    type: "GET",
				    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=deleteTemplateField",
				    data: {"id": id},
				    success: function(messageData) {
				    	updateTemplateList();
				    	var message = jQuery.parseJSON(messageData);
				    	document.getElementById('MessageOkTT').innerHTML = message.ok;
				    	document.getElementById('MessageErrorTT').innerHTML = message.error;
				    	
				    },
				    error: function (XMLHttpRequest, textStatus, errorThrown) {
				        alert(dic["NO_DEL_ELE"]);
				    }
			});
	    }
}
//Delete Selectd properties

function deleteSelectedTFields(){
	var arrayOfFields = new Array();
	jQuery("input:checkbox[name=tempField]:checked").each(function()
		{
			arrayOfFields.push(jQuery(this).val());
		});
	 if (confirm(dic['CONFIRM_SEL_ELEM'])) {
			
		 jQuery.ajax({
			    type: "GET",
			    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=deleteSelectedTemplateFields",
			    data: {'fieldArray':   JSON.stringify(arrayOfFields) },// arrayOfFields			    
			    success: function(messageData) {
			    	updateTemplateList();
			    	var message = jQuery.parseJSON(messageData);
			    	document.getElementById('MessageOkTT').innerHTML = message.ok;
			    	document.getElementById('MessageErrorTT').innerHTML = message.error;
			    	
			    },
			    error: function (XMLHttpRequest, textStatus, errorThrown) {
			        alert(dic["NO_DEL_ELE"]);
			    }
		});
    }
}


