table 50101 "LAA Sample Request Line"
{
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1;"Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
            
        }
        field(2; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(4; Description; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Unit of Measure Code"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(6; Quantity; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Unit Price"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Line Amount"; Decimal)
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