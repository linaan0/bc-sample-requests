table 50100 "LAA Sample Request Header"
{
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1;"No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2;"Customer No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3;"Customer Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4;"Customer E-mail"; Text[80])
        {
            DataClassification = ToBeClassified;
        }
        field(5;Project; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(6;"Request Date"; Date)
        {
            DataClassification = ToBeClassified; 
        }
        field(7;Status; Enum "LAA Sample Request Status")
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Requested By"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Total Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Approved By"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Approved Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Rejection Reason"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Tracking No."; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Shipped Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }
    
    // keys
    // {
    //     key(Key1; MyField)
    //     {
    //         Clustered = true;
    //     }
    // }
    
    fieldgroups
    {
        // Add changes to field groups here
    }
    
    var
        myInt: Integer;
    
    trigger OnInsert()
    begin
        
    end;
    
    trigger OnModify()
    begin
        
    end;
    
    trigger OnDelete()
    begin
        
    end;
    
    trigger OnRename()
    begin
        
    end;
    
}