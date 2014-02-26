// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require fancybox
//= require jquery.remotipart
//= require constants
//= require wizard
//= require validate
//= require jquery.maskedinput-1.0
//= require_tree .


// Application
$(document).ready(function(){

  jQuery.ajaxSetup({ beforeSend: function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")} });

  // Prevent multiple submissions on links/buttons with class="single-clk"
  $('.single-clk').live('click', function(event) {
    $el = $(this);
    message = $el.data('load-msg');
    if (message == undefined) message = 'Sending...'
    $el.fadeOut(200, function(){
      $el.before($('<span/>', {
        class: "loading",
        text: message}).fadeIn(600))
    });
    $el.click(function() {
      $(this).attr('disabled', 'disabled');
    });
  });

});
