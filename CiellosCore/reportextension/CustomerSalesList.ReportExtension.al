reportextension 50100 "PTE Customer Sales List" extends "Customer - Sales List"
{
    dataset
    {
        add(Customer)
        {
            column(CustGroupName_; CustGroupName) { }
            column(CustGroupDescription_; CustGroupDescription) { }
            column(Last_Date_Modified; "Last Date Modified") { }

            column(CustGroupName_Label_; CustGroupName_Label) { }
            column(CustGroupDescription_Label_; CustGroupDescription_Label) { }
            column(Last_Date_Modified_Label; Last_Date_Modified_Label) { }
        }
    }

    requestpage
    {
        layout
        {
            addlast(Options)
            {
                field(CustGroupName; CustGroupName)
                {
                    Caption = 'Customer Group Name';
                    ToolTip = 'Specifies the Customers group name.';
                }
                field(CustGroupDescription; CustGroupDescription)
                {
                    Caption = 'Customer Group Description';
                    ToolTip = 'Specifies the Customers group description.';
                }
            }
        }
    }

    rendering
    {
        layout(LayoutName)
        {
            Type = RDLC;
            LayoutFile = 'reportextension/CustomerSalesList.rdl';
        }
    }

    var
        CustGroupName: Text[100];

        CustGroupDescription: Text[100];
        CustGroupName_Label: Label 'Customer group name';
        CustGroupDescription_Label: Label 'Customer group description';
        Last_Date_Modified_Label: Label 'Last Date Modified';
}