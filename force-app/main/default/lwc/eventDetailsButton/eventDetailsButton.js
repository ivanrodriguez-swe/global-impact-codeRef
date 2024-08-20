import { LightningElement, api} from 'lwc';
import checkInAttendee from '@salesforce/apex/EventDetailsButtonController.checkInAttendee';
import checkInAll from '@salesforce/apex/EventDetailsButtonController.checkInAll';

export default class EventDetailsButton extends LightningElement {
    @api buttonVariant;
    @api buttonLabel;
    @api buttonTitle;
    @api buttonType;
    @api buttonStatus;
    @api attendeeRecords;
    @api buttonToShow;
    //This variable stores the attendee'd Id related to the button on the list of attendees displayed
    @api attendeeId;
    @api eventId;

    attendeeInfoMap = new Map();
    
    get buttonDisabled(){
        if(this.buttonToShow === 'check-in'){
            if(this.buttonStatus){
                return true;
            }
        }else if (this.buttonToShow === 'check-in-all'){
            if(this.buttonStatus){
                return true;
            }
        }
        return false;
    }

    handleClick(){
        if(this.buttonToShow === 'check-in'){
            let attendees = Object.values(this.attendeeRecords);
            for(let i=0;i<attendees.length;i++){
                let element = attendees[i];
                if(element.Id === this.attendeeId){
                    this.attendeeInfoMap.volunteerId=element.Id;
                    this.attendeeInfoMap.contactId=element.Attendee__c;
                    this.attendeeInfoMap.eventId = this.eventId;
                    //this.attendeeToCheckIn = (`${element}`);
                    //We do not need to go through the entire array
                    break;
                }
            }
            checkInAttendee({attendeeRecord: this.attendeeInfoMap})
            .then(()=>{
                this.dispatchEvent(new CustomEvent('checkin'));
            })
            .catch((error)=>{
                console.log(`Error: ${JSON.stringify(error)}`);
            });
            
        }else if(this.buttonToShow === 'check-in-all'){
            checkInAll({myEventId:this.eventId})
            .then(()=>{
                this.dispatchEvent(new CustomEvent('checkinall'));
            })
            .catch((error)=>{
                console.log(`Error: ${JSON.stringify(error)}`);
            })
            
        }
        
    }
}