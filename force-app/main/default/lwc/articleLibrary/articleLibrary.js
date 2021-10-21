
import { 
    api,
    track,
    LightningElement
} from 'lwc';

import { 
    toast,
    merge,
    cleanArticles,
} from './util';

import getAllArticles from '@salesforce/apex/Article.getAllArticles'
import getAllDataCategories from '@salesforce/apex/Article.getAllDataCategories'


export default class ArticleLibrary extends LightningElement {

    page_size = 5
    available_articles = []

    @api icon
    @api title
    
    @track index = 0
    @track sort = false
    @track query = false
    @track loaded = false
    @track all_articles = []
    @track selectedCategories = []


    get indexPage(){
        return this.index + 1
    }
    get endPage(){
        return this.available_articles.length > this.page_size 
            ? Math.ceil( this.available_articles.length / this.page_size)
            : 1
    }
    get articles(){

        if( this.all_articles.length === 0){ return [] }

        this.available_articles = this.all_articles

        if(this.query){
            this.available_articles = this.available_articles.filter(a => 
                a.Keywords.includes(this.query) || a.Title.toLowerCase().includes(this.query))
        }

        if(this.selectedCategories.length){
            this.available_articles = this.available_articles.filter(a => 
                this.selectedCategories.some(cate => 
                    a.Category.includes(cate)))
        }

        if(this.sort){

            if(this.sort === 'Best Rating'){
                this.available_articles = this.available_articles.sort((a,b) => b.Rating - a.Rating)
            }
            else if(this.sort === 'Most Viewed'){
                this.available_articles = this.available_articles.sort((a,b) => b.Views - a.Views)
            }
            else if(this.sort === 'Date'){
                this.available_articles = this.available_articles.sort((a,b) => b.Date - a.Date)
            }
        }

        const start = this.index === 0 
            ? this.index 
            : this.index * this.page_size

        const end = start + this.page_size

        return this.available_articles.slice( start, end )
    }

    async connectedCallback(){

        this.all_articles = await this.getAllArticles()

        this.categories = await this.getAllCategories()

        this.loaded = true
    }

    async getAllArticles(){

        return cleanArticles( await getAllArticles() )
    }

    async getAllCategories(){

        const { categories } = JSON.parse(await getAllDataCategories())

        return categories.map(cat => merge(cat))
    }

    sortArticles(event){

        const { value } = event.target

        this.sort = value
    }

    handleSearch(event){

        const { query } = event.detail

        console.log('query changed')
        console.log(query)

        this.index = 0

        this.query = query ? query.toLowerCase() : ''

        //this.debug()
    }

    nextPage(event){

        const { value } = event.detail

        console.log('nextPage changed')
        console.log(value)
        if( this.indexPage === this.endPage ){ return }
        this.index++

        //this.debug()
    }

    previousPage(event){

        const { value } = event.detail

        console.log('previousPage changed')
        console.log(value)

        if( this.index === 0 ){ return }

        this.index--

        //this.debug()
    }
    handlePageSize(event){

        const { value } = event.target

        console.log('handlePageSize changed')
        console.log(value)

        this.page_size = Number( value )

        this.index = 0

        //this.debug()
    }

    handleCategories(event){

        const { names, selected } = event.detail

        if(selected){
            names.map(name => {
                this.selectedCategories = this.selectedCategories.filter(val => val !== name).concat([name])
            })
        }
        else if(!selected){
            names.map(name => {
                this.selectedCategories = this.selectedCategories.filter(val => val !== name)
            })
        }

        //this.selectedCategories = selected
        //    ? this.selectedCategories.filter(val => val !== name).concat([name])
        //    : this.selectedCategories.filter(val => val !== name)

        console.log(JSON.parse(JSON.stringify({
            selected,
            names,
            selectedCategories: this.selectedCategories,
        })))
    }

    debug(){

        console.log(JSON.parse(JSON.stringify({
            index: this.index,
            indexPage: this.indexPage,
            endPage: this.endPage,
            articles: this.articles,
            available_articles: this.available_articles,
            all_articles: this.all_articles,
        })))
    }
}