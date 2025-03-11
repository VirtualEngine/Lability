#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Public\Get-LabMedia' {

    InModuleScope -ModuleName $moduleName {

        It 'Returns all built-in media when no "Id" is specified' {
            $labMedia = Get-LabMedia;

            $labMedia.Count -gt 1 | Should Be $true;
        }

        It 'Returns a single matching built-in media when "Id" is specified' {
            $testMediaId = '2016_x64_Datacenter_EN_Eval';
            $labMedia = Get-LabMedia -Id $testMediaId;

            $labMedia | Should Not BeNullOrEmpty;
            $labMedia.Count | Should BeNullOrEmpty;
        }

        It 'Returns null if no built-in media is found when "Id" is specified' {
            $labMedia = Get-LabMedia -Id 'NonExistentMediaId';

            $labMedia | Should BeNullOrEmpty;
        }

    } #end InModuleScope

} #end describe
