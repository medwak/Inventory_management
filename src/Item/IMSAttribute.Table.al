/// <summary>
/// Free-form, industry specific item characteristics without schema changes:
/// e.g. Active Ingredient / Storage Temp. (pharma), Allergens (food), Size / Colour (retail),
/// Grade / Load Rating (construction). Attributes with a blank profile apply to all industries.
/// </summary>
table 50109 "IMS Attribute"
{
    Caption = 'Item Attribute';
    DataClassification = CustomerContent;
    DrillDownPageId = "IMS Attributes";
    LookupPageId = "IMS Attributes";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
        }
        field(3; Type; Enum "IMS Attribute Type")
        {
            Caption = 'Type';
        }
        field(4; "Option Values"; Text[250])
        {
            Caption = 'Option Values';
        }
        field(5; "Industry Profile Code"; Code[20])
        {
            Caption = 'Industry Profile Code';
            TableRelation = "IMS Industry Profile";
        }
        field(6; Mandatory; Boolean)
        {
            Caption = 'Mandatory';
        }
        field(7; "Unit of Measure"; Text[30])
        {
            Caption = 'Unit of Measure';
        }
        field(8; Blocked; Boolean)
        {
            Caption = 'Blocked';
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
        key(Profile; "Industry Profile Code", Mandatory) { }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Name, Type) { }
    }

    trigger OnDelete()
    var
        ItemAttributeValue: Record "IMS Item Attribute Value";
    begin
        ItemAttributeValue.SetRange("Attribute Code", Code);
        ItemAttributeValue.DeleteAll();
    end;
}
