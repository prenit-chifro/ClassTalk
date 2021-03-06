// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery.remotipart
//= require bootstrap-sprockets
//= require moment 
//= require bootstrap-datetimepicker
//= require turbolinks
//= require fullcalendar
//= require fullcalendar/gcal
//= require_tree .

this.App || (this.App = {});

App.checkIsAndroidNativeApp = function (){
	
	if(navigator.userAgent.indexOf("CLASSTALK_ANDROID_APP") > -1){
		
		return true;
	}
	
	return false;
}

App.checkIsIosNativeApp = function (){
	if(navigator.userAgent.indexOf("CLASSTALK_IOS_APP") > -1){
		return true;
	}
	return false;
}

App.isAndroidNativeApp = App.checkIsAndroidNativeApp();
App.isIosNativeApp = App.checkIsIosNativeApp();
App.hasSubscribedToWebNotifications = false;
App.currentUserId  = "";

var isMobile = {
    Android: function() {
        return navigator.userAgent.match(/Android/i);
    },
    BlackBerry: function() {
        return navigator.userAgent.match(/BlackBerry/i);
    },
    iOS: function() {
        return navigator.userAgent.match(/iPhone|iPad|iPod/i);
    },
    Opera: function() {
        return navigator.userAgent.match(/Opera Mini/i);
    },
    Windows: function() {
        return navigator.userAgent.match(/IEMobile/i);
    },
    any: function() {
        return (isMobile.Android() || isMobile.BlackBerry() || isMobile.iOS() || isMobile.Opera());
    }
};

if(!String.linkify) {
    String.prototype.linkify = function() {

        // http://, https://, ftp://
        var urlPattern = /\b(?:https?|ftp):\/\/[a-z0-9-+&@#\/%?=~_|!:,.;]*[a-z0-9-+&@#\/%=~_|]/gim;

        // www. sans http:// or https://
        var pseudoUrlPattern = /(^|[^\/])(www\.[\S]+(\b|$))/gim;

        // Email addresses
        var emailAddressPattern = /[\w.]+@[a-zA-Z_-]+?(?:\.[a-zA-Z]{2,6})+/gim;

        return this
            .replace(urlPattern, '<a href="$&" target="_blank">$&</a>')
            .replace(pseudoUrlPattern, '$1<a href="http://$2" target="_blank">$2</a>')
            .replace(emailAddressPattern, '<a href="mailto:$&" target="_blank">$&</a>');
    };
}

$(document).on("ready", function(){
	App.sendGCMRegistraionIdToBackend();
	App.sendIosDeviceTokenToBackend();
});

$(document).on('turbolinks:before-visit', function(event){
	$(".ajax-loader").css("display", "block");	
});

$(document).ajaxComplete(function( event, xhr, requestOptions ) {
	newCsrfToken = xhr.getResponseHeader('X-CSRF-Token');
	if(newCsrfToken){
		$('meta[name="csrf-token"]').attr('content', newCsrfToken);
	}	
	newCurrentUserId = xhr.getResponseHeader('X-Current-User-Id');
	if(newCurrentUserId){
		App.currentUserId = newCurrentUserId;
		$('meta[name="current-user-id"]').attr('content', newCurrentUserId);
	}
	
	sendAndroidGCMRegistrationFlag = xhr.getResponseHeader('X-Send-Android-GCM-Registration-Id-Flag');
	if(sendAndroidGCMRegistrationFlag){
		sendGCMRegistraionIdToBackend();
	}

	sendIosDeviceTokenFlag = xhr.getResponseHeader('X-Send-Ios-Deivce-Token-Flag');
	if(sendAndroidGCMRegistrationFlag){
		App.sendIosDeviceTokenToBackend();
	}
});

$(document).on("turbolinks:load", function(){
	
	$(".alert").delay(4000).slideUp(200, function() {
		$(this).alert('close');
	});
	$(".ajax-loader").css("display", "none");
	$('#navbar > ul.nav li a').click(function(e) {

		var $this = $(this);
		$this.parent().siblings().removeClass('active-navigation').end().addClass('active-navigation');		
	});
	$('#navbar li a[data-toggle="tab"]').on('click', function (e) {    		
		var targetAchieve = $(this).attr('href');
		$(".home-new-tabs li").removeClass('active');
		$(".home-new-tabs li a[href='" + targetAchieve + "']").parent().addClass('active');
		window.location.replace(('' + window.location).split('#')[0] + targetAchieve);
	});
	$(function(){
		
		var hash = window.location.hash;		
		
		if(hash){
			$('ul.nav a[href="' + hash + '"]').tab('show');		
			$('#navbar ul.nav a[href="' + hash + '"]').parent().addClass('active-navigation');
		}else{
			$('ul.nav a[href="' + "#all-messages" + '"]').tab('show');		
			$('#navbar ul.nav a[href="' + "#all-messages" + '"]').parent().addClass('active-navigation');
		}
		
	
		$('.nav-tabs a').click(function (e) {
			var hash = $(this).attr("href");
			window.location.replace(('' + window.location).split('#')[0] + hash);
			if (isMobile.any()){			
				$('#navbar ul.nav li').removeClass('active-navigation');
				$('#navbar ul.nav li').removeClass('active');
				$('#navbar ul.nav a[href="' + hash + '"]').parent().addClass('active-navigation');			
				
			}
		});

		document.onmouseover = function() {
		    //User's mouse is inside the page.
		    window.innerDocClick = true;
		}

		document.onmouseleave = function() {
		    //User's mouse has left the page.
		    window.innerDocClick = false;
		}

		window.onhashchange = function() {
		    if (window.innerDocClick) {
		        //Your own in-page mechanism triggered the hash change
		    } else {
		    	//window.location.hash = "";
		    	history.back();
		        //Browser back button was clicked
		    }
		}
	});
	
	App.currentUserId = $('meta[name="current-user-id"]').attr('content');
	App.saveCurrentUrlOnAndroid();
	
	if(App.hasSubscribedToWebNotifications == false){
		App.checkWebNotificationServiceWorker();
	}
	
	/*For right menu*/
	$('.navbar-toggle').click(function(e){
		$(this).toggleClass("is-active");
		var animateMainMenu = $("#navbar");
		
		animateMainMenu.animate({
			right: parseInt(animateMainMenu.css('right')) == 0 ? -(animateMainMenu.outerWidth()) :0
		});
		e.stopPropagation();
		e.preventDefault();
	});

	$('.main_toggle_menu').click(function(e){				
		$('.main_toggle_menu').not(this).find('ul').slideUp();
		$(this).find('ul').slideToggle(300);
		$(this).siblings().find(".arrow-up-icon").removeClass('arrow-down-icon');
		$(this).find(".arrow-up-icon").toggleClass("arrow-down-icon");
		$(this).siblings().removeClass('active');
		e.stopPropagation();
		e.preventDefault();
	});
	$(".right-menu").on("click", function(e){
		$(this).find(".arrow-up-icon").toggleClass("arrow-down-icon");
		$(".right-menu-toggle").slideToggle();
		e.stopPropagation();
		e.preventDefault();
	});
	$(document).click(function(e) {
		if(e.target.id!="navbar"){
			$(".navbar-toggle").removeClass("is-active");
			$("#navbar").animate(
				{right:"-250px"}
			);
			$('.main_toggle_menu').find('ul').slideUp();
			$('.main_toggle_menu').find(".arrow-up-icon").toggleClass("arrow-down-icon");
		}
	});
	$(document).click(function(evt){		
		if(evt.target.id!="right-menu-toggle-id"){
			$(".arrow-up-icon").removeClass("arrow-down-icon");
			$(".right-menu-toggle").slideUp();
		}
	});
	$(document).keyup(function(e) {
		if (e.keyCode === 27){
			$(".modal").find("button.close").trigger("click");
		}
	});	
	
	$(".teachers-list-heading").click(function(e){
		$(this).find(".arrow-up-icon").toggleClass("arrow-down-icon");
		$(this).parents("li").find("div.classRoute").slideToggle();
		e.preventDefault();
		e.stopPropagation();
	});	
	$(".teachers-list-heading-inner").click(function(e){
		$(this).find(".arrow-up-icon").toggleClass("arrow-down-icon");
		$(this).parents("li.find-teacher-list").find("div.classRoute").slideToggle();
		e.preventDefault();
		e.stopPropagation();
	});	
	
	$('.next-page-link').click(function(event){
		clickedElement = $(this);
		App.navigateToLink(clickedElement);			
	});

	$(".alert").delay(2000).slideUp(200, function() {
		$(this).alert('close');
	});
	$('#login-form-link').click(function(e) {
		$("#login-form").delay(100).fadeIn(100);
 		$("#register-form").fadeOut(100);
		$('#register-form-link').removeClass('active');
		$(this).addClass('active');
		e.preventDefault();
	});
	$('#register-form-link').click(function(e) {
		$("#register-form").delay(100).fadeIn(100);
 		$("#login-form").fadeOut(100);
		$('#login-form-link').removeClass('active');
		$(this).addClass('active');
		e.preventDefault();
	});
	$(".dropdownToggle").click(function(e){
		$(".dropdownMenu").slideToggle("slow");
		e.preventDefault();
	});
	$(document).click(function(e) {
		if(e.target.id!="dropdownToggle"){
			$('.dropdownMenu').slideUp(1000);
		}
	});
	

	if($("ul.main-app-tabs li:nth-child(1)").hasClass("active")){
		if($(this).find("a[href='#chats']")){
			$("li.chat-tab-icon").css("display", "inline-block");
			$("li.contact-tab-icon").css("display", "none");
			$("li.group-tab-icon").css("display", "none");
		}
	}
	$('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {    
		var target = $(this).attr('href');
		
		if(target=="#chats"){
			$("li.chat-tab-icon").css("display", "inline-block");
			$("li.contact-tab-icon").css("display", "none");
			$("li.group-tab-icon").css("display", "none");
		} else if(target=="#contacts"){
			$("li.chat-tab-icon").css("display", "none");
			$("li.contact-tab-icon").css("display", "inline-block");
			$("li.group-tab-icon").css("display", "none");
		} else if(target=="#groups"){
			$("li.chat-tab-icon").css("display", "none");
			$("li.contact-tab-icon").css("display", "none");
			$("li.group-tab-icon").css("display", "inline-block");
		} 
		
		$(target).css('left','-'+$(window).width()+'px');   
		var left = $(target).offset().left;
		$(target).css({left:left}).animate({"left":"0px"}, "5");

		radioButtonId = $(this).attr("data-message-category-input-id");
		radioButton = $(radioButtonId);
		messageCategoriesDiv = radioButton.parents(".message-categories-div")
		messageCategoriesDiv.find('input').prop('checked', false);
		radioButton.prop('checked', true);
		
	});
	$(".view-attachment-button").on("click", function(){
		$(this).html("");
		attachmentType = $(this).attr("data-attachment-type");
		if(attachmentType == "Image"){
			var linkMedia = $(this).attr("data-attachment-url");
			var markupArryForMedia=[
				'<p style="max-width: 300px; margin: 0 auto;">',
					'<img style="width: 100%;" height= "200" src="' +  linkMedia + '"></img>',
				'</p>' 
			];
		}

		if(attachmentType == "Video"){
			var linkMedia = $(this).attr("data-attachment-url");
			var fileType = $(this).attr("data-attachment-extension");
			var markupArryForMedia=[
				'<p style="max-width: 300px; margin: 0 auto;">',
					'<video width="300" height="200" controls class="video-js vjs-default-skin">',
							'<source src="' + linkMedia + '" type="' + fileType +'" >',
							
							'Your browser does not support the video tag.',
					'</video>',
				'</p>' 
			];
		}
		if(attachmentType == "Document"){
			var linkMedia = $(this).attr("data-href");
			var markupArryForMedia=[
				'<p style="max-width: 300px; margin: 0 auto;">',
					'<iframe style="width: 100%;" height= "200" src="' +  linkMedia + '"></iframe>',
				'</p>' 
			];
		}

		$(this).html(markupArryForMedia.join(''));
	});

	if (isMobile.any()){			
		$(".swipe-area, .swipe-area-show").swipe({
			swipeStatus:function(event, phase, direction, distance, duration, fingers){
				if (phase=="move" && direction =="left") {
				   var tabShow = $('#tablist .active').next();
					if (tabShow.length > 0)
						tabShow.find('a').tab('show');
					return false;
				}
				if (phase=="move" && direction =="right") {
				  var tabShow = $('#tablist .active').prev();
					if (tabShow.length > 0)
						tabShow.find('a').tab('show');
					return false;
				}
			},
			allowPageScroll:"vertical"
		});
		var longTapCount=1000;
		$(".tab-content-show ul li.message .media-body").swipe({
			longTap:function(event, target) {
			  longTapCount++;
			  showTooltip(target);
			},
		});
		function showTooltip(target) {
			$("div.delete-message").fadeIn(300);
		}
	}
	function fixMessagesButton() {		
		var buttonDiv = $('.detect-div');
		if(buttonDiv.offset()){
			var windowTop = $(window).scrollTop();
			var divTop = $('.detect-div').offset().top;
			if (windowTop > divTop) {				
				$('.chat-show-tabs-upper-div').addClass('stick');
				$('.scroller').addClass('scroller-fixed');
				$('.detect-div').height($('.chat-show-tabs-upper-div').outerHeight() +56);
			} else {
				$('.chat-show-tabs-upper-div').removeClass('stick');
				$('.scroller').removeClass('scroller-fixed');
				$('.detect-div').height(0);
			}
		}		
	}
	$(window).scroll(fixMessagesButton);
	
	if (isMobile.any()){
		$(".tabs-container").find("ul.list").addClass("add-class-tabs-container-mobile");
		$("ul.list").find("li").addClass("add-class-list-mobile");
	} else{
		if($(".list").html()){
			var hidWidth;
			var scrollBarWidths = 40;

			var widthOfList = function(){
			  var itemsWidth = 0;
			  $('.list li').each(function(){
				var itemWidth = $(this).outerWidth();
				itemsWidth+=itemWidth;
			  });
			  return itemsWidth;
			};

			var widthOfHidden = function(){
			  return (($('.wrapper').outerWidth())-widthOfList()-getLeftPosi())-scrollBarWidths;
			};
		
			var getLeftPosi = function(){
				return $('.list').position().left;			
			};

			var reAdjust = function(){
			  if (($('.wrapper').outerWidth()) < widthOfList()) {
				$('.scroller-right').show();
			  }
			  else {
				$('.scroller-right').hide();
			  }
			  
			  if (getLeftPosi()<0) {
				$('.scroller-left').show();
			  }
			  else {
				$('.item').animate({left:"-="+getLeftPosi()+"px"},'slow');
				$('.scroller-left').hide();
			  }
			}

			reAdjust();

			$(window).on('resize',function(e){  
				reAdjust();
			});

			$('.scroller-right').click(function() {		  
			  $('.scroller-left').fadeIn('slow');
			  $('.scroller-right').fadeOut('slow');		  
			  $('.list').animate({left:"+="+widthOfHidden()+"px"},'slow',function(){});
			});

			$('.scroller-left').click(function() {		  
				$('.scroller-right').fadeIn('slow');
				$('.scroller-left').fadeOut('slow');		  
				$('.list').animate({left:"-="+getLeftPosi()+"px"},'slow',function(){});
			}); 
		}	
	}	

	$(".attachment-icon").on("click", toggleAttachIcons);
	
	function toggleAttachIcons(){
		$(".attachment-toggle-show").slideToggle("slow");
	}
	$('.attachment-toggle-show').click(function(e){
		e.stopPropagation();
	});
	
	$(document).click(function(e) {
		if(e.target.id!="attach-icon"){
			$('.attachment-toggle-show').slideUp(1000);
		}
	});
	$("ul.attachment-toggle-show label.attached-events").click(function(e){
		e.stopPropagation();
		e.preventDefault();
		$(this).parents('ul.attachment-toggle-show').find('input').prop('checked', false);
		$(this).find('input').prop('checked', true);
		$('.custom-file-input').trigger("click");
	});
	$("ul.attachment-toggle-show label.add-attached-events").click(function(e){
		$(".chat-show-tabs").find("li.custom-events").find("a").trigger("click");
	});

	$(".attendance-body ul li label").click(function(e){
		var elementCheckbox = $(this).find("input");
		if(elementCheckbox.is(':checked')){
			elementCheckbox.prop('checked', false);
			$('.present-student-count-span').html(parseInt($('.present-student-count-span').html())-1);
			$('.absent-student-count-span').html(parseInt($('.absent-student-count-span').html())+1);
		}else{
			elementCheckbox.prop('checked', true);
			$('.present-student-count-span').html(parseInt($('.present-student-count-span').html())+1);
			$('.absent-student-count-span').html(parseInt($('.absent-student-count-span').html())-1);
		}		
	});

	$('.search-attendance-input').on("keyup keydown", function() {
		
	    var value = $(this).val();
	    if(value){
	    	$(".student-in-attendance").hide().filter(function () {
				if($(".student-name-in-attendance", this).text().toLowerCase().indexOf(value.toLowerCase()) >= 0 || $(".student-roll-number", this).text().toLowerCase().indexOf(value.toLowerCase()) >= 0  ){					
					return true;
				}else{
					return false;
				}			    
			}).show();
	    }else{
	    	$(".student-in-attendance").show();
	    }    
	});
	
	$('.search-conversation-new-group').on("keyup keydown", function() {
	    var value = $(this).val();
	    if(value){
	    	$("ul.search-index-conversation-modal li").hide().filter(function () {
			    var mediaHeading = $(this).find(".media-heading");
				var roleSmall = $(this).find(".role-small");
				if(mediaHeading.text().toLowerCase().indexOf(value.toLowerCase()) >= 0 || roleSmall.text().toLowerCase().indexOf(value.toLowerCase()) >= 0 ){
					
					if(mediaHeading.parents('.class-students-list-custom').css("display") == "none"){
						mediaHeading.parents('.class-students-list-custom').css("display", "block");
					}
					return true;
				} else{
					return false;
				}
			}).show();
	    }else{
	    	$("ul.search-index-conversation-modal li").show();
			$('.class-tab-students-list-custom').css("display", "none");
	    }    
	});
	$('.search-conversation-new-page').on("keyup keydown", function() {
	    var value = $(this).val();
	    if(value){
	    	$("ul.index-conversation-modal li").hide().filter(function () {
			    if($(".media-heading", this).text().toLowerCase().indexOf(value.toLowerCase()) >= 0 || $(".role-small", this).text().toLowerCase().indexOf(value.toLowerCase()) >= 0 ){
					return true;
				} else{
					return false;
				}
			}).show();
	    }else{
	    	$("ul.index-conversation-modal li").show();
	    } 
	});
	$('.search-conversation-new-group-page').on("keyup keydown", function() {
	    var value = $(this).val();
	   if(value){
	    	$("ul.index-conversation-modal li").hide().filter(function () {
			    if($(".media-heading", this).text().toLowerCase().indexOf(value.toLowerCase()) >= 0 || $(".role-small", this).text().toLowerCase().indexOf(value.toLowerCase()) >= 0 ){
					return true;
				} else{
					return false;
				}
			}).show();
	    }else{
	    	$("ul.index-conversation-modal li").show();
	    } 
	});
	$(".open-contact-on-click-element").click(function(){
		if(!$(this).parents(".radio").html()){
			
			var imageModal = $("#imageModal");
			parent = $(this).parents('.open-contact-on-click-element-parent');
			name = $(parent).find('.media-heading-content').html();
			if($(parent).find(".media-heading-role").html()){
				name = name + " :- " + $(parent).find(".media-heading-role").html();
			}
			imageModal.find(".modal-body").html($(parent).find(".media-left").html());
			imageModal.find(".modal-title").html(name);
			imageModal.find(".modal-footer").html($(parent).find(".icon-short-profile-modal-main-div").html());
			imageModal.modal("show");
		}		
	});

	$('body').on('hidden.bs.modal', '#imageModal', function () {
		$(this).removeData('bs.modal').find(".modal-body").empty();
		$(this).removeData('bs.modal').find(".modal-title").empty();
		$(this).removeData('bs.modal').find(".modal-footer").empty();
	});

	$('.profile-pic-uploadBtn').on('change', function(event) {
		
		var files = event.target.files;
		var image = files[0]
		var clickedInput = $(this);
		if(image){
			var reader = new FileReader();
			reader.onload = function(file) {
			  var img = new Image();
			  img.src = file.target.result;
			  img.className = "custom-profile-image img-circle";
			  clickedInput.parents('.user-profile-picture-target').find('.user-profile-picture-inner-target').html(img);
			}
			reader.readAsDataURL(image);	
		}
		
	});

});

App.navigateToLink = function(linkElement){
	href = linkElement.attr("data-next-page-link-address");
	requestType = linkElement.attr("data-request-type");
	paramsJSONString =  '{' + linkElement.attr("data-request-params") + '}'
	
	if(requestType == "GET"){
		Turbolinks.visit(href);
	}else{
		params = {};
		if(paramsJSONString){
			params = jQuery.parseJSON(paramsJSONString);
		}
		$.ajax({
		    type: requestType,
		    url: href,
		    data: params,
		    beforeSend: function(data) {
				var csfrToken = $("meta[name='csrf-token']").attr("content");
				data.setRequestHeader('X-CSRF-Token', csfrToken);
			},
		    success: function(data, textStatus) {
		        if (data.redirect) {
		            // data.redirect contains the string URL to redirect to
		            window.location.href = data.redirect;
		        }
		        else {
		            eval(data);
		        }
		    }
		});
	}
}

App.openCalender = function(){
	$('.month-calendar-div').slideToggle("slow");
	if(!$('.calendar').html()){
		App.initialize_calendar();
	}

};

App.scrollToBottomOfPage = function(){
	$('html, body').animate({scrollTop:$(document).height()}, 'fast');
};

App.fetchEventForm = function(date, view){
	$.ajax({
	    url: "/events/new",
		success: function(data, textStatus) {
	    	
	    }
	});
}

App.checkWebNotificationServiceWorker = function (){
	App.currentUserId = $('meta[name="current-user-id"]').attr('content');
	if (App.currentUserId && App.hasSubscribedToWebNotifications == false && 'serviceWorker' in navigator) {
		navigator.serviceWorker.register('/web_notification_service_worker.js')  
		.then(App.initialiseWebNotificationWorkerState)
		.catch(function(error) {
			console.log("Registartion error: " + error);
			App.setWebNoyificationSubscriptionStatus(false);
		});
	}else {
		console.log('Chrome Service workers aren\'t supported in this browser.');  
	}

	if (App.currentUserId && App.hasSubscribedToWebNotifications == false && 'safari' in window && 'pushNotification' in window.safari) {
        var permissionData = window.safari.pushNotification.permission('web.push.in.classtalk');
        App.checkSafariPushPermission(permissionData);
    }
    else {
      	console.log('Safari Service workers aren\'t supported in this browser.');  
    }
};

App.initialiseWebNotificationWorkerState = function (registartion){
	if (!('showNotification' in ServiceWorkerRegistration.prototype)) {  
		console.warn('Notifications aren\'t supported.');  
		return;  
	}
	
	if (Notification.permission === 'denied') {  
		console.warn('The user has blocked notifications.');  
		Notification.requestPermission();
		return;  
	}

	// Check if push messaging is supported  
	if (!('PushManager' in window)) {  
		console.warn('Push messaging isn\'t supported.');  
		return;  
	}
	
	navigator.serviceWorker.ready.then(function(serviceWorkerRegistration) {
		serviceWorkerRegistration.pushManager.getSubscription()  
  		.then(function(subscription) {
			
			if (!subscription) {  
				
				serviceWorkerRegistration.pushManager.subscribe({ userVisibleOnly: true })
				.then(function(subscription) {
					App.sendWebNotificationSubscriptionToServer(subscription);
				});
			  // We aren't subscribed to push, so set UI  
			  // to allow the user to enable push  
			  return;  
			}
							
			App.sendWebNotificationSubscriptionToServer(subscription);
			
		});
	});
}

App.checkSafariPushPermission = function (permissionData) {
    if (permissionData.permission === 'default') {
        // This is a new web service URL and its validity is unknown.
        window.safari.pushNotification.requestPermission(
            'https://classtalk.in', // The web service URL.
            'web.push.in.classtalk',     // The Website Push ID.
            {user_id: App.currentUserId},
            App.checkSafariPushPermission          // The callback function.
        );
    }
    else if (permissionData.permission === 'denied') {
      // The user said no. Talk to your UX expert to see what you can do to entice your
      // users to subscribe to push notifications.
      //alert("push permission denied");
      App.setWebNoyificationSubscriptionStatus(false);
    }
    else if (permissionData.permission === 'granted') {
        // The web service URL is a valid push provider, and the user said yes.
        // permissionData.deviceToken is now available to use.
        //alert("The user said yes for push, with token: "+ permissionData.deviceToken);
        App.sendAppleWebNotificationSubscriptionToServer(permissionData.deviceToken);
        
    }
};

App.sendWebNotificationSubscriptionToServer = function(subscription){
	subscription = subscription.toJSON();
	csfrToken = $("meta[name='csrf-token']").attr("content");
	currentUserId = $("meta[name='current-user-id']").attr("content");
	if(currentUserId){
		$.ajax({
			url: "/web_notification_subscriptions.js",
			type: "POST",
			data: {
				user_id: currentUserId,
				endpoint: subscription.endpoint,
				p256dh: subscription.keys.p256dh,
				auth: subscription.keys.auth
			},
			beforeSend: function(data) {
				
				data.setRequestHeader('X-CSRF-Token', csfrToken);
			},
			success: function(data) {
				App.setWebNoyificationSubscriptionStatus(true);
			}
		});
	}
}

App.sendAppleWebNotificationSubscriptionToServer = function(deviceToken){
	
	csfrToken = $("meta[name='csrf-token']").attr("content");
	currentUserId = $("meta[name='current-user-id']").attr("content");
	if(currentUserId){
		$.ajax({
			url: '/v1/devices/' + deviceToken + '/registrations/web.push.in.classtalk',
			type: "POST",
			data: {
				user_id: currentUserId,
			},
			beforeSend: function(data) {
				
				data.setRequestHeader('X-CSRF-Token', csfrToken);
			},
			success: function(data) {
				App.setWebNoyificationSubscriptionStatus(true);  
			}
		});
	}
}


App.setWebNoyificationSubscriptionStatus = function(status){
	App.hasSubscribedToWebNotifications = status;
}

App.updateCheckboxCounter = function() {
	var len = $("input[name='participant_ids[]']:checked").length;	
	if(len>0){
		$(".checkbox-counter").text(len);
	}else{
		$(".checkbox-counter").text('Select');
	}
}

App.checkEmptyString = function(string) {
	if(string.length > 0) {
		return true
	} else {
		return false
	}
}

App.sendGCMRegistraionIdToBackend = function(){
	
	if(App.isAndroidNativeApp){
		
		androidGCMRegistrationId = Android.getAndroidGCMRegistratioId();
		
		notifyGCMRegistrationId(androidGCMRegistrationId);	
	}
}

App.sendIosDeviceTokenToBackend = function(){
	
	if(App.isIosNativeApp){
		try {
	        webkit.messageHandlers.getPushDeviceToken.postMessage("");
	    } catch(err) {
	        console.log('The native ios context does not exist yet');
	    }
	}
}

function notifyGCMRegistrationId(androidGCMRegistrationId){
	if(App.checkEmptyString(androidGCMRegistrationId)){
		
		currentUserId = $("meta[name='current-user-id']").attr("content");
		csfrToken = $('meta[name="csrf-token"]').attr('content');
		if(!currentUserId) {
			currentUserId = "";
		} 
			
		$.ajax({
			url: "/android_devices.js?gcm_registration_id="+androidGCMRegistrationId+"&current_user_id="+currentUserId,
			type: "POST",
			beforeSend: function(data) {
				data.setRequestHeader('X-CSRF-Token', csfrToken);
			},
			success: function(data) {
				
			}
		});
	}
	return;
}

function notifyIosDeviceToken(deviceToken){
	if(App.checkEmptyString(deviceToken)){
		deviceToken = deviceToken.slice(1, -1);
		currentUserId = $("meta[name='current-user-id']").attr("content");
		csfrToken = $('meta[name="csrf-token"]').attr('content');
		if(!currentUserId) {
			currentUserId = "";
		} 
			
		$.ajax({
			url: "/ios_devices.js?ios_device_token="+deviceToken+"&current_user_id="+currentUserId,
			type: "POST",
			beforeSend: function(data) {
				data.setRequestHeader('X-CSRF-Token', csfrToken);
			},
			success: function(data) {
				
			}
		});
	}
	
	return;
}


App.showAndroidToast = function(toast) {
	if(App.isAndroidNativeApp){
		Android.showToast(toast);
	}else{
		$(".alert span").html(message);
		$(".alert").delay(2000).slideUp(200, function() {
			$(this).alert('close');
		});
	}
}

App.saveCurrentUrlOnAndroid = function(){
	if(App.isAndroidNativeApp){
		currentUrlRelativePath = window.location.href;
		Android.setCurrentUrl(currentUrlRelativePath);
	}
}
App.shareOnAndroidFromWeb = function(textToShare, targetUrl, imageUrl, imageFileName) {
	if(App.isAndroidNativeApp){
		Android.shareOnAndroid(textToShare, targetUrl, imageUrl, imageFileName);		
	}
}
App.getContactNoDetailsFromAndroid = function(){
	if(App.isAndroidNativeApp){
		Android.getContactNoDetail();	
	}
}
App.openImageInAndroid = function(file_name, image_url){
	if(App.isAndroidNativeApp){
		Android.openImage(file_name, image_url);	
	}
}

function getSelectedContactNoFromAndroid(name, contact_no){
	
	nameArray = name.split(' ');
	var firstName = nameArray[0];
	var lastName = "";
	if(nameArray.length > 1) lastName = nameArray[nameArray.length - 1];
	
	contactNoArray = contact_no.trim().replace(/\D/g, '').split('');
	
	var isdCode = "";
	var contactNo = "";
	
	length = contactNoArray.length;
	
	for(i=length-1; i>=length-10; i--){
		contactNo = contactNo + contactNoArray[i];
	}
	contactNo = contactNo.split("").reverse().join("");
	
	for(i=0;i<length-10; i++){
		isdCode = isdCode + contactNoArray[i];
	}
	if(isdCode == "" || isdCode == "0"){
		isdCode = "91";
	}
	
	App.scrollToBottomOfPage();
	
}

App.initialize_calendar = function() {
  $('.calendar').each(function(){
    var calendar = $(this);
    calendar.fullCalendar({
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'month,agendaWeek,agendaDay'
      },
      defaultView: "agendaWeek",
      firstDay: 1,
      slotDuration: "01:00:00",
      scrollTime: "07:00:00",
      eventSources: [
      	{	
      		googleCalendarApiKey: 'AIzaSyBygb2VxPHEs8rV8j7dgreRvpowydmGrow',
		   	url: 'https://www.google.com/calendar/feeds/indian__en%40holiday.calendar.google.com/public/basic',

		    color: 'red',   // an option!
		    textColor: 'black' // an option!
		},
		{
		    url: '/events',
		    color: 'blue',   // an option!
		    textColor: 'black' // an option!
		}

      ],
      editable: true,
      selectable: true,
      selectHelper: true,
      eventClick: function(event, jsEvent, view) {
      		if(event.edit_url){
      			$.ajax({
		        	url: event.edit_url,
		        	complete: function(data){
		        		if(data.status == "200"){
		        			eval(data.responseText);
		        		}
		        	}
		        });
      		}else{
      			window.open(event.url);
      		}
            
	        return false;
      },
      dayClick: function(date, jsEvent, view) {
      	$.ajax({
        	url: "events/new.js?start_time= " + date.format() + '&end_time= ' + date.format(),
        	complete: function(data){
        		if(data.status == "200"){
        			eval(data.responseText);
        		}
        	}
        });
      },
      select: function(start, end) {
        $.ajax({
        	url: "events/new.js?start_time=" + start.format() + '&end_time=' + end.format(),
        	complete: function(data){
        		if(data.status == "200"){
        			eval(data.responseText);
        		}
        	}
        });

        calendar.fullCalendar('unselect');
      },
      eventDrop: function(event,dayDelta,minuteDelta,allDay,revertFunc) {
      	if(event.update_url){
      		if (confirm("update this event?")) {
	          	$.ajax({
	      			url: event.update_url + "&start_time=" + event.start.format() + "&end_time=" + event.end.format(),
		      		method: "PATCH",
		        	complete: function(data){
		        		if(data.status == "200"){
		        			eval(data.responseText);
		        		}
		        	}	
	      		});
	        }
      		
      		
      	}else{

      	}
      },
      eventResize: function(event, delta, revertFunc) {
	    if(event.update_url){
	    	if (confirm("update this event?")) {
	          	$.ajax({
	      			url: event.update_url + "&start_time=" + event.start.format() + "&end_time=" + event.end.format(),
		      		method: "PATCH",
		        	complete: function(data){
		        		if(data.status == "200"){
		        			eval(data.responseText);
		        		}
		        	}	
	      		});
	        }
      		
      	}else{
      		
      	} 
	        

	  }
  	});
  });  
};
