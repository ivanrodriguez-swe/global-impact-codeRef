/**
 * This is the controller class for the volunteerEventsDatatable LWC
 * @author Ivan A. Rodriguez
 */
public without sharing class VolunteerEventsDatatableController {
    /**
     * This method returns the Volunteer Events based on 
     * the current user's location
     */
    @AuraEnabled(cacheable=true)
    public static List<Volunteer_Event__c> getVolunteerEvents(Object contactId){
        try {
            Id sentId = (Id) contactId;
            List<Volunteer_Event__c> eventsToDisplay = new List<Volunteer_Event__c>();
            //Get Contact Information
            Contact con = getContact(sentId);
            String contactLocation = con.Location__c;
            String contactState= con.MailingState;
            if(String.isBlank(contactLocation) && String.isBlank(contactState)){
                //Return empty  list ==> No events to display
                return eventsToDisplay;
            }
            //Get All Events records
            List<Volunteer_Event__c> events = getAllEvents(contactLocation,contactState);
            //DIsplaying all the events except the one I am registered for
            Boolean registered = false;
            for(Volunteer_Event__c ev: events){                  
                for(Volunteer_Event_Attendee__c att: ev.Volunteer_Event_Attendees__r){
                    if(att.Attendee__c == sentId && att.Registration_Status__c == 'Registered'){
                            registered = true;
                             break;
                        }
                    }
                    if(!registered){
                        eventsToDisplay.add(ev);
                    }
                    registered = false;
                }
            return eventsToDisplay;

        } catch (Exception e) { 
            throw new AuraHandledException(e.getMessage());
        }
    }

     /**
     * This method returns Event that I register for
     */
    @AuraEnabled(cacheable=true)
    public static List<Volunteer_Event__c> getRegisteredEvents(Object contactId){
        Id sentId = (Id) contactId;
        List<Volunteer_Event__c> myEvents = new List<Volunteer_Event__c>();
        try {
            Contact con = getContact(sentId);
            String contactLocation = con.Location__c;
            String contactState = con.MailingState;
            //To increment size limit when querying
            List<Volunteer_Event__c> events = getAllEvents(contactLocation,contactState);
            //From the returned Events, send to the LWC component the ones that the user has been registered for
            for(Volunteer_Event__c ev: events){                  
                for(Volunteer_Event_Attendee__c att: ev.Volunteer_Event_Attendees__r){
                    if(att.Attendee__c == sentId && att.Registration_Status__c == 'Registered'){
                        myEvents.add(ev);
                    }
                }
            }
            return myEvents;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
     * Method to retrieve the contact based on an ID
     * @param contactId Id of the contact
     * @return Contact details
     */
    private static Contact getContact(Id contactId){
        List<Contact> con  = new List<Contact>();
        con = [SELECT Id, Location__c, Name, MailingState
                        FROM Contact
                        WHERE Id =:contactId LIMIT 1];
        return con[0];
    }

    
    /**
     * Method that queries events and accordingly returns the events by state or by location
     * @param contactLocation Location of the Contact
     * @param contactState State of the contact
     * @return List of the events that satisfy the filters
     */
    private static List<Volunteer_Event__c> getAllEvents(String contactLocation, String contactState){
        List<Volunteer_Event__c> eventsToDisplay = new List<Volunteer_Event__c>();
        List<Volunteer_Event__c> eventsByLocation = new List<Volunteer_Event__c>();
        List<Volunteer_Event__c> eventsByState = new List<Volunteer_Event__c>();
        //To increment size limit when querying
        for(List<Volunteer_Event__c> events: [SELECT Id, Name, Nearest_Offices__c, Start_Time__c, End_Time__c,State__c, Event_Address__c, Status__c,
        (SELECT Id, Attendee__c, Registration_Status__c FROM Volunteer_Event_Attendees__r)
        FROM Volunteer_Event__c 
        WHERE Status__c = 'Active']){
            //Check if we need ot return by location or by state
            if(!String.isBlank(contactLocation)){
                for(Volunteer_Event__c ev: events){
                    Set<String> offices = new Set<String>(Utils.getMultiselectPicklistAsList(ev.Nearest_Offices__c));
                    if(offices.contains(contactLocation)){
                        eventsByLocation.add(ev);
                    }
                    if(ev.State__c == contactState){
                        eventsByState.add(ev);
                    }
                }
                if(eventsByLocation.size()>0){
                    eventsToDisplay = eventsByLocation;
                }else{
                    eventsToDisplay = eventsByState;
                }
            }else if(!String.isBlank(contactState)){
                for(Volunteer_Event__c ev: events){
                    if(ev.State__c == contactState){
                        eventsByState.add(ev);
                    }
                }
                eventsToDisplay = eventsByState;
            }
        }
        return eventsToDisplay;
    }
    //Exception class 
    public class NoAssociatedContactException extends Exception{}
}