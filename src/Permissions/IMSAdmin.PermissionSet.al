/// <summary>Administrators: additionally maintain setup and industry profiles.</summary>
permissionset 50102 "IMS - ADMIN"
{
    Assignable = true;
    Caption = 'Inventory Mgt. - Admin';
    IncludedPermissionSets = "IMS - EDIT";
    Permissions =
        tabledata "IMS Setup" = RIMD,
        tabledata "IMS Industry Profile" = RIMD;
}
