({
    login : function(component, event, helper) {
        component.set("v.user", event.getParam("user"));
        component.set("v.cart", event.getParam("cart"));
        component.set("v.isLogged", !component.get("v.isLogged"));
        console.log("handled by body");
    }
})