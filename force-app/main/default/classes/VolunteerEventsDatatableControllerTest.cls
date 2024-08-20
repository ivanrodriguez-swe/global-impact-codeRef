/**
 * This is the test class for the VolunteerEventsDatatableController class
 * @author Ivan A. Rodriguez
 */
@isTest
private class VolunteerEventsDatatableControllerTest {
    
    @isTest
    private static void testNoEventReturnedIfRegistered(){
        //Creating event with two attendees (The lead will be inserted)
        GlobalImpactHelperTestMethods.generateDataForEvent('Nations Way', 'FL', 3);
        Contact con = [SELECT Id, Name, LastName FROM 
                        Contact 
                        WHERE LastName = 'Test_2' ];
        System.debug('Last Name: '+con.LastName);
        System.debug('@@Contact Id: '+con.Id);
        Test.startTest();
        List<Volunteer_Event__c> events = VolunteerEventsDatatableController.getVolunteerEvents(con.Id);
        System.assert(events.size() == 0,'Since there is only one event and the user is already registered, no events should be returned');
        Test.stopTest();
    }
    @isTest 
    private static void testEventReturned(){
        GlobalImpactHelperTestMethods.generateDataForEvent('Nations Way', 'FL', 3);
        Volunteer_Event__c event = [SELECT Id 
                                    From 
                                    Volunteer_Event__c WHERE Name = 'My Volunteer Event'];
        Id recordTypeId = GlobalImpactHelperTestMethods.getRecordTypeId('Employee_Contacts');
        Account acc = [SELECT Id FROM Account WHERE Name = 'Global Impact Account'];
        //Creatin a new contact with attendee record that has not been registered
        Contact con = new Contact(
                LastName='Test_17',
                email = 'test17'+'@testemail.com',
                Location__c = 'Nations Way',
                RecordTypeId=recordTypeId,
                AccountId=acc.Id,
                Employment_Status__c = 'Active'
            );
        insert con;
        Volunteer_Event_Attendee__c att = new Volunteer_Event_Attendee__c(
            Attendee__c = con.Id,
            Volunteer_Event__c = event.Id,
            Registration_Date__c = Datetime.now(),
            Registration_Status__c = 'Deregistered',
            T_Shirt_Size__c = 'Small'
        );
        insert att;
        Test.startTest();
        List<Volunteer_Event__c> events = VolunteerEventsDatatableController.getVolunteerEvents(con.Id);
        System.assert(events.size() > 0,'There should be an event returned');
        Test.stopTest();

    }

    @isTest 
    private static void testGetRegisteredEvents(){
        //Creating event with two attendees (The lead will be inserted)
        GlobalImpactHelperTestMethods.generateDataForEvent('Nations Way', 'FL', 3);
        Contact con = [SELECT Id, Name, LastName FROM 
                        Contact 
                        WHERE LastName = 'Test_2' ];
        Test.startTest();
        List<Volunteer_Event__c> myEvents = VolunteerEventsDatatableController.getRegisteredEvents(con.Id);
        System.assert(myEvents.size()>0);
        Test.stopTest();

    }

    @isTest
    private static void testGetAllEventsForUsersWithNoLocations(){
        GlobalImpactHelperTestMethods.generateDataForEvent('Nations Way', 'FL', 3);
        Id recordTypeId = GlobalImpactHelperTestMethods.getRecordTypeId('Employee_Contacts');
        Account acc = [SELECT Id FROM Account WHERE Name = 'Global Impact Account'];
        //Creatin a new contact 
        Contact con = new Contact(
                LastName='Test_17',
                email = 'test17'+'@testemail.com',
                MailingState = 'FL',
                RecordTypeId=recordTypeId,
                AccountId=acc.Id,
                Employment_Status__c = 'Active'
            );
        insert con;
        //Getting events by state
        List<Volunteer_Event__c> myEvents = VolunteerEventsDatatableController.getVolunteerEvents(con.Id);
        System.assert(myEvents.size()>0);
    }
}