
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

/**
 * 
 * @param {String} str - String to capitalize the first character
 * @returns {String} String with first character capitalized
 */
export function capitalize(str){
    return str.charAt(0).toUpperCase() + str.slice(1)
}


/**
 * @param msg String message
 * @param type String variant to use [success, error, info, warning]
 * @returns {ShowToastEvent} Event ready to dispatch using this.dispatchEvent(event)
 */
export function toast(msg, type){

    const event = new ShowToastEvent({
        title: capitalize(type),
        message: msg,
        variant: type,
    });
    
    return event
}
