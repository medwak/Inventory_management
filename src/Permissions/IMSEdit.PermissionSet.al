/// <summary>
/// Day-to-day users: maintain master data and post journals. Ledger tables are granted
/// indirectly (lowercase) so they can only be written through the posting codeunits.
/// </summary>
permissionset 50101 "IMS - EDIT"
{
    Assignable = true;
    Caption = 'Inventory Mgt. - Edit & Post';
    IncludedPermissionSets = "IMS - READ";
    Permissions =
        tabledata "IMS Item" = RIMD,
        tabledata "IMS Item Category" = RIMD,
        tabledata "IMS Item Variant" = RIMD,
        tabledata "IMS Unit of Measure" = RIMD,
        tabledata "IMS Item Unit of Measure" = RIMD,
        tabledata "IMS Location" = RIMD,
        tabledata "IMS Bin" = RIMD,
        tabledata "IMS Attribute" = RIMD,
        tabledata "IMS Item Attribute Value" = RIMD,
        tabledata "IMS Stockkeeping Unit" = RIMD,
        tabledata "IMS Lot No. Information" = RIMD,
        tabledata "IMS Item Journal Line" = RIMD,
        tabledata "IMS Item Journal Batch" = RIMD,
        tabledata "IMS Replenishment Line" = RIMD,
        tabledata "IMS Item Ledger Entry" = Rim,
        tabledata "IMS Item Application Entry" = Rim,
        tabledata "IMS Register" = Rim,
        tabledata "IMS Setup" = R,
        tabledata "IMS Industry Profile" = R;
}
