table 50102 "LAA Sample Request Setup"
{
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1;"Primary Key"; Code[20])
        {
            DataClassification = ToBeClassified;
            
        }
        field(2; "Sample Request Nos."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Default Max. Sample Qty."; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Max. Request per Period"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Request Period"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
    }
    
    // keys
    // {
    //     key(Key1; {MyField})
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