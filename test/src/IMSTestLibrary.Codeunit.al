codeunit 50151 "IMS Test Library"
{
    procedure Initialize()
    var
        ImsInstall: Codeunit "IMS Install";
    begin
        ImsInstall.InitializeCompany();
    end;

    procedure CreateProfile(IndustryType: Enum "IMS Industry Type"; var IndustryProfile: Record "IMS Industry Profile")
    begin
        IndustryProfile.Init();
        IndustryProfile.Code := CopyStr(UniqueCode(), 1, MaxStrLen(IndustryProfile.Code));
        IndustryProfile."Industry Type" := IndustryType;
        IndustryProfile."Default Base Unit of Measure" := 'PCS';
        IndustryProfile.Insert();
    end;

    procedure CreateItem(IndustryProfileCode: Code[20]; var Item: Record "IMS Item")
    begin
        Item.Init();
        Item."No." := CopyStr(UniqueCode(), 1, MaxStrLen(Item."No."));
        Item.Description := Item."No.";
        Item.GTIN := ValidGTIN();
        Item.Insert(true);
        Item.Validate("Industry Profile Code", IndustryProfileCode);
        if Item."Base Unit of Measure" = '' then
            Item.Validate("Base Unit of Measure", 'PCS');
        Item.Modify(true);
    end;

    procedure CreateLocation(var Location: Record "IMS Location")
    begin
        Location.Init();
        Location.Code := CopyStr(UniqueCode(), 1, MaxStrLen(Location.Code));
        Location.Insert();
    end;

    procedure PostLine(EntryType: Enum "IMS Entry Type"; ItemNo: Code[20]; LocationCode: Code[10]; Qty: Decimal; UnitCost: Decimal; LotNo: Code[50]; ExpirationDate: Date)
    var
        ItemJnlLine: Record "IMS Item Journal Line";
    begin
        CreateJournalLine(ItemJnlLine, EntryType, ItemNo, LocationCode, Qty, UnitCost, LotNo, ExpirationDate);
        PostJournalLine(ItemJnlLine);
    end;

    procedure CreateJournalLine(var ItemJnlLine: Record "IMS Item Journal Line"; EntryType: Enum "IMS Entry Type"; ItemNo: Code[20]; LocationCode: Code[10]; Qty: Decimal; UnitCost: Decimal; LotNo: Code[50]; ExpirationDate: Date)
    begin
        Clear(ItemJnlLine);
        ItemJnlLine."Journal Batch Name" := 'DEFAULT';
        ItemJnlLine."Line No." := 10000;
        ItemJnlLine."Posting Date" := WorkDate();
        ItemJnlLine."Document No." := 'TEST';
        ItemJnlLine."External Document No." := 'EXT-REF';
        ItemJnlLine.Validate("Entry Type", EntryType);
        ItemJnlLine.Validate("Item No.", ItemNo);
        ItemJnlLine.Validate("Location Code", LocationCode);
        ItemJnlLine.Validate(Quantity, Qty);
        ItemJnlLine.Validate("Unit Cost", UnitCost);
        if LotNo <> '' then
            ItemJnlLine.Validate("Lot No.", LotNo);
        if ExpirationDate <> 0D then
            ItemJnlLine."Expiration Date" := ExpirationDate;
    end;

    procedure PostJournalLine(var ItemJnlLine: Record "IMS Item Journal Line")
    var
        ItemJnlPostLine: Codeunit "IMS Item Jnl.-Post Line";
    begin
        ItemJnlPostLine.RunWithCheck(ItemJnlLine);
    end;

    procedure GetInventory(ItemNo: Code[20]; LocationCode: Code[10]): Decimal
    var
        Item: Record "IMS Item";
    begin
        Item.Get(ItemNo);
        Item.SetRange("Location Filter", LocationCode);
        Item.CalcFields(Inventory);
        exit(Item.Inventory);
    end;

    procedure ReleaseLot(ItemNo: Code[20]; LotNo: Code[50])
    var
        LotNoInfo: Record "IMS Lot No. Information";
    begin
        LotNoInfo.Get(ItemNo, '', LotNo);
        LotNoInfo.SetStatus(LotNoInfo.Status::Available);
    end;

    procedure FindLastOutbound(ItemNo: Code[20]; var ItemLedgerEntry: Record "IMS Item Ledger Entry")
    begin
        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetRange(Positive, false);
        ItemLedgerEntry.FindLast();
    end;

    procedure ValidGTIN(): Code[14]
    begin
        exit('4006381333931');
    end;

    procedure UniqueCode(): Code[10]
    begin
        exit(CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, 10));
    end;
}
