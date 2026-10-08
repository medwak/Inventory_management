/// <summary>
/// Posts one journal line into the immutable item ledger (NAV "Item Jnl.-Post Line" pattern).
///
/// Inbound (Purchase, Positive Adjmt., Output) creates an open stock layer.
/// Outbound (Sale, Negative Adjmt., Consumption) consumes open layers in the order given by the
/// industry's picking strategy (FIFO / FEFO / LIFO), skipping lots the industry does not allow
/// to be issued (quarantine, expired, short shelf life). When the line has no lot/serial the
/// outbound is split into one ledger entry per lot/serial actually consumed.
/// Transfer = outbound at "Location Code" + inbound at "New Location Code" with the same
/// lots, serials, expiry and cost.
///
/// Keep one instance alive for a whole batch: it caches the next entry no. and the register.
/// </summary>
codeunit 50103 "IMS Item Jnl.-Post Line"
{
    Permissions = tabledata "IMS Item Ledger Entry" = rim,
                  tabledata "IMS Item Application Entry" = ri,
                  tabledata "IMS Register" = rim,
                  tabledata "IMS Lot No. Information" = rim,
                  tabledata "IMS Item" = rm;
    TableNo = "IMS Item Journal Line";

    trigger OnRun()
    begin
        RunWithCheck(Rec);
    end;

    var
        Item: Record "IMS Item";
        IndustryProfile: Record "IMS Industry Profile";
        ImsRegister: Record "IMS Register";
        ItemJnlCheckLine: Codeunit "IMS Item Jnl.-Check Line";
        IndustryMgt: Codeunit "IMS Industry Mgt.";
        IndustryHandler: Interface "IMS Industry Handler";
        NextEntryNo: Integer;
        InsufficientStockErr: Label 'There is not enough available stock of item %1 at location %2 (variant: %3, bin: %4, lot: %5, serial: %6). Missing quantity (base): %7. Lots that are blocked, in quarantine or expired are not available.', Comment = '%1 = Item No., %2 = Location, %3 = Variant, %4 = Bin, %5 = Lot No., %6 = Serial No., %7 = Missing quantity';

    procedure RunWithCheck(var ItemJnlLine: Record "IMS Item Journal Line")
    begin
        ItemJnlCheckLine.RunCheck(ItemJnlLine);
        PostLine(ItemJnlLine);
    end;

    /// <summary>Posts a line that has already been checked (used by batch posting).</summary>
    procedure RunWithoutCheck(var ItemJnlLine: Record "IMS Item Journal Line")
    begin
        PostLine(ItemJnlLine);
    end;

    procedure GetRegister(var NewImsRegister: Record "IMS Register")
    begin
        NewImsRegister := ImsRegister;
    end;

    local procedure PostLine(var ItemJnlLine: Record "IMS Item Journal Line")
    var
        TempOutboundEntry: Record "IMS Item Ledger Entry" temporary;
        IsHandled: Boolean;
    begin
        OnBeforePostLine(ItemJnlLine, IsHandled);
        if IsHandled then
            exit;

        Item.Get(ItemJnlLine."Item No.");
        IndustryMgt.GetProfileAndHandler(Item, IndustryProfile, IndustryHandler);
        InitNextEntryNo();

        if ItemJnlLine.IsInbound() then
            PostInbound(
                ItemJnlLine, ItemJnlLine."Location Code", ItemJnlLine."Bin Code",
                ItemJnlLine."Lot No.", ItemJnlLine."Serial No.", ItemJnlLine."Quantity (Base)", CalcInboundCost(ItemJnlLine))
        else begin
            PostOutbound(ItemJnlLine, TempOutboundEntry);
            if ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Transfer then
                PostTransferReceipt(ItemJnlLine, TempOutboundEntry);
        end;

        UpdateItemUnitCost();

        OnAfterPostLine(ItemJnlLine);
    end;

    local procedure PostInbound(ItemJnlLine: Record "IMS Item Journal Line"; LocationCode: Code[10]; BinCode: Code[20]; LotNo: Code[50]; SerialNo: Code[50]; QtyBase: Decimal; CostAmount: Decimal)
    var
        ItemLedgerEntry: Record "IMS Item Ledger Entry";
        LotNoInfo: Record "IMS Lot No. Information";
    begin
        InitLedgerEntry(ItemLedgerEntry, ItemJnlLine);
        ItemLedgerEntry."Location Code" := LocationCode;
        ItemLedgerEntry."Bin Code" := BinCode;
        ItemLedgerEntry."Lot No." := LotNo;
        ItemLedgerEntry."Serial No." := SerialNo;
        ItemLedgerEntry.Quantity := QtyBase;
        ItemLedgerEntry."Remaining Quantity" := QtyBase;
        ItemLedgerEntry.Open := true;
        ItemLedgerEntry.Positive := true;
        ItemLedgerEntry."Cost Amount" := CostAmount;
        if LotNo <> '' then begin
            GetOrCreateLotNoInfo(ItemJnlLine, LotNo, LotNoInfo);
            ItemLedgerEntry."Expiration Date" := LotNoInfo."Expiration Date";
        end;
        InsertLedgerEntry(ItemLedgerEntry);
    end;

    local procedure PostOutbound(ItemJnlLine: Record "IMS Item Journal Line"; var TempOutboundEntry: Record "IMS Item Ledger Entry" temporary)
    var
        TempLayerPiece: Record "IMS Item Ledger Entry" temporary;
        OutboundEntry: Record "IMS Item Ledger Entry";
        GroupStarted: Boolean;
    begin
        AllocateFromOpenLayers(ItemJnlLine, TempLayerPiece);

        // One outbound ledger entry per lot/serial combination consumed.
        TempLayerPiece.SetCurrentKey("Lot No.", "Serial No.");
        TempLayerPiece.FindSet();
        repeat
            if (not GroupStarted) or
               (TempLayerPiece."Lot No." <> OutboundEntry."Lot No.") or
               (TempLayerPiece."Serial No." <> OutboundEntry."Serial No.")
            then begin
                if GroupStarted then
                    FinishOutboundEntry(OutboundEntry, TempOutboundEntry);
                InitLedgerEntry(OutboundEntry, ItemJnlLine);
                OutboundEntry."Location Code" := ItemJnlLine."Location Code";
                OutboundEntry."Bin Code" := ItemJnlLine."Bin Code";
                OutboundEntry."Lot No." := TempLayerPiece."Lot No.";
                OutboundEntry."Serial No." := TempLayerPiece."Serial No.";
                OutboundEntry."Expiration Date" := TempLayerPiece."Expiration Date";
                OutboundEntry.Positive := false;
                OutboundEntry.Open := false;
                GroupStarted := true;
            end;
            OutboundEntry.Quantity -= TempLayerPiece.Quantity;
            OutboundEntry."Cost Amount" -= TempLayerPiece."Cost Amount";
            // NextEntryNo is the number the outbound entry receives in FinishOutboundEntry.
            InsertApplicationEntry(TempLayerPiece."Entry No.", NextEntryNo, TempLayerPiece.Quantity, TempLayerPiece."Cost Amount", ItemJnlLine."Posting Date");
        until TempLayerPiece.Next() = 0;
        FinishOutboundEntry(OutboundEntry, TempOutboundEntry);
    end;

    local procedure FinishOutboundEntry(var OutboundEntry: Record "IMS Item Ledger Entry"; var TempOutboundEntry: Record "IMS Item Ledger Entry" temporary)
    begin
        case Item."Costing Method" of
            Item."Costing Method"::Average:
                OutboundEntry."Cost Amount" := -Round(-OutboundEntry.Quantity * Item."Unit Cost", 0.01);
            Item."Costing Method"::Standard:
                OutboundEntry."Cost Amount" := -Round(-OutboundEntry.Quantity * Item."Standard Cost", 0.01);
        end;
        OnBeforeInsertOutboundEntry(OutboundEntry, Item);
        InsertLedgerEntry(OutboundEntry);
        TempOutboundEntry := OutboundEntry;
        TempOutboundEntry.Insert();
    end;

    local procedure PostTransferReceipt(ItemJnlLine: Record "IMS Item Journal Line"; var TempOutboundEntry: Record "IMS Item Ledger Entry" temporary)
    begin
        TempOutboundEntry.Reset();
        TempOutboundEntry.FindSet();
        repeat
            PostInbound(
                ItemJnlLine, ItemJnlLine."New Location Code", ItemJnlLine."New Bin Code",
                TempOutboundEntry."Lot No.", TempOutboundEntry."Serial No.",
                -TempOutboundEntry.Quantity, -TempOutboundEntry."Cost Amount");
        until TempOutboundEntry.Next() = 0;
    end;

    /// <summary>
    /// Reserves quantity from open inbound layers. Each consumed slice is returned in
    /// TempLayerPiece ("Entry No." = inbound entry, Quantity / "Cost Amount" = slice).
    /// </summary>
    local procedure AllocateFromOpenLayers(ItemJnlLine: Record "IMS Item Journal Line"; var TempLayerPiece: Record "IMS Item Ledger Entry" temporary)
    var
        InboundEntry: Record "IMS Item Ledger Entry";
        InboundEntryToModify: Record "IMS Item Ledger Entry";
        PickingStrategy: Enum "IMS Picking Strategy";
        QtyToAllocate: Decimal;
        AllocatedQty: Decimal;
    begin
        QtyToAllocate := ItemJnlLine."Quantity (Base)";
        PickingStrategy := IndustryHandler.GetPickingStrategy(Item, IndustryProfile);

        if PickingStrategy = "IMS Picking Strategy"::FEFO then
            InboundEntry.SetCurrentKey("Item No.", Open, Positive, "Location Code", "Variant Code", "Expiration Date")
        else
            InboundEntry.SetCurrentKey("Item No.", Open, Positive, "Location Code", "Variant Code");
        InboundEntry.Ascending(PickingStrategy <> "IMS Picking Strategy"::LIFO);

        InboundEntry.SetRange("Item No.", ItemJnlLine."Item No.");
        InboundEntry.SetRange(Open, true);
        InboundEntry.SetRange(Positive, true);
        InboundEntry.SetRange("Location Code", ItemJnlLine."Location Code");
        InboundEntry.SetRange("Variant Code", ItemJnlLine."Variant Code");
        if ItemJnlLine."Bin Code" <> '' then
            InboundEntry.SetRange("Bin Code", ItemJnlLine."Bin Code");
        if ItemJnlLine."Lot No." <> '' then
            InboundEntry.SetRange("Lot No.", ItemJnlLine."Lot No.");
        if ItemJnlLine."Serial No." <> '' then
            InboundEntry.SetRange("Serial No.", ItemJnlLine."Serial No.");
        OnAllocateFromOpenLayersOnAfterSetFilters(InboundEntry, ItemJnlLine);

        if InboundEntry.FindSet() then
            repeat
                if CanIssueFromLayer(InboundEntry, ItemJnlLine) then begin
                    if QtyToAllocate < InboundEntry."Remaining Quantity" then
                        AllocatedQty := QtyToAllocate
                    else
                        AllocatedQty := InboundEntry."Remaining Quantity";

                    TempLayerPiece := InboundEntry;
                    TempLayerPiece.Quantity := AllocatedQty;
                    TempLayerPiece."Cost Amount" := CalcLayerCost(InboundEntry, AllocatedQty);
                    TempLayerPiece.Insert();

                    // Modify through a second variable: Open is part of the key being iterated.
                    InboundEntryToModify.Get(InboundEntry."Entry No.");
                    InboundEntryToModify."Remaining Quantity" -= AllocatedQty;
                    InboundEntryToModify.Open := InboundEntryToModify."Remaining Quantity" <> 0;
                    InboundEntryToModify.Modify();

                    QtyToAllocate -= AllocatedQty;
                end;
            until (InboundEntry.Next() = 0) or (QtyToAllocate = 0);

        if QtyToAllocate > 0 then
            Error(
                InsufficientStockErr, ItemJnlLine."Item No.", ItemJnlLine."Location Code", ItemJnlLine."Variant Code",
                ItemJnlLine."Bin Code", ItemJnlLine."Lot No.", ItemJnlLine."Serial No.", QtyToAllocate);
    end;

    local procedure CanIssueFromLayer(InboundEntry: Record "IMS Item Ledger Entry"; ItemJnlLine: Record "IMS Item Journal Line"): Boolean
    var
        LotNoInfo: Record "IMS Lot No. Information";
    begin
        if InboundEntry."Lot No." = '' then
            exit(true);
        if not LotNoInfo.Get(InboundEntry."Item No.", InboundEntry."Variant Code", InboundEntry."Lot No.") then
            exit(true);
        exit(IndustryHandler.CanIssueFromLot(Item, IndustryProfile, LotNoInfo, ItemJnlLine."Posting Date", ItemJnlLine."Entry Type"));
    end;

    /// <summary>Cost of a slice of a layer. The last slice takes the remainder so no rounding residue is left.</summary>
    local procedure CalcLayerCost(InboundEntry: Record "IMS Item Ledger Entry"; QtyBase: Decimal): Decimal
    var
        ItemApplicationEntry: Record "IMS Item Application Entry";
    begin
        if QtyBase = InboundEntry."Remaining Quantity" then begin
            ItemApplicationEntry.SetCurrentKey("Inbound Item Entry No.");
            ItemApplicationEntry.SetRange("Inbound Item Entry No.", InboundEntry."Entry No.");
            ItemApplicationEntry.CalcSums("Cost Amount");
            exit(InboundEntry."Cost Amount" - ItemApplicationEntry."Cost Amount");
        end;
        exit(Round(InboundEntry."Cost Amount" * QtyBase / InboundEntry.Quantity, 0.01));
    end;

    local procedure CalcInboundCost(ItemJnlLine: Record "IMS Item Journal Line"): Decimal
    begin
        if Item."Costing Method" = Item."Costing Method"::Standard then
            exit(Round(Item."Standard Cost" * ItemJnlLine."Quantity (Base)", 0.01));
        exit(ItemJnlLine.Amount);
    end;

    local procedure InitLedgerEntry(var ItemLedgerEntry: Record "IMS Item Ledger Entry"; ItemJnlLine: Record "IMS Item Journal Line")
    begin
        Clear(ItemLedgerEntry);
        ItemLedgerEntry.Init();
        ItemLedgerEntry."Item No." := ItemJnlLine."Item No.";
        ItemLedgerEntry."Variant Code" := ItemJnlLine."Variant Code";
        ItemLedgerEntry."Posting Date" := ItemJnlLine."Posting Date";
        ItemLedgerEntry."Entry Type" := ItemJnlLine."Entry Type";
        ItemLedgerEntry."Document No." := ItemJnlLine."Document No.";
        ItemLedgerEntry."External Document No." := ItemJnlLine."External Document No.";
        ItemLedgerEntry.Description := ItemJnlLine.Description;
        ItemLedgerEntry."Unit of Measure Code" := ItemJnlLine."Unit of Measure Code";
        ItemLedgerEntry."Qty. per Unit of Measure" := ItemJnlLine."Qty. per Unit of Measure";
        ItemLedgerEntry."Journal Batch Name" := ItemJnlLine."Journal Batch Name";
        ItemLedgerEntry."User ID" := CopyStr(UserId(), 1, MaxStrLen(ItemLedgerEntry."User ID"));
    end;

    local procedure InsertLedgerEntry(var ItemLedgerEntry: Record "IMS Item Ledger Entry")
    begin
        ItemLedgerEntry."Entry No." := NextEntryNo;
        UpdateRegister(ItemLedgerEntry."Entry No.", ItemLedgerEntry."Journal Batch Name");
        ItemLedgerEntry."Register No." := ImsRegister."No.";
        ItemLedgerEntry.Insert();
        OnAfterInsertItemLedgerEntry(ItemLedgerEntry);
        NextEntryNo += 1;
    end;

    local procedure InsertApplicationEntry(InboundEntryNo: Integer; OutboundEntryNo: Integer; QtyBase: Decimal; CostAmount: Decimal; PostingDate: Date)
    var
        ItemApplicationEntry: Record "IMS Item Application Entry";
    begin
        ItemApplicationEntry.Init();
        ItemApplicationEntry."Inbound Item Entry No." := InboundEntryNo;
        ItemApplicationEntry."Outbound Item Entry No." := OutboundEntryNo;
        ItemApplicationEntry.Quantity := QtyBase;
        ItemApplicationEntry."Cost Amount" := CostAmount;
        ItemApplicationEntry."Posting Date" := PostingDate;
        ItemApplicationEntry.Insert();
    end;

    local procedure GetOrCreateLotNoInfo(ItemJnlLine: Record "IMS Item Journal Line"; LotNo: Code[50]; var LotNoInfo: Record "IMS Lot No. Information")
    begin
        if LotNoInfo.Get(ItemJnlLine."Item No.", ItemJnlLine."Variant Code", LotNo) then
            exit;
        LotNoInfo.Init();
        LotNoInfo."Item No." := ItemJnlLine."Item No.";
        LotNoInfo."Variant Code" := ItemJnlLine."Variant Code";
        LotNoInfo."Lot No." := LotNo;
        LotNoInfo.Description := ItemJnlLine.Description;
        LotNoInfo."Expiration Date" := ItemJnlLine."Expiration Date";
        if (LotNoInfo."Expiration Date" = 0D) and (Format(Item."Shelf Life") <> '') then
            LotNoInfo."Expiration Date" := CalcDate(Item."Shelf Life", ItemJnlLine."Posting Date");
        LotNoInfo.Status := IndustryHandler.GetInitialLotStatus(Item, IndustryProfile);
        OnBeforeInsertLotNoInfo(LotNoInfo, ItemJnlLine);
        LotNoInfo.Insert();
    end;

    /// <summary>Keeps Item."Unit Cost" equal to the current average value of stock on hand.</summary>
    local procedure UpdateItemUnitCost()
    begin
        if Item."Costing Method" = Item."Costing Method"::Standard then
            exit;
        Item.CalcFields(Inventory, "Inventory Value");
        if Item.Inventory <= 0 then
            exit;
        Item."Unit Cost" := Round(Item."Inventory Value" / Item.Inventory, 0.00001);
        Item.Modify();
    end;

    local procedure InitNextEntryNo()
    var
        ItemLedgerEntry: Record "IMS Item Ledger Entry";
    begin
        if NextEntryNo <> 0 then
            exit;
        ItemLedgerEntry.LockTable();
        ItemLedgerEntry.SetLoadFields("Entry No.");
        if ItemLedgerEntry.FindLast() then
            NextEntryNo := ItemLedgerEntry."Entry No." + 1
        else
            NextEntryNo := 1;
    end;

    local procedure UpdateRegister(EntryNo: Integer; JournalBatchName: Code[10])
    var
        NewRegisterNo: Integer;
    begin
        if ImsRegister."No." <> 0 then begin
            ImsRegister."To Entry No." := EntryNo;
            ImsRegister.Modify();
            exit;
        end;
        ImsRegister.LockTable();
        if ImsRegister.FindLast() then
            NewRegisterNo := ImsRegister."No." + 1
        else
            NewRegisterNo := 1;
        ImsRegister.Init();
        ImsRegister."No." := NewRegisterNo;
        ImsRegister."From Entry No." := EntryNo;
        ImsRegister."To Entry No." := EntryNo;
        ImsRegister."Creation Date" := Today();
        ImsRegister."Creation Time" := Time();
        ImsRegister."User ID" := CopyStr(UserId(), 1, MaxStrLen(ImsRegister."User ID"));
        ImsRegister."Journal Batch Name" := JournalBatchName;
        ImsRegister.Insert();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostLine(var ItemJnlLine: Record "IMS Item Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostLine(var ItemJnlLine: Record "IMS Item Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertItemLedgerEntry(var ItemLedgerEntry: Record "IMS Item Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertOutboundEntry(var OutboundEntry: Record "IMS Item Ledger Entry"; Item: Record "IMS Item")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertLotNoInfo(var LotNoInfo: Record "IMS Lot No. Information"; ItemJnlLine: Record "IMS Item Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAllocateFromOpenLayersOnAfterSetFilters(var InboundEntry: Record "IMS Item Ledger Entry"; ItemJnlLine: Record "IMS Item Journal Line")
    begin
    end;
}
