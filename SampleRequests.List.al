page 50110 "LAA Sample Requests"
{
    PageType = List;
    SourceTable = "LAA Sample Request Header";
    Caption = 'Sample Requests';
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "LAA Sample Request";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.") { ApplicationArea = All; ToolTip = 'Specifies the sample request number.'; }
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; ToolTip = 'Specifies the customer number.'; }
                field("Customer Name"; Rec."Customer Name") { ApplicationArea = All; ToolTip = 'Specifies the customer name.'; }
                field("Request Date"; Rec."Request Date") { ApplicationArea = All; ToolTip = 'Specifies the request date.'; }
                field(Status; Rec.Status) { ApplicationArea = All; ToolTip = 'Specifies the current status.'; }
                field("Total Amount"; Rec."Total Amount") { ApplicationArea = All; ToolTip = 'Specifies the total sample value.'; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Print)
            {
                Caption = 'Print'; Image = Print; ApplicationArea = All;
                ToolTip = 'Print the selected sample request packing document without prices.';
                trigger OnAction()
                var SampleReport: Report "LAA Sample Request Report";
                begin
                    CurrPage.SetSelectionFilter(Rec);
                    SampleReport.SetTableView(Rec);
                    SampleReport.RunModal();
                end;
            }
        }
    }
}