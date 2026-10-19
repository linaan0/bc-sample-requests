page 50109 "LAA Sample Request"
{
    PageType = Document;
    SourceTable = "LAA Sample Request Header";
    Caption = 'Sample Request';
    ApplicationArea = All;
    UsageCategory = Documents;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.") { ApplicationArea = All; Editable = false; ToolTip = 'Specifies the sample request number.'; }
                field("Customer No."; Rec."Customer No.") { ApplicationArea = All; ToolTip = 'Specifies the customer receiving the sample.'; }
                field("Customer Name"; Rec."Customer Name") { ApplicationArea = All; ToolTip = 'Specifies the customer name copied from the customer card.'; }
                field("Contact E-mail"; Rec."Contact E-mail") { ApplicationArea = All; ToolTip = 'Specifies the optional contact email address.'; }
                field(Project; Rec.Project) { ApplicationArea = All; ToolTip = 'Specifies the project for which the sample is requested.'; }
                field("Request Date"; Rec."Request Date") { ApplicationArea = All; ToolTip = 'Specifies the date the request was created.'; }
                field(Status; Rec.Status) { ApplicationArea = All; ToolTip = 'Specifies the current request status.'; }
                field("Requested By"; Rec."Requested By") { ApplicationArea = All; ToolTip = 'Specifies the user who created the request.'; }
                field("Total Amount"; Rec."Total Amount") { ApplicationArea = All; ToolTip = 'Specifies the total value of the sample lines.'; }
            }
            part(Lines; "LAA Sample Request Lines")
            {
                ApplicationArea = All;
                SubPageLink = "Document No." = field("No.");
                UpdatePropagation = Both;
            }
            group(Approval)
            {
                Caption = 'Approval and shipment';
                field("Approved By"; Rec."Approved By") { ApplicationArea = All; ToolTip = 'Specifies the user who approved the request.'; }
                field("Approved Date"; Rec."Approved Date") { ApplicationArea = All; ToolTip = 'Specifies the approval date.'; }
                field("Rejection Reason"; Rec."Rejection Reason") { ApplicationArea = All; ToolTip = 'Specifies why the request was rejected.'; }
                field("Tracking No."; Rec."Tracking No.") { ApplicationArea = All; ToolTip = 'Specifies the shipment tracking number.'; }
                field("Shipped Date"; Rec."Shipped Date") { ApplicationArea = All; ToolTip = 'Specifies the date the sample was shipped.'; }
            }
        }
    }
}