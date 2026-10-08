/// <summary>One record per posting run: the range of ledger entries it created (audit trail).</summary>
table 50116 "IMS Register"
{
    Caption = 'Inventory Register';
    DataClassification = CustomerContent;
    DrillDownPageId = "IMS Registers";
    LookupPageId = "IMS Registers";

    fields
    {
        field(1; "No."; Integer)
        {
            Caption = 'No.';
        }
        field(2; "From Entry No."; Integer)
        {
            Caption = 'From Entry No.';
            TableRelation = "IMS Item Ledger Entry";
        }
        field(3; "To Entry No."; Integer)
        {
            Caption = 'To Entry No.';
            TableRelation = "IMS Item Ledger Entry";
        }
        field(4; "Creation Date"; Date)
        {
            Caption = 'Creation Date';
        }
        field(5; "Creation Time"; Time)
        {
            Caption = 'Creation Time';
        }
        field(6; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(7; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }
}
