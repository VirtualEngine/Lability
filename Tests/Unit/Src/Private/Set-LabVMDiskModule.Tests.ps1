#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Set-LabVMDiskModule' {

    InModuleScope $moduleName {

        $testModules = @(
            @{ Name = 'PowerShellModule'; }
            @{ Name = 'DscResourceModule'; }
        )

        It 'Calls "Invoke-LabModuleCacheDownload" with "Force" when specified' {
            Mock Invoke-LabModuleCacheDownload -MockWith { }
            Mock Expand-LabModuleCache -MockWith { }

            Set-LabVMDiskModule -Module $testModules -DestinationPath ".\" -Force

            Assert-MockCalled Invoke-LabModuleCacheDownload -ParameterFilter { $Force -eq $true } -Scope It;

        }

        It 'Calls "Expand-LabModuleCache" with "Clean" when specified' {
            Mock Invoke-LabModuleCacheDownload -MockWith { }
            Mock Expand-LabModuleCache -MockWith { }

            Set-LabVMDiskModule -Module $testModules -DestinationPath ".\" -Clean

            Assert-MockCalled Expand-LabModuleCache -ParameterFilter { $Clean -eq $true } -Scope It;

        }

    } #end InModuleScope

} #end describe
