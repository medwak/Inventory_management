enum 50104 "IMS Replenishment Policy"
{
    Extensible = true;
    Caption = 'Replenishment Policy';

    value(0; Manual) { Caption = 'Manual'; }
    value(1; "Fixed Reorder Qty.") { Caption = 'Fixed Reorder Qty.'; }
    value(2; "Maximum Qty.") { Caption = 'Maximum Qty.'; }
}
