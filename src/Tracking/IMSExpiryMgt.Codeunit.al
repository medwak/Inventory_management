/// <summary>
/// Expiry monitoring. Schedule it as a Job Queue Entry (Object Type Codeunit, ID 50107)
/// to block expired lots every night so they can no longer be sold or consumed.
/// </summary>
codeunit 50107 "IMS Expiry Mgt."
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        ImsSetup: Record "IMS Setup";
    begin
        ImsSetup.GetRecordOnce();
        if ImsSetup."Block Expired Lots (Job)" then
            BlockExpiredLots(Today());
    end;

    /// <summary>Blocks every available/quarantined lot with stock whose expiration date is before AsOfDate.</summary>
    procedure BlockExpiredLots(AsOfDate: Date) NoOfLotsBlocked: Integer
    var
        LotNoInfo: Record "IMS Lot No. Information";
        LotNoInfoToModify: Record "IMS Lot No. Information";
    begin
        LotNoInfo.SetCurrentKey("Expiration Date", Status);
        LotNoInfo.SetFilter("Expiration Date", '<>%1&<%2', 0D, AsOfDate);
        LotNoInfo.SetFilter(Status, '<>%1', LotNoInfo.Status::Blocked);
        if LotNoInfo.FindSet() then
            repeat
                LotNoInfo.CalcFields(Inventory);
                if LotNoInfo.Inventory > 0 then begin
                    // Separate variable: the filtered field (Status) is being modified.
                    LotNoInfoToModify.Get(LotNoInfo."Item No.", LotNoInfo."Variant Code", LotNoInfo."Lot No.");
                    LotNoInfoToModify.SetStatus(LotNoInfoToModify.Status::Blocked);
                    NoOfLotsBlocked += 1;
                end;
            until LotNoInfo.Next() = 0;
    end;

    /// <summary>Fills a temporary buffer with lots in stock that expire within the warning period.</summary>
    procedure GetExpiringLots(var TempLotNoInfo: Record "IMS Lot No. Information" temporary; AsOfDate: Date)
    var
        LotNoInfo: Record "IMS Lot No. Information";
    begin
        TempLotNoInfo.Reset();
        TempLotNoInfo.DeleteAll();
        LotNoInfo.SetCurrentKey("Expiration Date", Status);
        LotNoInfo.SetRange("Expiration Date", AsOfDate, GetWarningDate(AsOfDate));
        if LotNoInfo.FindSet() then
            repeat
                LotNoInfo.CalcFields(Inventory);
                if LotNoInfo.Inventory > 0 then begin
                    TempLotNoInfo := LotNoInfo;
                    TempLotNoInfo.Insert();
                end;
            until LotNoInfo.Next() = 0;
    end;

    procedure GetWarningDate(AsOfDate: Date): Date
    var
        ImsSetup: Record "IMS Setup";
    begin
        ImsSetup.GetRecordOnce();
        if Format(ImsSetup."Expiry Warning Period") = '' then
            exit(AsOfDate);
        exit(CalcDate(ImsSetup."Expiry Warning Period", AsOfDate));
    end;
}
