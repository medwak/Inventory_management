/// <summary>UI wrapper around batch posting: confirmation and result message.</summary>
codeunit 50105 "IMS Item Jnl.-Post"
{
    var
        PostConfirmQst: Label 'Do you want to post the journal lines in batch %1?', Comment = '%1 = Batch Name';
        PostedMsg: Label '%1 journal line(s) were posted.', Comment = '%1 = Number of lines';

    procedure PostWithConfirmation(JournalBatchName: Code[10])
    var
        ItemJnlPostBatch: Codeunit "IMS Item Jnl.-Post Batch";
        NoOfLinesPosted: Integer;
    begin
        if GuiAllowed() then
            if not Confirm(PostConfirmQst, false, JournalBatchName) then
                exit;
        NoOfLinesPosted := ItemJnlPostBatch.PostBatch(JournalBatchName);
        if GuiAllowed() then
            Message(PostedMsg, NoOfLinesPosted);
    end;
}
