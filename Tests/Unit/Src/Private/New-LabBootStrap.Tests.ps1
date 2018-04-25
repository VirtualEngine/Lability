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

            $bootstrap -match "<#CustomBootStrapInjectionPoint#>`r?`n" | Should Be $true;
        }

        It 'Defaults "MaxEnvelopeSizeKb" size to 1024' {
            $bootstrap = New-LabBootStrap;

            $bootstrap -match 'WSMan:\\localhost\\MaxEnvelopeSizekb -Value 1024' | Should Be $true;
        }

        It 'Sets "MaxEnvelopeSizeKb" size to "2048" when specified' {
            $bootstrap = New-LabBootStrap -MaxEnvelopeSizeKb 2048;

            $bootstrap -match 'WSMan:\\localhost\\MaxEnvelopeSizekb -Value 2048' | Should Be $true;
        }

    } #end InModuleScope
} #end Describe
