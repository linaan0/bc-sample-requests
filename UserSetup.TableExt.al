tableextension 50101 "LAA User Setup Ext" extends "User Setup"
{
    fields
    {
        field(50100; "LAA Sample Approval Limit"; Decimal)
        {
            Caption = 'Sample Approval Limit';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
    }
}