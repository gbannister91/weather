global with sharing class GB_weatherCalloutBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts{
   
    global GB_weatherCalloutBatch() {}
    
    global List<Contact> start(Database.BatchableContext bc) 
    {   

        List<Contact> returnList = new List<Contact>();
        //Enhancement - use other address also, use latitude & longitude. Allow for more than 100
        //Optional enhancement - if both are empty, use capital city of country, or default to London. Filter out non UK countries
        String query = 'SELECT Id, MailingCity, MailingPostalCode FROM Contact WHERE MailingCity != null OR MailingPostalCode != null';
        List<Contact> cons = Database.query(query);
        
       	
        return cons;
       
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> recordsToUpdate)
    {

        List<GB_weather__c> recordsToUpsert = new List<GB_weather__c>();
        for (Contact con : recordsToUpdate)
        {
            //optional enhancement: where parameters match, only make one callout and use map to update all relevent records
            String parameter = String.isNotBlank(con.MailingPostalCode)?con.MailingPostalCode.replaceAll(' ',''):con.MailingCity;
            GB_weather__c weatherRecord = GB_weatherCalloutService.makeCallout(parameter, con.Id, false);
            if (weatherRecord != null) {
                recordsToUpsert.add(weatherRecord);
            }
        }          
        GB_weatherAccessor.handleUpserts(recordsToUpsert);
    }
    
    global void finish(Database.BatchableContext bc){
    }
    
    
    // Allow for batches to be scheduled
    global void execute(SchedulableContext sc) {
        GB_weatherCalloutBatch.scheduleBatches();
    }
    
    public static void scheduleBatches() {
        // Execute batch with size 100 to protect callout limits
        GB_weatherCalloutBatch batchObject = new GB_weatherCalloutBatch();
        Database.executeBatch(batchObject,100);
    }
}
