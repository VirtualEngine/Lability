#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Invoke-Executable' {

    InModuleScope $moduleName {

        It 'Calls "Start-Process" with correct process path' {
            $testProcess = 'Test.exe';
            $testArguments = @('/Arg1','-Arg2');
            $testExitCode = 0;
            Mock Start-Process -ParameterFilter { $FilePath -eq $testProcess } -MockWith { return [PSCustomObject] @{ ExitCode = $testExitCode; } }

            Invoke-Executable -Path 'Test.exe' -Arguments $testArguments;

            Assert-MockCalled Start-Process -ParameterFilter { $FilePath -eq $testProcess } -Scope It;
        }

        It 'Calls "Start-Process" with correct arguments' {
            $testProcess = 'Test.exe';
            $testArguments = @('/Arg1','-Arg2');
            $testExitCode = 0;
            Mock Start-Process -ParameterFilter { $ArgumentList.Count -eq 2 } -MockWith { return [PSCustomObject] @{ ExitCode = $testExitCode; } }

            Invoke-Executable -Path 'Test.exe' -Arguments $testArguments;

            Assert-MockCalled Start-Process -ParameterFilter { $ArgumentList.Count -eq 2 } -Scope It;
        }

        It 'Waits for "Start-Process" to exit' {
            $testProcess = 'Test.exe';
            $testArguments = @('/Arg1','-Arg2');
            $testExitCode = 0;
            Mock Start-Process -ParameterFilter { $Wait -eq $true } -MockWith { return [PSCustomObject] @{ ExitCode = $testExitCode; } }

            Invoke-Executable -Path 'Test.exe' -Arguments $testArguments;

            Assert-MockCalled Start-Process -ParameterFilter { $Wait -eq $true } -Scope It;
        }

        It 'Warns when process exits with non-zero exit code' {
            $testProcess = 'Test.exe';
            $testArguments = @('/Arg1','-Arg2');
            $testExitCode = 1;
            Mock Start-Process -ParameterFilter { $Path -eq $testProcess } -MockWith { return [PSCustomObject] @{ ExitCode = $testExitCode; } }

            { Invoke-Executable -Path 'Test.exe' -Arguments $testArguments -WarningAction Stop 3>&1 } | Should Throw;
        }

    } #end InModuleScope
} #end Describe
