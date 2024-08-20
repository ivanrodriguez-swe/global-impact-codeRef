import { LightningElement , api} from 'lwc';

export default class GlobalImpactBanner extends LightningElement {
    @api showBanner;
    @api bannerMessage;
}