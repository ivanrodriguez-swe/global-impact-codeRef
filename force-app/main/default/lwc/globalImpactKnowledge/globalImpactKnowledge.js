import { LightningElement, api, wire } from 'lwc';
import { getSObjectValue } from '@salesforce/apex';
import languageCode from '@salesforce/i18n/lang';
import getKnowledgeArticleByTitleAndLanguage from '@salesforce/apex/KnowledgeDAO.getKnowledgeArticleByTitleAndLanguage';
import ANSWER_FIELD from '@salesforce/schema/Knowledge__kav.Answer__c';

export default class GlobalImpactKnowledge extends LightningElement {
    @api knowledgeArticleTitle;
    languageCode = 'en-US';

    @wire(getKnowledgeArticleByTitleAndLanguage, { title: '$knowledgeArticleTitle', languageCode: '$languageCode' }) 
    article;

    get body() {
        return this.article.data ? getSObjectValue(this.article.data, ANSWER_FIELD) : '';
    }

    connectedCallback() {
        this.languageCode = languageCode;
    }
}