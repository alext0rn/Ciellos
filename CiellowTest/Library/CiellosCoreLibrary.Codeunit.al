codeunit 50151 "Ciellos Core Library"
{
    var
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryRandom: Codeunit "Library - Random";

    procedure CreateCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation.Name := LibraryRandom.RandText(40);
        CompanyInformation."Phone No." := LibraryRandom.RandText(30);
        CompanyInformation."E-Mail" := LibraryRandom.RandText(30) + '@gmail.com';
        CompanyInformation.Modify();
    end;

    procedure CreateCustomerOrderSetup()
    var
        CustomerOrderSetup: Record "Customer Order Setup";
    begin
        If not CustomerOrderSetup.Get() then
            CustomerOrderSetup.Init();

        LibraryUtility.UpdateSetupNoSeriesCode(Database::"Customer Order Setup", CustomerOrderSetup.FieldNo("Customer Order Nos."));
        LibraryUtility.UpdateSetupNoSeriesCode(Database::"Customer Order Setup", CustomerOrderSetup.FieldNo("Customer Order Payment Nos."));
        LibraryUtility.UpdateSetupNoSeriesCode(Database::"Customer Order Setup", CustomerOrderSetup.FieldNo("Posted Customer Order Nos."));
        LibraryUtility.UpdateSetupNoSeriesCode(Database::"Customer Order Setup", CustomerOrderSetup.FieldNo("Pstd Cust Order Pmt Nos."));
    end;

    procedure CreateCustomerOrderWithLine(var CustomerOrderHeader: Record "Customer Order Header"; var CustomerOrderLine: Record "Customer Order Line")
    begin
        CreateCustomerOrderHeader(CustomerOrderHeader);
        CreateCustomerOrderLine(CustomerOrderLine, CustomerOrderHeader, LibraryRandom.RandIntInRange(2, 10));
    end;

    procedure CreateCustomerOrderHeader(var CustomerOrderHeader: Record "Customer Order Header")
    begin
        CustomerOrderHeader.Init();
        CustomerOrderHeader.Validate("Customer No.", LibrarySales.CreateCustomerNo());
        CustomerOrderHeader.Insert(true);
    end;

    procedure CreateCustomerOrderLine(var CustomerOrderLine: Record "Customer Order Line"; CustomerOrderHeader: Record "Customer Order Header"; Quantity: Integer)
    var
        UnitOfMeasure: Record "Unit of Measure";
        Item: Record Item;
        Location: Record Location;
    begin
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(Item, LibraryRandom.RandDec(200, 2), LibraryRandom.RandDec(200, 2));
        CustomerOrderLine.Init();
        CustomerOrderLine."Document No." := CustomerOrderHeader."No.";
        CustomerOrderLine."Customer No." := CustomerOrderHeader."Customer No.";
        CustomerOrderLine."Line No." := 10000;
        CustomerOrderLine.Validate("Item No.", Item."No.");
        CustomerOrderLine."Location Code" := LibraryWarehouse.CreateLocation(Location);
        CustomerOrderLine.Validate(Quantity, Quantity);
        CustomerOrderLine.Insert(true)
    end;

    procedure ReleaseCustomerOrder(var CustomerOrderHeader: Record "Customer Order Header")
    var
        CustomerOrderPage: TestPage "Customer Order";
    begin
        CustomerOrderPage.OpenView();
        CustomerOrderPage.GoToRecord(CustomerOrderHeader);
        CustomerOrderPage.Release.Invoke();
        CustomerOrderPage.Close();
    end;

    procedure ReOpenCustomerOrder(var CustomerOrderHeader: Record "Customer Order Header")
    var
        CustomerOrderPage: TestPage "Customer Order";
    begin
        CustomerOrderPage.OpenView();
        CustomerOrderPage.GoToRecord(CustomerOrderHeader);
        CustomerOrderPage.ReOpen.Invoke();
        CustomerOrderPage.Close();
    end;

    procedure PostCustomerOrder(var CustomerOrderHeader: Record "Customer Order Header")
    var
        CustomerOrderPage: TestPage "Customer Order";
    begin
        CustomerOrderPage.OpenView();
        CustomerOrderPage.GoToRecord(CustomerOrderHeader);
        CustomerOrderPage.Post.Invoke();
    end;
}