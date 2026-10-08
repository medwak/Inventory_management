page 50112 "IMS Item Attribute Values"
{
    Caption = 'Item Attribute Values';
    PageType = ListPart;
    SourceTable = "IMS Item Attribute Value";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Values)
            {
                field("Attribute Code"; Rec."Attribute Code") { ToolTip = 'Specifies the attribute.'; }
                field("Attribute Name"; Rec."Attribute Name") { ToolTip = 'Specifies the attribute name.'; }
                field("Attribute Type"; Rec."Attribute Type") { ToolTip = 'Specifies the attribute data type.'; }
                field(Value; Rec.Value) { ToolTip = 'Specifies the value. It is validated against the attribute type.'; }
            }
        }
    }
}
