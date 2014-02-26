// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready(function() {

  //set pos make/model
  $('select.pos-make').html("");
  $('select.pos-make').append(new Option("---select make---", "", false, false)); 
  $('select.pos-make').append(new Option("Dinerware", "Dinerware", false, false)); 
  $('select.pos-make').append(new Option("MICROS", "MICROS", false, false)); 
  $('select.pos-make').append(new Option("POSitouch", "POSitouch", false, false)); 
  $('select.pos-model').html("");

  $('select.pos-make').change(function(){

    if ($('select.pos-make').val() == 'Dinerware'){
      $('select.pos-model').find('option').remove();
      $('select.pos-model').append(new Option("---select model #---", "", false, false));
      $('select.pos-model').append(new Option("3.0.0.4591", "3.0.0.4591", false, false));	
      $('select.pos-model').append(new Option("3.0.0.4646", "3.0.0.4646", false, false));	
      $('select.pos-model').append(new Option("3.0.1.4668", "3.0.1.4668", false, false));	
      $('select.pos-model').append(new Option("3.0.2.4678", "3.0.2.4678", false, false));	
      $('select.pos-model').append(new Option("3.0.2.4702", "3.0.2.4702", false, false));	
      $('select.pos-model').append(new Option("3.0.2.4713", "3.0.2.4713", false, false));	
      $('select.pos-model').append(new Option("3.0.3.4720", "3.0.3.4720", false, false));	
      $('select.pos-model').append(new Option("3.0.4.4749", "3.0.4.4749", false, false));	
      $('select.pos-model').append(new Option("3.1.0.4900", "3.1.0.4900", false, false));	
      $('select.pos-model').append(new Option("3.1.1.4941", "3.1.1.4941", false, false));	
      $('select.pos-model').append(new Option("3.1.3.4972", "3.1.3.4972", false, false));	
      $('select.pos-model').append(new Option("3.1.5.5010", "3.1.5.5010", false, false));	
      $('select.pos-model').append(new Option("3.2.1.5284", "3.2.1.5284", false, false));	
      $('select.pos-model').append(new Option("3.2.2.5351", "3.2.2.5351", false, false));	
      $('select.pos-model').append(new Option("3.2.3.5400", "3.2.3.5400", false, false));	
      $('select.pos-model').append(new Option("3.2.4.5467", "3.2.4.5467", false, false));	
    }

    if ($('select.pos-make').val() == 'MICROS'){
      $('select.pos-model').find('option').remove();
      $('select.pos-model').append(new Option("---select model #---", "", false, false));		
      $('select.pos-model').append(new Option("3700 Platform w/ MICROS Transaction Services License", "3700", false, false));	
    }

    if ($('select.pos-make').val() == 'POSitouch'){
      $('select.pos-model').find('option').remove();
      $('select.pos-model').append(new Option("all models are supported", "all", false, false));
    }

    if ($('select.pos-make').val() == ''){
      $('select.pos-model').find('option').remove();
    }	

  });

  // order types
  var show_hours = true;
  check_operational_hours();
  check_delivery();
  check_matching_hours();
  $('input.delivery-orders').click(function() {
    check_delivery();
    check_matching_hours();
  });
  $('input.onsite-orders').click(function() {
    check_operational_hours();
    check_matching_hours();
  });
  $('input.match-hours').click(function() {
    check_matching_hours();
  });

  function check_operational_hours() {
    if($('input.onsite-orders.take-out.yes').prop("checked") || 
        $('input.onsite-orders.dine-in.yes').prop("checked")) {
      $('.operational-hours-builder').show();
      //$('input.match-hours.yes').prop("checked",true); // Bad
      show_hours = true; 
    } else {
      $('.operational-hours-builder').hide();
      //$('input.match-hours.no').prop("checked",true); // Bad
      show_hours = false;
    }
  };

  function check_delivery() {
    if($('input.delivery-orders.address-delivery.yes').prop("checked") || 
        $('input.delivery-orders.spot-delivery.yes').prop("checked")) {
      $('.delivery-hours-builder').show();
      $('#yes_delivery').show(); // step_three
      $('#no_delivery').hide(); // step_three
    } else {
      $('.delivery-hours-builder').hide();
      $('#no_delivery').show(); // step_three
      $('#yes_delivery').hide(); // step_three    
    }
  };

  function check_matching_hours() {
    if($('input.match-hours.yes').prop("checked") && show_hours) {
      $('table.delivery-hours').hide();
    } else {
      $('table.delivery-hours').show();
    }
  };
  // end hours
  
  // pos integration
  set_and_check_integration();
  $('input[type=radio].integration').click(function() {
    set_and_check_integration();
  });
  
  function set_and_check_integration() {
    if($('input.integration.yes').prop("checked")) {
      $('div.standard-integration').hide();
      $('div.pos-integration').show();
    } else {
      $('div.pos-integration').hide();
      $('div.standard-integration').show();
    }
  };
  // end pos integration

  // menu type
  set_and_check_menu_type();
  $('input[type=radio].location_menu_type').click(function() {
    set_and_check_menu_type();
  });

  function set_and_check_menu_type() {
    if($('input.location_menu_type.doc').prop("checked")) {
      $('div.web-url').hide();
      $('div.upload-doc').show();
      $('div.openmenu-url').hide();
      $('div.hours-builder').show();
    }
    if($('input.location_menu_type.web').prop("checked")) {
      $('div.web-url').show();
      $('div.upload-doc').hide();
      $('div.openmenu-url').hide();
      $('div.hours-builder').show();
    }
    if($('input.location_menu_type.openmenu').prop("checked")) {
      $('div.web-url').hide();
      $('div.upload-doc').hide();
      $('div.openmenu-url').show();
      $('div.hours-builder').hide();
    };
  };
  // end menu type

  // registration form wizard
  $("#ContactWizard").formWizard();
  // registration form number masking
  $(".location_phone").mask("(999) 999-9999");
  $(".location_address_state").mask("aa");
  $(".location_address_zip").mask("99999");
  $(".user_contact_phone").mask("(999) 999-9999");

  // add * to required field labels - not working TODO
  $(".required").append("&nbsp;<strong>*</strong>&nbsp;");

  $('#show_all_tags').click(function() {
    $(".extra-tags").slideToggle();
    return false;
  });

});
