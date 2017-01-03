//= require cable
//= require_self
//= require_tree .

this.App || (this.App = {});

App.cable = ActionCable.createConsumer();  
App.subscriptions = [];

App.subscribe_to = function(channel, params){
		
	params["channel"] = channel;
	var newSubscription = {params: params};
	App.subscriptions.push(newSubscription);
	
	var ServerSubscriptionCallback = App.cable.subscriptions.create(params, {  
	  received: function(data) {	
		eval(data.published_script);
	  },
	  connected: function(){
		  
	  },
	  disconnected: function(){
		  
	  },
	  rejected: function(){
		 this.unsubscribe();
	  }
	});	
}

App.isChannelSubscribed = function(channel, params){
	
	params["channel"] = channel;
	for(i=0; i< App.subscriptions.length;i++){
		if(App.subscriptions[i]){
			
			for (var key in App.subscriptions[i].params) {
			  if (params.hasOwnProperty(key) && params[key] == App.subscriptions[i].params[key]) {
				
				return true;

			  }
			}
			
		}
		
	}
	return false;
}