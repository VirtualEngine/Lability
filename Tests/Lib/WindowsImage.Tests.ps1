#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'VirtualEngineLab';
if (!$PSScriptRoot) { # $PSScriptRoot is not defined in 2.0
    $PSScriptRoot = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
}
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;

Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'WindowsImage' {

    InModuleScope $moduleName {

        Context 'Validates "ExpandWindowsImage" method' {

            It 'Mounts ISO image' {
                $testIsoPath = 'TestDrive:\TestIsoImage.iso';
                $testVhdPath = 'TestDrive:\TestImage.vhdx';
                $testVhdImage = @{ Path = $testVhdPath };
                $testWimImageIndex = 42;
                Mock Get-DiskImage -MockWith { return [PSCustomObject] @{ DriveLetter = 'Z' } }
                Mock Get-Volume -MockWith { return [PSCustomObject] @{ DriveLetter = 'Z' } }
                Mock GetDiskImageDriveLetter -MockWith { return 'Z' }
                Mock Expand-WindowsImage -MockWith { }
                Mock Dismount-DiskImage -MockWith { }
                Mock Mount-DiskImage -ParameterFilter { $ImagePath -eq $testIsoPath } -MockWith { return [PSCustomObject] @{ ImagePath = $testIsoPath } }

                ExpandWindowsImage -IsoPath $testIsoPath -WimImageIndex $testWimImageIndex -Vhd $testVhdImage -PartitionStyle GPT;

                Assert-MockCalled Mount-DiskImage -ParameterFilter { $ImagePath -eq $testIsoPath } -Scope It;
            }

            It 'Calls "GetWindowsImageIndex" method when passing "WimImageName"' {
                $testIsoPath = 'TestDrive:\TestIsoImage.iso';
                $testVhdPath = 'TestDrive:\TestImage.vhdx';
                $testVhdImage = @{ Path = $testVhdPath };
                $testWimImageName = 'TestWimImage';
                Mock Get-DiskImage -MockWith { return [PSCustomObject] @{ DriveLetter = 'Z' } }
                Mock Get-Volume -MockWith { return [PSCustomObject] @{ DriveLetter = 'Z' } }
                Mock GetDiskImageDriveLetter -MockWith { return 'Z' }
                Mock Expand-WindowsImage -MockWith { }
                Mock Mount-DiskImage -MockWith { return [PSCustomObject] @{ ImagePath = $testIsoPath } }
                Mock Dismount-DiskImage -MockWith { }
                Mock GetWindowsImageIndex -ParameterFilter { $ImageName -eq $testWimImageName } -MockWith { return 42; }

                ExpandWindowsImage -IsoPath $testIsoPath -WimImageName $testWimImageName -Vhd $testVhdImage -PartitionStyle GPT;

                Assert-MockCalled GetWindowsImageIndex -ParameterFilter { $ImageName -eq $testWimImageName } -Scope It;
            }

            It 'Calls "Expand-WindowsImage" with specified "WimImageIndex"' {
                $testIsoPath = 'TestDrive:\TestIsoImage.iso';
                $testVhdPath = 'TestDrive:\TestImage.vhdx';
                $testVhdImage = @{ Path = $testVhdPath };
                $testWimImageIndex = 42;
                Mock Get-DiskImage -MockWith { return [PSCustomObject] @{ DriveLetter = 'Z' } }
                Mock Get-Volume -MockWith { return [PSCustomObject] @{ DriveLetter = 'Z' } }
                Mock GetDiskImageDriveLetter -MockWith { return 'Z' }
                Mock Expand-WindowsImage -ParameterFilter { $Index -eq $testWimImageIndex} -MockWith { }
                Mock Mount-DiskImage -MockWith { return [PSCustomObject] @{ ImagePath = $testIsoPath } }
                Mock Dismount-DiskImage -MockWith { }

                ExpandWindowsImage -IsoPath $testIsoPath -WimImageIndex $testWimImageIndex -Vhd $testVhdImage -PartitionStyle MBR;

                Assert-MockCalled Expand-WindowsImage -ParameterFilter { $Index -eq $testWimImageIndex} -Scope It;
            }

            It 'Dismounts ISO image' {
                $testIsoPath = 'TestDrive:\TestIsoImage.iso';
                $testVhdPath = 'TestDrive:\TestImage.vhdx';
                $testVhdImage = @{ Path = $testVhdPath };
                $testWimImageIndex = 42;
                Mock Get-DiskImage -MockWith { return [PSCustomObject] @{ DriveLetter = 'Z' } }
                Mock Get-Volume -MockWith { return [PSCustomObject] @{ DriveLetter = 'Z' } }
                Mock GetDiskImageDriveLetter -MockWith { return 'Z' }
                Mock Expand-WindowsImage -MockWith { }
                Mock Mount-DiskImage -MockWith { return [PSCustomObject] @{ ImagePath = $testIsoPath } }
                Mock Dismount-DiskImage -ParameterFilter { $ImagePath -eq $testIsoPath } -MockWith { }

                ExpandWindowsImage -IsoPath $testIsoPath -WimImageIndex $testWimImageIndex -Vhd $testVhdImage -PartitionStyle GPT;

                Assert-MockCalled Dismount-DiskImage -ParameterFilter { $ImagePath -eq $testIsoPath } -Scope It;
            }

        } #end context Validates "ExpandWindowsImage" method

        Context 'Validates "GetWindowsImageIndex" method' {

            It 'Returns a "System.Int32" type' {
                $testDriveLetter = 'Z';
                $testImageName = 'Test Image';
                $testImageIndex = 42;
                $fakeWindowsImages = @(
                    [PSCustomObject] @{ ImageName = $testImageName; ImageIndex = $testImageIndex; }
                    [PSCustomObject] @{ ImageName = 'A random Image'; ImageIndex = $testImageIndex + 1; }
                )
                Mock Get-WindowsImage -ParameterFilter { $ImagePath -match "^$testDriveLetter" } -MockWith { return $fakeWindowsImages; }

                $imageIndex = GetWindowsImageIndex -IsoDriveLetter $testDriveLetter -ImageName $testImageName;
                
                $imageIndex -is [System.Int32] | Should Be $true;
            }

            It 'Returns the matching image index if found' {
                $testDriveLetter = 'Z';
                $testImageName = 'Test Image';
                $testImageIndex = 42;
                $fakeWindowsImages = @(
                    [PSCustomObject] @{ ImageName = $testImageName; ImageIndex = $testImageIndex; }
                    [PSCustomObject] @{ ImageName = 'A random Image'; ImageIndex = $testImageIndex + 1; }
                )
                Mock Get-WindowsImage -ParameterFilter { $ImagePath -match "^$testDriveLetter" } -MockWith { return $fakeWindowsImages; }

                $imageIndex = GetWindowsImageIndex -IsoDriveLetter $testDriveLetter -ImageName $testImageName;
                
                $imageIndex | Should Be $testImageIndex;
            }

            It 'Returns nothing when image index is not found' {
                $testDriveLetter = 'Z';
                $testImageName = 'Test Image';
                $testImageIndex = 42;
                $fakeWindowsImages = @(
                    [PSCustomObject] @{ ImageName = $testImageName; ImageIndex = $testImageIndex; }
                    [PSCustomObject] @{ ImageName = 'A random Image'; ImageIndex = $testImageIndex + 1; }
                )
                Mock Get-WindowsImage -ParameterFilter { $ImagePath -match "^$testDriveLetter" } -MockWith { return $fakeWindowsImages; }

                $imageIndex = GetWindowsImageIndex -IsoDriveLetter $testDriveLetter -ImageName 'This should not exist';
                
                $imageIndex | Should BeNullOrEmpty;
            }

        } #end context Validates "GetWindowsImageIndex" method

        Context 'Validates "GetWindowsImageName" method' {

            It 'Returns a "System.String" type' {
                $testDriveLetter = 'Z';
                $testImageName = 'Test Image';
                $testImageIndex = 42;
                $fakeWindowsImages = @(
                    [PSCustomObject] @{ ImageName = $testImageName; ImageIndex = $testImageIndex; }
                    [PSCustomObject] @{ ImageName = 'A random Image'; ImageIndex = $testImageIndex + 1; }
                )
                Mock Get-WindowsImage -ParameterFilter { $ImagePath -match "^$testDriveLetter" } -MockWith { return $fakeWindowsImages; }

                $imageName = GetWindowsImageName -IsoDriveLetter $testDriveLetter -ImageIndex $testImageIndex;
                
                $imageName -is [System.String] | Should Be $true;
            }

            It 'Returns the matching image name' {
                $testDriveLetter = 'Z';
                $testImageName = 'Test Image';
                $testImageIndex = 42;
                $fakeWindowsImages = @(
                    [PSCustomObject] @{ ImageName = $testImageName; ImageIndex = $testImageIndex; }
                    [PSCustomObject] @{ ImageName = 'A random Image'; ImageIndex = $testImageIndex + 1; }
                )
                Mock Get-WindowsImage -ParameterFilter { $ImagePath -match "^$testDriveLetter" } -MockWith { return $fakeWindowsImages; }

                $imageName = GetWindowsImageName -IsoDriveLetter $testDriveLetter -ImageIndex $testImageIndex;
                
                $imageName | Should Be $testImageName;
            }

            It 'Returns nothing when image name is not found' {
                $testDriveLetter = 'Z';
                $testImageName = 'Test Image';
                $testImageIndex = 42;
                $fakeWindowsImages = @(
                    [PSCustomObject] @{ ImageName = $testImageName; ImageIndex = $testImageIndex; }
                    [PSCustomObject] @{ ImageName = 'A random Image'; ImageIndex = $testImageIndex + 1; }
                )
                Mock Get-WindowsImage -ParameterFilter { $ImagePath -match "^$testDriveLetter" } -MockWith { return $fakeWindowsImages; }

                $imageName = GetWindowsImageName -IsoDriveLetter $testDriveLetter -ImageIndex 99;
                
                $imageName | Should BeNullOrEmpty;
            }

        } #end context Validates "GetWindowsImageName" method

    } #end InModuleScope

} #end describe WindowsImage
