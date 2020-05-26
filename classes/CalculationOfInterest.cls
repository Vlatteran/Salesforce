public with sharing class CalculationOfInterest implements Schedulable{
    public void execute(SchedulableContext param1) {
        List<Card__c> cards = null;
        cards = [SELECT Id, Amount__c, Bank__r.Interest__c FROM Card__c];
        for(Card__c card : cards){
            card.Amount__c += card.Amount__c * (card.Bank__r.Interest__c /100);
        }
        update cards;
    }
}