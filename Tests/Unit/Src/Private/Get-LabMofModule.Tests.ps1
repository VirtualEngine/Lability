#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Get-LabMofModule' {

    InModuleScope $moduleName {

        It 'Does count individual module references' {

            $testMofPath = 'TestDrive:\Test.mof';
            $testMofContent = @'
instance of MSFT_xFirewall as $MSFT_xFirewall1ref
{
    // REDACTED //
    ModuleName = "xNetworking";
    ModuleVersion = "3.2.0.0";
    ConfigurationName = "TEST";
};

instance of MSFT_xADDomain as $MSFT_xADDomain1ref
{
    // REDACTED //
    ModuleName = "xActiveDirectory";
    ModuleVersion = "2.16.0.0";
    ConfigurationName = "TEST";
};

instance of OMI_ConfigurationDocument
{
    // REDACTED //
};
'@
            (Set-Content -Path $testMofPath -Value $testMofContent -Force -Encoding UTF8);

            $result = Get-LabMofModule -Path $testMofPath;

            $result.Name.Count | Should Be 2;
        }

        It 'Does not count duplicate module references' {

            $testMofPath = 'TestDrive:\Test.mof';
            $testMofContent = @'
instance of MSFT_xFirewall as $MSFT_xFirewall1ref
{
    // REDACTED //
    ModuleName = "xNetworking";
    ModuleVersion = "3.2.0.0";
    ConfigurationName = "TEST";
};

instance of MSFT_xIPAddress as $MSFT_xIPAddress1ref
{
// REDACTED //
ModuleName = "xNetworking";
ModuleVersion = "3.2.0.0";
ConfigurationName = "TEST";
};

instance of OMI_ConfigurationDocument
{
    // REDACTED //
};
'@
            (Set-Content -Path $testMofPath -Value $testMofContent -Force -Encoding UTF8);

            $result = Get-LabMofModule -Path $testMofPath;

            $result.Name | Should Be 'xNetworking';
            $result.Name.Count | Should Be 1;
            $result.RequiredVersion | Should Be '3.2.0.0';
        }

        It 'Ignores "PSDesiredStateConfiguration" instances' {

            $testMofPath = 'TestDrive:\Test.mof';
            $testMofContent = @'
instance of MSFT_ScriptResource as $MSFT_ScriptResource1ref
{
    // REDACTED //
    ModuleName = "PSDesiredStateConfiguration";
    ModuleVersion = "0.0";
    ConfigurationName = "TEST";
};

instance of OMI_ConfigurationDocument
{
// REDACTED //
};
'@
            (Set-Content -Path $testMofPath -Value $testMofContent -Force -Encoding UTF8);

            $result = Get-LabMofModule -Path $testMofPath;

            $result | Should BeNullOrEmpty;
        }

        It 'Ignores "MSFT_Credential" instances' {

            $testMofPath = 'TestDrive:\Test.mof';
            $testMofContent = @'
instance of MSFT_Credential as $MSFT_Credential1ref
{
UserName = "// REDACTED //";
Password = "// REDACTED //";
};

instance of OMI_ConfigurationDocument
{
// REDACTED //
};
'@
            (Set-Content -Path $testMofPath -Value $testMofContent -Force -Encoding UTF8);

            $result = Get-LabMofModule -Path $testMofPath;

            $result | Should BeNullOrEmpty;
        }

    } #end InModuleScope

} #end describe
