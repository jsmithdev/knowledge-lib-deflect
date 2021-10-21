import { api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Articles extends NavigationMixin(LightningElement) {
    
    @api articles = []

    navToArticle(event){

        const urlName = event.target.name
        const articleType = 'Standard'
        //const articleType = 'Knowledge__kav'

        console.log(urlName, articleType)

        this[NavigationMixin.Navigate]({
            type: 'standard__knowledgeArticlePage',
            attributes: {
                articleType,
                urlName,
            },
        });
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