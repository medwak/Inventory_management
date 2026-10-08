/// <summary>Validation of GS1 GTIN-8/12/13/14 barcodes (mod-10 check digit).</summary>
codeunit 50108 "IMS GTIN Mgt."
{
    var
        InvalidGTINErr: Label '%1 is not a valid GTIN. A GTIN has 8, 12, 13 or 14 digits and a valid check digit.', Comment = '%1 = GTIN';

    procedure CheckGTIN(GTIN: Code[14])
    begin
        if not IsValidGTIN(GTIN) then
            Error(InvalidGTINErr, GTIN);
    end;

    procedure IsValidGTIN(GTIN: Code[14]): Boolean
    var
        Digit: Integer;
        Sum: Integer;
        Weight: Integer;
        i: Integer;
    begin
        if not (StrLen(GTIN) in [8, 12, 13, 14]) then
            exit(false);
        if DelChr(GTIN, '=', '0123456789') <> '' then
            exit(false);

        // Walk from the digit left of the check digit to the start; weights alternate 3,1,3,...
        Weight := 3;
        for i := StrLen(GTIN) - 1 downto 1 do begin
            Evaluate(Digit, CopyStr(GTIN, i, 1));
            Sum += Digit * Weight;
            Weight := 4 - Weight;
        end;
        Evaluate(Digit, CopyStr(GTIN, StrLen(GTIN), 1));
        exit((10 - (Sum mod 10)) mod 10 = Digit);
    end;
}
