table 50102 "Customer Order Payment"
{
    Caption = 'Customer Order Payment';
    LookupPageId = "Customer Order Payment";

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            ClosingDates = true;
        }
        field(4; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            TableRelation = "Posted Customer Order Header"."No.";
        }
        field(5; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer."No.";
        }
        field(6; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(7; Amount; Decimal)
        {
            Caption = 'Amount';
        }
    }

    keys
    {
        key(Key1; "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        CustOrderSetup: Record "Customer Order Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        if "Document No." = '' then begin
            CustOrderSetup.Get();
            CustOrderSetup.TestField("Customer Order Payment Nos.");
            "Document No." := NoSeriesMgt.GetNextNo(CustOrderSetup."Customer Order Payment Nos.", 0D, true);
        end;

        if "Posting Date" = 0D then
            "Posting Date" := WorkDate();
    end;
}