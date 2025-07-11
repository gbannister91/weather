public with sharing class GB_weatherAccessor {

    @AuraEnabled
    public static GB_weather__c getWeatherForContact(String contactId, Boolean makeCallout)
    {
        if (!makeCallout) {
            return getWeatherForContactLocal(contactId);
        }
        else {
            Contact con = [SELECT Id, MailingCity, MailingPostalCode FROM Contact WHERE Id = :contactId LIMIT 1];
            if (String.isNotBlank(con.MailingPostalCode) || String.isNotBlank(con.MailingCity)) {
                String parameter = String.isNotBlank(con.MailingPostalCode)?con.MailingPostalCode.replaceAll(' ',''):con.MailingCity;
                return GB_weatherCalloutService.makeCallout(parameter, con.Id, true);
            }
            else return null;
        }
    }




    public static GB_weather__c getWeatherForContactLocal(String contactId) {
        List<GB_weather__c> weatherList = [SELECT Id, GB_Description__c, GB_Temperature__c, GB_iconUrl__c, GB_contactId__c FROM GB_weather__c WHERE GB_contactId__c = :contactId limit 1];
        if (weatherList.size() > 0) {
            return weatherList[0];
        }
        return null;
    }

    public static void handleUpserts(List<GB_weather__c> weatherRecords) {
        upsertWeather(weatherRecords);
        publishEvents(weatherRecords);
    }

    public static void upsertWeather(List<GB_weather__c> weatherRecords) {
        try {
            upsert weatherRecords GB_contactId__c;
        }
        catch (DMLException e) {
            //to do - error handling
        }
    }

    public static void publishEvents(List<GB_weather__c> weatherRecords) {
        List<GB_addressUpdated__e> eventList = new List<GB_addressUpdated__e>();
        for (GB_weather__c weatherRecord : weatherRecords) {
            GB_addressUpdated__e updateEvent = new GB_addressUpdated__e();
            updateEvent.GB_contactId__c = weatherRecord.GB_contactId__c;
            eventList.add(updateEvent);
        }
        //to do - check for any errors and handle
        EventBus.publish(eventList);
    }

}
