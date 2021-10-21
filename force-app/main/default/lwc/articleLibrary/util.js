
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

/**
 * 
 * @param {String} str - String to capitalize the first character
 * @returns {String} String with first character capitalized
 */
export function capitalize(str){
    return str.charAt(0).toUpperCase() + str.slice(1)
}


/**
 * @param msg String message
 * @param type String variant to use [success, error, info, warning]
 * @returns {ShowToastEvent} Event ready to dispatch using this.dispatchEvent(event)
 */
export function toast(msg, type){

    const event = new ShowToastEvent({
        title: capitalize(type),
        message: msg,
        variant: type,
    });
    
    return event
}


/**
 * @param {Array} articles Array of articles that needs cleaned / formatted
 * 
 * @returns {ShowToastEvent} Event ready to dispatch using this.dispatchEvent(event)
 */
export function cleanArticles(articles){
    
    return articles.map(value => {

        const article = {
            Id: value.Id,
            Title: value.Title ? value.Title : '',
            Keywords: value.Key_Words__c ? value.Key_Words__c.toLowerCase() : '',
            Summary: value.Summary,
            UrlName: value.UrlName,
            Views: value.ArticleTotalViewCount,
            Date: value.LastModifiedDate ? new Date(value.LastModifiedDate).getTime() : 0,
            Date_DB: value.LastModifiedDate,
            Rating: value.Article_Link__r ? value.Article_Link__r.Rating__c : 0,
            Category: Array.isArray(value.DataCategorySelections) 
                ? value.DataCategorySelections.map(x => x.DataCategoryName.replace(/_/g, ' ')).join(', ') 
                : []
        }
        
        return article
    })
}

export function merge(entry){

    const item = {
        label: entry.label,
        name: entry.name,
        description: entry.desc,
    }

    const { children } = entry.children.find(x => x.name === 'All')

    item.children = children.map(child => grouper(child, entry))

    return item
}

function grouper(entry, group){

    const item = findSame(entry, group)

    if(item.children){
        item.children = item.children.map(child => grouper(child, group))
    }
    
    return item
}

function findSame(item, group){
    
    return group.children.find(x => x.name === item.name)
}
