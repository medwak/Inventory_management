/// <summary>
/// Data-driven configuration of an industry. Several profiles can share one Industry Type
/// (e.g. "PHARMA-RX" and "PHARMA-OTC"), so most behaviour is configured, not coded.
/// The Industry Type selects the code-driven rules (interface implementation).
/// </summary>
table 50101 "IMS Industry Profile"
{
    Caption = 'Industry Profile';
    DataClassification = CustomerContent;
    DrillDownPageId = "IMS Industry Profiles";
    LookupPageId = "IMS Industry Profiles";

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
        field(3; "Industry Type"; Enum "IMS Industry Type")
        {
            Caption = 'Industry Type';
        }
        field(4; "Default Tracking Type"; Enum "IMS Item Tracking Type")
        {
            Caption = 'Default Tracking Type';
        }
        field(5; "Expiration Date Required"; Boolean)
        {
            Caption = 'Expiration Date Required';
        }
        field(6; "Default Shelf Life"; DateFormula)
        {
            Caption = 'Default Shelf Life';
        }
        field(7; "Default Costing Method"; Enum "IMS Costing Method")
        {
            Caption = 'Default Costing Method';
        }
        field(8; "Default Picking Strategy"; Enum "IMS Picking Strategy")
        {
            Caption = 'Default Picking Strategy';
        }
        field(9; "Block Expired Stock"; Boolean)
        {
            Caption = 'Block Expired Stock';
        }
        field(10; "Min. Shelf Life on Sale"; DateFormula)
        {
            Caption = 'Min. Remaining Shelf Life on Sale';
        }
        field(11; "GTIN Required"; Boolean)
        {
            Caption = 'GTIN Required';
        }
        field(12; "Default Base Unit of Measure"; Code[10])
        {
            Caption = 'Default Base Unit of Measure';
            TableRelation = "IMS Unit of Measure";
        }
        field(13; "Quarantine on Receipt"; Boolean)
        {
            Caption = 'Quarantine New Lots on Receipt';
        }
        field(20; "No. of Items"; Integer)
        {
            Caption = 'No. of Items';
            FieldClass = FlowField;
            CalcFormula = count("IMS Item" where("Industry Profile Code" = field(Code)));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
        key(IndustryType; "Industry Type") { }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description, "Industry Type") { }
    }

    trigger OnDelete()
    begin
        CalcFields("No. of Items");
        TestField("No. of Items", 0);
    end;
}
