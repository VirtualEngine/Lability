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

        It 'Calls "InvokeModuleCacheDownload" with "Force" when specified' {
            Mock InvokeModuleCacheDownload -MockWith { }
            Mock ExpandModuleCache -MockWith { }

            Set-LabVMDiskModule -Module $testModules -DestinationPath ".\" -Force

            Assert-MockCalled InvokeModuleCacheDownload -ParameterFilter { $Force -eq $true } -Scope It;

        }

        It 'Calls "ExpandModuleCache" with "Clean" when specified' {
            Mock InvokeModuleCacheDownload -MockWith { }
            Mock ExpandModuleCache -MockWith { }

            Set-LabVMDiskModule -Module $testModules -DestinationPath ".\" -Clean

            Assert-MockCalled ExpandModuleCache -ParameterFilter { $Clean -eq $true } -Scope It;

        }

    } #end InModuleScope

} #end describe
