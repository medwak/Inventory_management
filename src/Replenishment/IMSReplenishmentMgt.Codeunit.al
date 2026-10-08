/// <summary>
/// Min/max and reorder-point planning. Plans per Stockkeeping Unit when an item has SKUs,
/// otherwise at item level across all locations. Accepted suggestions are carried out as
/// Purchase lines in an item journal batch. Can run from the Job Queue (no UI).
/// </summary>
codeunit 50106 "IMS Replenishment Mgt."
{
    var
        ImsSetup: Record "IMS Setup";
        NextLineNo: Integer;

    procedure CalculatePlan(var ItemFilter: Record "IMS Item"; LocationFilter: Text) NoOfSuggestions: Integer
    var
        Item: Record "IMS Item";
        StockkeepingUnit: Record "IMS Stockkeeping Unit";
        ReplenishmentLine: Record "IMS Replenishment Line";
    begin
        ImsSetup.GetRecordOnce();
        ReplenishmentLine.SetRange("User ID", UserId());
        ReplenishmentLine.DeleteAll();
        NextLineNo := 0;

        Item.CopyFilters(ItemFilter);
        Item.SetRange(Blocked, false);
        Item.SetLoadFields(
            "No.", Description, "Replenishment Policy", "Reorder Point", "Reorder Quantity",
            "Maximum Inventory", "Safety Stock Quantity", "Lead Time Calculation");
        if Item.FindSet() then
            repeat
                StockkeepingUnit.SetRange("Item No.", Item."No.");
                if LocationFilter <> '' then
                    StockkeepingUnit.SetFilter("Location Code", LocationFilter);
                if not StockkeepingUnit.IsEmpty() then begin
                    StockkeepingUnit.FindSet();
                    repeat
                        if StockkeepingUnit."Replenishment Policy" <> StockkeepingUnit."Replenishment Policy"::Manual then
                            NoOfSuggestions += PlanOne(
                                Item, StockkeepingUnit."Variant Code", StockkeepingUnit."Location Code", StockkeepingUnit."Location Code",
                                StockkeepingUnit."Replenishment Policy", StockkeepingUnit."Reorder Point", StockkeepingUnit."Reorder Quantity",
                                StockkeepingUnit."Maximum Inventory", StockkeepingUnit."Safety Stock Quantity", StockkeepingUnit."Lead Time Calculation");
                    until StockkeepingUnit.Next() = 0;
                end else
                    if Item."Replenishment Policy" <> Item."Replenishment Policy"::Manual then
                        NoOfSuggestions += PlanOne(
                            Item, '', ImsSetup."Default Location Code", LocationFilter,
                            Item."Replenishment Policy", Item."Reorder Point", Item."Reorder Quantity",
                            Item."Maximum Inventory", Item."Safety Stock Quantity", Item."Lead Time Calculation");
            until Item.Next() = 0;
    end;

    /// <summary>Pure calculation of the quantity to order; public so it can be unit tested.</summary>
    procedure CalcSuggestedQty(Policy: Enum "IMS Replenishment Policy"; Inventory: Decimal; ReorderPoint: Decimal; ReorderQty: Decimal; MaximumInventory: Decimal; SafetyStock: Decimal) SuggestedQty: Decimal
    begin
        if (Inventory > ReorderPoint) and (Inventory >= SafetyStock) then
            exit(0);

        case Policy of
            "IMS Replenishment Policy"::"Fixed Reorder Qty.":
                begin
                    if ReorderQty <= 0 then
                        exit(0);
                    // Order whole multiples of the reorder quantity until above both reorder point and safety stock.
                    repeat
                        SuggestedQty += ReorderQty;
                    until (Inventory + SuggestedQty > ReorderPoint) and (Inventory + SuggestedQty >= SafetyStock);
                end;
            "IMS Replenishment Policy"::"Maximum Qty.":
                if MaximumInventory > Inventory then
                    SuggestedQty := MaximumInventory - Inventory;
        end;
        OnAfterCalcSuggestedQty(Policy, Inventory, ReorderPoint, ReorderQty, MaximumInventory, SafetyStock, SuggestedQty);
    end;

    /// <summary>Creates purchase journal lines for accepted suggestions and removes them from the worksheet.</summary>
    procedure CarryOut(JournalBatchName: Code[10]) NoOfLinesCreated: Integer
    var
        ReplenishmentLine: Record "IMS Replenishment Line";
        ItemJnlBatch: Record "IMS Item Journal Batch";
        ItemJnlLine: Record "IMS Item Journal Line";
        LastItemJnlLine: Record "IMS Item Journal Line";
        LineNo: Integer;
    begin
        ItemJnlBatch.Get(JournalBatchName);
        LastItemJnlLine.SetRange("Journal Batch Name", JournalBatchName);
        if LastItemJnlLine.FindLast() then
            LineNo := LastItemJnlLine."Line No.";

        ReplenishmentLine.SetRange("User ID", UserId());
        ReplenishmentLine.SetRange("Accept Suggestion", true);
        ReplenishmentLine.SetFilter("Suggested Quantity", '>0');
        if ReplenishmentLine.FindSet() then
            repeat
                LineNo += 10000;
                ItemJnlLine.Init();
                ItemJnlLine."Journal Batch Name" := JournalBatchName;
                ItemJnlLine."Line No." := LineNo;
                ItemJnlLine.SetUpNewLine(LastItemJnlLine);
                ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::Purchase);
                ItemJnlLine.Validate("Posting Date", ReplenishmentLine."Due Date");
                ItemJnlLine.Validate("Item No.", ReplenishmentLine."Item No.");
                ItemJnlLine.Validate("Variant Code", ReplenishmentLine."Variant Code");
                ItemJnlLine.Validate("Location Code", ReplenishmentLine."Location Code");
                ItemJnlLine.Validate(Quantity, ReplenishmentLine."Suggested Quantity");
                ItemJnlLine.Insert(true);
                LastItemJnlLine := ItemJnlLine;
                NoOfLinesCreated += 1;
            until ReplenishmentLine.Next() = 0;
        ReplenishmentLine.DeleteAll();
    end;

    local procedure PlanOne(var Item: Record "IMS Item"; VariantCode: Code[10]; LocationCode: Code[10]; InventoryLocationFilter: Text; Policy: Enum "IMS Replenishment Policy"; ReorderPoint: Decimal; ReorderQty: Decimal; MaximumInventory: Decimal; SafetyStock: Decimal; LeadTime: DateFormula): Integer
    var
        ReplenishmentLine: Record "IMS Replenishment Line";
        SuggestedQty: Decimal;
    begin
        Item.SetFilter("Location Filter", InventoryLocationFilter);
        if VariantCode <> '' then
            Item.SetRange("Variant Filter", VariantCode)
        else
            Item.SetRange("Variant Filter");
        Item.CalcFields(Inventory);

        SuggestedQty := CalcSuggestedQty(Policy, Item.Inventory, ReorderPoint, ReorderQty, MaximumInventory, SafetyStock);
        if SuggestedQty <= 0 then
            exit(0);

        NextLineNo += 10000;
        ReplenishmentLine.Init();
        ReplenishmentLine."User ID" := CopyStr(UserId(), 1, MaxStrLen(ReplenishmentLine."User ID"));
        ReplenishmentLine."Line No." := NextLineNo;
        ReplenishmentLine."Item No." := Item."No.";
        ReplenishmentLine."Variant Code" := VariantCode;
        ReplenishmentLine."Location Code" := LocationCode;
        ReplenishmentLine.Description := Item.Description;
        ReplenishmentLine."Replenishment Policy" := Policy;
        ReplenishmentLine."Current Inventory" := Item.Inventory;
        ReplenishmentLine."Reorder Point" := ReorderPoint;
        ReplenishmentLine."Safety Stock Quantity" := SafetyStock;
        ReplenishmentLine."Maximum Inventory" := MaximumInventory;
        ReplenishmentLine."Suggested Quantity" := SuggestedQty;
        ReplenishmentLine."Due Date" := WorkDate();
        if Format(LeadTime) <> '' then
            ReplenishmentLine."Due Date" := CalcDate(LeadTime, WorkDate());
        ReplenishmentLine.Insert();
        exit(1);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcSuggestedQty(Policy: Enum "IMS Replenishment Policy"; Inventory: Decimal; ReorderPoint: Decimal; ReorderQty: Decimal; MaximumInventory: Decimal; SafetyStock: Decimal; var SuggestedQty: Decimal)
    begin
    end;
}
