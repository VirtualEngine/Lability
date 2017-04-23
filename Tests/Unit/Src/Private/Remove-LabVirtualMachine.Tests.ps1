#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Clear-LabVirtualMachine' {

    InModuleScope $moduleName {

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
            Mock Clear-LabVirtualMachine -MockWith { }
            Mock Remove-LabVMDisk -MockWith { }
            Mock RemoveLabSwitch -MockWith { }
            Mock RemoveLabVMSnapshot -ParameterFilter { $Name -eq $testVMName } -MockWith { }

            Remove-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName;

            Assert-MockCalled RemoveLabVMSnapshot -ParameterFilter { $Name -eq $testVMName } -Scope It;
        }

        It 'Removes the virtual machine' {
            $testVMName = 'TestVM';
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = $testVMName; }
                )
            }
            Mock Remove-LabVMDisk -MockWith { }
            Mock RemoveLabSwitch -MockWith { }
            Mock RemoveLabVMSnapshot -MockWith { }
            Mock Clear-LabVirtualMachine -ParameterFilter { $Name -eq $testVMName } -MockWith { }

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
            Mock RemoveLabSwitch -MockWith { }
            Mock RemoveLabVMSnapshot -MockWith { }
            Mock Clear-LabVirtualMachine -MockWith { }
            Mock Remove-LabVMDisk -ParameterFilter { $Name -eq $testVMName } -MockWith { }

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
            Mock RemoveLabSwitch -MockWith { }
            Mock RemoveLabVMSnapshot -MockWith { }
            Mock Clear-LabVirtualMachine -MockWith { }
            Mock Remove-LabVMDisk -MockWith { }

            Remove-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName;

            Assert-MockCalled RemoveLabSwitch -Exactly 0 -Scope It;
        }

        It 'Removes the virtual switch when "RemoveSwitch" is specified' {
            $testVMName = 'TestVM';
            $testVMSwitch = 'Test Switch';
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = $testVMName; SwitchName = $testVMSwitch; }
                )
            }
            Mock RemoveLabVMSnapshot -MockWith { }
            Mock Clear-LabVirtualMachine -MockWith { }
            Mock Remove-LabVMDisk -MockWith { }
            Mock RemoveLabSwitch -ParameterFilter { $Name -eq $testVMSwitch } -MockWith { }

            Remove-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName -RemoveSwitch;

            Assert-MockCalled RemoveLabSwitch -ParameterFilter { $Name -eq $testVMSwitch } -Scope It;
        }

        It 'Calls "RemoveLabVirtualMachine" with "ConfigurationData" (#97)' {
            $testVMName = 'TestVM';
            $testVMSwitch = 'Test Switch';
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = $testVMName; SwitchName = $testVMSwitch; }
                )
            }
            Mock RemoveLabVMSnapshot -MockWith { }
            Mock Remove-LabVMDisk -MockWith { }
            Mock RemoveLabSwitch -MockWith { }
            Mock Clear-LabVirtualMachine -ParameterFilter { $null -ne $configurationData } -MockWith { }

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
            Mock RemoveLabVMSnapshot -MockWith { }
            Mock RemoveLabSwitch -MockWith { }
            Mock Clear-LabVirtualMachine -MockWith { }
            Mock Remove-LabVMDisk -ParameterFilter { $null -ne $configurationData } -MockWith { }

            Remove-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName -RemoveSwitch;

            Assert-MockCalled Remove-LabVMDisk -ParameterFilter { $null -ne $configurationData } -Scope It;
        }

    } #end InModuleScope
} #end Describe
