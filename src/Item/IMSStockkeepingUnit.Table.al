/// <summary>
/// Optional per location / variant replenishment parameters. When an item has SKUs the
/// replenishment engine plans per SKU; otherwise it uses the item-level parameters.
/// </summary>
table 50117 "IMS Stockkeeping Unit"
{
    Caption = 'Stockkeeping Unit';
    DataClassification = CustomerContent;
    DrillDownPageId = "IMS Stockkeeping Units";
    LookupPageId = "IMS Stockkeeping Units";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = "IMS Item";
            NotBlank = true;

            trigger OnValidate()
            var
                Item: Record "IMS Item";
            begin
                if "Item No." = '' then
                    exit;
                Item.Get("Item No.");
                "Replenishment Policy" := Item."Replenishment Policy";
                "Reorder Point" := Item."Reorder Point";
                "Reorder Quantity" := Item."Reorder Quantity";
                "Maximum Inventory" := Item."Maximum Inventory";
                "Safety Stock Quantity" := Item."Safety Stock Quantity";
                "Lead Time Calculation" := Item."Lead Time Calculation";
            end;
        }
        field(2; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "IMS Item Variant".Code where("Item No." = field("Item No."));
        }
        field(3; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = "IMS Location";
            NotBlank = true;
        }
        field(10; "Replenishment Policy"; Enum "IMS Replenishment Policy")
        {
            Caption = 'Replenishment Policy';
        }
        field(11; "Reorder Point"; Decimal)
        {
            Caption = 'Reorder Point';
            DecimalPlaces = 0 : 5;
        }
        field(12; "Reorder Quantity"; Decimal)
        {
            Caption = 'Reorder Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(13; "Maximum Inventory"; Decimal)
        {
            Caption = 'Maximum Inventory';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(14; "Safety Stock Quantity"; Decimal)
        {
            Caption = 'Safety Stock Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(15; "Lead Time Calculation"; DateFormula)
        {
            Caption = 'Lead Time Calculation';
        }
        field(20; Inventory; Decimal)
        {
            Caption = 'Inventory';
            FieldClass = FlowField;
            CalcFormula = sum("IMS Item Ledger Entry".Quantity where("Item No." = field("Item No."),
                                                                     "Variant Code" = field("Variant Code"),
                                                                     "Location Code" = field("Location Code")));
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Item No.", "Variant Code", "Location Code")
        {
            Clustered = true;
        }
        key(Location; "Location Code", "Item No.") { }
    }
}
