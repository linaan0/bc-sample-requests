page 50209 "LAA Sample Request"
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
                Editable = IsOpen;
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the sample request number.';

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
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
                Editable = IsOpen;
            }
            group(Approval)
            {
                Caption = 'Approval and shipment';
                field("Approved By"; Rec."Approved By") { ApplicationArea = All; ToolTip = 'Specifies the user who approved the request.'; }
                field("Approved Date"; Rec."Approved Date") { ApplicationArea = All; ToolTip = 'Specifies the approval date.'; }
                field("Rejection Reason"; Rec."Rejection Reason") { ApplicationArea = All; Editable = CanEnterReason; ToolTip = 'Specifies why the request was rejected.'; }
                field("Tracking No."; Rec."Tracking No.") { ApplicationArea = All; Editable = CanEnterTracking; ToolTip = 'Specifies the shipment tracking number.'; }
                field("Shipped Date"; Rec."Shipped Date") { ApplicationArea = All; ToolTip = 'Specifies the date the sample was shipped.'; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Submit)
            {
                Caption = 'Submit'; Image = SendApprovalRequest; ApplicationArea = All;
                ToolTip = 'Submit the request for automatic approval or approval by another user.';
                trigger OnAction() var Mgt: Codeunit "LAA Sample Request Mgt."; begin Mgt.Submit(Rec); CurrPage.Update(false); end;
            }
            action(Approve)
            {
                Caption = 'Approve'; Image = Approve; ApplicationArea = All;
                ToolTip = 'Approve a pending request if your limit covers its value.';
                trigger OnAction() var Mgt: Codeunit "LAA Sample Request Mgt."; begin Mgt.Approve(Rec); CurrPage.Update(false); end;
            }
            action(Reject)
            {
                Caption = 'Reject'; Image = Reject; ApplicationArea = All;
                ToolTip = 'Reject a pending request after entering a rejection reason.';
                trigger OnAction() var Mgt: Codeunit "LAA Sample Request Mgt."; begin Mgt.Reject(Rec); CurrPage.Update(false); end;
            }
            action("Mark as Shipped")
            {
                Caption = 'Mark as Shipped'; Image = Shipment; ApplicationArea = All;
                ToolTip = 'Mark an approved request as shipped after entering its tracking number.';
                trigger OnAction() var Mgt: Codeunit "LAA Sample Request Mgt."; begin Mgt.MarkAsShipped(Rec); CurrPage.Update(false); end;
            }
            action(Cancel)
            {
                Caption = 'Cancel'; Image = Cancel; ApplicationArea = All;
                ToolTip = 'Cancel an open, pending approval or approved request.';
                trigger OnAction()
                var Mgt: Codeunit "LAA Sample Request Mgt."; ConfirmCancelQst: Label 'Cancel sample request %1?', Comment = '%1 = Request number';
                begin
                    if Confirm(ConfirmCancelQst, false, Rec."No.") then begin Mgt.Cancel(Rec); CurrPage.Update(false); end;
                end;
            }
            action(Reopen)
            {
                Caption = 'Reopen'; Image = ReOpen; ApplicationArea = All;
                ToolTip = 'Reopen a pending, approved or rejected request for editing.';
                trigger OnAction() var Mgt: Codeunit "LAA Sample Request Mgt."; begin Mgt.Reopen(Rec); CurrPage.Update(false); end;
            }
            action(Print)
            {
                Caption = 'Print'; Image = Print; ApplicationArea = All;
                ToolTip = 'Print the sample request packing document without prices.';
                trigger OnAction()
                var
                    Header: Record "LAA Sample Request Header";
                begin
                    Header := Rec;
                    Header.SetRecFilter();
                    Report.Run(Report::"LAA Sample Request Report", true, false, Header);
                end;
            }
        }

        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(Submit_Promoted; Submit) { }
                actionref(Approve_Promoted; Approve) { }
                actionref(Reject_Promoted; Reject) { }
                actionref(MarkAsShipped_Promoted; "Mark as Shipped") { }
                actionref(Cancel_Promoted; Cancel) { }
                actionref(Reopen_Promoted; Reopen) { }
                actionref(Print_Promoted; Print) { }
            }
        }
    }

    var
        IsOpen: Boolean;
        CanEnterReason: Boolean;
        CanEnterTracking: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        IsOpen := Rec.Status = Rec.Status::Open;
        CanEnterReason := Rec.Status in [Rec.Status::Open, Rec.Status::"Pending Approval"];
        CanEnterTracking := Rec.Status in [Rec.Status::Open, Rec.Status::Approved];
    end;
}