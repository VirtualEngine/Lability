#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Test-LabVMDiskPath' {

    InModuleScope $moduleName {

        It 'Calls "Get-LabMedia" to resolve the parent VHDX path' {
            $testVM = 'TestVM';
            $testMedia = 'TestMedia';
            Mock Get-LabImage -MockWith { return @{ ImagePath = "TestDrive:\$testMedia.vhdx"; } }
            Mock ImportDscResource -ParameterFilter { $Prefix -eq 'VHD' } -MockWith { }
            Mock TestDscResource -MockWith { }

            $vmDisk = Test-LabVMDisk -Name $testVM -Media $testMedia;

            Assert-MockCalled Get-LabImage -Scope It;
        }

        It 'Calls "TestDscResource" with virtual machine name' {
            $testVMName = 'TestVMName';
            $testMedia = 'TestMedia';
            Mock Get-LabImage -MockWith { return @{ ImagePath = "TestDrive:\$testMedia.vhdx"; } }
            Mock ImportDscResource -ParameterFilter { $Prefix -eq 'VHD' } -MockWith { }
            Mock TestDscResource -ParameterFilter { $Parameters.Name -eq $testVMName } -MockWith { }

            $vmDisk = Test-LabVMDisk -Name $testVMName -Media $testMedia;

            Assert-MockCalled TestDscResource -ParameterFilter { $Parameters.Name -eq $testVMName } -Scope It;
        }

        It 'Calls "TestDscResource" with "MaximumSize" when image is not available (#104)' {
            $testVMSize = 'TestVMSize';
            $testMedia = 'TestNewMedia';
            Mock Get-LabImage -MockWith { }
            Mock ImportDscResource -ParameterFilter { $Prefix -eq 'VHD' } -MockWith { }
            Mock TestDscResource -ParameterFilter { $Parameters.MaximumSize -eq 127GB } -MockWith { }

            $vmDisk = Test-LabVMDisk -Name $testVMSize -Media $testMedia;

            Assert-MockCalled TestDscResource -ParameterFilter { $Parameters.MaximumSize -eq 127GB } -Scope It;
        }

        It 'Calls "TestDscResource" with "VHDX" when image is not available (#104)' {
            $testVMGeneration = 'TestVMGeneration';
            $testMedia = 'TestNewMedia';
            Mock Get-LabImage -MockWith { }
            Mock ImportDscResource -ParameterFilter { $Prefix -eq 'VHD' } -MockWith { }
            Mock TestDscResource -ParameterFilter { $Parameters.Generation -eq 'VHDX' } -MockWith { }

            $vmDisk = Test-LabVMDisk -Name $testVMGeneration -Media $testMedia;

            Assert-MockCalled TestDscResource -ParameterFilter { $Parameters.Generation -eq 'VHDX' } -Scope It;
        }

        It 'Calls "Get-LabImage" with "ConfigurationData" when specified (#97)' {
            $testVMName = 'TestVM';
            $testMedia = 'TestMedia';
            Mock Get-LabImage -ParameterFilter { $null -ne $ConfigurationData } -MockWith { return @{ ImagePath = "TestDrive:\$testMedia.vhdx"; } }
            Mock ImportDscResource -MockWith { }
            Mock TestDscResource -MockWith { }

            $vmDisk = Test-LabVMDisk -Name $testVMName -Media $testMedia -ConfigurationData @{};

            Assert-MockCalled Get-LabImage -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
        }

    } #end InModuleScope

} #end describe
