codeunit 50101 "Customer Order Pmt Post"
{
    TableNo = "Customer Order Payment";

    var
        PostedLbl: Label 'Payment posted successfully';
        AmountErr: Label 'You can not paid more then %1', Comment = '%1 = Max amount';
        AmountBelowZeroErr: Label 'Order already paid';

    trigger OnRun()
    begin
        if Post(Rec) then
            Message(PostedLbl);
    end;

    local procedure Post(var CustomerOrderPayment: Record "Customer Order Payment"): Boolean
    begin
        CheckCustomerOrderPayment(CustomerOrderPayment);

        CreatePostedPayment(CustomerOrderPayment);

        CustomerOrderPayment.Delete(true);

        exit(true);
    end;

    local procedure CheckCustomerOrderPayment(CustomerOrderPayment: Record "Customer Order Payment")
    var
        PostedCustomerOrder: Record "Posted Customer Order Header";
        PostedCustomerOrderPayment: Record "Posted Customer Order Payment";
        PaidAmount: Decimal;
    begin
        PostedCustomerOrderPayment.SetLoadFields(Amount);
        PostedCustomerOrderPayment.SetRange("Source No.", CustomerOrderPayment."Source No.");
        PostedCustomerOrderPayment.SetRange("Customer No.", CustomerOrderPayment."Customer No.");
        PostedCustomerOrderPayment.CalcSums(Amount);
        if not PostedCustomerOrderPayment.IsEmpty() then
            PaidAmount := PostedCustomerOrderPayment.Amount;

        PostedCustomerOrder.SetAutoCalcFields("Order Amount");
        if PostedCustomerOrder.Get(CustomerOrderPayment."Source No.") then
            if CustomerOrderPayment.Amount > (PostedCustomerOrder."Order Amount" - PaidAmount) then
                if PostedCustomerOrder."Order Amount" - PaidAmount < 0 then
                    Error(AmountBelowZeroErr)
                else
                    Error(StrSubstNo(AmountErr, PostedCustomerOrder."Order Amount" - PaidAmount));
    end;

    local procedure CreatePostedPayment(CustomerOrderPayment: Record "Customer Order Payment")
    var
        CustomerOrderSetup: Record "Customer Order Setup";
        PostedCustomerOrderPayment: Record "Posted Customer Order Payment";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        LineNo: Integer;
    begin
        if PostedCustomerOrderPayment.FindLast() then
            LineNo += PostedCustomerOrderPayment."Line No." + 10000
        else
            LineNo := 10000;
        CustomerOrderSetup.Get();
        CustomerOrderSetup.TestField("Pstd Cust Order Pmt Nos.");
        PostedCustomerOrderPayment.Init();
        PostedCustomerOrderPayment.TransferFields(CustomerOrderPayment);
        PostedCustomerOrderPayment."Document No." := NoSeriesMgt.GetNextNo(CustomerOrderSetup."Pstd Cust Order Pmt Nos.", 0D, true);
        PostedCustomerOrderPayment."Line No." := LineNo;
        PostedCustomerOrderPayment.Insert();
    end;

}