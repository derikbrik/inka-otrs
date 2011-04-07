/*!
 * Copyright 2010-2011, Juan Manuel Rodriguez
 * licensed under AGPL Version 2.
 * http://www.omilenitsolutions.com/
 * Date: 3-dic-2010
 */

var REGEX_01 = /^[^']+$/;
var REGEX_02 = /^[0-9\.,-]+$/;
var REGEX_03 = /^[0-9-]+$/; 

function validateinputtext(event, objInput){
			
		switch (event.keyCode) {
			case 8:
			case 9:
			case 37:
			case 39:
				return true;
				break;
		}
		var strText = objInput.value;
		var keyCode = String.fromCharCode(event.keyCode||event.charCode);
		return REGEX_01.test(keyCode);
}

function validateFloatInput(event, objInput){
	
	switch (event.keyCode) {
		case 8:
		case 9:
		case 37:
		case 39:
			return true;
			break;
	}
	var strText = objInput.value;
	var keyCode = String.fromCharCode(event.keyCode||event.charCode);
	return REGEX_02.test(keyCode);
}

function validateIntegerInput(event, objInput){

	if(event.keyCode == 8){
		return true;
	}
	var strText = objInput.value;
	var keyCode = String.fromCharCode(event.keyCode||event.charCode);
	return REGEX_03.test(keyCode);
}

//Load Divs Functions
function showloadDiv(divId,small){
	
	var offset = jQuery("#"+divId).offset();
	jQuery("#"+divId).hide();
	var load=document.getElementById('loaddiv');
	if(load == undefined){
		load = document.createElement("div");		
		load.id='loaddiv';
		document.getElementsByTagName("body")[0].appendChild(load);
	}
	load.style.top = offset.top + "px";
	load.style.left = offset.left + "px";
	
	load.style.display = 'block';
	if(small == null || small == undefined){		
		load.setAttribute("class", "loading");
	}else{
		load.setAttribute("class", "loadingSmall");		
	}
}

function hideloadDiv(divId){
	jQuery("#loaddiv").hide();
	jQuery("#"+divId).show();
}

//Asume the containerId is the Id+'Container'
function populateSubCategory(selectId,category_id,onchange,currentSubCategoryId){
	
	showloadDiv(selectId+'Container',true);
	//Remove Current Div
	jQuery('#'+selectId).remove();
	
	//Ask for the State List
	jQuery.ajax({
		    type: "GET",
		    url: "index.pl?Action=AdminInkaConfigurationItemsTemplates&ajax=1&method=getCategoryLeaf",
		    data: {'id':category_id},
		    success: function(jsonCategoryList) {
		    	var categories = jQuery.parseJSON(jsonCategoryList);
		    	jQuery('#'+selectId+'Container').append('<select id="'+selectId+'" name="id_category" onchange="return '+onchange+';">');
		    	jQuery("#"+selectId).append('<option value="0" >--'+dic['NONE']+'--</option>');
		    	for (i = 0; i < categories.length; i++) {
		    		jQuery("#"+selectId).append('<option value="'+categories[i].id+'" >'+categories[i].name+'</option>');
		        }
		    	if(currentSubCategoryId!=null && currentSubCategoryId!=undefined){
		    		jQuery("#"+selectId).val(currentSubCategoryId);
		    		jQuery("#"+selectId).attr('disabled', 'disabled');
		    	}
		    	hideloadDiv(selectId+'Container');
		    },
		    error: function (XMLHttpRequest, textStatus, errorThrown) {
		        alert(dic["NO_CAT_SUBLIST"]);
		        hideloadDiv(selectId+'Container');
		    }
		});
}

//Generic function for validate Forms
//params has the following form:
// {rules: { idInput01:"required", id02:"required"},messages: {idInput01:"This field is requiered",id02:"This field is requiered"}}
function inkaValidateForm(params){
	
	var messages = params.messages;
	var rules = params.rules;
	var returnFlag = true;
	var valueAux = 0;
	var defaultMessage = dic["FIELD_REQ"];
	var classForInput = '';
	var error = false;
	var flagUseDefault = false;
	var errorMessage = '';
		
	if(messages == null || messages == undefined || messages.length === 0 ){
		flagUseDefault = true;	
	}
	
	
	jQuery.each(rules, function(key, value) {
		 valueAux = jQuery('#'+key).val();
		 error = false;
		 if(jQuery('#'+key).is("select")){
				 if( valueAux == null || valueAux == undefined || valueAux=='0' || valueAux === 0 ){					  	
					  	classForInput = 'Error';
						error = true;					  	
				}
		 }else{
			 if(jQuery('#'+key).attr('type')=='checkbox'){
				 if(!jQuery('#'+key).is(':checked')){
					 classForInput = 'inputError';
					 error = true;
				 }
			 }else{
				 if( valueAux == null || valueAux == undefined || valueAux.length === 0 ){
					 classForInput = 'inputError';
					 error = true;
				 }
			 }
		 }
		 //****//
		 if(error){
			  	jQuery('label[for='+key+']').addClass('labelError');
			  	jQuery('#'+key).addClass(classForInput);
			  	returnFlag = false;
			  	if(flagUseDefault || messages[key] == undefined ||  messages[key] == ''){
			  		errorMessage = defaultMessage;
			  	}else{
			  		errorMessage = messages[key];
			  	}
			  	
				if(document.getElementById(key+'Message') == null || document.getElementById(key+'Message') == undefined){
					jQuery('#'+key).parent().append('<div class="labelErrorMessage" id="'+key+'Message" >'+errorMessage+'</div>');	
				}else{
					jQuery('#'+key+'Message').html(errorMessage);
				}
			  	
		 }else{
			 jQuery('label[for='+key+']').removeClass('labelError');
			 jQuery('#'+key).removeClass('Error');
			 jQuery('#'+key).removeClass('inputError');
	 		 if(document.getElementById(key+'Message') != null && document.getElementById(key+'Message') != undefined){
	 			jQuery('#'+key+'Message').html('');	
			 }
		 }
	});
	return returnFlag;
}