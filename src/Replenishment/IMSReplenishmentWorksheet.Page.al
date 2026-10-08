page 50120 "IMS Replenishment Worksheet"
{
    Caption = 'Replenishment Worksheet';
    PageType = Worksheet;
    SourceTable = "IMS Replenishment Line";
    UsageCategory = Tasks;
    ApplicationArea = All;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Accept Suggestion"; Rec."Accept Suggestion") { ToolTip = 'Specifies whether the suggestion is carried out.'; }
                field("Item No."; Rec."Item No.") { ToolTip = 'Specifies the item.'; Editable = false; }
                field("Variant Code"; Rec."Variant Code") { ToolTip = 'Specifies the variant.'; Editable = false; }
                field(Description; Rec.Description) { ToolTip = 'Specifies the description.'; Editable = false; }
                field("Location Code"; Rec."Location Code") { ToolTip = 'Specifies the location to replenish.'; }
                field("Replenishment Policy"; Rec."Replenishment Policy") { ToolTip = 'Specifies the policy used.'; }
                field("Current Inventory"; Rec."Current Inventory") { ToolTip = 'Specifies the quantity on hand.'; }
                field("Reorder Point"; Rec."Reorder Point") { ToolTip = 'Specifies the reorder point.'; }
                field("Safety Stock Quantity"; Rec."Safety Stock Quantity") { ToolTip = 'Specifies the safety stock.'; }
                field("Maximum Inventory"; Rec."Maximum Inventory") { ToolTip = 'Specifies the maximum inventory.'; }
                field("Suggested Quantity"; Rec."Suggested Quantity") { ToolTip = 'Specifies the quantity to order (base units). You can change it.'; }
                field("Due Date"; Rec."Due Date") { ToolTip = 'Specifies when the stock is needed (today + lead time).'; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CalculatePlan)
            {
                Caption = 'Calculate Plan';
                Image = CalculatePlan;
                ToolTip = 'Calculate replenishment suggestions for all items with a replenishment policy.';

                trigger OnAction()
                var
                    Item: Record "IMS Item";
                    ReplenishmentMgt: Codeunit "IMS Replenishment Mgt.";
                begin
                    Message(PlanCalculatedMsg, ReplenishmentMgt.CalculatePlan(Item, ''));
                    CurrPage.Update(false);
                end;
            }
            action(CarryOut)
            {
                Caption = 'Carry Out (Create Journal Lines)';
                Image = CarryOutActionMessage;
                ToolTip = 'Create purchase lines in an item journal batch for the accepted suggestions.';

                trigger OnAction()
                var
                    ItemJnlBatch: Record "IMS Item Journal Batch";
                    ReplenishmentMgt: Codeunit "IMS Replenishment Mgt.";
                begin
                    if Page.RunModal(Page::"IMS Item Journal Batches", ItemJnlBatch) <> Action::LookupOK then
                        exit;
                    Message(CarriedOutMsg, ReplenishmentMgt.CarryOut(ItemJnlBatch.Name), ItemJnlBatch.Name);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            actionref(CalculatePlan_Promoted; CalculatePlan) { }
            actionref(CarryOut_Promoted; CarryOut) { }
        }
    }

    var
        PlanCalculatedMsg: Label '%1 replenishment suggestion(s) were created.', Comment = '%1 = Count';
        CarriedOutMsg: Label '%1 journal line(s) were created in batch %2.', Comment = '%1 = Count, %2 = Batch';

    trigger OnOpenPage()
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("User ID", UserId());
        Rec.FilterGroup(0);
    end;
}
