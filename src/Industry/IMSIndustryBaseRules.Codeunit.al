/// <summary>
/// Profile (configuration) driven rules shared by all industries. Industry handlers call
/// these and then add their own, so a handler only contains what makes its industry different.
/// </summary>
codeunit 50110 "IMS Industry Base Rules"
{
    var
        GTINMgt: Codeunit "IMS GTIN Mgt.";
        MandatoryAttributeErr: Label 'Item %1 is missing a value for the mandatory attribute %2.', Comment = '%1 = Item No., %2 = Attribute Code';

    procedure InitItemDefaults(var Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile")
    begin
        Item."Item Tracking Type" := IndustryProfile."Default Tracking Type";
        Item."Expiration Date Required" := IndustryProfile."Expiration Date Required";
        Item."Shelf Life" := IndustryProfile."Default Shelf Life";
        Item."Costing Method" := IndustryProfile."Default Costing Method";
        Item."Picking Strategy" := IndustryProfile."Default Picking Strategy";
        if (Item."Base Unit of Measure" = '') and (IndustryProfile."Default Base Unit of Measure" <> '') then
            Item.Validate("Base Unit of Measure", IndustryProfile."Default Base Unit of Measure");
    end;

    procedure ValidateItem(Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile")
    begin
        Item.TestField("Base Unit of Measure");
        if IndustryProfile."GTIN Required" then
            Item.TestField(GTIN);
        if Item.GTIN <> '' then
            GTINMgt.CheckGTIN(Item.GTIN);
        CheckMandatoryAttributes(Item);
    end;

    procedure CheckJournalLine(ItemJnlLine: Record "IMS Item Journal Line"; Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile")
    begin
    end;

    procedure GetPickingStrategy(Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile"): Enum "IMS Picking Strategy"
    begin
        exit(Item."Picking Strategy");
    end;

    procedure CanIssueFromLot(Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile"; LotNoInfo: Record "IMS Lot No. Information"; PostingDate: Date; EntryType: Enum "IMS Entry Type"): Boolean
    begin
        // Scrapping must always be possible, whatever the status or expiry.
        if EntryType = "IMS Entry Type"::"Negative Adjmt." then
            exit(LotNoInfo.Status <> LotNoInfo.Status::Blocked);

        case LotNoInfo.Status of
            LotNoInfo.Status::Blocked:
                exit(false);
            LotNoInfo.Status::Quarantine:
                // Quarantined stock may be moved (e.g. to a QC bin) but not sold or consumed.
                if EntryType <> "IMS Entry Type"::Transfer then
                    exit(false);
        end;

        if IndustryProfile."Block Expired Stock" and IsExpired(LotNoInfo, PostingDate) then
            exit(false);

        if (EntryType = "IMS Entry Type"::Sale) and (LotNoInfo."Expiration Date" <> 0D) and
           (Format(IndustryProfile."Min. Shelf Life on Sale") <> '')
        then
            if LotNoInfo."Expiration Date" < CalcDate(IndustryProfile."Min. Shelf Life on Sale", PostingDate) then
                exit(false);

        exit(true);
    end;

    procedure GetInitialLotStatus(Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile"): Enum "IMS Lot Status"
    begin
        if IndustryProfile."Quarantine on Receipt" then
            exit("IMS Lot Status"::Quarantine);
        exit("IMS Lot Status"::Available);
    end;

    procedure IsExpired(LotNoInfo: Record "IMS Lot No. Information"; PostingDate: Date): Boolean
    begin
        exit((LotNoInfo."Expiration Date" <> 0D) and (LotNoInfo."Expiration Date" < PostingDate));
    end;

    procedure CheckMandatoryAttributes(Item: Record "IMS Item")
    var
        Attribute: Record "IMS Attribute";
        ItemAttributeValue: Record "IMS Item Attribute Value";
    begin
        Attribute.SetRange(Mandatory, true);
        Attribute.SetRange(Blocked, false);
        Attribute.SetFilter("Industry Profile Code", '%1|%2', '', Item."Industry Profile Code");
        Attribute.SetLoadFields(Code);
        if Attribute.FindSet() then
            repeat
                if not ItemAttributeValue.Get(Item."No.", Attribute.Code) or (ItemAttributeValue.Value = '') then
                    Error(MandatoryAttributeErr, Item."No.", Attribute.Code);
            until Attribute.Next() = 0;
    end;
}
