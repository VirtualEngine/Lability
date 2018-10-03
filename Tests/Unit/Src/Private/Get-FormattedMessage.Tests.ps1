#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Get-FormattedMessage' {

    InModuleScope $moduleName {

        It 'Does not return call stack information when "$labDefaults.CallStackLogging" = "$null"' {
            $labDefaults = @{ }
            $testMessage = 'This is a test message';

            $message = Get-FormattedMessage -Message $testMessage;

            $message -match '\] \[' | Should Be $false;
        }

        It 'Does not return call stack information when "$labDefaults.CallStackLogging" = "$false"' {
            $labDefaults = @{ CallStackLogging = $false; }
            $testMessage = 'This is a test message';

            $message = Get-FormattedMessage -Message $testMessage;

            $message -match '\] \[' | Should Be $false;
        }

        It 'Returns call stack information when "$labDefaults.CallStackLogging" = "$true"' {
            $labDefaults = @{ CallStackLogging = $true; }
            $testMessage = 'This is a test message';

            $message = Get-FormattedMessage -Message $testMessage;

            $message -match '\] \[' | Should Be $true;
        }

    } #end InModuleScope
} #end Describe
