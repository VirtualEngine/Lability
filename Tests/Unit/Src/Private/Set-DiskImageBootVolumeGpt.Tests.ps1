#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Set-DiskImageBootVolumeGpt' {

    InModuleScope $moduleName {

        It 'Calls "BCDBOOT.EXE" with "/f UEFI"' {
            $testVhdPath = (New-Item -Path 'TestDrive:\TestImage.vhdx' -Force -ItemType File).FullName;
            $testVhdImage = @{ Path = $testVhdPath };
            Mock Get-DiskImageDriveLetter -MockWith { return 'Z'; }
            Mock Invoke-Executable -MockWith { }
            Mock Invoke-Executable -ParameterFilter { $Path -eq 'BCDBOOT.EXE' -and $Arguments -contains '/f UEFI' } -MockWith { }

            Set-DiskImageBootVolumeGpt -Vhd $testVhdImage;

            Assert-MockCalled Invoke-Executable -ParameterFilter { $Path -eq 'BCDBOOT.EXE' -and $Arguments -contains '/f UEFI' } -Scope It -Exactly 1;
        }

    } #end InModuleScope
} #end Describe
