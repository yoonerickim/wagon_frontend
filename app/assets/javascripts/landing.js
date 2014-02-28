// Main Tab System
function create_tabs(id){
	$("#"+id+" .tab_content").hide();
	$("#"+id+" ul.tabs li:first").addClass("active").show();
	$("#"+id+" .tab_content:first").show();
	$("#"+id+" ul.tabs li").click(function() {
		if (!$(this).hasClass('notab')) {
		    $("#"+id+" ul.tabs li").removeClass("active");
		    $(this).addClass("active");
		    $("#"+id+" .tab_content").hide();
		    var activeTab = $(this).find("a").attr("href");
		    $(activeTab).fadeIn();
		$(".info_box").fadeOut();
		    return false;
		}
	});
}

$(document).ready(function(){
	// home page billboard
	
	//window.setTimeout(function(){	
	//  $("#bb_nav a.activeSlide").html("<span><a href='#'>i</a></span>");
	//  $("#bb_nav a.activeSlide span").animate({width:50}, 15000);	
	//}, 300);
	
	function onBefore() {
		// todo: timing animations
		$('#title').html(this.title);
		$("#bb_nav a.activeSlide").html("<a href='#'>i</a>");
		$("#bb_nav a.activeSlide span").animate({width:0}, 0);
	}
	function onAfter() {
		// todo: timing animations
		$("#bb_nav a.activeSlide").html("<span><a href='#'>i</a></span>");
		$("#bb_nav a.activeSlide span").animate({width:50}, 15000);	
	}
	
	// $('#billboard ul').cycle({
	// 	timeout: 10000,
	// 	speed: 500,
	// 	prev: '#prev',
	// 	next: '#next',
	// 	before: onBefore,
	// 	after: onAfter,
	// 	pager:  '#bb_nav', 
	// 	pauseOnPagerHover: true, 
	// 	pagerEvent: 'mouseover' 
	// });
	
	// Create Tabs
	create_tabs('features');
	// Create Tabs Vendor Dashboard
	create_tabs('main_tabs');
	// Table Navigations
	var infobox_ht;
	$("#VOID table a.btn").click(function() {
		infobox_ht = $('.tab_container').height();
		//alert(infobox_ht);
		$(".info_box").css('height', infobox_ht);
		$(".info_box").fadeIn();
		return false;
	});

	$("a.close_info_box").click(function() {
		$(".info_box").fadeOut();
		return false;
	});


	// button on vendor landing page
	$(".btn_arrow").hover(function() {
		//alert("help");
		$(this).animate({ backgroundColor: "#ef4e22" }, 200);
		},function() {
		    $(this).animate({ backgroundColor: "#cb421d" }, 200);
	});
	// top nav on vendor landing page
	$('#nav a').hoverFadeColor({
		fadeTospeed: 100,
		fadeFromspeed: 100
	});

});