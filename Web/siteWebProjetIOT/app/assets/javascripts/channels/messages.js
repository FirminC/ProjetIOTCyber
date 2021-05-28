App.messages = App.cable.subscriptions.create("MessagesChannel", {
  connected: function() {
    console.log("Connected to the WebSocket");
    // document.getElementById("messages_sender").addEventListener('keydown', function(event) {
    //   if (event.keyCode === 13){
    //     App.messages.speak(event.target.value);
    //     event.target.value = "";
    //     event.preventDefault();
    //   }
    // });
  },
  disconnected: function() {
    console.log("Disconnected from the WebSocket");
  },
  received: function(data) {
    var p = document.createElement("p")
    p.innerHTML = data.message;
    document.getElementById("js-messages").appendChild(p)
  },
  speak: function(message) {
    this.perform('speak', { "message": message });
  }
});