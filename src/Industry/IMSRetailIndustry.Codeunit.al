/// <summary>
/// Retail &amp; wholesale: every item must carry a valid GTIN (barcode) so it can be scanned at POS/receiving.
/// Variants (size/colour) are expected; stock is consumed FIFO.
/// </summary>
codeunit 50112 "IMS Retail Industry" implements "IMS Industry Handler"
{
    var
        BaseRules: Codeunit "IMS Industry Base Rules";

    procedure InitItemDefaults(var Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile")
    begin
        BaseRules.InitItemDefaults(Item, IndustryProfile);
    end;

    procedure ValidateItem(Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile")
    begin
        Item.TestField(GTIN);
        BaseRules.ValidateItem(Item, IndustryProfile);
    end;

    procedure CheckJournalLine(ItemJnlLine: Record "IMS Item Journal Line"; Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile")
    begin
        BaseRules.CheckJournalLine(ItemJnlLine, Item, IndustryProfile);
    end;

    procedure GetPickingStrategy(Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile"): Enum "IMS Picking Strategy"
    begin
        exit(BaseRules.GetPickingStrategy(Item, IndustryProfile));
    end;

    procedure CanIssueFromLot(Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile"; LotNoInfo: Record "IMS Lot No. Information"; PostingDate: Date; EntryType: Enum "IMS Entry Type"): Boolean
    begin
        exit(BaseRules.CanIssueFromLot(Item, IndustryProfile, LotNoInfo, PostingDate, EntryType));
    end;

    procedure GetInitialLotStatus(Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile"): Enum "IMS Lot Status"
    begin
        exit(BaseRules.GetInitialLotStatus(Item, IndustryProfile));
    end;
}
