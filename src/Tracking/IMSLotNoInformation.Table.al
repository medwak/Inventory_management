/// <summary>
/// One record per lot: expiry, manufacturing date, QA status and supplier references.
/// Created automatically the first time a lot is received.
/// </summary>
table 50111 "IMS Lot No. Information"
{
    Caption = 'Lot No. Information';
    DataClassification = CustomerContent;
    DrillDownPageId = "IMS Lot No. Information List";
    LookupPageId = "IMS Lot No. Information List";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = "IMS Item";
            NotBlank = true;
        }
        field(2; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "IMS Item Variant".Code where("Item No." = field("Item No."));
        }
        field(3; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            NotBlank = true;
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(5; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
        }
        field(6; "Manufacturing Date"; Date)
        {
            Caption = 'Manufacturing Date';
        }
        field(7; Status; Enum "IMS Lot Status")
        {
            Caption = 'Status';
        }
        field(8; "Vendor Lot No."; Code[50])
        {
            Caption = 'Vendor Lot No.';
        }
        field(9; "Certificate No."; Text[50])
        {
            Caption = 'Certificate of Analysis No.';
        }
        field(10; "Status Changed By"; Code[50])
        {
            Caption = 'Status Changed By';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(11; "Status Changed At"; DateTime)
        {
            Caption = 'Status Changed At';
            Editable = false;
        }
        field(20; Inventory; Decimal)
        {
            Caption = 'Inventory';
            FieldClass = FlowField;
            CalcFormula = sum("IMS Item Ledger Entry".Quantity where("Item No." = field("Item No."),
                                                                     "Variant Code" = field("Variant Code"),
                                                                     "Lot No." = field("Lot No."),
                                                                     "Location Code" = field("Location Filter")));
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(21; "Location Filter"; Code[10])
        {
            Caption = 'Location Filter';
            FieldClass = FlowFilter;
            TableRelation = "IMS Location";
        }
    }

    keys
    {
        key(PK; "Item No.", "Variant Code", "Lot No.")
        {
            Clustered = true;
        }
        key(Expiry; "Expiration Date", Status) { }
        key(Lot; "Lot No.") { }
    }

    trigger OnModify()
    begin
        if Status <> xRec.Status then begin
            "Status Changed By" := CopyStr(UserId(), 1, MaxStrLen("Status Changed By"));
            "Status Changed At" := CurrentDateTime();
        end;
    end;

    procedure SetStatus(NewStatus: Enum "IMS Lot Status")
    begin
        if Status = NewStatus then
            exit;
        Status := NewStatus;
        "Status Changed By" := CopyStr(UserId(), 1, MaxStrLen("Status Changed By"));
        "Status Changed At" := CurrentDateTime();
        Modify();
    end;
}
