/// <summary>
/// Pharmaceutical &amp; healthcare (GxP style):
/// - items must be lot tracked with mandatory expiration dates,
/// - every received lot starts in Quarantine until QA releases it,
/// - stock is always issued FEFO and expired stock can never be issued (only scrapped),
/// - sales must reference an external document (order / prescription) for traceability.
/// </summary>
codeunit 50113 "IMS Pharma Industry" implements "IMS Industry Handler"
{
    var
        BaseRules: Codeunit "IMS Industry Base Rules";
        LotTrackingRequiredErr: Label 'Pharmaceutical item %1 must be lot tracked.', Comment = '%1 = Item No.';

    procedure InitItemDefaults(var Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile")
    begin
        BaseRules.InitItemDefaults(Item, IndustryProfile);
        if not Item.UsesLotTracking() then
            Item."Item Tracking Type" := Item."Item Tracking Type"::Lot;
        Item."Expiration Date Required" := true;
        Item."Picking Strategy" := Item."Picking Strategy"::FEFO;
    end;

    procedure ValidateItem(Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile")
    begin
        if not Item.UsesLotTracking() then
            Error(LotTrackingRequiredErr, Item."No.");
        Item.TestField("Expiration Date Required", true);
        BaseRules.ValidateItem(Item, IndustryProfile);
    end;

    procedure CheckJournalLine(ItemJnlLine: Record "IMS Item Journal Line"; Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile")
    begin
        BaseRules.CheckJournalLine(ItemJnlLine, Item, IndustryProfile);
        if ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Sale then
            ItemJnlLine.TestField("External Document No.");
    end;

    procedure GetPickingStrategy(Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile"): Enum "IMS Picking Strategy"
    begin
        exit("IMS Picking Strategy"::FEFO);
    end;

    procedure CanIssueFromLot(Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile"; LotNoInfo: Record "IMS Lot No. Information"; PostingDate: Date; EntryType: Enum "IMS Entry Type"): Boolean
    begin
        if (EntryType <> "IMS Entry Type"::"Negative Adjmt.") and BaseRules.IsExpired(LotNoInfo, PostingDate) then
            exit(false);
        exit(BaseRules.CanIssueFromLot(Item, IndustryProfile, LotNoInfo, PostingDate, EntryType));
    end;

    procedure GetInitialLotStatus(Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile"): Enum "IMS Lot Status"
    begin
        exit("IMS Lot Status"::Quarantine);
    end;
}
