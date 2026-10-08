/// <summary>
/// Industry verticals. Each value binds to an "IMS Industry Handler" implementation.
/// The enum is extensible: another extension can add e.g. "Automotive" with its own codeunit.
/// </summary>
enum 50100 "IMS Industry Type" implements "IMS Industry Handler"
{
    Extensible = true;
    Caption = 'Industry Type';
    DefaultImplementation = "IMS Industry Handler" = "IMS General Industry";

    value(0; General)
    {
        Caption = 'General';
        Implementation = "IMS Industry Handler" = "IMS General Industry";
    }
    value(1; Retail)
    {
        Caption = 'Retail & Wholesale';
        Implementation = "IMS Industry Handler" = "IMS Retail Industry";
    }
    value(2; Pharmaceutical)
    {
        Caption = 'Pharmaceutical & Healthcare';
        Implementation = "IMS Industry Handler" = "IMS Pharma Industry";
    }
    value(3; "Food & Beverage")
    {
        Caption = 'Food & Beverage';
        Implementation = "IMS Industry Handler" = "IMS Food Bev Industry";
    }
    value(4; Manufacturing)
    {
        Caption = 'Manufacturing';
        Implementation = "IMS Industry Handler" = "IMS Manufacturing Industry";
    }
    value(5; Construction)
    {
        Caption = 'Construction & Hardware';
        Implementation = "IMS Industry Handler" = "IMS Construction Industry";
    }
}
