table 50100 "LAA Sample Request Header"
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
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
            trigger OnValidate()
            var
                CustomerRec: Record Customer;
                SampleLine: Record "LAA Sample Request Line";
            begin
                if "Customer No." = '' then begin
                    "Customer Name" := '';
                    exit;
                end;
                CustomerRec.Get("Customer No.");
                if CustomerRec.Blocked <> CustomerRec.Blocked::" " then
                    Error('Customer %1 (%2) is blocked. Choose an unblocked customer.', CustomerRec."No.", CustomerRec.Name);
                SampleLine.SetRange("Document No.", "No.");
                if not SampleLine.IsEmpty() then
                    Error('You cannot change the customer after adding request lines. Remove the lines first.');
                "Customer Name" := CustomerRec.Name;
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
                if "Contact E-mail" <> '' then
                    MailManagement.CheckValidEmailAddresses("Contact E-mail");
            end;
        }
        field(5; Project; Text[100])
        {
            Caption = 'Project';
            DataClassification = CustomerContent;
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
            trigger OnValidate() begin EnsureOpenOrPending(); end;
        }
        field(13; "Tracking No."; Text[50])
        {
            Caption = 'Tracking No.';
            DataClassification = CustomerContent;
            trigger OnValidate() begin EnsureOpenOrApproved(); end;
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
    keys { key(PK; "No.") { Clustered = true; } }

    trigger OnInsert()
    var
        Setup: Record "LAA Sample Request Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if "No." = '' then begin
            Setup.Get('');
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

    procedure EnsureOpenOrPending()
    begin
        if not (Status in [Status::Open, Status::"Pending Approval"]) then
            Error('Request %1 does not allow this change in its current status.', "No.");
    end;

    procedure EnsureOpenOrApproved()
    begin
        if not (Status in [Status::Open, Status::Approved]) then
            Error('Request %1 does not allow this change in its current status.', "No.");
    end;

}