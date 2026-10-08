page 50117 "IMS Item Application Entries"
{
    Caption = 'Item Application Entries';
    PageType = List;
    SourceTable = "IMS Item Application Entry";
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Entries)
            {
                field("Entry No."; Rec."Entry No.") { ToolTip = 'Specifies the entry number.'; }
                field("Posting Date"; Rec."Posting Date") { ToolTip = 'Specifies the posting date.'; }
                field("Inbound Item Entry No."; Rec."Inbound Item Entry No.") { ToolTip = 'Specifies the receipt (stock layer) that was consumed.'; }
                field("Outbound Item Entry No."; Rec."Outbound Item Entry No.") { ToolTip = 'Specifies the issue that consumed it.'; }
                field(Quantity; Rec.Quantity) { ToolTip = 'Specifies the quantity applied.'; }
                field("Cost Amount"; Rec."Cost Amount") { ToolTip = 'Specifies the layer cost of the applied quantity.'; }
            }
        }
    }
}
