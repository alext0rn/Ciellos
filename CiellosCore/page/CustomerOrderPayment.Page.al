page 50104 "Customer Order Payment"
{
    Caption = 'Customer Order Payment';
    PageType = Worksheet;
    ApplicationArea = All;
    UsageCategory = Documents;
    AutoSplitKey = true;
    SourceTable = "Customer Order Payment";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Posting Date.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Document No.';
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Source No.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Customer No.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Description.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Amount.';
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
            action(Post)
            {
                Caption = 'Post Payment';
                ToolTip = 'Specifies the Post Payment action.';
                ApplicationArea = All;
                Image = Post;

                trigger OnAction()
                begin
                    Codeunit.Run(Codeunit::"Customer Order Pmt Post", Rec);
                end;
            }
        }
        area(Promoted)
        {
            actionref(Post_Promoted; Post) { }
        }
    }
}