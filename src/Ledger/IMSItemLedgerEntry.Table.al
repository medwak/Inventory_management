/// <summary>
/// Immutable record of every stock movement (the single source of truth for inventory).
/// Positive entries are stock layers: "Remaining Quantity" shows what is left of them and
/// Open = true while anything is left. Outbound entries are applied to layers through
/// "IMS Item Application Entry". Inventory is never stored on the item - it is summed here
/// through SIFT-indexed FlowFields, which keeps posting append-only and highly concurrent.
/// </summary>
table 50114 "IMS Item Ledger Entry"
{
    Caption = 'Item Ledger Entry';
    DataClassification = CustomerContent;
    DrillDownPageId = "IMS Item Ledger Entries";
    LookupPageId = "IMS Item Ledger Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = "IMS Item";
        }
        field(3; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "IMS Item Variant".Code where("Item No." = field("Item No."));
        }
        field(4; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(5; "Entry Type"; Enum "IMS Entry Type")
        {
            Caption = 'Entry Type';
        }
        field(6; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(7; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(8; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(9; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = "IMS Location";
        }
        field(10; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = "IMS Bin".Code where("Location Code" = field("Location Code"));
        }
        field(11; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(12; "Remaining Quantity"; Decimal)
        {
            Caption = 'Remaining Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(13; Open; Boolean)
        {
            Caption = 'Open';
        }
        field(14; Positive; Boolean)
        {
            Caption = 'Positive';
        }
        field(15; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
        }
        field(16; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
        }
        field(17; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
        }
        field(18; "Cost Amount"; Decimal)
        {
            Caption = 'Cost Amount';
            AutoFormatType = 1;
        }
        field(19; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
        }
        field(20; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
        }
        field(21; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
        }
        field(22; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(23; "Register No."; Integer)
        {
            Caption = 'Register No.';
            TableRelation = "IMS Register";
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        // Inventory / value by item, location, variant and date (Item FlowFields, valuation).
        key(ItemLocationDate; "Item No.", "Location Code", "Variant Code", "Posting Date")
        {
            SumIndexFields = Quantity, "Cost Amount";
        }
        // Inventory by lot (Lot No. Information FlowField, lot traceability).
        key(ItemLot; "Item No.", "Variant Code", "Lot No.", "Location Code")
        {
            SumIndexFields = Quantity;
        }
        // Open stock layers, FIFO/LIFO order (Entry No. is appended implicitly).
        key(OpenLayers; "Item No.", Open, Positive, "Location Code", "Variant Code") { }
        // Open stock layers, FEFO order.
        key(OpenLayersFEFO; "Item No.", Open, Positive, "Location Code", "Variant Code", "Expiration Date") { }
        key(Tracking; "Lot No.", "Serial No.") { }
        key(SerialNo; "Item No.", "Serial No.", Open) { }
        key(Document; "Document No.", "Posting Date") { }
        key(LocationBin; "Location Code", "Bin Code")
        {
            SumIndexFields = Quantity;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Entry No.", "Item No.", "Posting Date", "Entry Type", Quantity) { }
    }

    procedure UnitCost(): Decimal
    begin
        if Quantity = 0 then
            exit(0);
        exit(Round("Cost Amount" / Quantity, 0.00001));
    end;
}
