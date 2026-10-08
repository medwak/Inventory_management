/// <summary>
/// How outbound entries are valued.
/// Actual   - cost of the inbound layers actually consumed (FIFO/LIFO/FEFO depending on the picking strategy).
/// Average  - running weighted average unit cost of the item.
/// Standard - the item's standard cost.
/// </summary>
enum 50103 "IMS Costing Method"
{
    Extensible = true;
    Caption = 'Costing Method';

    value(0; Actual) { Caption = 'Actual (Applied Layers)'; }
    value(1; Average) { Caption = 'Average'; }
    value(2; Standard) { Caption = 'Standard'; }
}
