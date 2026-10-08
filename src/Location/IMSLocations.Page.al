page 50109 "IMS Locations"
{
    Caption = 'Locations';
    PageType = List;
    SourceTable = "IMS Location";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Locations)
            {
                field("Code"; Rec."Code") { ToolTip = 'Specifies the location code (warehouse, store, site, cold room...).'; }
                field(Name; Rec.Name) { ToolTip = 'Specifies the location name.'; }
                field(Address; Rec.Address) { ToolTip = 'Specifies the address.'; }
                field(City; Rec.City) { ToolTip = 'Specifies the city.'; }
                field("Country/Region Code"; Rec."Country/Region Code") { ToolTip = 'Specifies the country/region.'; }
                field("Bin Mandatory"; Rec."Bin Mandatory") { ToolTip = 'Specifies whether every movement at this location must specify a bin.'; }
                field("Temperature Controlled"; Rec."Temperature Controlled") { ToolTip = 'Specifies whether the location is temperature controlled.'; }
                field(Blocked; Rec.Blocked) { ToolTip = 'Specifies whether the location is blocked.'; }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Bins)
            {
                Caption = 'Bins';
                Image = Bins;
                RunObject = page "IMS Bins";
                RunPageLink = "Location Code" = field(Code);
                ToolTip = 'Set up the bins (shelves, racks, zones) of the location.';
            }
        }
        area(Promoted)
        {
            actionref(Bins_Promoted; Bins) { }
        }
    }
}
