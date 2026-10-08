page 50118 "IMS Registers"
{
    Caption = 'Inventory Registers';
    PageType = List;
    SourceTable = "IMS Register";
    SourceTableView = sorting("No.") order(descending);
    UsageCategory = History;
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Registers)
            {
                field("No."; Rec."No.") { ToolTip = 'Specifies the register number.'; }
                field("Creation Date"; Rec."Creation Date") { ToolTip = 'Specifies when the posting ran.'; }
                field("Creation Time"; Rec."Creation Time") { ToolTip = 'Specifies the time of the posting.'; }
                field("User ID"; Rec."User ID") { ToolTip = 'Specifies who posted.'; }
                field("Journal Batch Name"; Rec."Journal Batch Name") { ToolTip = 'Specifies the posted journal batch.'; }
                field("From Entry No."; Rec."From Entry No.") { ToolTip = 'Specifies the first ledger entry created.'; }
                field("To Entry No."; Rec."To Entry No.") { ToolTip = 'Specifies the last ledger entry created.'; }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(ItemLedger)
            {
                Caption = 'Item Ledger';
                Image = ItemLedger;
                ToolTip = 'View the ledger entries created by this posting run.';

                trigger OnAction()
                var
                    ItemLedgerEntry: Record "IMS Item Ledger Entry";
                begin
                    ItemLedgerEntry.SetRange("Entry No.", Rec."From Entry No.", Rec."To Entry No.");
                    Page.Run(Page::"IMS Item Ledger Entries", ItemLedgerEntry);
                end;
            }
        }
        area(Promoted)
        {
            actionref(ItemLedger_Promoted; ItemLedger) { }
        }
    }
}
