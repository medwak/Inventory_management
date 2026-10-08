page 50100 "IMS Setup"
{
    Caption = 'Inventory Management Setup';
    PageType = Card;
    SourceTable = "IMS Setup";
    UsageCategory = Administration;
    ApplicationArea = All;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Default Industry Profile"; Rec."Default Industry Profile")
                {
                    ToolTip = 'Specifies the industry profile assigned to new items when none is given.';
                }
                field("Default Location Code"; Rec."Default Location Code")
                {
                    ToolTip = 'Specifies the location used on new journal lines and for item-level replenishment.';
                }
                field("Enable Posting Telemetry"; Rec."Enable Posting Telemetry")
                {
                    ToolTip = 'Specifies whether batch posting statistics are sent to Application Insights.';
                }
            }
            group(Numbering)
            {
                Caption = 'Numbering';
                field("Item Nos."; Rec."Item Nos.")
                {
                    ToolTip = 'Specifies the number series used for new items.';
                }
            }
            group(Expiry)
            {
                Caption = 'Expiry';
                field("Expiry Warning Period"; Rec."Expiry Warning Period")
                {
                    ToolTip = 'Specifies how far ahead lots are reported as expiring, for example 30D.';
                }
                field("Block Expired Lots (Job)"; Rec."Block Expired Lots (Job)")
                {
                    ToolTip = 'Specifies whether the scheduled expiry job blocks lots whose expiration date has passed.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.InsertIfNotExists();
    end;
}
