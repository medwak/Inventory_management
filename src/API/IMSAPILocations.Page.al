/// <summary>REST: /api/ims/inventory/v1.0/companies({id})/locations</summary>
page 50131 "IMS API Locations"
{
    PageType = API;
    APIPublisher = 'ims';
    APIGroup = 'inventory';
    APIVersion = 'v1.0';
    EntityName = 'location';
    EntitySetName = 'locations';
    EntityCaption = 'Location';
    EntitySetCaption = 'Locations';
    SourceTable = "IMS Location";
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field("code"; Rec."Code") { Caption = 'Code'; }
                field(displayName; Rec.Name) { Caption = 'Name'; }
                field(address; Rec.Address) { Caption = 'Address'; }
                field(city; Rec.City) { Caption = 'City'; }
                field(countryRegionCode; Rec."Country/Region Code") { Caption = 'Country/Region Code'; }
                field(binMandatory; Rec."Bin Mandatory") { Caption = 'Bin Mandatory'; }
                field(temperatureControlled; Rec."Temperature Controlled") { Caption = 'Temperature Controlled'; }
                field(blocked; Rec.Blocked) { Caption = 'Blocked'; }
            }
        }
    }
}
