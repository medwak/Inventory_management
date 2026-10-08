page 50103 "IMS Item Categories"
{
    Caption = 'Item Categories';
    PageType = List;
    SourceTable = "IMS Item Category";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Categories)
            {
                field("Code"; Rec."Code") { ToolTip = 'Specifies the category code.'; }
                field(Description; Rec.Description) { ToolTip = 'Specifies the category description.'; }
                field("Parent Category"; Rec."Parent Category") { ToolTip = 'Specifies the parent category, which allows a category hierarchy.'; }
                field("Industry Profile Code"; Rec."Industry Profile Code") { ToolTip = 'Specifies the industry profile the category belongs to.'; }
            }
        }
    }
}
