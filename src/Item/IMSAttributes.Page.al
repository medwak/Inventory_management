page 50111 "IMS Attributes"
{
    Caption = 'Item Attributes';
    PageType = List;
    SourceTable = "IMS Attribute";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Attributes)
            {
                field("Code"; Rec."Code") { ToolTip = 'Specifies the attribute code.'; }
                field(Name; Rec.Name) { ToolTip = 'Specifies the attribute name.'; }
                field(Type; Rec.Type) { ToolTip = 'Specifies the data type used to validate values.'; }
                field("Option Values"; Rec."Option Values") { ToolTip = 'Specifies the comma separated list of allowed values for Option attributes.'; }
                field("Unit of Measure"; Rec."Unit of Measure") { ToolTip = 'Specifies the unit the value is expressed in, e.g. °C or mg.'; }
                field("Industry Profile Code"; Rec."Industry Profile Code") { ToolTip = 'Specifies the industry profile the attribute applies to. Blank applies to all.'; }
                field(Mandatory; Rec.Mandatory) { ToolTip = 'Specifies whether items of the profile cannot be posted without a value.'; }
                field(Blocked; Rec.Blocked) { ToolTip = 'Specifies whether the attribute is blocked.'; }
            }
        }
    }
}
