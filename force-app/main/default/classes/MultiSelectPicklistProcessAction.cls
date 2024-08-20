/**
 * This class provides a method that can be called to convert 
 * multiselect picklists (Strings separated by ';') to a list of Strings.
 * @author: Ivan A. Rodriguez
 * @Date: Aug 25th, 2021
 */
public  class MultiSelectPicklistProcessAction {
    @InvocableMethod (label='Get MultiSelect Picklists as a List' description='Return a multiselect picklist as a List of Strings.' category='Utilities')
    public static List<StringListResult> getMultiselectPicklistsValues(List <MultiselectPicklistValue> multiselectPicklists){
        //In case we pass an empty List to the method
        //return null
        if(multiselectPicklists.size() == 0){
            return null;
        }
        // Create a StringListResult object to hold the value
        StringListResult processedValue = new StringListResult();

        //Create a List<StringListResult> object to hold the values that are going to be returned
        List<StringListResult> result = new List<StringListResult>();

        // Create a variable to store the input value
        String inputValue = multiselectPicklists[0].inputValue;
        //Check if the variable is empty or null
        if (String.isBlank(inputValue)){
            return null;
        }
        //
        processedValue.outputValues = inputValue.split(';');
        result.add(processedValue);
        return result;
    }

    //Input variable so it can be accessed in the flow
    public class MultiselectPicklistValue {
        @InvocableVariable(label='MultiSelect Picklists for Input' description='Specify the Picklists to be processed' required=true)
        public String inputValue;
    }
    // Output variable returned 
    public class StringListResult {
        @InvocableVariable(label='List returned' description='It is returned a List with the list of values of the MultiSelect picklists that were passed in' required=true)
        public List<String> outputValues; 
    }
}