import { LightningElement } from 'lwc';
import validateEntry from '@salesforce/apex/GlobalImpactLoginController.validateEntry';
import requestCode from '@salesforce/apex/GlobalImpactLoginController.requestCode';
import { NavigationMixin } from 'lightning/navigation';
import LOGIN_INVALID_USERNAME from '@salesforce/label/c.Volunteer_Event_Login_Invalid_Username';
import LOGIN_INVALID_CODE from '@salesforce/label/c.Volunteer_Event_Login_Invalid_Code';
import LOGIN_HELP_TEXT from '@salesforce/label/c.GID_Login_Help_Text';
import ACCOUNT_LOCKED from '@salesforce/label/c.Volunteer_Event_Account_Locked_Message';
import ATTEMPTS_LEFT from '@salesforce/label/c.Volunteer_Event_Attempts_Left';
export default class GlobalImpactLogin extends NavigationMixin(LightningElement) {
    //Variable to store the url of the server that provides the IP of the current user
    serverProvider = 'https://api.ipify.org?format=jsonp='
    //IP address of the current user
    userIPAddress;
    //variable to send email and token to the Apex Controller
    userInfo;
    contactRecord;
    //Storing data entered by the user
    userEmail;
    // Error flag and message to display to user
    errorCheck = false;
    errorMessage;
    //Code entered by user 
    _enteredToken;
    //Control Displaying buttons
    showLoginButton = false;
    showRequestButton = true;
    //Control when to make the username read only
    disableUsername = false;
    //To see if it is an invalid contact
    invalidContact = false;
    //COntrol the place holder when the username is a read only
    usernameEntered = 'Email Address';
    label = {
        LOGIN_INVALID_USERNAME,
        LOGIN_INVALID_CODE,
        LOGIN_HELP_TEXT,
        ACCOUNT_LOCKED,
        ATTEMPTS_LEFT
    }

    renderedCallback() {
        sessionStorage.clear();
    }
    // This method calls the Apex controller and verifies if the Contact exists
    grantAccessProcess(event) {
        event.preventDefault();
        if(this.invalidContact === true){
            console.log('No User found');
            this.errorCheck = true;
            this.errorMessage = this.label.LOGIN_INVALID_CODE;
        }else{
            const inputs = [...this.template.querySelectorAll('input')];
            inputs.forEach((inp) => {
                if (inp.type === 'password') {
                    this._enteredToken = JSON.stringify(inp.value).replaceAll('"', '');
                }
            });
            this.userInfo = new Map();
            this.userInfo.userEmail = this.userEmail;
            this.userInfo.userToken = this._enteredToken;
            this.userInfo.sessionId = this.generateSessionId();
            this.getUserIPAddress(this.serverProvider)
                .then(response => {
                    this.ipAddress = JSON.stringify(response).replaceAll('"', '');
                    this.userInfo.userIpAddr = this.ipAddress;
                })
                .then(() => {
                    validateEntry({ userInfo: this.userInfo })
                        .then((data) => {
                            if (data === 'locked') {
                                console.log(`Account Locked`);
                                this.errorCheck = true;
                                this.errorMessage = this.label.ACCOUNT_LOCKED;
                                this.hideButtons();
                            } else if (data.substring(0, ('invalidRegex').length) === 'invalidRegex') {
                                console.log(`Invalid Regex in Requesting Code`);
                                this.errorCheck = true;
                                let attempts = data.substring(('invalidRegex').length, data.length);
                                this.errorCheck = true;
                                if (parseInt(attempts, 10) <= 0) {
                                    this.errorMessage = (this.label.LOGIN_INVALID_CODE).concat(this.label.ATTEMPTS_LEFT, ' 0');
                                } else {
                                    this.errorMessage = (this.label.LOGIN_INVALID_CODE).concat(this.label.ATTEMPTS_LEFT,' ', attempts);
                                }
                            } else if (data.substring(0, 3) === '003') {
                                //Setting Session Storage
                                sessionStorage.setItem('contactId', data);
                                sessionStorage.setItem('sessionId', this.userInfo.sessionId);
                                //Redirect users to the Home page
                                this[NavigationMixin.Navigate]({
                                    type: 'comm__namedPage',
                                    attributes: {
                                        name: 'Home',
                                    },
                                });
                            } else {
                                this.errorCheck = true;
                                const result = parseInt(data, 10);
                                if (result <= 0) {
                                    this.errorMessage = (this.label.LOGIN_INVALID_CODE).concat(this.label.ATTEMPTS_LEFT, ' 0');
                                    this.showLoginButton = false;
                                    this.showRequestButton = false;
                                } else {
                                    this.errorMessage = (this.label.LOGIN_INVALID_CODE).concat(this.label.ATTEMPTS_LEFT,' ', data);
                                }
                            }
                        })
                        .catch((error) => {
                            console.log('Error when validating Entry');
                            this.errorCheck = true;
                            //this.errorMessage = error.body.message;
                            this.errorMessage = `error: ${JSON.stringify(error)}`;

                        });
                })
                .catch((error) => {
                    this.errorCheck = true;
                    //this.errorMessage = error.body.message;
                    this.errorMessage = `errod: ${JSON.stringify(error)}`;
                })
        }
    }

    //This method requests the generation of the code
    requestVolunteerCode(event) {
        event.preventDefault();
        const inputs = [...this.template.querySelectorAll('input')];
        inputs.forEach((inp) => {
            if (inp.type === 'email') {
                this.userEmail = JSON.stringify(inp.value).replaceAll('"', '');
            }
        });
        if (this.userEmail === '') {
            this.errorCheck = true;
            this.errorMessage = this.label.LOGIN_INVALID_USERNAME;
        } else {
            this.getUserIPAddress(this.serverProvider)
                .then(response => {
                    this.ipAddress = JSON.stringify(response).replaceAll('"', '');
                })
                .then(() => {
                    let userInfo = new Map();
                    userInfo.userEmail = this.userEmail;
                    userInfo.userIpAddr = this.ipAddress;
                    requestCode({ userInfo: userInfo })
                        .then((data) => {
                            if(data === 'invalidRegex'){
                                this.errorCheck = true;
                                this.errorMessage = this.label.LOGIN_INVALID_USERNAME;
                            } 
                            else if (data === 'locked') {
                                this.errorCheck = true;
                                this.errorMessage = this.label.ACCOUNT_LOCKED;
                                this.hideButtons();
                            } else {
                                if(data === null){
                                    this.invalidContact = true;
                                }
                                this.showLoginButton = true;
                                this.showRequestButton = false;
                                this.usernameEntered = this.userEmail;
                                this.disableUsername = true;
                                //Reset Error messages
                                this.errorMessage = '';
                                this.errorCheck = false;
                            }
                        })
                        .catch((error) => {
                            this.errorCheck = true;
                            this.errorMessage = JSON.stringify(error);
                        })
                })
                .catch((error) => {
                    this.errorCheck = true;
                    this.errorMessage = JSON.stringify(error);
                });
        }
    }

    hideButtons() {
        this.usernameEntered = this.userEmail;
        this.disableUsername = true;
        this.showLoginButton = false;
        this.showRequestButton = false;
    }
    generateSessionId() {
        return '_' + Math.random().toString(36).substring(2, 14);
    }

    //Promise to get the user Ip address
    getUserIPAddress(url) {
        return new Promise((resolve, reject) => {
            let request = new XMLHttpRequest();
            request.open('GET', url, true);
            request.onload = () => {
                if (request.status >= 200 && request.status < 400) {
                    resolve(request.response);
                } else {
                    reject(request.statusText);
                }
            };
            request.onerror = () => {
                reject(request.statusText);
            }
            request.send();
        });
    }


}