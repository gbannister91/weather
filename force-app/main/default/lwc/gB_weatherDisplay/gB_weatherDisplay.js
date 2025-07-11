import { LightningElement,api,wire} from 'lwc';
import getWeatherForContact from '@salesforce/apex/GB_weatherAccessor.getWeatherForContact';
import { subscribe, unsubscribe } from "lightning/empApi";

export default class GB_weatherDisplay extends LightningElement {

    @api weatherUnavailable = false;
    @api isLoading = false;
    @api isRefreshing = false;
    temperature;
    iconURL;
    description;
    parameter;
	addressUpdateSubscription = {};
	updatePlatformEvent = '/event/GB_addressUpdated__e';
    @api recordId;
    //Replace with apex
    /*@wire(getRecord, { recordId: '$recordId', fields: FIELDS })
        wiredContact({ error, data }) {
            if (error) {
                //to do - show toast, handle error etc
            } else if (data) {
                this.parameter = data.fields.MailingPostalCode?data.fields.MailingPostalCode.replaceAll(" ",""):data.fields.MailingCity;
            }
        }*/

    connectedCallback() {
        this.isLoading = true;
        this.getWeather();
        this.handleSubscribeToAddressUpdateEvent();
    }

    getWeather() {
        getWeatherForContact({contactId:this.recordId,
                            makeCallout:false
        })
            .then((response) => {
                if(!response) {
                    this.weatherUnavailable = true;
                }
                else
                {
                    this.temperature = response.GB_Temperature__c;
                    this.description = response.GB_Description__c;
                    this.iconURL = response.GB_iconUrl__c;
                }
                this.isLoading = false;
            })
            .catch((error)=> {
                this.isLoading = false;
            })
    }

    refreshWeather() {
        this.isRefreshing = true;
        getWeatherForContact({contactId:this.recordId,
                            makeCallout:true
        })
        .then((response) => {
                if(!response) {
                    this.weatherUnavailable = true;
                }
                else
                {
                    this.temperature = response.GB_Temperature__c;
                    this.description = response.GB_Description__c;
                    this.iconURL = response.GB_iconUrl__c;
                }
                this.isRefreshing = false;
            })
            .catch(()=> {
                this.isRefreshing = false;
            })
    }

    handleSubscribeToAddressUpdateEvent() {
		const messageCallback = (response) => {
			// Check if the platform event corresponds to the current record
			if (response.data.payload.GB_contactId__c === this.recordId) {
				this.getWeather();
			}
		};
		subscribe(this.updatePlatformEvent, -1, messageCallback).then(
			(response) => {
				this.addressUpdateSubscription = response;
			}
		);
	}

    disconnectedCallback() {
        this.handleUnsubscribeFromAddressUpdateEvent();
    }

	handleUnsubscribeFromAddressUpdateEvent() {
		unsubscribe(this.addressUpdateSubscription, () => {});
	}
}
