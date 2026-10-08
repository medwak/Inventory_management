enum 50106 "IMS Lot Status"
{
    Extensible = true;
    Caption = 'Lot Status';

    value(0; Available) { Caption = 'Available'; }
    value(1; Quarantine) { Caption = 'Quarantine'; }
    value(2; Blocked) { Caption = 'Blocked'; }
}
