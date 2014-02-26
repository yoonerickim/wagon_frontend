// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
//
//
$(document).ready(function(){

  function loadFancybox() {
    $('a.menu_edit').fancybox({
	  height: 500,
	  width: 650,
	  autoDimensions: false,
	  centerOnScroll: true,
      hideOnOverlayClick: false
    });
  }

  loadFancybox();
  $('ul#locations').live('change', loadFancybox); // triggered in close.js.erb
  

	$('#menu_editor textarea').focus(function(){
		$(this).animate({
			height: '86px'
		}, 300);
	});

	$('#menu_editor textarea').focusout(function(){
		$(this).animate({
			height: '43px'
		}, 300);
	});

});
