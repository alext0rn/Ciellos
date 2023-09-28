pageextension 50100 "PTE Customer Card" extends "Customer Card"
{
    layout
    {
        moveafter("Search Name"; "Phone No.")
        moveafter("Phone No."; "E-Mail")
        moveafter("E-Mail"; "VAT Registration No.")
        modify("Phone No.")
        {
            Caption = 'Mobile';
        }
        modify("E-Mail")
        {
            Caption = 'E-mail';
        }
        modify("VAT Registration No.")
        {
            Caption = 'VAT Reg. Number';
        }
        addlast(Payments)
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
        addlast(factboxes)
        {
            part("Customer Payments Subf"; "Customer Payments Subf")
            {
                Caption = 'Customer Order Payments';
                ApplicationArea = All;
                SubPageLink = "No." = FIELD("No.");
            }
        }
    }
}