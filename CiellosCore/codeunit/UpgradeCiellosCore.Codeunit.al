codeunit 50105 "Upgrade Ciellos Core"
{
    Subtype = Upgrade;

    trigger OnCheckPreconditionsPerCompany()
    var
        CompanyInformation: Record "Company Information";
        CantUpgradeErr: Label 'Can not upgrade Company because Company Information Name is empty';
    begin
        CompanyInformation.Get();
        if CompanyInformation.Name = '' then
            Error(CantUpgradeErr);
    end;

    trigger OnCheckPreconditionsPerDatabase()
    var
        AppData: ModuleInfo;
        UpgNotCompatibleErr: Label 'The upgrade is not compatible';
    begin
        if NavApp.GetCurrentModuleInfo(AppData) then
            if AppData.DataVersion = Version.Create(1, 0, 0, 1) then
                Error(UpgNotCompatibleErr);
    end;

    trigger OnUpgradePerCompany()
    var
        UpgradeTagCore: Codeunit "Upgrade Tag Core";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        if UpgradeTagMgt.HasUpgradeTag(UpgradeTagCore.GetCustomerUpgradeTag()) then
            exit;

        UpgradeCustomer();

        UpgradeTagMgt.SetUpgradeTag(UpgradeTagCore.GetCustomerUpgradeTag());
    end;

    trigger OnUpgradePerDatabase()
    var
        UpgradeTagCore: Codeunit "Upgrade Tag Core";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        if UpgradeTagMgt.HasUpgradeTag(UpgradeTagCore.GetCustomerOrdeSetupUpgradeTag()) then
            exit;

        UpgradeCustomerOrderSetup();

        UpgradeTagMgt.SetUpgradeTag(UpgradeTagCore.GetCustomerOrdeSetupUpgradeTag());
    end;

    trigger OnValidateUpgradePerCompany()
    var
        Customer: Record Customer;
        Pos: Integer;
        UpdateErrForCust: Label 'Update error. Customer Name is not updated';
    begin
        if Customer.FindSet() then
            repeat
                Pos := StrPos(Customer.Name, ' 09.2023');
                if Pos = 0 then
                    Error(UpdateErrForCust);
            until Customer.Next() = 0;
    end;

    trigger OnValidateUpgradePerDatabase()
    var
        CustomerOrderSetup: Record "Customer Order Setup";
    begin
        CustomerOrderSetup.Get();
        CustomerOrderSetup.TestField("Customer Order Nos.", 'CO2');
        CustomerOrderSetup.TestField("Customer Order Payment Nos.", 'COP2');
        CustomerOrderSetup.TestField("Posted Customer Order Nos.", 'PCO2');
        CustomerOrderSetup.TestField("Pstd Cust Order Pmt Nos.", 'PCOP2');
    end;

    local procedure UpgradeCustomer()
    var
        Customer: Record Customer;
    begin
        if Customer.FindSet() then
            repeat
                Customer.Name := Customer.Name + ' 09.2023';
                Customer.Modify();
            until Customer.Next() = 0;
    end;

    local procedure UpgradeCustomerOrderSetup()
    var
        CustomerOrderSetup: Record "Customer Order Setup";
    begin
        if not CustomerOrderSetup.Get() then begin
            CustomerOrderSetup.Init();
            CustomerOrderSetup.Insert();
        end;

        CustomerOrderSetup."Customer Order Nos." := InitSeries('CO2', 'Series No. for Customer Order', true, 'CO000001', 'CO999999', '', 1, false);
        CustomerOrderSetup."Customer Order Payment Nos." := InitSeries('COP2', 'Series No. for Customer Order Payment', true, 'COP000001', 'COP999999', '', 1, false);
        CustomerOrderSetup."Posted Customer Order Nos." := InitSeries('PCO2', 'Series No. for Posted Customer Order', true, 'PCO000001', 'PCO999999', '', 1, false);
        CustomerOrderSetup."Pstd Cust Order Pmt Nos." := InitSeries('PCOP2', 'Series No. for Posted Customer Order Payment', true, 'PCOP000001', 'PCOP999999', '', 1, false);

        CustomerOrderSetup.Modify();
    end;

    local procedure InitSeries(SeriesCode: Code[20]; Description: Text[100]; ManualNos: Boolean; StartNo: Code[20]; EndNo: Code[20]; LastUsed: Code[20]; IncrBy: Integer; Gaps: Boolean): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if NoSeries.Get(SeriesCode) then
            exit(SeriesCode);

        NoSeries.Init();
        NoSeries.Code := SeriesCode;
        NoSeries.Description := Description;
        NoSeries."Default Nos." := true;
        NoSeries."Manual Nos." := ManualNos;
        NoSeries.Insert();

        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := NoSeries.Code;
        NoSeriesLine.Validate("Starting No.", StartNo);
        NoSeriesLine.Validate("Ending No.", EndNo);
        NoSeriesLine.Validate("Last No. Used", LastUsed);
        NoSeriesLine.Validate("Increment-by No.", IncrBy);
        NoSeriesLine.Validate("Allow Gaps in Nos.", Gaps);
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine.Insert(true);

        exit(NoSeries.Code);
    end;
}