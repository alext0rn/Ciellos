page 50108 "Customer Payments Subf"
{
    Caption = 'Customer Payments Subform';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = CardPart;
    SourceTable = Customer;

    layout
    {
        area(content)
        {
            field("PTE Total Order Amount"; Rec."PTE Total Order Amount")
            {
                ApplicationArea = All;
                DrillDown = true;
                ToolTip = 'Specifies the Total Order Amount for the Customer';

                trigger OnDrillDown()
                var
                    PstdCustOrder: Record "Posted Customer Order Header";
                begin
                    PstdCustOrder.SetRange("Customer No.", Rec."No.");
                    Page.Run(Page::"Pstd Customer Orders", PstdCustOrder);
                end;
            }
            field("PTE Total Paid Amount"; Rec."PTE Total Paid Amount")
            {
                ApplicationArea = All;
                DrillDown = true;
                ToolTip = 'Specifies the Total Paid Amount for the Customer';

                trigger OnDrillDown()
                var
                    PstdCustOrderPmt: Record "Posted Customer Order Payment";
                begin
                    PstdCustOrderPmt.SetRange("Customer No.", Rec."No.");
                    Page.Run(Page::"Pstd Customer Order Payment", PstdCustOrderPmt);
                end;
            }
        }
    }
}

