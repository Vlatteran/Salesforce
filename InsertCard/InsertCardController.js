/**
 * Created by Hacker on 20.05.2020.
 */

({
    init : function(component, event, helper) {
		var getATMs = component.get("c.getATMs");
        getATMs.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var getATMsResponse = response.getReturnValue();
                if (getATMsResponse !== "Some problem"){
                    var ATMs  = JSON.parse(getATMsResponse);
                    component.set("v.ATMs", ATMs);
                }
            }else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(getATMs);
	},

	confirmClick : function(component, event, helper){
	    var ATM = component.find("selectATM").get("v.value");
        if(ATM === "Choose ATM"){
            alert("Choose ATM");
            return;
        }
	    var card = component.get("v.card");
	    var cardJSON = JSON.stringify(card);
	    var getCard = component.get("c.getCard");
	    getCard.setParams({'cardJSON' : cardJSON});
        getCard.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var getCardResponse = response.getReturnValue();
                if (!(getCardResponse === "Error" || getCardResponse === "Incorrect PIN or Number")){
                    var card  = JSON.parse(getCardResponse);
                    var ATMs = component.get("v.ATMs");
                        for(var i = 0; i < ATMs.length; i++){
                            if (ATMs[i].Bank__r.Name === ATM){
                                ATM = ATMs[i];
                                break;
                            }
                        }
                    var changeLocation = component.getEvent("ChangeLocation");
                    changeLocation.setParams({'location' : 'mainMenu'});
                    changeLocation.fire();
                    var cardInserted = component.getEvent("CardInserted");
                    cardInserted.setParams({'card' : card});
                    cardInserted.setParams({'ATM' : ATM});
                    cardInserted.fire();
                }else{
                    alert(getCardResponse)
                }
            }else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(getCard);
	}
});