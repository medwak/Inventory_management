/// <summary>Per-user replenishment worksheet line (suggestion to purchase/produce stock).</summary>
table 50118 "IMS Replenishment Line"
{
    Caption = 'Replenishment Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = "IMS Item";
        }
        field(4; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "IMS Item Variant".Code where("Item No." = field("Item No."));
        }
        field(5; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = "IMS Location";
        }
        field(6; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(7; "Replenishment Policy"; Enum "IMS Replenishment Policy")
        {
            Caption = 'Replenishment Policy';
            Editable = false;
        }
        field(8; "Current Inventory"; Decimal)
        {
            Caption = 'Current Inventory';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(9; "Reorder Point"; Decimal)
        {
            Caption = 'Reorder Point';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(10; "Safety Stock Quantity"; Decimal)
        {
            Caption = 'Safety Stock Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(11; "Maximum Inventory"; Decimal)
        {
            Caption = 'Maximum Inventory';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(12; "Suggested Quantity"; Decimal)
        {
            Caption = 'Suggested Quantity (Base)';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(13; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
        field(14; "Accept Suggestion"; Boolean)
        {
            Caption = 'Accept Suggestion';
            InitValue = true;
        }
    }

    keys
    {
        key(PK; "User ID", "Line No.")
        {
            Clustered = true;
        }
        key(Item; "Item No.", "Location Code") { }
    }
}
