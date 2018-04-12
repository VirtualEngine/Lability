#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Public\Start-LabHostConfiguration' {

    InModuleScope -ModuleName $moduleName {

        # Guard mocks
        Mock Import-LabDscResource -MockWith { }
        Mock Invoke-LabDscResource -MockWith { }
        Mock New-Directory -MockWith { }

        It 'Does not attempt to create an empty path' {
            $fakeHostDefaults = '{ "APath": "" }' | ConvertFrom-Json;
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return $fakeHostDefaults; }
            Mock Get-LabHostSetupConfiguration -MockWith { }

            Start-LabHostConfiguration;

            Assert-MockCalled New-Directory -Exactly 0 -Scope It;
        }

        It 'Calls "New-Directory" for each path' {
            $fakeHostDefaults = '{ "APath": "TestDrive:\\", "BPath": "C:\\" }' | ConvertFrom-Json;
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return $fakeHostDefaults; }
            Mock Get-LabHostSetupConfiguration -MockWith { }

            Start-LabHostConfiguration;

            Assert-MockCalled New-Directory -Exactly ($fakeHostDefaults.PSObject.Properties | Measure | Select -ExpandProperty Count) -Scope It;
        }

        It 'Calls "Invoke-LabDscResource" for each host configuration item' {
            $fakeHostDefaults = '{ "APath": "TestDrive:\\", "BPath": "C:\\" }' | ConvertFrom-Json;
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return $fakeHostDefaults; }

            $fakeConfiguration = @(
                @{ ModuleName = 'TestModule1'; ResourceName = 'TestResource1'; Prefix = 'Prefix1'; Parameters = @{ P1 = 1; } }
                @{ ModuleName = 'TestModule2'; ResourceName = 'TestResource2'; Prefix = 'PendingReboot'; Parameters = @{ P1 = 1; } }
            )
            Mock Get-LabHostSetupConfiguration -MockWith { return $fakeConfiguration; }

            Start-LabHostConfiguration;

            Assert-MockCalled Invoke-LabDscResource -Exactly $fakeConfiguration.Count -Scope It;
        }

        It 'Does not call "Invoke-LabDscResource" on "xPendingReboot" when "IgnorePendingReboot" is specified (#278)' {

            $fakeHostDefaults = '{ "APath": "TestDrive:\\", "BPath": "C:\\" }' | ConvertFrom-Json;
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return $fakeHostDefaults; }

            $fakeConfiguration = @(
                @{ ModuleName = 'xPendingReboot'; ResourceName = 'MSFT_xPendingReboot'; Prefix = 'PendingReboot'; Parameters = @{ P1 = 1; } }
            )
            Mock Get-LabHostSetupConfiguration -MockWith { return $fakeConfiguration; }

            Start-LabHostConfiguration -IgnorePendingReboot -WarningAction SilentlyContinue;

            Assert-MockCalled Invoke-LabDscResource -Exactly 0 -Scope It;
        }

    } #end InModuleScope

} #end describe
