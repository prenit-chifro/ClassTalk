$(document).on("turbolinks:load", function(){
	var currentUserId = $('meta[name="current-user-id"]').attr('content');

	if(currentUserId && !App.isChannelSubscribed("UsersChannel", {user_id: currentUserId})){
		App.subscribe_to("UsersChannel", {user_id: currentUserId});
	}
});

