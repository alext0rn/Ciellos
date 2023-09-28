codeunit 50102 "Customer Order Helper"
{
    procedure CheckPayments(PostedCustomerOrderHeader: Record "Posted Customer Order Header")
    var
        PostedCustOrderPayment: Record "Posted Customer Order Payment";
        OrderPayedErr: Label 'Order is already fully payed';
    begin
        PostedCustomerOrderHeader.CalcFields("Order Amount");
        PostedCustOrderPayment.CalcSums(Amount);
        PostedCustOrderPayment.SetRange("Source No.", PostedCustomerOrderHeader."No.");
        PostedCustOrderPayment.SetRange("Customer No.", PostedCustomerOrderHeader."Customer No.");
        if not PostedCustOrderPayment.IsEmpty() then
            if PostedCustOrderPayment.Amount >= PostedCustomerOrderHeader."Order Amount" then
                Error(OrderPayedErr);
    end;

    procedure ReleaseCustomerOrder(var CustomerOrderHeader: Record "Customer Order Header")
    var
        CustomerOrderLine: Record "Customer Order Line";
    begin
        CustomerOrderHeader.CalcFields("Order Amount");
        CustomerOrderHeader.TestField("Order Amount");
        CustomerOrderHeader.TestField("Document Date");
        CustomerOrderHeader.TestField("Posting Date");
        CustomerOrderHeader.TestField("Customer No.");

        CustomerOrderLine.SetRange("Document No.", CustomerOrderHeader."No.");
        CustomerOrderLine.SetRange("Customer No.", CustomerOrderHeader."Customer No.");
        CustomerOrderLine.SetRange(Quantity, 0);
        if not CustomerOrderLine.IsEmpty() then
            CustomerOrderLine.TestField(Quantity, 0);

        CustomerOrderHeader.Status := CustomerOrderHeader.Status::Released;
        CustomerOrderHeader.Modify();
    end;

    procedure ReOpenCustomerOrder(var CustomerOrderHeader: Record "Customer Order Header")
    begin
        CustomerOrderHeader.Status := CustomerOrderHeader.Status::Open;
        CustomerOrderHeader.Modify();
    end;
}