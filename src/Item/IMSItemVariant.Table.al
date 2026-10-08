/// <summary>Variants such as size/colour (retail), strength (pharma) or grade (construction).</summary>
table 50104 "IMS Item Variant"
{
    Caption = 'Item Variant';
    DataClassification = CustomerContent;
    DrillDownPageId = "IMS Item Variants";
    LookupPageId = "IMS Item Variants";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = "IMS Item";
            NotBlank = true;
        }
        field(2; "Code"; Code[10])
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
    }

    keys
    {
        key(PK; "Item No.", "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description) { }
    }
}
