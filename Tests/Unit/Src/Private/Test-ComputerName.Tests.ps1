#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Test-ComputerName' {

    InModuleScope $moduleName {

        $baseComputerName = 'TestComputer-1';

        It "Passes when computer name does not contain invalid characters" {
            Test-ComputerName -ComputerName $baseComputerName | Should Be $true;
        }

        $invalidChars = @('~','!','@','#','$','%','^','&','*','(',')','=','+','_','[',']',
                            '{','}','\','|',';',':','.',"'",'"',',','<','>','/','?',' ');

        foreach ($invalidChar in $invalidChars) {

            It "Fails when computer name contains invalid '$invalidChar' character" {
                $testComputerName = '{0}{1}' -f $baseComputerName, $invalidChar;
                Test-ComputerName -ComputerName $testComputerName | Should Be $false;
            }

        } #end foreach invalid character

    } #end InModuleScope
} #end Describe
