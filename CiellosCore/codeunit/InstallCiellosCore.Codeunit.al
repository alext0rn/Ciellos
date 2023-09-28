codeunit 50104 "Install Ciellos Core"
{
    Subtype = Install;


    trigger OnInstallAppPerCompany()
    begin
        CreateCustomerOrderSetup();
    end;

    trigger OnInstallAppPerDatabase()
    var
        AppInfo: ModuleInfo;
        HelloMsg: Label 'Thank you for installing application.';
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);

        if AppInfo.AppVersion = Version.Create(1, 0, 0, 0) then
            Message(HelloMsg);
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

    local procedure CreateCustomerOrderSetup()
    var
        CustomerOrderSetup: Record "Customer Order Setup";
    begin
        if not CustomerOrderSetup.Get() then begin
            CustomerOrderSetup.Init();
            CustomerOrderSetup.Insert();
        end;

        CustomerOrderSetup."Customer Order Nos." := InitSeries('CO', 'Series No. for Customer Order', true, 'CO000001', 'CO999999', '', 1, false);
        CustomerOrderSetup."Customer Order Payment Nos." := InitSeries('COP', 'Series No. for Customer Order Payment', true, 'COP000001', 'COP999999', '', 1, false);
        CustomerOrderSetup."Posted Customer Order Nos." := InitSeries('PCO', 'Series No. for Posted Customer Order', true, 'PCO000001', 'PCO999999', '', 1, false);
        CustomerOrderSetup."Pstd Cust Order Pmt Nos." := InitSeries('PCOP', 'Series No. for Posted Customer Order Payment', true, 'PCOP000001', 'PCOP999999', '', 1, false);

        CustomerOrderSetup.Modify();
    end;
}