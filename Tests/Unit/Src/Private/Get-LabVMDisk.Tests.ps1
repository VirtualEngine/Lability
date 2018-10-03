#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Get-LabVMDisk' {

    InModuleScope $moduleName {

        ## Guard mocks
        Mock Import-LabDscResource -MockWith { }
        Mock Get-LabDscResource -MockWith { }
        Mock Get-LabImage -MockWith { }

        It 'Calls "Get-LabMedia" to resolve the parent VHDX path' {
            $testVMName = 'TestVM';
            $testMedia = 'TestMedia';
            Mock Get-LabImage -ParameterFilter { $Id -eq $testMedia } -MockWith { return @{ ImagePath = "TestDrive:\$testMedia.vhdx"; } }

            $null = Get-LabVMDisk -Name $testVMName -Media $testMedia;

            Assert-MockCalled Get-LabImage -ParameterFilter { $Id -eq $testMedia } -Scope It;
        }

        It 'Calls "Get-LabDscResource" with virtual machine name' {
            $testVMName = 'TestVM';
            $testMedia = 'TestMedia';
            Mock Get-LabImage -MockWith { return @{ ImagePath = "TestDrive:\$testMedia.vhdx"; } }

            $null = Get-LabVMDisk -Name $testVMName -Media $testMedia;

            Assert-MockCalled Get-LabDscResource -ParameterFilter { $Parameters.Name -eq $testVMName } -Scope It;
        }

        It 'Calls "Get-LabImage" with "ConfigurationData" when specified (#97)' {
            $testVMName = 'TestVM';
            $testMedia = 'TestMedia';
            Mock Get-LabImage -ParameterFilter { $null -ne $ConfigurationData } -MockWith { return @{ ImagePath = "TestDrive:\$testMedia.vhdx"; } }

            $null = Get-LabVMDisk -Name $testVMName -Media $testMedia -ConfigurationData @{};

            Assert-MockCalled Get-LabImage -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
        }

    } #end InModuleScope

} #end describe
