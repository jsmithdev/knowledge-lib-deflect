import { 
    api,
    LightningElement, 
} from 'lwc';

export default class Paginator extends LightningElement {

    @api index = 0
    @api end = 0

    next(){
        this.dispatchEvent(new CustomEvent('next', {
            detail: {
                value: this.index
            }
        }))
    }
    previous(){
        this.dispatchEvent(new CustomEvent('previous', {
            detail: {
                value: this.index
            }
        }))
    }
    
}