codeunit 50106 "Upgrade Tag Core"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure OnGetPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]]);
    begin
        PerCompanyUpgradeTags.Add(GetCustomerUpgradeTag());
        PerCompanyUpgradeTags.Add(GetCustomerOrdeSetupUpgradeTag());
    end;

    procedure GetCustomerUpgradeTag(): Text
    begin
        exit('Customer_Upgrade_092023');
    end;

    procedure GetCustomerOrdeSetupUpgradeTag(): Text
    begin
        exit('CustomerOrderSetup_Upgrade_092023');
    end;
}