codeunit 50207 "LAA Sample Request Mgt."
{
    procedure CreateForCustomer(CustomerNo: Code[20]; var SampleRequest: Record "LAA Sample Request Header")
    begin
        SampleRequest.Init();
        SampleRequest.Validate("Customer No.", CustomerNo);
        SampleRequest.Insert(true);
    end;
    procedure Submit(var SampleRequest: Record "LAA Sample Request Header")
    var
        SampleLine: Record "LAA Sample Request Line";
        CustomerRec: Record Customer;
        UserSetupRec: Record "User Setup";
        ApprovalLimit: Decimal;
        RequestCount: Integer;
        PeriodStart: Date;
        Setup: Record "LAA Sample Request Setup";
        OldStatus: Enum "LAA Sample Request Status";
        NoLinesErr: Label 'Request %1 has no lines. Add at least one item before submitting.', Comment = '%1 = Request number';
        PeriodLimitErr: Label 'This customer already has %1 requests since %2. The configured request limit has been reached.', Comment = '%1 = Number of requests in period, %2 = Period start date';
    begin
        SampleRequest.EnsureOpen();
        SampleRequest.TestField("Customer No.");
        CustomerRec.Get(SampleRequest."Customer No.");
        if CustomerRec.Blocked <> CustomerRec.Blocked::" " then
            Error('Customer %1 is blocked. Select an unblocked customer before submitting.', CustomerRec."No.");
        SampleLine.SetRange("Document No.", SampleRequest."No.");
        if SampleLine.IsEmpty() then
            Error(NoLinesErr, SampleRequest."No.");
        if Setup.Get('') then
            if (Setup."Max. Requests per Period" > 0) and (Format(Setup."Request Period") <> '') then begin
                PeriodStart := CalcDate(Setup."Request Period", WorkDate());
                SampleLine.Reset();
                RequestCount := CountCustomerRequests(SampleRequest."Customer No.", PeriodStart);
                if RequestCount >= Setup."Max. Requests per Period" then
                    Error(PeriodLimitErr, RequestCount, PeriodStart);
            end;
        SampleRequest.CalcFields("Total Amount");
        if UserSetupRec.Get(UserId()) then
            ApprovalLimit := UserSetupRec."LAA Sample Approval Limit"
        else
            ApprovalLimit := 0;
        OldStatus := SampleRequest.Status;
        if SampleRequest."Total Amount" <= ApprovalLimit then begin
            SampleRequest.Status := SampleRequest.Status::Approved;
            SampleRequest."Approved By" := CopyStr(UserId(), 1, MaxStrLen(SampleRequest."Approved By"));
            SampleRequest."Approved Date" := WorkDate();
        end else begin
            SampleRequest.Status := SampleRequest.Status::"Pending Approval";
            Clear(SampleRequest."Approved By");
            Clear(SampleRequest."Approved Date");
        end;
        SampleRequest.Modify(true);
        OnAfterStatusChanged(SampleRequest, OldStatus, SampleRequest.Status);
    end;

    procedure Approve(var SampleRequest: Record "LAA Sample Request Header")
    var
        UserSetupRec: Record "User Setup";
        ApprovalLimit: Decimal;
        OldStatus: Enum "LAA Sample Request Status";
        OwnRequestErr: Label 'You cannot approve request %1 because you submitted it. Ask another authorized user.', Comment = '%1 = Request number';
        LimitErr: Label 'Your sample approval limit does not cover request %1. Ask a user with a higher limit.', Comment = '%1 = Request number';
    begin
        if SampleRequest.Status <> SampleRequest.Status::"Pending Approval" then
            Error('Only Pending Approval requests can be approved.');
        if SampleRequest."Requested By" = UserId() then
            Error(OwnRequestErr, SampleRequest."No.");
        if UserSetupRec.Get(UserId()) then
            ApprovalLimit := UserSetupRec."LAA Sample Approval Limit";
        SampleRequest.CalcFields("Total Amount");
        if ApprovalLimit < SampleRequest."Total Amount" then
            Error(LimitErr, SampleRequest."No.");
        OldStatus := SampleRequest.Status;
        SampleRequest.Status := SampleRequest.Status::Approved;
        SampleRequest."Approved By" := CopyStr(UserId(), 1, MaxStrLen(SampleRequest."Approved By"));
        SampleRequest."Approved Date" := WorkDate();
        SampleRequest.Modify(true);
        OnAfterStatusChanged(SampleRequest, OldStatus, SampleRequest.Status);
    end;

    procedure Reject(var SampleRequest: Record "LAA Sample Request Header")
    var
        OldStatus: Enum "LAA Sample Request Status";
        ReasonErr: Label 'Enter a rejection reason before rejecting request %1.', Comment = '%1 = Request number';
    begin
        if SampleRequest.Status <> SampleRequest.Status::"Pending Approval" then
            Error('Only Pending Approval requests can be rejected.');
        SampleRequest.TestField("Rejection Reason");
        if SampleRequest."Rejection Reason" = '' then
            Error(ReasonErr, SampleRequest."No.");
        OldStatus := SampleRequest.Status;
        SampleRequest.Status := SampleRequest.Status::Rejected;
        SampleRequest.Modify(true);
        OnAfterStatusChanged(SampleRequest, OldStatus, SampleRequest.Status);
    end;

    procedure MarkAsShipped(var SampleRequest: Record "LAA Sample Request Header")
    var
        OldStatus: Enum "LAA Sample Request Status";
    begin
        if SampleRequest.Status <> SampleRequest.Status::Approved then
            Error('Only Approved requests can be marked as shipped.');
        SampleRequest.TestField("Tracking No.");
        OldStatus := SampleRequest.Status;
        SampleRequest.Status := SampleRequest.Status::Shipped;
        SampleRequest."Shipped Date" := WorkDate();
        SampleRequest.Modify(true);
        OnAfterStatusChanged(SampleRequest, OldStatus, SampleRequest.Status);
    end;

    procedure Cancel(var SampleRequest: Record "LAA Sample Request Header")
    var
        OldStatus: Enum "LAA Sample Request Status";
    begin
        if not (SampleRequest.Status in [SampleRequest.Status::Open, SampleRequest.Status::"Pending Approval", SampleRequest.Status::Approved]) then
            Error('Only Open, Pending Approval or Approved requests can be cancelled.');
        OldStatus := SampleRequest.Status;
        SampleRequest.Status := SampleRequest.Status::Cancelled;
        SampleRequest.Modify(true);
        OnAfterStatusChanged(SampleRequest, OldStatus, SampleRequest.Status);
    end;

    procedure Reopen(var SampleRequest: Record "LAA Sample Request Header")
    var
        OldStatus: Enum "LAA Sample Request Status";
    begin
        if not (SampleRequest.Status in [SampleRequest.Status::"Pending Approval", SampleRequest.Status::Approved, SampleRequest.Status::Rejected]) then
            Error('Only Pending Approval, Approved or Rejected requests can be reopened.');
        OldStatus := SampleRequest.Status;
        SampleRequest.Status := SampleRequest.Status::Open;
        Clear(SampleRequest."Approved By");
        Clear(SampleRequest."Approved Date");
        SampleRequest.Modify(true);
        OnAfterStatusChanged(SampleRequest, OldStatus, SampleRequest.Status);
    end;

    local procedure CountCustomerRequests(CustomerNo: Code[20]; PeriodStart: Date): Integer
    var
        Header: Record "LAA Sample Request Header";
    begin
        Header.SetRange("Customer No.", CustomerNo);
        Header.SetFilter("Request Date", '%1..%2', PeriodStart, WorkDate());
        Header.SetFilter(Status, '<>%1&<>%2', Header.Status::Rejected, Header.Status::Cancelled);
        exit(Header.Count());
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterStatusChanged(var SampleRequest: Record "LAA Sample Request Header"; OldStatus: Enum "LAA Sample Request Status"; NewStatus: Enum "LAA Sample Request Status")
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure ItemOnBeforeDelete(var Rec: Record Item; RunTrigger: Boolean)
    var
        SampleLine: Record "LAA Sample Request Line";
        Header: Record "LAA Sample Request Header";
        ItemDeleteErr: Label 'Item %1 is used on active sample request %2. Resolve or cancel that request before deleting the item.', Comment = '%1 = Item number, %2 = Request number';
    begin
        SampleLine.SetRange("Item No.", Rec."No.");
        if SampleLine.FindSet() then
            repeat
                if Header.Get(SampleLine."Document No.") and (Header.Status in [Header.Status::Open, Header.Status::"Pending Approval", Header.Status::Approved]) then
                    Error(ItemDeleteErr, Rec."No.", Header."No.");
            until SampleLine.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure CustomerOnBeforeDelete(var Rec: Record Customer; RunTrigger: Boolean)
    var
        Header: Record "LAA Sample Request Header";
        CustomerDeleteErr: Label 'Customer %1 is used on active sample request %2. Resolve or cancel that request before deleting the customer.', Comment = '%1 = Customer number, %2 = Request number';
    begin
        Header.SetRange("Customer No.", Rec."No.");
        Header.SetFilter(Status, '%1|%2|%3', Header.Status::Open, Header.Status::"Pending Approval", Header.Status::Approved);
        if Header.FindFirst() then
            Error(CustomerDeleteErr, Rec."No.", Header."No.");
    end;
}