/*!
 * Copyright 2010-2011, Juan Manuel Rodriguez
 * licensed under AGPL Version 2.
 * http://www.omilenitsolutions.com/
 * Date: 04-Ene-2010 
 */

function initialiceOCSIPage(){
	
	jQuery("#tabsocsi").tabs();
	 
	switch(step){
	 
	 	case '0': jQuery("#tabsocsi").tabs("remove" , 0 );
	 			jQuery("#tabsocsi").tabs("remove" , 1 );
	 			break;
	 	case '1':
	 	case '2': jQuery("#tabsocsi").tabs("remove" , 0 );
		  		  jQuery("#tabsocsi").tabs("remove" , 0 );
		  		  prepareProgressScreen(step);
	 		    break;
//	 	case 3: break;
	 	case '4': window.setInterval(checkStatus, 5000);
	 	        break;
		}
	
	 if(!enabled){
			jQuery('#ocsiTable').hide();
			jQuery('#osciButtonContainer').hide();
		
	 }else{
			jQuery('#ocsiwsenabled').attr('checked', true); 
	 }
	
}

function prepareProgressScreen(step){
	
	if(step == 1){
		return;
	}
	jQuery('#ocsiCategoryForm').hide();
	showloadDiv('ocsiMessageCreateTemplatesLoading',true);	
	document.getElementById('ocsiMessageCreateTemplates').innerHTML = dic["CNT"]+'...';
	
	//Call Creation of New Templates
	jQuery.ajax({
	    type: "GET",
	    url: "index.pl?Action=AgentInkaConfigurationItems&ajax=1&method=createOCSITemplates",
	    data: {},
	    success: function(messageData) {
	    	var message = jQuery.parseJSON(messageData);
	    	document.getElementById('ocsiMessageCreateTemplates').innerHTML = message.ok;
	    	document.getElementById('ocsiCAMessError').innerHTML = message.error;
	    	hideloadDiv('ocsiMessageCreateTemplatesLoading');
	    },
	    error: function (XMLHttpRequest, textStatus, errorThrown) {
	    	document.getElementById('ocsiCAMessError').innerHTML = dic["UNKNOWN_ERROR"];
	    	hideloadDiv('ocsiMessageCreateTemplatesLoading');
	    }
	});
}

function toggleCategorySelect(id){

	 if(jQuery('#ocsicc_'+id).is(':checked')){
		jQuery('#select_ocsicc_'+id).attr('disabled', '');
	}else{
		jQuery('#select_ocsicc_'+id).attr('disabled', 'disabled');
	}
}

function enabledDisabledOCSI(){
	
	var enabledCheck = jQuery('#ocsiwsenabled').is(':checked');
	if(enabledCheck){
		jQuery('#ocsiTable').show("fast");
		jQuery('#osciButtonContainer').show();
	}else{
		jQuery('#ocsiTable').hide("fast");
		if(!enabled){
			jQuery('#osciButtonContainer').hide();
		}
	}
}

function submitOCSIWBForm(){

	var mapOfElementsToValidate ={
			rules: {
				ocsiwsurl:"required",
			},
			messages: {
				ocsiwsurl:dic["FIELD_REQ"],
			}
	};
	return inkaValidateForm(mapOfElementsToValidate);
}

function testConnection(){
	
	var URL 	 = encodeURIComponent(jQuery('#ocsiwsurl').val());
	var user 	 = encodeURIComponent(jQuery('#ocsiwsuser').val());
	var password = encodeURIComponent(jQuery('#ocsiwspassword').val());
	var protocol = jQuery('#ocsiwsprotocol').val();
	var path 	 = jQuery('#ocsiwspath').val();
	
	showloadDiv('osciButtonContainer',true);
	document.getElementById('ocsiCAMessOk').innerHTML = '';
	document.getElementById('ocsiCAMessError').innerHTML = '';
	jQuery.ajax({
	    type: "GET",
	    url: "index.pl?Action=AgentInkaConfigurationItems&ajax=1&method=testOCSIWebServiceConnection",
	    data: {'URL': URL, 'user': user,'password':password,'protocol':protocol,'path':path},
	    success: function(messageData) {
	    	var message = jQuery.parseJSON(messageData);
	    	document.getElementById('ocsiCAMessOk').innerHTML = message.ok;
	    	document.getElementById('ocsiCAMessError').innerHTML = message.error;
	    	hideloadDiv('osciButtonContainer');
	    },
	    error: function (XMLHttpRequest, textStatus, errorThrown) {
	    	document.getElementById('ocsiCAMessError').innerHTML = dic["UNKNOWN_ERROR"];
	    	hideloadDiv('osciButtonContainer');
	    }
	});
}

/*
 * This function will check every ten seconds the state of the creation of the new categories,
 * the data migration and the new templates
 * */
function checkStatus() { 
	

	jQuery.ajax({
	    type: "GET",
	    url: "index.pl?Action=AgentInkaConfigurationItems&ajax=1&method=getProgressStatusCode",
	    data: {},
	    success: function(id) {
	    	var id = jQuery.parseJSON(id);
	    	alert(id);
	    	
	    },
	    error: function (XMLHttpRequest, textStatus, errorThrown) {
	    	document.getElementById('ocsiCAMessError').innerHTML = dic["UNKNOWN_ERROR"];
	    	
	    }
	});
	

}