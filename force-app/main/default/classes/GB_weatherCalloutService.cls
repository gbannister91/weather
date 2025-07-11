public with sharing class GB_weatherCalloutService {
    
    @AuraEnabled
    public static GB_weather__c makeCallout(String parameter, String contactId, Boolean isFromLwc) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        String apiKey = String.valueOf(GB_customSettingsAccessor.getFieldValue('GB_apiKey__c'));
        String endpoint = 'callout:GB_WeatherAPI/v1/current.json?key=' + apiKey + '&q=' + parameter;
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        GB_weather__c weatherObject = new GB_weather__c();
        try {
            response = http.send(request);
            if (response.getStatusCode() == 200) {
                Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                //Enhancement: check to see if user wants celcius or fahrenheit
                Map<String,Object> currentWeather = (Map<String,Object>)responseMap.get('current');
                weatherObject.GB_Temperature__c = Decimal.valueOf(String.valueOf(currentWeather.get('temp_c')));
                Map<String,Object> condition = (Map<String,Object>)currentWeather.get('condition');
                weatherObject.GB_iconUrl__c = String.valueOf(condition.get('icon'));
                weatherObject.GB_Description__c = String.valueOf(condition.get('text'));
                weatherObject.GB_Contact__c = contactId;
                weatherObject.GB_contactId__c = contactId;
            }
            else {
                return null;
            }
        }
        catch (CalloutException e) {
            //Handle errors - error logging?
            return null;
        }
        if (isFromLwc) {
            upsert weatherObject GB_contactId__c;
        }
        return weatherObject;

    }
}
