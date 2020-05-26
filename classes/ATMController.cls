public with sharing class ATMController {
    @AuraEnabled
    public static String getATMs() {
        List<ATM__c> banks;
        banks = [SELECT Name, Bank__r.Commission__c, Bank__r.Name, AmountUSD__c, AmountBYN__c, Amount__c FROM ATM__c];
        if (banks.size() != 0) {
            return JSON.serialize(banks);
        } else {
            return 'Some problem';
        }
    }

    @AuraEnabled
    public static String getCard(String cardJSON) {
        Card__c card = (Card__c) JSON.deserialize(cardJSON, Card__c.class);
        System.debug(cardJSON);
        List<Card__c> getCard = null;
        getCard = [SELECT Id,
                Amount__c,
                PIN__c,
                Number__c,
                Bank__r.Name,
                Bank__r.USDRate__c,
                Bank__r.BYR__c,
                Credit__c,
                CreditLimit__c
        FROM Card__c
        ];
        if (getCard.size() != 0) {
            for (Card__c x : getCard) {
                if (x.Number__c == card.Number__c && x.PIN__c == card.PIN__c) {
                    x.PIN__c = '';
                    return JSON.serialize(x);
                }
            }
            return 'Incorrect PIN or Number';
        }else{
            return 'Error';
        }
    }

    @AuraEnabled
    public static String[] insertTransaction(String transactionJSON) {
        Transaction__c transact = null;
        Card__c card = null;
        ATM__c ATM = null;
        try {
            transact = (Transaction__c) JSON.deserialize(transactionJSON, Transaction__c.class);
        } catch (Exception e) {
            return (new String[]{
                    'Problems with transactionJSON'
            });
        }
        try {
            card = [SELECT Id, Amount__c, Bank__r.USDRate__c, Bank__r.BYR__c, Bank__r.Name,
                    Credit__c,
                    CreditLimit__c FROM Card__c WHERE Id = :transact.Card__c];
            ATM = [SELECT Id, Amount__c, AmountUSD__c, AmountBYN__c, Bank__r.Name, Bank__r.Commission__c, Name FROM ATM__c WHERE Id = :transact.ATM__c];
        }catch (Exception e) {
            return(new String[]{
                    'Something went wrong'
            });
        }
        if(card.Amount__c + card.CreditLimit__c < transact.amount__c){
            return(new String[]{
                    'Not enough money on your card'
            });
        }
        card.Amount__c -= transact.amount__c;
        switch on transact.Currency__c {
            when 'RUB' {
                if(ATM.Amount__c < transact.amount__c){
                    return(new String[]{
                            'Not enough RUB in ATM'
                    });
                }
                ATM.Amount__c -= transact.amount__c;
            }
            when 'USD' {
                if(ATM.AmountUSD__c < transact.amount__c){
                    return(new String[]{
                            'Not enough USD in ATM'
                    });
                }
                ATM.AmountUSD__c -= transact.amount__c / card.Bank__r.USDRate__c;
            }
            when 'BYN' {
                if(ATM.AmountBYN__c < transact.amount__c){
                    return(new String[]{
                            'Not enough BYN in ATM'
                    });
                }
                ATM.AmountBYN__c -= transact.amount__c / card.Bank__r.BYR__c;
            }
        }
        update card;
        update ATM;
        insert transact;
        return(new String[]{
                JSON.serialize(card), JSON.serialize(ATM)
        });
    }
}