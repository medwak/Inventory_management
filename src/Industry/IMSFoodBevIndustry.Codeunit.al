/// <summary>
/// Food &amp; beverage: lot tracking with expiration dates (recall readiness), FEFO picking,
/// expired lots never issued, and the profile's minimum remaining shelf life enforced on sales.
/// </summary>
codeunit 50114 "IMS Food Bev Industry" implements "IMS Industry Handler"
{
    var
        BaseRules: Codeunit "IMS Industry Base Rules";
        LotTrackingRequiredErr: Label 'Food & beverage item %1 must be lot tracked for recall traceability.', Comment = '%1 = Item No.';

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
        exit(BaseRules.GetInitialLotStatus(Item, IndustryProfile));
    end;
}
