page 50110 "IMS Bins"
{
    Caption = 'Bins';
    PageType = List;
    SourceTable = "IMS Bin";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Bins)
            {
                field("Location Code"; Rec."Location Code") { ToolTip = 'Specifies the location.'; }
                field("Code"; Rec."Code") { ToolTip = 'Specifies the bin code.'; }
                field(Description; Rec.Description) { ToolTip = 'Specifies the bin description.'; }
                field(Inventory; Rec.Inventory) { ToolTip = 'Specifies the quantity in the bin (all items, base units).'; }
                field(Blocked; Rec.Blocked) { ToolTip = 'Specifies whether the bin is blocked.'; }
            }
        }
    }
}
