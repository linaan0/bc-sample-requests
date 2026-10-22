report 50217 "LAA Sample Request Report"
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
            column(ReportTitleLbl; ReportTitleLbl) { }
            column(RequestNoLbl; RequestNoLbl) { }
            column(RequestDateLbl; RequestDateLbl) { }
            column(CustomerLbl; CustomerLbl) { }
            column(ContactEmailLbl; ContactEmailLbl) { }
            column(ItemNoLbl; ItemNoLbl) { }
            column(DescriptionLbl; DescriptionLbl) { }
            column(QuantityLbl; QuantityLbl) { }
            column(UnitOfMeasureLbl; UnitOfMeasureLbl) { }

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
    var
        ReportTitleLbl: Label 'Sample Request';
        RequestNoLbl: Label 'Request No.';
        RequestDateLbl: Label 'Request Date';
        CustomerLbl: Label 'Customer';
        ContactEmailLbl: Label 'Contact E-mail';
        ItemNoLbl: Label 'Item No.';
        DescriptionLbl: Label 'Description';
        QuantityLbl: Label 'Quantity';
        UnitOfMeasureLbl: Label 'Unit of Measure';
}