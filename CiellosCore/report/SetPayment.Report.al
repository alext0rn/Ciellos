report 50100 "Set Payment"
{
    ProcessingOnly = true;

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(General)
                {
                    field(PostingDate_; PostingDate)
                    {
                        ApplicationArea = All;
                    }
                    field(DocumentNo; DocumentNo)
                    {
                        Editable = false;
                        ApplicationArea = All;
                    }
                    field(CustomerNo_; CustomerNo)
                    {
                        Editable = false;
                        ApplicationArea = All;
                    }
                    field(Description; Description)
                    {
                        ApplicationArea = All;
                    }
                    field(Amount_; Amount)
                    {
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            if Amount > MaxAmount then
                                Error(StrSubstNo(AmountErr, MaxAmount));
                        end;
                    }
                }
            }
        }
    }

    trigger OnPostReport()
    begin
        if Amount = 0 then
            Error(AmountZeroErr);
        if PostingDate = 0D then
            Error(PostingDateErr);
        CreatePayment();
    end;

    var
        DocumentNo: Code[20];
        CustomerNo: Code[20];
        Description: Text[100];
        PostingDate: Date;
        Amount: Decimal;
        MaxAmount: Decimal;
        AmountZeroErr: Label 'Amount should not be 0';
        AmountErr: Label 'Max amount for payment - %1', Comment = '%1 - Max amount';
        PostingDateErr: Label 'Please enter Posting Date';

    procedure SetData(PostedCustomerOrderHeader: Record "Posted Customer Order Header");
    begin
        PostingDate := PostedCustomerOrderHeader."Posting Date";
        DocumentNo := PostedCustomerOrderHeader."No.";
        CustomerNo := PostedCustomerOrderHeader."Customer No.";
        SetMaxAmount(PostedCustomerOrderHeader);
        Amount := MaxAmount;
    end;

    local procedure SetMaxAmount(PostedCustomerOrderHeader: Record "Posted Customer Order Header")
    var
        PostedCustOrderPayment: Record "Posted Customer Order Payment";
    begin
        PostedCustomerOrderHeader.CalcFields("Order Amount");
        PostedCustOrderPayment.CalcSums(Amount);
        PostedCustOrderPayment.SetRange("Source No.", PostedCustomerOrderHeader."No.");
        PostedCustOrderPayment.SetRange("Customer No.", PostedCustomerOrderHeader."Customer No.");
        if not PostedCustOrderPayment.IsEmpty() then
            MaxAmount := PostedCustomerOrderHeader."Order Amount" - PostedCustOrderPayment.Amount
        else
            MaxAmount := PostedCustomerOrderHeader."Order Amount";
    end;

    local procedure CreatePayment()
    var
        CustomerOrderPayment: Record "Customer Order Payment";
    begin
        CustomerOrderPayment.Init();
        CustomerOrderPayment."Posting Date" := PostingDate;
        CustomerOrderPayment."Source No." := DocumentNo;
        CustomerOrderPayment."Customer No." := CustomerNo;
        CustomerOrderPayment.Description := Description;
        CustomerOrderPayment.Amount := Amount;
        CustomerOrderPayment.Insert(true);
    end;
}