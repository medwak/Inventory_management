/// <summary>
/// Order in which open inbound entries (stock layers) are consumed by outbound postings.
/// </summary>
enum 50105 "IMS Picking Strategy"
{
    Extensible = false;
    Caption = 'Picking Strategy';

    value(0; FIFO) { Caption = 'FIFO (First In, First Out)'; }
    value(1; FEFO) { Caption = 'FEFO (First Expired, First Out)'; }
    value(2; LIFO) { Caption = 'LIFO (Last In, First Out)'; }
}
