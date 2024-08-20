/**
 * This class provides helpful methods to process data
 * @author Ivan A. Rodriguez
 */
public class Utils {

    /**
     * This method returns the values in a multi-select picklist as a List.
     * This method uses the MultiSelectPicklistProcessAction class to reuse code.
     * @param String picklist (String separated by ';'. Values are separated by ';' in a multiselect picklist field.)
     * @return List<String> with the values in a List
     */
    public static List<String> getMultiselectPicklistAsList (String picklist){
        if(String.isBlank(picklist)){
            return null;
        }
        // Create record of inner class
        MultiSelectPicklistProcessAction.MultiselectPicklistValue myValues = 
                        new MultiSelectPicklistProcessAction.MultiselectPicklistValue();
        myValues.inputValue = picklist;
        // Prepare the parameter that is needed to make the method call
        List<MultiSelectPicklistProcessAction.MultiselectPicklistValue> input = 
                        new List<MultiSelectPicklistProcessAction.MultiselectPicklistValue>();
        input.add(myValues);
        // Call the method that returns the List
        List<MultiSelectPicklistProcessAction.StringListResult> myResult = 
                        MultiSelectPicklistProcessAction.getMultiselectPicklistsValues(input);
        return myResult[0].outputValues;
    }

    /**
     * This method returns a List of Strings as a multi-select Picklist's string
     * @param values list of values that need to be concatenated an formatted for a multi-select picklist
     * @return String of concatenated values
     */
    public static String getListAsMultiselectPicklist(List<String> values){
        if( (values  == null) || (values.size() == 0)){
            return null;
        }
        String result='';
        for(Integer i = 0; i<=values.size() -1 ; i++){
            if(i == (values.size() -1)){
                result+= values.get(i);
            }else{
                result+=values.get(i)+';';
            }
        }
        return result;
    }
}