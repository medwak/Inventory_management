table 50108 "IMS Bin"
{
    Caption = 'Bin';
    DataClassification = CustomerContent;
    DrillDownPageId = "IMS Bins";
    LookupPageId = "IMS Bins";

    fields
    {
        field(1; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = "IMS Location";
            NotBlank = true;
        }
        field(2; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(4; Blocked; Boolean)
        {
            Caption = 'Blocked';
        }
        field(10; Inventory; Decimal)
        {
            Caption = 'Inventory (Base)';
            FieldClass = FlowField;
            CalcFormula = sum("IMS Item Ledger Entry".Quantity where("Location Code" = field("Location Code"), "Bin Code" = field(Code)));
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Location Code", "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description) { }
    }
}
