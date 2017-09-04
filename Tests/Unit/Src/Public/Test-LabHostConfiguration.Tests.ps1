#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Public\Test-LabHostConfiguration' {

    InModuleScope -ModuleName $moduleName {

        # Guard mocks
        Mock Import-LabDscResource -MockWith { }

        It 'Passes when target paths exist' {
            $fakeHostDefaults = '{ "APath": "TestDrive:\\", "TestShare": "TestShare", "BPath": "C:\\" }' | ConvertFrom-Json;
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return $fakeHostDefaults; }
            Mock Test-LabDscResource -MockWith { return $true; }

            Test-LabHostConfiguration | Should Be $true;
        }

        It 'Fails when a target path does not exist' {
            $fakeHostDefaults = '{ "APath": "TestDrive:\\NonExistentFolderPath", "TestShare": "TestShare", "BPath": "C:\\" }' | ConvertFrom-Json;
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return $fakeHostDefaults; }
            Mock Test-LabDscResource -MockWith { return $true; }

            Test-LabHostConfiguration | Should Be $false;
        }

        It 'Passes when host configuration is correct' {
            $fakeConfiguration = @(
                @{ ModuleName = 'TestModule1'; ResourceName = 'TestResource1'; Prefix = 'Passes'; Parameters = @{ P1 = 1; } }
                @{ ModuleName = 'TestModule2'; ResourceName = 'TestResource2'; Prefix = 'Passes'; Parameters = @{ P1 = 1; } }
            )
            $fakeHostDefaults = '{ }' | ConvertFrom-Json;
            Mock Get-ConfigurationData -MockWith { return $fakeHostDefaults; }
            Mock Get-LabHostSetupConfiguration -MockWith { return $fakeConfiguration; }
            Mock Test-Path -MockWith { return $true; }
            Mock Test-LabDscResource -ParameterFilter { $ResourceName -eq 'Passes' } -MockWith { return $true; }
            Mock Test-LabDscResource -ParameterFilter { $ResourceName -eq 'Fails' } -MockWith { return $false; }

            Test-LabHostConfiguration | Should Be $true;
        }

        It 'Fails when host configuration is incorrect' {
            $fakeConfiguration = @(
                @{ ModuleName = 'TestModule1'; ResourceName = 'TestResource1'; Prefix = 'Passes'; Parameters = @{ P1 = 1; } }
                @{ ModuleName = 'TestModule2'; ResourceName = 'TestResource2'; Prefix = 'Fails'; Parameters = @{ P1 = 1; } }
            )
            $fakeHostDefaults = '{ }' | ConvertFrom-Json;
            Mock Get-ConfigurationData -MockWith { return $fakeHostDefaults; }
            Mock Get-LabHostSetupConfiguration -MockWith { return $fakeConfiguration; }
            Mock Test-Path -MockWith { return $true; }
            Mock Test-LabDscResource -ParameterFilter { $ResourceName -eq 'Passes' } -MockWith { return $true; }
            Mock Test-LabDscResource -ParameterFilter { $ResourceName -eq 'Fails' } -MockWith { return $false; }

            Test-LabHostConfiguration | Should Be $false;
        }

        It 'Fails when host configuration has a pending reboot' {
            $fakeConfiguration = @(
                @{ ModuleName = 'TestModule1'; ResourceName = 'TestResource1'; Prefix = 'Passes'; Parameters = @{ P1 = 1; } }
                @{ ModuleName = 'TestModule2'; ResourceName = 'TestResource2'; Prefix = 'PendingReboot'; Parameters = @{ P1 = 1; } }
            )
            $fakeHostDefaults = '{ }' | ConvertFrom-Json;
            Mock Get-ConfigurationData -MockWith { return $fakeHostDefaults; }
            Mock Get-LabHostSetupConfiguration -MockWith { return $fakeConfiguration; }
            Mock Test-Path -MockWith { return $true; }
            Mock Test-LabDscResource -ParameterFilter { $ResourceName -eq 'Passes' } -MockWith { return $true; }
            Mock Test-LabDscResource -ParameterFilter { $ResourceName -eq 'PendingReboot' } -MockWith { return $false; }

            Test-LabHostConfiguration 3> $null | Should Be $false;
        }

        It 'Passes when host configuration has a pending reboot but -IgnorePendingReboot is specified' {
            $fakeConfiguration = @(
                @{ ModuleName = 'TestModule1'; ResourceName = 'TestResource1'; Prefix = 'Passes'; Parameters = @{ P1 = 1; } }
                @{ ModuleName = 'TestModule2'; ResourceName = 'TestResource2'; Prefix = 'PendingReboot'; Parameters = @{ P1 = 1; } }
            )
            $fakeHostDefaults = '{ }' | ConvertFrom-Json;
            Mock Get-ConfigurationData -MockWith { return $fakeHostDefaults; }
            Mock Get-LabHostSetupConfiguration -MockWith { return $fakeConfiguration; }
            Mock Test-Path -MockWith { return $true; }
            Mock Test-LabDscResource -ParameterFilter { $ResourceName -eq 'Passes' } -MockWith { return $true; }
            Mock Test-LabDscResource -ParameterFilter { $ResourceName -eq 'PendingReboot' } -MockWith { return $false; }

            Test-LabHostConfiguration -IgnorePendingReboot 3> $null | Should Be $true;
        }

    } #end InModuleScope

} #end describe
