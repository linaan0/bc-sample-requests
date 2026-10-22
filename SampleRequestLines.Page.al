page 50208 "LAA Sample Request Lines"
{
    PageType = ListPart;
    SourceTable = "LAA Sample Request Line";
    Caption = 'Lines';
    AutoSplitKey = true;
    DelayedInsert = true;
    MultipleNewLines = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Item No."; Rec."Item No.") { ApplicationArea = All; ToolTip = 'Specifies the item requested as a sample.'; }
                field(Description; Rec.Description) { ApplicationArea = All; ToolTip = 'Specifies the copied item description.'; }
                field(Quantity; Rec.Quantity) { ApplicationArea = All; ToolTip = 'Specifies the sample quantity.'; }
                field("Unit of Measure Code"; Rec."Unit of Measure Code") { ApplicationArea = All; ToolTip = 'Specifies the item base unit of measure.'; }
                field("Unit Price"; Rec."Unit Price") { ApplicationArea = All; ToolTip = 'Specifies the unit price captured when the item was added.'; }
                field("Line Amount"; Rec."Line Amount") { ApplicationArea = All; ToolTip = 'Specifies quantity multiplied by the captured unit price.'; }
            }
        }
    }
}