/**
 * This class is the controller class for the globalImpactLogin LWC
 * @author Ivan A. Rodriguez
 */
public without sharing class GlobalImpactLoginController {
    private static String regexEmailValue = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
    private static String regexCodeValue ='^[a-zA-Z0-9]{15}$';
    private static final List<String> STATUS = new List<String>{
        'Success',
        'Failed: Invalid Password',
        'Failed: Account Locked',
        'Failed: Invalid Username'
    };
    private static final Integer sessionDuration = 2;
    private static final Integer maxLoginAttempts = 5;

    @AuraEnabled
    public static String validateEntry(Map<String,Object> userInfo){
        try {
            String outcome='';
            String userToken =  (String) userInfo.get('userToken');
            String userEmail = (String) userInfo.get('userEmail');
            String sessionId = (String) userInfo.get('sessionId');
            String ipAddress = (String) userInfo.get('userIpAddr');
            Pattern codePattern = Pattern.compile(regexCodeValue);
            Matcher codeMatcher = codePattern.matcher(userToken);
            
            Contact userContact = getContact(userEmail);
            if(userContact.Global_Impact_Portal_Locked__c == true){
                incrementLoginAttempts(userContact);
                logHistory(userEmail, STATUS[2], ipAddress);
                outcome = 'locked';
            }
            else if(!codeMatcher.matches()){
               outcome = 'invalidRegex'+incrementLoginAttempts(userContact);
               logHistory(userEmail, STATUS[1], ipAddress);
            }
            else if((userContact.Volunteer_Portal_Code__c != null) && (userContact.Volunteer_Portal_Code__c).equals(userToken)){
                userContact.Volunteer_Session_Expiration__c = System.DateTime.now().addMinutes(sessionDuration);
                userContact.Global_Impact_Session_Id__c = sessionId;
                //Clear Code
                userContact.Volunteer_Portal_Code__c = '';
                //Reset Invalid Attempts Counter
                userContact.Global_Impact_Invalid_Login_Count__c = 0;
                outcome = userContact.Id;
                update userContact;
                logHistory(userEmail, STATUS[0], ipAddress);
            }
            else{
                //Increase counter because the user has entered invalid code
                outcome = incrementLoginAttempts(userContact);
                logHistory(userEmail, STATUS[1], ipAddress);
            }
            return outcome;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        } 
    }

    @AuraEnabled
    public static String requestCode(Map<String,Object> userInfo){
        try {
            String userEmail = (String) userInfo.get('userEmail');
            String ipAddress = (String) userInfo.get('userIpAddr');
            Pattern emailPattern = Pattern.compile(regexEmailValue);
            Matcher emailMatcher = emailPattern.matcher(userEmail);
            String portalCode;
            //Map<String,Object> contactEmail = new Map<String,Object>{'userEmail'=>userEmail};
            if (!emailMatcher.matches()){
                //Here we will include the creation of Login History records
                //logHistory(userEmail, Status[3], ipAddress);
                //return empty String
                return 'invalidRegex';
            }
            Contact userContact = getContact(userEmail);
             if(userContact == null){
                //It is not a valid contact so log the error the Login History
                logHistory(userEmail, STATUS[3], ipAddress);
                //return empty string;
            }
            else if(userContact.Global_Impact_Portal_Locked__c == true){
                portalCode = 'locked';
                userContact.Global_Impact_Invalid_Login_Count__c = userContact.Global_Impact_Invalid_Login_Count__c + 1;
                update userContact;
                logHistory(userEmail, STATUS[2], ipAddress);
            }
            else {
                //Contact found so generate Code an update the Contact Record;
                portalCode = VolunteerCodeGenerator.generateCode()[0].code;
                userContact.Volunteer_Portal_Code__c = portalCode;
                update userContact;
            }
            return portalCode;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    private static Contact getContact (String userEmail){
        Id recordTypeId = [SELECT Id, Name, DeveloperName FROM 
                            RecordType 
                            WHERE DeveloperName = 'Employee_Contacts' 
                            AND 
                            SobjectType='Contact'
                            LIMIT 1].Id;
        List<Contact> userContact = new List<Contact>();
        userContact = [SELECT Id, Name, Volunteer_Portal_Code__c, Email, CreatedDate,
                                    Global_Impact_Session_Id__c, Volunteer_Session_Expiration__c,
                                    Global_Impact_Invalid_Login_Count__c, Global_Impact_Portal_Locked__c
                                    FROM Contact 
                                    WHERE Email=:userEmail
                                    AND 
                                    recordTypeId = :recordTypeId
                                    ORDER BY CreatedDate DESC];
        if(userContact.size() > 0){
            return userContact[0];
        }
        return null;
    }
    
    private static String incrementLoginAttempts(Contact userContact){
        try{
            String result='';
            if(userContact.Global_Impact_Invalid_Login_Count__c == null){
                userContact.Global_Impact_Invalid_Login_Count__c = 0;
            }
            userContact.Global_Impact_Invalid_Login_Count__c =   userContact.Global_Impact_Invalid_Login_Count__c + 1;
            if((userContact.Global_Impact_Portal_Locked__c == false) && 
                (maxLoginAttempts - userContact.Global_Impact_Invalid_Login_Count__c )<= 1){
                userContact.Global_Impact_Portal_Locked__c = true;
            } 
            update userContact;
            result = ''+(maxLoginAttempts - userContact.Global_Impact_Invalid_Login_Count__c);
            return result;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static void logHistory(String username, String status, String ipAddress){
        Portal_Login_History__c logUser = new Portal_Login_History__c();
        logUser.Username__c = username;
        logUser.Status__c = status;
        logUser.Source_IP__c = ipAddress;
        logUser.Portal__c = 'Global Impact';
        logUser.Login_Time__c = DateTime.now();
        try{
            insert logUser;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}