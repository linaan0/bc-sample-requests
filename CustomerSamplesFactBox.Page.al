page 50112 "LAA Customer Samples FactBox"
{
    PageType = CardPart;
    SourceTable = Customer;
    Caption = 'Customer Samples';

    layout
    {
        area(Content)
        {
            field("LAA Open Sample Requests"; Rec."LAA Open Sample Requests")
            {
                ApplicationArea = All;
                ToolTip = 'Shows open, pending approval and approved sample requests for this customer.';
                DrillDown = true;
                trigger OnDrillDown()
                var Header: Record "LAA Sample Request Header";
                begin
                    Header.SetRange("Customer No.", Rec."No.");
                    Header.SetFilter(Status, '%1|%2|%3', Header.Status::Open, Header.Status::"Pending Approval", Header.Status::Approved);
                    Page.Run(Page::"LAA Sample Requests", Header);
                end;
            }
            field("LAA Shipped Sample Requests"; Rec."LAA Shipped Sample Requests")
            {
                ApplicationArea = All;
                ToolTip = 'Shows the number of shipped sample requests for this customer.';
                DrillDown = true;
                trigger OnDrillDown()
                var Header: Record "LAA Sample Request Header";
                begin
                    Header.SetRange("Customer No.", Rec."No.");
                    Header.SetRange(Status, Header.Status::Shipped);
                    Page.Run(Page::"LAA Sample Requests", Header);
                end;
            }
        }
    }
}