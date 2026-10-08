page 50116 "IMS Item Ledger Entries"
{
    Caption = 'Item Ledger Entries';
    PageType = List;
    SourceTable = "IMS Item Ledger Entry";
    SourceTableView = sorting("Entry No.") order(descending);
    UsageCategory = History;
    ApplicationArea = All;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Entries)
            {
                field("Posting Date"; Rec."Posting Date") { ToolTip = 'Specifies the posting date.'; }
                field("Entry Type"; Rec."Entry Type") { ToolTip = 'Specifies the entry type.'; }
                field("Document No."; Rec."Document No.") { ToolTip = 'Specifies the document number.'; }
                field("External Document No."; Rec."External Document No.") { ToolTip = 'Specifies the external reference.'; }
                field("Item No."; Rec."Item No.") { ToolTip = 'Specifies the item.'; }
                field("Variant Code"; Rec."Variant Code") { ToolTip = 'Specifies the variant.'; }
                field(Description; Rec.Description) { ToolTip = 'Specifies the description.'; }
                field("Location Code"; Rec."Location Code") { ToolTip = 'Specifies the location.'; }
                field("Bin Code"; Rec."Bin Code") { ToolTip = 'Specifies the bin.'; }
                field("Lot No."; Rec."Lot No.") { ToolTip = 'Specifies the lot.'; }
                field("Serial No."; Rec."Serial No.") { ToolTip = 'Specifies the serial number.'; }
                field("Expiration Date"; Rec."Expiration Date") { ToolTip = 'Specifies the expiration date of the lot.'; }
                field(Quantity; Rec.Quantity) { ToolTip = 'Specifies the quantity in base units (negative for issues).'; }
                field("Remaining Quantity"; Rec."Remaining Quantity") { ToolTip = 'Specifies how much of a receipt is still in stock.'; }
                field(Open; Rec.Open) { ToolTip = 'Specifies whether the receipt still has stock remaining.'; }
                field("Cost Amount"; Rec."Cost Amount") { ToolTip = 'Specifies the cost value of the entry.'; }
                field("User ID"; Rec."User ID") { ToolTip = 'Specifies who posted the entry.'; Visible = false; }
                field("Register No."; Rec."Register No.") { ToolTip = 'Specifies the register (posting run).'; Visible = false; }
                field("Entry No."; Rec."Entry No.") { ToolTip = 'Specifies the entry number.'; }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Applications)
            {
                Caption = 'Applications';
                Image = Approve;
                ToolTip = 'View which receipts this issue consumed, or which issues consumed this receipt.';

                trigger OnAction()
                var
                    ItemApplicationEntry: Record "IMS Item Application Entry";
                begin
                    if Rec.Positive then
                        ItemApplicationEntry.SetRange("Inbound Item Entry No.", Rec."Entry No.")
                    else
                        ItemApplicationEntry.SetRange("Outbound Item Entry No.", Rec."Entry No.");
                    Page.Run(Page::"IMS Item Application Entries", ItemApplicationEntry);
                end;
            }
        }
        area(Promoted)
        {
            actionref(Applications_Promoted; Applications) { }
        }
    }
}
