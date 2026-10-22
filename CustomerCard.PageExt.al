pageextension 50215 "LAA Customer Card Ext" extends "Customer Card"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part("LAA Customer Samples"; "LAA Customer Samples FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("No.");
                ToolTip = 'Shows this customer''s open and shipped sample request counts.';
            }
        }
    }
    actions
    {
        addlast(Processing)
        {
            action("LAA Sample Requests")
            {
                Caption = 'Sample Requests';
                ApplicationArea = All;
                Image = List;
                ToolTip = 'Open the sample requests for this customer.';
                trigger OnAction()
                var Header: Record "LAA Sample Request Header";
                begin
                    Header.SetRange("Customer No.", Rec."No.");
                    Page.Run(Page::"LAA Sample Requests", Header);
                end;
            }
            action("LAA New Sample Request")
            {
                Caption = 'New Sample Request';
                ApplicationArea = All;
                Image = NewDocument;
                ToolTip = 'Create a new sample request for this customer.';
                trigger OnAction()
                var
                    Header: Record "LAA Sample Request Header";
                    Mgt: Codeunit "LAA Sample Request Mgt.";
                begin
                    Mgt.CreateForCustomer(Rec."No.", Header);
                    Page.Run(Page::"LAA Sample Request", Header);
                end;
            }
        }
    }
}