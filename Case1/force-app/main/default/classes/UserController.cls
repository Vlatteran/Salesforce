public with sharing class UserController {
	@AuraEnabled
    public static User__c getUser(User__c user){
        system.debug(user.Email__c);
        system.debug(user.Password__c);
        String email = user.Email__c;
        User__c getUser = NULL;
        try{
            getUser = [SELECT Name,
                       Email__c, 
                       Password__c, 
                       (SELECT Name, Amount__c FROM Cards__r), 
                       (SELECT Product__r.Name, Quantity__c FROM Carts__r)
                       FROM User__c
                       WHERE Email__c = :email];
        }catch(Exception e){
            
        }
        if (getUser != NULL) {
            if(getUser.Password__c == user.Password__c){
                system.debug('true');
                getUser.Password__c = '';
                system.debug(getUser);
                return getUser;
            } else {
            	system.debug('false');
            	return user;
            }
        }else {
            system.debug('false');
            return user;
        }
        
    }
    
    @AuraEnabled
    public static User__c newUser(User__c user){
        if (!getUser(user).Password__c.equals('')){
            insert user;
            return getUser(user);
        }else{
            return user;
        }
    }
}