import { 
    api, 
    track, 
    LightningElement 
} from 'lwc';

export default class ArticleLines extends LightningElement {

    @api lines = []
    @api cssClass = ""

    passthrough( event ){}
}