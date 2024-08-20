/**
 * This class is the controller for the eventDetailsButton LWC
 * @author Ivan A. Rodriguez;
 */
public without sharing class EventDetailsButtonController {
    
    //Since the database is being modified, I cannot use cacheaeble=true
    @AuraEnabled
    public static void checkInAttendee(Map<String,Object> attendeeRecord){
        try {
            Id volunteerId = (Id) attendeeRecord.get('volunteerId');
            Id contactId = (Id) attendeeRecord.get('contactId');
            Id eventId = (Id) attendeeRecord.get('eventId');
            List<Volunteer_Event_Attendee__c> existingAttendee = [SELECT Id,
                                                    Active_Volunteer_Time__c,
                                                    Active_Volunteer_Time_Formula__c, 
                                                    Attendee__c,
                                                    Attendee__r.Name,
                                                    Lead_Volunteer__c,
                                                    Volunteer_Event__c,
                                                    Registration_Status__c,
                                                    T_Shirt_Size__c
                                                FROM Volunteer_Event_Attendee__c
                                                WHERE 
                                                    Volunteer_Event__c = :eventId
                                                AND
                                                    Registration_Status__c = 'Registered' 
                                                AND Id =:volunteerId];
            if(!(existingAttendee[0].Active_Volunteer_Time_Formula__c)){
                Volunteer_Time__c vt = new Volunteer_Time__c(
                                          Attendee__c = contactId,
                                          Volunteer_Event_Attendee__c = volunteerId,
                                          Start_Time__c =  datetime.now(),
                                          Volunteer_Event__c = eventId
                                        );
                insert vt;
                //Update Lookup of the volunteer attendee to volunteer time
                Volunteer_Event_Attendee__c attendee = new Volunteer_Event_Attendee__c(
                    Id=volunteerId,
                    Active_Volunteer_Time__c = vt.Id
                );
                update attendee;
            }else{
                System.debug('There is already Volunteer time record associated to this Volunteer Attendee and Volunteer Event.'+
                'The button must be failing');
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void checkInAll(Object myEventId){
        try {
            Id eventId = (Id) myEventId;
            //New Volunteer Times to insert
            Map<Id,Volunteer_Time__c> volunteerTimesPerAttendee = new Map<Id,Volunteer_Time__c>();
            //Volunteer Event Attendees records to update with the new Volunteer Times records' Ids
            Map<Id,Volunteer_Event_Attendee__c> attendeesMap = 
                                    new Map<Id,Volunteer_Event_Attendee__c>(
                                        [SELECT Id,
                                                Active_Volunteer_Time__c,
                                                Active_Volunteer_Time_Formula__c, 
                                                Attendee__c,
                                                Attendee__r.Name,
                                                Lead_Volunteer__c,
                                                Volunteer_Event__c,
                                                Registration_Status__c,
                                                T_Shirt_Size__c
                                            FROM Volunteer_Event_Attendee__c
                                            WHERE 
                                                Volunteer_Event__c = :eventId
                                            AND
                                                Registration_Status__c = 'Registered' ]);
            //Variable to store the final Attendees that will be updated with the new times created
            List<Volunteer_Event_Attendee__c> attendeesToUpdate = new List<Volunteer_Event_Attendee__c>();
            for(Id attId:attendeesMap.keyset()){
                if(attendeesMap.get(attId).Active_Volunteer_Time_Formula__c){
                    continue;
                }
                //Then there is not a Volunteer Time Record associated;so, create one
                volunteerTimesPerAttendee.put(attId,new Volunteer_Time__c( 
                    Attendee__c = attendeesMap.get(attId).Attendee__c,
                    Volunteer_Event_Attendee__c = attId,
                    Start_Time__c =  datetime.now(),
                    Volunteer_Event__c = eventId
                ));
            }
            if(volunteerTimesPerAttendee.size() != 0){
                //insert Volunteer Times
                insert volunteerTimesPerAttendee.values();
                //Now we need to update the Volunteer Attendee records with the id of the Volunteer
                //times inserted
                for(Id attId:volunteerTimesPerAttendee.keyset()){
                    attendeesMap.get(attId).Active_Volunteer_Time__c = volunteerTimesPerAttendee.get(attId).Id;
                    attendeesToUpdate.add(attendeesMap.get(attId));
                }
                update attendeesToUpdate;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}