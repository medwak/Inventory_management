table 50102 "IMS Item Category"
{
    Caption = 'Item Category';
    DataClassification = CustomerContent;
    DrillDownPageId = "IMS Item Categories";
    LookupPageId = "IMS Item Categories";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Parent Category"; Code[20])
        {
            Caption = 'Parent Category';
            TableRelation = "IMS Item Category";

            trigger OnValidate()
            begin
                if "Parent Category" = Code then
                    FieldError("Parent Category");
            end;
        }
        field(4; "Industry Profile Code"; Code[20])
        {
            Caption = 'Industry Profile Code';
            TableRelation = "IMS Industry Profile";
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
        key(Parent; "Parent Category") { }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description) { }
    }
}
