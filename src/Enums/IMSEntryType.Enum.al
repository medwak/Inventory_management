/// <summary>
/// Type of an inventory movement. Journal quantities are always entered as positive
/// numbers; the entry type decides the sign of the resulting item ledger entry.
/// </summary>
enum 50101 "IMS Entry Type"
{
    Extensible = true;
    Caption = 'Entry Type';

    value(0; Purchase) { Caption = 'Purchase'; }
    value(1; Sale) { Caption = 'Sale'; }
    value(2; "Positive Adjmt.") { Caption = 'Positive Adjmt.'; }
    value(3; "Negative Adjmt.") { Caption = 'Negative Adjmt.'; }
    value(4; Transfer) { Caption = 'Transfer'; }
    value(5; Consumption) { Caption = 'Consumption'; }
    value(6; Output) { Caption = 'Output'; }
}
