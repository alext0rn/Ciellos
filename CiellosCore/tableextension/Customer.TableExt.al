tableextension 50100 "PTE Customer" extends Customer
{
    fields
    {
        field(50100; "PTE Total Order Amount"; Decimal)
        {
            Caption = 'Total Order Amount';
            FieldClass = FlowField;
            CalcFormula = sum("Posted Customer Order Line".Amount where("Customer No." = field("No.")));
            Editable = false;
        }
        field(50101; "PTE Total Paid Amount"; Decimal)
        {
            Caption = 'Total Paid Amount';
            FieldClass = FlowField;
            CalcFormula = sum("Posted Customer Order Payment".Amount where("Customer No." = field("No.")));
            Editable = false;
        }
    }
}