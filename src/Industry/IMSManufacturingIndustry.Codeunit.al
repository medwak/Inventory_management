/// <summary>
/// Manufacturing: raw material consumption and finished goods output must reference the
/// production order (External Document No.) so genealogy can be traced from FG lot to RM lots.
/// </summary>
codeunit 50115 "IMS Manufacturing Industry" implements "IMS Industry Handler"
{
    var
        BaseRules: Codeunit "IMS Industry Base Rules";

    procedure InitItemDefaults(var Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile")
    begin
        BaseRules.InitItemDefaults(Item, IndustryProfile);
    end;

    procedure ValidateItem(Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile")
    begin
        BaseRules.ValidateItem(Item, IndustryProfile);
    end;

    procedure CheckJournalLine(ItemJnlLine: Record "IMS Item Journal Line"; Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile")
    begin
        BaseRules.CheckJournalLine(ItemJnlLine, Item, IndustryProfile);
        if ItemJnlLine."Entry Type" in [ItemJnlLine."Entry Type"::Consumption, ItemJnlLine."Entry Type"::Output] then
            ItemJnlLine.TestField("External Document No.");
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
