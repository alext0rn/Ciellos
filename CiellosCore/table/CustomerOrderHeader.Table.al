table 50100 "Customer Order Header"
{
    Caption = 'Customer Order Header';
    DataCaptionFields = "No.", "Customer Name";
    LookupPageID = "Customer Order";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                CustOrderSetup: Record "Customer Order Setup";
                NoSeriesMgt: Codeunit NoSeriesManagement;
            begin
                if "No." <> xRec."No." then begin
                    CustOrderSetup.Get();
                    NoSeriesMgt.TestManual(CustOrderSetup."Customer Order Nos.");
                end;

                RecreateLines();
            end;
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                if Customer.Get("Customer No.") then
                    "Customer Name" := Customer.Name;

                RecreateLines();
            end;
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
            CalcFormula = sum("Customer Order Line".Amount where("Document No." = field("No."), "Customer No." = field("Customer No.")));
            Editable = false;
        }
        field(7; Status; Enum "Customer Order Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        CustOrderSetup: Record "Customer Order Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        if "No." = '' then begin
            CustOrderSetup.Get();
            CustOrderSetup.TestField("Customer Order Nos.");
            "No." := NoSeriesMgt.GetNextNo(CustOrderSetup."Customer Order Nos.", 0D, true);
        end;

        if "Document Date" = 0D then
            "Document Date" := WorkDate();
        if "Posting Date" = 0D then
            "Posting Date" := WorkDate();
    end;

    trigger OnDelete()
    begin
        DeleteLines();
    end;

    local procedure LineExist(): Boolean
    var
        CustomerOrderLine: Record "Customer Order Line";
    begin
        CustomerOrderLine.SetRange("Document No.", xRec."No.");
        CustomerOrderLine.SetRange("Customer No.", xRec."Customer No.");
        exit(not CustomerOrderLine.IsEmpty());
    end;

    local procedure RecreateLines()
    var
        CustomerOrderLine: Record "Customer Order Line";
        TempCustomerOrderLine: Record "Customer Order Line" temporary;
    begin
        if not LineExist() then
            exit;

        if (Rec."No." = xRec."No.") and (Rec."Customer No." = xRec."Customer No.") then
            exit;

        CustomerOrderLine.SetRange("Document No.", xRec."No.");
        CustomerOrderLine.SetRange("Customer No.", xRec."Customer No.");
        if CustomerOrderLine.FindSet() then
            repeat
                TempCustomerOrderLine.Init();
                TempCustomerOrderLine.TransferFields(CustomerOrderLine);
                TempCustomerOrderLine."Document No." := Rec."No.";
                TempCustomerOrderLine."Customer No." := Rec."Customer No.";
                TempCustomerOrderLine.Insert(true);
            until CustomerOrderLine.Next() = 0;

        CustomerOrderLine.DeleteAll(true);

        if TempCustomerOrderLine.FindSet() then
            repeat
                CustomerOrderLine.Init();
                CustomerOrderLine.TransferFields(TempCustomerOrderLine);
                CustomerOrderLine.Insert();
            until TempCustomerOrderLine.Next() = 0;
    end;

    local procedure DeleteLines()
    var
        CustomerOrderLine: Record "Customer Order Line";
    begin
        CustomerOrderLine.SetRange("Document No.", Rec."No.");
        CustomerOrderLine.SetRange("Customer No.", Rec."Customer No.");
        if not CustomerOrderLine.IsEmpty() then
            CustomerOrderLine.DeleteAll(true);
    end;
}