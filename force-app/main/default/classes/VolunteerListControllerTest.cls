/**
 * This is the test class for the VolunteerList Controller
 * @author Ivan A. Rodriguez
 */
@isTest
private class VolunteerListControllerTest {
    @TestSetup
    static void makeData(){
        //This method will generate an event, contacts, and their corresponding attendees.
        GlobalImpactHelperTestMethods.generateDataForEvent('Nations Way', 'FL', 5);
    }

    @isTest 
    private static void testANotEventLead(){
        //Creating event Info map 
        Volunteer_Event__c myEvent = [SELECT Id FROM Volunteer_Event__c 
                                        WHERE Name = 'My Volunteer Event'
                                            LIMIT 1];
        //Getting one of the 5 contacts that was registered for this event
        COntact con = [SELECT Id FROM Contact WHERE LastName = 'Test_2'];
        //Creating the eventInfo map that contains the necessary information to call the method
        Map<String, Object> eventInfo = new Map<String,Object>{
            'eventId'=>myEvent.Id,
            'contactId'=>con.Id
        };
        Test.startTest();
        Map<String,Object> result = VolunteerListController.getAttendeeList(eventInfo);
        Test.stopTest();
        //Verifying results
        System.assert(result == null, 'There should not be any attendees returned');
    }

    @isTest 
    private static void testAnEventLead(){
         //Creating event Info map 
         Volunteer_Event__c myEvent = [SELECT Id FROM Volunteer_Event__c 
                        WHERE Name = 'My Volunteer Event'
                            LIMIT 1];
        Id eventId = myEVent.Id;
        //Getting the Volunteer event lead that was registered for this event
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Test_1'];
        //Creating the eventInfo map that contains the necessary information to call the method
        Map<String, Object> eventInfo = new Map<String,Object>{
            'eventId'=>eventId,
            'contactId'=>con.Id
        };

        Map<String,Object> result = VolunteerListController.getAttendeeList(eventInfo);
         //Verifying results
        System.assert(result != null, 'There should be a list of attendees returned');
        //Since all volunteer are registered this output should be false;
        Boolean outPut = (Boolean) result.get('disableCheckAllButton');
        System.assert(!outPut, 'The value for the disableCheckAllButton key must have been set to false');

        //Checcking in all attendee and make sure that the disableCheckAllButton key is set to true
        List<Volunteer_Event_Attendee__c> attendees =[SELECT Id, Volunteer_Event__c, Registration_Status__c,
                                                        Attendee__c, Attendee__r.LastName, Lead_Volunteer__c,
                                                        Active_Volunteer_Time__c
                                                        FROM Volunteer_Event_Attendee__c
                                                        WHERE Volunteer_Event__c =:eventId
                                                    ];
        //Creating Volunteer Time record for each attende
        System.debug('@@@Attendees: '+attendees);
        Map<Id,Volunteer_Time__c> volunteerTimes = new Map<Id,Volunteer_Time__c>();
        for(Volunteer_Event_Attendee__c att: attendees){
            volunteerTimes.put(att.Id,
                new Volunteer_Time__c(
                    Start_Time__c = System.DateTime.now(),
                    Volunteer_Event__c = eventId,
                    Attendee__c = att.Attendee__c,
                    Volunteer_Event_Attendee__c = att.Id
                )
            );
        } 
        insert volunteerTimes.values();
        //Linking times to Attendees
        for(Volunteer_Event_Attendee__c att: attendees){
            att.Active_Volunteer_Time__c=volunteerTimes.get(att.Id).Id;
        }
        update attendees;
        Test.startTest();
        result = VolunteerListController.getAttendeeList(eventInfo);
        Test.stopTest();
        System.assert(result != null, 'There should be a list of attendees returned');
        //Since all volunteer are registered this output should be false;
        outPut = (Boolean) result.get('disableCheckAllButton');
        System.assert(outPut, 'The value for the disableCheckAllButton key must have been set to true, because all attendees were checked in');

    }
}