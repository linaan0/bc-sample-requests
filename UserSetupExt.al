pageextension 50214 "LAA User Setup Ext" extends "User Setup"
{
    layout
    {
        addlast(Control1)
        {
            field("LAA Sample Approval Limit"; Rec."LAA Sample Approval Limit")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the maximum total value of sample requests this user may approve.';
            }
        }
    }
}