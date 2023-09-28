page 50100 "Customer Order"
{
    Caption = 'Customer Order';
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "Customer Order Header";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = PageEditable;
                    ToolTip = 'Specifies the Number of Document.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Editable = PageEditable;
                    ToolTip = 'Specifies the Customer Number.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the Customer Name.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                    Editable = PageEditable;
                    ToolTip = 'Specifies the Document Date.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Editable = PageEditable;
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
            part("Customer Order Subf."; "Customer Order Subf.")
            {
                Caption = 'Lines';
                SubPageLink = "Document No." = field("No."), "Customer No." = field("Customer No.");
                ApplicationArea = All;
                Editable = PageEditable;
                UpdatePropagation = Both;
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

    trigger OnAfterGetCurrRecord()
    begin
        PageEditable := Rec.Status = Rec.Status::Open;
    end;

    var
        PageEditable: Boolean;
}