#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Get-LabHostSetupConfiguration' {

    InModuleScope -ModuleName $moduleName {

        It 'Installs "Microsoft-Hyper-V-All" feature with "WindowsOptionalFeature" on a desktop OS' {
            Mock Get-CimInstance -ParameterFilter { $ClassName -eq 'Win32_OperatingSystem' } -MockWith { return [PSCustomObject] @{ ProductType = 1; } }

            $windowsOptionalFeature = Get-LabHostSetupConfiguration | Where-Object { $_.Parameters['Name'] -eq 'Microsoft-Hyper-V-All' }

            $windowsOptionalFeature | Should Not BeNullOrEmpty;
        }

        It 'Installs "Hyper-V" feature using "WindowsFeature" on a server OS' {
            Mock Get-CimInstance -ParameterFilter { $ClassName -eq 'Win32_OperatingSystem' } -MockWith { return [PSCustomObject] @{ ProductType = 2; } }

            $windowsFeature = Get-LabHostSetupConfiguration | Where-Object { $_.Parameters['Name'] -eq 'Hyper-V' }

            $windowsFeature | Should Not BeNullOrEmpty;
        }

        It 'Installs "RSAT-Hyper-V-Tools" feature using "WindowsFeature" on a server OS' {
            Mock Get-CimInstance -ParameterFilter { $ClassName -eq 'Win32_OperatingSystem' } -MockWith { return [PSCustomObject] @{ ProductType = 2; } }

            $windowsFeature = Get-LabHostSetupConfiguration | Where-Object { $_.Parameters['Name'] -eq 'RSAT-Hyper-V-Tools' }

            $windowsFeature | Should Not BeNullOrEmpty;
        }

        It 'Checks for a pending reboot' {
            $pendingReboot = Get-LabHostSetupConfiguration | Where-Object { $_.ModuleName -eq 'xPendingReboot' -and $_.ResourceName -eq 'MSFT_xPendingReboot' }

            $pendingReboot | Should Not BeNullOrEmpty;
        }

    } #end InModuleScope

} #end describe
