table 50104 "Posted Customer Order Line"
{
    Caption = 'Posted Customer Order Line';

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