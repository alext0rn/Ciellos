codeunit 50100 "Customer Order Post"
{
    TableNo = "Customer Order Header";

    var
        PostedLbl: Label 'Document posted successfully';

    trigger OnRun()
    begin
        if Post(Rec) then
            Message(PostedLbl);
    end;

    local procedure Post(var CustomerOrderHeader: Record "Customer Order Header"): Boolean
    var
        PostedCustomerOrderHeader: Record "Posted Customer Order Header";
        CustomerOrderHelper: Codeunit "Customer Order Helper";
    begin
        if CustomerOrderHeader.Status <> CustomerOrderHeader.Status::Released then
            CustomerOrderHelper.ReleaseCustomerOrder(CustomerOrderHeader);

        CreatePostedHeader(PostedCustomerOrderHeader, CustomerOrderHeader);
        CreatePostedLines(PostedCustomerOrderHeader, CustomerOrderHeader);

        CustomerOrderHeader.Delete(true);

        exit(true);
    end;

    local procedure CreatePostedHeader(var PostedCustomerOrderHeader: Record "Posted Customer Order Header"; CustomerOrderHeader: Record "Customer Order Header")
    var
        CustomerOrderSetup: Record "Customer Order Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        CustomerOrderSetup.Get();
        CustomerOrderSetup.TestField("Posted Customer Order Nos.");
        PostedCustomerOrderHeader.Init();
        PostedCustomerOrderHeader.TransferFields(CustomerOrderHeader);
        PostedCustomerOrderHeader."No." := NoSeriesMgt.GetNextNo(CustomerOrderSetup."Posted Customer Order Nos.", 0D, true);
        PostedCustomerOrderHeader."Source No." := CustomerOrderHeader."No.";
        PostedCustomerOrderHeader.Insert();
    end;

    local procedure CreatePostedLines(PostedCustomerOrderHeader: Record "Posted Customer Order Header"; CustomerOrderHeader: Record "Customer Order Header")
    var
        CustomerOrderLine: Record "Customer Order Line";
        PostedCustomerOrderLine: Record "Posted Customer Order Line";
        LineNo: Integer;
    begin
        LineNo := 10000;
        CustomerOrderLine.SetRange("Document No.", CustomerOrderHeader."No.");
        CustomerOrderLine.SetRange("Customer No.", CustomerOrderHeader."Customer No.");
        if CustomerOrderLine.FindSet(true) then
            repeat
                CustomerOrderLine.TestField("Item No.");
                CustomerOrderLine.TestField(Quantity);
                CustomerOrderLine.TestField(Amount);

                PostedCustomerOrderLine.Init();
                PostedCustomerOrderLine.TransferFields(CustomerOrderLine);
                PostedCustomerOrderLine."Document No." := PostedCustomerOrderHeader."No.";
                PostedCustomerOrderLine."Line No." := LineNo;
                PostedCustomerOrderLine.Insert();

                LineNo += 10000;
            until CustomerOrderLine.Next() = 0;
    end;
}