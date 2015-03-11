public class Utilities {
    public class ListViewWrapper {
        public List<String> fields {get; set;}
        public List<String> columnNames {get; set;}
        public List<Sobject> allRecords {get; set;}

        private String objectName;
        private String listId;

        public ListViewWrapper(String objectName, String listId) {
            this.objectName = objectName;
            this.listId = listId;

            fields = new List<String>();
            columnNames = new List<String>();
            allRecords = new List<Sobject>();
        }

        public void fetchListViewDetail() {
            // Http callout 
            HttpRequest req = new HttpRequest();
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
            req.setHeader('Content-Type', 'application/json');
            String endpoint = String.format(
                '{0}/services/data/v32.0/sobjects/{1}/listviews/{2}/describe', 
                new List<String> {
                    URL.getSalesforceBaseUrl().toExternalForm(),
                    objectName, listId
                }
            );

            req.setEndpoint(endpoint);
            req.setMethod('GET');

            HttpResponse res = new Http().send(req);
            Map<String,Object> root = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());

            // Nested list logic to overcome collection limit
            for (Sobject sobj : Database.query((String)root.get('query'))){
                if (allRecords.size() == 10000) break;
                allRecords.add(sobj);
            }
            
            // Parsing JSON string to get the column details
            List<Utilities.Columns> parsedColumns =
                (List<Utilities.Columns>) System.JSON.deserialize(
                    JSON.serialize(root.get('columns')), 
                    List<Utilities.Columns>.class
                );

            for (Utilities.Columns lc : parsedColumns) {
                if(lc.hidden == false && lc.fieldNameOrPath != Null){
                    fields.add(lc.fieldNameOrPath);
                    columnNames.add(lc.label);    
                }
            }
        }
    }

    public class Columns {
        public String ascendingLabel;
        public String descendingLabel;
        public String fieldNameOrPath;
        public Boolean hidden;
        public String label;
        public String selectListItem;
        public String sortDirection;
        public Integer sortIndex;
        public Boolean sortable;
        public String type;
    }
}