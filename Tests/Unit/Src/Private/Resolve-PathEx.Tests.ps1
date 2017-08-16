#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Resolve-PathEx' {

    InModuleScope $moduleName {

        It 'Resolves existing home path' {
            (Get-PSProvider -PSProvider 'FileSystem').Home = (Get-PSDrive -Name TestDrive).Root;
            $fileSystemPath = (Get-PSProvider -PSProvider 'FileSystem').Home;
            $psPath = '~';

            Resolve-PathEx -Path $psPath | Should Be $fileSystemPath;
        }

        It 'Resolves non-existent home path' {
            (Get-PSProvider -PSProvider 'FileSystem').Home = (Get-PSDrive -Name TestDrive).Root;
            $fileSystemPath = '{0}\HopefullyThisPathDoesNotExist' -f (Get-PSProvider -PSProvider 'FileSystem').Home;
            $psPath = '~\HopefullyThisPathDoesNotExist';

            Resolve-PathEx -Path $psPath | Should Be $fileSystemPath;
        }

    } #end InModuleScope

} #end describe
