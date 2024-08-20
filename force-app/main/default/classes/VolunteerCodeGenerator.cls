/**
 * This class provides a method that generates a 10 characters 
 * random code, that will be used by volunteers to log in
 * to the Global Impact 
 */
public class VolunteerCodeGenerator {
    //Dictionary with all letters and numbers
    private static final List<String> dictionary = new List<String>{'a','b','c','d','e','f','g','h',
                                                                    'i','j','k','l','m','n','o','p','q','r','s','t','u',
                                                                    'v','w','x','y','z','0','1','2','3','4','5','6','7','8','9'};
    //This is to test the exception functionality;
    private static Boolean testException = false;

    @InvocableMethod(label='Generate Volunteer Portal Code' description='Return a 15 characters long random string' category='Utilities')
    public static List<VolunteerPortalCode> generateCode(){
        List<VolunteerPortalCode> portalCode = new List<VolunteerPortalCode>();
        VolunteerPortalCode result = new VolunteerPortalCode();
        String code = '';
        Integer index;
        Integer len = 15;
        for(Integer i=0; i < len; i++){
            index = Math.mod(Math.abs(Crypto.getRandomInteger()), dictionary.size());
            if(Math.mod(index,2) == 0){
                code += dictionary[index].toUpperCase();
            }else{
                code += dictionary[index];
            }
        }
        result.code = code;
        portalCode.add(result);
        return portalCode;
    }

    //Output code returned
    public class VolunteerPortalCode{
        @InvocableVariable(label='Volunteer Portal Code returned' description='This is the returned generated code' required=true)
        public String code;
    }
}