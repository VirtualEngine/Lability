#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\LabVMDisk' {

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

            It 'Calls "Get-LabImage" with "ConfigurationData" when specified (#97)' {
                $testVMName = 'TestVM';
                $testMedia = 'TestMedia';
                Mock ImportDscResource -MockWith { }
                Mock GetDscResource -MockWith { }
                Mock Get-LabImage -ParameterFilter { $null -ne $ConfigurationData } -MockWith { return @{ ImagePath = "TestDrive:\$testMedia.vhdx"; } }

                $vmDisk = GetLabVMDisk -Name $testVMName -Media $testMedia -ConfigurationData @{};

                Assert-MockCalled Get-LabImage -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
            }

        }  #end context Validates "GetLabVMDisk" method

        Context 'Validates "TestLabVMDisk" method' {

            It 'Calls "Get-LabMedia" to resolve the parent VHDX path' {
                $testVM = 'TestVM';
                $testMedia = 'TestMedia';
                Mock Get-LabImage -MockWith { return @{ ImagePath = "TestDrive:\$testMedia.vhdx"; } }
                Mock ImportDscResource -ParameterFilter { $Prefix -eq 'VHD' } -MockWith { }
                Mock TestDscResource -MockWith { }

                $vmDisk = TestLabVMDisk -Name $testVM -Media $testMedia;

                Assert-MockCalled Get-LabImage -Scope It;
            }

            It 'Calls "TestDscResource" with virtual machine name' {
                $testVMName = 'TestVMName';
                $testMedia = 'TestMedia';
                Mock Get-LabImage -MockWith { return @{ ImagePath = "TestDrive:\$testMedia.vhdx"; } }
                Mock ImportDscResource -ParameterFilter { $Prefix -eq 'VHD' } -MockWith { }
                Mock TestDscResource -ParameterFilter { $Parameters.Name -eq $testVMName } -MockWith { }

                $vmDisk = TestLabVMDisk -Name $testVMName -Media $testMedia;

                Assert-MockCalled TestDscResource -ParameterFilter { $Parameters.Name -eq $testVMName } -Scope It;
            }

            It 'Calls "TestDscResource" with "MaximumSize" when image is not available (#104)' {
                $testVMSize = 'TestVMSize';
                $testMedia = 'TestNewMedia';
                Mock Get-LabImage -MockWith { }
                Mock ImportDscResource -ParameterFilter { $Prefix -eq 'VHD' } -MockWith { }
                Mock TestDscResource -ParameterFilter { $Parameters.MaximumSize -eq 127GB } -MockWith { }

                $vmDisk = TestLabVMDisk -Name $testVMSize -Media $testMedia;

                Assert-MockCalled TestDscResource -ParameterFilter { $Parameters.MaximumSize -eq 127GB } -Scope It;
            }

            It 'Calls "TestDscResource" with "VHDX" when image is not available (#104)' {
                $testVMGeneration = 'TestVMGeneration';
                $testMedia = 'TestNewMedia';
                Mock Get-LabImage -MockWith { }
                Mock ImportDscResource -ParameterFilter { $Prefix -eq 'VHD' } -MockWith { }
                Mock TestDscResource -ParameterFilter { $Parameters.Generation -eq 'VHDX' } -MockWith { }

                $vmDisk = TestLabVMDisk -Name $testVMGeneration -Media $testMedia;

                Assert-MockCalled TestDscResource -ParameterFilter { $Parameters.Generation -eq 'VHDX' } -Scope It;
            }

            It 'Calls "Get-LabImage" with "ConfigurationData" when specified (#97)' {
                $testVMName = 'TestVM';
                $testMedia = 'TestMedia';
                Mock Get-LabImage -ParameterFilter { $null -ne $ConfigurationData } -MockWith { return @{ ImagePath = "TestDrive:\$testMedia.vhdx"; } }
                Mock ImportDscResource -MockWith { }
                Mock TestDscResource -MockWith { }

                $vmDisk = TestLabVMDisk -Name $testVMName -Media $testMedia -ConfigurationData @{};

                Assert-MockCalled Get-LabImage -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
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

            It 'Calls "Get-LabImage" with "ConfigurationData" when specified (#97)' {
                $testVMName = 'TestVM';
                $testMedia = 'TestMedia';
                Mock Get-LabImage -ParameterFilter { $null -ne $ConfigurationData } -MockWith { return @{ ImagePath = "TestDrive:\$testMedia.vhdx"; } }
                Mock ImportDscResource -MockWith { }
                Mock InvokeDscResource -MockWith { }

                $vmDisk = SetLabVMDisk -Name $testVMName -Media $testMedia -ConfigurationData @{};

                Assert-MockCalled Get-LabImage -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
            }

        }  #end context Validates "SetLabVMDisk" method

        Context 'Validates "RemoveLabVMDisk" method' {

            It 'Calls "Get-LabMedia" to resolve the parent VHDX path' {
                $testVMName = 'TestVM';
                $testMedia = 'TestMedia';
                Mock Get-LabImage -ParameterFilter { $Id -eq $testMedia } -MockWith { return @{ ImagePath = "TestDrive:\$testMedia.vhdx"; Generation = 'VHDX'; } }
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
                Mock Get-LabImage -MockWith { return @{ ImagePath = $testImagePath; Generation = 'VHDX'; } }
                Mock ImportDscResource -ParameterFilter { $Prefix -eq 'VHD' } -MockWith { }
                Mock InvokeDscResource -ParameterFilter { $Parameters.Ensure -eq 'Absent' } -MockWith { }
                New-Item -Path $testLabVMDiskPath -ItemType File -Force -ErrorAction SilentlyContinue;

                $vmDisk = RemoveLabVMDisk -Name $testVMName -Media $testMedia;

                Assert-MockCalled InvokeDscResource -ParameterFilter { $Parameters.Ensure -eq 'Absent' } -Scope It;
            }

            It 'Calls "Get-LabImage" with "ConfigurationData" when specified (#97)' {
                $testVMName = 'TestVM';
                $testMedia = 'TestMedia';
                Mock Get-LabImage -ParameterFilter { $null -ne $ConfigurationData } -MockWith { return @{ ImagePath = "TestDrive:\$testMedia.vhdx"; Generation = 'VHDX'; } }
                Mock ImportDscResource -MockWith { }
                Mock InvokeDscResource -MockWith { }

                $vmDisk = RemoveLabVMDisk -Name $testVMName -Media $testMedia -ConfigurationData @{};

                Assert-MockCalled Get-LabImage -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
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

            It 'Calls "RemoveLabVMDisk" and "SetLabVMDisk" with "ConfigurationData" when specified (#97)' {
                $testVMName = 'TestVM';
                $testMedia = 'TestMedia';
                Mock RemoveLabVMSnapshot -MockWith { }
                Mock RemoveLabVMDisk -ParameterFilter { $null -ne $ConfigurationData } -MockWith { }
                Mock SetLabVMDisk -ParameterFilter { $null -ne $ConfigurationData } -MockWith { }

                ResetLabVMDisk -Name $testVMName -Media $testMedia -ConfigurationData @{};

                Assert-MockCalled RemoveLabVMDisk -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
                Assert-MockCalled SetLabVMDisk -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
            }

        }  #end context Validates "ResetLabVMDisk" method

    } #end InModuleScope

} #end describe Src\LabVMDisk
