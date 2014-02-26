// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function() {
  $('p.instructions').jTruncate(); 
  // check for user
  var username = null;
  $.each($('.check'), function(id, obj) {
    $(obj).bind('blur', function(e) {
      var value = $(obj).val();
      if (value != username) {
        username = value;
        
        if (username != ''){
          $.post('/users/check', { username: username } );
        }
      }
    });
  });

  // disable by default TODO these should probably be in HTML not JS
  $('#change-card .new input').attr('disabled', 'disabled');
  $('#change-card .new option').attr('disabled', 'disabled');

  // change card
  $("#default-card a[href='change-card']").click(function(event){
    $('#default-card').hide();
    $('#change-card').fadeIn();
    $('#change-card input').removeAttr('disabled');
    event.preventDefault();
    event.stopPropagation();
  });

  // add new card
  $('#change-card input[type=radio]').click(function(event){
    if ($(this).val() == 'new') {
      $('#change-card .new input').removeAttr('disabled');
      $('#change-card .new option').removeAttr('disabled');
      $('#change-card .new').show();
    } else {
      $('#change-card .new').hide();
    }
  });

  var orderTip = $('#order_tip');
  var confirmationTip = $('#confirmation_tip');
  var tipAmount = $('span.tip_amount');
  var deliveryFeeData = $('td#delivery_fee');

  // copy default on load
  confirmationTip.prop('value', orderTip.prop('value'));

  // confirmation -> order tip
  confirmationTip.live('keyup', function(event){
    var value = $(this).prop('value');
    orderTip.prop('value', value);

    var subtotal = parseInt($('td#subtotal').text().replace(/\D/g,''));
    var tax = parseInt($('td#tax').text().replace(/\D/g,''));
    var deliveryFee = parseInt(deliveryFeeData.text().replace(/\D/g,''));
    if (isNaN(deliveryFee)) {
      deliveryFee = 0;
    }
    var tip = null;
    var tipPercentage = parseInt(confirmationTip.prop('value'));
    if (isNaN(tipPercentage)) {
      tipPercentage = 0;
      tip = 0;
    } else {
      tip = Math.round(subtotal * (tipPercentage / 100.0));
    }
    tipAmount.html(numberToCurrency(tip / 100.0));

    var total = subtotal + tax + deliveryFee + tip;
    $('.total_amount').html(numberToCurrency(total / 100.0));
  });

  // Format a floating point or integer to a currency string
  //
  function numberToCurrency(number) {
    var number = '' + number;

    if (number.indexOf('.') > -1) {
      var split = number.split('.');

      for(i = split[1].length; i < 2; i++) {
        number = number + '0';
      }
    } else {
      number = number + '.00';
    }

    return '$' + number;
  }

});
