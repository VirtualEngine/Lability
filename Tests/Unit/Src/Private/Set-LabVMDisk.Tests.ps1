#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Set-LabVMDiskPath' {

    InModuleScope $moduleName {

        ## Guard mocks
        Mock Get-LabImage -MockWith { }
        Mock ImportDscResource -MockWith { }
        Mock InvokeDscResource -MockWith { }

        It 'Calls "Get-LabMedia" to resolve the parent VHDX path' {
            $testVMName = 'TestVM';
            $testMedia = 'TestMedia';
            Mock Get-LabImage -ParameterFilter { $Id -eq $testMedia } -MockWith { return @{ ImagePath = "TestDrive:\$testMedia.vhdx"; } }

            $vmDisk = Set-LabVMDisk -Name $testVMName -Media $testMedia;

            Assert-MockCalled Get-LabImage -ParameterFilter { $Id -eq $testMedia } -Scope It;
        }

        It 'Calls "InvokeDscResource" with virtual machine name' {
            $testVMName = 'TestVM';
            $testMedia = 'TestMedia';
            Mock Get-LabImage -MockWith { return @{ ImagePath = "TestDrive:\$testMedia.vhdx"; } }

            $vmDisk = Set-LabVMDisk -Name $testVMName -Media $testMedia;

            Assert-MockCalled InvokeDscResource -ParameterFilter { $Parameters.Name -eq $testVMName } -Scope It;
        }

        It 'Calls "Get-LabImage" with "ConfigurationData" when specified (#97)' {
            $testVMName = 'TestVM';
            $testMedia = 'TestMedia';
            Mock Get-LabImage -ParameterFilter { $null -ne $ConfigurationData } -MockWith { return @{ ImagePath = "TestDrive:\$testMedia.vhdx"; } }

            $vmDisk = Set-LabVMDisk -Name $testVMName -Media $testMedia -ConfigurationData @{};

            Assert-MockCalled Get-LabImage -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
        }

    } #end InModuleScope

} #end describe
