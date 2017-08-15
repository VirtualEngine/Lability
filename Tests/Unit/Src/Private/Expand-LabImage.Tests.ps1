#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Expand-LabImage' {

    InModuleScope $moduleName {

        function Get-Volume {
        <#
            Suppress Error:
            Cannot process argument transformation on parameter 'DiskImage'. Cannot convert the
            "@{DriveLetter=Z}" value of type "System.Management.Automation.PSCustomObject" to type
            "Microsoft.Management.Infrastructure.CimInstance"
        #>
            param (
                [PSCustomObject] $DiskImage
            )
        }

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
            Mock Mount-DiskImage -MockWith { return [PSCustomObject] @{ ImagePath = $testIsoPath } }

            Expand-LabImage -MediaPath $testIsoPath -WimImageIndex $testWimImageIndex -Vhd $testVhdImage -PartitionStyle GPT;

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

            Expand-LabImage -MediaPath $testWimPath -WimImageIndex $testWimImageIndex -Vhd $testVhdImage -PartitionStyle GPT;

            Assert-MockCalled Mount-DiskImage -Scope It -Exactly 0;
        }

        It 'Calls "Get-WindowsImageByIndex" method when passing "WimImageName"' {
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
            Mock Get-WindowsImageByIndex -MockWith { return 42; }

            Expand-LabImage -MediaPath $testIsoPath -WimImageName $testWimImageName -Vhd $testVhdImage -PartitionStyle GPT;

            Assert-MockCalled Get-WindowsImageByIndex -ParameterFilter { $ImageName -eq $testWimImageName } -Scope It;
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
            Mock Expand-WindowsImage -MockWith { }

            Expand-LabImage -MediaPath $testIsoPath -WimImageIndex $testWimImageIndex -Vhd $testVhdImage -PartitionStyle MBR;

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
            Mock Expand-WindowsImage -MockWith { }

            Expand-LabImage -MediaPath $testIsoPath -WimImageIndex $testWimImageIndex -Vhd $testVhdImage -PartitionStyle MBR -WimPath $testWimPath;

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
            Mock Dismount-DiskImage -MockWith { }

            Expand-LabImage -MediaPath $testIsoPath -WimImageIndex $testWimImageIndex -Vhd $testVhdImage -PartitionStyle GPT;

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

            Expand-LabImage -MediaPath $testWimPath -WimImageIndex $testWimImageIndex -Vhd $testVhdImage -PartitionStyle GPT;

            Assert-MockCalled Dismount-DiskImage -Scope It -Exactly 0;
        }

        It 'Calls "Add-LabImageWindowsOptionalFeature" when "WindowsOptionalFeature" is defined' {
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
            Mock Get-WindowsImageByIndex -MockWith { return 42; }
            Mock Add-LabImageWindowsOptionalFeature -MockWith { }

            $expandLabImageParams = @{
                MediaPath = $testIsoPath;
                WimImageName = $testWimImageName;
                Vhd = $testVhdImage;
                PartitionStyle = 'GPT';
                WindowsOptionalFeature = 'NetFx3';
            }
            Expand-LabImage @expandLabImageParams;

            Assert-MockCalled Add-LabImageWindowsOptionalFeature -Scope It;
        }

        It 'Calls "Add-LabImageWindowsOptionalFeature" with custom "SourcePath"' {
            $testWimPath = 'TestDrive:\TestWimImage.wim';
            [ref] $null = New-Item -Path $testWimPath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testVhdPath = 'TestDrive:\TestImage.vhdx';
            $testVhdImage = @{ Path = $testVhdPath };
            $testWimImageName = 'TestWimImage';
            $testSourcePath = '\CustomSourcePath';
            Mock GetDiskImageDriveLetter -MockWith { return 'Z' }
            Mock Expand-WindowsImage -MockWith { }
            Mock Get-WindowsImageByIndex { return 42; }
            Mock Add-LabImageWindowsOptionalFeature -MockWith { }

            $expandLabImageParams = @{
                MediaPath = $testWimPath;
                WimImageName = $testWimImageName;
                Vhd = $testVhdImage;
                PartitionStyle = 'GPT';
                WindowsOptionalFeature = 'NetFx3';
                SourcePath = $testSourcePath;
            }
            Expand-LabImage @expandLabImageParams -WarningAction SilentlyContinue;

            Assert-MockCalled Add-LabImageWindowsOptionalFeature -ParameterFilter { $ImagePath.EndsWith($testSourcePath) }-Scope It;

        }

        It 'Dismounts ISO image when error is thrown (#166)' {
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
            Mock Expand-WindowsImage -MockWith { Write-Error 'Should Dismount ISO' }

            Expand-LabImage -MediaPath $testIsoPath -WimImageIndex $testWimImageIndex -Vhd $testVhdImage -PartitionStyle GPT -ErrorAction SilentlyContinue;

            Assert-MockCalled Dismount-DiskImage -ParameterFilter { $ImagePath -eq $testIsoPath } -Scope It;
        }

    } #end InModuleScope

} #end Describe
