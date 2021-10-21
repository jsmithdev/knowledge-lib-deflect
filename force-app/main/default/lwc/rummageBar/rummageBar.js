
import { 
    api, 
    LightningElement, 
    track,
} from 'lwc'

/** Delay used to debounce event handlers before invoking Apex. */
const DELAY = 500;

export default class RummageBar extends LightningElement {

    @api label = 'Search'
    @api placeholder = 'Search'

    @track query = '';

    handleKeyChange(event) {

        window.clearTimeout(this.delayTimeout)

        this.query = event.target.value

        this.delayTimeout = setTimeout(() => {
            this.dispatchEvent(new CustomEvent('rummaged', {
                detail: {
                    query: this.query
                }
            }))
        }, DELAY)

        return true
    }
}