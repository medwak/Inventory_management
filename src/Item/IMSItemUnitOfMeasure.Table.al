/// <summary>Conversion of an alternative unit (e.g. BOX = 12 PCS) to the item's base unit.</summary>
table 50106 "IMS Item Unit of Measure"
{
    Caption = 'Item Unit of Measure';
    DataClassification = CustomerContent;
    DrillDownPageId = "IMS Item Units of Measure";
    LookupPageId = "IMS Item Units of Measure";

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
            TableRelation = "IMS Unit of Measure";
            NotBlank = true;
        }
        field(3; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            InitValue = 1;

            trigger OnValidate()
            var
                Item: Record "IMS Item";
            begin
                if "Qty. per Unit of Measure" <= 0 then
                    FieldError("Qty. per Unit of Measure", MustBePositiveErr);
                if Item.Get("Item No.") then
                    if (Item."Base Unit of Measure" = Code) and ("Qty. per Unit of Measure" <> 1) then
                        FieldError("Qty. per Unit of Measure", BaseMustBeOneErr);
            end;
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
        fieldgroup(DropDown; "Code", "Qty. per Unit of Measure") { }
    }

    var
        MustBePositiveErr: Label 'must be greater than 0';
        BaseMustBeOneErr: Label 'must be 1 for the base unit of measure';
        CannotDeleteBaseUoMErr: Label 'You cannot delete %1 because it is the base unit of measure of item %2.', Comment = '%1 = UoM Code, %2 = Item No.';

    trigger OnDelete()
    var
        Item: Record "IMS Item";
    begin
        if Item.Get("Item No.") then
            if Item."Base Unit of Measure" = Code then
                Error(CannotDeleteBaseUoMErr, Code, "Item No.");
    end;
}
