/**
 * This class is the controller class for the VolunteerEventsRedirectController 
 * @author ivan A. Rodriguez
 */
@isTest
private class VolunteerEventsRedirectControllerTest {
    @TestSetup
    static void makeGlobalContactsData(){
        List<Contact> newContacts = GlobalImpactHelperTestMethods.createGlobalImpactContacts('Nations Way', 'FL', 1);
        insert newContacts;
    }
    @isTest
    private static void testUserWithNoSession(){
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Test_0' LIMIT 1];
        Map<String,Object> sessionInfo = new Map<String,Object>{
            'sessionId' =>null,
            'contactId' =>con.Id
        };
        Test.startTest();
        String result = VolunteerEventsRedirectController.validateUserSession(sessionInfo);
        Test.stopTest();
        System.assert(result == 'null','The expected result is null, because there is not a session Id');
        
        //Testing a null map
        Map<String, Object> nullMap;
        result = VolunteerEventsRedirectController.validateUserSession(nullMap);
        System.assert(result == 'null','The expected result is null because the Map is null');

    }

    @isTest 
    private static void testUserWithValidSessions(){
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Test_0' LIMIT 1];
        con.Global_Impact_Session_Id__c = '_testSession';
        update con;
        Map<String,Object> sessionInfo = new Map<String,Object>{
            'sessionId' =>con.Global_Impact_Session_Id__c,
            'contactId' =>con.Id
        };
        Test.startTest();
        String result = VolunteerEventsRedirectController.validateUserSession(sessionInfo);
        Test.stopTest();
        System.assert(result == 'true','The expected result true, because the contact with that session Id exists');
    }

    @isTest 
    private static void testRefreshSession(){
        Contact con = [SELECT Id, Global_Impact_Session_Id__c  FROM Contact WHERE LastName = 'Test_0' LIMIT 1];
        con.Global_Impact_Session_Id__c = '_testSession';
        update con;
        Test.startTest();
        VolunteerEventsRedirectController.refreshSession(con.Id);
        Test.stopTest();

        //Verifying results;
        Contact updatedContact = [SELECT Id, Volunteer_Session_Expiration__c FROM Contact WHERE LastName = 'Test_0' LIMIT 1];
        System.assert(updatedContact.Volunteer_Session_Expiration__c != null,'The Volunteer Session Expiration field must be populated');
        
    }
}