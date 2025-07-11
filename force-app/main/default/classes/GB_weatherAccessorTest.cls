@IsTest
public with sharing class GB_weatherAccessorTest {
    
    @IsTest
    public static void testGetWeatherLocal() {
        GB_weather__c weatherRecord = new GB_weather__c();
        Test.setMock(HttpCalloutMock.class, new GB_weatherDataMock());
        Contact con = new Contact(LastName='Test', MailingCity='Test');
        Test.startTest();
        insert con;
        Test.stopTest();
        weatherRecord = GB_weatherAccessor.getWeatherForContact(con.Id, false);
        System.assertEquals(weatherRecord.GB_contactId__c, con.Id);
    }

    @IsTest
    public static void testGetWeatherCallout() {
        GB_weather__c weatherRecord = new GB_weather__c();
        Test.setMock(HttpCalloutMock.class, new GB_weatherDataMock());
        Contact con = new Contact(LastName='Test', MailingCity='Test');
        Test.startTest();
        insert con;
        weatherRecord = GB_weatherAccessor.getWeatherForContact(con.Id, true);
        Test.stopTest();
        weatherRecord = GB_weatherAccessor.getWeatherForContact(con.Id, false);
        System.assertEquals(weatherRecord.GB_contactId__c, con.Id);
    }
}
