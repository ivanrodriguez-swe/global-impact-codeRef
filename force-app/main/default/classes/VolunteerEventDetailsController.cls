/**
 * Apex controller for volunteerEvantDetails component
 * @author Ivan A. Rodriguez
 */
public without sharing class VolunteerEventDetailsController {
    /**
   * Method that checks if the user is registered or not to an event 
   * at the time the LWC is render.
   * @param Map<String,Object> eventAttendeeDetails: userId and eventId
   * @return Boolean true if is already registered
   */

  @AuraEnabled(cacheable=true)
  public static Map<String,Object> getEventInformation(Map<String, Object> eventAttendeeDetails) {
    try {
      Map<String,Object> eventInfo = new Map<String,Object>();
      Id contactId = (Id) eventAttendeeDetails.get('contactId');
      Id eventId = (Id) eventAttendeeDetails.get('eventId');
      //User us = getUser(userId);
      Contact con = getContact(contactId);
      
      Volunteer_Event__c ev = [SELECT Id,Name,Nearest_Offices__c,Start_Time__c, Event_Address__c,
                              End_Time__c, Max_Attendees__c,Additional_Attendees__c,
                              Registration_Closed_Date__c,
                              (SELECT Id, Attendee__c, Registration_Status__c
                              FROM Volunteer_Event_Attendees__r)
                              FROM Volunteer_Event__c
                              WHERE Id = :eventId];

      if((ev.Registration_Closed_Date__c != null) && Date.today() > ev.Registration_Closed_Date__c){
        eventInfo.put('closed',ev.Name);
      }
      for (Volunteer_Event_Attendee__c att : ev.Volunteer_Event_Attendees__r) {
        if (contactId == att.Attendee__c &&
            att.Registration_Status__c == 'Registered') {
            eventInfo.put('registered', ev.Name);
        }
      }
      if(ev.Volunteer_Event_Attendees__r.size()>= (ev.Additional_Attendees__c == null?ev.Max_Attendees__c:ev.Additional_Attendees__c+ev.Max_Attendees__c)){
          eventInfo.put('full',ev.Name);
      }
      return eventInfo;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * This method is triggered when the user wants to register to the Event. It verifies
   * if the user is already register to any of the events and if he/she is, an exception is thrown.
   * @param Map<String,Object> eventAttendeeDetails: userId, event Id and tShirtSize respectively
   */
  @AuraEnabled
  public static void registerToEvent(Map<String, Object> eventAttendeeDetails) {
    try {
      Id contactId = (Id) eventAttendeeDetails.get('contactId');
      Id eventId = (Id) eventAttendeeDetails.get('eventId');
      String tShirtSize = (String) eventAttendeeDetails.get('tShirtSize');
      String preferredLanguage = (String) eventAttendeeDetails.get('preferredLanguage');
      Contact con = getContact(contactId);
      //User us = getUser(userId);
      String Location = con.Location__c;
      //To store the volunteer attendee that will be created or updated
      Volunteer_Event_Attendee__c attendee;
      //Variable to let the system know that a Volunteer Event Attendee record already exist and needs to be updated to 'Registered'
      Boolean needsToBeRegistered = false;
      //To increment size limit when querying, For SOQL is used
      for (List<Volunteer_Event__c> events : [SELECT Id,Name,Nearest_Offices__c,Start_Time__c,End_Time__c,Max_Attendees__c,Additional_Attendees__c, 
                                                      Registration_Closed_Date__c, Event_Address__c, Status__c,
                                                      (SELECT Id, Attendee__c, Registration_Status__c
                                                      FROM Volunteer_Event_Attendees__r)
                                              FROM Volunteer_Event__c 
                                              WHERE Status__c = 'Active']) {
        //From the returned Events, check if the user has registered for any of the events before and if it has, throw an exception
        for (Volunteer_Event__c ev : events) {
          for (Volunteer_Event_Attendee__c att : ev.Volunteer_Event_Attendees__r) {
            if (
              att.Attendee__c == contactId &&
              att.Registration_Status__c == 'Registered'
            ) {
              throw new VolunteerEventRegistrationException(
                'You are registered to ' +
                ev.Name +
                ' Event.'
              );
            } else if (
              ev.Id == eventId &&
              att.Attendee__c == contactId &&
              att.Registration_Status__c == 'Deregistered'
            ) {
                // Save the record to be updated later
                attendee = new Volunteer_Event_Attendee__c(
                  Id = att.Id,
                  Registration_Status__c = 'Registered',
                  T_Shirt_Size__c = tShirtSize,
                  Accepted_Terms_Conditions__c = true,
                  Global_Impact_Preferred_Email_Language__c = preferredLanguage,
                  Registration_Date__c = System.now());
                
                needsToBeRegistered = true;
            }
          }
        }
      }
      if (needsToBeRegistered && attendee != null) {
        update attendee;
      } else {
        // If the Volunteer Event Attendee record does not exist, then create a new one to register the user
        attendee = new Volunteer_Event_Attendee__c(
          Attendee__c = contactId,
          Registration_Status__c = 'Registered',
          Volunteer_Event__c = eventId,
          Registration_Date__c = System.now(),
          T_Shirt_Size__c = tShirtSize,
          Accepted_Terms_Conditions__c = true,
          Global_Impact_Preferred_Email_Language__c = preferredLanguage
        );
        insert attendee;
      }
      con.Global_Impact_Preferred_Email_Language__c = preferredLanguage;
      con.T_Shirt_Size__c = tShirtSize;
      update con;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * This method is triggered when a user wants to deregister from an event.
   * @param Map<String,Object> eventAttendeeDetails: userId and eventId
   */
  @AuraEnabled
  public static void deregisterFromEvent(Map<String, Object> eventAttendeeDetails) {
    try {
      Id contactId = (Id) eventAttendeeDetails.get('contactId');
      Id eventId = (Id) eventAttendeeDetails.get('eventId');
      //User us = getUser(userId);
      List<Volunteer_Event_Attendee__c> eventAttendee = [SELECT Id,Attendee__c,Volunteer_Event__c,Registration_Status__c,Accepted_Terms_Conditions__c,T_Shirt_Size__c
                                                        FROM Volunteer_Event_Attendee__c
                                                        WHERE Attendee__c = :contactId AND Volunteer_Event__c = :eventId];
      eventAttendee[0].Registration_Status__c = 'Deregistered';
      eventAttendee[0].T_Shirt_Size__c = '';
      eventAttendee[0].Accepted_Terms_Conditions__c = false;
      update eventAttendee;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  private static Contact getContact(Id contactId){
        List<Contact> con  = new List<Contact>();
        con = [SELECT Id, Location__c, Name, Global_Impact_Preferred_Email_Language__c, T_Shirt_Size__c 
                        FROM Contact
                        WHERE Id =:contactId LIMIT 1];
        return con[0];
  }

  /**
   * Exception class
   */
  public class VolunteerEventRegistrationException extends Exception {
  }

}