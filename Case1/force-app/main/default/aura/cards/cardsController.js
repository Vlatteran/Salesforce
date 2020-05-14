({
	updeteCards : function(component, event, helper) {
		var cards = event.getSource().get("v.cards");
        component.set("v.cards", cards);
        console.log("handled by card");
        console.log(component.get("v.cards"));
	}
})