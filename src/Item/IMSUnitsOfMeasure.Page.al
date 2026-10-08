page 50107 "IMS Units of Measure"
{
    Caption = 'Units of Measure';
    PageType = List;
    SourceTable = "IMS Unit of Measure";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Units)
            {
                field("Code"; Rec."Code") { ToolTip = 'Specifies the unit of measure code.'; }
                field(Description; Rec.Description) { ToolTip = 'Specifies the unit of measure description.'; }
            }
        }
    }
}
