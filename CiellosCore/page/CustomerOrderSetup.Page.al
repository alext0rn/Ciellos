page 50102 "Customer Order Setup"
{
    Caption = 'Customer Order Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Customer Order Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Customer Order Nos."; Rec."Customer Order Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the No. Series for Customer Order.';
                }
                field("Customer Order Payment Nos."; Rec."Customer Order Payment Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the No. Series for Customer Order Payment.';
                }
                field("Posted Customer Order Nos."; Rec."Posted Customer Order Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the No. Series for Posted Customer Order.';
                }
                field("Pstd Cust Order Pmt Nos."; Rec."Pstd Cust Order Pmt Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the No. Series for Posted Customer Order Payments.';
                }
            }
        }
    }

    trigger OnInit()
    begin
        if Rec.IsEmpty() then
            Rec.Insert();
    end;
}