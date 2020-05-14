({
	register : function(component, event, helper) {
		console.log("register");
        var newUser = component.get("v.newUser");
        if(newUser.Password__c === component.get("v.confirmPassword")){
        	newUser = component.get("c.newUser");
            newUser.setParams({'user':component.get("v.newUser")})
			newUser.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var user = [];
                user.push(response.getReturnValue());
                console.log(user);
                if (user.Name !== ""){
                    console.log("success")
                    var loginEvent = component.getEvent("login");
                    loginEvent.setParams({ "user": user });
                    loginEvent.fire();
                }
            }else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(newUser);
        }
	}
})