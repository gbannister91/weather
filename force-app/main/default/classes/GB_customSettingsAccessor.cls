public with sharing class GB_customSettingsAccessor {

    public static Object getFieldValue(String fieldName) {
        GB_WeatherAPIConfig__c customSetting = GB_WeatherAPIConfig__c.getOrgDefaults();
        return customSetting.get(fieldName);
    }
}
