#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\New-LabSwitch' {

    InModuleScope $moduleName {

        It 'Returns a "System.Collections.Hashtable" object type' {
            $testSwitchName = 'TestSwitch';
            $newSwitchParams = @{
                Name = $testSwitchName;
                Type = 'Internal';
            }
            $labSwitch = New-LabSwitch @newSwitchParams;
            $labSwitch -is [System.Collections.Hashtable] | Should Be $true;
        }

        It 'Throws when switch type is "External" and "NetAdapterName" is not specified' {
            $testSwitchName = 'TestSwitch';
            $newSwitchParams = @{
                Name = $testSwitchName;
                Type = 'External';
            }

            { New-LabSwitch @newSwitchParams } | Should Throw;
        }

        It 'Removes "NetAdapterName" if switch type is not "External"' {
            $testSwitchName = 'TestSwitch';
            $newSwitchParams = @{
                Name = $testSwitchName;
                Type = 'Internal';
            }

            $labSwitch = New-LabSwitch @newSwitchParams;

            $labSwitch.NetAdapaterName | Should BeNullOrEmpty;
        }

        It 'Removes "AllowManagementOS" if switch type is not "External"' {
            $testSwitchName = 'TestSwitch';
            $newSwitchParams = @{
                Name = $testSwitchName;
                Type = 'Internal';
            }

            $labSwitch = New-LabSwitch @newSwitchParams;

            $labSwitch.AllowManagementOS | Should BeNullOrEmpty;
        }

    } #end InModuleScope

} #end describe
