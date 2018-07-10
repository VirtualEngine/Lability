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

            $bootstrap -match '-Name maxEnvelopeSize -Value 1024 -Force' | Should Be $true;
        }

        It 'Sets "MaxEnvelopeSizeKb" size to "2048" when specified' {
            $bootstrap = New-LabBootStrap -MaxEnvelopeSizeKb 2048;

            $bootstrap -match '-Name maxEnvelopeSize -Value 2048 -Force' | Should Be $true;
        }

    } #end InModuleScope
} #end Describe
