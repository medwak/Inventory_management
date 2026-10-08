page 50108 "IMS Item Units of Measure"
{
    Caption = 'Item Units of Measure';
    PageType = List;
    SourceTable = "IMS Item Unit of Measure";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Units)
            {
                field("Item No."; Rec."Item No.") { ToolTip = 'Specifies the item.'; Visible = false; }
                field("Code"; Rec."Code") { ToolTip = 'Specifies the unit of measure.'; }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure") { ToolTip = 'Specifies how many base units one unit contains, e.g. 12 for a box of 12.'; }
            }
        }
    }
}
