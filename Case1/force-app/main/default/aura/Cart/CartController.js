({
	saveChanges : function(component, event, helper) {
        var cart = component.get("v.cart");
		console.log(cart);
        var action = component.get("c.upCart");
        var toUpdate = new Map();
        //toUpdate.set("type", "Cart__c");
        for (var i = 0; i < cart.length; i++){
            toUpdate.set(cart[i].Id, cart[i].Quantity__c);
        }
        var stringToUpdate = '';
        var i = 0;
        for(var x of toUpdate){
            stringToUpdate += '{"type":"Cart__c", "ID" : "' + x[0] + '", "Quantity__c" : ' + x[1] + '} , ';
            i++;
        }
        stringToUpdate = stringToUpdate.substring(0, stringToUpdate.length - 3);
        stringToUpdate += '';
        console.log(stringToUpdate);
        action.setParams({
                                  'toUpdate' : stringToUpdate,
                                  'user': cart[0].User__c});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var cart = response.getReturnValue();
                console.log(cart);
                component.set("v.cart", cart)
                console.log(component.get("v.cart"))
                var cartUpdate = component.getEvent("cartUpdate");
                cartUpdate.setParams({ "cart": cart });
                cartUpdate.fire();
            }else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
	},
    
    changeCart : function(component, event, helper) {
		var cart = component.get("v.cart");
        try{
            var total = 0;
            for (var x = 0; x < cart.length; x++){
                total += cart[x].Product__r.Price__c * cart[x].Quantity__c;
            }
        component.set("v.total", total);
        }catch(Exception){
            console.log(Exception);
        }
        console.log("handled by cart");
	},
    oldCart : function(component, event, helper) {
        var action = component.get("c.getCart");
        var user = JSON.parse('{"type" : "User__c", "Id" : "' + component.get("v.cart")[0].User__c + '"}');
        action.setParams({"user" : user});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var cart = response.getReturnValue();
                console.log(cart);
                component.set("v.cart", cart);
                console.log(component.get("v.cart"));
            }else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    }
})