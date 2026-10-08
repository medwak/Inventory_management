/// <summary>
/// Posts all lines of a journal batch in one transaction: check every line first, then post,
/// then delete the journal lines. Any error rolls back the whole batch.
/// </summary>
codeunit 50104 "IMS Item Jnl.-Post Batch"
{
    TableNo = "IMS Item Journal Line";

    trigger OnRun()
    begin
        PostBatch(Rec."Journal Batch Name");
    end;

    var
        NothingToPostErr: Label 'There is nothing to post in journal batch %1.', Comment = '%1 = Batch Name';
        DocNoSeriesErr: Label 'Document No. %1 on line %2 does not follow the number series of batch %3. The next number is %4.', Comment = '%1 = Document No., %2 = Line No., %3 = Batch, %4 = Expected No.';

    procedure PostBatch(JournalBatchName: Code[10]) NoOfLinesPosted: Integer
    var
        ItemJnlBatch: Record "IMS Item Journal Batch";
        ItemJnlLine: Record "IMS Item Journal Line";
        ItemJnlCheckLine: Codeunit "IMS Item Jnl.-Check Line";
        ItemJnlPostLine: Codeunit "IMS Item Jnl.-Post Line";
        NoSeries: Codeunit "No. Series";
        LastDocumentNo: Code[20];
        ExpectedDocumentNo: Code[20];
        StartDateTime: DateTime;
    begin
        StartDateTime := CurrentDateTime();
        ItemJnlBatch.Get(JournalBatchName);
        ItemJnlLine.SetRange("Journal Batch Name", JournalBatchName);
        ItemJnlLine.SetFilter("Item No.", '<>%1', '');
        ItemJnlLine.LockTable();
        if ItemJnlLine.IsEmpty() then
            Error(NothingToPostErr, JournalBatchName);

        OnBeforePostBatch(ItemJnlBatch, ItemJnlLine);

        // 1. Check all lines (and consume document numbers) before anything is written.
        ItemJnlLine.FindSet();
        repeat
            ItemJnlCheckLine.RunCheck(ItemJnlLine);
            if (ItemJnlBatch."No. Series" <> '') and (ItemJnlLine."Document No." <> LastDocumentNo) then begin
                ExpectedDocumentNo := NoSeries.GetNextNo(ItemJnlBatch."No. Series", ItemJnlLine."Posting Date");
                if ItemJnlLine."Document No." <> ExpectedDocumentNo then
                    Error(DocNoSeriesErr, ItemJnlLine."Document No.", ItemJnlLine."Line No.", JournalBatchName, ExpectedDocumentNo);
                LastDocumentNo := ItemJnlLine."Document No.";
            end;
        until ItemJnlLine.Next() = 0;

        // 2. Post. One Post Line instance => one register and one entry-no. lock for the batch.
        ItemJnlLine.FindSet();
        repeat
            ItemJnlPostLine.RunWithoutCheck(ItemJnlLine);
            NoOfLinesPosted += 1;
        until ItemJnlLine.Next() = 0;

        // 3. Clear the batch (including empty lines).
        ItemJnlLine.SetRange("Item No.");
        ItemJnlLine.DeleteAll();

        OnAfterPostBatch(ItemJnlBatch, NoOfLinesPosted);
        LogTelemetry(JournalBatchName, NoOfLinesPosted, CurrentDateTime() - StartDateTime);
    end;

    local procedure LogTelemetry(JournalBatchName: Code[10]; NoOfLinesPosted: Integer; PostingDuration: Duration)
    var
        ImsSetup: Record "IMS Setup";
        CustomDimensions: Dictionary of [Text, Text];
    begin
        ImsSetup.GetRecordOnce();
        if not ImsSetup."Enable Posting Telemetry" then
            exit;
        CustomDimensions.Add('JournalBatch', JournalBatchName);
        CustomDimensions.Add('LinesPosted', Format(NoOfLinesPosted));
        CustomDimensions.Add('DurationMs', Format(PostingDuration));
        Session.LogMessage(
            'IMS-0001', 'Inventory journal batch posted', Verbosity::Normal, DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher, CustomDimensions);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostBatch(ItemJnlBatch: Record "IMS Item Journal Batch"; var ItemJnlLine: Record "IMS Item Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostBatch(ItemJnlBatch: Record "IMS Item Journal Batch"; NoOfLinesPosted: Integer)
    begin
    end;
}
