/// <summary>
/// Staging line for every inventory movement (NAV journal pattern). Lines are validated by
/// "IMS Item Jnl.-Check Line" and turned into immutable ledger entries by "IMS Item Jnl.-Post Line".
/// Quantities are always positive; the Entry Type determines the direction.
/// </summary>
table 50113 "IMS Item Journal Line"
{
    Caption = 'Item Journal Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "IMS Item Journal Batch";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Entry Type"; Enum "IMS Entry Type")
        {
            Caption = 'Entry Type';

            trigger OnValidate()
            begin
                if "Entry Type" <> "Entry Type"::Transfer then begin
                    "New Location Code" := '';
                    "New Bin Code" := '';
                end;
                SetDefaultUnitCost();
            end;
        }
        field(4; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(6; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(7; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = "IMS Item";

            trigger OnValidate()
            var
                Item: Record "IMS Item";
            begin
                if "Item No." <> xRec."Item No." then begin
                    "Variant Code" := '';
                    "Lot No." := '';
                    "Serial No." := '';
                    "Expiration Date" := 0D;
                end;
                if "Item No." = '' then begin
                    Description := '';
                    "Unit of Measure Code" := '';
                    exit;
                end;
                Item.Get("Item No.");
                Item.TestField(Blocked, false);
                Description := Item.Description;
                Validate("Unit of Measure Code", Item."Base Unit of Measure");
                SetDefaultUnitCost();
            end;
        }
        field(8; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(9; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "IMS Item Variant".Code where("Item No." = field("Item No."), Blocked = const(false));
        }
        field(10; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = "IMS Location" where(Blocked = const(false));

            trigger OnValidate()
            begin
                if "Location Code" <> xRec."Location Code" then
                    "Bin Code" := '';
            end;
        }
        field(11; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = "IMS Bin".Code where("Location Code" = field("Location Code"), Blocked = const(false));
        }
        field(12; "New Location Code"; Code[10])
        {
            Caption = 'New Location Code';
            TableRelation = "IMS Location" where(Blocked = const(false));

            trigger OnValidate()
            begin
                if "New Location Code" <> '' then
                    TestField("Entry Type", "Entry Type"::Transfer);
                if "New Location Code" <> xRec."New Location Code" then
                    "New Bin Code" := '';
            end;
        }
        field(13; "New Bin Code"; Code[20])
        {
            Caption = 'New Bin Code';
            TableRelation = "IMS Bin".Code where("Location Code" = field("New Location Code"), Blocked = const(false));
        }
        field(14; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "IMS Item Unit of Measure".Code where("Item No." = field("Item No."));

            trigger OnValidate()
            var
                ItemUnitOfMeasure: Record "IMS Item Unit of Measure";
            begin
                if "Unit of Measure Code" = '' then
                    "Qty. per Unit of Measure" := 1
                else begin
                    ItemUnitOfMeasure.Get("Item No.", "Unit of Measure Code");
                    "Qty. per Unit of Measure" := ItemUnitOfMeasure."Qty. per Unit of Measure";
                end;
                SetDefaultUnitCost();
                Validate(Quantity);
            end;
        }
        field(15; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
        }
        field(16; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                "Quantity (Base)" := Round(Quantity * "Qty. per Unit of Measure", 0.00001);
                UpdateAmount();
            end;
        }
        field(17; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(18; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            AutoFormatType = 2;
            DecimalPlaces = 2 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                UpdateAmount();
            end;
        }
        field(19; Amount; Decimal)
        {
            Caption = 'Amount';
            AutoFormatType = 1;
            Editable = false;
        }
        field(20; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';

            trigger OnValidate()
            var
                LotNoInfo: Record "IMS Lot No. Information";
            begin
                if "Lot No." = '' then
                    exit;
                if LotNoInfo.Get("Item No.", "Variant Code", "Lot No.") then
                    "Expiration Date" := LotNoInfo."Expiration Date";
            end;

            trigger OnLookup()
            var
                LotNoInfo: Record "IMS Lot No. Information";
            begin
                LotNoInfo.SetRange("Item No.", "Item No.");
                LotNoInfo.SetRange("Variant Code", "Variant Code");
                if Page.RunModal(0, LotNoInfo) = Action::LookupOK then
                    Validate("Lot No.", LotNoInfo."Lot No.");
            end;
        }
        field(21; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
        }
        field(22; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
        }
    }

    keys
    {
        key(PK; "Journal Batch Name", "Line No.")
        {
            Clustered = true;
        }
        key(Document; "Journal Batch Name", "Document No.", "Posting Date") { }
    }

    trigger OnInsert()
    begin
        TestField("Journal Batch Name");
    end;

    /// <summary>Defaults a new line from the previous line / batch (NAV SetUpNewLine pattern).</summary>
    procedure SetUpNewLine(LastItemJnlLine: Record "IMS Item Journal Line")
    var
        ItemJnlBatch: Record "IMS Item Journal Batch";
        ImsSetup: Record "IMS Setup";
        NoSeries: Codeunit "No. Series";
    begin
        ItemJnlBatch.Get("Journal Batch Name");
        if LastItemJnlLine."Line No." <> 0 then begin
            "Posting Date" := LastItemJnlLine."Posting Date";
            "Document No." := LastItemJnlLine."Document No.";
            "Entry Type" := LastItemJnlLine."Entry Type";
            "Location Code" := LastItemJnlLine."Location Code";
        end else begin
            "Posting Date" := WorkDate();
            "Entry Type" := ItemJnlBatch."Default Entry Type";
            if ItemJnlBatch."No. Series" <> '' then
                "Document No." := NoSeries.PeekNextNo(ItemJnlBatch."No. Series", "Posting Date");
            ImsSetup.GetRecordOnce();
            "Location Code" := ImsSetup."Default Location Code";
        end;
    end;

    /// <summary>True for entry types that add stock at "Location Code".</summary>
    procedure IsInbound(): Boolean
    begin
        exit("Entry Type" in ["Entry Type"::Purchase, "Entry Type"::"Positive Adjmt.", "Entry Type"::Output]);
    end;

    local procedure UpdateAmount()
    begin
        Amount := Round(Quantity * "Unit Cost", 0.01);
    end;

    local procedure SetDefaultUnitCost()
    var
        Item: Record "IMS Item";
    begin
        if "Item No." = '' then
            exit;
        Item.SetLoadFields("Costing Method", "Unit Cost", "Standard Cost");
        Item.Get("Item No.");
        if Item."Costing Method" = Item."Costing Method"::Standard then
            Validate("Unit Cost", Item."Standard Cost" * "Qty. per Unit of Measure")
        else
            Validate("Unit Cost", Item."Unit Cost" * "Qty. per Unit of Measure");
    end;
}
