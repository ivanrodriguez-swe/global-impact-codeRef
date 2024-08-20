/**
 * Test class for Apex controller VolunteerEventLeadController
 */
@isTest
public class VolunteerEventLeadControllerTest {
    
    @TestSetup
    static void setupData(){
        GlobalImpactHelperTestMethods.generateDataForEvent('Nations Way', 'FL', 5);
    }

    @isTest
    private static void testGetLeadEventInfo() {
        Volunteer_Event__c testEvent = getVolunteerEvent();

        Test.startTest();
        Volunteer_Event_Attendee__c leadEventInfo = VolunteerEventLeadController.getLeadEventInfo(testEvent.Id, testEvent.Lead__c);
        Test.stopTest();

        System.assertEquals(testEvent.Lead__c, leadEventInfo.Attendee__c, 'Wrong Volunteer Event Attendee for Event Lead.');

        try{
            VolunteerEventLeadController.getLeadEventInfo('Invalid Event Id', 'Invalid Contact Id');
        }catch(Exception e){
            System.assert(!String.isBlank(e.getMessage()),'There should have been an exception thrown for no returned event.');
        }
    }

    @isTest
    private static void testNoLeadEventInfo() {
        Volunteer_Event__c testEvent = getVolunteerEvent();

        Test.startTest();
        Volunteer_Event_Attendee__c leadEventInfo = VolunteerEventLeadController.getLeadEventInfo(testEvent.Id, null);
        Test.stopTest();

        System.assertEquals(null, leadEventInfo, 'There should be no Volunteer Event Attendee for Event Lead.');
    }

    /*********************** HELPER METHODS ****************** */
    private static Volunteer_Event__c getVolunteerEvent(){
        Volunteer_Event__c event = [SELECT Id, Lead__c 
                                    FROM Volunteer_Event__c 
                                    LIMIT 1];
                            
        return event;
    }
}