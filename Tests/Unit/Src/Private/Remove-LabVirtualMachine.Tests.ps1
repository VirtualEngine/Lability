#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Remove-LabVirtualMachine' {

    InModuleScope $moduleName {

        ## Guard mocks
        Mock Clear-LabVirtualMachine -MockWith { }
        Mock Remove-LabVMDisk -MockWith { }
        Mock Remove-LabSwitch -MockWith { }
        Mock Remove-LabVMSnapshot -MockWith { }

        It 'Throws when VM cannot be found' {
            $testVMName = 'TestVM';
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = '*' }
                )
            }
            { Remove-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName } | Should Throw;
        }

        It 'Removes all snapshots' {
            $testVMName = 'TestVM';
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = $testVMName; }
                )
            }

            Remove-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName;

            Assert-MockCalled Remove-LabVMSnapshot -ParameterFilter { $Name -eq $testVMName } -Scope It;
        }

        It 'Removes the virtual machine' {
            $testVMName = 'TestVM';
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = $testVMName; }
                )
            }

            Remove-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName;

            Assert-MockCalled Clear-LabVirtualMachine -ParameterFilter { $Name -eq $testVMName } -Scope It;
        }

        It 'Removes the VHDX file' {
            $testVMName = 'TestVM';
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = $testVMName; }
                )
            }

            Remove-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName;

            Assert-MockCalled Remove-LabVMDisk -ParameterFilter { $Name -eq $testVMName } -Scope It;
        }

        It 'Does not remove the virtual switch by default' {
            $testVMName = 'TestVM';
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = $testVMName; }
                )
            }

            Remove-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName;

            Assert-MockCalled Remove-LabSwitch -Exactly 0 -Scope It;
        }

        It 'Removes the virtual switch when "RemoveSwitch" is specified' {
            $testVMName = 'TestVM';
            $testVMSwitch = 'Test Switch';
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = $testVMName; SwitchName = $testVMSwitch; }
                )
            }

            Remove-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName -RemoveSwitch;

            Assert-MockCalled Remove-LabSwitch -ParameterFilter { $Name -eq $testVMSwitch } -Scope It;
        }

        It 'Calls "RemoveLabVirtualMachine" with "ConfigurationData" (#97)' {
            $testVMName = 'TestVM';
            $testVMSwitch = 'Test Switch';
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = $testVMName; SwitchName = $testVMSwitch; }
                )
            }

            Remove-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName -RemoveSwitch;

            Assert-MockCalled Clear-LabVirtualMachine -ParameterFilter { $null -ne $configurationData } -Scope It;
        }

        It 'Calls "Remove-LabVMDisk" with "ConfigurationData" (#97)' {
            $testVMName = 'TestVM';
            $testVMSwitch = 'Test Switch';
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = $testVMName; SwitchName = $testVMSwitch; }
                )
            }

            Remove-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName -RemoveSwitch;

            Assert-MockCalled Remove-LabVMDisk -ParameterFilter { $null -ne $configurationData } -Scope It;
        }

        It 'Calls "Remove-LabVMDisk" without environment prefix (#292)' {
            $testVMName = 'TestVM';
            $configurationData = @{
                AllNodes = @(
                    @{
                        NodeName = $testVMName;
                        Lability_HardDiskDrive = @( @{ Generation = 'VHDX'; MaximumSizeBytes = 10GB; } )
                    }
                )
                NonNodeData = @{ Lability = @{ EnvironmentPrefix = 'TEST-'; } }
            }

            Remove-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName;

            Assert-MockCalled Remove-LabVMDisk -ParameterFilter { $NodeName -eq $testVMName } -Scope It;
        }

    } #end InModuleScope
} #end Describe
