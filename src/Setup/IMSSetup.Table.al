table 50100 "IMS Setup"
{
    Caption = 'Inventory Management Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "IMS Setup";
    LookupPageId = "IMS Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Item Nos."; Code[20])
        {
            Caption = 'Item Nos.';
            TableRelation = "No. Series";
        }
        field(3; "Default Industry Profile"; Code[20])
        {
            Caption = 'Default Industry Profile';
            TableRelation = "IMS Industry Profile";
        }
        field(4; "Default Location Code"; Code[10])
        {
            Caption = 'Default Location Code';
            TableRelation = "IMS Location";
        }
        field(5; "Expiry Warning Period"; DateFormula)
        {
            Caption = 'Expiry Warning Period';
        }
        field(6; "Block Expired Lots (Job)"; Boolean)
        {
            Caption = 'Block Expired Lots (Job Queue)';
        }
        field(7; "Enable Posting Telemetry"; Boolean)
        {
            Caption = 'Enable Posting Telemetry';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    var
        RecordHasBeenRead: Boolean;

    /// <summary>Reads the singleton once per session instance and creates it when missing.</summary>
    procedure GetRecordOnce()
    begin
        if RecordHasBeenRead then
            exit;
        if not Get() then begin
            Init();
            Insert();
        end;
        RecordHasBeenRead := true;
    end;

    procedure InsertIfNotExists()
    begin
        Reset();
        if not Get() then begin
            Init();
            Insert(true);
        end;
    end;
}
