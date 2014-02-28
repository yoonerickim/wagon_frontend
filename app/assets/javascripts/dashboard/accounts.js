// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function() {

  var container = $('div#in_process_map');
  var map = null;
  var userMarker = null;
  var spotMarkers = [];
  var deliveryMarkers = [];
  var infoWindows = [];
  var greenDot = new google.maps.MarkerImage('/assets/ball_green.png',
    null, null,
    new google.maps.Point(0,16), // anchor 
    new google.maps.Size(32,32) // scaled size
    );
  var blueDot = new google.maps.MarkerImage('/assets/ball_blue.png', 
    null, null, 
    new google.maps.Point(0,16), // anchor 
    new google.maps.Size(32,32) // scaled size
    );
  var yellowDot = new google.maps.MarkerImage('/assets/ball_yellow.png', 
    null, null, 
    new google.maps.Point(0,16), // anchor 
    new google.maps.Size(32,32) // scaled size
    );
  var orangeDot = new google.maps.MarkerImage('/assets/ball_orange.png', 
    null, null, 
    new google.maps.Point(0,16), // anchor 
    new google.maps.Size(32,32) // scaled size
    );
  var pinImage = new google.maps.MarkerImage('/assets/pin.png',
      new google.maps.Size(32, 39), // size
      new google.maps.Point(0,0), // origin
      new google.maps.Point(6, 35) // anchor
      );

  if (container.length > 0) {
    buildMap();
  }

  function buildMap() {
    var spots = {};
    var locations = {};
    var deliveries = [];
    var bounds = new google.maps.LatLngBounds();

    var mapContainer = $('#in_process_map');
    var currentOrders = $('table#in_process');
    if (currentOrders.length == 0){
      //currentOrders = $('table#current_orders');
    }

    var userLatLng = null;
    //if (currentOrders.attr('data-user-lat') && currentOrders.attr('data-user-lng')) {
    //  userLatLng = new google.maps.LatLng(currentOrders.attr('data-user-lat'), currentOrders.attr('data-user-lng'));
    //  console.log(userLatLng);
    //  bounds.extend(userLatLng);
    //}

    currentOrders.find('tbody tr').each(function(index, element){
      element = $(element);
      var id = element.attr('data-id');

      var latLng = new google.maps.LatLng(element.attr('data-spot-lat'), element.attr('data-spot-lng'));
      bounds.extend(latLng);
      spots[id] = latLng;

      var latLng = new google.maps.LatLng(element.attr('data-location-lat'), element.attr('data-location-lng'));
      bounds.extend(latLng);
      locations[id] = latLng;

      if (element.attr('data-delivery-lat') && element.attr('data-delivery-lng')) {
        var latLng = new google.maps.LatLng(element.attr('data-delivery-lat'),element.attr('data-delivery-lng'));
        //console.log(latLng);
        bounds.extend(latLng);
        deliveries[id] = latLng;
      }
    });

    var mapOptions = {
      zoom: 14,
      center: bounds.getCenter(),
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    map = new google.maps.Map(container[0], mapOptions);
    map.fitBounds(bounds);

    addUser(userLatLng);
    addSpots(spots);
    addLocations(locations);
    addDeliveries(deliveries);
  }

  function addUser(latLng) {
    if (latLng == null) { return false; }
    var markerOptions = {
      position: latLng,
      icon: blueDot,
      map: map
    };
    userMarker = new google.maps.Marker(markerOptions);

    var infoOptions = {
      content: '<div id="info-window"><h1>My Current Location</h1><p>'+ latLng +'</p></div>',
      pixelOffset: new google.maps.Size(0,12),
      maxWidth: 440
    }
    var infoWindow = new google.maps.InfoWindow(infoOptions);
    infoWindows.push(infoWindow);

    google.maps.event.addListener(userMarker, 'click', function(){
      closeInfoWindows();
      infoWindow.open(map, userMarker);
      map.panTo(markerOptions['position']);
    });
  }

  function addSpots(spots) {
    var content = null;

    for (var id in spots) {
      content = $('table#in_process tbody tr[data-id=' + id + ']').find('td.spot').html();
      addDot(blueDot, spots[id], content);
    }
  }

  function addLocations(locations) {
    var content = null;

    for (var id in locations) {
      content = $('table#in_process tbody tr[data-id=' + id + ']').find('td.location').html();
      addDot(pinImage, locations[id], content);
    }
  }

  function addDeliveries(deliveries) {
    var content = null;

    for (var id in deliveries) {
      content = $('table#in_process tbody tr[data-id=' + id + ']').find('td.info').html();
      addDot(greenDot, deliveries[id], content);
    }
  }

  function addDot(image, latLng, content) {
    var spotMarker = new google.maps.Marker({
      position: latLng,
        icon: image,
        map: map
    });
    spotMarkers.push(spotMarker);
    var infoWindow = new google.maps.InfoWindow({
      content: content,
        pixelOffset: new google.maps.Size(0,12),
        maxWidth: 440
    });
    infoWindows.push(infoWindow);

    google.maps.event.addListener(spotMarker, 'click', function(){
      closeInfoWindows();
      infoWindow.open(map, spotMarker);
      map.panTo(spotMarker.position);
    });
  }

  function closeInfoWindows() {
    for(var i = 0; i < infoWindows.length; i++) {
      infoWindows[i].close();
    }
  }
});
