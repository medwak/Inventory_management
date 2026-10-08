page 50105 "IMS Item Card"
{
    Caption = 'Item Card';
    PageType = Card;
    SourceTable = "IMS Item";
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the item number.';
                    Importance = Promoted;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field(Description; Rec.Description) { ToolTip = 'Specifies the item description.'; Importance = Promoted; }
                field("Description 2"; Rec."Description 2") { ToolTip = 'Specifies additional description text.'; Importance = Additional; }
                field("Industry Profile Code"; Rec."Industry Profile Code") { ToolTip = 'Specifies the industry profile. Changing it applies the industry''s defaults for tracking, expiry, costing and picking.'; Importance = Promoted; }
                field("Industry Type"; Rec."Industry Type") { ToolTip = 'Specifies the industry rule set applied to the item.'; }
                field("Item Category Code"; Rec."Item Category Code") { ToolTip = 'Specifies the item category.'; }
                field(GTIN; Rec.GTIN) { ToolTip = 'Specifies the GTIN-8/12/13/14 barcode. The check digit is validated.'; }
                field(Blocked; Rec.Blocked) { ToolTip = 'Specifies whether the item is blocked from posting.'; }
                field("Last Date Modified"; Rec."Last Date Modified") { ToolTip = 'Specifies when the item was last changed.'; }
            }
            group(InventoryGroup)
            {
                Caption = 'Inventory';
                field("Base Unit of Measure"; Rec."Base Unit of Measure") { ToolTip = 'Specifies the unit in which inventory is held.'; Importance = Promoted; }
                field(Inventory; Rec.Inventory) { ToolTip = 'Specifies the quantity on hand across all locations.'; Importance = Promoted; }
                field("Inventory Value"; Rec."Inventory Value") { ToolTip = 'Specifies the value of the quantity on hand.'; }
                field("No. of Variants"; Rec."No. of Variants") { ToolTip = 'Specifies how many variants the item has.'; }
            }
            group(Tracking)
            {
                Caption = 'Item Tracking';
                field("Item Tracking Type"; Rec."Item Tracking Type") { ToolTip = 'Specifies whether the item is tracked by lot and/or serial number.'; }
                field("Expiration Date Required"; Rec."Expiration Date Required") { ToolTip = 'Specifies whether received lots must have an expiration date.'; }
                field("Shelf Life"; Rec."Shelf Life") { ToolTip = 'Specifies the shelf life used to calculate the expiration date of a new lot, for example 180D.'; }
                field("Picking Strategy"; Rec."Picking Strategy") { ToolTip = 'Specifies in which order stock is consumed. Some industries enforce FEFO.'; }
            }
            group(Costing)
            {
                Caption = 'Costs & Prices';
                field("Costing Method"; Rec."Costing Method") { ToolTip = 'Specifies how outbound entries are valued.'; }
                field("Unit Cost"; Rec."Unit Cost") { ToolTip = 'Specifies the current average unit cost of stock on hand.'; }
                field("Standard Cost"; Rec."Standard Cost") { ToolTip = 'Specifies the standard cost, used when Costing Method is Standard.'; }
                field("Unit Price"; Rec."Unit Price") { ToolTip = 'Specifies the sales price per base unit.'; }
            }
            group(Replenishment)
            {
                Caption = 'Replenishment';
                field("Replenishment Policy"; Rec."Replenishment Policy") { ToolTip = 'Specifies how replenishment is planned. Stockkeeping units override these values per location.'; }
                field("Reorder Point"; Rec."Reorder Point") { ToolTip = 'Specifies the inventory level at or below which a reorder is suggested.'; }
                field("Reorder Quantity"; Rec."Reorder Quantity") { ToolTip = 'Specifies the fixed quantity ordered with the Fixed Reorder Qty. policy.'; }
                field("Maximum Inventory"; Rec."Maximum Inventory") { ToolTip = 'Specifies the level to order up to with the Maximum Qty. policy.'; }
                field("Safety Stock Quantity"; Rec."Safety Stock Quantity") { ToolTip = 'Specifies the buffer stock that should always be on hand.'; }
                field("Lead Time Calculation"; Rec."Lead Time Calculation") { ToolTip = 'Specifies the replenishment lead time, for example 7D.'; }
            }
            part(Attributes; "IMS Item Attribute Values")
            {
                Caption = 'Attributes';
                SubPageLink = "Item No." = field("No.");
                UpdatePropagation = Both;
            }
        }
        area(FactBoxes)
        {
            systempart(Links; Links) { }
            systempart(Notes; Notes) { }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(LedgerEntries)
            {
                Caption = 'Ledger Entries';
                Image = ItemLedger;
                ShortcutKey = 'Ctrl+F7';
                RunObject = page "IMS Item Ledger Entries";
                RunPageLink = "Item No." = field("No.");
                RunPageView = sorting("Item No.", "Location Code", "Variant Code", "Posting Date") order(descending);
                ToolTip = 'View the history of transactions for the item.';
            }
            action(Variants)
            {
                Caption = 'Variants';
                Image = ItemVariant;
                RunObject = page "IMS Item Variants";
                RunPageLink = "Item No." = field("No.");
                ToolTip = 'Set up variants such as size, colour or strength.';
            }
            action(UnitsOfMeasure)
            {
                Caption = 'Units of Measure';
                Image = UnitOfMeasure;
                RunObject = page "IMS Item Units of Measure";
                RunPageLink = "Item No." = field("No.");
                ToolTip = 'Set up alternative units of measure and their conversion to the base unit.';
            }
            action(StockkeepingUnits)
            {
                Caption = 'Stockkeeping Units';
                Image = SKU;
                RunObject = page "IMS Stockkeeping Units";
                RunPageLink = "Item No." = field("No.");
                ToolTip = 'Set up replenishment parameters per location and variant.';
            }
            action(Lots)
            {
                Caption = 'Lots';
                Image = Lot;
                RunObject = page "IMS Lot No. Information List";
                RunPageLink = "Item No." = field("No.");
                ToolTip = 'View the lots of the item with expiry and status.';
            }
        }
        area(Promoted)
        {
            actionref(LedgerEntries_Promoted; LedgerEntries) { }
            actionref(Variants_Promoted; Variants) { }
            actionref(Lots_Promoted; Lots) { }
        }
    }
}
