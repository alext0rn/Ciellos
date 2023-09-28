table 50103 "Posted Customer Order Header"
{
    Caption = 'Posted Customer Order Header';
    DataCaptionFields = "No.", "Customer Name";
    LookupPageID = "Pstd Customer Order";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(3; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
            TableRelation = Customer.Name;
            ValidateTableRelation = false;
        }
        field(4; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
        field(5; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(6; "Order Amount"; Decimal)
        {
            Caption = 'Order Amount';
            FieldClass = FlowField;
            CalcFormula = sum("Posted Customer Order Line".Amount where("Document No." = field("No."), "Customer No." = field("Customer No.")));
            Editable = false;
        }
        field(7; "Total Paid Amount"; Decimal)
        {
            Caption = 'Total Paid Amount';
            FieldClass = FlowField;
            CalcFormula = sum("Posted Customer Order Payment".Amount where("Source No." = field("No."), "Customer No." = field("Customer No.")));
            Editable = false;
        }
        field(8; "Source No."; Code[20])
        {
            Caption = 'SOurce No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }
}