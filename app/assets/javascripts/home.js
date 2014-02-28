var map;

// PLUGINS
(function ($) {
// VERTICALLY ALIGN FUNCTION
$.fn.vAlign = function() {
  return this.each(function(i){
  var ah = $(this).height();
  var ph = $(window).height();
  var mh = (ph - ah) / 2;
  if(mh>0) {
    $(this).css('margin-top', mh);
  } else {
    $(this).css('margin-top', 0);
  }
});
};
})(jQuery);


$(document).ready(function() {
	var geocoder = new google.maps.Geocoder();
	var markers = new Array();
	var infoOptionsContent = null;
	var pin = null;
	var userMarker = null;
	var userMarkerImage = new google.maps.MarkerImage('/assets/blue_pin.png',
	  // pinImage dimentions
	  new google.maps.Size(32, 39),
	  // pinImage origin
	  new google.maps.Point(0,0),
	  // pinImage anchor point
	  new google.maps.Point(6, 35)
	);	
	var pinImage = new google.maps.MarkerImage('/assets/pin.png',
	  // pinImage dimentions
	  new google.maps.Size(32, 39),
	  // pinImage origin
	  new google.maps.Point(0,0),
	  // pinImage anchor point
	  new google.maps.Point(6, 35)
	);
	var container = $('#map');
	var origin_lat = container.attr('data-origin-lat');
	var origin_lng = container.attr('data-origin-lng');
  var delivery_type = container.attr('data-delivery-type');

  //var pin_lat = $('#pin_lat');
  //var pin_lng = $('#pin_lng');
  //var pin_address = $('#pin_address');

  //var location_lat = $('#location_lat');
  //var location_lng = $('#location_lng');
  //var location_address = $('#location_address');


  if ($('#map').length > 0) {
    buildMap();
  }

  //SEARCH BOX REPLACE DEFAULT TEXT
  var search_default = $('#map_search input').val();
  var search_input = $('#map_search input');
  search_input.blur(function() {
    if (this.value == '') {
      this.value = search_default
    };
  });

  search_input.focus(function() {
    if (this.value == search_default) {
      this.value = '';
    }
  });

  var search_location_default = $('#map_tools input').val();
  var search_location_input = $('#map_tools input');
  search_location_input.blur(function() {
    if (this.value == '') {
      this.value = search_location_default
    };
  });

  search_location_input.focus(function() {
    if (this.value == search_location_default) {
      this.value = '';
    }
  });

	//VARIABLES
	var page_box = jQuery("#page_box");
	var landing_overlay = jQuery("#landing_overlay");
	var location_overlay = jQuery("#location_overlay");
	var options_overlay = jQuery("#options_overlay");
	var main_overlay = jQuery(".main_overlay");

	//LOADING OPEN PAGE BOX
	page_box.css({
	  position:'absolute',
	  left: ($(window).width() - $('#page_box').outerWidth())/2,
	  top: ($(window).height() - $('#page_box').outerHeight())/2
	});

	//MAP VARS
	var minus_heights = $('#header').height() + $('#toolbar').height() + $('#footer').height();
	var map_container = $('#map'),
			sidebar = $('#sidebar'),
			container_height = $(window).height() - minus_heights;

	//RESIZE VAR AND FUNCTION
	$(window).resize(function() {
		var container_height = $(window).height() - minus_heights;
		map_container.css({height:container_height});
		sidebar.css({height:container_height});
		//PAGE BOX OVERLAY
		page_box.css({
			position:'absolute',
			left: ($(window).width() - page_box.outerWidth())/2,
			top: ($(window).height() - page_box.outerHeight())/2
		});
	});

	//MAP STUFF
	map_container.css({height:container_height});
	sidebar.css({height:container_height});

	//CLOSE PAGE BOX DIV
	jQuery("#page_box .close").live('click', function(){
		page_box.fadeOut(400);
		//page_box.animate({top:"0px"},600);
		return false;
	});

	//CLOSE MAIN OVERLAY DIV
	jQuery(".main_overlay .close").live('click', function(){
		main_overlay.fadeOut(400);
		//page_box.animate({top:"0px"},600);
		return false;
	});


	//OPEN PAGE BOX DIV
	//page_box.fadeIn(400);

	//INITIAL LOADING SPINNER FOR LOCATION OVERLAYS
	$('#location_overlay .overlay_wrapper .loading').activity({segments: 12, width:4, space: 3, length: 7, color: '#ccc'});

	// WINDOW RESIZE UI FUNCTIONS
	$(window).resize(function() {
	  landing_overlay.vAlign();
	  location_overlay.vAlign();
	  options_overlay.vAlign();
	  main_overlay.vAlign();
	
	  
	});

	//OPENING OF LANDING OVERLAY
	//jQuery("#content.landing .bookmarks").live('click', function(){
	//	alert('This will bring up any stored addresses for a simple 1-click interface')
	//	landing_overlay.fadeIn(400);
	//	landing_overlay.vAlign();
		//page_box.animate({top:"0px"},600);
	//	return false;
	//});

	jQuery("#content.landing .locations").live('click', function(){

		// if the browser supports the w3c geo api
		if(navigator.geolocation){
		  // get the current position
		  navigator.geolocation.getCurrentPosition(

		  // if this was successful, get the latitude and longitude
		  function(position){
		    var lat = position.coords.latitude;
		    var lng = position.coords.longitude;
		    $('#step_one_input_text').val('(' + lat + ', ' + lng + ')');
		    if (confirm('FYI: these are the geo-coordinates of your current location according to your web browser. Press OK to confirm accuracy and find restaurants that will deliver to you.')){
			    process_step_one();
		    }else{
			    $('#step_one_input_text').val('');
		    }
		  },
		  // if there was an error
		  function(error){
		    alert('Sorry, we were unable to obtain your geolocation from your browser.  Please enter your approxamate location instead.');
		  });
		}else{
			alert('Sorry, your browser does not support geolocation.')
		}

	});





	//CLOSE LANDING OVERLAY
	jQuery("#content.landing .close").live('click', function(){
		landing_overlay.fadeOut(400);
		//page_box.animate({top:"0px"},600);
		landing_overlay.html("<div class='overlay_wrapper'><div class='loading'></div></div>");
		$('.loading').activity({segments: 12, width:4, space: 3, length: 7, color: '#ccc'});
	  	//location_overlay.html("1-Working... This should be replaced by a spinning thing!<br /><div class=\"close\"><a href=''>Close Window</a> (This will change)</div>");
		return false;
	});

	//OPENING OF LOCATION OVERLAY
	jQuery("#info_window a, .should_open_menu_overlay_when_clicked").live('click', function(){
		location_overlay.fadeIn(400);
		location_overlay.vAlign();
		//page_box.animate({top:"0px"},600);
		return false;
	});

	//CLOSE LOCATION OVERLAY
	jQuery("#location_overlay .close").live('click', function(){
		location_overlay.fadeOut(400);
		options_overlay.fadeOut(300);
		//page_box.animate({top:"0px"},600);
		location_overlay.html("<div class='overlay_wrapper'><div class='loading'></div></div>");
		$('.loading').activity({segments: 12, width:4, space: 3, length: 7, color: '#ccc'});
    	//location_overlay.html("1-Working... This should be replaced by a spinning thing!<br /><div class=\"close\"><a href=''>Close Window</a> (This will change)</div>");
		return false;
	});



	//OPENING OF OPTIONS OVERLAY
	//jQuery("#location_overlay a.options").live('click', function(){
	//	options_overlay.fadeIn(400);

  //  //$(this).prop('href').append("?quantity=5") // TODO get qty from form, etc.

	//	//page_box.animate({top:"0px"},600);
	//	return false;
	//});

	//CLOSE LOCATION OVERLAY
	jQuery("#options_overlay .close").live('click', function(){
		options_overlay.fadeOut(400);
		//page_box.animate({top:"0px"},600);
		options_overlay.html("<div class='overlay_wrapper'><div class='loading'></div></div>");
		$('.loading').activity({segments: 12, width:4, space: 3, length: 7, color: '#555'});
    	//options_overlay.html("2-Working... This should be replaced by a spinning thing!<br /><div class=\"close\"><a href=''>Close Window</a> (This will change)</div>");
		return false;
	});

	// LOCATION OVERLAY CATEGORY ACCORDIANS
	jQuery("#location_overlay .categories").accordion();

  // recenter map
  // TODO update map button triggers recenter -- probably will change
  $('#map_tools .btn_update_map').click(function(event) {
    movePinViaSearch();
  });

  $('#map_tools .search_box input[type=text]').keyup(function(event) {
	  if (event.which == 13){movePinViaSearch()}
	});

  function movePinViaSearch(){
    var address = $('#map_tools .search_box input[type=text]').val();
    geocoder.geocode({ 'address': address }, function(results, status) {
      if (status == google.maps.GeocoderStatus.OK) {
        if (delivery_type == '2' && ['street_address', 'subpremise'].indexOf(results[0].types[0]) == '-1'){
	        alert('Please enter an exact street address.');
	        $('#formatted_address').val(results[0].formatted_address);
        }else{
          movePin(results[0].geometry.location);
        }
      }else{
	      alert('We were not able to locate that address. Please be more specific and try again.');
      }
    });
  }

  // build map and add listeners
  function buildMap() {

    var latlng = new google.maps.LatLng(origin_lat, origin_lng);
    var mapOptions = {
      zoom: 14,
      center: latlng,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    map = new google.maps.Map(container[0], mapOptions);


    if (delivery_type != hts.orders.ADDRESS_DELIVERY){
      map.setOptions({ draggableCursor: 'crosshair' });
	  	google.maps.event.addListener(map, "click", function(event) {movePin(event.latLng)});
    }

    //this calls fetchLocations() inside it.
    dropPin(origin_lat, origin_lng);
  }

  function movePin(latLng){
	  if (pin != null){pin.setMap(null)}
	
	  if ($('#location_lat').length > 0){
		  var the_pin_to_use = pinImage;
	  }else{
		  var the_pin_to_use = userMarkerImage;
		
	  }
	  pin = new google.maps.Marker({
	      position: latLng,
	      map: map,
	      icon: the_pin_to_use,
	      draggable: true
	  });
	  if (delivery_type != hts.orders.ADDRESS_DELIVERY){
      //google.maps.event.addListener(pin, 'dragend', function() {fetchLocations();});
    }
	  //fetchLocations();

    var lat, lng, address;

    // Set pin position for setting position when order is placed.
    lat = latLng.lat();
    lng = latLng.lng();

    if ($('#map').data('page') == 'confirm_location'){
      $('#location_lat').attr('value', latLng.lat());
      $('#location_lng').attr('value', latLng.lng());	
    }else{
      $('#pin_lat').attr('value', latLng.lat());
      $('#pin_lng').attr('value', latLng.lng());
    }

    //open the infowindow
    var infoOptions = {
      content: infoOptionsContent,
      maxWidth: 240
    };
    var infoWindow = new google.maps.InfoWindow(infoOptions);
    infoWindow.open(map, pin);

    window.setTimeout(function(){
		  $('#confirm_location_link').click(function(){
        document.location.href='/confirm_location?a=' + encodeURIComponent($('#pin_address').val()) + '&lat=' + $('#pin_lat').val() + '&lng=' + $('#pin_lng').val();
		  });
		  $('#go_to_order_link').click(function(){
        document.location.href='/confirm_order?pin_address=' + encodeURIComponent($('#pin_address').val()) + '&pin_lat=' + $('#pin_lat').val() + '&pin_lng=' + $('#pin_lng').val() + '&location_address=' + encodeURIComponent($('#location_address').val()) + '&location_lat=' + $('#location_lat').val() + '&location_lng=' + $('#location_lng').val();
		  });			
		
    }, 500);


    // reverse geocode here for address #pin_address
    geocoder.geocode({'latLng': latLng}, function(results, status){
      if (status == google.maps.GeocoderStatus.OK) {
        address = results[0].formatted_address;
        if ($('#map').data('page') == 'confirm_location'){
          $('#location_address').attr('value', address);	
	      }else{
          $('#pin_address').attr('value', address);
	        //var data = {lat: lat, lng: lng, address: address};
	        //$.post('/users/pin', data);
        }


      } else {
	      // if (pin_address.attr('value') == ''){
	      //   var data = {lat: lat, lng: lng, address: address};
	      //   $.post('/users/pin', data);
	      // }
        // TODO log me!!!
        // It would be nice to add something like this:
        // data = {
        //   path: 'current_url',
        //   message: "Could not reverse geocode!",
        //   data:"hash of relevant data to reproduce the error here"
        // }
        // $.post('/log',data};
      }
    });
  }

  // check map bounds and fetch locations from server
  function fetchLocations() {

    var latLng = pin.getPosition();
    var data = {lat: latLng.lat(), lng: latLng.lng(), t: delivery_type};

    $.get('/locations/fetch', data, function(result) {
      addMarkers();
      //attachListingAnimations();
      increaseBounds();
    });

  }

  // clean off all markers
  function clearMarkers() {
    for (i in markers) {
      markers[i].setMap(null);
    }
    markers.length = 0; // clear array
  }

  function closeInfoWindows(){
    for (i in markers) {
      markers[i].infoWindow.close();
    }
  }

  // collect locations from html, and add markers
  function addMarkers() {
    clearMarkers();
    $('#listings li').each(function(index, element) {
      addListingMarker(map, index, element);
    });
  }

  // put a marker on the map
  function addListingMarker(map, index, element) {
    var li = $(element);
    var id = li.attr('data-id');
    var name = li.attr('data-name');
    var lat = li.attr('data-lat');
    var lng = li.attr('data-lng');

    var latLng = new google.maps.LatLng(lat,lng);

    var markerOptions = { position: latLng,
      map: map,
      title: name,
      zIndex: index,
      icon: '/assets/map_marker.png'
    };

    var marker = new google.maps.Marker(markerOptions);

    var infoOptions = {
      content: li.find("div.marker_info").html(),
      maxWidth: 440
    };

    marker.infoWindow = new google.maps.InfoWindow(infoOptions);

    google.maps.event.addListener(marker, 'click', function() {
	    closeInfoWindows();
      marker.infoWindow.open(map, marker);
      map.panTo(latLng);
    });

    markers.push(marker);
  }

	// LINKS FROM VENDOR LISTINGS - OPEN INFOWINDOWS (STILL NEEDS SOME WORK)

	$('#listings li').live("click", function () {
		var index = $(this).attr("class").match(/location_([0-9]+)/)[1];
		gotoClickedMarker(index);

		// HIGHLIGHT SELECTED LOCATION
		$("#listings li").removeClass("active");
		$(this).addClass("active");

		return false;
	});

	/*
	$('.main_link_logo, .main_link').live("click", function () {
		var index = $(this).attr("href").match(/location_([0-9]+)/)[1];
		//alert(index);
		gotoClickedMarker(index);
		return false;
	});
	*/

	// OPENS INFOWINDOW FOR SELECTED VENDOR
	function gotoClickedMarker(index){
		google.maps.event.trigger(markers[index],'click');
		//return false;
	}

  function dropPin(lat,lng){
    var latLng = new google.maps.LatLng(lat,lng);
    movePin(latLng);

    switch(delivery_type){
	    case hts.orders.SPOT_DELIVERY:
        infoOptionsContent = '<div class="tool_tip"><div class="inside"><p><b>Tip:</b> clicking anywhere on the map <br> will move this spot and update available restaurants.</p></div></div>';
	      break;
      case hts.orders.TAKE_OUT:
        infoOptionsContent = '<div class="tool_tip"><div class="inside"><p><b>Tip:</b> clicking anywhere on the map <br> will move this spot and update available take-out restaurants nearby.</p></div></div>';
	      break;
	    case hts.orders.DINE_IN:
        infoOptionsContent = '<div class="tool_tip"><div class="inside"><p><b>Tip:</b> clicking anywhere on the map <br> will move this spot and update available dine-in restaurants nearby. </p></div></div>';
        break;
		  case hts.orders.CUSTOM:
		
		    if ($('#location_lat').length > 0){
          infoOptionsContent = '<div class="tool_tip"><div class="inside"><h3>Where is your desired vendor located?</h3><p>Click on a restaurant, food stand, convenience store, etc...';
          infoOptionsContent += "<br /> <br /><a id='go_to_order_link'  class='btn_med green' href='#'>ORDER FROM HERE</a></p></div></div>";
        }else{
          infoOptionsContent = '<div class="tool_tip"><div class="inside"><h3>Where do you want food delivered?</h3> <p>Clicking anywhere on the map will move your spot. It\'s OK to move around a bit after you order, we will text you to connect.';
          infoOptionsContent += "<br /> <br /> <a id='confirm_location_link' class='btn_med green' href='#'>I'LL BE NEAR HERE</a></p></div></div>";	
        }
      
	        break;
			default:
        infoOptionsContent = '<div class="tool_tip"><div class="inside"><p><b>Tip:</b> enter a new address in the search box above (right) to move this spot and update available restaurants. </p></div></div>';
    }

    var infoOptions = {
      content: infoOptionsContent,
      maxWidth: 240
    };
    var infoWindow = new google.maps.InfoWindow(infoOptions);

    //drop a blue dot at USER'S location 
    if ($('#location_lat').length > 0){
		  if (userMarker != null){userMarker.setMap(null)}
		  userMarker = new google.maps.Marker({
		      position: new google.maps.LatLng($('#pin_lat').val(),$('#pin_lng').val()),
		      map: map,
		      icon: userMarkerImage
		  });	
	
    }



    window.setTimeout(function(){
	   infoWindow.open(map, pin); 
	   //map.setZoom(map.getZoom() - 1); 

      window.setTimeout(function(){
			  $('#confirm_location_link').click(function(){
	        document.location.href='/confirm_location?a=' + encodeURIComponent($('#pin_address').val()) + '&lat=' + $('#pin_lat').val() + '&lng=' + $('#pin_lng').val();
			  });
			  $('#go_to_order_link').click(function(){
	        document.location.href='/confirm_order?pin_address=' + encodeURIComponent($('#pin_address').val()) + '&pin_lat=' + $('#pin_lat').val() + '&pin_lng=' + $('#pin_lng').val() + '&location_address=' + encodeURIComponent($('#location_address').val()) + '&location_lat=' + $('#location_lat').val() + '&location_lng=' + $('#pin_lng').val();
			  });			
			
      }, 500); 


	  }, 1000)



  }

	function increaseBounds(){

    var latLngs = new Array();
    $('#listings li').each(function(index, element) {
	    var li = $(element);
	    var lat = li.attr('data-lat');
	    var lng = li.attr('data-lng');
      latLngs.push(new google.maps.LatLng(lat,lng));
    });

    //add the pin location
    latLngs.push(pin.getPosition());

    var originLatLng = new google.maps.LatLng(origin_lat, origin_lng)

		if (latLngs.length == 1){
			  map.setZoom(11);
			  map.setCenter(latLngs[0]);
		}else{
			if (latLngs.length == 0){
				map.setZoom(12);
				map.setCenter(originLatLng);
			}else{
			  var bounds = new google.maps.LatLngBounds();
				for (var j = 0; j < latLngs.length; j++){
					bounds.extend(latLngs[j]);
				}
		    map.fitBounds(bounds);
	    }
		}
		//don't want to zoom in too far - it makes a bad UX
		if (map.getZoom() > 15){map.setZoom(15)}
	}


  //for step 1 select box
	$('#step_one_type_select').change(function(){
		if ($('#step_one_type_select').val() == hts.orders.SPOT_DELIVERY){
			$('#step_one_input_text').attr('placeholder', 'Enter a location to get started (e.g. city or zip)');
			$('#geo-location-button').show();
		}
		if ($('#step_one_type_select').val() == hts.orders.ADDRESS_DELIVERY){
			$('#step_one_input_text').attr('placeholder', 'Enter a full address (at least street and zip)');
			$('#geo-location-button').hide();
		}
		if ($('#step_one_type_select').val() == hts.orders.TAKE_OUT){
			$('#step_one_input_text').attr('placeholder', 'Enter a location to search for take-out (e.g. zip)');
			$('#geo-location-button').show();
		}
		if ($('#step_one_type_select').val() == hts.orders.DINE_IN){
			$('#step_one_input_text').attr('placeholder', 'Enter a location to search for restaurants');
			$('#geo-location-button').show();
		}
	});



	//LISTING HOVER ANIMATIONS
	function attachListingAnimations() {
	  $('#listings li.odd').hover(
	      function () {
	        $(this).animate({backgroundColor: '#ffffff',color:"#222"}, 200);
	      },
	      function () {
	        $(this).animate({backgroundColor: '#f3f3f3',color:"#555"}, 200);
	      });
	  $('#listings li.even').hover(
	      function () {
	        $(this).animate({backgroundColor: '#ffffff',color:"#222"}, 200);
	      },
	      function () {
	        $(this).animate({backgroundColor: '#e4e4e4',color:"#555"}, 200);
	      });
	}


  //step 1 home stuff
  $('#step_one_input_text').keyup(function(event){
    if (event.which == 13){process_step_one()}
  });
	$('#the_button').click(function(){
		process_step_one();
	});

	function process_step_one(){

	  $('#the_button').attr('disabled', 'disabled');
	  $('#the_button').val('Loading...')

	  geocoder.geocode( { 'address': $('#step_one_input_text').val()}, function(results, status) {
	    if (status == google.maps.GeocoderStatus.OK) {
        var lat = results[0].geometry.location.lat();
        var lng = results[0].geometry.location.lng();

        document.location.href='/confirm_spot?a=' + encodeURIComponent(results[0].formatted_address) + '&lat=' + lat + '&lng=' + lng;

	    }else{
		    reset_step_one_button();
		    alert('We were not able to locate this address. Perhaps try to be more specific?');
	    }

    });

	}

  function reset_step_one_button(){
    $('#the_button').removeAttr('disabled');
    $('#the_button').val('Next');
  }


  $('#filter_search').keyup(function(event){
	  if (event.which == 13 && ($('#filter_search').val().length > 2 || $('#filter_search').val().length == 0)){
	    var latLng = pin.getPosition();
	    var data = {
        lat: latLng.lat(), lng: latLng.lng(),
        t: delivery_type,
        q: encodeURIComponent($('#filter_search').val())
      };
	    $.get('/locations/fetch', data, function(result) {
	      addMarkers();
        //probably better UX to not increase bounds here
 	      //increaseBounds();
	    });
	  }
  });

  // lightbox (general use)
  //NOT WORKING --> $('.lightbox').fancybox();
  
  prepLightBoxes();
  
  
  
});
//----------END DOCUMENT READY -------------

prepLightBoxes = function(){
  
  $("a.lightbox").click(function() {
		var dialogTitle = $(this).attr("title");
		var dialogID = $(this).attr("href");
		$(dialogID).dialog({
			autoOpen: false,
			show: 	"fade",
			hide: 	"fade",
			modal: 	true,
			title: 	dialogTitle,
			width: 	500,
			height: 440,
			minWidth: 500,
			minHeight: 440
		}).dialog("open");
		return false;
	});
	
  
}

