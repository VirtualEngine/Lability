#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Set-UnattendXml' {

    InModuleScope $moduleName {

        It 'Saves Xml file to disk' {
            $testPassword = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);
            $testTimezone = 'GMT Standard Time';
            $testPath = "$((Get-PSDrive -Name TestDrive).Root)\test.xml";

            Set-UnattendXml -Path $testPath -Credential $testPassword -Timezone $testTimezone;

            Test-Path -Path $testPath | Should Be $true;
        }

    } #end InModuleScope
} #end Describe
