tableextension 50102 "LAA Customer Ext" extends Customer
{
    fields
    {
        field(50100; "LAA Open Sample Requests"; Integer)
        {
            Caption = 'Open Sample Requests';
            FieldClass = FlowField;
            CalcFormula = count("LAA Sample Request Header" where("Customer No." = field("No."), Status = filter(Open | "Pending Approval" | Approved)));
            Editable = false;
        }
        field(50101; "LAA Shipped Sample Requests"; Integer)
        {
            Caption = 'Shipped Sample Requests';
            FieldClass = FlowField;
            CalcFormula = count("LAA Sample Request Header" where("Customer No." = field("No."), Status = const(Shipped)));
            Editable = false;
        }
    }
}