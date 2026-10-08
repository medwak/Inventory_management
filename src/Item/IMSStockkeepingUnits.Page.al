page 50119 "IMS Stockkeeping Units"
{
    Caption = 'Stockkeeping Units';
    PageType = List;
    SourceTable = "IMS Stockkeeping Unit";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(SKUs)
            {
                field("Item No."; Rec."Item No.") { ToolTip = 'Specifies the item. Replenishment values are copied from the item.'; }
                field("Variant Code"; Rec."Variant Code") { ToolTip = 'Specifies the variant.'; }
                field("Location Code"; Rec."Location Code") { ToolTip = 'Specifies the location.'; }
                field(Inventory; Rec.Inventory) { ToolTip = 'Specifies the quantity on hand at the location.'; }
                field("Replenishment Policy"; Rec."Replenishment Policy") { ToolTip = 'Specifies the replenishment policy at this location.'; }
                field("Reorder Point"; Rec."Reorder Point") { ToolTip = 'Specifies the reorder point at this location.'; }
                field("Reorder Quantity"; Rec."Reorder Quantity") { ToolTip = 'Specifies the reorder quantity at this location.'; }
                field("Maximum Inventory"; Rec."Maximum Inventory") { ToolTip = 'Specifies the maximum inventory at this location.'; }
                field("Safety Stock Quantity"; Rec."Safety Stock Quantity") { ToolTip = 'Specifies the safety stock at this location.'; }
                field("Lead Time Calculation"; Rec."Lead Time Calculation") { ToolTip = 'Specifies the lead time to this location.'; }
            }
        }
    }
}
