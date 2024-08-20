/**
 * This is the test class for the controller class GlobalImpactController
 * @author Ivan A. Rodriguez
 */
@isTest
private class GlobalImpactLoginControllerTest {
    @TestSetup
    static void makeData(){
        Contact volunteerContact = GlobalImpactHelperTestMethods.createGlobalImpactContacts('Nations Way', 'FL', 1)[0];
        insert volunteerContact;
    }
    
    @isTest
    private static void testValidateEntrySuccess(){
        //Simulate code generation
        Contact volunteerContact = simulateCodeGeneration();
        update volunteerContact;
        //Creating input
        Map<String, String> userInfo = new Map<String,String>{
                            'userEmail'=>volunteerContact.Email,
                            'userToken'=>volunteerContact.Volunteer_Portal_Code__c,
                            'sessionId'=>volunteerContact.Global_Impact_Session_Id__c,
                            'userIpAddr'=>'192.168.1.17'
        };
        Test.startTest();
        Id contactId = GlobalImpactLoginController.validateEntry(userInfo);
        Test.stopTest();
        //Assert Results
        System.assertEquals(volunteerContact.Id, contactId,'The contact should have been found');
        String userEmail = userInfo.get('userEmail');
        Portal_Login_History__c logUser = [SELECT Username__c, Status__c, Source_Ip__c, Portal__c, Login_Time__c
                                            FROM Portal_Login_History__c
                                            WHERE Username__c =:userEmail
                                            LIMIT 1];
        System.assert(logUser != null);
        System.assertEquals('Success', logUser.Status__c, 'The status should be susccess');

        //Adding an exception
        userInfo = null;
        try{
            contactId = GlobalImpactLoginController.validateEntry(userInfo);
        }catch(Exception e){
            System.debug('Exception that is expected');
        }
    }

    @isTest
    private static void testValidateEntryLockedUser(){
         //Simulate code generation
         Contact volunteerContact = simulateCodeGeneration();
         //lock contact
         volunteerContact.Global_Impact_Portal_Locked__c = true;
         update volunteerContact;
         //Creating input
         Map<String, String> userInfo = new Map<String,String>{
            'userEmail'=>volunteerContact.Email,
            'userToken'=>volunteerContact.Volunteer_Portal_Code__c,
            'sessionId'=>volunteerContact.Global_Impact_Session_Id__c,
            'userIpAddr'=>'192.168.1.17'
         };
        Test.startTest();
        String result = GlobalImpactLoginController.validateEntry(userInfo);
        Test.stopTest();
        String userEmail = userInfo.get('userEmail');
        //Verifying results;
        System.assertEquals('locked',result,'The String returned should be \'locked\'');
        Contact returnedContact = [SELECT Id, Email, MailingState,Volunteer_Portal_Code__c,
                                    Global_Impact_Session_Id__c, Volunteer_Session_Expiration__c,
                                    Global_Impact_Invalid_Login_Count__c, Global_Impact_Portal_Locked__c
                                    FROM Contact
                                    WHERE Email =: userEmail
                                    LIMIT 1];
         System.assert(returnedContact.Global_Impact_Invalid_Login_Count__c > 0, 'The Login attempt counter should have been increased');
         Portal_Login_History__c logUser = [SELECT Username__c, Status__c, Source_Ip__c, Portal__c, Login_Time__c
                                            FROM Portal_Login_History__c
                                            WHERE Username__c =:userEmail
                                            LIMIT 1];
        System.assert(logUser != null);
        System.assertEquals('Failed: Account Locked', logUser.Status__c, 'The status should be \'Account Locked\'');

    }

    @isTest
    private static void testValidateEntryRegexFailure(){
        //Simulate code generation
        Contact volunteerContact = simulateCodeGeneration();
        update volunteerContact;
          //Creating input
          Map<String, String> userInfo = new Map<String,String>{
            'userEmail'=>volunteerContact.Email,
            'userToken'=>'^&gh@gshKamsnae',
            'sessionId'=>volunteerContact.Global_Impact_Session_Id__c,
            'userIpAddr'=>'192.168.1.17'
         };
         Test.startTest();
         String result = GlobalImpactLoginController.validateEntry(userInfo);
         Test.stopTest();
         String userEmail = userInfo.get('userEmail');
         //Verifying results
         String stringInResult = result.substring(0,'invalidRegex'.length());
         System.assertEquals('invalidRegex',stringInResult, 'The value should match and say \'invalidRegex\'');
         //Verify log creation
         Portal_Login_History__c logUser = [SELECT Username__c, Status__c, Source_Ip__c, Portal__c, Login_Time__c
                            FROM Portal_Login_History__c
                            WHERE Username__c =:userEmail
                            LIMIT 1];
        System.assert(logUser != null);
        System.assertEquals('Failed: Invalid Password', logUser.Status__c, 'The status should be \'Invalid Password\'');
    }

    @isTest
    private static void testValidateEntryWrongCode(){
         //Simulate code generation
         Contact volunteerContact = simulateCodeGeneration();
         update volunteerContact;
         //Creating input with valid Regex but wrong code
         Map<String, String> userInfo = new Map<String,String>{
            'userEmail'=>volunteerContact.Email,
            'userToken'=>'HGJsyt678HNbsJK',
            'sessionId'=>volunteerContact.Global_Impact_Session_Id__c,
            'userIpAddr'=>'192.168.1.17'
         };
         Test.startTest();
         String result = GlobalImpactLoginController.validateEntry(userInfo);
         Test.stopTest();
         String userEmail = userInfo.get('userEmail');
         Integer attemptsLeft = Integer.valueOf(result);
         System.assertEquals(4,attemptsLeft,'An Integer represented as a String-> value = 4');
         Portal_Login_History__c logUser = [SELECT Username__c, Status__c, Source_Ip__c, Portal__c, Login_Time__c
            FROM Portal_Login_History__c
            WHERE Username__c =:userEmail
            LIMIT 1];
        System.assert(logUser != null);
        System.assertEquals('Failed: Invalid Password', logUser.Status__c, 'The status should be \'Invalid Password\'');
    }

    @isTest
    private static void testRequestCodeSuccess(){
        //Creating input
        Map<String, String> userInfo = new Map<String,String>{
            'userEmail'=>'test0@testemail.com',
            'userIpAddr'=>'192.168.1.17'
         };
         String userEmail = userInfo.get('userEmail');
         Test.startTest();
         String result = GlobalImpactLoginController.requestCode(userInfo);
         Test.stopTest();
         //Verifying results;
         System.assertEquals(15,result.length(),'The Code generated must be a 15 digit code');
    }

    @isTest
    private static void testRequestCodeInvalidregex(){
         //Creating input
         Map<String, String> userInfo = new Map<String,String>{
            'userEmail'=>'%$#test0@@testemail.com',
            'userIpAddr'=>'192.168.1.17'
         };
         String userEmail = userInfo.get('userEmail');
         Test.startTest();
         String result = GlobalImpactLoginController.requestCode(userInfo);
         Test.stopTest();
         //Verifying results;
         System.assert(result == 'invalidRegex','The String \'invalidRegex\' should have been returned');
    }

    @isTest
    private static void testRequestCodeNotExistingContact(){
         //Creating input
         Map<String, String> userInfo = new Map<String,String>{
            'userEmail'=>'test23000@testemail.com',
            'userIpAddr'=>'192.168.1.17'
         };
         String userEmail = userInfo.get('userEmail');
         Test.startTest();
         String result = GlobalImpactLoginController.requestCode(userInfo);
         Test.stopTest();
         //Verifying results;
         System.assert(result == null,'A null should be returned');
         //Verifying that the log record was properly created
         Portal_Login_History__c logUser = [SELECT Username__c, Status__c, Source_Ip__c, Portal__c, Login_Time__c
            FROM Portal_Login_History__c
            WHERE Username__c =:userEmail
            LIMIT 1];
        System.assert(logUser != null);
        System.assertEquals('Failed: Invalid Username', logUser.Status__c, 'The status should be \'Invalid Username\'');
    }

    @isTest
    private static void testRequestCodeUserLocked(){
         //Simulate code generation
         Contact volunteerContact = simulateCodeGeneration();
         volunteerContact.Global_Impact_Portal_Locked__c = true;
         update volunteerContact;
          //Creating input
          Map<String, String> userInfo = new Map<String,String>{
            'userEmail'=>'test0@testemail.com',
            'userIpAddr'=>'192.168.1.17'
         };
         String userEmail = userInfo.get('userEmail');
         Test.startTest();
         String result = GlobalImpactLoginController.requestCode(userInfo);
         Test.stopTest();
          //Verifying results;
          System.assert(result == 'locked','A null should be returned');
          //Verifying that the log record was properly created
          Portal_Login_History__c logUser = [SELECT Username__c, Status__c, Source_Ip__c, Portal__c, Login_Time__c
             FROM Portal_Login_History__c
             WHERE Username__c =:userEmail
             LIMIT 1];
         System.assert(logUser != null);
         System.assertEquals('Failed: Account Locked', logUser.Status__c, 'The status should be \'Account Locked\'');
    }

    /**
     * This method is a helper for the validateEntry test methods
     */
    private static Contact simulateCodeGeneration(){
        Contact volunteerContact = [SELECT Id, Email, MailingState,Volunteer_Portal_Code__c,
                                    Global_Impact_Session_Id__c, Volunteer_Session_Expiration__c,
                                    Global_Impact_Invalid_Login_Count__c, Global_Impact_Portal_Locked__c
                                    FROM Contact
                                    WHERE MailingState='FL'
                                    LIMIT 1];
        //simulating code generation
        volunteerContact.Global_Impact_Session_Id__c = '_hjsTAsTh129';
        volunteerContact.Volunteer_Portal_Code__c='hjsOURhs67UYHGF';
        return volunteerContact;
    }
}