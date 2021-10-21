import { 
    api, 
    track, 
    LightningElement 
} from 'lwc';

import userId from '@salesforce/user/Id';


import { 
    toast, 
    capitalize,
} from './util';

import getChildQuestions from '@salesforce/apex/Article.getChildQuestions'
import getArticlesByQuestionId from '@salesforce/apex/Article.getArticlesByQuestionId'


export default class ArticleLine extends LightningElement {

    @api userId = userId
    @api record
    @track active = false
    @track children = []
    @track articles
    @track showCase
    @track allowUploads = true
    @track filename = ''

    documentId

    async onclick(event){

        event.cancelBubble = true
        
        if(this.active){
            this.active = false
            return
        }

        this.active = true

        const { Id } = this.record
        
        this.children = await getChildQuestions({ uid: Id })

        if(!this.children.length){

            this.articles = await getArticlesByQuestionId({ uid: Id })
        }

        this.dispatch('create', { 
            type: 'question-tracking',
            questionId: Id 
        })
    }

    createArticleTracking(event){

        const { uid } = event.target.dataset

        this.dispatch('create', {
            type: 'article-tracking',
            articleId: uid,
        })
    }

    toggleCase(){
        this.showCase = this.showCase ? false : true
    }
    createdCase(event){

        const { id } = event.detail

        this.dispatch('create', {
            type: 'case-created',
            caseId: id,
            documentId: this.documentId,
        })

    }


    handleClosedModal( event ){

        this.dispatch('create', {
            type: 'closed-article',
        })
    }
    handleUploadFinished( event ){

        console.log(JSON.parse(JSON.stringify({ 
            detail: event.detail,
        })))

        this.documentId = event.detail.files[0].documentId
        this.filename = event.detail.files[0].name

        this.allowUploads = false
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

    passthrough( event ){}
}