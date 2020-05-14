({
    addToCartClick : function(component, event, helper) {
        if(component.get("v.inCart")) return;
        component.set("v.inCart", true);
        var addToCart = component.get("c.addToCart");
        var user = component.get("v.user");
        var toParse = '{"type" : "Cart__c", "Quantity__c" : 1, "User__c" : "' + user.Id + '", "Product__c" : "' + component.get("v.product").Id +'"}';
        var toUpsert = JSON.parse(toParse);
        addToCart.setParams({'toUpsert' : toParse,
                             'user' : JSON.stringify(user)});
        addToCart.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var cart = response.getReturnValue();
                component.set("v.cart", cart)
                var cartUpdate = component.getEvent("cartUpdate");
                cartUpdate.setParams({ "cart": cart });
                cartUpdate.fire();
            }else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(addToCart);
    },
    
    isInCart : function(component, event, helper){
        var product = component.get("v.product.Id");
        var cart = component.get("v.cart");
        var cartId = [];
        for (var i = 0; i < cart.length; i++){
            cartId.push(cart[i].Product__r.Id);
        }
        if (cartId.indexOf(product) !== -1){
            component.set("v.InCart", true);
        } else { 
            component.set("v.InCart", false);
        }
    },
    
    updateCart : function(component, event, helper){
        console.log("CartUpdate handled by shpoItem")
        var cart = event.getSource().get("v.cart");
		component.set("v.cart", cart);        
    }
    
})