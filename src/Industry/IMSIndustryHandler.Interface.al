/// <summary>
/// Contract every industry implementation must fulfil. The posting engine never contains
/// industry specific code; it asks the handler resolved from the item's Industry Profile.
/// To support a new industry: extend enum "IMS Industry Type" and implement this interface.
/// </summary>
interface "IMS Industry Handler"
{
    /// <summary>Applies industry defaults to a new item when an industry profile is assigned.</summary>
    procedure InitItemDefaults(var Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile");

    /// <summary>Verifies that the item master data meets the industry's rules before it can be posted.</summary>
    procedure ValidateItem(Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile");

    /// <summary>Industry specific checks on a journal line (runs after the generic checks).</summary>
    procedure CheckJournalLine(ItemJnlLine: Record "IMS Item Journal Line"; Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile");

    /// <summary>Order in which stock layers are consumed.</summary>
    procedure GetPickingStrategy(Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile"): Enum "IMS Picking Strategy";

    /// <summary>Returns false when stock of the lot may not be issued (quarantine, expired, short shelf life...).</summary>
    procedure CanIssueFromLot(Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile"; LotNoInfo: Record "IMS Lot No. Information"; PostingDate: Date; EntryType: Enum "IMS Entry Type"): Boolean;

    /// <summary>Status assigned to a lot the first time it is received.</summary>
    procedure GetInitialLotStatus(Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile"): Enum "IMS Lot Status";
}
