codeunit 50150 "IMS Posting Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        Library: Codeunit "IMS Test Library";

    [Test]
    procedure PositiveAdjustmentIncreasesInventory()
    var
        Item: Record "IMS Item";
        Location: Record "IMS Location";
    begin
        Library.Initialize();
        Library.CreateItem('GENERAL', Item);
        Library.CreateLocation(Location);

        Library.PostLine("IMS Entry Type"::"Positive Adjmt.", Item."No.", Location.Code, 10, 5, '', 0D);

        Assert.AreEqual(10, Library.GetInventory(Item."No.", Location.Code), 'Inventory after receipt');
    end;

    [Test]
    procedure ActualCostingConsumesLayersFIFO()
    var
        Item: Record "IMS Item";
        Location: Record "IMS Location";
        ItemLedgerEntry: Record "IMS Item Ledger Entry";
    begin
        Library.Initialize();
        Library.CreateItem('GENERAL', Item);
        Item.Validate("Costing Method", Item."Costing Method"::Actual);
        Item.Validate("Picking Strategy", Item."Picking Strategy"::FIFO);
        Item.Modify(true);
        Library.CreateLocation(Location);

        Library.PostLine("IMS Entry Type"::Purchase, Item."No.", Location.Code, 10, 5, '', 0D);
        Library.PostLine("IMS Entry Type"::Purchase, Item."No.", Location.Code, 10, 7, '', 0D);
        Library.PostLine("IMS Entry Type"::Sale, Item."No.", Location.Code, 15, 0, '', 0D);

        // 10 x 5 from the first layer + 5 x 7 from the second layer.
        Library.FindLastOutbound(Item."No.", ItemLedgerEntry);
        Assert.AreEqual(-85, ItemLedgerEntry."Cost Amount", 'FIFO cost of the sale');
        Item.CalcFields("Inventory Value");
        Assert.AreEqual(35, Item."Inventory Value", 'Remaining inventory value');
    end;

    [Test]
    procedure LIFOConsumesNewestLayerFirst()
    var
        Item: Record "IMS Item";
        Location: Record "IMS Location";
        ItemLedgerEntry: Record "IMS Item Ledger Entry";
    begin
        Library.Initialize();
        Library.CreateItem('GENERAL', Item);
        Item.Validate("Costing Method", Item."Costing Method"::Actual);
        Item.Validate("Picking Strategy", Item."Picking Strategy"::LIFO);
        Item.Modify(true);
        Library.CreateLocation(Location);

        Library.PostLine("IMS Entry Type"::Purchase, Item."No.", Location.Code, 10, 5, '', 0D);
        Library.PostLine("IMS Entry Type"::Purchase, Item."No.", Location.Code, 10, 7, '', 0D);
        Library.PostLine("IMS Entry Type"::Sale, Item."No.", Location.Code, 5, 0, '', 0D);

        Library.FindLastOutbound(Item."No.", ItemLedgerEntry);
        Assert.AreEqual(-35, ItemLedgerEntry."Cost Amount", 'LIFO cost of the sale');
    end;

    [Test]
    procedure CannotIssueMoreThanOnHand()
    var
        Item: Record "IMS Item";
        Location: Record "IMS Location";
    begin
        Library.Initialize();
        Library.CreateItem('GENERAL', Item);
        Library.CreateLocation(Location);
        Library.PostLine("IMS Entry Type"::Purchase, Item."No.", Location.Code, 3, 1, '', 0D);

        asserterror Library.PostLine("IMS Entry Type"::Sale, Item."No.", Location.Code, 4, 0, '', 0D);
        Assert.ExpectedError('There is not enough available stock');
    end;

    [Test]
    procedure TransferMovesStockAndCost()
    var
        Item: Record "IMS Item";
        FromLocation: Record "IMS Location";
        ToLocation: Record "IMS Location";
        ItemJnlLine: Record "IMS Item Journal Line";
    begin
        Library.Initialize();
        Library.CreateItem('GENERAL', Item);
        Library.CreateLocation(FromLocation);
        Library.CreateLocation(ToLocation);
        Library.PostLine("IMS Entry Type"::Purchase, Item."No.", FromLocation.Code, 10, 4, '', 0D);

        Library.CreateJournalLine(ItemJnlLine, "IMS Entry Type"::Transfer, Item."No.", FromLocation.Code, 6, 0, '', 0D);
        ItemJnlLine.Validate("New Location Code", ToLocation.Code);
        Library.PostJournalLine(ItemJnlLine);

        Assert.AreEqual(4, Library.GetInventory(Item."No.", FromLocation.Code), 'Stock left at source');
        Assert.AreEqual(6, Library.GetInventory(Item."No.", ToLocation.Code), 'Stock at destination');
        Item.CalcFields("Inventory Value");
        Assert.AreEqual(40, Item."Inventory Value", 'A transfer must not change total value');
    end;

    [Test]
    procedure FoodFEFOPicksEarliestExpiringLotAutomatically()
    var
        Item: Record "IMS Item";
        Location: Record "IMS Location";
        ItemLedgerEntry: Record "IMS Item Ledger Entry";
    begin
        Library.Initialize();
        Library.CreateItem('FOODBEV', Item);
        Library.CreateLocation(Location);

        Library.PostLine("IMS Entry Type"::Purchase, Item."No.", Location.Code, 5, 1, 'LATE', WorkDate() + 60);
        Library.PostLine("IMS Entry Type"::Purchase, Item."No.", Location.Code, 5, 1, 'EARLY', WorkDate() + 20);

        // No lot on the sale: the engine must pick the lot expiring first.
        Library.PostLine("IMS Entry Type"::Sale, Item."No.", Location.Code, 3, 0, '', 0D);

        Library.FindLastOutbound(Item."No.", ItemLedgerEntry);
        Assert.AreEqual('EARLY', ItemLedgerEntry."Lot No.", 'FEFO must issue the earliest expiring lot');
    end;

    [Test]
    procedure FoodSaleSplitsAcrossLotsIntoSeparateEntries()
    var
        Item: Record "IMS Item";
        Location: Record "IMS Location";
        ItemLedgerEntry: Record "IMS Item Ledger Entry";
    begin
        Library.Initialize();
        Library.CreateItem('FOODBEV', Item);
        Library.CreateLocation(Location);
        Library.PostLine("IMS Entry Type"::Purchase, Item."No.", Location.Code, 5, 1, 'L1', WorkDate() + 20);
        Library.PostLine("IMS Entry Type"::Purchase, Item."No.", Location.Code, 5, 1, 'L2', WorkDate() + 40);

        Library.PostLine("IMS Entry Type"::Sale, Item."No.", Location.Code, 8, 0, '', 0D);

        ItemLedgerEntry.SetRange("Item No.", Item."No.");
        ItemLedgerEntry.SetRange(Positive, false);
        Assert.AreEqual(2, ItemLedgerEntry.Count(), 'One outbound entry per lot');
        ItemLedgerEntry.SetRange("Lot No.", 'L2');
        ItemLedgerEntry.FindFirst();
        Assert.AreEqual(-3, ItemLedgerEntry.Quantity, 'Quantity taken from the second lot');
    end;

    [Test]
    procedure FoodExpiredLotIsSkippedForSales()
    var
        Item: Record "IMS Item";
        Location: Record "IMS Location";
        ItemLedgerEntry: Record "IMS Item Ledger Entry";
    begin
        Library.Initialize();
        Library.CreateItem('FOODBEV', Item);
        Library.CreateLocation(Location);
        Library.PostLine("IMS Entry Type"::Purchase, Item."No.", Location.Code, 5, 1, 'OLD', WorkDate() - 1);
        Library.PostLine("IMS Entry Type"::Purchase, Item."No.", Location.Code, 5, 1, 'FRESH', WorkDate() + 30);

        Library.PostLine("IMS Entry Type"::Sale, Item."No.", Location.Code, 2, 0, '', 0D);
        Library.FindLastOutbound(Item."No.", ItemLedgerEntry);
        Assert.AreEqual('FRESH', ItemLedgerEntry."Lot No.", 'Expired lot must be skipped');

        // Only 3 sellable units remain although 8 are on hand.
        asserterror Library.PostLine("IMS Entry Type"::Sale, Item."No.", Location.Code, 4, 0, '', 0D);
        Assert.ExpectedError('There is not enough available stock');
    end;

    [Test]
    procedure ExpiredLotCanStillBeScrapped()
    var
        Item: Record "IMS Item";
        Location: Record "IMS Location";
    begin
        Library.Initialize();
        Library.CreateItem('FOODBEV', Item);
        Library.CreateLocation(Location);
        Library.PostLine("IMS Entry Type"::Purchase, Item."No.", Location.Code, 5, 1, 'OLD', WorkDate() - 1);

        Library.PostLine("IMS Entry Type"::"Negative Adjmt.", Item."No.", Location.Code, 5, 0, 'OLD', 0D);

        Assert.AreEqual(0, Library.GetInventory(Item."No.", Location.Code), 'Expired stock written off');
    end;

    [Test]
    procedure PharmaLotIsQuarantinedUntilReleased()
    var
        Item: Record "IMS Item";
        Location: Record "IMS Location";
        LotNoInfo: Record "IMS Lot No. Information";
    begin
        Library.Initialize();
        Library.CreateItem('PHARMA', Item);
        Library.CreateLocation(Location);

        Library.PostLine("IMS Entry Type"::Purchase, Item."No.", Location.Code, 100, 1, 'B001', WorkDate() + 365);
        LotNoInfo.Get(Item."No.", '', 'B001');
        Assert.AreEqual(LotNoInfo.Status::Quarantine, LotNoInfo.Status, 'New pharma lots start in quarantine');

        asserterror Library.PostLine("IMS Entry Type"::Sale, Item."No.", Location.Code, 10, 0, '', 0D);
        Assert.ExpectedError('There is not enough available stock');

        Library.ReleaseLot(Item."No.", 'B001');
        Library.PostLine("IMS Entry Type"::Sale, Item."No.", Location.Code, 10, 0, '', 0D);
        Assert.AreEqual(90, Library.GetInventory(Item."No.", Location.Code), 'Stock after release and sale');
    end;

    [Test]
    procedure PharmaReceiptRequiresLotNo()
    var
        Item: Record "IMS Item";
        Location: Record "IMS Location";
    begin
        Library.Initialize();
        Library.CreateItem('PHARMA', Item);
        Library.CreateLocation(Location);

        asserterror Library.PostLine("IMS Entry Type"::Purchase, Item."No.", Location.Code, 10, 1, '', 0D);
        Assert.ExpectedError('Lot No. must have a value');
    end;

    [Test]
    procedure RetailItemRequiresGTIN()
    var
        Item: Record "IMS Item";
        Location: Record "IMS Location";
    begin
        Library.Initialize();
        Library.CreateItem('RETAIL', Item);
        Item.Validate(GTIN, '');
        Item.Modify(true);
        Library.CreateLocation(Location);

        asserterror Library.PostLine("IMS Entry Type"::Purchase, Item."No.", Location.Code, 1, 1, '', 0D);
        Assert.ExpectedError(Item.FieldCaption(GTIN) + ' must have a value');
    end;

    [Test]
    procedure GTINCheckDigitIsValidated()
    var
        GTINMgt: Codeunit "IMS GTIN Mgt.";
    begin
        Assert.IsTrue(GTINMgt.IsValidGTIN('4006381333931'), 'Valid EAN-13');
        Assert.IsTrue(GTINMgt.IsValidGTIN('96385074'), 'Valid EAN-8');
        Assert.IsFalse(GTINMgt.IsValidGTIN('4006381333932'), 'Wrong check digit');
        Assert.IsFalse(GTINMgt.IsValidGTIN('12345'), 'Wrong length');
    end;

    [Test]
    procedure ManufacturingConsumptionRequiresProductionOrderRef()
    var
        IndustryProfile: Record "IMS Industry Profile";
        Item: Record "IMS Item";
        Location: Record "IMS Location";
        ItemJnlLine: Record "IMS Item Journal Line";
    begin
        Library.Initialize();
        Library.CreateProfile("IMS Industry Type"::Manufacturing, IndustryProfile);
        Library.CreateItem(IndustryProfile.Code, Item);
        Library.CreateLocation(Location);
        Library.PostLine("IMS Entry Type"::Purchase, Item."No.", Location.Code, 10, 1, '', 0D);

        Library.CreateJournalLine(ItemJnlLine, "IMS Entry Type"::Consumption, Item."No.", Location.Code, 2, 0, '', 0D);
        ItemJnlLine."External Document No." := '';
        asserterror Library.PostJournalLine(ItemJnlLine);
        Assert.ExpectedError(ItemJnlLine.FieldCaption("External Document No.") + ' must have a value');
    end;

    [Test]
    procedure AverageCostIsRecalculatedOnReceipt()
    var
        Item: Record "IMS Item";
        Location: Record "IMS Location";
    begin
        Library.Initialize();
        Library.CreateItem('GENERAL', Item);
        Library.CreateLocation(Location);

        Library.PostLine("IMS Entry Type"::Purchase, Item."No.", Location.Code, 10, 10, '', 0D);
        Library.PostLine("IMS Entry Type"::Purchase, Item."No.", Location.Code, 30, 20, '', 0D);

        Item.Get(Item."No.");
        Assert.AreEqual(17.5, Item."Unit Cost", 'Weighted average (100 + 600) / 40');
    end;

    [Test]
    procedure ReplenishmentFixedReorderQtyOrdersMultiples()
    var
        ReplenishmentMgt: Codeunit "IMS Replenishment Mgt.";
    begin
        // On hand 5, reorder point 20, lot size 10 -> 20 brings stock to 25 (> reorder point).
        Assert.AreEqual(20, ReplenishmentMgt.CalcSuggestedQty("IMS Replenishment Policy"::"Fixed Reorder Qty.", 5, 20, 10, 0, 0), 'Fixed reorder qty');
        Assert.AreEqual(0, ReplenishmentMgt.CalcSuggestedQty("IMS Replenishment Policy"::"Fixed Reorder Qty.", 25, 20, 10, 0, 0), 'Above reorder point');
        Assert.AreEqual(95, ReplenishmentMgt.CalcSuggestedQty("IMS Replenishment Policy"::"Maximum Qty.", 5, 20, 0, 100, 0), 'Order up to maximum');
    end;
}
