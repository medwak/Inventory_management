table 50112 "IMS Item Journal Batch"
{
    Caption = 'Item Journal Batch';
    DataClassification = CustomerContent;
    DrillDownPageId = "IMS Item Journal Batches";
    LookupPageId = "IMS Item Journal Batches";

    fields
    {
        field(1; Name; Code[10])
        {
            Caption = 'Name';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(4; "Default Entry Type"; Enum "IMS Entry Type")
        {
            Caption = 'Default Entry Type';
        }
    }

    keys
    {
        key(PK; Name)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        ItemJournalLine: Record "IMS Item Journal Line";
    begin
        ItemJournalLine.SetRange("Journal Batch Name", Name);
        ItemJournalLine.DeleteAll(true);
    end;
}
