@isTest
public with sharing class KnowledgeDAOTest {
    @isTest
    private static void navigationMenuItemsByLinkSetIdTest() {
        List<Knowledge__kav> testKnowledgeArticles = new List<Knowledge__kav>();
        // create an article
        Knowledge__kav testArticle1 = new Knowledge__kav(Title='test article', 
                                                         UrlName='testarticleurl1', 
                                                         Language='en_US',
                                                         Question__c = 'test question',
                                                         Answer__c = 'test answer',
                                                         App_Visibility__c = 'Fantelligence');
        testKnowledgeArticles.add(testArticle1);
        
        Knowledge__kav testArticle2 = new Knowledge__kav(Title='test article2', 
                                                         UrlName='testarticleurl2', 
                                                         Language='en_US',
                                                         Question__c = 'test question2',
                                                         Answer__c = 'test answer2',
                                                         App_Visibility__c = 'Fantelligence');
        testKnowledgeArticles.add(testArticle2);

        // Insert Articles
        insert testKnowledgeArticles;
        List<Id> insertedArticleIds = new List<Id>();

        for (Knowledge__kav ka : [SELECT Id, KnowledgeArticleId FROM Knowledge__kav]) {
            KbManagement.PublishingService.publishArticle(ka.KnowledgeArticleId, true);
            insertedArticleIds.add(ka.Id);
        }

        List<Knowledge__DataCategorySelection> newDataCats = new List<Knowledge__DataCategorySelection>();
        // assign Data Categories
        for (Id articleId : insertedArticleIds) {
            newDataCats.add(new Knowledge__DataCategorySelection(ParentId = articleId,
                                                                 DataCategoryName = 'FAQs',
                                                                 DataCategoryGroupName = 'Fantelligence'));
            
            newDataCats.add(new Knowledge__DataCategorySelection(ParentId = articleId,
                                                                 DataCategoryName = 'Fantelligence',
                                                                 DataCategoryGroupName = 'Fantelligence_Version'));
        }

        insert newDataCats;


        List<Knowledge__kav> testKnowledgeArticlesReturned = KnowledgeDAO.getKnowledgeArticlesByIds(insertedArticleIds, 'Fantelligence');

        System.assertEquals(2, testKnowledgeArticlesReturned.size(), 'All knowledge articles that were inserted were not returned.');
    }
    
    @isTest
    private static void getAllKnowledgeArticlesByUrlNameMapTest() {
        List<Knowledge__kav> testKnowledgeArticles = new List<Knowledge__kav>();
        // create an article
        Knowledge__kav testArticle1 = new Knowledge__kav(Title='test article', 
                                                         UrlName='testarticleurl1', 
                                                         Language='en_US',
                                                         Question__c = 'test question',
                                                         Answer__c = 'test answer',
                                                         App_Visibility__c = 'Fantelligence');
        testKnowledgeArticles.add(testArticle1);
        
        Knowledge__kav testArticle2 = new Knowledge__kav(Title='test article2', 
                                                         UrlName='testarticleurl2', 
                                                         Language='en_US',
                                                         Question__c = 'test question2',
                                                         Answer__c = 'test answer2',
                                                         App_Visibility__c = 'Fantelligence');
        testKnowledgeArticles.add(testArticle2);


        // Insert Articles
        insert testKnowledgeArticles;
        List<Id> insertedArticleIds = new List<Id>();

        for (Knowledge__kav ka : [SELECT Id, KnowledgeArticleId FROM Knowledge__kav]) {
            KbManagement.PublishingService.publishArticle(ka.KnowledgeArticleId, true);
            insertedArticleIds.add(ka.Id);
        }

        Map<String, Knowledge__kav> testKnowledgeArticlesReturned = KnowledgeDAO.getAllKnowledgeArticlesByUrlNameMap('Fantelligence');

        System.assertEquals(2, testKnowledgeArticlesReturned.keySet().size(), 'All knowledge articles that were inserted were not returned.');
    }
    
    @isTest
    private static void buildTreeNodesFromDataCategoriesTest() {
        List<Knowledge__kav> testKnowledgeArticles = new List<Knowledge__kav>();
        // create an article
        Knowledge__kav testArticle1 = new Knowledge__kav(Title='test article', 
                                                         UrlName='testarticleurl1', 
                                                         Language='en_US',
                                                         Question__c = 'test question',
                                                         Answer__c = 'test answer',
                                                         App_Visibility__c = 'Fantelligence');
        testKnowledgeArticles.add(testArticle1);
        
        Knowledge__kav testArticle2 = new Knowledge__kav(Title='test article2', 
                                                         UrlName='testarticleurl2', 
                                                         Language='en_US',
                                                         Question__c = 'test question2',
                                                         Answer__c = 'test answer2',
                                                         App_Visibility__c = 'Fantelligence');
        testKnowledgeArticles.add(testArticle2);


        // Insert Articles
        insert testKnowledgeArticles;
        List<Id> insertedArticleIds = new List<Id>();

        for (Knowledge__kav ka : [SELECT Id, KnowledgeArticleId FROM Knowledge__kav]) {
            KbManagement.PublishingService.publishArticle(ka.KnowledgeArticleId, true);
            insertedArticleIds.add(ka.Id);
        }

        List<Knowledge__DataCategorySelection> newDataCats = new List<Knowledge__DataCategorySelection>();
        // assign Data Categories
        for (Id articleId : insertedArticleIds) {
            newDataCats.add(new Knowledge__DataCategorySelection(ParentId = articleId,
                                                                 DataCategoryName = 'FAQs',
                                                                 DataCategoryGroupName = 'Fantelligence'));
            
            newDataCats.add(new Knowledge__DataCategorySelection(ParentId = articleId,
                                                                 DataCategoryName = 'Fantelligence',
                                                                 DataCategoryGroupName = 'Fantelligence_Version'));
        }

        insert newDataCats;


        List<KnowledgeDAO.TreeNode> testKnowledgeArticlesReturned = KnowledgeDAO.buildTreeNodesFromDataCategories('Fantelligence', 'Fantelligence_Help', false);
    }

    @isTest
    private static void testGetKnowledgeArticleByTitleAndLanguage() {
        
        List<Knowledge__kav> testKnowledgeArticles = new List<Knowledge__kav>();

        Knowledge__kav testArticleAbout = new Knowledge__kav(Title='Global Impact Day About', 
                                                        UrlName='Global-Impact-Day-About-en-US-test', 
                                                        Language='en_US',
                                                        Language_Code__c = 'en-US',
                                                        Answer__c = 'Global Impact Day is a day of service.');
                                                        testKnowledgeArticles.add(testArticleAbout);

        Knowledge__kav testArticleFAQ = new Knowledge__kav(Title='Global Impact Day FAQ', 
                                                        UrlName='Global-Impact-Day-FAQ-es-test',
                                                        Language_Code__c = 'es',
                                                        Answer__c = 'El Día del Impacto Global es un día de servicio.');
                                                        testKnowledgeArticles.add(testArticleFAQ);

        insert testKnowledgeArticles;
        
        Test.startTest();
        Knowledge__kav globalImpactAboutArticle = KnowledgeDAO.getKnowledgeArticleByTitleAndLanguage(testArticleAbout.Title, testArticleAbout.Language_Code__c);
        Knowledge__kav globalImpactFAQArticle = KnowledgeDAO.getKnowledgeArticleByTitleAndLanguage(testArticleFAQ.Title, testArticleFAQ.Language_Code__c);
        Test.stopTest();

        System.assertEquals('Global-Impact-Day-About-en-US-test', globalImpactAboutArticle.UrlName);
        System.assertEquals('Global-Impact-Day-FAQ-es-test', globalImpactFAQArticle.UrlName);

        try{
            KnowledgeDAO.getKnowledgeArticleByTitleAndLanguage(null, null);
        }catch(Exception e){
            System.assert(!String.isBlank(e.getMessage()),'There should have been an exception thrown for no returned knowledge article.');
        }
    }
}