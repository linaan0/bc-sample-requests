tableextension 50100 "LAA Item Ext" extends Item
{
    fields
    {
        field(50100; "LAA Sample Allowed"; Boolean)
        {
            Caption = 'Sample Allowed';
            DataClassification = CustomerContent;
        }
        field(50101; "LAA Max. Sample Qty."; Decimal)
        {
            Caption = 'Max. Sample Qty.';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
    }
}