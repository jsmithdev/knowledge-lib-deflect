import { api, track, LightningElement } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class Modal extends LightningElement {

    @api header
    @api trigger
    @api value
    /**
     * @description {String} small | medium | large
     */
    @api variant
    
    @track loading
    @track active
    @track data = []


    is = 'modal'


    async show(){

        this.loading = true
        this.active = true

        this.loading = false
    }
    
    get modalClassList(){

        if(this.variant === 'large'){
            return 'slds-modal slds-fade-in-open slds-modal_large'
        }
        else if(this.variant === 'small')      {
            return 'slds-modal slds-fade-in-open slds-modal_small'
        }

        return 'slds-modal slds-fade-in-open slds-modal_medium'
    }

    close(){
        this.active = false
        this.dispatch('close')
    }

    error(type, message){
        this.toast(message, type, 'error')
    }

    toast( message = '', title = 'Info', variant = 'info') {
        
        const event = new ShowToastEvent({
            title,
            message,
            variant,
        })

        this.dispatchEvent(event)
    }
    /**
     * 
     * @param {String} name name of event
     * @param {Object} detail object to send
     */
    dispatch(name, detail = {}){

        this.dispatchEvent(new CustomEvent( name , {
            bubbles: true, 
            composed : true,
            detail
        }))
    }
}