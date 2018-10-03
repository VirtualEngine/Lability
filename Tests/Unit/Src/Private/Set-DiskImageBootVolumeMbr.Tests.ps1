#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Set-DiskImageBootVolumeMbr' {

    InModuleScope $moduleName {

        It 'Calls "BCDBOOT.EXE" with "/f BIOS"' {
            $testVhdPath = (New-Item -Path 'TestDrive:\TestImage.vhdx' -Force -ItemType File).FullName;
            $testVhdImage = @{ Path = $testVhdPath };
            Mock Get-DiskImageDriveLetter -MockWith { return 'Z'; }
            Mock Invoke-Executable -MockWith { }
            Mock Invoke-Executable -ParameterFilter { $Path -eq 'BCDBOOT.EXE' -and $Arguments -contains '/f BIOS' } -MockWith { }

            Set-DiskImageBootVolumeMbr -Vhd $testVhdImage;

            Assert-MockCalled Invoke-Executable -ParameterFilter { $Path -eq 'BCDBOOT.EXE' -and $Arguments -contains '/f BIOS' } -Scope It -Exactly 1;
        }

        It 'Calls "BCDEDIT.EXE" thrice' {
            $testVhdPath = (New-Item -Path 'TestDrive:\TestImage.vhdx' -Force -ItemType File).FullName;
            $testVhdImage = @{ Path = $testVhdPath };
            Mock Get-DiskImageDriveLetter -MockWith { return 'Z'; }
            Mock Invoke-Executable -MockWith { }
            Mock Invoke-Executable -ParameterFilter { $Path -eq 'BCDEDIT.EXE' } -MockWith { }

            Set-DiskImageBootVolumeMbr -Vhd $testVhdImage;

            Assert-MockCalled Invoke-Executable -ParameterFilter { $Path -eq 'BCDEDIT.EXE' } -Scope It -Exactly 3;
        }

    } #end InModuleScope
} #end Describe
