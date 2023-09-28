codeunit 50103 "Event Helper"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure OnBeforePostSalesDoc(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var HideProgressWindow: Boolean; var IsHandled: Boolean)
    var
        PostedCustomerOrder: Record "Posted Customer Order Header";
        ContinuePostingLbl: Label 'This Customer has Posted Customer Order. Do you want to continue posting?';
    begin
        PostedCustomerOrder.SetRange("Customer No.", SalesHeader."Sell-to Customer No.");
        if not PostedCustomerOrder.IsEmpty() then
            if not Confirm(ContinuePostingLbl) then
                Error('');
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteCustomer(var Rec: Record Customer; RunTrigger: Boolean)
    var
        DeleteCustomerLbl: Label 'Are you sure that you want delete this Customer?';
    begin
        if not Confirm(DeleteCustomerLbl) then
            Error('');
    end;
}