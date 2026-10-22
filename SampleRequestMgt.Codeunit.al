codeunit 50207 "LAA Sample Request Mgt."
{
    var
        SubmitStatusErr: Label 'Request %1 is %2. Only Open requests can be submitted.', Comment = '%1 = Request number, %2 = Current status';
        CustomerBlockedErr: Label 'Customer %1 is blocked. Choose a customer that is not blocked before submitting.', Comment = '%1 = Customer number';
        NoLinesErr: Label 'Request %1 has no lines. Add at least one item before submitting.', Comment = '%1 = Request number';
        PeriodLimitErr: Label 'Customer %1 already has %2 sample requests since %3. The maximum is %4 per period. Wait until the period has passed or ask for an exception.', Comment = '%1 = Customer number, %2 = Number of requests in the period, %3 = Period start date, %4 = Maximum requests per period';
        OnlyPendingErr: Label 'Request %1 is %2. Only Pending Approval requests can be approved or rejected.', Comment = '%1 = Request number, %2 = Current status';
        OwnRequestErr: Label 'You cannot approve or reject request %1 because you requested it. Ask another authorized user.', Comment = '%1 = Request number';
        LimitErr: Label 'Your sample approval limit does not cover request %1. Ask a user with a higher limit.', Comment = '%1 = Request number';
        ReasonErr: Label 'Enter a rejection reason before rejecting request %1.', Comment = '%1 = Request number';
        ShipStatusErr: Label 'Request %1 is %2. Only Approved requests can be marked as shipped.', Comment = '%1 = Request number, %2 = Current status';
        TrackingErr: Label 'Enter a tracking number before marking request %1 as shipped.', Comment = '%1 = Request number';
        CancelStatusErr: Label 'Request %1 is %2. Only Open, Pending Approval or Approved requests can be cancelled.', Comment = '%1 = Request number, %2 = Current status';
        ReopenStatusErr: Label 'Request %1 is %2. Only Pending Approval, Approved or Rejected requests can be reopened.', Comment = '%1 = Request number, %2 = Current status';
        ItemDeleteErr: Label 'Item %1 is on sample request %2. Cancel or finish that request before deleting the item.', Comment = '%1 = Item number, %2 = Request number';
        CustomerDeleteErr: Label 'Customer %1 is on sample request %2. Cancel or finish that request before deleting the customer.', Comment = '%1 = Customer number, %2 = Request number';

    procedure CreateForCustomer(CustomerNo: Code[20]; var SampleRequest: Record "LAA Sample Request Header")
    begin
        // Validate before Insert so a blocked customer fails without leaving an empty request behind.
        SampleRequest.Init();
        SampleRequest.Validate("Customer No.", CustomerNo);
        SampleRequest.Insert(true);
    end;

    procedure Submit(var SampleRequest: Record "LAA Sample Request Header")
    var
        ApprovalLimit: Decimal;
    begin
        if SampleRequest.Status <> SampleRequest.Status::Open then
            Error(SubmitStatusErr, SampleRequest."No.", SampleRequest.Status);
        SampleRequest.TestField("Customer No.");
        CheckCustomerNotBlocked(SampleRequest."Customer No.");
        CheckHasLines(SampleRequest);
        CheckRequestLimit(SampleRequest);
        SampleRequest.CalcFields("Total Amount");
        ApprovalLimit := GetApprovalLimit();
        if SampleRequest."Total Amount" <= ApprovalLimit then begin
            SampleRequest."Approved By" := CopyStr(UserId(), 1, MaxStrLen(SampleRequest."Approved By"));
            SampleRequest."Approved Date" := WorkDate();
            SetStatus(SampleRequest, SampleRequest.Status::Approved);
        end else
            SetStatus(SampleRequest, SampleRequest.Status::"Pending Approval");
    end;

    procedure Approve(var SampleRequest: Record "LAA Sample Request Header")
    begin
        CheckCanDecide(SampleRequest);
        SampleRequest."Approved By" := CopyStr(UserId(), 1, MaxStrLen(SampleRequest."Approved By"));
        SampleRequest."Approved Date" := WorkDate();
        SetStatus(SampleRequest, SampleRequest.Status::Approved);
    end;

    procedure Reject(var SampleRequest: Record "LAA Sample Request Header")
    begin
        CheckCanDecide(SampleRequest);
        if SampleRequest."Rejection Reason" = '' then
            Error(ReasonErr, SampleRequest."No.");
        SetStatus(SampleRequest, SampleRequest.Status::Rejected);
    end;

    procedure MarkAsShipped(var SampleRequest: Record "LAA Sample Request Header")
    begin
        if SampleRequest.Status <> SampleRequest.Status::Approved then
            Error(ShipStatusErr, SampleRequest."No.", SampleRequest.Status);
        if SampleRequest."Tracking No." = '' then
            Error(TrackingErr, SampleRequest."No.");
        SampleRequest."Shipped Date" := WorkDate();
        SetStatus(SampleRequest, SampleRequest.Status::Shipped);
    end;

    procedure Cancel(var SampleRequest: Record "LAA Sample Request Header")
    begin
        if not (SampleRequest.Status in [SampleRequest.Status::Open, SampleRequest.Status::"Pending Approval", SampleRequest.Status::Approved]) then
            Error(CancelStatusErr, SampleRequest."No.", SampleRequest.Status);
        SetStatus(SampleRequest, SampleRequest.Status::Cancelled);
    end;

    procedure Reopen(var SampleRequest: Record "LAA Sample Request Header")
    begin
        if not (SampleRequest.Status in [SampleRequest.Status::"Pending Approval", SampleRequest.Status::Approved, SampleRequest.Status::Rejected]) then
            Error(ReopenStatusErr, SampleRequest."No.", SampleRequest.Status);
        Clear(SampleRequest."Approved By");
        Clear(SampleRequest."Approved Date");
        SetStatus(SampleRequest, SampleRequest.Status::Open);
    end;

    local procedure SetStatus(var SampleRequest: Record "LAA Sample Request Header"; NewStatus: Enum "LAA Sample Request Status")
    var
        OldStatus: Enum "LAA Sample Request Status";
    begin
        OldStatus := SampleRequest.Status;
        SampleRequest.Status := NewStatus;
        // Modify(true) so the table's transition rules run for every status change.
        SampleRequest.Modify(true);
        OnAfterStatusChanged(SampleRequest, OldStatus, NewStatus);
    end;

    local procedure CheckCanDecide(var SampleRequest: Record "LAA Sample Request Header")
    begin
        if SampleRequest.Status <> SampleRequest.Status::"Pending Approval" then
            Error(OnlyPendingErr, SampleRequest."No.", SampleRequest.Status);
        if SampleRequest."Requested By" = UserId() then
            Error(OwnRequestErr, SampleRequest."No.");
        SampleRequest.CalcFields("Total Amount");
        if GetApprovalLimit() < SampleRequest."Total Amount" then
            Error(LimitErr, SampleRequest."No.");
    end;

    local procedure GetApprovalLimit(): Decimal
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(UserId()) then
            exit(UserSetup."LAA Sample Approval Limit");
        exit(0);
    end;

    local procedure CheckCustomerNotBlocked(CustomerNo: Code[20])
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustomerNo);
        if Customer.Blocked <> Customer.Blocked::" " then
            Error(CustomerBlockedErr, Customer."No.");
    end;

    local procedure CheckHasLines(var SampleRequest: Record "LAA Sample Request Header")
    var
        SampleLine: Record "LAA Sample Request Line";
    begin
        SampleLine.SetRange("Document No.", SampleRequest."No.");
        if SampleLine.IsEmpty() then
            Error(NoLinesErr, SampleRequest."No.");
    end;

    local procedure CheckRequestLimit(var SampleRequest: Record "LAA Sample Request Header")
    var
        Setup: Record "LAA Sample Request Setup";
        PeriodStart: Date;
        RequestCount: Integer;
    begin
        if not Setup.Get('') then
            exit;
        if (Setup."Max. Requests per Period" = 0) or (Format(Setup."Request Period") = '') then
            exit;
        PeriodStart := CalcDate(Setup."Request Period", WorkDate());
        RequestCount := CountOtherRequests(SampleRequest, PeriodStart);
        if RequestCount >= Setup."Max. Requests per Period" then
            Error(PeriodLimitErr, SampleRequest."Customer No.", RequestCount, PeriodStart, Setup."Max. Requests per Period");
    end;

    local procedure CountOtherRequests(var SampleRequest: Record "LAA Sample Request Header"; PeriodStart: Date): Integer
    var
        Header: Record "LAA Sample Request Header";
    begin
        Header.SetRange("Customer No.", SampleRequest."Customer No.");
        Header.SetRange("Request Date", PeriodStart, WorkDate());
        Header.SetFilter("No.", '<>%1', SampleRequest."No.");
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
    begin
        if Rec.IsTemporary() then
            exit;
        SampleLine.SetRange("Item No.", Rec."No.");
        if SampleLine.FindSet() then
            repeat
                if Header.Get(SampleLine."Document No.") then
                    if Header.Status in [Header.Status::Open, Header.Status::"Pending Approval", Header.Status::Approved] then
                        Error(ItemDeleteErr, Rec."No.", Header."No.");
            until SampleLine.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure CustomerOnBeforeDelete(var Rec: Record Customer; RunTrigger: Boolean)
    var
        Header: Record "LAA Sample Request Header";
    begin
        if Rec.IsTemporary() then
            exit;
        Header.SetRange("Customer No.", Rec."No.");
        Header.SetFilter(Status, '%1|%2|%3', Header.Status::Open, Header.Status::"Pending Approval", Header.Status::Approved);
        if Header.FindFirst() then
            Error(CustomerDeleteErr, Rec."No.", Header."No.");
    end;
}
