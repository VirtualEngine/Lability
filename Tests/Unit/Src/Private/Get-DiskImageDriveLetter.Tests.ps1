#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Get-DiskImageDriveLetter' {

    InModuleScope $moduleName {

        It 'Throws when no disk letter is found' {
            Mock Get-Partition -MockWith { return [PSCustomObject] @{ DriveLetter = $null; Type = 'Basic'; DiskNumber = 1; } }
            $diskImage = [PSCustomObject] @{ DiskNumber = 1 };

            { Get-DiskImageDriveLetter -DiskImage $diskImage -PartitionType Basic } | Should Throw;
        }

        It 'Throws when no disk letter is found for specified partition type' {
            Mock Get-Partition -MockWith { return [PSCustomObject] @{ DriveLetter = 'Z'; Type = 'IFS'; DiskNumber = 1; } }
            $diskImage = [PSCustomObject] @{ DiskNumber = 1 };

            { Get-DiskImageDriveLetter -DiskImage $diskImage -PartitionType Basic } | Should Throw;
        }

        It 'Returns a single character' {
            Mock Get-Partition -MockWith { return [PSCustomObject] @{ DriveLetter = 'Z'; Type = 'IFS'; DiskNumber = 1; } }
            $diskImage = [PSCustomObject] @{ DiskNumber = 1 };

            (Get-DiskImageDriveLetter -DiskImage $diskImage -PartitionType IFS).Length | Should Be 1;
        }

    } #end InModuleScope
} #end Describe
