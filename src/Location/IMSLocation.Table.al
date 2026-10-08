table 50107 "IMS Location"
{
    Caption = 'Location';
    DataClassification = CustomerContent;
    DrillDownPageId = "IMS Locations";
    LookupPageId = "IMS Locations";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
        }
        field(3; Address; Text[100])
        {
            Caption = 'Address';
        }
        field(4; City; Text[30])
        {
            Caption = 'City';
        }
        field(5; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
        }
        field(6; "Bin Mandatory"; Boolean)
        {
            Caption = 'Bin Mandatory';
        }
        field(7; "Temperature Controlled"; Boolean)
        {
            Caption = 'Temperature Controlled';
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
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Name, City) { }
    }

    trigger OnDelete()
    var
        ItemLedgerEntry: Record "IMS Item Ledger Entry";
        Bin: Record "IMS Bin";
    begin
        ItemLedgerEntry.SetRange("Location Code", Code);
        if not ItemLedgerEntry.IsEmpty() then
            Error(EntriesExistErr, Code);
        Bin.SetRange("Location Code", Code);
        Bin.DeleteAll();
    end;

    var
        EntriesExistErr: Label 'You cannot delete location %1 because it has ledger entries.', Comment = '%1 = Location Code';
}
