/// <summary>
/// REST: /api/ims/inventory/v1.0/companies({id})/journalLines
/// Integrations (POS, WMS scanners, e-commerce, MES) create lines here and call the bound action
/// .../journalLines({id})/Microsoft.NAV.post to post the whole batch the line belongs to.
/// </summary>
page 50133 "IMS API Journal Lines"
{
    PageType = API;
    APIPublisher = 'ims';
    APIGroup = 'inventory';
    APIVersion = 'v1.0';
    EntityName = 'journalLine';
    EntitySetName = 'journalLines';
    EntityCaption = 'Journal Line';
    EntitySetCaption = 'Journal Lines';
    SourceTable = "IMS Item Journal Line";
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(journalBatchName; Rec."Journal Batch Name") { Caption = 'Journal Batch Name'; }
                field(lineNumber; Rec."Line No.") { Caption = 'Line No.'; }
                field(entryType; Rec."Entry Type") { Caption = 'Entry Type'; }
                field(postingDate; Rec."Posting Date") { Caption = 'Posting Date'; }
                field(documentNumber; Rec."Document No.") { Caption = 'Document No.'; }
                field(externalDocumentNumber; Rec."External Document No.") { Caption = 'External Document No.'; }
                field(itemNumber; Rec."Item No.") { Caption = 'Item No.'; }
                field(variantCode; Rec."Variant Code") { Caption = 'Variant Code'; }
                field(locationCode; Rec."Location Code") { Caption = 'Location Code'; }
                field(binCode; Rec."Bin Code") { Caption = 'Bin Code'; }
                field(newLocationCode; Rec."New Location Code") { Caption = 'New Location Code'; }
                field(newBinCode; Rec."New Bin Code") { Caption = 'New Bin Code'; }
                field(unitOfMeasureCode; Rec."Unit of Measure Code") { Caption = 'Unit of Measure Code'; }
                field(quantity; Rec.Quantity) { Caption = 'Quantity'; }
                field(unitCost; Rec."Unit Cost") { Caption = 'Unit Cost'; }
                field(lotNumber; Rec."Lot No.") { Caption = 'Lot No.'; }
                field(serialNumber; Rec."Serial No.") { Caption = 'Serial No.'; }
                field(expirationDate; Rec."Expiration Date") { Caption = 'Expiration Date'; }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        LastItemJnlLine: Record "IMS Item Journal Line";
    begin
        if Rec."Line No." = 0 then begin
            LastItemJnlLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
            if LastItemJnlLine.FindLast() then;
            Rec."Line No." := LastItemJnlLine."Line No." + 10000;
        end;
        if Rec."Posting Date" = 0D then
            Rec."Posting Date" := WorkDate();
        Rec.Insert(true);
        exit(false);
    end;

    [ServiceEnabled]
    procedure Post(var ActionContext: WebServiceActionContext)
    var
        ItemJnlPostBatch: Codeunit "IMS Item Jnl.-Post Batch";
    begin
        ItemJnlPostBatch.PostBatch(Rec."Journal Batch Name");
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"IMS API Journal Lines");
        ActionContext.SetResultCode(WebServiceActionResultCode::Deleted);
    end;
}
