({
    doInit : function(component, event, helper) {
        var getProducts = component.get("c.getProducts");
        var getCategories = component.get("c.getCategories");
        // Add callback behavior for when response is received
        getProducts.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set("v.productList", response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        getCategories.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set("v.categoryList", response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        // Send action off to be executed
        $A.enqueueAction(getProducts);
        $A.enqueueAction(getCategories);
    }
})