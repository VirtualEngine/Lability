#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\New-Directory' {

    InModuleScope -ModuleName $moduleName {

        ## Need to resolve actual filesystem path for System.IO.DirectoryInfo calls
        $testDirectoryPath = "$((Get-PSdrive -Name TestDrive).Root)\New-Directory";

        It 'Returns a "System.IO.DirectoryInfo" object if target "Path" already exists' {
            Remove-Item -Path 'TestDrive:\New-Directory' -Force -ErrorAction SilentlyContinue;
            $testDirectoryPath = "$env:SystemRoot";
            Test-Path -Path $testDirectoryPath | Should Be $true;
            (New-Directory -Path $testDirectoryPath) -is [System.IO.DirectoryInfo] | Should Be $true;
        }

        It 'Returns a "System.IO.DirectoryInfo" object if target "Path" does not exist' {
            Remove-Item -Path 'TestDrive:\New-Directory' -Force -ErrorAction SilentlyContinue;
            (New-Directory -Path $testDirectoryPath) -is [System.IO.DirectoryInfo] | Should Be $true;
        }

        It 'Creates target "Path" if it does not exist' {
            Remove-Item -Path 'TestDrive:\New-Directory' -Force -ErrorAction SilentlyContinue;
            Test-Path -Path $testDirectoryPath | Should Be $false;
            New-Directory -Path $testDirectoryPath;
            Test-Path -Path $testDirectoryPath | Should Be $true;
        }

        It 'Returns a "System.IO.DirectoryInfo" object if target "DirectoryInfo" already exists' {
            Remove-Item -Path 'TestDrive:\New-Directory' -Force -ErrorAction SilentlyContinue;
            $testDirectoryPath = "$env:SystemRoot";
            Test-Path -Path $testDirectoryPath | Should Be $true;
            $directoryInfo = New-Object -TypeName System.IO.DirectoryInfo -ArgumentList $testDirectoryPath;
            ($directoryInfo | New-Directory ) -is [System.IO.DirectoryInfo] | Should Be $true;
        }

        It 'Returns a "System.IO.DirectoryInfo" object if target "DirectoryInfo" does not exist' {
            Remove-Item -Path 'TestDrive:\New-Directory' -Force -ErrorAction SilentlyContinue;
            Test-Path -Path $testDirectoryPath | Should Be $false;
            $output = New-Directory -Path $testDirectoryPath;
            Test-Path -Path $testDirectoryPath | Should Be $true;
            $output -is [System.IO.DirectoryInfo] | Should Be $true;
        }

        It 'Creates target "DirectoryInfo" if it does not exist' {
            Remove-Item -Path 'TestDrive:\New-Directory' -Force -ErrorAction SilentlyContinue;
            Test-Path -Path $testDirectoryPath | Should Be $false;
            $directoryInfo = New-Object -TypeName System.IO.DirectoryInfo -ArgumentList $testDirectoryPath;
            $directoryInfo | New-Directory;
            Test-Path -Path $testDirectoryPath | Should Be $true;
        }

    } #end InModuleScope

} #end describe
