#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Disable-BitLockerFDV' {

    InModuleScope $moduleName {

        Mock Set-ItemProperty { }

        It "Calls 'Set-ItemProperty' when BitLocker is enabled on the system" {
            $fdvDenyWriteAccess = $true;
            Disable-BitLockerFDV;

            Assert-MockCalled Set-ItemProperty -Scope It -Times 1
        }

        It "It does not call 'Set-ItemProperty' when BitLocker is not enabled on the system" {
            $fdvDenyWriteAccess = $false;
            Disable-BitLockerFDV;

            Assert-MockCalled Set-ItemProperty -Scope It -Times 0
        }

    } #end InModuleScope
} #end Describe
