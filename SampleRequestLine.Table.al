table 50201 "LAA Sample Request Line"
{
    Caption = 'Sample Request Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            TableRelation = "LAA Sample Request Header"."No.";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item where("LAA Sample Allowed" = const(true), Blocked = const(false));
            trigger OnValidate()
            var
                ItemRec: Record Item;
            begin
                if "Item No." = '' then begin
                    Description := '';
                    "Unit of Measure Code" := '';
                    "Unit Price" := 0;
                    "Line Amount" := 0;
                    exit;
                end;
                ItemRec.Get("Item No.");
                if not ItemRec."LAA Sample Allowed" then
                    Error('Item %1 (%2) is not marked as allowed for samples. Choose an eligible item.', ItemRec."No.", ItemRec.Description);
                if ItemRec.Blocked then
                    Error('Item %1 (%2) is blocked. Choose an unblocked item.', ItemRec."No.", ItemRec.Description);
                Description := ItemRec.Description;
                "Unit of Measure Code" := ItemRec."Base Unit of Measure";
                "Unit Price" := ItemRec."Unit Price";
                RecalculateAmount();
            end;
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(6; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            trigger OnValidate()
            begin
                ValidateQuantity();
                RecalculateAmount();
            end;
        }
        field(7; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8; "Line Amount"; Decimal)
        {
            Caption = 'Line Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Document No.", "Line No.") { Clustered = true; }
        key(Item; "Item No.") { }
    }

    local procedure GetNextLineNo(): Integer
    var
        SampleLine: Record "LAA Sample Request Line";
    begin
        SampleLine.SetRange("Document No.", "Document No.");
        if SampleLine.FindLast() then
            exit(SampleLine."Line No." + 10000);
        exit(10000);
    end;

    local procedure ValidateQuantity()
    var
        ItemRec: Record Item;
        Setup: Record "LAA Sample Request Setup";
        MaxQty: Decimal;
        MaxQtyErr: Label 'Quantity must be greater than zero and no more than %1 for item %2. Reduce the quantity and try again.', Comment = '%1 = Maximum allowed quantity, %2 = Item number';
    begin
        if Quantity <= 0 then
            Error('Quantity must be greater than zero.');
        if not ItemRec.Get("Item No.") then
            exit;
        MaxQty := ItemRec."LAA Max. Sample Qty.";
        if MaxQty = 0 then begin
            if Setup.Get('') then
                MaxQty := Setup."Default Max. Sample Qty.";
        end;
        if (MaxQty > 0) and (Quantity > MaxQty) then
            Error(MaxQtyErr, MaxQty, "Item No.");
    end;

    local procedure RecalculateAmount()
    begin
        "Line Amount" := Quantity * "Unit Price";
    end;
}