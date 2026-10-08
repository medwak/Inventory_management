/// <summary>Seeds setup, units of measure, a location, a journal batch and one profile per industry.</summary>
codeunit 50100 "IMS Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        InitializeCompany();
    end;

    procedure InitializeCompany()
    var
        ImsSetup: Record "IMS Setup";
    begin
        ImsSetup.InsertIfNotExists();

        InsertUnitOfMeasure('PCS', 'Piece');
        InsertUnitOfMeasure('BOX', 'Box');
        InsertUnitOfMeasure('KG', 'Kilogram');
        InsertUnitOfMeasure('L', 'Litre');
        InsertUnitOfMeasure('M', 'Metre');
        InsertUnitOfMeasure('BAG', 'Bag');
        InsertUnitOfMeasure('TABLET', 'Tablet');

        InsertProfile('GENERAL', 'General goods', "IMS Industry Type"::General, "IMS Item Tracking Type"::None, false, '', "IMS Costing Method"::Average, "IMS Picking Strategy"::FIFO, false, '', false, 'PCS', false);
        InsertProfile('RETAIL', 'Retail & wholesale', "IMS Industry Type"::Retail, "IMS Item Tracking Type"::None, false, '', "IMS Costing Method"::Average, "IMS Picking Strategy"::FIFO, false, '', true, 'PCS', false);
        InsertProfile('PHARMA', 'Pharmaceuticals', "IMS Industry Type"::Pharmaceutical, "IMS Item Tracking Type"::Lot, true, '<2Y>', "IMS Costing Method"::Actual, "IMS Picking Strategy"::FEFO, true, '<90D>', true, 'TABLET', true);
        InsertProfile('FOODBEV', 'Food & beverage', "IMS Industry Type"::"Food & Beverage", "IMS Item Tracking Type"::Lot, true, '<30D>', "IMS Costing Method"::Actual, "IMS Picking Strategy"::FEFO, true, '<7D>', true, 'PCS', false);
        InsertProfile('MANUFACT', 'Manufacturing materials', "IMS Industry Type"::Manufacturing, "IMS Item Tracking Type"::Lot, false, '', "IMS Costing Method"::Standard, "IMS Picking Strategy"::FIFO, false, '', false, 'PCS', false);
        InsertProfile('CONSTRUCT', 'Construction & hardware', "IMS Industry Type"::Construction, "IMS Item Tracking Type"::None, false, '', "IMS Costing Method"::Average, "IMS Picking Strategy"::FIFO, false, '', false, 'BAG', false);

        InsertLocation('MAIN', 'Main warehouse');
        InsertJournalBatch('DEFAULT', 'Default journal');

        ImsSetup.Get();
        if ImsSetup."Default Industry Profile" = '' then
            ImsSetup."Default Industry Profile" := 'GENERAL';
        if ImsSetup."Default Location Code" = '' then
            ImsSetup."Default Location Code" := 'MAIN';
        if Format(ImsSetup."Expiry Warning Period") = '' then
            Evaluate(ImsSetup."Expiry Warning Period", '<30D>');
        ImsSetup.Modify();
    end;

    local procedure InsertUnitOfMeasure(UoMCode: Code[10]; Description: Text[50])
    var
        UnitOfMeasure: Record "IMS Unit of Measure";
    begin
        if UnitOfMeasure.Get(UoMCode) then
            exit;
        UnitOfMeasure.Code := UoMCode;
        UnitOfMeasure.Description := Description;
        UnitOfMeasure.Insert();
    end;

    local procedure InsertProfile(ProfileCode: Code[20]; Description: Text[100]; IndustryType: Enum "IMS Industry Type"; TrackingType: Enum "IMS Item Tracking Type"; ExpiryRequired: Boolean; ShelfLife: Text; CostingMethod: Enum "IMS Costing Method"; PickingStrategy: Enum "IMS Picking Strategy"; BlockExpired: Boolean; MinShelfLifeOnSale: Text; GTINRequired: Boolean; BaseUoM: Code[10]; QuarantineOnReceipt: Boolean)
    var
        IndustryProfile: Record "IMS Industry Profile";
    begin
        if IndustryProfile.Get(ProfileCode) then
            exit;
        IndustryProfile.Init();
        IndustryProfile.Code := ProfileCode;
        IndustryProfile.Description := Description;
        IndustryProfile."Industry Type" := IndustryType;
        IndustryProfile."Default Tracking Type" := TrackingType;
        IndustryProfile."Expiration Date Required" := ExpiryRequired;
        if ShelfLife <> '' then
            Evaluate(IndustryProfile."Default Shelf Life", ShelfLife);
        IndustryProfile."Default Costing Method" := CostingMethod;
        IndustryProfile."Default Picking Strategy" := PickingStrategy;
        IndustryProfile."Block Expired Stock" := BlockExpired;
        if MinShelfLifeOnSale <> '' then
            Evaluate(IndustryProfile."Min. Shelf Life on Sale", MinShelfLifeOnSale);
        IndustryProfile."GTIN Required" := GTINRequired;
        IndustryProfile."Default Base Unit of Measure" := BaseUoM;
        IndustryProfile."Quarantine on Receipt" := QuarantineOnReceipt;
        IndustryProfile.Insert();
    end;

    local procedure InsertLocation(LocationCode: Code[10]; Name: Text[100])
    var
        Location: Record "IMS Location";
    begin
        if Location.Get(LocationCode) then
            exit;
        Location.Code := LocationCode;
        Location.Name := Name;
        Location.Insert();
    end;

    local procedure InsertJournalBatch(BatchName: Code[10]; Description: Text[100])
    var
        ItemJnlBatch: Record "IMS Item Journal Batch";
    begin
        if ItemJnlBatch.Get(BatchName) then
            exit;
        ItemJnlBatch.Name := BatchName;
        ItemJnlBatch.Description := Description;
        ItemJnlBatch.Insert();
    end;
}
