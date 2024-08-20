/**
 * This class test the fucntionality of converting multiselect picklist to a List
 * @author: Ivan A. Rodriguez
 */
@isTest
private class MultiSelectPicklistProcessActionTest {
    @isTest
    private static void testGetMultiselectPicklistValues(){
        //********************Setting Variables for Test ***************** */
        String case1 = 'Apple;Strawbwerry;Avocado;Lemon;Coconut';
        String case2 = '';
        
        // Create required object to hold the input variables
        MultiSelectPicklistProcessAction.MultiselectPicklistValue scenario 
                        = new MultiSelectPicklistProcessAction.MultiselectPicklistValue();

        //Create required List for input parameter of the method
        List<MultiSelectPicklistProcessAction.MultiselectPicklistValue> inputs 
                        = new List<MultiSelectPicklistProcessAction.MultiselectPicklistValue>();
     
        // Create required List to store the returned object
        List<MultiSelectPicklistProcessAction.StringListResult> results = new List<MultiSelectPicklistProcessAction.StringListResult>();
        
        // Set variables 
        scenario.inputValue = case1;
        inputs.add(scenario);

        //**************** Begin Test 1*************************
        results = MultiSelectPicklistProcessAction.getMultiselectPicklistsValues(inputs);
        
        //Check results of Test 1;
        List<String> finalResult = new List<String>();
        finalResult = results[0].outputValues;
        System.assertEquals(5, finalResult.size(),'The result here should be three');
        System.debug('@@@ Begin Output Test 1');
        System.debug('Size of the Test List Result: '+finalResult.size());
        for(String s: finalResult){
            System.debug(s);
        }
        System.debug('@@@ Ends Output Test 1');
        //reset variable so it can be used in other scenarios
        inputs.remove(0);

        //***************************************Begin Test 2
        scenario.inputValue = case2;
        inputs.add(scenario);
        results = MultiSelectPicklistProcessAction.getMultiselectPicklistsValues(inputs);
        System.debug('@@@ Begin Output Test 2. Passing a blank String');
        System.debug('The returned value is: '+ results);
        System.assert(results == null, 'The result returned should be null because we passed blank Sting');
        System.debug('@@@ Ends Output Test 2');
        //reset variable so it can be used in other scenarios
        inputs.remove(0);

        /********************** Begin Test 3 */
        List<MultiSelectPicklistProcessAction.MultiselectPicklistValue> baddInput;
        results = MultiSelectPicklistProcessAction.getMultiselectPicklistsValues(inputs);
        System.debug('@@@ Begin Output Test 3. Passing a null List of objects by the method');
        System.debug('The returned value is: '+ results);
        System.assert(results == null, 'The result returned should be null because the List of Parameters we passed is null');
        System.debug('@@@ Ends Output Test 3');
   
    }
}