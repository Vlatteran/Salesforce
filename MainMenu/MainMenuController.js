/**
 * Created by Hacker on 20.05.2020.
 */

({
    showBalance : function(component, event, helper){
        component.set("v.showBalance", !component.get("v.showBalance"));
    },

    commissionCount : function(component, event, helper){
        var transaction = component.get("v.transaction");
        if (component.get("v.card").Bank__r.Name !== component.get("v.ATM").Bank__r.Name){
            var commission = component.get("v.ATM.Bank__r.Commission__c");
            transaction.Commission__c = parseFloat(transaction.Amount__c) * parseFloat(commission) / 100;
        }
        component.set("v.transaction", transaction);
    },

    totalCount : function(component, event, helper){
        var transaction = component.get("v.transaction");
        var rate = parseFloat(component.get("v.rate"));
        component.set("v.total", (parseFloat(transaction.Amount__c) + parseFloat(transaction.Commission__c)) * rate)
    },

    changeCurrency: function (component, event, helper) {
     var currency = component.find('selectCurrency').get('v.value');
     var transaction = component.get("v.transaction");
     transaction.Currency__c = currency;
     switch (currency){
        case "RUB":
            component.set("v.rate", 1);
            break;
        case "USD":
            component.set("v.rate", component.get("v.card.Bank__r.USDRate__c"));
            break;
        case "BYN":
            component.set("v.rate", component.get("v.card.Bank__r.BYR__c"))
     }
     component.set("v.transaction", transaction);
    },

    withdrawCash: function (component, event, helper) {
        var transaction = component.get("v.transaction");
        var ATM = component.get("v.ATM");
        var card = component.get("v.card");
        transaction.ATM__c = ATM.Id;
        transaction.Card__c = card.Id;
        if(transaction.Amount__c < 10){
            alert("Amount must be more then 10");
            return
        }else{
            switch (transaction.Currency__c){
                case "RUB":
                    if (transaction.Amount__c > ATM.Amount__c){
                        alert("Not enough RUB in ATM");
                        return;
                    }
                    break;
                case "USD":
                    if (transaction.AmountUSD__c > ATM.Amount__c){
                        alert("Not enough RUB in ATM");
                        return;
                    }
                    break;
                case "BYN":
                    if (transaction.AmountBYN__c > ATM.Amount__c){
                        alert("Not enough BYN in ATM");
                        return;
                    }
            }
        }
        transaction.Given__c = transaction.Amount__c;
        transaction.Amount__c = component.get("v.total");
        if(card.Amount__c + card.CreditLimit__c < transaction.Amount__c + transaction.Commission__c){
            alert("Not enough money on your card");
            return;
        }
        var transactionJSON = JSON.stringify(transaction);
        var insertTransaction = component.get("c.insertTransaction");
        insertTransaction.setParams({'transactionJSON' : transactionJSON});
        insertTransaction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                alert('You have withdrawn ' + transaction.Given__c + ' ' + transaction.Currency__c + '\n'+ transaction.Amount__c +'RUB were deducted from your account')
                var getATMsResponse = response.getReturnValue();
                card = JSON.parse(getATMsResponse[0]);
                ATM = JSON.parse(getATMsResponse[1]);
                var cardInserted = component.getEvent("CardInserted");
                cardInserted.setParams({'card' : card});
                cardInserted.setParams({'ATM' : ATM});
                cardInserted.fire();
                component.set("v.transaction", {'type' : 'Transaction__c', 'Amount__c' : 0.00, 'Commission__c' : 0.00, 'Currency__c' : 'RUB', 'ATM__c' : '', 'Card__c' : ''})
            }else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(insertTransaction);
    },

    exit : function(component, event, helper){
        var changeLocation = component.getEvent("ChangeLocation");
        changeLocation.setParams({'location' : 'insertCard'});
        changeLocation.fire();
    }

});