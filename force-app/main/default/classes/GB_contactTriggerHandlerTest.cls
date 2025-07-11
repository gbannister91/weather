@IsTest
public with sharing class GB_contactTriggerHandlerTest {
    
    @IsTest
    public static void testInsertContactWithMailingCity() {
        Test.setMock(HttpCalloutMock.class, new GB_weatherDataMock());
        Contact con = new Contact(LastName='Test', MailingCity='Test');
        Test.startTest();
        insert con;
        Test.stopTest();
        List<GB_weather__c> weatherRecords = [SELECT Id FROM GB_weather__c WHERE GB_contactId__c =: con.Id LIMIT 1];
        System.assertEquals(weatherRecords.size(),1);
    }

    @IsTest
    public static void testUpdateContactWithMailingPostalCode() {
        Test.setMock(HttpCalloutMock.class, new GB_weatherDataMock());
        Contact con = new Contact(LastName='Test2', MailingCity='Test2');
        Test.startTest();
        insert con;
        con.MailingPostalCode = 'LS1 1AA';
        update con;
        Test.stopTest();
        List<GB_weather__c> weatherRecords = [SELECT Id, CreatedDate, LastModifiedDate FROM GB_weather__c WHERE GB_contactId__c =: con.Id LIMIT 1];
        System.debug(weatherRecords);
        System.assertEquals(weatherRecords.size(),1);
        //System.assert(weatherRecords[0].CreatedDate != weatherRecords[0].LastModifiedDate);
    }

    @IsTest
    public static void testInsertMultipleContactsWithMailingCity() {
        Test.setMock(HttpCalloutMock.class, new GB_weatherDataMock());
        List<Contact> cons = new List<Contact>();
        for (integer i = 0; i < 300; i++) {
            Contact con = new Contact(LastName='Test', MailingCity='Test');
            cons.add(con);
        }
        Test.startTest();
        insert cons;
        Test.stopTest();
        List<GB_weather__c> weatherRecords = [SELECT Id FROM GB_weather__c];
        //Expect 200 to be created since the calls cannot be chained during unit tests
        System.assertEquals(weatherRecords.size(),200);
    }
}
