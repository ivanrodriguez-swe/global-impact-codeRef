/**
 * This class is the controller for the VolunteerEventsRedirect lwc
 * @author Ivan A. Rodriguez
 */
public without sharing class VolunteerEventsRedirectController {
    private static final Integer sessionDuration = 20;
    
    @AuraEnabled (cacheable = true)
    public static String validateUserSession(Map<String,Object> sessionInfo){
        try {
            if(sessionInfo == null){
                return 'null';
            }
            List<Contact> userContact = new List<Contact>();
            String validContact = 'false';
            String sessionId = (String) sessionInfo.get('sessionId');
            String contactId = (String) sessionInfo.get('contactId');
            if(String.isBlank(sessionId) || String.isBlank(contactId)){
                return 'null';
            }
            userContact = [SELECT Id, Global_Impact_Session_Id__c, Volunteer_Session_Expiration__c
                                    FROM Contact 
                                    WHERE id =:contactId
                                    AND Global_Impact_Session_Id__c =:sessionId
                                    LIMIT 1];
            if(userContact.size() >0){
                validContact = 'true';
            }
            return validContact;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void refreshSession(String contactId){
        try {
            List<Contact> userContact = new List<Contact>();
            userContact = [SELECT Id, Global_Impact_Session_Id__c, Volunteer_Session_Expiration__c
                                            FROM Contact 
                                            WHERE id =:contactId
                                        LIMIT 1];
            if(userContact.size() > 0 && !String.isBlank(userContact[0].Global_Impact_Session_Id__c)){
                userContact[0].Volunteer_Session_Expiration__c = System.DateTime.now().addMinutes(sessionDuration);
                update userContact[0];
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}