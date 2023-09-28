pageextension 50101 "PTE Customer List" extends "Customer List"
{
    layout
    {
        moveafter("Name 2"; "Phone No.")
        moveafter("Phone No."; "Post Code")
        moveafter("Post Code"; "Location Code")
        modify("Phone No.")
        {
            Caption = 'Mobile';
        }
        modify("Post Code")
        {
            Caption = 'Postal Code';
        }
        modify("Location Code")
        {
            Caption = 'Area Code';
        }
        addlast(Control1)
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