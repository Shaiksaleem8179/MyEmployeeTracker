/**
 * @description       : 
 * @author            : Shaik Saleem
 * @group             : 
 * @last modified on  : 03-26-2024
 * @last modified by  : Shaik Saleem
**/
public class BackupDailyExp implements Database.Batchable<sObject> {
        
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String Query ='SELECT Spent_on_What__c,Spent_Amount__c,Spent_Date__c,Who_Spent__r.Name,Payment_Type__r.Name,Payment_Type__r.Id,Who_Spent__r.Id,Yet_to_Calculate__c FROM Daily_Expenses__c WHERE Yet_to_Calculate__c =false';
        return Database.getQueryLocator(Query);
    }

    public void execute(Database.BatchableContext BC, List<Daily_Expenses__c> scope) {
        List<Daily_Expenses_Backup__c> UpdateBackups = new List<Daily_Expenses_Backup__c>();
        List<Daily_Expenses__c> UpdateDailyExp = new List<Daily_Expenses__c>();
        for (Daily_Expenses__c BackupEXP : scope) {
            Daily_Expenses_Backup__c newrec = New Daily_Expenses_Backup__c();
            newrec.Spent_Amount__c=BackupEXP.Spent_Amount__c;
            newrec.Employee__c=BackupEXP.Who_Spent__r.Id;
            newrec.Payment_Bank__c=BackupEXP.Payment_Type__r.Id;
            newrec.Payment_Type__c  =BackupEXP.Payment_Type__r.Name;         
            newrec.Spent_Date__c=BackupEXP.Spent_Date__c;
            newrec.Spent_on_What__c=BackupEXP.Spent_on_What__c;
            newrec.Who_Spent__c=BackupEXP.Who_Spent__r.Name;
            newrec.Yet_to_Calculate__c=true;
           UpdateBackups.add(newrec); 
           //Update yet to calculate as true
           BackupEXP.Yet_to_Calculate__c =true;
           UpdateDailyExp.add(BackupEXP);
        }
        try {
            Insert UpdateBackups;
            Update UpdateDailyExp;
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }
    public void finish(Database.BatchableContext BC) {
        // Get the ID of the AsyncApexJob representing this batch job
   // from Database.BatchableContext.
   // Query the AsyncApexJob object to retrieve the current job's information.
   AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
      TotalJobItems, CreatedBy.Email
      FROM AsyncApexJob WHERE Id =
      :BC.getJobId()];
   // Send an email to the Apex job's submitter notifying of job completion.
   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
   String[] toAddresses = new String[] {a.CreatedBy.Email};
   mail.setToAddresses(toAddresses);
   mail.setSubject('Apex Sharing Recalculation ' + a.Status);
   mail.setPlainTextBody
   ('The batch Apex job processed ' + a.TotalJobItems +
   ' batches with '+ a.NumberOfErrors + ' failures.');
   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}