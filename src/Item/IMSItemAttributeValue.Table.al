table 50110 "IMS Item Attribute Value"
{
    Caption = 'Item Attribute Value';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = "IMS Item";
            NotBlank = true;
        }
        field(2; "Attribute Code"; Code[20])
        {
            Caption = 'Attribute Code';
            TableRelation = "IMS Attribute" where(Blocked = const(false));
            NotBlank = true;

            trigger OnValidate()
            begin
                if Value <> '' then
                    Validate(Value);
            end;
        }
        field(3; Value; Text[250])
        {
            Caption = 'Value';

            trigger OnValidate()
            begin
                CheckValue();
            end;
        }
        field(4; "Attribute Name"; Text[100])
        {
            Caption = 'Attribute Name';
            FieldClass = FlowField;
            CalcFormula = lookup("IMS Attribute".Name where(Code = field("Attribute Code")));
            Editable = false;
        }
        field(5; "Attribute Type"; Enum "IMS Attribute Type")
        {
            Caption = 'Attribute Type';
            FieldClass = FlowField;
            CalcFormula = lookup("IMS Attribute".Type where(Code = field("Attribute Code")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Item No.", "Attribute Code")
        {
            Clustered = true;
        }
        key(AttributeValue; "Attribute Code", Value) { }
    }

    var
        InvalidValueErr: Label '%1 is not a valid %2 value for attribute %3.', Comment = '%1 = Value, %2 = Type, %3 = Attribute Code';
        InvalidOptionErr: Label '%1 is not an allowed value for attribute %2. Allowed values: %3.', Comment = '%1 = Value, %2 = Attribute Code, %3 = Option list';

    local procedure CheckValue()
    var
        Attribute: Record "IMS Attribute";
        IntegerValue: Integer;
        DecimalValue: Decimal;
        DateValue: Date;
        BooleanValue: Boolean;
        IsValid: Boolean;
    begin
        if Value = '' then
            exit;
        Attribute.Get("Attribute Code");
        case Attribute.Type of
            Attribute.Type::"Text":
                IsValid := true;
            Attribute.Type::"Integer":
                IsValid := Evaluate(IntegerValue, Value);
            Attribute.Type::"Decimal":
                IsValid := Evaluate(DecimalValue, Value);
            Attribute.Type::"Date":
                IsValid := Evaluate(DateValue, Value);
            Attribute.Type::"Boolean":
                IsValid := Evaluate(BooleanValue, Value);
            Attribute.Type::"Option":
                begin
                    if not IsAllowedOption(Attribute."Option Values", Value) then
                        Error(InvalidOptionErr, Value, Attribute.Code, Attribute."Option Values");
                    IsValid := true;
                end;
        end;
        if not IsValid then
            Error(InvalidValueErr, Value, Attribute.Type, Attribute.Code);
    end;

    local procedure IsAllowedOption(OptionValues: Text; CandidateValue: Text): Boolean
    var
        AllowedValue: Text;
    begin
        foreach AllowedValue in OptionValues.Split(',') do
            if AllowedValue.Trim().ToLower() = CandidateValue.Trim().ToLower() then
                exit(true);
        exit(false);
    end;
}
