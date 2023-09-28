page 50101 "Customer Orders"
{
    Caption = 'Customer Orders';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "Customer Order";
    SourceTable = "Customer Order Header";
    Editable = false;

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
                    ToolTip = 'Specifies the Customer No.';
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
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Status of Document.';
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
            action(Release)
            {
                Caption = 'Release';
                ToolTip = 'Specifies the Release action.';
                ApplicationArea = All;
                Enabled = Rec.Status = Rec.Status::Open;
                Image = ReleaseDoc;

                trigger OnAction()
                var
                    CustomerOrderHelper: Codeunit "Customer Order Helper";
                begin
                    CustomerOrderHelper.ReleaseCustomerOrder(Rec);
                end;
            }
            action(ReOpen)
            {
                Caption = 'ReOpen';
                ToolTip = 'Specifies the ReOpen action.';
                ApplicationArea = All;
                Enabled = Rec.Status = Rec.Status::Released;
                Image = ReOpen;

                trigger OnAction()
                var
                    CustomerOrderHelper: Codeunit "Customer Order Helper";
                begin
                    CustomerOrderHelper.ReOpenCustomerOrder(Rec);
                end;
            }
            action(Post)
            {
                Caption = 'Post';
                ToolTip = 'Specifies the Post action.';
                ApplicationArea = All;
                Image = Post;

                trigger OnAction()
                begin
                    Codeunit.Run(Codeunit::"Customer Order Post", Rec);
                end;
            }
        }
        area(Promoted)
        {
            actionref(Release_Promoted; Release) { }
            actionref(ReOpen_Promoted; ReOpen) { }
            actionref(Post_Promoted; Post) { }
        }
    }
}