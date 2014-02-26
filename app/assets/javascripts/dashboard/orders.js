// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function() {

  function confirmOrderChange(event) {
    var goOn = confirm("You are about to change the status of this order. Are you " + 
        "sure you want to make this change?");
    if (goOn == false) {
      event.preventDefault();
      event.stopPropagation();
    }
    return goOn;
  }

  // submit deliverer on select - status
  $('form.deliverer select').live('change', function(){
    if (confirmOrderChange(event)) {
      $(this).closest('form').submit();
    } else {
      $(this).closest('form').each(function(){
        this.reset();
      });
    }
  });

  // AJAX in order status and actions
  if ($('#order_status_actions').length > 0) {
    $.get(window.location.pathname + '/status');
  }
});
