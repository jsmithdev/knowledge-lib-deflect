import { api, LightningElement } from 'lwc'

import { getAllChildrenNames } from './util'

export default class ArticleCategory extends LightningElement {

    @api category = {}
    @api active = false
    @api selected = false

    activate(){
        this.active = true
    }

    deactivate(){
        this.active = false
    }

    select(){

        this.selected = this.selected ? false : true

        this.dispatchEvent(new CustomEvent('selected', {
            bubbles: true,
            composed: true,
            detail: {
                selected: this.selected,
                names: getAllChildrenNames(this.category).map(x => x.replace(/_/g, ' ')),
            }
        }))
    }

    debug(){

        //console.log(JSON.parse(JSON.stringify({
        //    detail: {
        //        name: this.category.name,
        //        selected: this.selected,
        //        value: this.template.querySelector('lightning-input').checked
        //    }
        //})))
    }

}


