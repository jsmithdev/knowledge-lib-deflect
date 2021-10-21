import { 
    track,
    LightningElement,
} from 'lwc';

export default class VotingThumbs extends LightningElement {
    
    @track value = undefined
    @track like__classList = ''
    @track dislike__classList = ''

    get opposite_value(){
        return this.value === undefined 
            ? false 
            : this.value === true
                ? false
                : true 
    }

    vote(event){

        const { type } = event.target.dataset

        const value = type === 'like' 
            ? true
            : type === 'dislike'
                ? false
                : undefined
                
        if(this.value === value || value === undefined){ return }

        this.value = value
        
        this.toggleClassList(value)
        this.dispatch(value)
    }

    dispatch(boolean){

        this.dispatchEvent(new CustomEvent('voted', {
            bubbles: true, 
            composed : true,
            detail: {
                value: boolean,
            }
        }))
    }

    toggleClassList(boolean){

        if(boolean){
            this.like__classList = 'active'
            this.dislike__classList = ''
        }
        else {
            this.like__classList = ''
            this.dislike__classList = 'active'
        }
    }
}
