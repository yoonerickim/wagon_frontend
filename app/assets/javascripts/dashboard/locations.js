// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function() {

  // confirm enter LLD mode
  $('a.enter-live-location').click(function(event) {
    var goOn = confirm("Note: this will log you out. For security, your staff will not be able to access your personal Hit The Spot details.");
    if (goOn == false) {
      event.preventDefault();
    }
  });

  // Attach a confirm to each action.
  //$('.order_actions a, .payment_actions a').live('click',function(event) {
  //  confirmOrderChange(event);
  //});


  $('a#edit_bank').fancybox({
    type: 'ajax',
    hideOnOverlayClick: false
  });
});
