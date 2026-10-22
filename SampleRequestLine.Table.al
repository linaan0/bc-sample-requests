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
                Item: Record Item;
            begin
                if "Item No." = '' then begin
                    Description := '';
                    "Unit of Measure Code" := '';
                    "Unit Price" := 0;
                    RecalculateAmount();
                    exit;
                end;
                Item.Get("Item No.");
                if not Item."LAA Sample Allowed" then
                    Error(ItemNotAllowedErr, Item."No.", Item.Description);
                if Item.Blocked then
                    Error(ItemBlockedErr, Item."No.", Item.Description);
                Description := Item.Description;
                "Unit of Measure Code" := Item."Base Unit of Measure";
                "Unit Price" := Item."Unit Price";
                if Quantity <> 0 then
                    ValidateQuantity();
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
        key(PK; "Document No.", "Line No.")
        {
            Clustered = true;
        }
        key(Item; "Item No.")
        {
        }
    }

    var
        ItemNotAllowedErr: Label 'Item %1 (%2) is not marked as allowed for samples. Choose an item with Sample Allowed turned on.', Comment = '%1 = Item number, %2 = Item description';
        ItemBlockedErr: Label 'Item %1 (%2) is blocked. Choose an item that is not blocked.', Comment = '%1 = Item number, %2 = Item description';
        QuantityPositiveErr: Label 'Quantity must be greater than zero. Enter a quantity of at least 1 sample.';
        MaxQtyErr: Label 'Quantity %1 is too high for item %2. The maximum is %3. Reduce the quantity and try again.', Comment = '%1 = Entered quantity, %2 = Item number, %3 = Maximum allowed quantity';

    trigger OnInsert()
    begin
        CheckHeaderOpen();
        if "Line No." = 0 then
            "Line No." := GetNextLineNo();
    end;

    trigger OnModify()
    begin
        CheckHeaderOpen();
    end;

    trigger OnDelete()
    begin
        CheckHeaderOpen();
    end;

    trigger OnRename()
    begin
        CheckHeaderOpen();
    end;

    local procedure CheckHeaderOpen()
    var
        Header: Record "LAA Sample Request Header";
    begin
        Header.Get("Document No.");
        Header.EnsureOpen();
    end;

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
        Item: Record Item;
        Setup: Record "LAA Sample Request Setup";
        MaxQty: Decimal;
    begin
        if Quantity <= 0 then
            Error(QuantityPositiveErr);
        if not Item.Get("Item No.") then
            exit;
        MaxQty := Item."LAA Max. Sample Qty.";
        if (MaxQty = 0) and Setup.Get('') then
            MaxQty := Setup."Default Max. Sample Qty.";
        if (MaxQty > 0) and (Quantity > MaxQty) then
            Error(MaxQtyErr, Quantity, "Item No.", MaxQty);
    end;

    local procedure RecalculateAmount()
    begin
        "Line Amount" := Quantity * "Unit Price";
    end;
}