# Multi-Industry Inventory Management (Business Central / NAV AL extension)

An inventory management system built as a **Microsoft Dynamics 365 Business Central**
extension (the AL successor of Microsoft Dynamics NAV / Navision) using classic NAV design
patterns: **master data → journal → check → post → immutable ledger entries**, SIFT‑indexed
FlowFields, number series, registers, integration events and permission sets.

It is designed to **scale** (many items, locations, users and tenants) and to serve **many
industries** from one code base. Industry behaviour is plugged in through an **extensible
enum + interface**, and configured per **Industry Profile**.

| Industry | What is enforced |
|---|---|
| General | Purely configuration driven |
| Retail & Wholesale | Valid GTIN/EAN barcode mandatory (check digit validated), variants (size/colour) |
| Pharmaceutical | Lot + expiry mandatory, new lots **quarantined** until QA release, **FEFO** enforced, expired stock can only be scrapped, sales need an external reference (order / prescription) |
| Food & Beverage | Lot + expiry mandatory, **FEFO**, expired lots never issued, minimum remaining shelf life on sale |
| Manufacturing | Consumption/output must reference a production order; standard costing by default |
| Construction & Hardware | Bulk units (bag, tonne, m³), consumption must reference a project/site |

New industries (e.g. Automotive, Electronics, Agriculture) are added **without changing this app** – see
[docs/EXTENDING.md](docs/EXTENDING.md).

## Features

- **Item master**: categories (hierarchical), variants, multiple units of measure with conversion,
  GTIN, typed **attributes** per industry (text/number/date/boolean/option, optionally mandatory).
- **Multi-location & bins**: warehouses, stores, sites, cold rooms; bin-mandatory locations.
- **Item tracking**: lot and/or serial numbers, expiration dates, lot status
  (Available / Quarantine / Blocked) with audit of who changed it, full lot traceability.
- **Movements** via the item journal: Purchase, Sale, Positive/Negative Adjustment, Transfer,
  Consumption, Output. Lots and serials are **picked automatically** (FIFO/FEFO/LIFO) when not
  specified, and the issue is split per lot.
- **Costing**: Actual (applied layers), Average, Standard. Item application entries record which
  receipt each issue consumed.
- **Replenishment**: reorder point / fixed reorder quantity / maximum quantity, safety stock,
  lead time, per location & variant via Stockkeeping Units; worksheet → journal lines.
- **Expiry management**: expiring-soon view, nightly Job Queue task that blocks expired lots.
- **APIs** (OData v4 / REST) for items, locations, ledger entries, journal lines (+ `post` action)
  and an aggregated `inventoryByLocation` query for Power BI.
- **Security**: READ / EDIT / ADMIN permission sets; ledgers writable only through posting code.
- **Tests**: separate test app covering posting, costing, FEFO, quarantine, industry rules and planning.

## Repository layout

```
app.json                      Main extension manifest (object IDs 50100-50149)
src/
  Enums/                      Entry type, tracking type, costing, picking, lot status, ...
  Industry/                   Industry interface, enum, profile table, per-industry codeunits
  Setup/                      Setup table + page
  Item/                       Item, category, variant, UoM, attributes, SKU (+ pages)
  Location/                   Location, bin
  Tracking/                   Lot information, expiry management
  Journal/                    Journal batch / line / page
  Posting/                    Check line, post line, post batch, UI wrapper
  Ledger/                     Item ledger, application entries, registers
  Replenishment/              Planning engine + worksheet
  API/                        API pages and API query
  Install/                    Install & upgrade codeunits (seed data)
  Permissions/                Permission sets
test/                         Test app (IDs 50150-50169)
docs/                         Architecture and extension guide
```

## Getting started

1. Install the **AL Language** extension in VS Code and create a Business Central sandbox (v24 or later).
2. Open the folder, update `.vscode/launch.json` with your environment, run **AL: Download Symbols**.
3. Press **F5** to publish. The install codeunit seeds setup, units of measure, location `MAIN`,
   journal batch `DEFAULT` and one industry profile per industry.
4. Open **Inventory Management Setup**, assign an Item No. series, then create items on the
   **Items** page, choosing an Industry Profile – defaults for tracking, expiry, costing and picking are applied.
5. Post receipts/issues/transfers in the **Item Journal** (F9 to post).
6. Assign the **IMS - EDIT** permission set to users (IMS - ADMIN for administrators).

To run the tests, publish the app in `test/` as well and run codeunit 50150 with the AL Test Runner.

## Documentation

- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) – design, data model, posting flow, scalability.
- [docs/EXTENDING.md](docs/EXTENDING.md) – adding an industry, events, APIs.
