/// <summary>REST (read-only): /api/ims/inventory/v1.0/companies({id})/itemLedgerEntries</summary>
page 50132 "IMS API Item Ledger Entries"
{
    PageType = API;
    APIPublisher = 'ims';
    APIGroup = 'inventory';
    APIVersion = 'v1.0';
    EntityName = 'itemLedgerEntry';
    EntitySetName = 'itemLedgerEntries';
    EntityCaption = 'Item Ledger Entry';
    EntitySetCaption = 'Item Ledger Entries';
    SourceTable = "IMS Item Ledger Entry";
    ODataKeyFields = SystemId;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    DataAccessIntent = ReadOnly;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; }
                field(entryNumber; Rec."Entry No.") { Caption = 'Entry No.'; }
                field(itemNumber; Rec."Item No.") { Caption = 'Item No.'; }
                field(variantCode; Rec."Variant Code") { Caption = 'Variant Code'; }
                field(postingDate; Rec."Posting Date") { Caption = 'Posting Date'; }
                field(entryType; Rec."Entry Type") { Caption = 'Entry Type'; }
                field(documentNumber; Rec."Document No.") { Caption = 'Document No.'; }
                field(externalDocumentNumber; Rec."External Document No.") { Caption = 'External Document No.'; }
                field(locationCode; Rec."Location Code") { Caption = 'Location Code'; }
                field(binCode; Rec."Bin Code") { Caption = 'Bin Code'; }
                field(lotNumber; Rec."Lot No.") { Caption = 'Lot No.'; }
                field(serialNumber; Rec."Serial No.") { Caption = 'Serial No.'; }
                field(expirationDate; Rec."Expiration Date") { Caption = 'Expiration Date'; }
                field(quantity; Rec.Quantity) { Caption = 'Quantity'; }
                field(remainingQuantity; Rec."Remaining Quantity") { Caption = 'Remaining Quantity'; }
                field(costAmount; Rec."Cost Amount") { Caption = 'Cost Amount'; }
            }
        }
    }
}
