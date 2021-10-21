public with sharing class Article {

    @AuraEnabled
    public static List<Deflection_Question__c> getTopLevelQuestions(){
        return [
            SELECT Id, Name, Question__c, Parent_Question__c, 
                Message_to_Display_to_User__c, Sort_Order__c
            FROM Deflection_Question__c
            WHERE Parent_Question__c = null
        ];
    }

    @AuraEnabled
    public static List<Deflection_Question__c> getChildQuestions(String uid){
        return [
            SELECT Id, Name, Question__c, Parent_Question__c, 
                Message_to_Display_to_User__c, Sort_Order__c
            FROM Deflection_Question__c
            WHERE Parent_Question__c = :uid
            ORDER BY Sort_Order__c ASC
        ];
    }

    @AuraEnabled
    public static List<Article_Link__c> getArticleLinksByQuestionId(String uid){
        return [
            SELECT Id, Article__c, Question__c
            FROM Article_Link__c 
            WHERE Question__c = :uid
        ];
    }
    
    @AuraEnabled
    public static List<Knowledge__kav> getArticles(List<Id> uids){
        return [
            SELECT Id, Article_Body__c, Title, PublishStatus, ArticleTotalViewCount 
            FROM Knowledge__kav 
            WHERE Id IN :uids
        ];
    }

    @AuraEnabled
    public static List<Knowledge__kav> getArticlesByQuestionId(String uid){

        List<Id> ids = new List<Id>();
        
        for(Article_Link__c link : Article.getArticleLinksByQuestionId(uid)){
            ids.add(link.Article__c);
        }

        return Article.getArticles(ids);
    }

    @AuraEnabled
    public static Article_Link__c getArticleByArticleId(String uid){

        return [
            SELECT Id, Article__c, Question__c
            FROM Article_Link__c 
            WHERE Article__c = :uid
            LIMIT 1
        ];
    }

    @AuraEnabled
    public static String createVisit(String articleId, String url){


        Visit__c visit = new Visit__c(
            Deflection_Question__c = articleId  == '' ? null : Article.getArticleByArticleId(articleId).Question__c,
            URL__c = url
        );
        
        insert visit;

        return visit.Id;
    }

    
    @AuraEnabled
    public static String createQuestionTrack(String visitId, String questionId){

        Question_Tracking__c track = new Question_Tracking__c(
            Deflection_Question__c = questionId,
            Visit__c = visitId
        );
        
        insert track;

        return track.Id;
    }
    
    @AuraEnabled
    public static String createArticleTrack(String visitId, String questionId, String articleId){

        Article_Link__c link = [SELECT ID FROM Article_Link__c WHERE Article__c = :articleId];

        Article_Tracking__c track = new Article_Tracking__c(
            //Outcome__c = asdf,
            //Case__c = asdf,
            Article_Link__c = link.Id,
            Visit__c = visitId,
            Article__c = articleId,
            Knowledge_Article_ID__c = articleId
        );
        
        insert track;

        return track.Id;
    }

    
    
    @AuraEnabled
    public static String updateArticleTrack( String trackId, String outcome ){

        Article_Tracking__c track = [
            SELECT Id, Outcome__c
            FROM Article_Tracking__c
            WHERE Id = :trackId
        ];
        
        track.Outcome__c = outcome;

        update track;

        return track.Id;
    }
    @AuraEnabled
    public static String updateArticleTrackCaseId( String trackId, String caseId ){

        Article_Tracking__c track = [
            SELECT Id, Case__c, Visit__c
            FROM Article_Tracking__c
            WHERE Id = :trackId
        ];
        
        track.Case__c = caseId;

        update track;

        if(track.Visit__c != null){
            Visit__c v = [SELECT ID, Case_Form_Opened__c FROM Visit__c WHERE ID = :track.Visit__c];
            v.Case_Form_Opened__c = true;
            update v;
        }

        return track.Id;
    }

    @AuraEnabled
    public static String updateFileParentId( String documentId, String caseId ){

        ContentDocumentLink link = new ContentDocumentLink(
            ContentDocumentId = documentId,
            LinkedEntityId = caseId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );

        insert link;

        return link.Id;
    }

    @AuraEnabled
    public static void updateVisitFnr( String visitId, String articleId, String caseId, String questionId ){

        Visit__c visit = [
            SELECT Id, Article__c, Case__c, Deflection_Question__c
            FROM Visit__c
            WHERE Id = :visitId
        ];

        visit.Article__c = articleId; 
        visit.Case__c = caseId; 
        visit.Deflection_Question__c = questionId; 

        update visit;
    }


    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getAllArticles(){
                
        return [
            SELECT Id, Summary, Title, UrlName, Key_Words__c, LastModifiedDate, ArticleTotalViewCount, Article_Link__r.Rating__c, ( SELECT dataCategoryName FROM DataCategorySelections ) 
            FROM Knowledge__kav 
            WHERE PublishStatus = 'Online' 
            AND IsVisibleInCsp = true 
            AND Language = 'en_US' 
            ORDER BY LastModifiedDate DESC NULLS LAST
            LIMIT 9000
        ];
    }

    /**
     * System.debug(Article.searchArticles('2020'));
     */
    @AuraEnabled(cacheable=true)
    public static List<List<SObject>> searchArticles(String query){
                
        return [
            FIND :query IN ALL FIELDS 
            RETURNING Knowledge__kav(
                toLabel(Title), toLabel(Summary), UrlName
                WHERE PublishStatus = 'Online'
                ORDER BY LastModifiedDate DESC
            ) 
        ];
    }



    /**
        System.debug(Article.getAllDataCategories());
    */
    @AuraEnabled(cacheable=true)
    public static String getAllDataCategories(){
       
        JSONGenerator gen = JSON.createGenerator(true);
    
        // Write data to the JSON string.
        gen.writeStartObject(); //{
        gen.writeFieldName( 'categories' );
        gen.writeStartArray();
        
        // Get the JSON string.
        //String pretty = gen.getAsString();

        List<String> objTypes = new List<String>{ 'KnowledgeArticleVersion' }; //, 'Question'

        //Creating a list of pair objects to use as a parameter for the describe call
        List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
         
         //Looping throught the first describe result to create
         //the list of pairs for the second describe call
         for(DescribeDataCategoryGroupResult singleResult : Schema.describeDataCategoryGroups(objTypes)){
            DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
            p.setSobject(singleResult.getSobject());
            p.setDataCategoryGroupName(singleResult.getName());

            
            pairs.add(p);
         }
        

         
         //describeDataCategoryGroupStructures()
         List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult = Schema.describeDataCategoryGroupStructures(pairs, false);
 
         //Getting data from the result
         for(DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult){
            //Get name of the associated Sobject
            //singleResult.getSobject();
 
            //Get the name of the data category group
            //singleResult.getName();
            //System.debug('singleResult.getName()');
            //System.debug(singleResult.getName());
 
            //Get the name of the data category group
            //singleResult.getLabel();
            //gen.writeFieldName( singleResult.getName() );

            gen.writeStartObject();
            //Get the description of the data category group
            gen.writeStringField('name', singleResult.getName());
            gen.writeStringField('label', singleResult.getLabel());
            gen.writeStringField('desc', singleResult.getDescription());
            gen.writeNumberField('group', 0);
            //gen.writeEndObject();

            //Get the top level categories
            DataCategory [] toplevelCategories = singleResult.getTopCategories();
            
            //Recursively get all the categories
            List<DataCategory> allCategories = getAllCategories(toplevelCategories);
 
            gen.writeFieldName( 'children' );
            gen.writeStartArray();

            for(DataCategory category : allCategories) {
               //Get the name of the category
               //category.getName();
               //System.debug('category.getName()');
               //System.debug(category.getName());
 
               //Get the label of the category
               //category.getLabel();

               //if('All' == category.getName()){ continue; }

               gen.writeStartObject();
               //Get the description of the data category group
               //gen.writeStringField('label', category.getLabel());
               //gen.writeStringField('desc', category.getDescription());

               //Get the list of sub categories in the category
                gen.writeStringField('name', category.getName());
                gen.writeStringField('label', category.getLabel());
                gen.writeNumberField('group', 1);
                gen.writeFieldName( 'children' );
                gen.writeStartArray();
                for(DataCategory childCategories : category.getChildCategories()){

                    //gen.writeFieldName( childCategories.getName() );
                    gen.writeStartObject();
                    //Get the description of the data category group
                    gen.writeStringField('name', childCategories.getName());
                    gen.writeStringField('label', childCategories.getLabel());
                    //gen.writeStringField('desc', childCategories.getDescription());
                    gen.writeEndObject();
                    //System.debug(childCategories.getLabel());
                    
                }
                gen.writeEndArray();
                gen.writeEndObject();
            }
            gen.writeEndArray();
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();

        return gen.getAsString();
    }

    private static DataCategory[] getAllCategories(DataCategory [] categories){
        
        if(categories.isEmpty()){
            return new DataCategory[]{};
        }
        else {
            DataCategory [] categoriesClone = categories.clone();
            DataCategory category = categoriesClone[0];
            DataCategory[] allCategories = new DataCategory[]{category};
            categoriesClone.remove(0);
            categoriesClone.addAll(category.getChildCategories());
            allCategories.addAll(getAllCategories(categoriesClone));
            return allCategories;
        }
    }




    /* 

    DATA POPULATION

    to change lookup to m.detail, current records must have field populated

    link Article_Tracking__c's to Article_Link__c
        - master detail, SUM(Rating), misc

    link Knowledge__kav to Article_Link__c


    System.debug(Article.linkArticleTracks());
    */
    public static String linkArticleTracks(){

        

        List<Article_Tracking__c> tracks = [
            SELECT id, Article__c, Article_Link__c
            FROM Article_Tracking__c
            WHERE Article_Link__c = null
            LIMIT 500
        ];
        System.debug(tracks.size()+ ' tracks');
        


        List<Id> ids = new List<Id>();
        for(Article_Tracking__c k : tracks){
            ids.add(k.Article__c);
        }
        System.debug(ids.size()+ ' ids');
        
        List<Article_Link__c> links = [
            SELECT id, Article__c
            from Article_Link__c
            where Article__c IN :ids
        ];
        System.debug(links.size()+ ' links');

        List<Article_Tracking__c> updates = new List<Article_Tracking__c>();

        for(Article_Tracking__c t : tracks){
            for(Article_Link__c l : links){
                if(t.Article__c == l.Article__c){
                    t.Article_Link__c = l.Id;
                    updates.add(t);
                    continue;
                }
            }
        }
    
        update updates;
        
        return updates.size()+ ' updates';
    }

    
    /* 
    System.debug(Article.dev_count());
    */
    public static String dev_count(){

        List<Article_Tracking__c> tracks = [
            select id, Article__c
            from Article_Tracking__c
            where Article__c = null
        ];
        System.debug(tracks.size()+ ' tracks');
    
        return tracks.size()+ ' tracks';
    }


    
    /* 
    System.debug(Article.linkArticlesWithLinks());
    */
    public static String linkArticlesWithLinks(){

        List<Knowledge__kav> toUpdate = new List<Knowledge__kav>();

        List<Article_Link__c> links = [
            SELECT Id, Article__c
            FROM Article_Link__c 
            WHERE Article__c != null
            AND Article__r.Article_Link__c = null
            LIMIT 48
        ];
        System.debug(links.size()+ ' links');
        

        List<Id> ids = new List<Id>();
        for(Article_Link__c k : links){
            ids.add(k.Article__c);
        }
        System.debug(ids.size()+ ' ids');

        List<Knowledge__kav> arts = [
            SELECT Id, Article_Link__c, KnowledgeArticleId, PublishStatus
            FROM Knowledge__kav 
            WHERE KnowledgeArticleId IN :ids
            OR Id IN :ids
        ];
        System.debug(arts.size()+ ' arts');



        List<Wrapper> wraps = new List<Wrapper>();
        List<Knowledge__kav> updateable = new List<Knowledge__kav>();
        for(Article_Link__c l : links){
            for(Knowledge__kav k : arts){
                if(k.Id == l.Article__c){
                    if(k.PublishStatus == 'Draft'){
                        k.Article_Link__c = l.Id;
                        updateable.add(k);
                        continue;
                    }
                    wraps.add( new Wrapper(l, k));
                    continue;
                }
            }
        }
    
        for(Wrapper w : wraps){

            try {
                String newVersionId = unPublishArticle(w.know.KnowledgeArticleId);
    
                Knowledge__kav newArticle = [ SELECT Id, Article_Link__c FROM Knowledge__kav WHERE KnowledgeArticleId =: newVersionId ];   
        
                newArticle.Article_Link__c = w.link.Id;
                System.debug('PublishStatus: '+w.know.PublishStatus);
                update newArticle;

                System.debug('NEW ARTICLE: '+ newArticle.Id);
        
                publishArticle(newVersionId);
            }
            catch(Exception e) {
                System.debug('An exception occurred: ' + e.getMessage());
            }
        }

        //update updateable;

        Integer num = wraps.size()+updateable.size();

        return num + ' updated!';
    }

    public class Wrapper {
        Article_Link__c link {get;set;}
        Knowledge__kav know {get;set;}
        public wrapper(Article_Link__c l, Knowledge__kav k){
            link = l;
            know = k;
        }
    }


 
    public static void publishArticle(String recordId) { //It need to be KnowledgeArticleId
        KbManagement.PublishingService.publishArticle(recordId, true);
    }
 
    public static String unPublishArticle(String recordId){ //It need to be KnowledgeArticleId
        String newArticleId = KbManagement.PublishingService.editOnlineArticle(recordId, true); 
        return [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id =: newArticleId].KnowledgeArticleId;
    }
 
 
    public static String updatetArticle(String title, String urlName, Id recordId) {
 
        String newVersionId = unPublishArticle(recordId);
 
        Knowledge__kav newArticle = [ SELECT Id, KnowledgeArticleId, Title, UrlName FROM Knowledge__kav WHERE KnowledgeArticleId =: newVersionId ];   
 
        newArticle.Title = title;
        newArticle.UrlName = urlName;
 
        update newArticle;
 
        publishArticle(newVersionId);
 
        return newVersionId;
   }

}



/**
    System.debug(Article.getDataCategories());
@AuraEnabled(cacheable=true)
public static List<String> getDataCategories(){

    List<String> results = new List<String>();
    
    List<String> objTypes = new List<String>{ 'KnowledgeArticleVersion' }; //, 'Question'

    for(DescribeDataCategoryGroupResult singleResult : Schema.describeDataCategoryGroups(objTypes)){
        //results.add( singleResult.getName() );
        results.add( singleResult.getLabel() );
    }

    return results;
}

@AuraEnabled(cacheable=true)
public static List<String> getDataCategories(String parent){

    List<String> results = new List<String>();
    
    List<String> objTypes = new List<String>{ 'KnowledgeArticleVersion' }; //, 'Question'

    for(DescribeDataCategoryGroupResult singleResult : Schema.describeDataCategoryGroups(objTypes)){
        //results.add( singleResult.getName() );
        results.add( singleResult.getLabel() );
    }

    return results;
}
    */