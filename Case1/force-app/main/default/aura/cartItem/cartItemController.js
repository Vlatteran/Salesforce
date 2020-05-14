({
	changeQuantity : function(component, event, helper) {
		var action = event.getSource().get("v.label");
        var quantity = parseInt(component.get("v.product.Quantity__c"));
        if (action === "+"){
            quantity++;
        }else if(action === "-"){
            if(quantity !== 1){
                quantity--;
            }
        }else if(action === "delete"){
            quantity = 0;
        }
        component.set("v.product.Quantity__c", quantity)
	}
})