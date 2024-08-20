import { LightningElement, wire } from 'lwc';
import {refreshApex} from '@salesforce/apex';
//Importing controller
import validateUserSession from '@salesforce/apex/VolunteerEventsRedirectController.validateUserSession';
import refreshSession from '@salesforce/apex/VolunteerEventsRedirectController.refreshSession';
//Import features to read variables from the current page
import {CurrentPageReference} from 'lightning/navigation';
import {NavigationMixin} from 'lightning/navigation';


export default class VolunteerEventsRedirect extends NavigationMixin(LightningElement) {
    //Identifier to detect if we are on Experience Builder
    app;
    //Variable that stores the eventId that is used in case we need to redirect the user to the vent details when using the search bar or home page
    eventId;
    //Other properties in the pageReference
    contactId;
    sessionId
    //Map to group information
    sessionInfo;
    mySession;
    //Guard
    sessionVerificationResult;
    

    @wire(CurrentPageReference)
    wiredPageReference(currentPageReference){
        this.contactId = sessionStorage.getItem('contactId');
        this.sessionId = sessionStorage.getItem('sessionId');
        this.app = currentPageReference.state.app;
        this.eventId = currentPageReference.attributes.recordId;
        if(this.app){
            //Do nothing
            
        }else{
            //Check first if the Session is valid (We are reliying the the contactId and sessionId values are always presented on the page)
            if(this.sessionId && this.contactId){
                this.sessionInfo = new Map();
                this.sessionInfo.sessionId = this.sessionId;
                this.sessionInfo.contactId = this.contactId;
                this.mySession = this.sessionInfo;
                this.handler();
            }
            else{
                this.navigateToLoginPage();
            }
        }
        
    }
    

/******************* FUNCTIONAL METHODS****************************************** */

//Validated if the user's session is valid
@wire(validateUserSession,{sessionInfo : '$mySession'})
wiredResponse(value){
    let {error,data} = value;
    this.sessionVerificationResult = value;
    if(data){
        if(data === 'true'){
            data = undefined;
            refreshSession({contactId : this.contactId})
            .then(()=>{
                this.isVolunteerEvent(this.eventId);
            })
            .catch((errorInUpdate)=>{
                console.log(`Error when validating Session: ${JSON.stringify(errorInUpdate)}`);
            });
        }else if( data === 'false'){
            this.navigateToLoginPage();
        }else{
               this.navigateToLoginPage();
        }
    }else if(error){
        console.log(`Error when validating Session: ${JSON.stringify(error)}`);
    }
    
}
handler(){
    refreshApex(this.sessionVerificationResult);
}


//Check if the user needs to be redirected to the Event Deatils page
    isVolunteerEvent(recordId){
        if(recordId){
            this.navigateToEventDetailsPage(recordId);
        }
    }

    /****************** NAVIGATION METHODS (HELPERS) ********************************************** */
    //Redirect Users to the login page
    navigateToLoginPage(){
        this[NavigationMixin.Navigate]({
            type:'comm__namedPage',
            attributes:{
                name: 'Authorize__c',
            },
        });
    }

    //Redirect users to the EVent Details.(This happens when users searchs using the search bar
    //or when users click an event from a List View)
    navigateToEventDetailsPage(recordId){
        this[NavigationMixin.Navigate]({
            type:'comm__namedPage',
            attributes: {
                name: 'Event_Details__c',
            }, 
            state: {
                eventId: recordId
            }
        });
    }
}