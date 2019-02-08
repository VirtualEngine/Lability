#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\New-DiskImage' {

    InModuleScope $moduleName {

        It 'Throws if VHD image already exists' {
            $testVhdPath = "TestDrive:\TestImage.vhdx";
            $newDiskImageParams = @{ Path = (New-Item -Path $testVhdPath -Force -ItemType File); PartitionStyle = 'MBR'; }

            { New-DiskImage @newDiskImageParams } | Should Throw;
        }

        It 'Removes existing VHD image if it already exists and -Force is specified' {
            $testVhdPath = "TestDrive:\TestImage.vhdx";
            $newDiskImageParams = @{ Path = (New-Item -Path $testVhdPath -Force -ItemType File); PartitionStyle = 'MBR'; Force = $true; }
            Mock Dismount-VHD -MockWith { }
            Mock Mount-VHD -MockWith { return [PSCustomObject] @{ DiskNumber = 10; } }
            Mock New-Vhd -MockWith { }
            Mock Initialize-Disk -MockWith { }
            Mock New-DiskImageMbr -MockWith { }
            Mock Remove-Item -ParameterFilter { $Path -eq $newDiskImageParams.Path } -MockWith { };
            Mock Get-ItemProperty -MockWith { [PSCustomObject] @{ FDVDenyWriteAccess = 0 } } -ParameterFilter {$Name -eq 'FDVDenyWriteAccess'}

            New-DiskImage @newDiskImageParams;

            Assert-MockCalled Remove-Item -ParameterFilter { $Path -eq $newDiskImageParams.Path } -Scope It;
        }

        It 'Creates new VHD file and initializes disk' {
            $testVhdPath = "TestDrive:\TestImage.vhdx";
            $testDiskNumber = 10;
            $newDiskImageParams = @{ Path = (New-Item -Path $testVhdPath -Force -ItemType File); PartitionStyle = 'GPT'; Force = $true; }
            Mock Dismount-VHD -MockWith { }
            Mock Mount-VHD -MockWith { return [PSCustomObject] @{ DiskNumber = $testDiskNumber; } }
            Mock New-DiskImageGpt -MockWith { }
            Mock Remove-Item -MockWith { };
            Mock Initialize-Disk -ParameterFilter { $Number -eq $testDiskNumber } -MockWith { }
            Mock New-Vhd -ParameterFilter { $Path -eq $newDiskImageParams.Path } -MockWith { }
            Mock Get-ItemProperty -MockWith { [PSCustomObject] @{ FDVDenyWriteAccess = 0 } } -ParameterFilter {$Name -eq 'FDVDenyWriteAccess'}

            New-DiskImage @newDiskImageParams;

            Assert-MockCalled New-Vhd -ParameterFilter { $Path -eq $newDiskImageParams.Path } -Scope It;
            Assert-MockCalled Initialize-Disk -ParameterFilter { $Number -eq $testDiskNumber } -Scope It;
        }

        It 'Does dismount VHD file if -PassThru is not specified' {
            $testVhdPath = "TestDrive:\TestImage2.vhdx";
            $testDiskNumber = 10;
            $newDiskImageParams = @{ Path = $testVhdPath; PartitionStyle = 'GPT'; PassThru = $false; }
            Mock Mount-VHD -MockWith { return [PSCustomObject] @{ DiskNumber = $testDiskNumber; } }
            Mock New-DiskImageGpt -MockWith { }
            Mock Initialize-Disk -MockWith { }
            Mock New-DiskImageMbr -MockWith { }
            Mock Dismount-VHD -ParameterFilter { $Path -eq $testVhdPath } -MockWith { }
            Mock Get-ItemProperty -MockWith { [PSCustomObject] @{ FDVDenyWriteAccess = 0 } } -ParameterFilter {$Name -eq 'FDVDenyWriteAccess'}

            New-DiskImage @newDiskImageParams;

            Assert-MockCalled Dismount-VHD -ParameterFilter { $Path -eq $testVhdPath } -Scope It;
        }

        It 'Does not dismount VHD file if -PassThru is specified' {
            $testVhdPath = "TestDrive:\TestImage3.vhdx";
            $testDiskNumber = 10;
            $newDiskImageParams = @{ Path = $testVhdPath; PartitionStyle = 'GPT'; PassThru = $true; }
            Mock Mount-VHD -MockWith { return [PSCustomObject] @{ DiskNumber = $testDiskNumber; } }
            Mock New-DiskImageGpt -MockWith { }
            Mock Initialize-Disk -MockWith { }
            Mock New-DiskImageMbr -MockWith { }
            Mock Dismount-VHD -ParameterFilter { $Path -eq $testVhdPath } -MockWith { }
            Mock Get-ItemProperty -MockWith { [PSCustomObject] @{ FDVDenyWriteAccess = 0 } } -ParameterFilter {$Name -eq 'FDVDenyWriteAccess'}

            New-DiskImage @newDiskImageParams;

            Assert-MockCalled Dismount-VHD -ParameterFilter { $Path -eq $testVhdPath } -Scope It -Exactly 0;
        }

        It 'Creates a dynamic disk when no "Type" is defined (#99)' {
            $testVhdPath = "TestDrive:\TestImage.vhdx";
            $testDiskNumber = 10;
            $newDiskImageParams = @{ Path = (New-Item -Path $testVhdPath -Force -ItemType File); PartitionStyle = 'GPT'; Force = $true; }
            Mock Dismount-VHD -MockWith { }
            Mock Mount-VHD -MockWith { return [PSCustomObject] @{ DiskNumber = $testDiskNumber; } }
            Mock New-DiskImageGpt -MockWith { }
            Mock Remove-Item -MockWith { };
            Mock Initialize-Disk -ParameterFilter { $Number -eq $testDiskNumber } -MockWith { }
            Mock New-Vhd -ParameterFilter { $Path -eq $newDiskImageParams.Path } -MockWith { }
            Mock Get-ItemProperty -MockWith { [PSCustomObject] @{ FDVDenyWriteAccess = 0 } } -ParameterFilter {$Name -eq 'FDVDenyWriteAccess'}

            New-DiskImage @newDiskImageParams;

            Assert-MockCalled New-Vhd -ParameterFilter { $PSBoundParameters.ContainsKey('Dynamic') -eq $true } -Scope It;
        }

        It 'Creates a fixed disk when "Type" is defined (#99)' {
            $testVhdPath = "TestDrive:\TestImage.vhdx";
            $testDiskNumber = 10;
            $newDiskImageParams = @{ Path = (New-Item -Path $testVhdPath -Force -ItemType File); PartitionStyle = 'GPT'; Force = $true; }
            Mock Dismount-VHD -MockWith { }
            Mock Mount-VHD -MockWith { return [PSCustomObject] @{ DiskNumber = $testDiskNumber; } }
            Mock New-DiskImageGpt -MockWith { }
            Mock Remove-Item -MockWith { };
            Mock Initialize-Disk -ParameterFilter { $Number -eq $testDiskNumber } -MockWith { }
            Mock New-Vhd -ParameterFilter { $Path -eq $newDiskImageParams.Path } -MockWith { }
            Mock Get-ItemProperty -MockWith { [PSCustomObject] @{ FDVDenyWriteAccess = 0 } } -ParameterFilter {$Name -eq 'FDVDenyWriteAccess'}

            New-DiskImage @newDiskImageParams -Type 'Fixed'

            Assert-MockCalled New-Vhd -ParameterFilter { $PSBoundParameters.ContainsKey('Fixed') -eq $true } -Scope It;
        }

        It 'Creates a custom size disk when "Size" is defined (#99)' {
            $testDiskSize = 80GB;
            $testVhdPath = "TestDrive:\TestImage.vhdx";
            $testDiskNumber = 10;
            $newDiskImageParams = @{ Path = (New-Item -Path $testVhdPath -Force -ItemType File); PartitionStyle = 'GPT'; Force = $true; }
            Mock Dismount-VHD -MockWith { }
            Mock Mount-VHD -MockWith { return [PSCustomObject] @{ DiskNumber = $testDiskNumber; } }
            Mock New-DiskImageGpt -MockWith { }
            Mock Remove-Item -MockWith { };
            Mock Initialize-Disk -ParameterFilter { $Number -eq $testDiskNumber } -MockWith { }
            Mock New-Vhd -ParameterFilter { $Path -eq $newDiskImageParams.Path } -MockWith { }
            Mock Get-ItemProperty -MockWith { [PSCustomObject] @{ FDVDenyWriteAccess = 0 } } -ParameterFilter {$Name -eq 'FDVDenyWriteAccess'}

            New-DiskImage @newDiskImageParams -Size $testDiskSize;

            Assert-MockCalled New-Vhd -ParameterFilter { $SizeBytes -eq $testDiskSize } -Scope It;
        }

        It 'Disables BitLocker fixed drive write protection if enabled' {
            $testVhdPath = "TestDrive:\TestImage.vhdx";
            $testDiskNumber = 10;
            $newDiskImageParams = @{ Path = (New-Item -Path $testVhdPath -Force -ItemType File); PartitionStyle = 'GPT'; Force = $true; }
            Mock Dismount-VHD -MockWith { }
            Mock Mount-VHD -MockWith { return [PSCustomObject] @{ DiskNumber = $testDiskNumber; } }
            Mock New-DiskImageGpt -MockWith { }
            Mock Remove-Item -MockWith { };
            Mock Initialize-Disk -ParameterFilter { $Number -eq $testDiskNumber } -MockWith { }
            Mock New-Vhd -ParameterFilter { $Path -eq $newDiskImageParams.Path } -MockWith { }
            Mock Get-ItemProperty -MockWith { [PSCustomObject] @{ FDVDenyWriteAccess = 1 } } -ParameterFilter {$Name -eq 'FDVDenyWriteAccess'}
            Mock Set-ItemProperty -MockWith { } -ParameterFilter {$Name -eq 'FDVDenyWriteAccess'}

            New-DiskImage @newDiskImageParams

            Assert-MockCalled Set-ItemProperty -ParameterFilter {$Name -eq 'FDVDenyWriteAccess'} -Exactly 2 -Scope It
        }

    } #end InModuleScope
} #end Describe
