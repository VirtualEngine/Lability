#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Reset-LabVMDiskPath' {

    InModuleScope $moduleName {

        ## Guard mocks
        Mock RemoveLabVMSnapshot -MockWith { }
        Mock Remove-LabVMDisk -MockWith { }
        Mock Set-LabVMDisk -MockWith { }

        $testVMName = 'TestVM';
        $testMedia = 'TestMedia';

        It 'Removes any existing snapshots' {
            ResetLabVMDisk -Name $testVMName -NodeName $testVMName -Media $testMedia;

            Assert-MockCalled RemoveLabVMSnapshot -ParameterFilter { $Name -eq $testVMName } -Scope It;
        }

        It 'Removes the existing VHDX file' {
            ResetLabVMDisk -Name $testVMName -Media $testMedia;

            Assert-MockCalled Remove-LabVMDisk -ParameterFilter { $Name -eq $testVMName } -Scope It;
        }

        It 'Creates a new VHDX file' {
            ResetLabVMDisk -Name $testVMName -Media $testMedia;

            Assert-MockCalled Set-LabVMDisk -ParameterFilter { $Name -eq $testVMName } -Scope It;
        }

        It 'Calls "Remove-LabVMDisk" and "SetLabVMDisk" with "ConfigurationData" when specified (#97)' {
            ResetLabVMDisk -Name $testVMName -Media $testMedia -ConfigurationData @{};

            Assert-MockCalled Remove-LabVMDisk -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
            Assert-MockCalled Set-LabVMDisk -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
        }

    } #end InModuleScope

} #end describe
