/// <summary>Links an outbound entry to the inbound layer(s) it consumed: quantity and cost.</summary>
table 50115 "IMS Item Application Entry"
{
    Caption = 'Item Application Entry';
    DataClassification = CustomerContent;
    DrillDownPageId = "IMS Item Application Entries";
    LookupPageId = "IMS Item Application Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Inbound Item Entry No."; Integer)
        {
            Caption = 'Inbound Item Entry No.';
            TableRelation = "IMS Item Ledger Entry";
        }
        field(3; "Outbound Item Entry No."; Integer)
        {
            Caption = 'Outbound Item Entry No.';
            TableRelation = "IMS Item Ledger Entry";
        }
        field(4; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(5; "Cost Amount"; Decimal)
        {
            Caption = 'Cost Amount';
            AutoFormatType = 1;
        }
        field(6; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Inbound; "Inbound Item Entry No.")
        {
            SumIndexFields = Quantity, "Cost Amount";
        }
        key(Outbound; "Outbound Item Entry No.") { }
    }
}
