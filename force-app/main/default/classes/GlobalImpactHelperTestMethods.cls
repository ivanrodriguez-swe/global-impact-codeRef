/**
 * This class provides helper methods that can be used 
 * by Global Impact's Test classes. 
 */
@isTest
public class GlobalImpactHelperTestMethods {
     /*********************** HELPER METHODS************************************************** */
     public static List<Contact> createGlobalImpactContacts (String location, String State, Integer count){
        List<Contact> result = new List<Contact>();
        if (count <= 0){
            //return empty list in case a negative count
            return result;
        }
        Account acc = new Account(
            Name='Global Impact Account'
        );
        insert acc;
        Id recordTypeId = getRecordTypeId('Employee_Contacts');
        for(Integer i = 0; i < count; i ++){
            Contact con = new Contact(
                LastName='Test_'+i,
                email = 'test'+i+'@testemail.com',
                RecordTypeId=recordTypeId,
                AccountId=acc.Id,
                Employment_Status__c = 'Active'
            );
            if(!String.isBlank(location)){
                con.Location__c = location;
            }
            if(!String.isBlank(State)){
                con.MailingState = State;
            }
            result.add(con);
        }
        return result;
    }

    /**
     * This method will create an event, contacts and attendees related to the event.
     * Always, the contact with last name "Test_1" will be the lead for the generated event
     */
    public static void generateDataForEvent(String location, String State, Integer count){
        List<Contact> globalImpactContacts = GlobalImpactHelperTestMethods.createGlobalImpactContacts(location,State,count);
        List<Volunteer_Event_Attendee__c> attendees = new List<Volunteer_Event_Attendee__c>();
        insert globalImpactContacts;
        //Find the contact with last name 'Test_1' so it can be the lead of the event
        Contact con = new Contact();
        for(Integer i = 0; i<= globalImpactContacts.size() -1; i++){
            if(globalImpactContacts[i].LastName == 'Test_1'){
                con = globalImpactContacts[i];
                break;
            }
        }
        Volunteer_Event__c event = createVolunteerEvent('My Volunteer Event',location,state, con.Id);
        insert event;
        //Create Volunteer Event Attendees per contacts
        for (Contact c: globalImpactContacts){
            //Do not create a Volunteer Attendee for this contact, because it gets created in a flow
            if(c.Id == con.Id){
                continue;
            }
            attendees.add(new Volunteer_Event_Attendee__c(
                Attendee__c = c.Id,
                Volunteer_Event__c = event.Id,
                Registration_Date__c = Datetime.now(),
                Registration_Status__c = 'Registered',
                T_Shirt_Size__c = 'Small'
            ));
        }
        insert attendees;
    }
    public static Id getRecordTypeId(String recordTypeDevName){
        RecordType rt = [SELECT Id, DeveloperName
                        FROM RecordType
                        WHERE SobjectType='Contact' AND DeveloperName =:recordTypeDevName];
        return rt.Id;
    }

    public static Volunteer_Event__c createVolunteerEvent(String Name, String Location, String State, Id leadId){
        //Create the Event
        Datetime myDate = Datetime.now();
        Volunteer_Event__c event = new Volunteer_Event__c(
            Name= Name,
            Event_Type__c = 'Global Impact Day 2022',
            Start_Time__c = myDate,
            End_Time__c = myDate.addHours(2),
            Street_Address_1__c = 'Test Street',
            City__c = 'Test City',
            Country__c = 'US',
            Postal_Code__c = '99999',
            Max_Attendees__c = 250, //We might have a total of 200 contacts so, we need enough spots
            Lead__c = leadId
        );
        if(!String.isBlank(location)){
            event.Nearest_Offices__c = location;
        }
        if(!String.isBlank(State)){
            event.State__c = State;
        }
        return event;
    }
}