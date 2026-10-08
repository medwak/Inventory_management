/// <summary>
/// Validates a journal line before posting. Contains no database writes, so a whole batch can be
/// checked up-front and nothing is posted when any line is wrong.
/// </summary>
codeunit 50102 "IMS Item Jnl.-Check Line"
{
    var
        IndustryMgt: Codeunit "IMS Industry Mgt.";
        QuantityMustBePositiveErr: Label 'Quantity must be greater than 0 on journal line %1 for item %2. Use the Entry Type to choose the direction of the movement.', Comment = '%1 = Line No., %2 = Item No.';
        SameLocationErr: Label 'A transfer must change the location or the bin (line %1).', Comment = '%1 = Line No.';
        BinMandatoryErr: Label 'Location %1 requires a bin code.', Comment = '%1 = Location Code';
        SerialQtyErr: Label 'A serial number can only be used for a quantity of 1 base unit (item %1, serial no. %2).', Comment = '%1 = Item No., %2 = Serial No.';
        SerialInStockErr: Label 'Serial no. %1 of item %2 is already in stock.', Comment = '%1 = Serial No., %2 = Item No.';
        LotNotFoundErr: Label 'Lot no. %1 does not exist for item %2.', Comment = '%1 = Lot No., %2 = Item No.';
        LotNotAvailableErr: Label 'Lot no. %1 of item %2 cannot be used for %3 (status: %4, expiration date: %5).', Comment = '%1 = Lot No., %2 = Item No., %3 = Entry Type, %4 = Status, %5 = Expiration Date';
        ExpirationRequiredErr: Label 'Item %1 requires an expiration date for lot no. %2. Enter one on the journal line or set a shelf life on the item.', Comment = '%1 = Item No., %2 = Lot No.';
        ExpirationMismatchErr: Label 'Lot no. %1 already exists with expiration date %2. You entered %3.', Comment = '%1 = Lot No., %2 = Existing Expiration Date, %3 = New Expiration Date';

    procedure RunCheck(var ItemJnlLine: Record "IMS Item Journal Line")
    var
        Item: Record "IMS Item";
        IndustryProfile: Record "IMS Industry Profile";
        IndustryHandler: Interface "IMS Industry Handler";
        IsHandled: Boolean;
    begin
        OnBeforeRunCheck(ItemJnlLine, IsHandled);
        if IsHandled then
            exit;

        ItemJnlLine.TestField("Item No.");
        ItemJnlLine.TestField("Posting Date");
        ItemJnlLine.TestField("Document No.");
        ItemJnlLine.TestField("Unit of Measure Code");
        if ItemJnlLine."Quantity (Base)" <= 0 then
            Error(QuantityMustBePositiveErr, ItemJnlLine."Line No.", ItemJnlLine."Item No.");

        Item.Get(ItemJnlLine."Item No.");
        Item.TestField(Blocked, false);
        IndustryMgt.GetProfileAndHandler(Item, IndustryProfile, IndustryHandler);
        IndustryHandler.ValidateItem(Item, IndustryProfile);

        CheckVariant(ItemJnlLine);
        CheckLocationAndBin(ItemJnlLine."Location Code", ItemJnlLine."Bin Code");
        if ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Transfer then begin
            ItemJnlLine.TestField("New Location Code");
            CheckLocationAndBin(ItemJnlLine."New Location Code", ItemJnlLine."New Bin Code");
            if (ItemJnlLine."Location Code" = ItemJnlLine."New Location Code") and (ItemJnlLine."Bin Code" = ItemJnlLine."New Bin Code") then
                Error(SameLocationErr, ItemJnlLine."Line No.");
        end else begin
            ItemJnlLine.TestField("New Location Code", '');
            ItemJnlLine.TestField("New Bin Code", '');
        end;

        CheckItemTracking(ItemJnlLine, Item, IndustryProfile, IndustryHandler);
        IndustryHandler.CheckJournalLine(ItemJnlLine, Item, IndustryProfile);

        OnAfterRunCheck(ItemJnlLine, Item, IndustryProfile);
    end;

    local procedure CheckVariant(ItemJnlLine: Record "IMS Item Journal Line")
    var
        ItemVariant: Record "IMS Item Variant";
    begin
        if ItemJnlLine."Variant Code" = '' then
            exit;
        ItemVariant.Get(ItemJnlLine."Item No.", ItemJnlLine."Variant Code");
        ItemVariant.TestField(Blocked, false);
    end;

    local procedure CheckLocationAndBin(LocationCode: Code[10]; BinCode: Code[20])
    var
        Location: Record "IMS Location";
        Bin: Record "IMS Bin";
    begin
        if LocationCode = '' then
            exit;
        Location.Get(LocationCode);
        Location.TestField(Blocked, false);
        if Location."Bin Mandatory" and (BinCode = '') then
            Error(BinMandatoryErr, LocationCode);
        if BinCode <> '' then begin
            Bin.Get(LocationCode, BinCode);
            Bin.TestField(Blocked, false);
        end;
    end;

    local procedure CheckItemTracking(ItemJnlLine: Record "IMS Item Journal Line"; Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile"; IndustryHandler: Interface "IMS Industry Handler")
    var
        LotNoInfo: Record "IMS Lot No. Information";
        IsInbound: Boolean;
    begin
        IsInbound := ItemJnlLine.IsInbound();

        if not Item.UsesLotTracking() then
            ItemJnlLine.TestField("Lot No.", '');
        if not Item.UsesSerialTracking() then
            ItemJnlLine.TestField("Serial No.", '');

        if IsInbound then begin
            // Inbound: tracking numbers are mandatory. Outbound: optional - when blank,
            // the posting engine picks lots/serials automatically by the picking strategy.
            if Item.UsesLotTracking() then
                ItemJnlLine.TestField("Lot No.");
            if Item.UsesSerialTracking() then
                ItemJnlLine.TestField("Serial No.");
            if ItemJnlLine."Lot No." <> '' then
                CheckInboundLotExpiration(ItemJnlLine, Item);
        end;

        if ItemJnlLine."Serial No." <> '' then begin
            if ItemJnlLine."Quantity (Base)" <> 1 then
                Error(SerialQtyErr, Item."No.", ItemJnlLine."Serial No.");
            if IsInbound and SerialNoInStock(Item."No.", ItemJnlLine."Serial No.") then
                Error(SerialInStockErr, ItemJnlLine."Serial No.", Item."No.");
        end;

        if (not IsInbound) and (ItemJnlLine."Lot No." <> '') then begin
            if not LotNoInfo.Get(ItemJnlLine."Item No.", ItemJnlLine."Variant Code", ItemJnlLine."Lot No.") then
                Error(LotNotFoundErr, ItemJnlLine."Lot No.", ItemJnlLine."Item No.");
            if not IndustryHandler.CanIssueFromLot(Item, IndustryProfile, LotNoInfo, ItemJnlLine."Posting Date", ItemJnlLine."Entry Type") then
                Error(LotNotAvailableErr, LotNoInfo."Lot No.", Item."No.", ItemJnlLine."Entry Type", LotNoInfo.Status, LotNoInfo."Expiration Date");
        end;
    end;

    local procedure CheckInboundLotExpiration(ItemJnlLine: Record "IMS Item Journal Line"; Item: Record "IMS Item")
    var
        LotNoInfo: Record "IMS Lot No. Information";
    begin
        if LotNoInfo.Get(ItemJnlLine."Item No.", ItemJnlLine."Variant Code", ItemJnlLine."Lot No.") then begin
            if (ItemJnlLine."Expiration Date" <> 0D) and (LotNoInfo."Expiration Date" <> 0D) and
               (ItemJnlLine."Expiration Date" <> LotNoInfo."Expiration Date")
            then
                Error(ExpirationMismatchErr, LotNoInfo."Lot No.", LotNoInfo."Expiration Date", ItemJnlLine."Expiration Date");
            if LotNoInfo."Expiration Date" <> 0D then
                exit;
        end;

        if not Item."Expiration Date Required" then
            exit;
        if (ItemJnlLine."Expiration Date" = 0D) and (Format(Item."Shelf Life") = '') then
            Error(ExpirationRequiredErr, Item."No.", ItemJnlLine."Lot No.");
    end;

    local procedure SerialNoInStock(ItemNo: Code[20]; SerialNo: Code[50]): Boolean
    var
        ItemLedgerEntry: Record "IMS Item Ledger Entry";
    begin
        ItemLedgerEntry.SetCurrentKey("Item No.", "Serial No.", Open);
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetRange("Serial No.", SerialNo);
        ItemLedgerEntry.SetRange(Open, true);
        ItemLedgerEntry.SetRange(Positive, true);
        exit(not ItemLedgerEntry.IsEmpty());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunCheck(var ItemJnlLine: Record "IMS Item Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRunCheck(var ItemJnlLine: Record "IMS Item Journal Line"; Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile")
    begin
    end;
}
