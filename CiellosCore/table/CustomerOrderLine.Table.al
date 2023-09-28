table 50101 "Customer Order Line"
{
    Caption = 'Customer Order Line';

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            TableRelation = "Customer Order Header"."No.";
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';

            DataClassification = CustomerContent;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(4; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                Item.Get("Item No.");
                Description := Item.Description;
            end;
        }
        field(5; "Description"; Text[200])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(6; "Location Code"; Code[20])
        {
            Caption = 'Location code';
            DataClassification = CustomerContent;
            TableRelation = Location.Code;
        }
        field(7; Quantity; Integer)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if Item.Get("Item No.") then
                    Amount := Quantity * Item."Unit Price";
            end;
        }
        field(8; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Document No.", "Customer No.", "Line No.")
        {
            Clustered = true;
        }
    }
}