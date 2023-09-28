page 50107 "Pstd Customer Orders"
{
    Caption = 'Posted Customer Orders';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "Pstd Customer Order";
    SourceTable = "Posted Customer Order Header";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Number of Document.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Customer Number.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Customer Name.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Document Date.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Posting Date.';
                }
                field("Order Amount"; Rec."Order Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total amount in lines.';
                }
                field("Total Paid Amount"; Rec."Total Paid Amount")
                {
                    ApplicationArea = All;
                    DrillDown = true;
                    ToolTip = 'Specifies the Total Paid Amount for the Order';

                    trigger OnDrillDown()
                    var
                        PstdCustOrderPmt: Record "Posted Customer Order Payment";
                    begin
                        PstdCustOrderPmt.SetRange("Source No.", Rec."No.");
                        PstdCustOrderPmt.SetRange("Customer No.", Rec."Customer No.");
                        Page.Run(Page::"Pstd Customer Order Payment", PstdCustOrderPmt);
                    end;
                }
            }
        }
        area(FactBoxes)
        {
            part(Picture; "Customer Picture")
            {
                ApplicationArea = All;
                Caption = 'Picture';
                SubPageLink = "No." = field("Customer No.");
            }
            part(Details; "Office Customer Details")
            {
                ApplicationArea = All;
                Caption = 'Customer Details';
                SubPageLink = "No." = field("Customer No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SetPayment)
            {
                Caption = 'Set Payment';
                Image = Payment;
                ApplicationArea = All;

                trigger OnAction()
                var
                    CustomerOrderHelper: Codeunit "Customer Order Helper";
                    SetPaymentReport: Report "Set Payment";
                    OrderAmountErr: Label 'Order Amount should not be 0';
                begin
                    CustomerOrderHelper.CheckPayments(Rec);
                    SetPaymentReport.SetData(Rec);
                    SetPaymentReport.Run();
                end;
            }
        }
        area(Promoted)
        {
            actionref(SetPayment_Promoted; SetPayment) { }
        }
    }
}