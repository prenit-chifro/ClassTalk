function onPush(event) {
	if(event.data){
		var webNotification = event.data.json();
		event.waitUntil(
		self.registration.showNotification(webNotification.title, {
		  body: webNotification.body,
		  icon: webNotification.icon,
		  tag:  "ClassNest-web-notification-tag-" + webNotification.id,
		  data: {targetUrl: webNotification.target_url},
		  vibrate: [400, 200, 400]
		})
	  );
	}
}

self.addEventListener("push", onPush);

self.addEventListener('notificationclick', function(event) {  
  // Android doesn't close the notification when you click on it  
  // See: http://crbug.com/463146  
  var targetUrl = event.notification.data.targetUrl;
  event.notification.close();

  // This looks to see if the current is already open and  
  // focuses if it is  
  event.waitUntil(
    clients.matchAll({  
      type: "window"  
    })
    .then(function(clientList) {  
      for (var i = 0; i < clientList.length; i++) {  
        var client = clientList[i];  
		
        if (client.url == targetUrl && 'focus' in client)  {
			return client.focus();  
		}
      }  
      if (clients.openWindow) {
        return clients.openWindow(targetUrl);  
      }
    })
  );
});