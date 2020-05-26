@IsTest
public with sharing class CalculationOfInterestTest {

    @IsTest
    private static void executePosTest(){
        ATMController_Tests.loadTestData();
        List<Card__c> cardsBefore = [SELECT Id, Amount__c, Bank__r.Interest__c FROM Card__c];
        for(Card__c card: cardsBefore){
            card.Amount__c *= (card.Bank__r.Interest__c /100 + 1);
        }
        String cronExp = '0 0 20 * * ? 2020';
        CalculationOfInterest calculationOfInterest = new CalculationOfInterest();
        Test.startTest();
        System.schedule('Test',cronExp, calculationOfInterest);
        Test.stopTest();
        List<Card__c> cardsAfter = [SELECT Id, Amount__c, Bank__r.Interest__c FROM Card__c];
        for(Card__c cardB : cardsBefore){
            for(Card__c cardA : cardsAfter){
                if (cardA.Id == cardB.Id){
                    System.assertEquals(cardB.Amount__c, cardA.Amount__c);
                }
            }
        }
    }

    @IsTest
    private static void executeNegTest(){
        List<Card__c> cardsBefore = [SELECT Id, Amount__c, Bank__r.Interest__c FROM Card__c];
        for(Card__c card: cardsBefore){
            card.Amount__c *= (card.Bank__r.Interest__c /100 + 1);
        }
        String cronExp = '0 0 20 * * ? 2020';
        CalculationOfInterest calculationOfInterest = new CalculationOfInterest();
        Test.startTest();
        System.schedule('Test',cronExp, calculationOfInterest);
        Test.stopTest();
        List<Card__c> cardsAfter = [SELECT Id, Amount__c, Bank__r.Interest__c FROM Card__c];
        for(Card__c cardB : cardsBefore){
            for(Card__c cardA : cardsAfter){
                if (cardA.Id == cardB.Id){
                    System.assertEquals(cardB.Amount__c, cardA.Amount__c);
                }
            }
        }
    }
}