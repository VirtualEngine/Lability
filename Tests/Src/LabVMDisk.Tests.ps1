#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
if (!$PSScriptRoot) { # $PSScriptRoot is not defined in 2.0
    $PSScriptRoot = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
}
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;

Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'LabVMDisk' {

    InModuleScope $moduleName {

        Context 'Validates "ResolveLabVMDiskPath" method' {

            It 'Appends the VM''s name to the host "DifferencingVhdPath"' {
                $testVMName = 'TestVM';
                $testDifferencingVhdPath = 'TestDrive:';
                Mock GetConfigurationData -MockWith { return @{ DifferencingVhdPath = $testDifferencingVhdPath; } }

                $vhdPath = ResolveLabVMDiskPath -Name $testVMName;

                $vhdPath | Should Be "$testDifferencingVhdPath\$testVMName.vhdx";
            }

        }  #end context Validates "ResolveLabVMDiskPath" method

        Context 'Validates "GetLabVMDisk" method' {

            It 'Calls "Get-LabMedia" to resolve the parent VHDX path' {
                $testVMName = 'TestVM';
                $testMedia = 'TestMedia';
                Mock Get-LabImage -ParameterFilter { $Id -eq $testMedia } -MockWith { return @{ ImagePath = "TestDrive:\$testMedia.vhdx"; } }
                Mock ImportDscResource -ParameterFilter { $Prefix -eq 'VHD' } -MockWith { }
                Mock GetDscResource -ParameterFilter { $Parameters.Name -eq $testVMName } -MockWith { }

                $vmDisk = GetLabVMDisk -Name $testVMName -Media $testMedia;

                Assert-MockCalled Get-LabImage -ParameterFilter { $Id -eq $testMedia } -Scope It;
            }
             
            It 'Calls "GetDscResource" with virtual machine name' {
                $testVMName = 'TestVM';
                $testMedia = 'TestMedia';
                Mock Get-LabImage -MockWith { return @{ ImagePath = "TestDrive:\$testMedia.vhdx"; } }
                Mock ImportDscResource -ParameterFilter { $Prefix -eq 'VHD' } -MockWith { }
                Mock GetDscResource -ParameterFilter { $Parameters.Name -eq $testVMName } -MockWith { }

                $vmDisk = GetLabVMDisk -Name $testVMName -Media $testMedia;

                Assert-MockCalled GetDscResource -ParameterFilter { $Parameters.Name -eq $testVMName } -Scope It;
            }
        
        }  #end context Validates "GetLabVMDisk" method

        Context 'Validates "TestLabVMDisk" method' {

            It 'Calls "Get-LabMedia" to resolve the parent VHDX path' {
                $testVMName = 'TestVM';
                $testMedia = 'TestMedia';
                Mock Get-LabImage -ParameterFilter { $Id -eq $testMedia } -MockWith { return @{ ImagePath = "TestDrive:\$testMedia.vhdx"; } }
                Mock ImportDscResource -ParameterFilter { $Prefix -eq 'VHD' } -MockWith { }
                Mock TestDscResource -ParameterFilter { $Parameters.Name -eq $testVMName } -MockWith { }

                $vmDisk = TestLabVMDisk -Name $testVMName -Media $testMedia;

                Assert-MockCalled Get-LabImage -ParameterFilter { $Id -eq $testMedia } -Scope It;
            }
             
            It 'Calls "TestDscResource" with virtual machine name' {
                $testVMName = 'TestVM';
                $testMedia = 'TestMedia';
                Mock Get-LabImage -MockWith { return @{ ImagePath = "TestDrive:\$testMedia.vhdx"; } }
                Mock ImportDscResource -ParameterFilter { $Prefix -eq 'VHD' } -MockWith { }
                Mock TestDscResource -ParameterFilter { $Parameters.Name -eq $testVMName } -MockWith { }

                $vmDisk = TestLabVMDisk -Name $testVMName -Media $testMedia;

                Assert-MockCalled TestDscResource -ParameterFilter { $Parameters.Name -eq $testVMName } -Scope It;
            }
        
        }  #end context Validates "TestLabVMDisk" method

        Context 'Validates "SetLabVMDisk" method' {

            It 'Calls "Get-LabMedia" to resolve the parent VHDX path' {
                $testVMName = 'TestVM';
                $testMedia = 'TestMedia';
                Mock Get-LabImage -ParameterFilter { $Id -eq $testMedia } -MockWith { return @{ ImagePath = "TestDrive:\$testMedia.vhdx"; } }
                Mock ImportDscResource -ParameterFilter { $Prefix -eq 'VHD' } -MockWith { }
                Mock InvokeDscResource -ParameterFilter { $Parameters.Name -eq $testVMName } -MockWith { }

                $vmDisk = SetLabVMDisk -Name $testVMName -Media $testMedia;

                Assert-MockCalled Get-LabImage -ParameterFilter { $Id -eq $testMedia } -Scope It;
            }
             
            It 'Calls "InvokeDscResource" with virtual machine name' {
                $testVMName = 'TestVM';
                $testMedia = 'TestMedia';
                Mock Get-LabImage -MockWith { return @{ ImagePath = "TestDrive:\$testMedia.vhdx"; } }
                Mock ImportDscResource -ParameterFilter { $Prefix -eq 'VHD' } -MockWith { }
                Mock InvokeDscResource -ParameterFilter { $Parameters.Name -eq $testVMName } -MockWith { }

                $vmDisk = SetLabVMDisk -Name $testVMName -Media $testMedia;

                Assert-MockCalled InvokeDscResource -ParameterFilter { $Parameters.Name -eq $testVMName } -Scope It;
            }
        
        }  #end context Validates "SetLabVMDisk" method

        Context 'Validates "RemoveLabVMDisk" method' {

            It 'Calls "Get-LabMedia" to resolve the parent VHDX path' {
                $testVMName = 'TestVM';
                $testMedia = 'TestMedia';
                Mock Get-LabImage -ParameterFilter { $Id -eq $testMedia } -MockWith { return @{ ImagePath = "TestDrive:\$testMedia.vhdx"; } }
                Mock ImportDscResource -ParameterFilter { $Prefix -eq 'VHD' } -MockWith { }
                Mock InvokeDscResource -ParameterFilter { $Parameters.Name -eq $testVMName } -MockWith { }

                $vmDisk = RemoveLabVMDisk -Name $testVMName -Media $testMedia;

                Assert-MockCalled Get-LabImage -ParameterFilter { $Id -eq $testMedia } -Scope It;
            }
             
            It 'Calls "InvokeDscResource" with virtual "Ensure" = "Absent"' {
                $testVMName = 'TestVM';
                $testMedia = 'TestMedia';
                $testImagePath = "TestDrive:\$testMedia.vhdx";
                $testLabVMDiskPath = "TestDrive:\$testVMName.vhdx";
                Mock GetConfigurationData -MockWith { return @{ DifferencingVhdPath = 'TestDrive:'; } }
                Mock Get-LabImage -MockWith { return @{ ImagePath = $testImagePath; } }
                Mock ImportDscResource -ParameterFilter { $Prefix -eq 'VHD' } -MockWith { }
                Mock InvokeDscResource -ParameterFilter { $Parameters.Ensure -eq 'Absent' } -MockWith { }
                New-Item -Path $testLabVMDiskPath -ItemType File -Force -ErrorAction SilentlyContinue;

                $vmDisk = RemoveLabVMDisk -Name $testVMName -Media $testMedia;

                Assert-MockCalled InvokeDscResource -ParameterFilter { $Parameters.Ensure -eq 'Absent' } -Scope It;
            }
        
        }  #end context Validates "RemoveLabVMDisk" method

        Context 'Validates "ResetLabVMDisk" method' {

            It 'Removes any existing snapshots' {
                $testVMName = 'TestVM';
                $testMedia = 'TestMedia';
                Mock RemoveLabVMSnapshot -ParameterFilter { $Name -eq $testVMName } -MockWith { }
                Mock RemoveLabVMDisk -ParameterFilter { $Name -eq $testVMName } -MockWith { }
                Mock SetLabVMDisk -ParameterFilter { $Name -eq $testVMName } -MockWith { }

                ResetLabVMDisk -Name $testVMName -Media $testMedia;

                Assert-MockCalled RemoveLabVMSnapshot -ParameterFilter { $Name -eq $testVMName } -Scope It;
            }

            It 'Removes the existing VHDX file' {
                $testVMName = 'TestVM';
                $testMedia = 'TestMedia';
                Mock RemoveLabVMSnapshot -ParameterFilter { $Name -eq $testVMName } -MockWith { }
                Mock RemoveLabVMDisk -ParameterFilter { $Name -eq $testVMName } -MockWith { }
                Mock SetLabVMDisk -ParameterFilter { $Name -eq $testVMName } -MockWith { }

                ResetLabVMDisk -Name $testVMName -Media $testMedia;

                Assert-MockCalled RemoveLabVMDisk -ParameterFilter { $Name -eq $testVMName } -Scope It;
            }

            It 'Creates a new VHDX file' {
                $testVMName = 'TestVM';
                $testMedia = 'TestMedia';
                Mock RemoveLabVMSnapshot -ParameterFilter { $Name -eq $testVMName } -MockWith { }
                Mock RemoveLabVMDisk -ParameterFilter { $Name -eq $testVMName } -MockWith { }
                Mock SetLabVMDisk -ParameterFilter { $Name -eq $testVMName } -MockWith { }

                ResetLabVMDisk -Name $testVMName -Media $testMedia;

                Assert-MockCalled SetLabVMDisk -ParameterFilter { $Name -eq $testVMName } -Scope It;
            }
        
        }  #end context Validates "ResetLabVMDisk" method
        
    } #end InModuleScope

} #end describe LabVMDisk
