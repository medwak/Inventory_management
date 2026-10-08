page 50113 "IMS Lot No. Information List"
{
    Caption = 'Lots';
    PageType = List;
    SourceTable = "IMS Lot No. Information";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Lots)
            {
                field("Item No."; Rec."Item No.") { ToolTip = 'Specifies the item.'; }
                field("Variant Code"; Rec."Variant Code") { ToolTip = 'Specifies the variant.'; }
                field("Lot No."; Rec."Lot No.") { ToolTip = 'Specifies the lot number.'; }
                field(Description; Rec.Description) { ToolTip = 'Specifies the description.'; }
                field(Status; Rec.Status) { ToolTip = 'Specifies whether the lot is available, in quarantine or blocked.'; StyleExpr = StatusStyle; }
                field("Expiration Date"; Rec."Expiration Date") { ToolTip = 'Specifies when the lot expires.'; StyleExpr = ExpiryStyle; }
                field("Manufacturing Date"; Rec."Manufacturing Date") { ToolTip = 'Specifies when the lot was produced.'; }
                field("Vendor Lot No."; Rec."Vendor Lot No.") { ToolTip = 'Specifies the supplier''s lot number.'; }
                field("Certificate No."; Rec."Certificate No.") { ToolTip = 'Specifies the certificate of analysis.'; }
                field(Inventory; Rec.Inventory) { ToolTip = 'Specifies the quantity of the lot on hand.'; }
                field("Status Changed By"; Rec."Status Changed By") { ToolTip = 'Specifies who last changed the status.'; }
                field("Status Changed At"; Rec."Status Changed At") { ToolTip = 'Specifies when the status was last changed.'; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Release)
            {
                Caption = 'Release';
                Image = ReleaseDoc;
                ToolTip = 'Release the lot from quarantine so it can be issued.';

                trigger OnAction()
                begin
                    Rec.SetStatus(Rec.Status::Available);
                end;
            }
            action(Quarantine)
            {
                Caption = 'Quarantine';
                Image = Pause;
                ToolTip = 'Put the lot on hold, e.g. pending quality control.';

                trigger OnAction()
                begin
                    Rec.SetStatus(Rec.Status::Quarantine);
                end;
            }
            action(Block)
            {
                Caption = 'Block (Recall)';
                Image = Stop;
                ToolTip = 'Block the lot, e.g. for a recall. Blocked stock can only be scrapped by negative adjustment.';

                trigger OnAction()
                begin
                    Rec.SetStatus(Rec.Status::Blocked);
                end;
            }
            action(ShowExpiring)
            {
                Caption = 'Show Expiring Soon';
                Image = Calendar;
                ToolTip = 'Show lots in stock that expire within the warning period from the setup.';

                trigger OnAction()
                var
                    ExpiryMgt: Codeunit "IMS Expiry Mgt.";
                begin
                    Rec.SetRange("Expiration Date", WorkDate(), ExpiryMgt.GetWarningDate(WorkDate()));
                    Rec.SetFilter(Inventory, '>0');
                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            action(LedgerEntries)
            {
                Caption = 'Ledger Entries (Traceability)';
                Image = ItemTracing;
                RunObject = page "IMS Item Ledger Entries";
                RunPageLink = "Item No." = field("Item No."), "Variant Code" = field("Variant Code"), "Lot No." = field("Lot No.");
                ToolTip = 'View every movement of the lot: where it came from and where it went.';
            }
        }
        area(Promoted)
        {
            actionref(Release_Promoted; Release) { }
            actionref(Quarantine_Promoted; Quarantine) { }
            actionref(Block_Promoted; Block) { }
            actionref(LedgerEntries_Promoted; LedgerEntries) { }
        }
    }

    var
        StatusStyle: Text;
        ExpiryStyle: Text;

    trigger OnAfterGetRecord()
    begin
        case Rec.Status of
            Rec.Status::Available:
                StatusStyle := 'Favorable';
            Rec.Status::Quarantine:
                StatusStyle := 'Ambiguous';
            Rec.Status::Blocked:
                StatusStyle := 'Unfavorable';
        end;
        ExpiryStyle := 'Standard';
        if (Rec."Expiration Date" <> 0D) and (Rec."Expiration Date" < WorkDate()) then
            ExpiryStyle := 'Unfavorable';
    end;
}
