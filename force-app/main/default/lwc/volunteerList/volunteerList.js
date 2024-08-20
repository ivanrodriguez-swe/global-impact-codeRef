import { LightningElement, wire } from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import {refreshApex} from '@salesforce/apex';
import getAttendeeList from '@salesforce/apex/VolunteerListController.getAttendeeList';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//IMPORT FIELDS
import SUPPLIES_NEEDED from '@salesforce/schema/Volunteer_Event__c.Supplies_Needed__c';
import SUPPLIES_ON_SITE from '@salesforce/schema/Volunteer_Event__c.Supplies_On_Site__c';
//IMPORT LABELS
import SUPPLIES_NEEDED_LABEL from '@salesforce/label/c.Volunteer_Event_Supplies_Needed_Label';
import SUPPLIES_ONSITE_LABEL from '@salesforce/label/c.Volunteer_Event_Supplies_On_Site_Label';
import VOLUNTEER_NAME_LABEL from '@salesforce/label/c.Volunteer_Event_Attendees_Name_Label';
import CHECK_IN_BUTTON_LABEL from '@salesforce/label/c.Volunteer_Event_Check_In_Button_Label';
import CHECK_IN_HEADER_LABEL from '@salesforce/label/c.Volunteer_Event_Check_In_Header_Label';
import CHECK_IN_ALL_BUTTON_LABEL from '@salesforce/label/c.Volunteer_Event_Check_In_All_Button_Label';
import CHECK_IN_LABEL from '@salesforce/label/c.Volunteer_Event_Check_In_Label';

const FIELDS = [
    SUPPLIES_NEEDED,
    SUPPLIES_ON_SITE
];
export default class VolunteerList extends LightningElement {
    //Variable to refresh apex when needed
    _wiredAttendeeList;
    //Variables that store info to find the related atteendees to the current event 
    eventId;
    contactId;
    //Map to send contactId and eventId
    eventInfo;
    //Temp variable to control executions of wired medthos
    tempEventInfo=new Map();
    //variable that stores the attendees of the current event 
    attendeeList = [];
    attendeeMap;
    //Labels
    label = {
        SUPPLIES_NEEDED_LABEL,
        SUPPLIES_ONSITE_LABEL,
        VOLUNTEER_NAME_LABEL,
        CHECK_IN_LABEL,
        CHECK_IN_HEADER_LABEL,
        CHECK_IN_ALL_BUTTON_LABEL,
        CHECK_IN_BUTTON_LABEL
    };
    //EVent Fields that can be seen only by Leads
    eventRecord;
    suppliesNeeded;
    suppliesOnSite;
    disabledCheckInAll;
    
    @wire(CurrentPageReference)
    wiredCurrentPageReference(currentPageReference){
        if(currentPageReference.state.eventId){
            this.eventId = currentPageReference.state.eventId;
            console.log(`Event Id from VolunteerList component: ${this.eventId}`);
            this.contactId = sessionStorage.getItem('contactId');
            //For testing purposes we will be using a contact
            //this.contactId = '0033K00000IdO9oQAF';
            this.tempEventInfo.contactId = this.contactId;
            this.tempEventInfo.eventId = this.eventId;
            this.eventInfo = this.tempEventInfo;
        }
        
    }
    @wire(getRecord, {recordId:'$eventId', fields:FIELDS})
    wiredEvents({error,data}){
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
            this.suppliesNeeded = getFieldValue(this.eventRecord,SUPPLIES_NEEDED);
            this.suppliesOnSite = getFieldValue(this.eventRecord, SUPPLIES_ON_SITE);
        }
    }
    
    @wire(getAttendeeList,{eventInfo: '$eventInfo'})
    wiredAttendeeListRecords(value){
        this._wiredAttendeeList = value;
        let returnedAttendees = [];
        let modifiedRecords =[];
        let {data,error}=value;
        if(data){
            console.log(`successfully found List of attendees for this leader`);
            this.attendeeMap = data;
            //Update variables
            returnedAttendees = this.attendeeMap.attendeeList;
            //Create a new property with the formatted name so we meet PII compliance
            returnedAttendees.forEach((att)=>{
                let element = {};
                let firstName = att.Attendee__r.FirstName;
                //let middleName = att.Attendee__r.MiddleName;
                let initialLastName = att.Attendee__r.LastName.substring(0,1);
                let formattedName;
                //if(middleName){
                   // formattedName = firstName.concat(' ',middleName,' ',initialLastName,'.');
                //}else{
                    formattedName = firstName.concat(' ',initialLastName,'.');
                //}

                console.log(`${formattedName}`)
                //adding new property to the object
                element.formattedName = formattedName;
                //Adding the other properties from the original object
                Object.assign(element,att);
                //pushing element to the new list
                modifiedRecords.push(element);
            })
            //assigning the list to the class variable so it can be read in the html file
            this.attendeeList = modifiedRecords;
            this.disabledCheckInAll = this.attendeeMap.disableCheckAllButton;
            console.log(`List of attendees: ${JSON.stringify(this.attendeeMap)}`);
        }else if(error){
            data = undefined;
            this.attendeeList = undefined;
        }else{
            console.log(`No records should be displayed`);
            data=undefined;
            this.attendeeList = undefined;
        }
    }   
    
    handleRefreshApex(){
        console.log(`Update cache to rendered update records`)
       return refreshApex(this._wiredAttendeeList);
    }
    
}