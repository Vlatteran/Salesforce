({
	applyFilters : function(component, event, helper) {
        var filtersToApply = component.get("v.filtersToApply");
        console.log(filtersToApply);
        if (filtersToApply.length === 0){
            var getProducts = component.get("c.getProducts");
        }else{
            var getProducts = component.get("c.getProduct");
            getProducts.setParams({"filters" : filtersToApply});
        }
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
        $A.enqueueAction(getProducts);
	},
    
    addFilterToApply : function(component, event, helper){
        var name = event.getSource().get("v.name")
        var checked = event.getSource().get("v.checked")
        var filtersToApply = component.get("v.filtersToApply")
        console.log(name + " " + checked);
        if (checked){
            filtersToApply.push(name);
        }else{
            filtersToApply.splice(filtersToApply.indexOf(name), 1);
        }
        console.log(component.get("v.filtersToApply"));
    }
})