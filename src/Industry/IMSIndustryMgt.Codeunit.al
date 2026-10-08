/// <summary>
/// Resolves the industry profile and the industry handler (interface implementation) for an item.
/// </summary>
codeunit 50101 "IMS Industry Mgt."
{
    procedure GetProfile(Item: Record "IMS Item"; var IndustryProfile: Record "IMS Industry Profile")
    begin
        Clear(IndustryProfile);
        if Item."Industry Profile Code" <> '' then
            IndustryProfile.Get(Item."Industry Profile Code");
    end;

    procedure GetProfileAndHandler(Item: Record "IMS Item"; var IndustryProfile: Record "IMS Industry Profile"; var IndustryHandler: Interface "IMS Industry Handler")
    begin
        GetProfile(Item, IndustryProfile);
        IndustryHandler := IndustryProfile."Industry Type";
        OnAfterGetProfileAndHandler(Item, IndustryProfile, IndustryHandler);
    end;

    /// <summary>Lets a subscriber swap the handler, e.g. per customer or per location, without changing the enum.</summary>
    [IntegrationEvent(false, false)]
    local procedure OnAfterGetProfileAndHandler(Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile"; var IndustryHandler: Interface "IMS Industry Handler")
    begin
    end;
}
