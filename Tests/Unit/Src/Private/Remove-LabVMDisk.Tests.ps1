#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Remove-LabVMDiskPath' {

    InModuleScope $moduleName {

         It 'Calls "Get-LabMedia" to resolve the parent VHDX path' {
            $testVMName = 'TestVM';
            $testMedia = 'TestMedia';
            Mock Get-LabImage -ParameterFilter { $Id -eq $testMedia } -MockWith { return @{ ImagePath = "TestDrive:\$testMedia.vhdx"; Generation = 'VHDX'; } }
            Mock ImportDscResource -ParameterFilter { $Prefix -eq 'VHD' } -MockWith { }
            Mock InvokeDscResource -ParameterFilter { $Parameters.Name -eq $testVMName } -MockWith { }

            $vmDisk = Remove-LabVMDisk -Name $testVMName -NodeName $testVMName -Media $testMedia;

            Assert-MockCalled Get-LabImage -ParameterFilter { $Id -eq $testMedia } -Scope It;
        }

        It 'Calls "InvokeDscResource" with virtual "Ensure" = "Absent"' {
            $testVMName = 'TestVM';
            $testMedia = 'TestMedia';
            $testImagePath = "TestDrive:\$testMedia.vhdx";
            $testLabVMDiskPath = "TestDrive:\$testVMName.vhdx";
            Mock Get-ConfigurationData -MockWith { return @{ DifferencingVhdPath = 'TestDrive:'; } }
            Mock Get-LabImage -MockWith { return @{ ImagePath = $testImagePath; Generation = 'VHDX'; } }
            Mock ImportDscResource -ParameterFilter { $Prefix -eq 'VHD' } -MockWith { }
            Mock InvokeDscResource -ParameterFilter { $Parameters.Ensure -eq 'Absent' } -MockWith { }
            New-Item -Path $testLabVMDiskPath -ItemType File -Force -ErrorAction SilentlyContinue;

            $vmDisk = Remove-LabVMDisk -Name $testVMName -NodeName $testVMName -Media $testMedia;

            Assert-MockCalled InvokeDscResource -ParameterFilter { $Parameters.Ensure -eq 'Absent' } -Scope It;
        }

        It 'Calls "Get-LabImage" with "ConfigurationData" when specified (#97)' {
            $testVMName = 'TestVM';
            $testMedia = 'TestMedia';
            Mock Get-LabImage -ParameterFilter { $null -ne $ConfigurationData } -MockWith { return @{ ImagePath = "TestDrive:\$testMedia.vhdx"; Generation = 'VHDX'; } }
            Mock ImportDscResource -MockWith { }
            Mock InvokeDscResource -MockWith { }

            $vmDisk = Remove-LabVMDisk -Name $testVMName -NodeName $testVMName -Media $testMedia -ConfigurationData @{};

            Assert-MockCalled Get-LabImage -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
        }

    } #end InModuleScope

} #end describe
