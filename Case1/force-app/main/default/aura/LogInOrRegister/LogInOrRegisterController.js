({
	register : function(component, event, helper) {
		console.log("register");
        var newUser = component.get("v.newUser");
        console.log(newUser.Email__c);
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
                    component.set("v.user", user);
                    var parent = component.get("v.parent");
                    parent.set("v.user", user)
                }
            }else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(newUser);
        }
	},
    
    login : function(component, event, helper) {
		console.log("login");
        var getUser = component.get("c.getUser");
        getUser.setParams({'user':component.get("v.user[0]")})
        getUser.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var user = [];
                user.push(response.getReturnValue());
                console.log(user);
                if (user.Name !== ""){
                    console.log("success")
                    component.set("v.user", user);
                    var parent = component.get("v.parent");
                    parent.set("v.user", user)
                }
            }else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(getUser);
	}
})