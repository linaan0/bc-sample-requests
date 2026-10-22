pageextension 50216 "LAA Customer List Ext" extends "Customer List"
{
    actions
    {
        addlast(Processing)
        {
            action("LAA Sample Requests")
            {
                Caption = 'Sample Requests';
                ApplicationArea = All;
                Image = List;
                ToolTip = 'Open the sample requests for the selected customer.';
                trigger OnAction()
                var Header: Record "LAA Sample Request Header";
                begin
                    Rec.TestField("No.");
                    Header.SetRange("Customer No.", Rec."No.");
                    Page.Run(Page::"LAA Sample Requests", Header);
                end;
            }
            action("LAA New Sample Request")
            {
                Caption = 'New Sample Request';
                ApplicationArea = All;
                Image = NewDocument;
                ToolTip = 'Create a new sample request for the selected customer.';
                trigger OnAction()
                var Header: Record "LAA Sample Request Header";
                begin
                    Rec.TestField("No.");
                    Header.Init();
                    Header.Insert(true);
                    Header.Validate("Customer No.", Rec."No.");
                    Header.Modify(true);
                    Page.Run(Page::"LAA Sample Request", Header);
                end;
            }
        }
    }
}