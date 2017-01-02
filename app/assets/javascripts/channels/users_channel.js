$(document).on("turbolinks:load", function(){
	var currentUserId = $('meta[name="current-user-id"]').attr('content');
	if(currentUserId && !App.isChannelSubscribed("UsersChannel", {user_id: currentUserId})){
		//alert("subscribing to user channel: " + currentUserId);
		App.subscribe_to("UsersChannel", {user_id: currentUserId});
	}
});

