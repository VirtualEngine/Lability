#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'VirtualEngineLab';
if (!$PSScriptRoot) { # $PSScriptRoot is not defined in 2.0
    $PSScriptRoot = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
}
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;

Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'LabHostConfiguration' {

    InModuleScope $moduleName {
    
        Context 'Validates "GetLabHostSetupConfiguration" method' {

            It 'Installs "Microsoft-Hyper-V-All" feature with "WindowsOptionalFeature" on a desktop OS' {
                Mock Get-WmiObject -MockWith { return [PSCustomObject] @{ ProductType = 1; } }
                
                $windowsOptionalFeature = GetLabHostSetupConfiguration | Where { $_.Parameters['Name'] -eq 'Microsoft-Hyper-V-All' }

                $windowsOptionalFeature | Should Not BeNullOrEmpty;
            }

            It 'Installs "Hyper-V" feature using "WindowsFeature" on a server OS' {
                Mock Get-WmiObject -MockWith { return [PSCustomObject] @{ ProductType = 2; } }
                
                $windowsFeature = GetLabHostSetupConfiguration | Where { $_.Parameters['Name'] -eq 'Hyper-V' }

                $windowsFeature | Should Not BeNullOrEmpty;
            }

            It 'Installs "RSAT-Hyper-V-Tools" feature using "WindowsFeature" on a server OS' {
                Mock Get-WmiObject -MockWith { return [PSCustomObject] @{ ProductType = 2; } }
                
                $windowsFeature = GetLabHostSetupConfiguration | Where { $_.Parameters['Name'] -eq 'RSAT-Hyper-V-Tools' }

                $windowsFeature | Should Not BeNullOrEmpty;
            }

            It 'Checks for a pending reboot' {
                $pendingReboot = GetLabHostSetupConfiguration | Where { $_.ModuleName -eq 'xPendingReboot' -and $_.ResourceName -eq 'MSFT_xPendingReboot' }

                $pendingReboot | Should Not BeNullOrEmpty;
            }

        } #end context Validates "GetLabHostSetupConfiguration" method

        Context 'Validates "Get-LabHostConfiguration" method' {

            It 'Calls "ImportDscResource once for each host configuration item' {
                $fakeConfiguration = @(
                    @{ ModuleName = 'TestModule1'; ResourceName = 'TestResource1'; Prefix = 'Prefix1'; Parameters = @{ P1 = 1; } }
                    @{ ModuleName = 'TestModule2'; ResourceName = 'TestResource2'; Prefix = 'PendingReboot'; Parameters = @{ P1 = 1; } }
                )
                Mock GetLabHostSetupConfiguration -MockWith { return $fakeConfiguration; }
                Mock GetDscResource -MockWith { }
                Mock ImportDscResource -MockWith { }

                Get-LabHostConfiguration;

                Assert-MockCalled ImportDscResource -Exactly $fakeConfiguration.Count -Scope It;
            }

            It 'Calls "GetDscResource once for each host configuration item' {
                $fakeConfiguration = @(
                    @{ ModuleName = 'TestModule1'; ResourceName = 'TestResource1'; Prefix = 'Prefix1'; Parameters = @{ P1 = 1; } }
                    @{ ModuleName = 'TestModule2'; ResourceName = 'TestResource2'; Prefix = 'PendingReboot'; Parameters = @{ P1 = 1; } }
                )
                Mock GetLabHostSetupConfiguration -MockWith { return $fakeConfiguration; }
                Mock GetDscResource -MockWith { }
                Mock ImportDscResource -MockWith { }

                Get-LabHostConfiguration;

                Assert-MockCalled GetDscResource -Exactly $fakeConfiguration.Count -Scope It;
            }

        } #end context Validates "Get-LabHostConfiguration" method

        Context 'Validates "Test-LabHostConfiguration" method' {

            It 'Passes when target paths exist' {
                $fakeHostDefaults = '{ "APath": "TestDrive:\\", "TestShare": "TestShare", "BPath": "C:\\" }' | ConvertFrom-Json;
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return $fakeHostDefaults; }

                Mock ImportDscResource -MockWith { }
                Mock TestDscResource -MockWith { return $true; }

                Test-LabHostConfiguration | Should Be $true;
            }


            It 'Fails when a target path does not exist' {
                $fakeHostDefaults = '{ "APath": "TestDrive:\\NonExistentFolderPath", "TestShare": "TestShare", "BPath": "C:\\" }' | ConvertFrom-Json;
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return $fakeHostDefaults; }

                Mock ImportDscResource -MockWith { }
                Mock TestDscResource -MockWith { return $true; }

                Test-LabHostConfiguration | Should Be $false;
            }

            It 'Passes when host configuration is correct' {
                $fakeConfiguration = @(
                    @{ ModuleName = 'TestModule1'; ResourceName = 'TestResource1'; Prefix = 'Passes'; Parameters = @{ P1 = 1; } }
                    @{ ModuleName = 'TestModule2'; ResourceName = 'TestResource2'; Prefix = 'Passes'; Parameters = @{ P1 = 1; } }
                )
                $fakeHostDefaults = '{ }' | ConvertFrom-Json;
                Mock GetConfigurationData -MockWith { return $fakeHostDefaults; }
                Mock GetLabHostSetupConfiguration -MockWith { return $fakeConfiguration; }
                Mock Test-Path -MockWith { return $true; }
                Mock ImportDscResource -MockWith { }
                Mock TestDscResource -ParameterFilter { $ResourceName -eq 'Passes' } -MockWith { return $true; }
                Mock TestDscResource -ParameterFilter { $ResourceName -eq 'Fails' } -MockWith { return $false; }

                Test-LabHostConfiguration | Should Be $true;
            }

            It 'Fails when host configuration is incorrect' {
                $fakeConfiguration = @(
                    @{ ModuleName = 'TestModule1'; ResourceName = 'TestResource1'; Prefix = 'Passes'; Parameters = @{ P1 = 1; } }
                    @{ ModuleName = 'TestModule2'; ResourceName = 'TestResource2'; Prefix = 'Fails'; Parameters = @{ P1 = 1; } }
                )
                $fakeHostDefaults = '{ }' | ConvertFrom-Json;
                Mock GetConfigurationData -MockWith { return $fakeHostDefaults; }
                Mock GetLabHostSetupConfiguration -MockWith { return $fakeConfiguration; }
                Mock Test-Path -MockWith { return $true; }
                Mock ImportDscResource -MockWith { }
                Mock TestDscResource -ParameterFilter { $ResourceName -eq 'Passes' } -MockWith { return $true; }
                Mock TestDscResource -ParameterFilter { $ResourceName -eq 'Fails' } -MockWith { return $false; }

                Test-LabHostConfiguration | Should Be $false;
            }

            It 'Fails when host configuration has a pending reboot' {
                $fakeConfiguration = @(
                    @{ ModuleName = 'TestModule1'; ResourceName = 'TestResource1'; Prefix = 'Passes'; Parameters = @{ P1 = 1; } }
                    @{ ModuleName = 'TestModule2'; ResourceName = 'TestResource2'; Prefix = 'PendingReboot'; Parameters = @{ P1 = 1; } }
                )
                $fakeHostDefaults = '{ }' | ConvertFrom-Json;
                Mock GetConfigurationData -MockWith { return $fakeHostDefaults; }
                Mock GetLabHostSetupConfiguration -MockWith { return $fakeConfiguration; }
                Mock Test-Path -MockWith { return $true; }
                Mock ImportDscResource -MockWith { }
                Mock TestDscResource -ParameterFilter { $ResourceName -eq 'Passes' } -MockWith { return $true; }
                Mock TestDscResource -ParameterFilter { $ResourceName -eq 'PendingReboot' } -MockWith { return $false; }

                Test-LabHostConfiguration 3> $null | Should Be $false;
            }

            It 'Passes when host configuration has a pending reboot but -IgnorePendingReboot is specified' {
                $fakeConfiguration = @(
                    @{ ModuleName = 'TestModule1'; ResourceName = 'TestResource1'; Prefix = 'Passes'; Parameters = @{ P1 = 1; } }
                    @{ ModuleName = 'TestModule2'; ResourceName = 'TestResource2'; Prefix = 'PendingReboot'; Parameters = @{ P1 = 1; } }
                )
                $fakeHostDefaults = '{ }' | ConvertFrom-Json;
                Mock GetConfigurationData -MockWith { return $fakeHostDefaults; }
                Mock GetLabHostSetupConfiguration -MockWith { return $fakeConfiguration; }
                Mock Test-Path -MockWith { return $true; }
                Mock ImportDscResource -MockWith { }
                Mock TestDscResource -ParameterFilter { $ResourceName -eq 'Passes' } -MockWith { return $true; }
                Mock TestDscResource -ParameterFilter { $ResourceName -eq 'PendingReboot' } -MockWith { return $false; }

                Test-LabHostConfiguration -IgnorePendingReboot 3> $null | Should Be $true;
            }

        } #end context Validates "Test-LabHostConfiguration" method'

        Context 'Validates "Start-LabHostConfiguration" method' {

            It 'Does not attempt to create an empty path' {
                $fakeHostDefaults = '{ "APath": "" }' | ConvertFrom-Json;
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return $fakeHostDefaults; }
                Mock GetLabHostSetupConfiguration -MockWith { }
                Mock ImportDscResource -MockWith { }
                Mock InvokeDscResource -MockWith { }
                Mock NewDirectory -MockWith { }

                Start-LabHostConfiguration;

                Assert-MockCalled NewDirectory -Exactly 0 -Scope It;
            }

            It 'Calls "NewDirectory" for each path' {
                $fakeHostDefaults = '{ "APath": "TestDrive:\\", "BPath": "C:\\" }' | ConvertFrom-Json;
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return $fakeHostDefaults; }
                Mock GetLabHostSetupConfiguration -MockWith { }
                Mock ImportDscResource -MockWith { }
                Mock InvokeDscResource -MockWith { }
                Mock NewDirectory -MockWith { }

                Start-LabHostConfiguration;

                Assert-MockCalled NewDirectory -Exactly ($fakeHostDefaults.PSObject.Properties | Measure | Select -ExpandProperty Count) -Scope It;
            }

            It 'Calls "InvokeDscResource" for each host configuration item' {
                $fakeHostDefaults = '{ "APath": "TestDrive:\\", "BPath": "C:\\" }' | ConvertFrom-Json;
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return $fakeHostDefaults; }

                $fakeConfiguration = @(
                    @{ ModuleName = 'TestModule1'; ResourceName = 'TestResource1'; Prefix = 'Prefix1'; Parameters = @{ P1 = 1; } }
                    @{ ModuleName = 'TestModule2'; ResourceName = 'TestResource2'; Prefix = 'PendingReboot'; Parameters = @{ P1 = 1; } }
                )
                Mock GetLabHostSetupConfiguration -MockWith { return $fakeConfiguration; }

                Mock ImportDscResource -MockWith { }
                Mock InvokeDscResource -MockWith { }
                Mock NewDirectory -MockWith { }

                Start-LabHostConfiguration;

                Assert-MockCalled InvokeDscResource -Exactly $fakeConfiguration.Count -Scope It;
            }

        } #end context Validates "Start-LabHostConfiguration" method

    } #end InModuleScope

} #end describe LabHostConfiguration
