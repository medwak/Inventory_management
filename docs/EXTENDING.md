# Extending the system

## Add a new industry (no change to this app)

Create a dependent extension:

```al
enumextension 50200 "AUTO Industry Type" extends "IMS Industry Type"
{
    value(50200; Automotive)
    {
        Caption = 'Automotive Parts';
        Implementation = "IMS Industry Handler" = "AUTO Automotive Industry";
    }
}

/// Automotive: serialized parts (VIN / part serial), FIFO, core returns need a reference.
codeunit 50200 "AUTO Automotive Industry" implements "IMS Industry Handler"
{
    var
        BaseRules: Codeunit "IMS Industry Base Rules";

    procedure InitItemDefaults(var Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile")
    begin
        BaseRules.InitItemDefaults(Item, IndustryProfile);
        Item."Item Tracking Type" := Item."Item Tracking Type"::Serial;
    end;

    procedure ValidateItem(Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile")
    begin
        BaseRules.ValidateItem(Item, IndustryProfile);
    end;

    procedure CheckJournalLine(ItemJnlLine: Record "IMS Item Journal Line"; Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile")
    begin
        BaseRules.CheckJournalLine(ItemJnlLine, Item, IndustryProfile);
        if ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::"Positive Adjmt." then
            ItemJnlLine.TestField("External Document No."); // core return reference
    end;

    procedure GetPickingStrategy(Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile"): Enum "IMS Picking Strategy"
    begin
        exit("IMS Picking Strategy"::FIFO);
    end;

    procedure CanIssueFromLot(Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile"; LotNoInfo: Record "IMS Lot No. Information"; PostingDate: Date; EntryType: Enum "IMS Entry Type"): Boolean
    begin
        exit(BaseRules.CanIssueFromLot(Item, IndustryProfile, LotNoInfo, PostingDate, EntryType));
    end;

    procedure GetInitialLotStatus(Item: Record "IMS Item"; IndustryProfile: Record "IMS Industry Profile"): Enum "IMS Lot Status"
    begin
        exit(BaseRules.GetInitialLotStatus(Item, IndustryProfile));
    end;
}
```

Then create an Industry Profile with *Industry Type = Automotive Parts* and assign it to items.
Many variations need **no code at all** – just another profile (e.g. `PHARMA-OTC` without
quarantine, `FOOD-FROZEN` with a 365-day shelf life, `RETAIL-FASHION` with variants).

## Industry-specific item data

Use **Attributes** (`IMS Attribute`) scoped to a profile, e.g.

| Profile | Attribute | Type | Mandatory |
|---|---|---|---|
| PHARMA | ACTIVE-INGR (Active ingredient) | Text | yes |
| PHARMA | STORAGE-TEMP (°C) | Decimal | yes |
| FOODBEV | ALLERGENS | Text | no |
| RETAIL | SIZE | Option (`XS,S,M,L,XL`) | no |
| CONSTRUCT | GRADE | Option (`C20,C25,C30`) | yes |

Mandatory attributes are enforced before an item can be posted. For structured data that
needs its own logic, use a `tableextension` on `IMS Item`.

## Integration events

| Publisher | Event | Typical use |
|---|---|---|
| IMS Industry Mgt. | `OnAfterGetProfileAndHandler` | Swap the handler per customer/location |
| IMS Item Jnl.-Check Line | `OnBeforeRunCheck`, `OnAfterRunCheck` | Extra validations (e.g. temperature-controlled location for cold-chain items) |
| IMS Item Jnl.-Post Line | `OnBeforePostLine`, `OnAfterPostLine` | Post to G/L, send notifications |
| | `OnAfterInsertItemLedgerEntry` | Sync to external WMS / data lake |
| | `OnBeforeInsertOutboundEntry` | Custom costing |
| | `OnBeforeInsertLotNoInfo` | Default vendor lot / certificate |
| | `OnAllocateFromOpenLayersOnAfterSetFilters` | Restrict which stock may be picked (e.g. by bin zone) |
| IMS Item Jnl.-Post Batch | `OnBeforePostBatch`, `OnAfterPostBatch` | Approvals, auditing |
| IMS Replenishment Mgt. | `OnAfterCalcSuggestedQty` | Rounding to pack size, MOQ |

## APIs

Base URL: `https://api.businesscentral.dynamics.com/v2.0/{tenant}/{environment}/api/ims/inventory/v1.0/companies({companyId})/`

| Entity set | Methods |
|---|---|
| `items` | GET, POST, PATCH, DELETE |
| `locations` | GET, POST, PATCH, DELETE |
| `itemLedgerEntries` | GET (read-only replica) |
| `journalLines` | GET, POST, PATCH, DELETE; `POST journalLines({id})/Microsoft.NAV.post` posts the line's batch |
| `inventoryByLocation` | GET (aggregated quantity & value per item/variant/location/lot) |

Example – receive a lot from a scanner:

```http
POST .../journalLines
{
  "journalBatchName": "WMS",
  "entryType": "Purchase",
  "documentNumber": "GRN-1001",
  "itemNumber": "PARA-500",
  "locationCode": "MAIN",
  "quantity": 1200,
  "unitCost": 0.02,
  "lotNumber": "B2026-117",
  "expirationDate": "2028-09-30"
}
```
