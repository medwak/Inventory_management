page 50106 "IMS Item Variants"
{
    Caption = 'Item Variants';
    PageType = List;
    SourceTable = "IMS Item Variant";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Variants)
            {
                field("Item No."; Rec."Item No.") { ToolTip = 'Specifies the item.'; Visible = false; }
                field("Code"; Rec."Code") { ToolTip = 'Specifies the variant code.'; }
                field(Description; Rec.Description) { ToolTip = 'Specifies the variant description.'; }
                field(Blocked; Rec.Blocked) { ToolTip = 'Specifies whether the variant is blocked.'; }
            }
        }
    }
}
