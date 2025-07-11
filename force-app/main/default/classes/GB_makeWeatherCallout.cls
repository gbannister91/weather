public class GB_makeWeatherCallout implements Queueable, Database.AllowsCallouts{

    public List<Contact> contacts;
    private Boolean chainCalls;
    public GB_makeWeatherCallout(List<Contact> contacts){
        this.contacts = contacts;
    }

    public void execute(QueueableContext context) {
        List<GB_weather__c> recordsToUpsert = new List<GB_Weather__c>();
        if(this.contacts.size() > 100) {
            this.chainCalls = true;
            for(integer i = 0; i<100; i++) {
                String parameter = String.isNotBlank(this.contacts[0].MailingPostalCode)?this.contacts[0].MailingPostalCode.replaceAll(' ',''):this.contacts[0].MailingCity;
                GB_weather__c weatherRecord = GB_weatherCalloutService.makeCallout(parameter, this.contacts[0].Id, false);
                if (weatherRecord != null) {
                    recordsToUpsert.add(weatherRecord);
                }
                this.contacts.remove(0);
            }
        }
        else {
            this.chainCalls = false;
            for(Contact con : this.contacts) {
                String parameter = String.isNotBlank(con.MailingPostalCode)?con.MailingPostalCode.replaceAll(' ',''):con.MailingCity;
                GB_weather__c weatherRecord = GB_weatherCalloutService.makeCallout(parameter, con.Id, false);
                if (weatherRecord != null) {
                    recordsToUpsert.add(weatherRecord);
                }
            }      
        }    
        GB_weatherAccessor.handleUpserts(recordsToUpsert);
        if(this.chainCalls && !Test.isRunningTest()) {
            System.enqueueJob(new GB_makeWeatherCallout(this.contacts));
        }
    }

}
