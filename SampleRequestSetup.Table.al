table 50202 "LAA Sample Request Setup"
{
    Caption = 'Sample Request Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "LAA Sample Request Setup";
    LookupPageId = "LAA Sample Request Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(2; "Sample Request Nos."; Code[20])
        {
            Caption = 'Sample Request Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(3; "Default Max. Sample Qty."; Decimal)
        {
            Caption = 'Default Max. Sample Qty.';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(4; "Max. Requests per Period"; Integer)
        {
            Caption = 'Max. Requests per Period';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(5; "Request Period"; DateFormula)
        {
            Caption = 'Request Period';
            DataClassification = CustomerContent;
        }
    }
    keys { key(PK; "Primary Key") { Clustered = true; } }
    var
        DeleteErr: Label 'The Sample Request Setup record cannot be deleted. Change its values instead.';
    trigger OnInsert()
    begin
        TestField("Primary Key", '');
    end;

    trigger OnModify()
    begin
        TestField("Primary Key", '');
    end;

    trigger OnDelete()
    begin
        Error(DeleteErr);
    end;
}