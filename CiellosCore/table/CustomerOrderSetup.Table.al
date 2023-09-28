table 50106 "Customer Order Setup"
{
    Caption = 'Customer Order Setup';
    DrillDownPageID = "Customer Order Setup";
    LookupPageID = "Customer Order Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Customer Order Nos."; Code[20])
        {
            Caption = 'Customer Order Nos.';
            TableRelation = "No. Series";
        }
        field(3; "Customer Order Payment Nos."; Code[20])
        {
            Caption = 'Customer Order Payment Nos.';
            TableRelation = "No. Series";
        }
        field(4; "Posted Customer Order Nos."; Code[20])
        {
            Caption = 'Posted Customer Order Nos.';
            TableRelation = "No. Series";
        }
        field(5; "Pstd Cust Order Pmt Nos."; Code[20])
        {
            Caption = 'Posted Customer Order Payment Nos.';
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
}