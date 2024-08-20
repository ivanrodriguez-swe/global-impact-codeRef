public with sharing class VolunteerEventLeadController {
    
   /**
   * This method is called when the volunteerEventLead aura component is initialized.
   * It returns all information for a provided Volunteer Event and Lead.
   * @param Id eventId
   * @param Id leadId
   */
    @AuraEnabled(cacheable=false)
    public static Volunteer_Event_Attendee__c getLeadEventInfo(Id eventId, Id leadId) {
        Volunteer_Event_Attendee__c attendee = new Volunteer_Event_Attendee__c();
        List<Volunteer_Event_Attendee__c> attendees = new List<Volunteer_Event_Attendee__c>();
        
        try {
            attendees = [SELECT Id,
                    Attendee__c,
                    Lead_Volunteer__c,
                    Volunteer_Event__c,
                    Registration_Status__c,
                    Volunteer_Event__r.Supplies_Needed__c,
                    Volunteer_Event__r.Supplies_On_Site__c
                FROM Volunteer_Event_Attendee__c
                WHERE Volunteer_Event__c = :eventId
                    AND Attendee__c = :leadId
                    AND Registration_Status__c ='Registered'
                    AND Lead_Volunteer__c = true
                LIMIT 1];

            if(attendees.size() > 0) {
                attendee = attendees.get(0);
            } else {
                attendee = null;
            }

            return attendee;

        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}