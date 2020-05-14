/*createComponentController.js*/
({
    login : function(component, event, helper) {
        console.log("login success, showing user")
        component.set("v.user", event.getParam("user"));
        component.set("v.orders", event.getParam("orders"));
        component.set("v.cards", event.getParam("cards"));
        component.set("v.isLogged", !component.get("v.isLogged"));
        console.log("Handled by user");
        console.log(component.get("v.cards[0].Name"))
    }
})