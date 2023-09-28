codeunit 50150 "Ciellos Core Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        CiellosCoreLibrary: Codeunit "Ciellos Core Library";
        Assert: Codeunit Assert;
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
        LibraryInventory: Codeunit "Library - Inventory";
        CustomerErr: Label 'Customers are equal';
        ReleasedStatusErr: Label 'Customer order status is not Released';
        OpenStatusErr: Label 'Customer order status is not Open';
        MessagesNotEqualErr: Label 'Messages are not equal';
        DocPostedLbl: Label 'Document posted successfully';
        PmtPostedLbl: Label 'Payment posted successfully';
        PaymentAmountErr: Label 'Amounts in Payment and Order are not equal';
        AmountsErr: Label 'Amount are not equal';
        DeleteCustomerLbl: Label 'Are you sure that you want delete this Customer?';
        ContinuePostingLbl: Label 'This Customer has Posted Customer Order. Do you want to continue posting?';

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure RecreateCustomerOrderLine()
    var
        CustomerOrderHeader: Record "Customer Order Header";
        CustomerOrderLine: Record "Customer Order Line";
    begin
        // [GIVEN]
        Initialize();

        CustomerOrderHeader.Init();
        CustomerOrderHeader.Validate("No.", LibraryRandom.RandText(20));
        CustomerOrderHeader.Validate("Customer No.", LibrarySales.CreateCustomerNo());
        CustomerOrderHeader.Insert(true);

        CiellosCoreLibrary.CreateCustomerOrderLine(CustomerOrderLine, CustomerOrderHeader, LibraryRandom.RandIntInRange(2, 10));

        // [WHEN]
        LibraryVariableStorage.Enqueue(CustomerOrderHeader."Customer No.");
        CustomerOrderHeader.Validate("Customer No.", LibrarySales.CreateCustomerNo());
        CustomerOrderHeader.Modify(true);

        // [THEN]
        CustomerOrderLine.SetRange("Document No.", CustomerOrderHeader."No.");
        CustomerOrderLine.SetRange("Customer No.", CustomerOrderHeader."Customer No.");
        CustomerOrderLine.FindFirst();
        Assert.IsFalse(CustomerOrderLine."Customer No." = LibraryVariableStorage.DequeueText(), CustomerErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('MessageHandler')]
    procedure PostCustomerOrder()
    var
        CustomerOrderHeader: Record "Customer Order Header";
        CustomerOrderLine: Record "Customer Order Line";
        PostedCustomerOrderHeader: Record "Posted Customer Order Header";
    begin
        // [GIVEN]
        Initialize();
        CiellosCoreLibrary.CreateCustomerOrderWithLine(CustomerOrderHeader, CustomerOrderLine);

        // [WHEN]
        CiellosCoreLibrary.ReleaseCustomerOrder(CustomerOrderHeader);
        CustomerOrderHeader.Get(CustomerOrderHeader."No.");
        Assert.IsTrue(CustomerOrderHeader.Status = CustomerOrderHeader.Status::Released, ReleasedStatusErr);

        CiellosCoreLibrary.ReOpenCustomerOrder(CustomerOrderHeader);
        CustomerOrderHeader.Get(CustomerOrderHeader."No.");
        Assert.IsTrue(CustomerOrderHeader.Status = CustomerOrderHeader.Status::Open, ReleasedStatusErr);

        LibraryVariableStorage.Enqueue(DocPostedLbl);
        LibraryVariableStorage.Enqueue(CustomerOrderHeader."No.");
        LibraryVariableStorage.Enqueue(CustomerOrderHeader."Customer No.");
        CiellosCoreLibrary.PostCustomerOrder(CustomerOrderHeader);

        // [THEN]
        PostedCustomerOrderHeader.SetRange("Source No.", LibraryVariableStorage.DequeueText());
        PostedCustomerOrderHeader.SetRange("Customer No.", LibraryVariableStorage.DequeueText());
        if PostedCustomerOrderHeader.IsEmpty() then
            asserterror;
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('MessageHandler,SetPaymentReportHelper')]
    procedure PostCustomerOrderPayment()
    var
        CustomerOrderHeader: Record "Customer Order Header";
        CustomerOrderLine: Record "Customer Order Line";
        PostedCustomerOrderHeader: Record "Posted Customer Order Header";
        PostedCustomerOrderPayment: Record "Posted Customer Order Payment";
    begin
        // [GIVEN]
        Initialize();
        CiellosCoreLibrary.CreateCustomerOrderWithLine(CustomerOrderHeader, CustomerOrderLine);

        LibraryVariableStorage.Enqueue(DocPostedLbl);
        LibraryVariableStorage.Enqueue(CustomerOrderHeader."No.");
        LibraryVariableStorage.Enqueue(CustomerOrderHeader."Customer No.");
        CiellosCoreLibrary.PostCustomerOrder(CustomerOrderHeader);

        // [WHEN]
        PostedCustomerOrderHeader.SetRange("Source No.", LibraryVariableStorage.DequeueText());
        PostedCustomerOrderHeader.SetRange("Customer No.", LibraryVariableStorage.DequeueText());
        PostedCustomerOrderHeader.FindLast();

        PostedCustomerOrderHeader.CalcFields("Order Amount");
        LibraryVariableStorage.Enqueue(PostedCustomerOrderHeader."Order Amount");

        CreateCustOrderPayment(PostedCustomerOrderHeader);
        LibraryVariableStorage.Enqueue(PmtPostedLbl);
        PostCustomerOrderPayment(PostedCustomerOrderHeader."No.", PostedCustomerOrderHeader."Customer No.");

        // [THEN]
        FindPostedCustomerOrderPayment(PostedCustomerOrderPayment, PostedCustomerOrderHeader."No.", PostedCustomerOrderHeader."Customer No.");
        Assert.AreEqual(PostedCustomerOrderPayment.Amount, PostedCustomerOrderHeader."Order Amount", PaymentAmountErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('MessageHandler,SetPaymentReportHelper,PstdCustomerOrderHandler,PstdCustomerOrderPaymentHandler')]
    procedure CheckOnDrillDownPage()
    var
        CustomerOrderHeader: Record "Customer Order Header";
        CustomerOrderLine: Record "Customer Order Line";
        PostedCustomerOrderHeader: Record "Posted Customer Order Header";
        PostedCustomerOrderPayment: Record "Posted Customer Order Payment";
    begin
        // [GIVEN]
        Initialize();
        CiellosCoreLibrary.CreateCustomerOrderWithLine(CustomerOrderHeader, CustomerOrderLine);

        LibraryVariableStorage.Enqueue(DocPostedLbl);
        LibraryVariableStorage.Enqueue(CustomerOrderHeader."No.");
        LibraryVariableStorage.Enqueue(CustomerOrderHeader."Customer No.");
        CiellosCoreLibrary.PostCustomerOrder(CustomerOrderHeader);

        PostedCustomerOrderHeader.SetRange("Source No.", LibraryVariableStorage.DequeueText());
        PostedCustomerOrderHeader.SetRange("Customer No.", LibraryVariableStorage.DequeueText());
        PostedCustomerOrderHeader.FindLast();

        PostedCustomerOrderHeader.CalcFields("Order Amount");
        LibraryVariableStorage.Enqueue(PostedCustomerOrderHeader."Order Amount");

        CreateCustOrderPayment(PostedCustomerOrderHeader);
        LibraryVariableStorage.Enqueue(PmtPostedLbl);
        PostCustomerOrderPayment(PostedCustomerOrderHeader."No.", PostedCustomerOrderHeader."Customer No.");

        // [WHEN]
        PostedCustomerOrderHeader.CalcFields("Total Paid Amount");
        LibraryVariableStorage.Enqueue(PostedCustomerOrderHeader."Order Amount");
        LibraryVariableStorage.Enqueue(PostedCustomerOrderHeader."Total Paid Amount");
        DrillDownCustomerCardPage(PostedCustomerOrderHeader."Customer No.");

        LibraryVariableStorage.Enqueue(PostedCustomerOrderHeader."Order Amount");
        LibraryVariableStorage.Enqueue(PostedCustomerOrderHeader."Total Paid Amount");
        DrillDownCustomerListPage(PostedCustomerOrderHeader."Customer No.");

        LibraryVariableStorage.Enqueue(PostedCustomerOrderHeader."Order Amount");
        LibraryVariableStorage.Enqueue(PostedCustomerOrderHeader."Total Paid Amount");
        DrillDownCustomerListPage(PostedCustomerOrderHeader."Customer No.");

        LibraryVariableStorage.Enqueue(PostedCustomerOrderHeader."Order Amount");
        LibraryVariableStorage.Enqueue(PostedCustomerOrderHeader."Total Paid Amount");
        DrillDownCustomerPaymentSubf(PostedCustomerOrderHeader."Customer No.");

        // [THEN]
        // No errors expected
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('ConfirmFalseHandler')]
    procedure CheckCustomerOnDeleteEventFalse()
    var
        Customer: Record Customer;
    begin
        // [GIVEN]
        LibrarySales.CreateCustomer(Customer);

        // [WHEN]
        // Confirm = false 
        LibraryVariableStorage.Enqueue(DeleteCustomerLbl);

        // [THEN]
        asserterror Customer.Delete(true);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('ConfirmTrueHandler')]
    procedure CheckCustomerOnDeleteEventTrue()
    var
        Customer: Record Customer;
    begin
        // [GIVEN]
        LibrarySales.CreateCustomer(Customer);

        // [WHEN]
        // Confirm = true 
        LibraryVariableStorage.Enqueue(DeleteCustomerLbl);

        // [THEN]
        // No errors expected
        Customer.Delete(true);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('MessageHandler,ConfirmFalseHandler')]
    procedure CheckSalesOrderEventFalse()
    var
        CustomerOrderHeader: Record "Customer Order Header";
        CustomerOrderLine: Record "Customer Order Line";
        PostedCustomerOrderHeader: Record "Posted Customer Order Header";
        SalesSetup: Record "Sales & Receivables Setup";
        SalesHeader: Record "Sales Header";
    begin
        // [GIVEN]
        Initialize();

        CiellosCoreLibrary.CreateCustomerOrderWithLine(CustomerOrderHeader, CustomerOrderLine);

        LibraryVariableStorage.Enqueue(DocPostedLbl);
        CiellosCoreLibrary.PostCustomerOrder(CustomerOrderHeader);

        // [WHEN]
        LibrarySales.CreateSalesOrderForCustomerNo(SalesHeader, CustomerOrderHeader."Customer No.");
        LibraryVariableStorage.Enqueue(ContinuePostingLbl);

        // [THEN]
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ConfirmTrueHandler')]
    procedure CheckSalesOrderEventTrue()
    var
        CustomerOrderHeader: Record "Customer Order Header";
        CustomerOrderLine: Record "Customer Order Line";
        PostedCustomerOrderHeader: Record "Posted Customer Order Header";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        // [GIVEN]
        Initialize();

        CiellosCoreLibrary.CreateCustomerOrderWithLine(CustomerOrderHeader, CustomerOrderLine);

        LibraryVariableStorage.Enqueue(DocPostedLbl);
        CiellosCoreLibrary.PostCustomerOrder(CustomerOrderHeader);

        // [WHEN]
        LibrarySales.CreateSalesOrderForCustomerNo(SalesHeader, CustomerOrderHeader."Customer No.");
        CreatePostingSetup(SalesHeader);

        LibraryVariableStorage.Enqueue(ContinuePostingLbl);
        LibraryVariableStorage.Enqueue(SalesHeader."No.");
        LibraryVariableStorage.Enqueue(SalesHeader."Sell-to Customer No.");
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN]
        SalesInvoiceHeader.SetRange("Order No.", LibraryVariableStorage.DequeueText());
        SalesInvoiceHeader.SetRange("Sell-to Customer No.", LibraryVariableStorage.DequeueText());
        SalesInvoiceHeader.FindFirst();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('MessageHandler,SetPaymentReportHelper')]
    procedure CallCustomerOrderReportFromPage()
    var
        CompanyInfo: Record "Company Information";
        CustomerOrderHeader: Record "Customer Order Header";
        CustomerOrderLine: Record "Customer Order Line";
        PostedCustomerOrderHeader: Record "Posted Customer Order Header";
        PostedCustomerOrderPayment: Record "Posted Customer Order Payment";
    begin
        // [GIVEN]
        Initialize();
        CompanyInfo.Get();
        CiellosCoreLibrary.CreateCustomerOrderWithLine(CustomerOrderHeader, CustomerOrderLine);

        LibraryVariableStorage.Enqueue(DocPostedLbl);
        LibraryVariableStorage.Enqueue(CustomerOrderHeader."No.");
        LibraryVariableStorage.Enqueue(CustomerOrderHeader."Customer No.");
        CiellosCoreLibrary.PostCustomerOrder(CustomerOrderHeader);

        PostedCustomerOrderHeader.SetRange("Source No.", LibraryVariableStorage.DequeueText());
        PostedCustomerOrderHeader.SetRange("Customer No.", LibraryVariableStorage.DequeueText());
        PostedCustomerOrderHeader.FindLast();

        PostedCustomerOrderHeader.CalcFields("Order Amount");
        LibraryVariableStorage.Enqueue(PostedCustomerOrderHeader."Order Amount");

        CreateCustOrderPayment(PostedCustomerOrderHeader);
        LibraryVariableStorage.Enqueue(PmtPostedLbl);
        PostCustomerOrderPayment(PostedCustomerOrderHeader."No.", PostedCustomerOrderHeader."Customer No.");

        // [WHEN]
        RunCustomerOrderReport(PostedCustomerOrderHeader);

        // [THEN]
        // No errors expected
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('MessageHandler,SetPaymentReportHelper')]
    procedure CheckCustomerOrderReport()
    var
        CompanyInfo: Record "Company Information";
        CustomerOrderHeader: Record "Customer Order Header";
        CustomerOrderLine: Record "Customer Order Line";
        PostedCustomerOrderHeader: Record "Posted Customer Order Header";
        PostedCustomerOrderPayment: Record "Posted Customer Order Payment";
    begin
        // [GIVEN]
        Initialize();
        CompanyInfo.Get();
        CiellosCoreLibrary.CreateCustomerOrderWithLine(CustomerOrderHeader, CustomerOrderLine);

        LibraryVariableStorage.Enqueue(DocPostedLbl);
        LibraryVariableStorage.Enqueue(CustomerOrderHeader."No.");
        LibraryVariableStorage.Enqueue(CustomerOrderHeader."Customer No.");
        CiellosCoreLibrary.PostCustomerOrder(CustomerOrderHeader);

        PostedCustomerOrderHeader.SetRange("Source No.", LibraryVariableStorage.DequeueText());
        PostedCustomerOrderHeader.SetRange("Customer No.", LibraryVariableStorage.DequeueText());
        PostedCustomerOrderHeader.FindLast();

        PostedCustomerOrderHeader.CalcFields("Order Amount");
        LibraryVariableStorage.Enqueue(PostedCustomerOrderHeader."Order Amount");

        CreateCustOrderPayment(PostedCustomerOrderHeader);
        LibraryVariableStorage.Enqueue(PmtPostedLbl);
        PostCustomerOrderPayment(PostedCustomerOrderHeader."No.", PostedCustomerOrderHeader."Customer No.");
        FindPostedCustomerOrderPayment(PostedCustomerOrderPayment, PostedCustomerOrderHeader."No.", PostedCustomerOrderHeader."Customer No.");

        // [WHEN]
        LibraryReportDataset.RunReportAndLoad(Report::"Posted Customer Order", PostedCustomerOrderHeader, '');

        // [THEN]
        LibraryReportDataset.AssertElementWithValueExists('CompanyName', CompanyInfo.Name);
        LibraryReportDataset.AssertElementWithValueExists('CompanyPhone', CompanyInfo."Phone No.");
        LibraryReportDataset.AssertElementWithValueExists('CompanyEmail', CompanyInfo."E-Mail");
        LibraryReportDataset.AssertElementWithValueExists('No_', PostedCustomerOrderHeader."No.");
        LibraryReportDataset.AssertElementWithValueExists('Customer_No_', PostedCustomerOrderHeader."Customer No.");
        LibraryReportDataset.AssertElementWithValueExists('Customer_Name_', PostedCustomerOrderHeader."Customer Name");
        LibraryReportDataset.AssertElementWithValueExists('Posting_Date_', Format(PostedCustomerOrderPayment."Posting Date", 0, '<Month,2>/<Day,2>/<Year>'));
        LibraryReportDataset.AssertElementWithValueExists('Description_', PostedCustomerOrderPayment.Description);
        LibraryReportDataset.AssertElementWithValueExists('Amount_', Format(PostedCustomerOrderPayment.Amount, 0, '<Precision,2:2><Standard Format,0>'));
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
        Assert.AreEqual(Message, LibraryVariableStorage.DequeueText(), MessagesNotEqualErr);
    end;

    [RequestPageHandler]
    procedure SetPaymentReportHelper(var RequestPage: TestRequestPage "Set Payment")
    begin
        RequestPage.Description.SetValue(LibraryRandom.RandText(30));
        RequestPage.Amount_.SetValue(LibraryVariableStorage.DequeueDecimal());
        RequestPage.OK().Invoke();
    end;

    [PageHandler]
    procedure PstdCustomerOrderHandler(var Page: TestPage "Pstd Customer Orders")
    begin
        Page.First();
        Assert.IsTrue(Page."Order Amount".Value = Format(LibraryVariableStorage.DequeueDecimal()), AmountsErr);
    end;

    [PageHandler]
    procedure PstdCustomerOrderPaymentHandler(var Page: TestPage "Pstd Customer Order Payment")
    begin
        Page.First();
        Assert.IsTrue(Page.Amount.Value = Format(LibraryVariableStorage.DequeueDecimal()), AmountsErr);
    end;

    [ConfirmHandler]
    procedure ConfirmFalseHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Assert.AreEqual(Question, LibraryVariableStorage.DequeueText(), MessagesNotEqualErr);
        Reply := false;
    end;

    [ConfirmHandler]
    procedure ConfirmTrueHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Assert.AreEqual(Question, LibraryVariableStorage.DequeueText(), MessagesNotEqualErr);
        Reply := true;
    end;

    [RequestPageHandler]
    procedure CustomerOrderReportHandler(var RequestPage: TestRequestPage "Posted Customer Order")
    begin
        RequestPage.OK().Invoke();
    end;


    local procedure Initialize()
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        CiellosCoreLibrary.CreateCompanyInformation();
        CiellosCoreLibrary.CreateCustomerOrderSetup();

        SalesSetup.Get();
        LibraryUtility.UpdateSetupNoSeriesCode(Database::"Sales & Receivables Setup", SalesSetup.FieldNo("Order Nos."));
        LibraryUtility.UpdateSetupNoSeriesCode(Database::"Sales & Receivables Setup", SalesSetup.FieldNo("Posted Shipment Nos."));
        LibraryUtility.UpdateSetupNoSeriesCode(Database::"Sales & Receivables Setup", SalesSetup.FieldNo("Posted Invoice Nos."));
    end;

    local procedure CreateCustOrderPayment(PostedCustomerOrderHeader: Record "Posted Customer Order Header")
    var
        PostedCustomerOrderPage: TestPage "Pstd Customer Order";
    begin
        PostedCustomerOrderPage.OpenView();
        PostedCustomerOrderPage.GoToRecord(PostedCustomerOrderHeader);
        PostedCustomerOrderPage.SetPayment.Invoke();
    end;

    local procedure PostCustomerOrderPayment(SourceNo: Code[20]; CustomerNo: Code[20])
    var
        CustomerOrderPayment: Record "Customer Order Payment";
        CustomerOrderPaymentPage: TestPage "Customer Order Payment";
    begin
        CustomerOrderPayment.SetRange("Source No.", SourceNo);
        CustomerOrderPayment.SetRange("Customer No.");
        CustomerOrderPayment.FindFirst();

        CustomerOrderPaymentPage.OpenView();
        CustomerOrderPaymentPage.GoToRecord(CustomerOrderPayment);
        CustomerOrderPaymentPage.Post.Invoke();
        CustomerOrderPaymentPage.Close();
    end;

    local procedure FindPostedCustomerOrderPayment(var PostedCustomerOrderPayment: Record "Posted Customer Order Payment"; SourceNo: Code[20]; CustomerNo: Code[20])
    begin
        PostedCustomerOrderPayment.SetRange("Source No.", SourceNo);
        PostedCustomerOrderPayment.SetRange("Customer No.");
        PostedCustomerOrderPayment.FindFirst();
    end;

    local procedure DrillDownCustomerCardPage(CustomerNo: Code[20])
    var
        Customer: Record Customer;
        CustomerPage: TestPage "Customer Card";
    begin
        Customer.Get(CustomerNo);

        CustomerPage.OpenView();
        CustomerPage.GoToRecord(Customer);
        CustomerPage."PTE Total Order Amount".Drilldown();
        CustomerPage."PTE Total Paid Amount".Drilldown();
        CustomerPage.Close();
    end;

    local procedure DrillDownCustomerListPage(CustomerNo: Code[20])
    var
        Customer: Record Customer;
        CustomerPage: TestPage "Customer List";
    begin
        Customer.Get(CustomerNo);

        CustomerPage.OpenView();
        CustomerPage.GoToRecord(Customer);
        CustomerPage."PTE Total Order Amount".Drilldown();
        CustomerPage."PTE Total Paid Amount".Drilldown();
        CustomerPage.Close();
    end;

    local procedure DrillDownCustomerPaymentSubf(CustomerNo: Code[20])
    var
        Customer: Record Customer;
        CustomerPage: TestPage "Customer List";
    begin
        Customer.Get(CustomerNo);

        CustomerPage.OpenView();
        CustomerPage.GoToRecord(Customer);
        CustomerPage."Customer Payments Subf"."PTE Total Order Amount".Drilldown();
        CustomerPage."Customer Payments Subf"."PTE Total Paid Amount".Drilldown();
        CustomerPage.Close();
    end;

    local procedure RunCustomerOrderReport(PostedCustomerOrderHeader: Record "Posted Customer Order Header")
    var
        PostedCustomerOrderPage: TestPage "Pstd Customer Order";
    begin
        PostedCustomerOrderPage.OpenView();
        PostedCustomerOrderPage.GoToRecord(PostedCustomerOrderHeader);
        PostedCustomerOrderPage.PostedCustOrderReport.Invoke();
        PostedCustomerOrderPage.Close();
    end;

    local procedure CreatePostingSetup(SalesHeader: Record "Sales Header")
    var
        GeneralPostingSetup: Record "General Posting Setup";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        InventoryPostingSetup: Record "Inventory Posting Setup";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();
        Item.Get(SalesLine."No.");

        LibraryInventory.CreateInventoryPostingSetup(InventoryPostingSetup, SalesLine."Location Code", Item."Inventory Posting Group");
        InventoryPostingSetup."Inventory Account" := LibraryERM.CreateGLAccountNo();
        InventoryPostingSetup.Modify();

        LibraryERM.CreateGeneralPostingSetup(GeneralPostingSetup, SalesHeader."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group");
        GeneralPostingSetup."COGS Account" := LibraryERM.CreateGLAccountNo();
        GeneralPostingSetup."Sales Account" := LibraryERM.CreateGLAccountNo();
        GeneralPostingSetup.Modify();
    end;
}