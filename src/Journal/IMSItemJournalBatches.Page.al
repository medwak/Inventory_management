page 50114 "IMS Item Journal Batches"
{
    Caption = 'Item Journal Batches';
    PageType = List;
    SourceTable = "IMS Item Journal Batch";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Batches)
            {
                field(Name; Rec.Name) { ToolTip = 'Specifies the batch name, e.g. RECEIPTS, COUNT, TRANSFERS or one batch per user/site.'; }
                field(Description; Rec.Description) { ToolTip = 'Specifies the batch description.'; }
                field("No. Series"; Rec."No. Series") { ToolTip = 'Specifies the number series that document numbers must follow.'; }
                field("Default Entry Type"; Rec."Default Entry Type") { ToolTip = 'Specifies the entry type of new lines.'; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(EditJournal)
            {
                Caption = 'Edit Journal';
                Image = OpenJournal;
                ShortcutKey = 'Return';
                ToolTip = 'Open the journal for the selected batch.';

                trigger OnAction()
                var
                    ItemJournal: Page "IMS Item Journal";
                begin
                    ItemJournal.SetJournalBatch(Rec.Name);
                    ItemJournal.Run();
                end;
            }
        }
        area(Promoted)
        {
            actionref(EditJournal_Promoted; EditJournal) { }
        }
    }
}
