#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Expand-LabIso' {

    InModuleScope $moduleName {

        It 'Mounts ISO image read-only' {
            $testIsoPath = 'TestDrive:\TestIsoImage.iso';
            $testDestinationPath = 'Y:\';
            $testIsoMountDrive = 'Z';
            $fakeDiskImage = [PSCustomObject] @{ DriveLetter = $testIsoMountDrive; ImagePath = $testIsoPath };
            Mock Get-Volume -MockWith { return [PSCustomObject] @{ DriveLetter = $testIsoMountDrive } }
            Mock CopyDirectory -MockWith { }
            Mock Dismount-DiskImage -MockWith { }
            Mock Mount-DiskImage -ParameterFilter { $ImagePath -eq $testIsoPath -and $Access -eq 'ReadOnly' } -MockWith { return $fakeDiskImage; }
            Mock Get-ItemProperty -MockWith { [PSCustomObject] @{ FDVDenyWriteAccess = 0 } } -ParameterFilter {$Name -eq 'FDVDenyWriteAccess'}

            Expand-LabIso -Path $testIsoPath -DestinationPath $testDestinationPath;

            Assert-MockCalled Mount-DiskImage -ParameterFilter { $ImagePath -eq $testIsoPath -and $Access -eq 'ReadOnly' } -Scope It;
        }

        It 'Copies ISO image contents to destination path recursively' {
            $testIsoPath = 'TestDrive:\TestIsoImage.iso';
            $testDestinationPath = 'Y:\';
            $testIsoMountDrive = 'Z';
            $fakeDiskImage = [PSCustomObject] @{ DriveLetter = $testIsoMountDrive; ImagePath = $testIsoPath };
            Mock Mount-DiskImage -MockWith { return $fakeDiskImage; }
            Mock Get-Volume -MockWith { return [PSCustomObject] @{ DriveLetter = $testIsoMountDrive } }
            Mock Dismount-DiskImage -MockWith { }
            Mock CopyDirectory -ParameterFilter { $DestinationPath.FullName -eq $testDestinationPath } -MockWith { }
            Mock Get-ItemProperty -MockWith { [PSCustomObject] @{ FDVDenyWriteAccess = 0 } } -ParameterFilter {$Name -eq 'FDVDenyWriteAccess'}

            Expand-LabIso -Path $testIsoPath -DestinationPath $testDestinationPath;

            Assert-MockCalled CopyDirectory -ParameterFilter { $DestinationPath.FullName -eq $testDestinationPath } -Scope It;
        }

        It 'Disounts ISO image' {
            $testIsoPath = 'TestDrive:\TestIsoImage.iso';
            $testDestinationPath = 'Y:\';
            $testIsoMountDrive = 'Z';
            $fakeDiskImage = [PSCustomObject] @{ DriveLetter = $testIsoMountDrive; ImagePath = $testIsoPath };
            Mock Mount-DiskImage -MockWith { return $fakeDiskImage; }
            Mock Get-Volume -MockWith { return [PSCustomObject] @{ DriveLetter = $testIsoMountDrive } }
            Mock CopyDirectory -MockWith { }
            Mock Dismount-DiskImage -ParameterFilter { $ImagePath -eq $testIsoPath } -MockWith { }
            Mock Get-ItemProperty -MockWith { [PSCustomObject] @{ FDVDenyWriteAccess = 0 } } -ParameterFilter {$Name -eq 'FDVDenyWriteAccess'}

            Expand-LabIso -Path $testIsoPath -DestinationPath $testDestinationPath;

            Assert-MockCalled Dismount-DiskImage -ParameterFilter { $ImagePath -eq $testIsoPath } -Scope It;
        }

        It 'Disables/enables BitLocker fixed drive write protection (if required)' {
            $testIsoPath = 'TestDrive:\TestIsoImage.iso';
            $testDestinationPath = 'Y:\';
            $testIsoMountDrive = 'Z';
            $fakeDiskImage = [PSCustomObject] @{ DriveLetter = $testIsoMountDrive; ImagePath = $testIsoPath };
            Mock Get-Volume -MockWith { return [PSCustomObject] @{ DriveLetter = $testIsoMountDrive } }
            Mock CopyDirectory -MockWith { }
            Mock Dismount-DiskImage -MockWith { }
            Mock Mount-DiskImage -ParameterFilter { $ImagePath -eq $testIsoPath -and $Access -eq 'ReadOnly' } -MockWith { return $fakeDiskImage; }
            Mock Disable-BitLockerFDV -MockWith { }
            Mock Assert-BitLockerFDV -MockWith { }

            Expand-LabIso -Path $testIsoPath -DestinationPath $testDestinationPath;

            Assert-MockCalled Disable-BitLockerFDV -Exactly 1 -Scope It
            Assert-MockCalled Assert-BitLockerFDV -Exactly 1 -Scope It
        }

    } #end InModuleScope

} #end describe
