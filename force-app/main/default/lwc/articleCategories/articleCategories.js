import { api, LightningElement } from 'lwc';

export default class ArticleCategories extends LightningElement {

    @api selected = false
    @api cssClass = ""
    @api categories = []
}