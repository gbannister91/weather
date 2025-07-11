@IsTest
public with sharing class GB_weatherCalloutBatchTest {
    
    @IsTest
    public static void testInsertContactWithMailingCity() {
        Test.setMock(HttpCalloutMock.class, new GB_weatherDataMock());
        Contact con = new Contact(LastName='Test', MailingCity='Test');
        Test.startTest();
        insert con;
        System.schedule('Batch weather job', '0 0 * * * ?', new GB_weatherCalloutBatch());
        Test.stopTest();
        List<GB_weather__c> weatherRecords = [SELECT Id FROM GB_weather__c WHERE GB_contactId__c =: con.Id LIMIT 1];
        System.assertEquals(weatherRecords.size(),1);
    }
}
