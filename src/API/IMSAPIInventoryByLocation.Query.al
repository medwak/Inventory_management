/// <summary>
/// REST (aggregated, read-only replica): /api/ims/inventory/v1.0/companies({id})/inventoryByLocation
/// Stock and value per item / variant / location / lot, computed by SQL from the SIFT-indexed ledger.
/// Suitable for Power BI and dashboards without loading individual entries.
/// </summary>
query 50100 "IMS API Inventory by Location"
{
    QueryType = API;
    APIPublisher = 'ims';
    APIGroup = 'inventory';
    APIVersion = 'v1.0';
    EntityName = 'inventoryByLocation';
    EntitySetName = 'inventoryByLocation';
    Caption = 'Inventory by Location';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(ItemLedgerEntry; "IMS Item Ledger Entry")
        {
            column(itemNumber; "Item No.") { }
            column(variantCode; "Variant Code") { }
            column(locationCode; "Location Code") { }
            column(lotNumber; "Lot No.") { }
            column(expirationDate; "Expiration Date") { }
            column(quantity; Quantity)
            {
                Method = Sum;
            }
            column(costAmount; "Cost Amount")
            {
                Method = Sum;
            }
        }
    }
}
