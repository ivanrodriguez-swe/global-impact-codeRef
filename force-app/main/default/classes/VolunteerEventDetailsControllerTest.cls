/**
 * This i sthe test class for the Apex controller VolunteerEventDetailsController
 */
@isTest
private class VolunteerEventDetailsControllerTest {
    @TestSetup
    static void makeData(){
        GlobalImpactHelperTestMethods.generateDataForEvent('Nations Way', 'FL', 5);    
    }

    @isTest
    private static void testGetInformationWhenClosedEventAndExceptionOccurs(){
       Volunteer_Event_Attendee__c  attendee = getVolunteerAttendee('Test_1');
        //Close the event 
        Volunteer_Event__c closedEvent = new Volunteer_Event__c(
            Id = attendee.Volunteer_Event__c,
            Registration_Closed_Date__c = Date.today().addDays(-3)
        );
        update closedEvent;
        // Creating the required map for the getEventInformation
        Map<String,String> eventAttendeeDetails = new Map<String,String>{
                                                            'contactId' => attendee.Attendee__c,
                                                             'eventId' => attendee.Volunteer_Event__c
                                                     };
        Map<String, Object> results = new Map<String,Object>();
        Test.startTest();
        results = VolunteerEventDetailsController.getEventInformation(eventAttendeeDetails);
        Test.stopTest();

        System.debug('Assert Results in testGetInformationWhenClosedEvent Begin');
        //Check if the result map contain the closed key
        System.assert(results.containsKey('closed'),'There \'closed\' key should exist in the result map');
        System.debug('Assert Results in testGetInformationWhenClosedEvent Ends');
        //Generate and Exception
        Map<String,String> badData = new Map<String,String>{
                                    'contactId' => null
        };
        try{
            VolunteerEventDetailsController.getEventInformation(badData); 
        }catch(Exception e){
            System.assert(!String.isBlank(e.getMessage()),'There should have been a message generated');
        }
                                   

    }

    @isTest
    private static void testGetInformationWhenEventFull(){
        Volunteer_Event_Attendee__c  attendee = getVolunteerAttendee('Test_1');
         //Full Even the event 
         Volunteer_Event__c fullEvent = new Volunteer_Event__c(
            Id = attendee.Volunteer_Event__c,
            Max_Attendees__c = 4
        );
        update fullEvent;
         // Creating the required map for the getEventInformation
         Map<String,String> eventAttendeeDetails = new Map<String,String>{
                                                 'contactId' => attendee.Attendee__c,
                                                'eventId' => attendee.Volunteer_Event__c
                                                };
        Map<String, Object> results = new Map<String,Object>();
        Test.startTest();
        results = VolunteerEventDetailsController.getEventInformation(eventAttendeeDetails);
        Test.stopTest();

        System.debug('Assert Results in testGetInformationWhenFullEvent Begin');
        //Check if the result map contain the closed key
        System.assert(results.containsKey('full'),'There \'full\' key should exist in the result map');
        System.debug('Assert Results in testGetInformationWhenFullEvent Ends');

    }

    @isTest
    private static void testDeregister(){
        Volunteer_Event_Attendee__c  attendee = getVolunteerAttendee('Test_2');
        //The volunteer is already registered (It was registered in the data creation)
         // Creating the required map for the getEventInformation
         Map<String,String> eventAttendeeDetails = new Map<String,String>{
            'contactId' => attendee.Attendee__c,
           'eventId' => attendee.Volunteer_Event__c,
           'tShirtSize' => attendee.T_Shirt_Size__c
           };
        //Trying to register again a Volunteer
        try{
            VolunteerEventDetailsController.registerToEvent(eventAttendeeDetails);
        }catch(Exception ex){
            System.assert(true);
            System.debug('The Exception was successfully thrown');
            System.debug(ex.getMessage());
        }

        //Deregister from an event
        Test.startTest();
        VolunteerEventDetailsController.deregisterFromEvent(eventAttendeeDetails);
        Test.stopTest();
        //Making sure that the the attendee was deregistered
        Id contactId = eventAttendeeDetails.get('contactId');
        Id eventId = eventAttendeeDetails.get('eventId');
        List<Volunteer_Event_Attendee__c> eventAttendee = [SELECT Id,Attendee__c,Volunteer_Event__c,Registration_Status__c,Accepted_Terms_Conditions__c,T_Shirt_Size__c
                                                        FROM Volunteer_Event_Attendee__c
                                                        WHERE Attendee__c = :contactId AND Volunteer_Event__c = :eventId];
        System.assertEquals('Deregistered',eventAttendee[0].Registration_Status__c,'The attendee should have been deregistered');

        //Generating an Exception to test behavior
        try{
            Map<String,String> empty = new Map<String,String>();
            VolunteerEventDetailsController.deregisterFromEvent(empty);
        }catch(Exception ex){
            System.assert(true);
            System.debug('Error captured: '+ex.getMessage());
        }
    }

    @isTest
    private static void testResgister(){
        Volunteer_Event_Attendee__c  attendee = getVolunteerAttendee('Test_2');
        System.debug('My Attendees: '+attendee);
        attendee.Registration_Status__c = 'Deregistered';
        update attendee;
        System.debug('### Updated');
        // Creating the required map for the getEventInformation
        Map<String,String> eventAttendeeDetails = new Map<String,String>{
            'contactId' => attendee.Attendee__c,
           'eventId' => attendee.Volunteer_Event__c
           };
        Test.startTest();
        VolunteerEventDetailsController.registerToEvent(eventAttendeeDetails);
        Test.stopTest();
        Volunteer_Event_Attendee__c  updatedAttendee = [SELECT id, Registration_Status__c
                                                    FROM Volunteer_Event_Attendee__c
                                                    LIMIT 1];
        System.assertEquals('Registered',updatedAttendee.Registration_Status__c);
    }

    @isTest
    private static void testRegisterNewRecord(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'Global Impact Account' LIMIT 1];
        Volunteer_Event__c myEvent = [SELECT Id FROM Volunteer_Event__c WHERE Name = 'My Volunteer Event' LIMIT 1];
        Id recordTypeId = GlobalImpactHelperTestMethods.getRecordTypeId('Employee_Contacts');
        Contact con = new Contact(
            LastName='Test_'+1717,
            email = 'Test'+1717+'@testemail.com',
            RecordTypeId=recordTypeId,
            AccountId=acc.Id,
            Employment_Status__c = 'Active'
        );
        insert con;

        //Creatin required map object
        Map<String,String> eventAttendeeDetails = new Map<String,String>{
            'contactId' => con.Id,
           'eventId' => myEvent.Id,
           'tShirtSize' => 'Small'
           };
        Id contactId = con.Id;
        VolunteerEventDetailsController.registerToEvent(eventAttendeeDetails);

        Volunteer_Event_Attendee__c insertedAttendee = [SELECT Id, Attendee__c
                                                            FROM Volunteer_Event_Attendee__c
                                                            WHERE
                                                            Attendee__c = :contactId];
        System.assert(insertedAttendee != null);
    }

    /*********************** HELPER METHODS ****************** */
     private static Volunteer_Event_Attendee__c getVolunteerAttendee(String LastName){
        Volunteer_Event_Attendee__c attendee = new Volunteer_Event_Attendee__c();
        attendee = [SELECT Id, Attendee__c, Volunteer_Event__c, T_Shirt_Size__c,Registration_Status__c
                            FROM Volunteer_Event_Attendee__c
                            WHERE Attendee__r.LastName = :LastName
                            LIMIT 1];
        return attendee;
     }

}