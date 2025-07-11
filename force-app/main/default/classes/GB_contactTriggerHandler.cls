public with sharing class GB_contactTriggerHandler {
    
    public static void afterInsert(List<Contact> contacts) {
        List<Contact> withAddresses = new List<Contact>();
        for (Contact con : contacts) {
            if(String.isNotBlank(con.MailingCity) || String.isNotBlank(con.MailingPostalCode)) {
                withAddresses.add(con);
            }
        }
        if (withAddresses.size() > 0) {
            ID jobID = System.enqueueJob(
                new GB_makeWeatherCallout(withAddresses)
            );
        }
    }

    public static void afterUpdate(List<Contact> newContacts, Map<Id,Contact> oldContactsMap) {
        List<Contact> withAddressUdpates = new List<Contact>();
        for (Contact con : newContacts) {
            if(String.isNotBlank(con.MailingCity) || String.isNotBlank(con.MailingPostalCode)) {
                if(con.MailingCity != oldContactsMap.get(con.Id).MailingCity || con.MailingPostalCode != oldContactsMap.get(con.Id).MailingPostalCode) {
                    withAddressUdpates.add(con);
                }  
            }
        }
        if (withAddressUdpates.size() > 0) {
            ID jobID = System.enqueueJob(
                new GB_makeWeatherCallout(withAddressUdpates)
            );
        }
    }
}
