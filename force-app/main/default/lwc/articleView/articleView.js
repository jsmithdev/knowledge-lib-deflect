import { 
    api,
    track,
    LightningElement
} from 'lwc';

import getTopLevelQuestions from '@salesforce/apex/Article.getTopLevelQuestions'
import createVisit from '@salesforce/apex/Article.createVisit'
import createQuestionTrack from '@salesforce/apex/Article.createQuestionTrack'
import createArticleTrack from '@salesforce/apex/Article.createArticleTrack'
import updateArticleTrack from '@salesforce/apex/Article.updateArticleTrack'
import updateArticleTrackCaseId from '@salesforce/apex/Article.updateArticleTrackCaseId'
import updateFileParentId from '@salesforce/apex/Article.updateFileParentId'
import updateVisitFnr from '@salesforce/apex/Article.updateVisitFnr'

import { toast } from './util';

export default class ArticleView extends LightningElement {

    @api icon
    @api title
    @api active
    
    @track loaded
    @track topLevelQuestions

    async connectedCallback(){

        console.log('connected')

        console.log(this.active)
        
        if(!this.active){ return }


        const [ questions, visit ] = await Promise.all([ getTopLevelQuestions(), this.createVisit() ])

        this.visit = visit

        this.topLevelQuestions = questions.map(q => ({...q}))

        this.loaded = true
    }

    async createVisit(articleId = ''){
        
        const args = {
            articleId,
            url: document.location.href
        }
        
        return createVisit( args )
    }

    async create(event){
        
        const { type } = event.detail

        if(type === 'question-tracking'){
            this.createQuestionTracking(event.detail)
        }
        else if(type === 'article-tracking'){
            this.createArticleTracking(event.detail)
        }
        else if(type === 'case-created'){
            this.updateArticleTracking(event.detail)
        }
        else if(type === 'closed-article'){
            this.updateArticleTracking('Closed')
        }
    }

    async createQuestionTracking(detail){

        const { questionId } = detail

        if(questionId === this.currentQuestion){ return }
        
        this.currentQuestion = questionId
        
        const args = {
            questionId,
            visitId: this.visit,
        }
        
        this.currentQuestionTrack = await createQuestionTrack( args )
    }

    async createArticleTracking(detail){

        const { articleId } = detail
        
        if(articleId === this.currentArticle){ return }
        
        this.currentArticle = articleId

        const args = {
            visitId: this.visit,
            articleId,
        }
        
        this.currentArticleTrack = await createArticleTrack( args )
    }

    
    async updateArticleTracking( outcome ){

        if(typeof outcome === 'object'){
            //case created

            const { 
                caseId, 
                documentId,
            } = outcome;

            console.log(documentId)

            await updateVisitFnr({ 
                visitId: this.visit,
                articleId: this.currentArticle,
                caseId: caseId,
                questionId: this.currentQuestion
            })
            
            const trackId = this.currentArticleTrack

            this.currentArticleTrack = await updateArticleTrackCaseId({ trackId, caseId })

            
            if(documentId){

                const linkId = await updateFileParentId({ documentId, caseId })

                console.log('linkId')
                console.log(linkId)
                console.log()
            }

            this.dispatchEvent( toast('Created Case, refreshing...', 'success') )

            this.refresh()
        }
        else {

            const trackId = this.currentArticleTrack

            //if closed after voting, do not overwrite vote
            if(this.voted && this.voted.article === trackId){ return }

            this.currentArticleTrack = await updateArticleTrack({ trackId, outcome })
        }
    }
    
    async vote( event ){


        const trackId = this.currentArticleTrack
        const { value } = event.detail

        const outcome = value ? 'Helpful' : 'Not Helpful'

        this.currentArticleTrack = await updateArticleTrack({ trackId, outcome })

        this.voted = {
            article: this.currentArticleTrack,
            vote: outcome
        }
    }

    refresh(){
        this.loaded = false
        //this.connectedCallback()
        location = `${location.protocol}//${location.hostname}`
    }
}