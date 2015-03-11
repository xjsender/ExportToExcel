public with sharing class ExportListViewToExcelController {
    public String fileName {get; set;}
    public Utilities.ListViewWrapper wrapper {get; set;}

    public void fetchListviewRecords() {
        String listId = apexpages.currentpage().getparameters().get('listId');
        String objName = apexpages.currentpage().getparameters().get('object');
        String listName = apexpages.currentpage().getparameters().get('listName');

        // Populate fileName
        fileName =  objName +'_'+listName.replace(' ','_') +'_'+ Datetime.now().format();

        // Populate wrapper
        wrapper = new Utilities.ListViewWrapper(objName, listId);
        wrapper.fetchListViewDetail();
    }
}