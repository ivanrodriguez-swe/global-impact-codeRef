/**
 * This javascript file loads Volunteer Events based on the current's User Location
 * @author Ivan A. Rodriguez
 */
import { LightningElement, wire} from 'lwc';
//import Id from '@salesforce/user/Id'
import getVolunteerEvents from '@salesforce/apex/VolunteerEventsDatatableController.getVolunteerEvents';
import getRegisteredEvents from '@salesforce/apex/VolunteerEventsDatatableController.getRegisteredEvents';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';
//GETTING CUSTOM LABELS
import NOT_REGISTERED_FOR_EVENT_LABEL from '@salesforce/label/c.Not_Registered_For_Event';
import NO_EVENTS_IN_AREA_LABEL from '@salesforce/label/c.No_Events_In_Area';
import DEREGISTER_CONTENT_LABEL from '@salesforce/label/c.GID_2021_Deregister_Content';
import ABOUT_THE_NONPROFIT_LABEL from '@salesforce/label/c.Volunteer_Event_About_The_Nonprofit_Label';
import ADDITIONAL_INFORMATION_LABEL from '@salesforce/label/c.Volunteer_Event_Additional_Information_Label';
import EVENT_ADDRESS_LABEL from '@salesforce/label/c.Volunteer_Event_Address_Label';
import AVAILABLE_REGISTRATION_SPOTS_LABEL from '@salesforce/label/c.Volunteer_Event_Available_Registration_Spots_Label';
import COVID_REQUIREMENTS_LABEL from '@salesforce/label/c.Volunteer_Event_Covid_Requirements_Label';
import EVENT_DESCRIPTION_LABEL from '@salesforce/label/c.Volunteer_Event_Description_Label';
import START_TIME_LABEL from '@salesforce/label/c.Volunteer_Event_Start_Time_Label';
import END_TIME_LABEL from '@salesforce/label/c.Volunteer_Event_End_Time_Label';
import LEAD_LABEL from '@salesforce/label/c.Volunteer_Event_Lead_Label';
import EVENT_NAME_LABEL from '@salesforce/label/c.Volunteer_Event_Name_Label';
import SUPPLIES_NEEDED_LABEL from '@salesforce/label/c.Volunteer_Event_Supplies_Needed_Label';
import SUPPLIES_ON_SITE_LABEL from '@salesforce/label/c.Volunteer_Event_Supplies_On_Site_Label';
import VOLUNTEER_REQUIREMENTS_LABEL from '@salesforce/label/c.Volunteer_Requirements_Label';
import REGISTER_BUTTON_LABEL from '@salesforce/label/c.Volunteer_Event_Register_Button';
import DEREGISTER_BUTTON_LABEL from '@salesforce/label/c.Volunteer_Event_Deregister_Button';
import CANCEL_BUTTON_LABEL from '@salesforce/label/c.Volunteer_Event_Cancel_Button';
import T_SHIRT_SIZE_LABEL from '@salesforce/label/c.Volunteer_T_Shirt_Size_Label';
import T_SHIRT_PLACEHOLDER_LABEL from '@salesforce/label/c.Volunteer_T_Shirt_Placeholder_Label';
import EVENT_GLOBAL_IMPACT_HEADER_LABEL from '@salesforce/label/c.Volunteer_Event_Global_Impact_Header_Label';
import AVAILABLE_EVENTS_HEADER_LABEL  from '@salesforce/label/c.Volunteer_Event_Available_Sites_Header_Label';
import EVENT_GLOBAL_IMPACT_RECORD_LABEL from '@salesforce/label/c.Volunteer_Event_Global_Impact_Record_Label';
import SHOW_DETAILS_LABEL from '@salesforce/label/c.Volunteer_Event_Show_Details_Button_Label';
import NO_OTHER_EVENTS_AVAILABLE_LABEL from '@salesforce/label/c.Volunteer_Events_No_Available';

//Columns in datatable
const columns = [
                {   
                    label: EVENT_NAME_LABEL, 
                    fieldName:'Name', 
                    wrapText: true,
                    hideDefaultActions: true
                },
                {   
                    label: EVENT_ADDRESS_LABEL, 
                    fieldName:'Event_Address__c',
                    wrapText: true,
                    hideDefaultActions: true},
                {   
                    label: START_TIME_LABEL,
                    type: 'date', 
                    fieldName:'Start_Time__c',
                    typeAttributes:{
                        year: "numeric",
                        month: "short",
                        day: "2-digit",
                        hour: "2-digit",
                        minute: "2-digit"
                    },
                    wrapText: true,
                    hideDefaultActions: true
                },
                {   
                    label: END_TIME_LABEL,
                    fieldName:'End_Time__c', 
                    type: 'date',
                    typeAttributes:{
                        year: "numeric",
                        month: "short",
                        day: "2-digit",
                        hour: "2-digit",
                        minute: "2-digit"
                    },
                    wrapText: true,
                    hideDefaultActions: true
                },
                {
                    type:'button',
                    typeAttributes: {
                        label: SHOW_DETAILS_LABEL
                    }
                }
];
export default class VolunteerEventsDatatable extends NavigationMixin(LightningElement) {
    //@api userId=Id;
    contactId;
    // This field is used so we can rendered the second table only if the first one was rendered
    myContactId;
    columns=columns;
    //Returned Volunteer Event records available for this user
    availableEvents;
    noEvents;
    //Returned event for which the user is registered
    registeredEvents;
    //Variables to control table display
    noRegisteredEvents;
    displayDatatables;
    noOtherAvailableEvents;
    showAvailableEvents;
    label = {
        NOT_REGISTERED_FOR_EVENT_LABEL,
        NO_EVENTS_IN_AREA_LABEL,
        DEREGISTER_CONTENT_LABEL,
        ABOUT_THE_NONPROFIT_LABEL,
        ADDITIONAL_INFORMATION_LABEL,
        EVENT_ADDRESS_LABEL,
        AVAILABLE_REGISTRATION_SPOTS_LABEL,
        COVID_REQUIREMENTS_LABEL,
        EVENT_DESCRIPTION_LABEL,
        START_TIME_LABEL,
        END_TIME_LABEL,
        LEAD_LABEL,
        EVENT_NAME_LABEL,
        SUPPLIES_NEEDED_LABEL,
        SUPPLIES_ON_SITE_LABEL,
        VOLUNTEER_REQUIREMENTS_LABEL,
        REGISTER_BUTTON_LABEL,
        DEREGISTER_BUTTON_LABEL,
        CANCEL_BUTTON_LABEL,
        T_SHIRT_SIZE_LABEL,
        T_SHIRT_PLACEHOLDER_LABEL,
        EVENT_GLOBAL_IMPACT_HEADER_LABEL,
        AVAILABLE_EVENTS_HEADER_LABEL,
        EVENT_GLOBAL_IMPACT_RECORD_LABEL,
        SHOW_DETAILS_LABEL,
        NO_OTHER_EVENTS_AVAILABLE_LABEL
    }

    connectedCallback(){
        if(sessionStorage.getItem('contactId')){
            this.contactId =sessionStorage.getItem('contactId');
        }
    }
    @wire(getVolunteerEvents,{contactId:'$contactId'})
    wiredVolunteerEvents({error,data}){
        if(data){
            this.error=undefined;
            this.availableEvents = data;
            this.myContactId = this.contactId;
        }else if(error){
            data = undefined;
            this.dispatchEvent(
                new ShowToastEvent(
                {
                    title: 'Error displaying Events: ',
                    message: error.body.message,
                    variant: 'error'
                })
            )
        }
    }

    @wire(getRegisteredEvents,{contactId:'$myContactId'})
       wiredRegisteredEvents({error,data}){
       if(data){
           this.error=undefined;
           this.registeredEvents = data;
           if(this.registeredEvents.length === 0){
               this.noRegisteredEvents = true;
               if(this.availableEvents.length ===0){
                    this.noEvents = true;
                }else{
                    this.displayDatatables = true;
                    this.showAvailableEvents = true;
                }
           }else{
               this.displayDatatables = true;
           }
       }else if(error){
           data = undefined;
           this.dispatchEvent(
               new ShowToastEvent(
               {
                   title: 'Error displaying Events: ',
                   message: error.body.message,
                   variant: 'error'
               })
           )
       }
   }

    

    handleRowAction(event){
        const rowId = event.detail.row.Id;
        this[NavigationMixin.Navigate]({
            type:'comm__namedPage',
            attributes: {
                name: 'Event_Details__c',
            }, 
            state: {
                eventId: rowId
            }
        });
    }
}