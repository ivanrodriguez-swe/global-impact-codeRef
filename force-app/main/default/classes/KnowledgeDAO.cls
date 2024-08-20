public with sharing class KnowledgeDAO {
    public class TreeNode{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public string metatext;
        @AuraEnabled
        public String name; 
        @AuraEnabled
        public String parentName;
        @AuraEnabled
        public Boolean expanded;
        @AuraEnabled
        public String articleId;
        @AuraEnabled
        public List<TreeNode> items;

        TreeNode(String label, String name, String parentName, String metatext, Boolean expanded, String articleId) {
            this.label = label;
            this.name = name;
            this.parentName = parentName;
            //this.metatext = metatext;
            this.expanded = expanded;
            this.articleId = articleId;
            this.items = new List<TreeNode>();
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getKnowledgeArticlesByIds(List<Id> knowledgeArticleId, String appVisibility) {
        return [SELECT 
                Id, 
                Title, 
                UrlName, 
                Question__c, 
                Answer__c, 
                LastPublishedDate,
                App_Visibility__c 
                FROM Knowledge__kav 
                WHERE Id IN :knowledgeArticleId 
                AND PublishStatus = 'Online'
                AND App_Visibility__c includes (:appVisibility)
                WITH SECURITY_ENFORCED];
    }

    @AuraEnabled(cacheable=true)
    public static Knowledge__kav getKnowledgeArticleByTitleAndLanguage(String title, String languageCode) {
        return [SELECT 
                Id, 
                Title, 
                UrlName, 
                Question__c, 
                Answer__c,
                Language_Code__c, 
                LastPublishedDate
                FROM Knowledge__kav 
                WHERE Title = :title
                AND Language_Code__c = :languageCode
                LIMIT 1];
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Knowledge__kav> getAllKnowledgeArticlesByUrlNameMap(String appVisibility) {
        Map<String, Knowledge__kav> knowledgeArticleUrlMap = new Map<String, Knowledge__kav>();
        for (Knowledge__kav k : [SELECT 
                                 Id,
                                 Title, 
                                 UrlName, 
                                 Question__c, 
                                 Answer__c, 
                                 LastPublishedDate,
                                 App_Visibility__c 
                                 FROM Knowledge__kav 
                                 WHERE PublishStatus = 'Online'
                                 AND App_Visibility__c includes (:appVisibility)
                                 WITH SECURITY_ENFORCED]) {
            knowledgeArticleUrlMap.put(k.UrlName, k);
        }
        return knowledgeArticleUrlMap;
    }

    @AuraEnabled(cacheable=true)
    public static List<TreeNode> buildTreeNodesFromDataCategories(String appVisibility, String topDataCategoryDeveloperName, Boolean includeTopCategoryName) {
        // get the IDs of all of the categories
        Map<String, List<Knowledge__DataCategorySelection>> kdcsMap = new Map<String, List<Knowledge__DataCategorySelection>>();
        Map<Id, Knowledge__DataCategorySelection> kdcsMapWithId = new Map<Id, Knowledge__DataCategorySelection>();
        Map<Id, List<Knowledge__DataCategorySelection>> kdcsMapWithIdList = new Map<Id, List<Knowledge__DataCategorySelection>>();
        List<Knowledge__kav> knowledgeArticleList = new List<Knowledge__kav>();
        List<Id> knowledgeArticleIds = new List<Id>();
        Map<String, List<Knowledge__kav>> articlesByDataCategory = new Map<String, List<Knowledge__kav>>();
        // get current user's Fantelligence Version
        String fantelligenceVersion = [SELECT Fantelligence_Version__c FROM User WHERE Id = :UserInfo.getUserId()].Fantelligence_Version__c.replace(' ', '_');
        Map<Id, List<String>> articlesByFantelligenceTier = new Map<Id, List<String>>();
        //System.debug('current fantelligence version: ' + fantelligenceVersion);
        for (Knowledge__DataCategorySelection kdcs : [SELECT ParentId, DataCategoryName, DataCategoryGroupName FROM Knowledge__DataCategorySelection]) {
            // add the parent ID (the knowledge article ID) to the list
            knowledgeArticleIds.add(kdcs.ParentId);

            // add it to the map based on the Data Category name
            if (kdcs.DataCategoryGroupName == 'Fantelligence') {
                if (kdcsMap.get(kdcs.DataCategoryName) == null) {
                    kdcsMap.put(kdcs.DataCategoryName, new List<Knowledge__DataCategorySelection> { kdcs });
                    if (kdcsMapWithId.get(kdcs.ParentId) == null) {
                        kdcsMapWithId.put(kdcs.ParentId, kdcs);
                    }
                    if (kdcsMapWithIdList.get(kdcs.ParentId) == null) {
                        kdcsMapWithIdList.put(kdcs.ParentId, new List<Knowledge__DataCategorySelection>{ kdcs });
                        //kdcsMapWithIdList.get(kdcs.ParentId).add(kdcs);
                    }
                    else {
                        kdcsMapWithIdList.get(kdcs.ParentId).add(kdcs);
                    }
                    articlesByDataCategory.put(kdcs.DataCategoryName, new List<Knowledge__kav>());
                    //System.debug('putting ' + kdcs.DataCategoryName);
                }
                else {
                    kdcsMap.get(kdcs.DataCategoryName).add(kdcs);
                    if (kdcsMapWithId.get(kdcs.ParentId) == null) {
                        kdcsMapWithId.put(kdcs.ParentId, kdcs);
                    }
                    
                    if (kdcsMapWithIdList.get(kdcs.ParentId) == null) {
                        kdcsMapWithIdList.put(kdcs.ParentId, new List<Knowledge__DataCategorySelection>{ kdcs });
                        //kdcsMapWithIdList.get(kdcs.ParentId).add(kdcs);
                    }
                    else {
                        kdcsMapWithIdList.get(kdcs.ParentId).add(kdcs);
                    }
                }
            }
            else if (kdcs.DataCategoryGroupName == 'Fantelligence_Version') {
                if (articlesByFantelligenceTier.get(kdcs.ParentId) == null) {
                    articlesByFantelligenceTier.put(kdcs.ParentId, new List<String> { kdcs.DataCategoryName });
                }
                else {
                    articlesByFantelligenceTier.get(kdcs.ParentId).add(kdcs.DataCategoryName);
                }
            }
        }

        // get the article names by category
        // ORIGINAL 
        /*for (Knowledge__kav know : getKnowledgeArticlesByIds(knowledgeArticleIds, appVisibility)) {
            if (kdcsMapWithId.get(know.Id) != null) {
                // get the group name
                String dataCatName = kdcsMapWithId.get(know.Id).DataCategoryName;
                // check the other map
                if (articlesByDataCategory.get(dataCatName) == null) {
                    articlesByDataCategory.put(dataCatName, new List<Knowledge__kav>{ know });
                }
                else {
                    articlesByDataCategory.get(dataCatName).add(know);
                }
            }

            knowledgeArticleList.add(know);
        }*/
        
        // NEW
        for (Knowledge__kav know : getKnowledgeArticlesByIds(knowledgeArticleIds, appVisibility)) {
            if (kdcsMapWithIdList.get(know.Id) != null) {
                for (Knowledge__DataCategorySelection kdcs : kdcsMapWithIdList.get(know.Id)) {
                    // get the group name
                    String dataCatName = kdcs.DataCategoryName;
                    // check the other map
                    if (articlesByDataCategory.get(dataCatName) == null) {
                        articlesByDataCategory.put(dataCatName, new List<Knowledge__kav>{ know });
                    }
                    else {
                        articlesByDataCategory.get(dataCatName).add(know);
                    }
                }
            }

            knowledgeArticleList.add(know);
        }

        List<TreeNode> treeNodeItems = new List<TreeNode>();
        // map of TreeNodes
        Map<String, List<TreeNode>> treeNodeMap = new Map<String, List<TreeNode>>();
        Map<String, List<String>> tmpNodeMap = new Map<String, List<String>>();
        // list of the described categories
        List<DescribeDataCategoryGroupResult> describeCategoryResult;
        // list of the described category results
        List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;
        
        // Making the call to the describeDataCategoryGroups to get the list of category groups associated
        List<String> objType = new List<String>();
        objType.add('KnowledgeArticleVersion');

        // once we describe the category 
        describeCategoryResult = Schema.describeDataCategoryGroups(objType);
        
        // Creating a list of pair objects to use as a parameter for the describe call
        List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
        
        // Looping throught the first describe result to create the list of pairs for the second describe call
        for(DescribeDataCategoryGroupResult singleResult : describeCategoryResult){
            DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
            p.setSobject(singleResult.getSobject());
            p.setDataCategoryGroupName(singleResult.getName());
            pairs.add(p);
        }
        
        // this structure then takes the pairs and splits it out
        describeCategoryStructureResult = Schema.describeDataCategoryGroupStructures(pairs, false);

        //Getting data from the result
        List<TreeNode> trueRootNodes = new List<TreeNode>();
        for(DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult){
            //Get the top level categories
            // FIRST TREE NODE - START
            List<DataCategory> toplevelCategories = singleResult.getTopCategories();
            List<DataCategory> tmpToplevelCategories = new List<DataCategory>();
            Map<String, DataCategory> tmpDataCatsMap = new Map<String, DataCategory>();
            for (DataCategory tlc : toplevelCategories) {
                if (tlc.getName() != topDataCategoryDeveloperName) { // || tlc.getName() != 'Fantelligence_Versions'
                    continue; 
                }
                else {
                    tmpToplevelCategories.add(tlc);
                }
            }

            List<DataCategory> tmpAllCategories = getAllCategories(tmpToplevelCategories);
            Map<String, TreeNode> tmpTreeNodeMap = new Map<String, TreeNode>();
            List<TreeNode> trueTreeRootNodes = new List<TreeNode>();

            // build the first map - loop through the top-level categories (tlc)
            // temporarily store the top level name
            String topCategoryName;
            for (DataCategory tlc : tmpAllCategories)  {
                // first, see if the parent has been added
                if (tmpTreeNodeMap.get(tlc.getName()) == null) {
                    // temporarily store the top level name
                    topCategoryName = tlc.getName();
                    // if not, add the parent with null as the parentName
                    // additional check - if the variable is false, don't add the top node item
                    if (includeTopCategoryName) {
                        tmpTreeNodeMap.put(tlc.getName(), new TreeNode(tlc.getLabel(), tlc.getName(), null, null, true, null));
                        // also add it to the list because it's a parent 
                        trueTreeRootNodes.add(new TreeNode(tlc.getLabel(), tlc.getName(), null, null, true, null));
                    }
                }
                // next, see if there are any children and loop through each category and add them as a top-level category
                if (tlc.getChildCategories().size() > 0) {
                    // there are child categories, so let's add the parent first
                    for (DataCategory clc : tlc.getChildCategories()) {
                        // add the child with the parent name
                        if (includeTopCategoryName) {
                            tmpTreeNodeMap.put(clc.getName(), new TreeNode(clc.getLabel(), clc.getName(), tlc.getName(), null, true, null));
                        }
                        else {
                            if (tmpTreeNodeMap.get(tlc.getName()) != null) {
                                tmpTreeNodeMap.put(clc.getName(), new TreeNode(clc.getLabel(), clc.getName(), tlc.getName(), null, true, null));
                            }
                            else {
                                tmpTreeNodeMap.put(clc.getName(), new TreeNode(clc.getLabel(), clc.getName(), null, null, true, null));
                            }
                        }
                    }
                }

                // next, get all articles that match this Data Category and add them
                if (articlesByDataCategory.get(tlc.getName()) != null) {
                    for (Knowledge__kav ka : articlesByDataCategory.get(tlc.getName())) {
                        if (articlesByFantelligenceTier.get(ka.Id) != null && (articlesByFantelligenceTier.get(ka.Id).contains('All_Fantelligence_Versions') || 
                            articlesByFantelligenceTier.get(ka.Id).contains(fantelligenceVersion))){
                            if (tmpTreeNodeMap.get(ka.UrlName) == null) {
                                tmpTreeNodeMap.put(ka.UrlName, new TreeNode(ka.Title, ka.UrlName, tlc.getName(), null, true, ka.Id));
                            }
                            else {
                                tmpTreeNodeMap.put(ka.UrlName + tlc.getName(), new TreeNode(ka.Title, ka.UrlName, tlc.getName(), null, true, ka.Id));
                            }
                        }
                    }
                }
            }

            // get the null tree value - that's the top level one
            for (TreeNode tn : tmpTreeNodeMap.values()) {
                // add data category to tree node map
                if (tn.parentName != null && tmpTreeNodeMap.get(tn.parentName) != null) {
                    tmpTreeNodeMap.get(tn.parentName).items.add(tn);
                }
            }

            // next, loop through the TreeNodes to build it based on the correct TreeNode structure
            for (TreeNode tn : tmpTreeNodeMap.values()) {
                if (tn.articleId == null && tn.items.size() == 0) {
                    tn.metatext = 'Coming Soon';
                }

                if (String.isBlank(tn.parentName) && tn.items.size() > 0) {
                    trueRootNodes.add(tn);
                }
            }
        }


        return trueRootNodes;
    }

    // required to get all categories        
    private static DataCategory[] getAllCategories(DataCategory [] categories){
        if(categories.isEmpty()){
            return new DataCategory[]{};
        } else {
            DataCategory [] categoriesClone = categories.clone();
            DataCategory category = categoriesClone[0];
            DataCategory[] allCategories = new DataCategory[]{category};
            categoriesClone.remove(0);
            categoriesClone.addAll(category.getChildCategories());
            allCategories.addAll(getAllCategories(categoriesClone));
            return allCategories;
        }
    }
}