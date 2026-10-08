page 50101 "IMS Industry Profiles"
{
    Caption = 'Industry Profiles';
    PageType = List;
    SourceTable = "IMS Industry Profile";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Profiles)
            {
                field("Code"; Rec."Code") { ToolTip = 'Specifies the code of the industry profile.'; }
                field(Description; Rec.Description) { ToolTip = 'Specifies a description of the profile.'; }
                field("Industry Type"; Rec."Industry Type") { ToolTip = 'Specifies which industry rule set (code) is applied to items of this profile.'; }
                field("Default Tracking Type"; Rec."Default Tracking Type") { ToolTip = 'Specifies the item tracking assigned to new items.'; }
                field("Expiration Date Required"; Rec."Expiration Date Required") { ToolTip = 'Specifies whether new items require expiration dates on receipt.'; }
                field("Default Shelf Life"; Rec."Default Shelf Life") { ToolTip = 'Specifies the shelf life used to calculate expiration dates when none is entered.'; }
                field("Default Costing Method"; Rec."Default Costing Method") { ToolTip = 'Specifies the costing method assigned to new items.'; }
                field("Default Picking Strategy"; Rec."Default Picking Strategy") { ToolTip = 'Specifies the order in which stock is consumed for new items.'; }
                field("Block Expired Stock"; Rec."Block Expired Stock") { ToolTip = 'Specifies whether expired lots are excluded from issues (scrapping by negative adjustment is still allowed).'; }
                field("Min. Shelf Life on Sale"; Rec."Min. Shelf Life on Sale") { ToolTip = 'Specifies the minimum remaining shelf life a lot must have to be sold, for example 14D.'; }
                field("GTIN Required"; Rec."GTIN Required") { ToolTip = 'Specifies whether items must have a valid GTIN/barcode.'; }
                field("Quarantine on Receipt"; Rec."Quarantine on Receipt") { ToolTip = 'Specifies whether new lots start in quarantine and must be released before they can be sold.'; }
                field("Default Base Unit of Measure"; Rec."Default Base Unit of Measure") { ToolTip = 'Specifies the base unit of measure assigned to new items.'; }
                field("No. of Items"; Rec."No. of Items") { ToolTip = 'Specifies how many items use this profile.'; }
            }
        }
    }
}
