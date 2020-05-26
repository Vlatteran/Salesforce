({
    changeLocation : function(component, event, helper){
        var location = event.getParam("location");
        component.set("v.location", location);
    },

    cardInserted : function(component, event, helper){
            var card = event.getParam("card");
            var ATM = event.getParam("ATM")
            component.set("v.card", card);
            component.set("v.ATM", ATM);
        }
})