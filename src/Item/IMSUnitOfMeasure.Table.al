table 50105 "IMS Unit of Measure"
{
    Caption = 'Unit of Measure';
    DataClassification = CustomerContent;
    DrillDownPageId = "IMS Units of Measure";
    LookupPageId = "IMS Units of Measure";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description) { }
    }
}
