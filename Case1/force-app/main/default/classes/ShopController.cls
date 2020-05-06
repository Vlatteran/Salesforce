public with sharing class ShopController {
    @AuraEnabled
    public static List<sObject> getProducts() {
        
        return [SELECT Name, Price__c, (SELECT Name FROM Product_Categories__r) 
                FROM Product__c];
    }
    
    @AuraEnabled
    public static List<sObject> getCategories() {
        return [SELECT Name FROM Product_Category__c GROUP BY Name];
    }
    
    @AuraEnabled
    public static List<sObject> getProduct(List<String> filters) {
        
        return [SELECT Name, Price__c, (SELECT Name FROM Product_Categories__r)
                FROM Product__c
				WHERE Id in (SELECT Product__c 
                             FROM Product_Category__c 
                             WHERE Name in :filters)];
    }
}