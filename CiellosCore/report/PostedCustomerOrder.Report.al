report 50101 "Posted Customer Order"
{
    ApplicationArea = All;
    DefaultRenderingLayout = RDLCLayout;
    UseRequestPage = false;

    dataset
    {
        dataitem("Posted Customer Order Header"; "Posted Customer Order Header")
        {
            column(CompanyName; CompanyInformation.Name) { }
            column(CompanyPhone; CompanyInformation."Phone No.") { }
            column(CompanyEmail; CompanyInformation."E-Mail") { }
            column(No_; "No.") { }
            column(Customer_No_; "Customer No.") { }
            column(Customer_Name_; "Customer Name") { }
            dataitem("Posted Customer Order Payment"; "Posted Customer Order Payment")
            {
                DataItemLink = "Source No." = field("No."), "Customer No." = field("Customer No.");

                column(Posting_Date_; FormatDate("Posting Date")) { }
                column(Description_; Description) { }
                column(Amount_; FormatDecimals(Amount)) { }
            }

            trigger OnPreDataItem()
            begin
                if DocumentNo <> '' then
                    "Posted Customer Order Header".SetRange("No.", DocumentNo);
            end;
        }
    }

    rendering
    {
        layout(RDLCLayout)
        {
            Type = RDLC;
            LayoutFile = 'report/PostedCustomerOrder.rdl';
        }
    }

    trigger OnInitReport()
    begin
        CompanyInformation.Get();
    end;

    var
        CompanyInformation: Record "Company Information";
        DocumentNo: Code[20];

    procedure SetRecord(PostedCustomerOrderHeader: Record "Posted Customer Order Header")
    begin
        DocumentNo := PostedCustomerOrderHeader."No.";
    end;

    local procedure FormatDecimals(DecValue: Decimal): Text
    begin
        exit(Format(DecValue, 0, '<Precision,2:2><Standard Format,0>'));
    end;

    local procedure FormatDate(DateValue: Date): Text
    begin
        exit(Format(DateValue, 0, '<Month,2>/<Day,2>/<Year>'))
    end;
}