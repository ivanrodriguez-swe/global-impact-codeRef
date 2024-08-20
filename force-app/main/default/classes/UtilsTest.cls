/**
 * This is the test class for the Utils class
 * @author Ivan A. Rodriguez
 */
@isTest
private class UtilsTest {
    @isTest
    private static void testGetMultiselectPicklistAsList(){
        String case1 ='Apple;Potate;Lemon;Strawberry';
        //empty String
        String case2 = '';
        //Null
        String case3;

        List<String> result = new List<String>();
        /************** TEST Case 1 ********** */
        System.debug('@@@ Begin Test 1');
        result = Utils.getMultiselectPicklistAsList(case1);
        System.assert(result.size() >0, 'It should return a List with a size greather than 0');
        System.debug('The List returned is: '+result);
        System.debug('@@@ End Test 1');
        /************** TEST Case 2 ********** */
        System.debug('@@@ Begin Test 2');
        result = Utils.getMultiselectPicklistAsList(case2);
        System.assert(result == null, 'It should return null because we passed an empty String');
        System.debug('The List returned is: '+result);
        System.debug('@@@ End Test 2');
        /************** TEST Case 3 ********** */
        System.debug('@@@ Begin Test 3');
        result = Utils.getMultiselectPicklistAsList(case3);
        System.assert(result == null, 'It should return null, because we passed a null String');
        System.debug('The List returned is: '+result);
        System.debug('@@@ End Test 1');
    }

    @isTest 
    private static void testGetListAsMultiselectPicklist(){
        List<String> case1 = new List<String>{'Apple','Potato','Lemon'};
        //EMpty list 
        List<String> case2 = new List<String>();
        //Null List
        List<String> case3;

        String result = '';
        /************** TEST Case 1 ********** */
        System.debug('### Begin Test 1');
        result = Utils.getListAsMultiselectPicklist(case1);
        System.assert(String.isBlank(result) == false, 'It should return a String');
        System.debug('The String returned is: '+result);
        System.debug('### End Test 1');
        /************** TEST Case 2 ********** */
        System.debug('### Begin Test 2');
        result = Utils.getListAsMultiselectPicklist(case2);
        System.assert(result == null, 'It should return null because we passed an empty List');
        System.debug('The String returned is: '+result);
        System.debug('### End Test 2');
        /************** TEST Case 3 ********** */
        System.debug('### Begin Test 3');
        result = Utils.getListAsMultiselectPicklist(case3);
        System.assert(result == null, 'It should return null, because we passed a null List');
        System.debug('The String returned is: '+result);
        System.debug('###End Test 1');

    }
}