/// <summary>
/// Upgrade entry point. Add one guarded step per schema/data change, protected by an upgrade tag,
/// so upgrades are idempotent and can be rolled out to many tenants safely.
/// </summary>
codeunit 50109 "IMS Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        ImsInstall: Codeunit "IMS Install";
    begin
        // Re-seeding is idempotent: only missing records are inserted (e.g. new industry profiles).
        ImsInstall.InitializeCompany();
    end;
}
