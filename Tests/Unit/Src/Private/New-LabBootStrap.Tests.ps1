#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\New-LabBootStrap' {

    InModuleScope $moduleName {

        It 'Returns a "System.String" type' {
            $bootstrap = New-LabBootStrap;

            $bootstrap -is [System.String] | Should Be $true;
        }

        It 'Includes custom BootStrap injection point' {
            $bootstrap = New-LabBootStrap;

            $bootstrap.ToString() -match "<#CustomBootStrapInjectionPoint#>`r`n" | Should Be $true;
        }

    } #end InModuleScope
} #end Describe
