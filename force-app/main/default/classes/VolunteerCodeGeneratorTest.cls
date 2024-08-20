/**
 * This class is the test class for the VolunteerCodeGenerator class
 * @author Ivan A. Rodriguez
 */
@isTest
private class VolunteerCodeGeneratorTest {
    @isTest
    private static void testGenerateCode(){
        System.debug('---Begin Test: testGenerateCode---');
        for(Integer i=0; i<200; i++){
            String codeGenerated = VolunteerCodeGenerator.generateCode()[0].code;
            System.debug('Generated Code: '+codeGenerated);
            System.assert(String.isNotBlank(codeGenerated), 'There should be a code generated');
            System.assertEquals(15,codeGenerated.length(),'The code needs to be 15 characters long');
        }
        System.debug('---Successful End Test: testGenerateCode---');
        
    }
}