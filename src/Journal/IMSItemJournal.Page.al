page 50115 "IMS Item Journal"
{
    Caption = 'Item Journal';
    PageType = Worksheet;
    SourceTable = "IMS Item Journal Line";
    UsageCategory = Tasks;
    ApplicationArea = All;
    AutoSplitKey = true;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            field(CurrentJnlBatchName; CurrentJnlBatchName)
            {
                Caption = 'Batch Name';
                ToolTip = 'Specifies the journal batch you are working in.';

                trigger OnLookup(var Text: Text): Boolean
                var
                    ItemJnlBatch: Record "IMS Item Journal Batch";
                begin
                    ItemJnlBatch.Name := CurrentJnlBatchName;
                    if Page.RunModal(Page::"IMS Item Journal Batches", ItemJnlBatch) <> Action::LookupOK then
                        exit(false);
                    // Returning true assigns Text to the field and runs OnValidate.
                    Text := ItemJnlBatch.Name;
                    exit(true);
                end;

                trigger OnValidate()
                var
                    ItemJnlBatch: Record "IMS Item Journal Batch";
                begin
                    ItemJnlBatch.Get(CurrentJnlBatchName);
                    SetBatchFilter();
                    CurrPage.Update(false);
                end;
            }
            repeater(Lines)
            {
                field("Posting Date"; Rec."Posting Date") { ToolTip = 'Specifies the posting date.'; }
                field("Entry Type"; Rec."Entry Type") { ToolTip = 'Specifies the type of movement: purchase, sale, adjustment, transfer, consumption or output.'; }
                field("Document No."; Rec."Document No.") { ToolTip = 'Specifies the document number.'; }
                field("External Document No."; Rec."External Document No.") { ToolTip = 'Specifies the external reference, e.g. delivery note, production order, project or prescription.'; }
                field("Item No."; Rec."Item No.") { ToolTip = 'Specifies the item.'; }
                field("Variant Code"; Rec."Variant Code") { ToolTip = 'Specifies the variant.'; }
                field(Description; Rec.Description) { ToolTip = 'Specifies the description.'; }
                field("Location Code"; Rec."Location Code") { ToolTip = 'Specifies the location (source location for transfers).'; }
                field("Bin Code"; Rec."Bin Code") { ToolTip = 'Specifies the bin.'; }
                field("New Location Code"; Rec."New Location Code") { ToolTip = 'Specifies the destination location of a transfer.'; }
                field("New Bin Code"; Rec."New Bin Code") { ToolTip = 'Specifies the destination bin of a transfer.'; }
                field(Quantity; Rec.Quantity) { ToolTip = 'Specifies the quantity (always positive).'; }
                field("Unit of Measure Code"; Rec."Unit of Measure Code") { ToolTip = 'Specifies the unit of measure.'; }
                field("Quantity (Base)"; Rec."Quantity (Base)") { ToolTip = 'Specifies the quantity in the base unit of measure.'; Visible = false; }
                field("Unit Cost"; Rec."Unit Cost") { ToolTip = 'Specifies the unit cost of receipts.'; }
                field(Amount; Rec.Amount) { ToolTip = 'Specifies the line amount.'; }
                field("Lot No."; Rec."Lot No.") { ToolTip = 'Specifies the lot. Required on receipts of lot tracked items; leave blank on issues to pick lots automatically (FIFO/FEFO).'; }
                field("Serial No."; Rec."Serial No.") { ToolTip = 'Specifies the serial number.'; }
                field("Expiration Date"; Rec."Expiration Date") { ToolTip = 'Specifies the expiration date of a new lot.'; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Post)
            {
                Caption = 'P&ost';
                Image = PostOrder;
                ShortcutKey = 'F9';
                ToolTip = 'Check and post all lines of the batch.';

                trigger OnAction()
                var
                    ItemJnlPost: Codeunit "IMS Item Jnl.-Post";
                begin
                    ItemJnlPost.PostWithConfirmation(CurrentJnlBatchName);
                    CurrPage.Update(false);
                end;
            }
            action(Replenishment)
            {
                Caption = 'Replenishment Worksheet';
                Image = CalculatePlan;
                RunObject = page "IMS Replenishment Worksheet";
                ToolTip = 'Calculate purchase suggestions and carry them out into this journal.';
            }
        }
        area(Navigation)
        {
            action(ItemLedgerEntries)
            {
                Caption = 'Item Ledger Entries';
                Image = ItemLedger;
                ShortcutKey = 'Ctrl+F7';
                RunObject = page "IMS Item Ledger Entries";
                RunPageLink = "Item No." = field("Item No.");
                ToolTip = 'View the posted entries of the item on the current line.';
            }
        }
        area(Promoted)
        {
            actionref(Post_Promoted; Post) { }
            actionref(Replenishment_Promoted; Replenishment) { }
        }
    }

    var
        CurrentJnlBatchName: Code[10];
        DefaultBatchNameTok: Label 'DEFAULT', Locked = true;
        DefaultBatchDescTxt: Label 'Default journal';

    trigger OnOpenPage()
    begin
        OpenJournal();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Journal Batch Name" := CurrentJnlBatchName;
        Rec.SetUpNewLine(xRec);
    end;

    procedure SetJournalBatch(NewBatchName: Code[10])
    begin
        CurrentJnlBatchName := NewBatchName;
    end;

    local procedure OpenJournal()
    var
        ItemJnlBatch: Record "IMS Item Journal Batch";
    begin
        if (CurrentJnlBatchName = '') or not ItemJnlBatch.Get(CurrentJnlBatchName) then
            if ItemJnlBatch.FindFirst() then
                CurrentJnlBatchName := ItemJnlBatch.Name
            else begin
                ItemJnlBatch.Init();
                ItemJnlBatch.Name := DefaultBatchNameTok;
                ItemJnlBatch.Description := DefaultBatchDescTxt;
                ItemJnlBatch.Insert(true);
                CurrentJnlBatchName := ItemJnlBatch.Name;
            end;
        SetBatchFilter();
    end;

    local procedure SetBatchFilter()
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("Journal Batch Name", CurrentJnlBatchName);
        Rec.FilterGroup(0);
    end;
}
