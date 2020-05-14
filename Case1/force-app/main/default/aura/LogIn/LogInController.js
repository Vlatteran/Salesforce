({
    login : function(component, event, helper) {
        console.log("login");
        var getUser = component.get("c.logIn");
        getUser.setParams({'user':component.get("v.user")})
        getUser.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var logInResult = JSON.parse(response.getReturnValue());
                var user = logInResult.user;
                console.log(user);
                console.log(logInResult.cart);
                console.log(logInResult.cards);
                console.log(logInResult.orders);
                if (user.Name !== ""){
                    console.log("success")
                    var loginEvent = component.getEvent("login");
                    loginEvent.setParams({ "user": user });
                    loginEvent.setParams({ "cart": logInResult.cart });
                    loginEvent.setParams({ "cards": logInResult.cards });
                    loginEvent.setParams({ "orders": logInResult.orders });
                    loginEvent.fire();
                }
            }else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(getUser);
    }
})