trigger GB_triggerOnContact on Contact (after insert, after update) {

    if (Trigger.isInsert) {
        GB_contactTriggerHandler.afterInsert(Trigger.new);
    }

    if (Trigger.isUpdate) {
        GB_contactTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }

}
