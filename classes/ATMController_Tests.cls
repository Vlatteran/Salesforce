/**
 * Created by Hacker on 24.05.2020.
 */

@IsTest
public class ATMController_Tests {

    public static void loadTestData(){
        List<Bank__c> banks = new List<Bank__c>();
        List<User__c> users = new List<User__c>();
        List<ATM__c> ATMs = new List<ATM__c>();
        List<Card__c> cards = new List<Card__c>();
        users.add(new User__c(Name = 'Vlad', Email__c = 'soboleff@mail.ru'));
        users.add(new User__c(Name = 'Andew' , Email__c = 'sobolefAM98@mai.ru'));
        banks.add(new Bank__c(Name = 'Sberbank', BYR__c = 30, USDRate__c = 70, Interest__c = 0, Commission__c = 0));
        banks.add(new Bank__c(Name = 'Recetbank', BYR__c = 30, USDRate__c = 70, Interest__c = 0, Commission__c = 0));
        insert banks;
        insert users;
        banks = [SELECT Id FROM Bank__c];
        users = [SELECT Id FROM User__c];
        ATMs.add(new ATM__c(Name = 'Sberkomat', AmountBYN__c = 200000, AmountUSD__c = 50000, Amount__c = 1000000, Bank__c = banks[0].Id));
        ATMs.add(new ATM__c(Name = 'Rocetkomat', AmountBYN__c = 200000, AmountUSD__c = 50000, Amount__c = 1000000, Bank__c = banks[1].Id));
        cards.add(new Card__c(Name = 'VladCard', Amount__c = 50000, PIN__c = '1234', Number__c = '1234123412341234', Owner__c = users[0].Id, Bank__c = banks[0].Id, CreditLimit__c = 0));
        cards.add(new Card__c(Name = 'AndrewCard', Amount__c = 50000, PIN__c = '1234', Number__c = '4321432143214321', Owner__c = users[1].Id, Bank__c = banks[0].Id, CreditLimit__c = 0));
        insert ATMs;
        insert cards;
    }

    @IsTest
    private static void getATMsPosTest() {
        loadTestData();
        Test.startTest();
        String result = ATMController.getATMs();
        String expected = JSON.serialize([SELECT Name, Bank__r.Commission__c, Bank__r.Name, AmountUSD__c, AmountBYN__c, Amount__c FROM ATM__c]);
        System.assertEquals(expected, result);
        Test.stopTest();
    }

    @IsTest
    private static void getATMsNegTest(){
        Test.startTest();
        String result = ATMController.getATMs();
        String expected = 'Some problem';
        System.assertEquals(expected, result);
        Test.stopTest();
    }

    @IsTest
    private static void getCardsPosTest(){
        loadTestData();
        Test.startTest();
        String expected;
        List<Card__c> getCard =[
                SELECT Id,
                        Amount__c,
                        PIN__c,
                        Number__c,
                        Bank__r.Name,
                        Bank__r.USDRate__c,
                        Bank__r.BYR__c,
                        Credit__c,
                        CreditLimit__c
                FROM Card__c];
        for (Card__c x : getCard) {
            if (x.Number__c == '1234123412341234') {
                x.PIN__c = '';
                expected = JSON.serialize(x);
            }
        }
        String result = ATMController.getCard(JSON.serialize(new Card__c(Number__c = '1234123412341234', PIN__c = '1234')));
        System.assertEquals(expected, result);
        Test.stopTest();
    }

    @IsTest
    private static void getCardsNegTest1(){
        Test.startTest();
        String result = ATMController.getCard(JSON.serialize(new Card__c(Number__c = '1234123412341234', PIN__c = '1234')));
        System.assertEquals('Error', result);
        Test.stopTest();
    }

    @IsTest
    private static void getCardsNegTest2(){
        loadTestData();
        Test.startTest();
        String result = ATMController.getCard(JSON.serialize(new Card__c(Number__c = '123412341', PIN__c = '1234')));
        System.assertEquals('Incorrect PIN or Number', result);
        Test.stopTest();
    }

    @IsTest
    private static void getCardsNegTest3(){
        loadTestData();
        Test.startTest();
        String result = ATMController.getCard(JSON.serialize(new Card__c(Number__c = '1234123412341234', PIN__c = '5465')));
        System.assertEquals('Incorrect PIN or Number', result);
        Test.stopTest();
    }

    @IsTest
    private static void insertTransactionPosTest1(){
        Transaction__c transact = new Transaction__c();
        loadTestData();
        Card__c card;
        for (Card__c x : [SELECT Id, Name, Number__c, Amount__c FROM Card__c]) {
            if (x.Number__c == '1234123412341234') {
                transact.Card__c = x.Id;
                card = x;
                break;
            }
        }
        ATM__c ATM;
        for (ATM__c x : [SELECT Id, Name, Amount__c FROM ATM__c]) {
            if (x.Name == 'Sberkomat') {
                transact.ATM__c = x.Id;
                ATM = x;
                break;
            }
        }
        transact.Given__c = 1000.00;
        transact.Currency__c = 'RUB';
        transact.amount__c = 1000.00;

        Test.startTest();
        ATMController.insertTransaction(JSON.serialize(transact));
        List<Transaction__c> result = [SELECT Currency__c, ATM__c, Card__c, amount__c, Given__c FROM Transaction__c];
        transact.Id = result.get(0).Id;
        System.assertEquals(transact, result.get(0));
        System.assertEquals((card.Amount__c - 1000), [SELECT Id, Amount__c FROM Card__c WHERE Id =:transact.Card__c].Amount__c);
        System.assertEquals((ATM.Amount__c - 1000), [SELECT Id, Amount__c FROM ATM__c WHERE Id =:transact.ATM__c].Amount__c);
        Test.stopTest();
    }

    @IsTest
    private static void insertTransactionPosTest2(){
        Transaction__c transact = new Transaction__c();
        loadTestData();
        Card__c card;
        for (Card__c x : [SELECT Id, Name, Number__c, Amount__c FROM Card__c]) {
            if (x.Number__c == '1234123412341234') {
                transact.Card__c = x.Id;
                card = x;
                break;
            }
        }
        ATM__c ATM;
        for (ATM__c x : [SELECT Id, Name, AmountUSD__c FROM ATM__c]) {
            if (x.Name == 'Sberkomat') {
                transact.ATM__c = x.Id;
                ATM = x;
                break;
            }
        }
        transact.Given__c = 100.00;
        transact.Currency__c = 'USD';
        transact.amount__c = 100.00 * 70;



        Test.startTest();
        ATMController.insertTransaction(JSON.serialize(transact));
        List<Transaction__c> result = [SELECT Currency__c, ATM__c, Card__c, amount__c, Given__c FROM Transaction__c];
        transact.Id = result.get(0).Id;
        System.assertEquals(transact, result.get(0));
        System.assertEquals((card.Amount__c - 100*70), [SELECT Id, Amount__c FROM Card__c WHERE Id =:transact.Card__c].Amount__c);
        System.assertEquals((ATM.AmountUSD__c - 100), [SELECT Id, AmountUSD__c FROM ATM__c WHERE Id =:transact.ATM__c].AmountUSD__c);
        Test.stopTest();
    }

    @IsTest
    private static void insertTransactionPosTest3(){
        Transaction__c transact = new Transaction__c();
        loadTestData();
        Card__c card;
        for (Card__c x : [SELECT Id, Name, Number__c, Amount__c FROM Card__c]) {
            if (x.Number__c == '1234123412341234') {
                transact.Card__c = x.Id;
                card = x;
                break;
            }
        }
        ATM__c ATM;
        for (ATM__c x : [SELECT Id, Name, AmountBYN__c FROM ATM__c]) {
            if (x.Name == 'Sberkomat') {
                transact.ATM__c = x.Id;
                ATM = x;
                break;
            }
        }
        transact.Given__c = 1000.00;
        transact.Currency__c = 'BYN';
        transact.amount__c = 1000.00*30;

        Test.startTest();
        ATMController.insertTransaction(JSON.serialize(transact));
        List<Transaction__c> result = [SELECT Currency__c, ATM__c, Card__c, amount__c, Given__c FROM Transaction__c];
        transact.Id = result.get(0).Id;
        System.assertEquals(transact, result.get(0));
        System.assertEquals((card.Amount__c - 1000 * 30), [SELECT Id, Amount__c FROM Card__c WHERE Id =:transact.Card__c].Amount__c);
        System.assertEquals((ATM.AmountBYN__c - 1000), [SELECT Id, AmountBYN__c FROM ATM__c WHERE Id =:transact.ATM__c].AmountBYN__c);
        Test.stopTest();
    }

    @IsTest
    private static void insertTransactionNegTest1(){
        Transaction__c transact = new Transaction__c();
        loadTestData();
        Card__c card;
        for (Card__c x : [SELECT Id, Name, Number__c, Amount__c FROM Card__c]) {
            if (x.Number__c == '1234123412341234') {
                transact.Card__c = x.Id;
                card = x;
                break;
            }
        }
        ATM__c ATM;
        for (ATM__c x : [SELECT Id, Name, Amount__c FROM ATM__c]) {
            if (x.Name == 'Sberkomat') {
                transact.ATM__c = x.Id;
                ATM = x;
                break;
            }
        }
        ATM.Amount__c = 0;
        update ATM;
        transact.Given__c = 1000.00;
        transact.Currency__c = 'RUB';
        transact.amount__c = 1000.00;

        Test.startTest();
        System.assertEquals('Not enough RUB in ATM', ATMController.insertTransaction(JSON.serialize(transact))[0]);
        System.assertEquals((card.Amount__c), [SELECT Id, Amount__c FROM Card__c WHERE Id =:transact.Card__c].Amount__c);
        System.assertEquals((ATM.Amount__c), [SELECT Id, Amount__c FROM ATM__c WHERE Id =:transact.ATM__c].Amount__c);
        Test.stopTest();
    }

    @IsTest
    private static void insertTransactionNegTest2(){
        Transaction__c transact = new Transaction__c();
        loadTestData();
        Card__c card;
        for (Card__c x : [SELECT Id, Name, Number__c, Amount__c FROM Card__c]) {
            if (x.Number__c == '1234123412341234') {
                transact.Card__c = x.Id;
                card = x;
                break;
            }
        }
        ATM__c ATM;
        for (ATM__c x : [SELECT Id, Name, AmountUSD__c FROM ATM__c]) {
            if (x.Name == 'Sberkomat') {
                transact.ATM__c = x.Id;
                ATM = x;
                break;
            }
        }
        ATM.AmountUSD__c = 0;
        update ATM;
        transact.Given__c = 100.00;
        transact.Currency__c = 'USD';
        transact.amount__c = 100.00 * 70;



        Test.startTest();
        System.assertEquals('Not enough USD in ATM', ATMController.insertTransaction(JSON.serialize(transact))[0]);
        System.assertEquals((card.Amount__c), [SELECT Id, Amount__c FROM Card__c WHERE Id =:transact.Card__c].Amount__c);
        System.assertEquals((ATM.AmountUSD__c), [SELECT Id, AmountUSD__c FROM ATM__c WHERE Id =:transact.ATM__c].AmountUSD__c);
        Test.stopTest();
    }

    @IsTest
    private static void insertTransactionNegTest3(){
        Transaction__c transact = new Transaction__c();
        loadTestData();
        Card__c card;
        for (Card__c x : [SELECT Id, Name, Number__c, Amount__c FROM Card__c]) {
            if (x.Number__c == '1234123412341234') {
                transact.Card__c = x.Id;
                card = x;
                break;
            }
        }
        ATM__c ATM;
        for (ATM__c x : [SELECT Id, Name, AmountBYN__c FROM ATM__c]) {
            if (x.Name == 'Sberkomat') {
                transact.ATM__c = x.Id;
                ATM = x;
                break;
            }
        }
        ATM.AmountBYN__c = 10;
        update ATM;
        transact.Given__c = 1000.00;
        transact.Currency__c = 'BYN';
        transact.amount__c = 1000.00*30;

        Test.startTest();
        System.assertEquals('Not enough BYN in ATM', ATMController.insertTransaction(JSON.serialize(transact))[0]);
        System.assertEquals((card.Amount__c), [SELECT Id, Amount__c FROM Card__c WHERE Id =:transact.Card__c].Amount__c);
        System.assertEquals((ATM.AmountBYN__c), [SELECT Id, AmountBYN__c FROM ATM__c WHERE Id =:transact.ATM__c].AmountBYN__c);
        Test.stopTest();
    }
    @IsTest
    private static void insertTransactionNegTest4(){
        Test.startTest();
        System.assertEquals('Problems with transactionJSON', ATMController.insertTransaction('Some invalid JSON')[0]);
        Test.stopTest();
    }
    @IsTest
    private static void insertTransactionNegTest5(){
        Transaction__c transact = new Transaction__c();
        transact.Given__c = 1000.00;
        transact.Currency__c = 'BYN';
        transact.amount__c = 1000.00*30;

        Test.startTest();
        System.assertEquals('Something went wrong', ATMController.insertTransaction(JSON.serialize(transact))[0]);
        Test.stopTest();
    }

    @IsTest
    private static void insertTransactionNegTest6(){
        Transaction__c transact = new Transaction__c();
        loadTestData();
        Card__c card;
        for (Card__c x : [SELECT Id, Name, Number__c, Amount__c FROM Card__c]) {
            if (x.Number__c == '1234123412341234') {
                transact.Card__c = x.Id;
                card = x;
                break;
            }
        }
        ATM__c ATM;
        for (ATM__c x : [SELECT Id, Name, AmountUSD__c FROM ATM__c]) {
            if (x.Name == 'Sberkomat') {
                transact.ATM__c = x.Id;
                ATM = x;
                break;
            }
        }
        transact.Given__c = 1000.00;
        transact.Currency__c = 'USD';
        transact.amount__c = 1000.00 * 70;



        Test.startTest();
        System.assertEquals('Not enough money on your card', ATMController.insertTransaction(JSON.serialize(transact))[0]);
        System.assertEquals((card.Amount__c), [SELECT Id, Amount__c FROM Card__c WHERE Id =:transact.Card__c].Amount__c);
        System.assertEquals((ATM.AmountUSD__c), [SELECT Id, AmountUSD__c FROM ATM__c WHERE Id =:transact.ATM__c].AmountUSD__c);
        Test.stopTest();
    }
}