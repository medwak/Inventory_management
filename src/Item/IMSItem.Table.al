table 50103 "IMS Item"
{
    Caption = 'Item';
    DataClassification = CustomerContent;
    DrillDownPageId = "IMS Item List";
    LookupPageId = "IMS Item List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            var
                NoSeries: Codeunit "No. Series";
            begin
                if "No." <> xRec."No." then begin
                    ImsSetup.GetRecordOnce();
                    NoSeries.TestManual(ImsSetup."Item Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';

            trigger OnValidate()
            begin
                if ("Search Description" = UpperCase(xRec.Description)) or ("Search Description" = '') then
                    "Search Description" := CopyStr(Description, 1, MaxStrLen("Search Description"));
            end;
        }
        field(3; "Search Description"; Code[100])
        {
            Caption = 'Search Description';
        }
        field(4; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
        }
        field(5; "Industry Profile Code"; Code[20])
        {
            Caption = 'Industry Profile Code';
            TableRelation = "IMS Industry Profile";

            trigger OnValidate()
            var
                IndustryProfile: Record "IMS Industry Profile";
                IndustryHandler: Interface "IMS Industry Handler";
            begin
                if "Industry Profile Code" = xRec."Industry Profile Code" then
                    exit;
                TestNoEntriesExist(FieldCaption("Industry Profile Code"));
                IndustryMgt.GetProfileAndHandler(Rec, IndustryProfile, IndustryHandler);
                IndustryHandler.InitItemDefaults(Rec, IndustryProfile);
            end;
        }
        field(6; "Industry Type"; Enum "IMS Industry Type")
        {
            Caption = 'Industry Type';
            FieldClass = FlowField;
            CalcFormula = lookup("IMS Industry Profile"."Industry Type" where(Code = field("Industry Profile Code")));
            Editable = false;
        }
        field(7; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            TableRelation = "IMS Item Category";
        }
        field(8; "Base Unit of Measure"; Code[10])
        {
            Caption = 'Base Unit of Measure';
            TableRelation = "IMS Unit of Measure";

            trigger OnValidate()
            var
                ItemUnitOfMeasure: Record "IMS Item Unit of Measure";
            begin
                if "Base Unit of Measure" = xRec."Base Unit of Measure" then
                    exit;
                TestNoEntriesExist(FieldCaption("Base Unit of Measure"));
                if "Base Unit of Measure" = '' then
                    exit;
                if not ItemUnitOfMeasure.Get("No.", "Base Unit of Measure") then begin
                    ItemUnitOfMeasure.Init();
                    ItemUnitOfMeasure."Item No." := "No.";
                    ItemUnitOfMeasure.Code := "Base Unit of Measure";
                    ItemUnitOfMeasure."Qty. per Unit of Measure" := 1;
                    ItemUnitOfMeasure.Insert();
                end else
                    if ItemUnitOfMeasure."Qty. per Unit of Measure" <> 1 then
                        ItemUnitOfMeasure.FieldError("Qty. per Unit of Measure");
            end;
        }
        field(9; GTIN; Code[14])
        {
            Caption = 'GTIN / Barcode';
            Numeric = true;

            trigger OnValidate()
            var
                GTINMgt: Codeunit "IMS GTIN Mgt.";
            begin
                if GTIN <> '' then
                    GTINMgt.CheckGTIN(GTIN);
            end;
        }
        field(10; "Item Tracking Type"; Enum "IMS Item Tracking Type")
        {
            Caption = 'Item Tracking Type';

            trigger OnValidate()
            begin
                if "Item Tracking Type" <> xRec."Item Tracking Type" then
                    TestNoEntriesExist(FieldCaption("Item Tracking Type"));
            end;
        }
        field(11; "Expiration Date Required"; Boolean)
        {
            Caption = 'Expiration Date Required';

            trigger OnValidate()
            begin
                if "Expiration Date Required" and not UsesLotTracking() then
                    Error(ExpiryNeedsLotErr);
            end;
        }
        field(12; "Shelf Life"; DateFormula)
        {
            Caption = 'Shelf Life';
        }
        field(13; "Costing Method"; Enum "IMS Costing Method")
        {
            Caption = 'Costing Method';

            trigger OnValidate()
            begin
                if "Costing Method" <> xRec."Costing Method" then
                    TestNoEntriesExist(FieldCaption("Costing Method"));
            end;
        }
        field(14; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            AutoFormatType = 2;
            DecimalPlaces = 2 : 5;
            MinValue = 0;
        }
        field(15; "Standard Cost"; Decimal)
        {
            Caption = 'Standard Cost';
            AutoFormatType = 2;
            DecimalPlaces = 2 : 5;
            MinValue = 0;
        }
        field(16; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            AutoFormatType = 2;
            DecimalPlaces = 2 : 5;
            MinValue = 0;
        }
        field(17; "Picking Strategy"; Enum "IMS Picking Strategy")
        {
            Caption = 'Picking Strategy';
        }
        field(20; "Replenishment Policy"; Enum "IMS Replenishment Policy")
        {
            Caption = 'Replenishment Policy';
        }
        field(21; "Reorder Point"; Decimal)
        {
            Caption = 'Reorder Point';
            DecimalPlaces = 0 : 5;
        }
        field(22; "Reorder Quantity"; Decimal)
        {
            Caption = 'Reorder Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(23; "Maximum Inventory"; Decimal)
        {
            Caption = 'Maximum Inventory';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(24; "Safety Stock Quantity"; Decimal)
        {
            Caption = 'Safety Stock Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(25; "Lead Time Calculation"; DateFormula)
        {
            Caption = 'Lead Time Calculation';
        }
        field(30; Blocked; Boolean)
        {
            Caption = 'Blocked';
        }
        field(31; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
            Editable = false;
        }
        field(32; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
        field(40; Inventory; Decimal)
        {
            Caption = 'Inventory';
            FieldClass = FlowField;
            CalcFormula = sum("IMS Item Ledger Entry".Quantity where("Item No." = field("No."),
                                                                     "Location Code" = field("Location Filter"),
                                                                     "Variant Code" = field("Variant Filter"),
                                                                     "Lot No." = field("Lot No. Filter"),
                                                                     "Posting Date" = field("Date Filter")));
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(41; "Inventory Value"; Decimal)
        {
            Caption = 'Inventory Value';
            FieldClass = FlowField;
            CalcFormula = sum("IMS Item Ledger Entry"."Cost Amount" where("Item No." = field("No."),
                                                                          "Location Code" = field("Location Filter"),
                                                                          "Variant Code" = field("Variant Filter"),
                                                                          "Lot No." = field("Lot No. Filter"),
                                                                          "Posting Date" = field("Date Filter")));
            AutoFormatType = 1;
            Editable = false;
        }
        field(42; "No. of Variants"; Integer)
        {
            Caption = 'No. of Variants';
            FieldClass = FlowField;
            CalcFormula = count("IMS Item Variant" where("Item No." = field("No.")));
            Editable = false;
        }
        field(50; "Location Filter"; Code[10])
        {
            Caption = 'Location Filter';
            FieldClass = FlowFilter;
            TableRelation = "IMS Location";
        }
        field(51; "Variant Filter"; Code[10])
        {
            Caption = 'Variant Filter';
            FieldClass = FlowFilter;
            TableRelation = "IMS Item Variant".Code where("Item No." = field("No."));
        }
        field(52; "Lot No. Filter"; Code[50])
        {
            Caption = 'Lot No. Filter';
            FieldClass = FlowFilter;
        }
        field(53; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(SearchDescription; "Search Description") { }
        key(IndustryProfile; "Industry Profile Code", "Item Category Code") { }
        key(GTIN; GTIN) { }
        key(Replenishment; "Replenishment Policy") { }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", Description, "Base Unit of Measure", "Industry Profile Code") { }
        fieldgroup(Brick; "No.", Description, Inventory, "Unit Price") { }
    }

    var
        ImsSetup: Record "IMS Setup";
        IndustryMgt: Codeunit "IMS Industry Mgt.";
        EntriesExistErr: Label 'You cannot change %1 because item %2 has ledger entries.', Comment = '%1 = Field Caption, %2 = Item No.';
        ExpiryNeedsLotErr: Label 'Expiration dates are recorded per lot. Set Item Tracking Type to Lot or Lot and Serial first.';

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
    begin
        ImsSetup.GetRecordOnce();
        if "No." = '' then begin
            ImsSetup.TestField("Item Nos.");
            "No. Series" := ImsSetup."Item Nos.";
            "No." := NoSeries.GetNextNo("No. Series", WorkDate());
        end;
        if ("Industry Profile Code" = '') and (ImsSetup."Default Industry Profile" <> '') then
            Validate("Industry Profile Code", ImsSetup."Default Industry Profile");
        "Last Date Modified" := Today();
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today();
    end;

    trigger OnDelete()
    var
        ItemVariant: Record "IMS Item Variant";
        ItemUnitOfMeasure: Record "IMS Item Unit of Measure";
        ItemAttributeValue: Record "IMS Item Attribute Value";
        StockkeepingUnit: Record "IMS Stockkeeping Unit";
    begin
        TestNoEntriesExist(TableCaption());
        ItemVariant.SetRange("Item No.", "No.");
        ItemVariant.DeleteAll();
        ItemUnitOfMeasure.SetRange("Item No.", "No.");
        ItemUnitOfMeasure.DeleteAll();
        ItemAttributeValue.SetRange("Item No.", "No.");
        ItemAttributeValue.DeleteAll();
        StockkeepingUnit.SetRange("Item No.", "No.");
        StockkeepingUnit.DeleteAll();
    end;

    procedure AssistEdit(OldItem: Record "IMS Item"): Boolean
    var
        NoSeries: Codeunit "No. Series";
    begin
        ImsSetup.GetRecordOnce();
        ImsSetup.TestField("Item Nos.");
        if NoSeries.LookupRelatedNoSeries(ImsSetup."Item Nos.", OldItem."No. Series", "No. Series") then begin
            "No." := NoSeries.GetNextNo("No. Series", WorkDate());
            exit(true);
        end;
    end;

    procedure UsesLotTracking(): Boolean
    begin
        exit("Item Tracking Type" in ["Item Tracking Type"::Lot, "Item Tracking Type"::"Lot and Serial"]);
    end;

    procedure UsesSerialTracking(): Boolean
    begin
        exit("Item Tracking Type" in ["Item Tracking Type"::Serial, "Item Tracking Type"::"Lot and Serial"]);
    end;

    procedure HasLedgerEntries(): Boolean
    var
        ItemLedgerEntry: Record "IMS Item Ledger Entry";
    begin
        if "No." = '' then
            exit(false);
        ItemLedgerEntry.SetRange("Item No.", "No.");
        exit(not ItemLedgerEntry.IsEmpty());
    end;

    local procedure TestNoEntriesExist(CurrentFieldCaption: Text)
    begin
        if HasLedgerEntries() then
            Error(EntriesExistErr, CurrentFieldCaption, "No.");
    end;
}
