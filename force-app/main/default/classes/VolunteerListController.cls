/**
 * This class is the apex controller of ythe volunteerList LWC
 * @author Ivan A. Rodriguez
 */
public without sharing class VolunteerListController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getAttendeeList(Map<String,Object> eventInfo){
        try {
            //Map that will be returned
            Map<String, Object> result = new Map<String,Object>();
            //Variable to verify if lead was registered to the event
            Boolean isLeadRegistered=false;
            //Variable to store the list of attendees
            List<Volunteer_Event_Attendee__c> attendeeList = new List<Volunteer_Event_Attendee__c>();

            Id eventId = (Id) eventInfo.get('eventId');
            Id contactId = (Id) eventInfo.get('contactId');
            //Variable to avoid rewrite the result object
            Boolean wasChecked = false;
            //Using a for-soql
            for(List<Volunteer_Event_Attendee__c> att:
                                                [SELECT Id, 
                                                    Active_Volunteer_Time__c,
                                                    Active_Volunteer_Time_Formula__c, 
                                                    Attendee__c,
                                                    Attendee__r.FirstName,
                                                    Attendee__r.LastName,
                                                    Attendee__r.MiddleName,
                                                    Lead_Volunteer__c,
                                                    Volunteer_Event__c,
                                                    Registration_Status__c,
                                                    T_Shirt_Size__c
                                                FROM Volunteer_Event_Attendee__c
                                                WHERE 
                                                    Volunteer_Event__c = :eventId
                                                    AND
                                                    Registration_Status__c ='Registered']
                                                    ){
                if(att.size() ==0){
                    System.debug('%%There are not attendees registered to the event');
                    return null;
                }
                attendeeList = att;
                for(Volunteer_Event_Attendee__c attendee: attendeeList){
                    if(!attendee.Active_Volunteer_Time_Formula__c && !wasChecked){
                        result.put('disableCheckAllButton',false);
                        wasChecked = true;
                    }
                    if(attendee.Attendee__c == contactId){
                        isLeadRegistered = true;
                        if(!attendee.Lead_Volunteer__c){
                            System.debug('%%The user should not be seen the List because he/she is not the Lead for the event');
                            return null;
                        }
                    }

                }
                   
                if(!isLeadRegistered){
                    System.debug('%%The Lead is not registered to the event');
                    return null;
                }
            }
            //Check if the key was set on the map
            //If it was not set, it means that all attendees were registered
            if(!result.containsKey('disableCheckAllButton')){
                result.put('disableCheckAllButton',true);
            }
            //Set list of attendees on the map
            result.put('attendeeList',attendeeList);
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}