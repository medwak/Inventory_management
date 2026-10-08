/// <summary>REST: /api/ims/inventory/v1.0/companies({id})/items</summary>
page 50130 "IMS API Items"
{
    PageType = API;
    APIPublisher = 'ims';
    APIGroup = 'inventory';
    APIVersion = 'v1.0';
    EntityName = 'item';
    EntitySetName = 'items';
    EntityCaption = 'Item';
    EntitySetCaption = 'Items';
    SourceTable = "IMS Item";
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
                field(number; Rec."No.") { Caption = 'No.'; }
                field(displayName; Rec.Description) { Caption = 'Display Name'; }
                field(industryProfileCode; Rec."Industry Profile Code") { Caption = 'Industry Profile Code'; }
                field(itemCategoryCode; Rec."Item Category Code") { Caption = 'Item Category Code'; }
                field(baseUnitOfMeasureCode; Rec."Base Unit of Measure") { Caption = 'Base Unit of Measure'; }
                field(gtin; Rec.GTIN) { Caption = 'GTIN'; }
                field(itemTrackingType; Rec."Item Tracking Type") { Caption = 'Item Tracking Type'; }
                field(expirationDateRequired; Rec."Expiration Date Required") { Caption = 'Expiration Date Required'; }
                field(costingMethod; Rec."Costing Method") { Caption = 'Costing Method'; }
                field(pickingStrategy; Rec."Picking Strategy") { Caption = 'Picking Strategy'; }
                field(unitCost; Rec."Unit Cost") { Caption = 'Unit Cost'; }
                field(standardCost; Rec."Standard Cost") { Caption = 'Standard Cost'; }
                field(unitPrice; Rec."Unit Price") { Caption = 'Unit Price'; }
                field(replenishmentPolicy; Rec."Replenishment Policy") { Caption = 'Replenishment Policy'; }
                field(reorderPoint; Rec."Reorder Point") { Caption = 'Reorder Point'; }
                field(reorderQuantity; Rec."Reorder Quantity") { Caption = 'Reorder Quantity'; }
                field(maximumInventory; Rec."Maximum Inventory") { Caption = 'Maximum Inventory'; }
                field(inventory; Rec.Inventory) { Caption = 'Inventory'; Editable = false; }
                field(inventoryValue; Rec."Inventory Value") { Caption = 'Inventory Value'; Editable = false; }
                field(blocked; Rec.Blocked) { Caption = 'Blocked'; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified Date Time'; Editable = false; }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.Insert(true);
        exit(false);
    end;
}
