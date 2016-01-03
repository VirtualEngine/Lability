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
                [ref] $null = New-Item -Path $testIsoPath -ItemType File -Force -ErrorAction SilentlyContinue;
                $testVhdPath = 'TestDrive:\TestImage.vhdx';
                $testVhdImage = @{ Path = $testVhdPath };
                $testWimImageIndex = 42;
                Mock Get-DiskImage -MockWith { return [PSCustomObject] @{ DriveLetter = 'Z' } }
                Mock Get-Volume -MockWith { return [PSCustomObject] @{ DriveLetter = 'Z' } }
                Mock GetDiskImageDriveLetter -MockWith { return 'Z' }
                Mock Expand-WindowsImage -MockWith { }
                Mock Dismount-DiskImage -MockWith { }
                Mock Mount-DiskImage -ParameterFilter { $ImagePath -eq $testIsoPath } -MockWith { return [PSCustomObject] @{ ImagePath = $testIsoPath } }
                
                ExpandWindowsImage -MediaPath $testIsoPath -WimImageIndex $testWimImageIndex -Vhd $testVhdImage -PartitionStyle GPT;
                
                Assert-MockCalled Mount-DiskImage -ParameterFilter { $ImagePath -eq $testIsoPath } -Scope It;
            }

            It 'Does not Mount WIM image' {
                $testWimPath = 'TestDrive:\TestWimImage.wim';
                [ref] $null = New-Item -Path $testWimPath -ItemType File -Force -ErrorAction SilentlyContinue;
                $testVhdPath = 'TestDrive:\TestImage.vhdx';
                $testVhdImage = @{ Path = $testVhdPath };
                $testWimImageIndex = 42;
                Mock GetDiskImageDriveLetter -MockWith { return 'Z' }
                Mock Expand-WindowsImage -MockWith { }
                Mock Mount-DiskImage -MockWith { }
                
                ExpandWindowsImage -MediaPath $testWimPath -WimImageIndex $testWimImageIndex -Vhd $testVhdImage -PartitionStyle GPT;
                
                Assert-MockCalled Mount-DiskImage -Scope It -Exactly 0;
            }

            It 'Calls "GetWindowsImageIndex" method when passing "WimImageName"' {
                $testIsoPath = 'TestDrive:\TestIsoImage.iso';
                [ref] $null = New-Item -Path $testIsoPath -ItemType File -Force -ErrorAction SilentlyContinue;
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

                ExpandWindowsImage -MediaPath $testIsoPath -WimImageName $testWimImageName -Vhd $testVhdImage -PartitionStyle GPT;

                Assert-MockCalled GetWindowsImageIndex -ParameterFilter { $ImageName -eq $testWimImageName } -Scope It;
            }

            It 'Calls "Expand-WindowsImage" with specified "WimImageIndex"' {
                $testIsoPath = 'TestDrive:\TestIsoImage.iso';
                [ref] $null = New-Item -Path $testIsoPath -ItemType File -Force -ErrorAction SilentlyContinue;
                $testVhdPath = 'TestDrive:\TestImage.vhdx';
                $testVhdImage = @{ Path = $testVhdPath };
                $testWimImageIndex = 42;
                Mock Get-DiskImage -MockWith { return [PSCustomObject] @{ DriveLetter = 'Z' } }
                Mock Get-Volume -MockWith { return [PSCustomObject] @{ DriveLetter = 'Z' } }
                Mock GetDiskImageDriveLetter -MockWith { return 'Z' }
                Mock Mount-DiskImage -MockWith { return [PSCustomObject] @{ ImagePath = $testIsoPath } }
                Mock Dismount-DiskImage -MockWith { }
                Mock Expand-WindowsImage -ParameterFilter { $Index -eq $testWimImageIndex} -MockWith { }

                ExpandWindowsImage -MediaPath $testIsoPath -WimImageIndex $testWimImageIndex -Vhd $testVhdImage -PartitionStyle MBR;

                Assert-MockCalled Expand-WindowsImage -ParameterFilter { $Index -eq $testWimImageIndex} -Scope It;
            }

            It 'Calls "Expand-WindowsImage" with custom "WimPath"' {
                $testIsoPath = 'TestDrive:\TestIsoImage.iso';
                [ref] $null = New-Item -Path $testIsoPath -ItemType File -Force -ErrorAction SilentlyContinue;
                $testVhdPath = 'TestDrive:\TestImage.vhdx';
                $testVhdImage = @{ Path = $testVhdPath };
                $testWimImageIndex = 42;
                $testWimPath = '\custom.wim';
                Mock Get-DiskImage -MockWith { return [PSCustomObject] @{ DriveLetter = 'Z' } }
                Mock Get-Volume -MockWith { return [PSCustomObject] @{ DriveLetter = 'Z' } }
                Mock GetDiskImageDriveLetter -MockWith { return 'Z' }
                Mock Mount-DiskImage -MockWith { return [PSCustomObject] @{ ImagePath = $testIsoPath } }
                Mock Dismount-DiskImage -MockWith { }
                Mock Expand-WindowsImage -ParameterFilter { $ImagePath.EndsWith($testWimPath) } -MockWith { }

                ExpandWindowsImage -MediaPath $testIsoPath -WimImageIndex $testWimImageIndex -Vhd $testVhdImage -PartitionStyle MBR -WimPath $testWimPath;

                Assert-MockCalled Expand-WindowsImage -ParameterFilter { $ImagePath.EndsWith($testWimPath) } -Scope It;
            }

            It 'Dismounts ISO image' {
                $testIsoPath = 'TestDrive:\TestIsoImage.iso';
                [ref] $null = New-Item -Path $testIsoPath -ItemType File -Force -ErrorAction SilentlyContinue;
                $testVhdPath = 'TestDrive:\TestImage.vhdx';
                $testVhdImage = @{ Path = $testVhdPath };
                $testWimImageIndex = 42;
                Mock Get-DiskImage -MockWith { return [PSCustomObject] @{ DriveLetter = 'Z' } }
                Mock Get-Volume -MockWith { return [PSCustomObject] @{ DriveLetter = 'Z' } }
                Mock GetDiskImageDriveLetter -MockWith { return 'Z' }
                Mock Expand-WindowsImage -MockWith { }
                Mock Mount-DiskImage -MockWith { return [PSCustomObject] @{ ImagePath = $testIsoPath } }
                Mock Dismount-DiskImage -ParameterFilter { $ImagePath -eq $testIsoPath } -MockWith { }

                ExpandWindowsImage -MediaPath $testIsoPath -WimImageIndex $testWimImageIndex -Vhd $testVhdImage -PartitionStyle GPT;

                Assert-MockCalled Dismount-DiskImage -ParameterFilter { $ImagePath -eq $testIsoPath } -Scope It;
            }

            It 'Does not dismount WIM image' {
                $testWimPath = 'TestDrive:\TestWimImage.wim';
                [ref] $null = New-Item -Path $testWimPath -ItemType File -Force -ErrorAction SilentlyContinue;
                $testVhdPath = 'TestDrive:\TestImage.vhdx';
                $testVhdImage = @{ Path = $testVhdPath };
                $testWimImageIndex = 42;
                Mock GetDiskImageDriveLetter -MockWith { return 'Z' }
                Mock Expand-WindowsImage -MockWith { }
                Mock Dismount-DiskImage { }

                ExpandWindowsImage -MediaPath $testWimPath -WimImageIndex $testWimImageIndex -Vhd $testVhdImage -PartitionStyle GPT;

                Assert-MockCalled Dismount-DiskImage -Scope It -Exactly 0;
            }

            It 'Calls "AddWindowsOptionalFeature" when "WindowsOptionalFeature" is defined' {
                $testIsoPath = 'TestDrive:\TestIsoImage.iso';
                [ref] $null = New-Item -Path $testIsoPath -ItemType File -Force -ErrorAction SilentlyContinue;
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
                Mock AddWindowsOptionalFeature { }

                $expandWindowsImageParams = @{
                    MediaPath = $testIsoPath;
                    WimImageName = $testWimImageName;
                    Vhd = $testVhdImage;
                    PartitionStyle = 'GPT';
                    WindowsOptionalFeature = 'NetFx3';
                }
                ExpandWindowsImage @expandWindowsImageParams;

                Assert-MockCalled AddWindowsOptionalFeature -Scope It;
            }

            It 'Calls "AddWindowsOptionalFeature" with custom "SourcePath"' {
                $testWimPath = 'TestDrive:\TestWimImage.wim';
                [ref] $null = New-Item -Path $testWimPath -ItemType File -Force -ErrorAction SilentlyContinue;
                $testVhdPath = 'TestDrive:\TestImage.vhdx';
                $testVhdImage = @{ Path = $testVhdPath };
                $testWimImageName = 'TestWimImage';
                $testSourcePath = '\CustomSourcePath';
                Mock GetDiskImageDriveLetter -MockWith { return 'Z' }
                Mock Expand-WindowsImage -MockWith { }
                Mock GetWindowsImageIndex { return 42; }
                Mock AddWindowsOptionalFeature -ParameterFilter { $ImagePath.EndsWith($testSourcePath) } -MockWith { }

                $expandWindowsImageParams = @{
                    MediaPath = $testWimPath;
                    WimImageName = $testWimImageName;
                    Vhd = $testVhdImage;
                    PartitionStyle = 'GPT';
                    WindowsOptionalFeature = 'NetFx3';
                    SourcePath = $testSourcePath;
                }
                ExpandWindowsImage @expandWindowsImageParams -WarningAction SilentlyContinue;

                Assert-MockCalled AddWindowsOptionalFeature -ParameterFilter { $ImagePath.EndsWith($testSourcePath) }-Scope It;
            
            }

        } #end context Validates "ExpandWindowsImage" method

        Context 'Validates "GetWindowsImageIndex" method' {

            It 'Returns a "System.Int32" type' {
                $testWimPath = 'TestDrive:\TestIsoImage.wim';
                [ref] $null = New-Item -Path $testWimPath -ItemType File -Force -ErrorAction SilentlyContinue;
                $testImageName = 'Test Image';
                $testImageIndex = 42;
                $fakeWindowsImages = @(
                    [PSCustomObject] @{ ImageName = $testImageName; ImageIndex = $testImageIndex; }
                    [PSCustomObject] @{ ImageName = 'A random Image'; ImageIndex = $testImageIndex + 1; }
                )
                Mock Get-WindowsImage -ParameterFilter { $ImagePath -eq $testWimPath } -MockWith { return $fakeWindowsImages; }

                $imageIndex = GetWindowsImageIndex -ImagePath $testWimPath -ImageName $testImageName;
                
                $imageIndex -is [System.Int32] | Should Be $true;
            }

            It 'Returns the matching image index if found' {
                $testWimPath = 'TestDrive:\TestIsoImage.wim';
                [ref] $null = New-Item -Path $testWimPath -ItemType File -Force -ErrorAction SilentlyContinue;
                $testImageName = 'Test Image';
                $testImageIndex = 42;
                $fakeWindowsImages = @(
                    [PSCustomObject] @{ ImageName = $testImageName; ImageIndex = $testImageIndex; }
                    [PSCustomObject] @{ ImageName = 'A random Image'; ImageIndex = $testImageIndex + 1; }
                )
                Mock Get-WindowsImage -ParameterFilter { $ImagePath -eq $testWimPath } -MockWith { return $fakeWindowsImages; }

                $imageIndex = GetWindowsImageIndex -ImagePath $testWimPath -ImageName $testImageName;
                
                $imageIndex | Should Be $testImageIndex;
            }

            It 'Returns nothing when image index is not found' {
                $testWimPath = 'TestDrive:\TestIsoImage.wim';
                [ref] $null = New-Item -Path $testWimPath -ItemType File -Force -ErrorAction SilentlyContinue;
                $testImageName = 'Test Image';
                $testImageIndex = 42;
                $fakeWindowsImages = @(
                    [PSCustomObject] @{ ImageName = $testImageName; ImageIndex = $testImageIndex; }
                    [PSCustomObject] @{ ImageName = 'A random Image'; ImageIndex = $testImageIndex + 1; }
                )
                Mock Get-WindowsImage -ParameterFilter { $ImagePath -eq $testWimPath } -MockWith { return $fakeWindowsImages; }

                $imageIndex = GetWindowsImageIndex -ImagePath $testWimPath -ImageName 'This should not exist';
                
                $imageIndex | Should BeNullOrEmpty;
            }

        } #end context Validates "GetWindowsImageIndex" method

        Context 'Validates "GetWindowsImageName" method' {

            It 'Returns a "System.String" type' {
                $testWimPath = 'TestDrive:\TestIsoImage.wim';
                [ref] $null = New-Item -Path $testWimPath -ItemType File -Force -ErrorAction SilentlyContinue;
                $testImageName = 'Test Image';
                $testImageIndex = 42;
                $fakeWindowsImages = @(
                    [PSCustomObject] @{ ImageName = $testImageName; ImageIndex = $testImageIndex; }
                    [PSCustomObject] @{ ImageName = 'A random Image'; ImageIndex = $testImageIndex + 1; }
                )
                Mock Get-WindowsImage -ParameterFilter { $ImagePath -eq $testWimPath } -MockWith { return $fakeWindowsImages; }

                $imageName = GetWindowsImageName -ImagePath $testWimPath -ImageIndex $testImageIndex;
                
                $imageName -is [System.String] | Should Be $true;
            }

            It 'Returns the matching image name' {
                $testWimPath = 'TestDrive:\TestIsoImage.wim';
                [ref] $null = New-Item -Path $testWimPath -ItemType File -Force -ErrorAction SilentlyContinue;
                $testImageName = 'Test Image';
                $testImageIndex = 42;
                $fakeWindowsImages = @(
                    [PSCustomObject] @{ ImageName = $testImageName; ImageIndex = $testImageIndex; }
                    [PSCustomObject] @{ ImageName = 'A random Image'; ImageIndex = $testImageIndex + 1; }
                )
                Mock Get-WindowsImage -ParameterFilter { $ImagePath -eq $testWimPath } -MockWith { return $fakeWindowsImages; }

                $imageName = GetWindowsImageName -ImagePath $testWimPath -ImageIndex $testImageIndex;
                
                $imageName | Should Be $testImageName;
            }

            It 'Returns nothing when image name is not found' {
                $testWimPath = 'TestDrive:\TestIsoImage.wim';
                [ref] $null = New-Item -Path $testWimPath -ItemType File -Force -ErrorAction SilentlyContinue;
                $testImageName = 'Test Image';
                $testImageIndex = 42;
                $fakeWindowsImages = @(
                    [PSCustomObject] @{ ImageName = $testImageName; ImageIndex = $testImageIndex; }
                    [PSCustomObject] @{ ImageName = 'A random Image'; ImageIndex = $testImageIndex + 1; }
                )
                Mock Get-WindowsImage -ParameterFilter { $ImagePath -eq $testWimPath } -MockWith { return $fakeWindowsImages; }

                $imageName = GetWindowsImageName -ImagePath $testWimPath -ImageIndex 99;
                
                $imageName | Should BeNullOrEmpty;
            }

        } #end context Validates "GetWindowsImageName" method

    } #end InModuleScope

} #end describe WindowsImage
