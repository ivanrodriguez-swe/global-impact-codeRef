import { LightningElement, wire} from 'lwc';
//GETTING EVENT'S FIELDS FROM SCHEMA
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import LEADER_FIRST_NAME from '@salesforce/schema/Volunteer_Event__c.Lead__r.FirstName';
import LEADER_LAST_NAME from '@salesforce/schema/Volunteer_Event__c.Lead__r.LastName';
//GETTING Contact Info from schema
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import PEFERRED_LANGUAGE from '@salesforce/schema/Contact.Global_Impact_Preferred_Email_Language__c';
//import LEADER_MIDDLE_NAME from '@salesforce/schema/Volunteer_Event__c.Lead__r.MiddleName';
import EVENT_NAME from '@salesforce/schema/Volunteer_Event__c.Name';
import EVENT_ADDRESS from '@salesforce/schema/Volunteer_Event__c.Event_Address__c';
import EVENT_START_TIME from '@salesforce/schema/Volunteer_Event__c.Start_Time__c';
import EVENT_END_TIME from '@salesforce/schema/Volunteer_Event__c.End_Time__c';
import VOLUNTEER_EVENT_ATTENDEE_T_SHIRT_SIZES_FIELD from '@salesforce/schema/Volunteer_Event_Attendee__c.T_Shirt_Size__c';
import ADDITIONAL_INFORMATION from '@salesforce/schema/Volunteer_Event__c.Additional_Information__c';
import ABOUT_NONPROFIT from '@salesforce/schema/Volunteer_Event__c.About_The_Nonprofit__c';
import ABOUT_NONPROFIT_ES from '@salesforce/schema/Volunteer_Event__c.About_The_Nonprofit_es__c';
import ABOUT_NONPROFIT_VI from '@salesforce/schema/Volunteer_Event__c.About_The_Nonprofit_vi__c';
import EVENT_DESCRIPTION from '@salesforce/schema/Volunteer_Event__c.Event_Description__c';
import EVENT_DESCRIPTION_ES from '@salesforce/schema/Volunteer_Event__c.Event_Description_es__c';
import EVENT_DESCRIPTION_VI from '@salesforce/schema/Volunteer_Event__c.Event_Description_vi__c';
import VOLUNTEER_REQUIREMENTS from '@salesforce/schema/Volunteer_Event__c.Volunteer_Requirements__c';
import VOLUNTEER_REQUIREMENTS_ES from '@salesforce/schema/Volunteer_Event__c.Volunteer_Requirements_es__c';
import VOLUNTEER_REQUIREMENTS_VI from '@salesforce/schema/Volunteer_Event__c.Volunteer_Requirements_vi__c';
import COVID_REQUIREMENTS from '@salesforce/schema/Volunteer_Event__c.Covid_Requirements__c';
import COVID_REQUIREMENTS_ES from '@salesforce/schema/Volunteer_Event__c.Covid_Requirements_es__c';
import COVID_REQUIREMENTS_VI from '@salesforce/schema/Volunteer_Event__c.Covid_Requirements_vi__c';
import AVAILABLE_SPOTS from '@salesforce/schema/Volunteer_Event__c.Available_Spots__c';

//GETTING EPEX METHODS AND REQUIRED MODULES
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import registerToEvent from '@salesforce/apex/VolunteerEventDetailsController.registerToEvent';
import deregisterFromEvent from '@salesforce/apex/VolunteerEventDetailsController.deregisterFromEvent';
import getEventInformation from '@salesforce/apex/VolunteerEventDetailsController.getEventInformation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
//GETTING CUSTOM LABELS
import TERMS_AND_CONDITIONS_ACCEPTANCE_LABEL from '@salesforce/label/c.GID_2021_Terms_Conditions_Acceptance';
import DEREGISTER_CONTENT_LABEL from '@salesforce/label/c.GID_2021_Deregister_Content';
import ABOUT_THE_NONPROFIT_LABEL from '@salesforce/label/c.Volunteer_Event_About_The_Nonprofit_Label';
import ADDITIONAL_INFORMATION_LABEL from '@salesforce/label/c.Volunteer_Event_Additional_Information_Label';
import EVENT_ADDRESS_LABEL from '@salesforce/label/c.Volunteer_Event_Address_Label';
import AVAILABLE_SPOTS_LABEL from '@salesforce/label/c.Volunteer_Event_Available_Registration_Spots_Label';
import COVID_REQUIREMENTS_LABEL from '@salesforce/label/c.Volunteer_Event_Covid_Requirements_Label';
import EVENT_DESCRIPTION_LABEL from '@salesforce/label/c.Volunteer_Event_Description_Label';
import START_TIME_LABEL from '@salesforce/label/c.Volunteer_Event_Start_Time_Label';
import END_TIME_LABEL from '@salesforce/label/c.Volunteer_Event_End_Time_Label';
import LEAD_LABEL from '@salesforce/label/c.Volunteer_Event_Lead_Label';
import EVENT_NAME_LABEL from '@salesforce/label/c.Volunteer_Event_Name_Label';
import VOLUNTEER_REQUIREMENTS_LABEL from '@salesforce/label/c.Volunteer_Requirements_Label';
import REGISTER_BUTTON_LABEL from '@salesforce/label/c.Volunteer_Event_Register_Button';
import DEREGISTER_BUTTON_LABEL from '@salesforce/label/c.Volunteer_Event_Deregister_Button';
import CANCEL_BUTTON_LABEL from '@salesforce/label/c.Volunteer_Event_Cancel_Button';
import T_SHIRT_SIZE_LABEL from '@salesforce/label/c.Volunteer_T_Shirt_Size_Label';
import T_SHIRT_PLACEHOLDER_LABEL from '@salesforce/label/c.Volunteer_T_Shirt_Placeholder_Label';
import EVENT_GLOBAL_IMPACT_HEADER_LABEL from '@salesforce/label/c.Volunteer_Event_Global_Impact_Header_Label';
import AVAILABLE_EVENTS_HEADER_LABEL  from '@salesforce/label/c.Volunteer_Event_Available_Sites_Header_Label';
import EVENT_GLOBAL_IMPACT_RECORD_LABEL from '@salesforce/label/c.Volunteer_Event_Global_Impact_Record_Label';
import EVENT_FULL_BANNER from '@salesforce/label/c.Volunteer_Event_Full_Banner_Label';
import EVENT_CLOSED_BANNER from '@salesforce/label/c.Volunteer_Event_Closed_Banner_Label';
import EVENT_PREFERRED_LANGUAGE from '@salesforce/label/c.Volunteer_Event_Preferred_Language';
import PREFERRED_LANGUAGE_PLACEHOLDER from '@salesforce/label/c.Volunteer_Preferred_Language_Placeholder';
import LANGUAGE from '@salesforce/i18n/lang';

const FIELDS = [
    LEADER_FIRST_NAME,
    LEADER_LAST_NAME,
    EVENT_NAME,
    EVENT_ADDRESS,
    EVENT_START_TIME,
    EVENT_END_TIME,
    ADDITIONAL_INFORMATION,
    ABOUT_NONPROFIT,
    ABOUT_NONPROFIT_ES,
    ABOUT_NONPROFIT_VI,
    EVENT_DESCRIPTION,
    EVENT_DESCRIPTION_ES,
    EVENT_DESCRIPTION_VI,
    VOLUNTEER_REQUIREMENTS,
    VOLUNTEER_REQUIREMENTS_ES,
    VOLUNTEER_REQUIREMENTS_VI,
    COVID_REQUIREMENTS,
    COVID_REQUIREMENTS_ES,
    COVID_REQUIREMENTS_VI,
    AVAILABLE_SPOTS
];
export default class VolunteerEventDetails extends NavigationMixin(LightningElement) {
    //@api ;
    objectApiName = 'Volunteer_Event__c';
    eventDetails = new Map();
    currentPageReference;
    currentEventId;
    myEventId;
    eventAttendeeDetails = new Map();
    registered = false;
    noRegistered = false;
    //exposing labels
    wiredIsRegisteredResult;
    availableSizes = [];
    availableLanguages = [];
    tShirtSizeSelected = '';
    languageSelected = '';
    label = {
        TERMS_AND_CONDITIONS_ACCEPTANCE_LABEL,
        DEREGISTER_CONTENT_LABEL,
        ABOUT_THE_NONPROFIT_LABEL,
        ADDITIONAL_INFORMATION_LABEL,
        EVENT_ADDRESS_LABEL,
        AVAILABLE_SPOTS_LABEL,
        COVID_REQUIREMENTS_LABEL,
        EVENT_DESCRIPTION_LABEL,
        START_TIME_LABEL,
        END_TIME_LABEL,
        LEAD_LABEL,
        EVENT_NAME_LABEL,
        VOLUNTEER_REQUIREMENTS_LABEL,
        REGISTER_BUTTON_LABEL,
        DEREGISTER_BUTTON_LABEL,
        CANCEL_BUTTON_LABEL,
        T_SHIRT_SIZE_LABEL,
        T_SHIRT_PLACEHOLDER_LABEL,
        EVENT_GLOBAL_IMPACT_HEADER_LABEL,
        AVAILABLE_EVENTS_HEADER_LABEL,
        EVENT_GLOBAL_IMPACT_RECORD_LABEL,
        EVENT_FULL_BANNER,
        EVENT_CLOSED_BANNER,
        EVENT_PREFERRED_LANGUAGE,
        PREFERRED_LANGUAGE_PLACEHOLDER,
    }
    //To store Pulled info form the getRecord
    eventRecord;
    eventName;
    eventAddress;
    eventStartTime;
    eventEndTime;
    eventLeaderName;
    eventAdditionalInformation;
    eventAboutNonprofit;
    eventDescription;
    volunteerRequirements;
    covidRequirements;
    availableSpots;

    //Variables to display and set Banner's message
    showBanner;
    bannerMessage;

    //Variable tos tore the Employee - Contact record type id
    contactRecordTypeId;

    @wire(CurrentPageReference)
    wireCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        if(currentPageReference.state.eventId){
            this.currentEventId = currentPageReference.state.eventId;
            this.eventAttendeeDetails.contactId = sessionStorage.getItem('contactId');
            this.eventAttendeeDetails.eventId = this.currentEventId;
            this.myEventId = this.currentEventId;
        }
    }
  
    @wire(getRecord, {recordId: '$myEventId',fields: FIELDS})
    wiredEvent({error,data}){
        if(error){
            this.dispatchEvent(
                new ShowToastEvent(
                    {
                        title:'Error When Loading Current Event',
                        message: error.body.message,
                        variant:'error'
                    }
                )
            )
        }else if(data){
            this.eventRecord = data;
            this.eventName = getFieldValue(this.eventRecord,EVENT_NAME);
            this.eventAddress = getFieldValue(this.eventRecord,EVENT_ADDRESS);
            this.eventStartTime = getFieldValue(this.eventRecord,EVENT_START_TIME);
            this.eventEndTime = getFieldValue(this.eventRecord,EVENT_END_TIME);
            this.eventAdditionalInformation = getFieldValue(this.eventRecord,ADDITIONAL_INFORMATION);
            let firstName = getFieldValue(this.eventRecord,LEADER_FIRST_NAME);
            this.availableSpots = getFieldValue(this.eventRecord,AVAILABLE_SPOTS)
            //let middleName = this.eventRecord.fields.Lead__r.MiddleName.value;
            let lastName = getFieldValue(this.eventRecord,LEADER_LAST_NAME);
            let initial = lastName.substring(0,1);
            this.eventLeaderName = firstName.concat(' ',initial,'.');
            this.setTranslatedFields(this.eventRecord);
        }
    }

    // Getting Tshirt picklist values
    @wire(getPicklistValues,
        {
            recordTypeId: '012000000000000AAA',
            fieldApiName: VOLUNTEER_EVENT_ATTENDEE_T_SHIRT_SIZES_FIELD
        })
    wiredPicklistValues(value) {
        let { data, error } = value;
        if (error) {
            data = undefined;
            //console.log(error);
            this.dispatchEvent(
                new ShowToastEvent(
                    {
                        title: 'Error Picklist Values ',
                        message: error.body.message,
                        variant: 'error'
                    })
            )

        } else {
            if (data) {
                //console.log(`Successfullly loaded picklist values`);
                this.availableSizes = data.values;
            }

        }
    }

    //Getting Employee - Contact recordTypeId
    @wire(getObjectInfo, {objectApiName: CONTACT_OBJECT})
    wiredObject({error,data}){
        if(data){
            const rtIds = data.recordTypeInfos;
            this.contactRecordTypeId = Object.keys(rtIds).find(rti => rtIds[rti].name === 'Employee - Contacts');
        } else if (error){
            console.log('Error Retrieving COntact Metadata Info: '+error);
        }
    }

    //Getting Picklist for Preferred Language on contact
    @wire(getPicklistValues,
        {
            recordTypeId: '$contactRecordTypeId',
            fieldApiName: PEFERRED_LANGUAGE
        })
    wiredValues(value) {
        let { data, error } = value;
        if (error) {
            data = undefined;
            //console.log(error);
            this.dispatchEvent(
                new ShowToastEvent(
                    {
                        title: 'Error Picklist Values ',
                        message: error.body.message,
                        variant: 'error'
                    })
            )

        } else {
            if (data) {
                console.log(`Successfullly loaded picklist values`);
                this.availableLanguages = data.values;
            }

        }
    }
    @wire(getEventInformation, { eventAttendeeDetails: '$eventAttendeeDetails' })
    wireResponse(value) {
        //Hold on to the provisioned result so we can refresh it later.
        this.wiredIsRegisteredResult = value;
        //Destructure the provisioned value
        let { data, error } = value;
        if (error) {
            data = undefined;
            if(this.eventAttendeeDetails.size !== 0){
                this.dispatchEvent(
                    new ShowToastEvent(
                        {
                            title: 'Error Retrieving Registration Status: ',
                            message: error.body.message,
                            variant: 'error'
                        })
                    )
            }
        } else {
            //Accessing data and convert it into a map
            for(let key in data){
                if(Object.prototype.hasOwnProperty.call(data,key)){
                    //this.eventDetails.push({value:data[key],key:key});
                    this.eventDetails[key] = data[key];
                }
            }
            if(this.eventDetails.closed){
                this.registered = false;
                this.noRegistered = false;
                this.showBanner=true;
                this.bannerMessage=this.label.EVENT_CLOSED_BANNER;
            }else if (this.eventDetails.registered) {
                this.registered = true;
                this.noRegistered = false;
            } else if(this.eventDetails.full){
                this.registered = false;
                this.noRegistered = false
                this.showBanner=true;
                this.bannerMessage=this.label.EVENT_FULL_BANNER;
            }else {
                this.registered = false;
                this.noRegistered = true;
            }

        }
    }

    submitFormToRegister() {
        this.showRegistrationModal();
    }

    submitFormToDeregister() {
        this.showDeregistrationModal();
    }
    //show Registration Modal
    showRegistrationModal() {
        const registrationModal = this.template.querySelector('c-modal.registration-modal');
        registrationModal.show();
    }
    //Hide Registration Modal 
    hideRegistrationModal() {
        const registrationModal = this.template.querySelector('c-modal.registration-modal');
        registrationModal.hide();
    }
    //Show Deregistration Modal
    showDeregistrationModal() {
        const deregistrationModal = this.template.querySelector('c-modal.deregistration-modal');
        deregistrationModal.show();
    }
    //Hide Deregistration Modal
    hideDeregistrationModal() {
        const deregistrationModal = this.template.querySelector('c-modal.deregistration-modal');
        deregistrationModal.hide();
    }
 
    //Register for an event
    registerToEvent() {
        //Validate if all fields were populated
        const allFieldsValid = [
            ...this.template.querySelectorAll(".modal-input-field"),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allFieldsValid) {
            this.eventAttendeeDetails.tShirtSize = this.tShirtSizeSelected;
            this.eventAttendeeDetails.preferredLanguage = this.languageSelected;
            this.register();

        } else {
            this.dispatchEvent(
                new ShowToastEvent(
                    {
                        title: 'Missing Fields',
                        message: 'Please, Select T-Shirt size and Accept Terms and Conditions',
                        variant: 'error'
                    })
            )
        }

    }
    //Set Preferred language based on selection
    handlePreferredLanguage(event){
        this.languageSelected = event.detail.value;
    }
    //Set T-Shirt size based on selection 
    handleTShirtSize(event) {
        this.tShirtSizeSelected = event.detail.value;
    }
    //calling the controller to register to the event
    register() {
        registerToEvent({ eventAttendeeDetails: this.eventAttendeeDetails })
            .then(() => {
                //hide registration modal
                this.hideRegistrationModal();
            })
            .then(() => {
               //Refreshing cache data of the Volunteer Datatable component
               window.location.reload();
            })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent(
                        {
                            title: 'Registration Succeed',
                            message: 'You have successfuly been registered',
                            variant: 'success'
                        })
                )
            })
            .then(() => {
                this.registered = true;
                this.noRegistered = false;
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent(
                        {
                            title: 'Registration Failed',
                            message: error.body.message,
                            variant: 'error'
                        })
                )
            });
    }

    //calling controller to deregister from Event
    deregister() {
        deregisterFromEvent({ eventAttendeeDetails: this.eventAttendeeDetails })
            .then(() => {
                this.hideDeregistrationModal();
            })
            .then(() => {
                //Refreshing cache data of the Volunteer Datatable component
               window.location.reload();
            })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent(
                        {
                            title: 'Deregistration Succeed',
                            message: 'You have successfuly been deregistered',
                            variant: 'success'
                        })
                )
            })
            .then(() => {
                this.registered = false;
                this.noRegistered = true;
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent(
                        {
                            title: 'Deregistration Failed',
                            message: error.body.message,
                            variant: 'error'
                        })
                )
            });
    }

    setTranslatedFields(eventRecord){
        if(LANGUAGE === 'es'){
            this.eventAboutNonprofit = getFieldValue(eventRecord,ABOUT_NONPROFIT_ES);
            this.eventDescription = getFieldValue(eventRecord,EVENT_DESCRIPTION_ES);
            this.volunteerRequirements = getFieldValue(eventRecord,VOLUNTEER_REQUIREMENTS_ES);
            this.covidRequirements = getFieldValue(eventRecord,COVID_REQUIREMENTS_ES);
        }else if( LANGUAGE === 'vi'){
            this.eventAboutNonprofit = getFieldValue(eventRecord,ABOUT_NONPROFIT_VI);
            this.eventDescription = getFieldValue(eventRecord,EVENT_DESCRIPTION_VI);
            this.volunteerRequirements = getFieldValue(eventRecord,VOLUNTEER_REQUIREMENTS_VI);
            this.covidRequirements = getFieldValue(eventRecord,COVID_REQUIREMENTS_VI);
        }else{
            this.eventAboutNonprofit = getFieldValue(eventRecord,ABOUT_NONPROFIT);
            this.eventDescription = getFieldValue(eventRecord,EVENT_DESCRIPTION);
            this.volunteerRequirements = getFieldValue(eventRecord,VOLUNTEER_REQUIREMENTS);
            this.covidRequirements = getFieldValue(eventRecord,COVID_REQUIREMENTS);
        }
        //Making sure that none of the fields are empty
        if(!this.eventAboutNonprofit){
            this.eventAboutNonprofit = getFieldValue(eventRecord,ABOUT_NONPROFIT);
        }
        if(!this.eventDescription){
            this.eventDescription = getFieldValue(eventRecord,EVENT_DESCRIPTION);
        }
        if(!this.volunteerRequirements){
            this.volunteerRequirements = getFieldValue(eventRecord,VOLUNTEER_REQUIREMENTS);
        }
        if(!this.covidRequirements){
            this.covidRequirements = getFieldValue(eventRecord,COVID_REQUIREMENTS);
        }
    }
}