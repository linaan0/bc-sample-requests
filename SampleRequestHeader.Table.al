table 50200 "LAA Sample Request Header"
{
    Caption = 'Sample Request';
    DataClassification = CustomerContent;
    LookupPageId = "LAA Sample Requests";
    DrillDownPageId = "LAA Sample Requests";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                Setup: Record "LAA Sample Request Setup";
                NoSeries: Codeunit NoSeriesManagement;
            begin
                if "No." <> xRec."No." then begin
                    GetSetup(Setup);
                    NoSeries.TestManual(Setup."Sample Request Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
            trigger OnValidate()
            var
                Customer: Record Customer;
                SampleLine: Record "LAA Sample Request Line";
            begin
                EnsureOpen();
                if "Customer No." <> xRec."Customer No." then begin
                    SampleLine.SetRange("Document No.", "No.");
                    if not SampleLine.IsEmpty() then
                        Error(CustomerHasLinesErr);
                end;
                if "Customer No." = '' then begin
                    "Customer Name" := '';
                    exit;
                end;
                Customer.Get("Customer No.");
                if Customer.Blocked <> Customer.Blocked::" " then
                    Error(CustomerBlockedErr, Customer."No.", Customer.Name);
                "Customer Name" := Customer.Name;
            end;
        }
        field(3; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "Contact E-mail"; Text[80])
        {
            Caption = 'Contact E-mail';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                EnsureOpen();
                if "Contact E-mail" <> '' then
                    MailManagement.CheckValidEmailAddresses("Contact E-mail");
            end;
        }
        field(5; Project; Text[100])
        {
            Caption = 'Project';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                EnsureOpen();
            end;
        }
        field(6; "Request Date"; Date)
        {
            Caption = 'Request Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(7; Status; Enum "LAA Sample Request Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8; "Requested By"; Code[50])
        {
            Caption = 'Requested By';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(9; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = sum("LAA Sample Request Line"."Line Amount" where("Document No." = field("No.")));
        }
        field(10; "Approved By"; Code[50])
        {
            Caption = 'Approved By';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(11; "Approved Date"; Date)
        {
            Caption = 'Approved Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; "Rejection Reason"; Text[250])
        {
            Caption = 'Rejection Reason';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                EnsureOpenOrPending();
            end;
        }
        field(13; "Tracking No."; Text[50])
        {
            Caption = 'Tracking No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                EnsureOpenOrApproved();
            end;
        }
        field(14; "Shipped Date"; Date)
        {
            Caption = 'Shipped Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(15; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            Editable = false;
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    var
        CustomerHasLinesErr: Label 'You cannot change the customer after request lines have been added. Delete the lines first, or create a new request.';
        CustomerBlockedErr: Label 'Customer %1 (%2) is blocked. Choose a customer that is not blocked.', Comment = '%1 = Customer number, %2 = Customer name';
        NotOpenErr: Label 'Request %1 is %2. Only Open requests can be edited. Reopen the request first.', Comment = '%1 = Request number, %2 = Current status';
        NotOpenOrPendingErr: Label 'Request %1 is %2. The rejection reason can only be changed while the request is Open or Pending Approval.', Comment = '%1 = Request number, %2 = Current status';
        NotOpenOrApprovedErr: Label 'Request %1 is %2. The tracking number can only be changed while the request is Open or Approved.', Comment = '%1 = Request number, %2 = Current status';
        DeleteStatusErr: Label 'Request %1 is %2 and cannot be deleted. Only Open or Cancelled requests can be deleted.', Comment = '%1 = Request number, %2 = Current status';
        NoChangeErr: Label 'The request number cannot be changed. Create a new request instead.';
        TransitionErr: Label 'Request %1 cannot change from %2 to %3. Use the actions on the request to change its status.', Comment = '%1 = Request number, %2 = Old status, %3 = New status';
        ReasonRequiredErr: Label 'Enter a rejection reason on request %1 before rejecting it.', Comment = '%1 = Request number';
        TrackingRequiredErr: Label 'Enter a tracking number on request %1 before marking it as shipped.', Comment = '%1 = Request number';
        SetupMissingErr: Label 'The Sample Request Setup does not exist yet. Open Sample Request Setup, fill it in and try again.';

    trigger OnInsert()
    var
        Setup: Record "LAA Sample Request Setup";
        NoSeries: Codeunit NoSeriesManagement;
    begin
        if "No." = '' then begin
            GetSetup(Setup);
            Setup.TestField("Sample Request Nos.");
            "No. Series" := Setup."Sample Request Nos.";
            "No." := NoSeries.GetNextNo("No. Series", WorkDate(), true);
        end;
        if "Request Date" = 0D then
            "Request Date" := WorkDate();
        if "Requested By" = '' then
            "Requested By" := CopyStr(UserId(), 1, MaxStrLen("Requested By"));
        Status := Status::Open;
    end;

    trigger OnModify()
    begin
        if Status <> xRec.Status then
            CheckStatusTransition()
        else
            CheckFieldChangesAllowed();
    end;

    trigger OnRename()
    begin
        Error(NoChangeErr);
    end;

    trigger OnDelete()
    var
        SampleLine: Record "LAA Sample Request Line";
    begin
        if not (Status in [Status::Open, Status::Cancelled]) then
            Error(DeleteStatusErr, "No.", Status);
        SampleLine.SetRange("Document No.", "No.");
        SampleLine.DeleteAll(false);
    end;

    procedure AssistEdit(OldHeader: Record "LAA Sample Request Header"): Boolean
    var
        Setup: Record "LAA Sample Request Setup";
        NoSeries: Codeunit NoSeriesManagement;
    begin
        GetSetup(Setup);
        Setup.TestField("Sample Request Nos.");
        if NoSeries.SelectSeries(Setup."Sample Request Nos.", OldHeader."No. Series", "No. Series") then begin
            "No." := NoSeries.GetNextNo("No. Series", WorkDate(), true);
            exit(true);
        end;
    end;

    procedure EnsureOpen()
    begin
        if Status <> Status::Open then
            Error(NotOpenErr, "No.", Status);
    end;

    local procedure EnsureOpenOrPending()
    begin
        if not (Status in [Status::Open, Status::"Pending Approval"]) then
            Error(NotOpenOrPendingErr, "No.", Status);
    end;

    local procedure EnsureOpenOrApproved()
    begin
        if not (Status in [Status::Open, Status::Approved]) then
            Error(NotOpenOrApprovedErr, "No.", Status);
    end;

    local procedure CheckFieldChangesAllowed()
    begin
        if ("Customer No." <> xRec."Customer No.") or
           ("Contact E-mail" <> xRec."Contact E-mail") or
           (Project <> xRec.Project)
        then
            EnsureOpen();
        if "Rejection Reason" <> xRec."Rejection Reason" then
            EnsureOpenOrPending();
        if "Tracking No." <> xRec."Tracking No." then
            EnsureOpenOrApproved();
    end;

    local procedure CheckStatusTransition()
    var
        IsValid: Boolean;
    begin
        case xRec.Status of
            xRec.Status::Open:
                IsValid := Status in [Status::"Pending Approval", Status::Approved, Status::Cancelled];
            xRec.Status::"Pending Approval":
                IsValid := Status in [Status::Approved, Status::Rejected, Status::Cancelled, Status::Open];
            xRec.Status::Approved:
                IsValid := Status in [Status::Shipped, Status::Cancelled, Status::Open];
            xRec.Status::Rejected:
                IsValid := Status = Status::Open;
        end;
        if not IsValid then
            Error(TransitionErr, "No.", xRec.Status, Status);
        if (Status = Status::Rejected) and ("Rejection Reason" = '') then
            Error(ReasonRequiredErr, "No.");
        if (Status = Status::Shipped) and ("Tracking No." = '') then
            Error(TrackingRequiredErr, "No.");
    end;

    local procedure GetSetup(var Setup: Record "LAA Sample Request Setup")
    begin
        if not Setup.Get('') then
            Error(SetupMissingErr);
    end;
}
