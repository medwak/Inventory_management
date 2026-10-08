page 50104 "IMS Item List"
{
    Caption = 'Items';
    PageType = List;
    SourceTable = "IMS Item";
    CardPageId = "IMS Item Card";
    UsageCategory = Lists;
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Items)
            {
                field("No."; Rec."No.") { ToolTip = 'Specifies the item number.'; }
                field(Description; Rec.Description) { ToolTip = 'Specifies the item description.'; }
                field("Industry Profile Code"; Rec."Industry Profile Code") { ToolTip = 'Specifies the industry profile that governs the item.'; }
                field("Item Category Code"; Rec."Item Category Code") { ToolTip = 'Specifies the item category.'; }
                field("Base Unit of Measure"; Rec."Base Unit of Measure") { ToolTip = 'Specifies the unit in which inventory is held.'; }
                field(Inventory; Rec.Inventory) { ToolTip = 'Specifies the quantity on hand in the base unit of measure.'; }
                field("Unit Cost"; Rec."Unit Cost") { ToolTip = 'Specifies the current unit cost.'; }
                field("Unit Price"; Rec."Unit Price") { ToolTip = 'Specifies the sales price per base unit.'; }
                field("Item Tracking Type"; Rec."Item Tracking Type") { ToolTip = 'Specifies whether the item is tracked by lot and/or serial number.'; }
                field(GTIN; Rec.GTIN) { ToolTip = 'Specifies the GTIN (barcode).'; Visible = false; }
                field(Blocked; Rec.Blocked) { ToolTip = 'Specifies whether the item is blocked from posting.'; }
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
            action(Lots)
            {
                Caption = 'Lots';
                Image = Lot;
                RunObject = page "IMS Lot No. Information List";
                RunPageLink = "Item No." = field("No.");
                ToolTip = 'View the lots of the item with expiry and status.';
            }
        }
        area(Processing)
        {
            action(ItemJournal)
            {
                Caption = 'Item Journal';
                Image = Journals;
                RunObject = page "IMS Item Journal";
                ToolTip = 'Open the item journal to post receipts, issues, adjustments and transfers.';
            }
        }
        area(Promoted)
        {
            actionref(LedgerEntries_Promoted; LedgerEntries) { }
            actionref(ItemJournal_Promoted; ItemJournal) { }
        }
    }
}
