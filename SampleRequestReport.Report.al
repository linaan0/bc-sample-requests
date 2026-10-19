report 50117 "LAA Sample Request Report"
{
    Caption = 'Sample Request';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = 'LAA Sample Request Report.rdl';

    dataset
    {
        dataitem(Header; "LAA Sample Request Header")
        {
            RequestFilterFields = "No.", "Customer No.", "Request Date";
            column(CompanyName; CompanyProperty.DisplayName()) { }
            column(RequestNo; "No.") { }
            column(RequestDate; "Request Date") { }
            column(CustomerName; "Customer Name") { }
            column(ContactEmail; "Contact E-mail") { }

            dataitem(Line; "LAA Sample Request Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Line No.");
                column(ItemNo; "Item No.") { }
                column(LineDescription; Description) { }
                column(LineQuantity; Quantity) { }
                column(UnitOfMeasureCode; "Unit of Measure Code") { }
            }
        }
    }
}