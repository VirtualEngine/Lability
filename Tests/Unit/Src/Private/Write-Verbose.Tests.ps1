#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Write-Verbose' {

    InModuleScope $moduleName {

        It 'Calls "Get-FormattedMessage" method' {
            $testMessage = 'This is a test message';
            Mock Get-FormattedMessage -ParameterFilter { $Message -match $testMessage } -MockWith { return $testMessage; }

            Write-Verbose -Message $testMessage;

            Assert-MockCalled Get-FormattedMessage -ParameterFilter { $Message -match $testMessage } -Scope It;
        }

        It 'Calls "Write-Verbose" method with test message' {
            $testMessage = 'This is a test message';
            Mock 'Microsoft.PowerShell.Utility\Write-Verbose' -ParameterFilter { $Message -match "$testMessage`$" } -MockWith { }

            Write-Verbose -Message $testMessage;

            Assert-MockCalled 'Microsoft.PowerShell.Utility\Write-Verbose' -ParameterFilter { $Message -match $testMessage } -Scope It;
        }

    } #end InModuleScope
} #end Describe
