(function (a) { 
    a.fn.formWizard = function (f) {
        if (this.length > 1) {
            this.each(function () {
                a(this).formWizard(f)
            });
            return this
        }
        var t = a(this),
            n = a(this).find("ul.steps"),
            l = a(this).find("ul.steps li");
        var j = {
            fadeInWizard: 500,
            autoSpaceSteps: true,
            stepArrows: true,
            defaultAjaxRequest: true,
            useValidation: true,
            formClass: ".defaultRequest",
            enableHelpers: true,
            helperArrows: true,
            userHoverIntent: true,
            interactionBlock: true,
            fadeInBlock: 500
        };
        var f = a.extend(j, f);
        this.intialize = function () {
            return this
        };
        var e = function () {
                var u = a(t).find(".step_content").height();
                a(t).find(".helper").css("height", u).animate({
                    width: "hide"
                }, 500);
                if (f.interactionBlock && a.browser.msie && a.browser.version.substr(0, 1) < 7) {
                    a(t).find(".step_content .blockuser").css("height", u + "px")
                }
            };
        
        a(this).find(".no_javascript").hide();
        a(this).removeClass("js");
        if (f.fadeInWizard > 0) {
            a(this).hide();
            a(this).fadeIn(f.fadeInWizard)
        }
        if (f.interactionBlock) {
            a(t).find(".step_content").prepend('<div class="blockuser"><span></span></div>')
        }
        if (f.enableHelpers) {
            if (f.helperArrows) {
                a(this).find(".helper").prepend('<span class="arrow"></span>')
            }
            if (jQuery().hoverIntent && f.userHoverIntent) {
                a(this).find("a.show_helper").hoverIntent({
                    over: o,
                    timeout: 1000,
                    out: b,
                    interval: 150
                })
            } else {
                a(this).find("a.show_helper").mouseover(function () {
                    q(a(this))
                }).mouseout(function () {
                    p(a(this))
                })
            }
        }
        function o() {
            var u = a(this).position();
            a(a(this).attr("href")).animate({
                width: "show"
            }, 500, function () {
                a("span.arrow").css("margin-top", "0").hide();
                a("span.arrow").animate({
                    marginTop: (u.top - 7),
                    opacity: "show"
                }, {
                    queue: true,
                    duration: 800
                })
            })
        }
        function q(v) {
            var u = a(v).position();
            a(a(v).attr("href")).animate({
                width: "show"
            }, 500, function () {
                a("span.arrow").css("margin-top", "0").hide();
                a("span.arrow").animate({
                    marginTop: (u.top - 7),
                    opacity: "show"
                }, {
                    queue: true,
                    duration: 800
                })
            })
        }
        function b() {
            a(a(this).attr("href")).animate({
                width: "hide"
            }, 500)
        }
        function isUrl(s) {
			    var regexp = /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/i
			    return regexp.test(s);
		    }
        function p(u) {
            a(a(u).attr("href")).animate({
                width: "hide"
            }, 500)
        }
        
        function validate() {
          var validateOutput = ''
          var state_regexp = /^(?:A[KLRZ]|C[AOT]|D[CE]|FL|GA|HI|I[ADLN]|K[SY]|LA|M[ADEINOST]|N[CDEHJMVY]|O[HKR]|PA|RI|S[CD]|T[NX]|UT|V[AT]|W[AIVY])*$/

          if (a(n).find("li.current").attr("id") == 'step1'){

            if ($('.wizard .vendor_name').val() == ''){
              validateOutput += '* Enter a company name' + "\n";
            } 
            if ($('.wizard .vendor_legal_name').val() == ''){
              validateOutput += '* Enter a company legal name' + "\n";
            } 
            if ($('.wizard .vendor_description').val() == ''){
              validateOutput += '* Enter a company description' + "\n";
            }

            if ($('.wizard .initial_user')){
              if ($('.wizard .user_first_name').val() == ''){
                validateOutput += '* Enter your first name' + "\n";
              } 
              if ($('.wizard .user_last_name').val() == ''){
                validateOutput += '* Enter your last name' + "\n";
              } 
              if ($('.wizard .user_contact_phone').val() == ''){
                validateOutput += '* Enter a valid telephone number' + "\n";
              } 
              if ($('.wizard .user_role_title').val() == ''){
                validateOutput += '* Enter your company title' + "\n";
              }
            }

          }

          if (a(n).find("li.current").attr("id") == 'step2'){
          	 if ($('.wizard .location_address_street1').val() == ''){
               validateOutput += '* Enter a Street1 address' + "\n";
             } 
          	 if ($('.wizard .location_address_city').val() == ''){
               validateOutput += '* Enter a city' + "\n";
             } 
             if ($('.wizard .location_address_state').val() == '' || 
                 !state_regexp.test($('.wizard .location_address_state').val())){ 
                   validateOutput += '* Enter a valid state two-letter code' + "\n";
                 }		
          	 if ($('.wizard .location_address_zip').val() == ''){
               validateOutput += '* Enter a valid zip' + "\n";
             } 
          	 if ($('.wizard .location_phone').val() == ''){
               validateOutput += '* Enter a valid telephone number for this location' + "\n";
             } 	
             if (($('.wizard .spot-delivery').prop('checked') ||
                 $('.wizard .address-delivery').prop('checked') ||
                 $('.wizard .take-out').prop('checked') ||
                 $('.wizard .dine-in').prop('checked')) == false ){
                   validateOutput += '* Please select at least one type of order (GPS Delivery, Address Delivery, Take-Out, and/or Dine-in) to accept for this location.' + "\n";
                 }  
             if ($('.standard-tags').find(":checked").length == 0 && 
                 $('.extra-tags').find(":checked").length == 0){
                   validateOutput += '* Please select at least one category for this location.' + "\n";
                 }
             if (validateOutput == '' && $('#lat').val() == ''){
               codeSignupAddress();
               validateOutput += '* Please type in your full address a different way if possible. We were unable to find its GPS coordinates based on how it was entered.';
             }
             window.setTimeout(function(){loadUpBoundariesMap();}, 500);
          }

          if (validateOutput == '' ){ 
            return true;
          } else{
            validateOutput = 'Please correct the following before continuing: ' + "\n\n" + validateOutput
            alert(validateOutput);
            return false;
          }
        }
        
        if (f.autoSpaceSteps) {
            var r = a(n).width();
            var h = 0;
            var m = a(l).size();
            var i = 1;
            a(n).find("li:first-child").addClass("current");
            a(l).each(function (u) {
                h = h + a(this).width();
                a(this).contents().wrap("<p></p>");
                if (f.stepArrows) {
                    if (m != (u + 1)) {
                        a(this).append("<span></span>")
                    }
                }
            });
            var s = r - h;
            var g = Math.floor(s / m / 2);
            a(l).each(function () {
                a(this).css({
                    "padding-right": g,
                    "padding-left": g
                })
            })
        }
        var c = a(this).find(".step_content div.step:first").addClass("current");
        a(this).find(".step_content div.step:first ~ div.step").hide();
        e();
        
        // the user clicks the "next" button on the wizard
        a(this).find(".next").click(function () {	
          if (validate()){ 
            var nextStep = parseInt($(this).attr("id").match(/\d+/)[0]) + 1;
            var paragraph = $("li#step" + nextStep + " p");
            if (nextStep > 5 || paragraph.find("a").size() == 0) 
              paragraph.html('<a href="#" class="wizard-step" id="wizard-step-' + nextStep + '">' + paragraph.html() + '</a>');
      
            k("next");
          }
        });
        
        // the user clicks the "previous" button on the wizard
        a(this).find(".prev").click(function () {
          var currentStep = parseInt(a(n).find("li.current").attr("id").match(/\d+/)[0]);
          var newStep = currentStep - 1;
          var furthestStep = parseInt(a(n).find("li a:last").attr("id").match(/\d+/)[0]);

          // The following logic is slightly tricky. Basically, if I'm on the latest step in the wizard and I click "Back",
          //  I don't need to validate the fields on the step that I am departing away from. However, if I hit "Back" and I'm
          //  not on the latest step in the wizard, I have to validate as navigation might allow the user to then jump over the 
          //  step with invalid data.
          if (currentStep == furthestStep)
            k("prev");

          else if (validate())
            k("prev");
        });
        
        // the user clicks one of the breadcrumbs on the wizard
        a(this).find("a.wizard-step").live("click", function() {
          var currentStep = parseInt(a(n).find("li.current").attr("id").match(/\d+/)[0]);
          var newStep = parseInt($(this).attr("id").match(/\d+/)[0]);
          var furthestStep = parseInt(a(n).find("li a:last").attr("id").match(/\d+/)[0]);
          
          // The following logic is slightly tricky. Basically, if I'm on the latest step in the wizard and I click an earlier step,
          //  I don't need to validate the fields on the step that I am departing away from. However, if I click an earlier step and I'm
          //  not on the latest step in the wizard, I have to validate as navigation might allow the user to then jump over the 
          //  step with invalid data. Additionally, if I click a step later in the wizard, I have to validate.
          if (newStep < currentStep && currentStep == furthestStep)
            k(newStep);
            
          else if (validate())
            k(newStep);
          
          return false;
        });
        if (f.useValidation) {
            a(this).find(f.formClass).validate()
        }
        if (f.defaultAjaxRequest) {
            a(this).find(f.formClass).submit(function () {
                var u = a(this).attr("action");
                var w = a(this);
                if (f.useValidation) {
                    var v = a(w).valid()
                } else {
                    v = true
                }
                if (v) {
                    a(document).ajaxStart(function () {
                        if (f.interactionBlock) {
                            d(1)
                        }
                    }).ajaxStop(function () {
                        if (f.interactionBlock) {
                            d(0)
                        }
                        e()
                    });
                    a.ajax({
                        type: "POST",
                        url: u,
                        data: a(this).serialize(),
                        dataType: "json",
                        success: function (x) {
                            if (x.response) {
                                a("div.errormsg").remove();
                                if (x.step) {
                                    k(x.step)
                                } else {
                                    k("next")
                                }
                            } else {
                                a("div.errormsg").remove();
                                a('<div class="errormsg">' + x.message + "</div>").insertBefore(w)
                            }
                        }
                    })
                }
                e();
                return false
            })
        }
        var d = this.interactionBlock = function (u) {
                if (u == 1) {
                    a(t).find(".step_content .blockuser").fadeIn(f.fadeInBlock)
                } else {
                    if (u == 0) {
                        a(t).find(".step_content .blockuser").fadeOut(f.fadeInBlock)
                    }
                }
            };
        var k = this.openstep = function (w) {
                var v = a(t).find(".step_content div.step.current");
                var u = a(t).find(".step_content div.step").size();
                a(v).fadeOut(function () {
                    a(v).removeClass("current");
                    a(n).find("li").removeClass("completed");
                    if (w == "next") {
                        a(this).next(".step").fadeIn().addClass("current");
                        a(n).find("li.current").removeClass("current").addClass("completed").next("li").addClass("current")
                    } else {
                        if (w == "prev") {
                            a(this).prev(".step").fadeIn().addClass("current");
                            a(n).find("li.current").removeClass("current").prev("li").addClass("current").prev("li").addClass("completed")
                        } else {
                            a(v).parent().find("div.step:nth-child(" + (w + 1) + ")").fadeIn().addClass("current");
                            a(n).find("li.current").removeClass("current");
                            a(n).find("li:nth-child(" + w + ")").addClass("current");
                            a(n).find("li.current").prev("li").addClass("completed")
                        }
                    }
                    if (a(n).find("li:last-child").hasClass("current")) {
                        var x = a(n).find("li.current").css("background-color");
                        a(n).css("background-color", x)
                    } else {
                        var x = a(n).find("li:not(.current):first").css("background-color");
                        a(n).css("background-color", x)
                    }
                    e()
                })
            };
        return this.intialize()
    }
})(jQuery);
