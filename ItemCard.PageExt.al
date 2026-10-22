pageextension 50213 "LAA Item Card Ext" extends "Item Card"
{
    layout
    {
        addlast(Item)
        {
            group("LAA Samples")
            {
                Caption = 'Samples';
                field("LAA Sample Allowed"; Rec."LAA Sample Allowed") { ApplicationArea = All; ToolTip = 'Specifies whether this item may be sent as a sample.'; }
                field("LAA Max. Sample Qty."; Rec."LAA Max. Sample Qty.") { ApplicationArea = All; ToolTip = 'Specifies the maximum quantity allowed per sample request; zero uses the setup default.'; }
            }
        }
    }
}