#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\WriteWarning' {

    InModuleScope $moduleName {

        It 'Calls "Get-FormattedMessage" method' {
            $testMessage = 'This is a test message';
            Mock Get-FormattedMessage -ParameterFilter { $Message -match $testMessage } -MockWith { return $testMessage; }

            WriteWarning -Message $testMessage -WarningAction SilentlyContinue;

            Assert-MockCalled Get-FormattedMessage -ParameterFilter { $Message -match $testMessage } -Scope It;
        }

        It 'Calls "WriteWarning" method with test message' {
            $testMessage = 'This is a test message';
            Mock 'Microsoft.PowerShell.Utility\Write-Warning' -ParameterFilter { $Message -match "$testMessage`$" } -MockWith { }

            WriteWarning -Message $testMessage;

            Assert-MockCalled 'Microsoft.PowerShell.Utility\Write-Warning' -ParameterFilter { $Message -match $testMessage } -Scope It;
        }

    } #end InModuleScope
} #end Describe
