page 50211 "LAA Sample Request Setup"
{
    PageType = Card;
    SourceTable = "LAA Sample Request Setup";
    Caption = 'Sample Request Setup';
    ApplicationArea = All;
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Sample Request Nos."; Rec."Sample Request Nos.") { ApplicationArea = All; ToolTip = 'Specifies the number series used for sample requests.'; }
                field("Default Max. Sample Qty."; Rec."Default Max. Sample Qty.") { ApplicationArea = All; ToolTip = 'Specifies the default maximum quantity when an item has no specific maximum.'; }
                field("Max. Requests per Period"; Rec."Max. Requests per Period") { ApplicationArea = All; ToolTip = 'Specifies the maximum number of requests per customer in the configured period; zero means no limit.'; }
                field("Request Period"; Rec."Request Period") { ApplicationArea = All; ToolTip = 'Specifies the period used to count requests, for example -30D.'; }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get('') then begin
            Rec.Init();
            Rec."Primary Key" := '';
            Rec.Insert(true);
        end;
    end;
}