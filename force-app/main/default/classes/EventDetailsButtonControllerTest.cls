/**
 * This is the test class for the EventDetailsButtonController class
 * @author Ivan A. Rodriguez
 */
@isTest
public class EventDetailsButtonControllerTest {
    /**
     * Method that preset an event and contacts
     */
    @TestSetup
    private static void makeData(){
        GlobalImpactHelperTestMethods.generateDataForEvent('Nations Way', 'FL', 200);
    }

    /********************** TEST METHODS****************************************** */
    @isTest
    private static void testCheckIn(){
        Volunteer_Event__c ev = [SELECT Id, Name From Volunteer_Event__c];
        List<Volunteer_Event_Attendee__c> attendees = [SELECT Id, Name, Volunteer_Event__c,Attendee__c
                                                        FROM Volunteer_Event_Attendee__c];
        Contact con = [SELECT Id, LastName FROM Contact WHERE LastName='Test_1'];
        Id volunteerId;
        for(Volunteer_Event_Attendee__c att: attendees){
            if(att.Attendee__c == con.Id){
                volunteerId = att.Id;
            }
        }
        Map<String, Object> attendeeRecord = new Map<String,Object>{
                                        'volunteerId'=>volunteerId,
                                        'contactId' =>con.Id,
                                        'eventId'=>ev.Id
                                    };
        Test.startTest();
        EventDetailsButtonController.checkInAttendee(attendeeRecord);
        Test.stopTest();
        //Verify results;
        System.debug('Check In results');
        List<Volunteer_Time__c> attendeeTime = [SELECT Id, Attendee__c, Volunteer_Event__c, Start_Time__c
                                                FROM Volunteer_Time__c
                                                WHERE Attendee__c =:con.Id];

                                    System.assert(attendeeTime.size() == 1, 'There are more than one Volunteer Time record for the same attendee in the same event');
                                    System.assertEquals(ev.Id, attendeeTime[0].Volunteer_Event__c, 'The events should match');
        //Generate and test an Exception
        Map<String,Object> badData = new Map<String, Object>{'wrongData'=>'This is wrong'};
        try{
            EventDetailsButtonController.checkInAttendee(badData);
        }catch(Exception e){
            System.debug('Message displayed by the Exception: '+e.getMessage());
            System.assert(!String.isBlank(e.getMessage()));
        }

        //Check In the same attendee again. This test is to make sure that no other Volunteer 
        //time records are being inserted in case the Check In button failed to hide in the front end
        EventDetailsButtonController.checkInAttendee(attendeeRecord);
        List<Volunteer_Time__c> sameAttendeeTime = [SELECT Id, Attendee__c, Volunteer_Event__c, Start_Time__c
                                                FROM Volunteer_Time__c
                                                WHERE Attendee__c =:con.Id];
        System.assertEquals(1, sameAttendeeTime.size(),'There should be only one attendee time record created');
        
        
    }

    @isTest
    private static void testCheckInAll(){
        Volunteer_Event__c ev = [SELECT Id, Name From Volunteer_Event__c];
        Test.startTest();
        EventDetailsButtonController.checkInAll(ev.Id);
        Test.stopTest();
        //Asert results
        List<Volunteer_Event_Attendee__c> attendees = [SELECT Id, Name,Volunteer_Event__c,
                (SELECT Id, Attendee__c, Volunteer_Event_Attendee__c,
                    Start_Time__c, Volunteer_Event__c
                    FROM Volunteer_Times__r)
                    FROM Volunteer_Event_Attendee__c
                    WHERE Volunteer_Event__c =: ev.Id];
        for(Volunteer_Event_Attendee__c att: attendees){
            System.debug('List of times\'size: '+att.Volunteer_Times__r.size());
            System.debug('List of times: '+att.Volunteer_Times__r.size());
            System.assert(att.Volunteer_Times__r.size() == 1,'Only one time per attendee should exist');
            System.assertEquals(ev.Id,att.Volunteer_Times__r[0].Volunteer_Event__c,'The Volunteer_Event__c field must be populated and match with the event of the attendee');
            System.assert(att.Volunteer_Times__r[0].Start_Time__c != null,'The field start time must be populated');
        }

        //Generate an exception and test an Exception
        try{
            //Using a Random String instead of a valid ID
            EventDetailsButtonController.checkInAll('Bad Data');
        }catch(Exception e){
            System.assert(!String.isBlank(e.getMessage()),'An error message must be generated');
        }

        //Check In All again. This situation could happen if the button fails to hide when it is pressed
        EventDetailsButtonController.checkInAll(ev.Id);
        List<Volunteer_Event_Attendee__c> otherAttendees = [SELECT Id, Name,Volunteer_Event__c,
                (SELECT Id, Attendee__c, Volunteer_Event_Attendee__c,
                    Start_Time__c, Volunteer_Event__c
                    FROM Volunteer_Times__r)
                    FROM Volunteer_Event_Attendee__c
                    WHERE Volunteer_Event__c =: ev.Id];
        Integer numberOfTimeRecords = 0;
        for(Volunteer_Event_Attendee__c att: otherAttendees){
            numberOfTimeRecords = numberOfTimeRecords + att.Volunteer_Times__r.size();
        }
        System.debug('Time records: '+numberOfTimeRecords);
        System.assertEquals(200, numberOfTimeRecords,'SInce we have only 200 attendees in the same event, we should not have more than 200 record ');
        System.debug('Asserts of all Check In All works fine');
    }

}