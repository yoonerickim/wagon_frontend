// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
//

$(document).ready(function() {

  function live_alert(id) {
    $("#"+id+"").fadeOut().delay(1000).fadeIn().delay().fadeOut().delay().fadeIn().fadeOut().delay().fadeIn();
  } 
  live_alert('red_alert');
  // NOT SURE WHERE TO PUT THIS - SETTINGS BOX FOR ON & OFF SWITCHES
  $(".cb-enable").click(function(){
    var parent = $(this).parents('.switch');
    $('.cb-disable',parent).removeClass('selected');
    $(this).addClass('selected');
    $('.checkbox',parent).attr('checked', true);
  });
  $(".cb-disable").click(function(){
    var parent = $(this).parents('.switch');
    $('.cb-enable',parent).removeClass('selected');
    $(this).addClass('selected');
    $('.checkbox',parent).attr('checked', false);
  });

  $('a.settings').fancybox({
    //width: 300,
    //height: 480,
    //autoDimensions: false,
    centerOnScroll: true,
    hideOnOverlayClick: false
  });

  $('a.confirm_order').fancybox({
    //width: 300,
    //height: 480,
    //autoDimensions: false,
    centerOnScroll: true,
    hideOnOverlayClick: false
  });

  // Start Map Code
  if ($('body.live div.current_map').length > 0) {
    var map = null;
    var locationMarker = null;
    var pinImage = new google.maps.MarkerImage('/assets/pin.png',
      // pinImage dimentions
      new google.maps.Size(32, 39),
      // pinImage origin
      new google.maps.Point(0,0),
      // pinImage anchor point
      new google.maps.Point(6, 35)
    );
    var container = $('div.current_map');
    var locationLatLng = new google.maps.LatLng(
        container.attr('data-location-lat'), 
        container.attr('data-location-lng')
    );

    // Build map
    function buildMap() {

      var mapOptions = {
        zoom: 14,
        center: locationLatLng,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };
      map = new google.maps.Map(container[0], mapOptions);

      var markerOptions = {
        position: locationLatLng,
        icon: pinImage,
        map: map
      }
      locationMarker = new google.maps.Marker(markerOptions);

      addOrderLocations();
    };
    
    function addOrderLocations() {
      var markerOptions = {
        map: map
      }
      $('#current_orders tr[data-order-type='+ hts.orders.SPOT_DELIVERY +']').
        each(function(index, element){
          element = $(element);
          markerOptions['position'] = new google.maps.LatLng(
            element.attr('data-lat'),
            element.attr('data-lng')
            );
          var marker = new google.maps.Marker(markerOptions);

          var infoOptions = {
            content: element.find('div.marker_html').html(),
            maxWidth: 440
          };
          var infoWindow = new google.maps.InfoWindow(infoOptions);

          google.maps.event.addListener(marker, 'click', function() {
            //closeInfoWindows();
            infoWindow.open(map, marker);
            map.panTo(markerOptions['position']);
          });
        });
      $('#current_orders tr[data-order-type='+ hts.orders.ADDRESS_DELIVERY +']').
        each(function(index, element){
          element = $(element);
          markerOptions['position'] = new google.maps.LatLng(
            element.attr('data-lat'),
            element.attr('data-lng')
            );
          var marker = new google.maps.Marker(markerOptions);

          var infoOptions = {
            content: element.find('div.marker_html').html(),
            maxWidth: 440
          };
          var infoWindow = new google.maps.InfoWindow(infoOptions);

          google.maps.event.addListener(marker, 'click', function() {
            //closeInfoWindows();
            infoWindow.open(map, marker);
            map.panTo(markerOptions['position']);
          });
        });
    };

    $('a[href="#tab1"]').click(function(event) {
      map = null;
      container.html('');
    });

    $('a[href="#tab2"]').click(function(event) {
      setTimeout(buildMap, 400);
    });

  } // end current map code
});
