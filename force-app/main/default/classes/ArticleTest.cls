@isTest
public with sharing class ArticleTest {
    
    @isTest
    public static void getTopLevelQuestions() {
        Article.getTopLevelQuestions();
    }
    
    @isTest
    public static void getChildQuestions() {
        Article.getChildQuestions('');
    }
    
    @isTest
    public static void getAllArticles() {
        Article.getAllArticles();
    }
    
    @isTest
    public static void searchArticles() {
        Article.searchArticles('2020');
    }
    
    @isTest
    public static void getAllDataCategories() {
        Article.getAllDataCategories();
    }
    
    @isTest
    public static void dev_count() {
        Article.dev_count();
    }
    
    @isTest
    public static void dataTests(){

        DAO data = new DAO();

        Article.getArticlesByQuestionId( data.question.Id );
        Article.getArticleLinksByQuestionId( data.question.Id );
        Article.getArticles( new List<id>{ data.article.Id } );

        String vId = Article.createVisit( data.article.Id, 'https://example.com' );

        data.visit = [ SELECT ID FROM Visit__c WHERE Id = :vId ];

        Article.createQuestionTrack( data.visit.Id, data.question.Id );
        
        data.articleTrackId = Article.createArticleTrack( data.visit.Id, data.question.Id, data.article.Id );
        
        Article.updateArticleTrack( data.articleTrackId, 'Helpful' );

        
        Article.updateArticleTrackCaseId( data.articleTrackId, null );

        
        Article.updateVisitFnr( data.visit.Id, data.article.Id, data.kase.Id, data.question.Id );
    }
    
    @isTest
    public static void contentTest(){

        DAO data = new DAO();

        Article.updateFileParentId( data.version.ContentDocumentId, data.kase.Id );
    }
    
    @isTest
    public static void contentTest2(){

        DAO data = new DAO();

        Article.linkArticleTracks();

        Article.linkArticlesWithLinks();
    }

    public class DAO {

        public Deflection_Question__c question {get;set;}
        public knowledge__kav article {get;set;}
        public Article_Link__c link {get;set;}
        public Visit__c visit {get;set;}
        public String articleTrackId {get;set;}
        public ContentVersion version {get;set;}
        public Case kase {get;set;}

        public DAO(){

            Group grp = [
                SELECT Id, Name
                FROM Group
                WHERE Name = 'UnAssigned' 
            ];
            Case c = new Case(
                ownerId = grp.Id,
                Priority = 'Low',
                subject = 'test',
                description = 'test'
            );
            insert c;
            kase = c;

            Deflection_Question__c q = new Deflection_Question__c();
            question = q;

            knowledge__kav a = new knowledge__kav(Title='test',summary='test',urlname='test');
            insert a;
            article = a;

            Article_Link__c al = new Article_Link__c(
                Question__c = q.Id,
                Article__c = a.Id
            );
            insert al;
            link = al;


            ContentVersion cv = new ContentVersion( 
                ContentLocation = 'S',
                VersionData = Blob.valueOf('test'),
                Title = 'test.txt',
                PathOnClient = 'test.txt'
            );
            insert cv;
            version = [
                SELECT Id, Title, ContentDocumentId 
                FROM ContentVersion 
                WHERE Id = :cv.Id 
                LIMIT 1
            ];

        }
    }
}