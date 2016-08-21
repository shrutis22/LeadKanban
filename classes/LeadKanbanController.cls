public class LeadKanbanController {
    public static String LEAD_MOVED = '{0} was moved successfully to {1}';
    
    public List<Schema.PicklistEntry> leadStatuses  { get; set; }
    public Map<String, List<Lead>> allLeads         { get; set; }
    
    public class UpdateStatus {
        public Boolean isSuccess;
        public String message;
    }
    
    public LeadKanbanController() {
        leadStatuses = Lead.Status.getDescribe().getPicklistValues();
        fetchLeads();
    }
    
    @RemoteAction
    public static UpdateStatus updateLeadStatus( Id leadId, String newLeadStatus ) {
        Lead leadDetails = [
            SELECT  Id
                    ,Name
            FROM    Lead
            WHERE   Id = :leadId
        ];
        
        leadDetails.Status = newLeadStatus;
        UPDATE leadDetails;
        
        UpdateStatus updatedLeadDetails = new UpdateStatus();
        updatedLeadDetails.isSuccess    = true;
        updatedLeadDetails.message      = String.format( LEAD_MOVED, new List<String>{ leadDetails.Name, newLeadStatus } );
        
        return updatedLeadDetails;
    }
    
    private void fetchLeads() {
        List<Lead> leads = [
            SELECT  Id
                    ,Name
                    ,Title
                    ,Company
                    ,Email
                    ,Status
            FROM    Lead
        ];
        
        allLeads = new Map<String, List<Lead>>();
        
        for( Schema.PicklistEntry ple : leadStatuses ) {
            allLeads.put( ple.getValue(), new List<Lead>() );
        }
        
        for( Lead lead : leads ) {
            allLeads.get( lead.Status ).add( lead );
        }
    }
}
