#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\ConvertPSObjectToHashtable' {

    InModuleScope $moduleName {

        It 'Returns a "System.Collections.Hashtable" object' {
            $testObject = [PSCustomObject] @{ Property1 = 'Value1'; Property2 = 2; }

            $result = ConvertPSObjectToHashtable -InputObject $testObject;

            $result -is [System.Collections.Hashtable] | Should Be $true;
        }

        It 'Converts property value types correctly' {
            $testObject = [PSCustomObject] @{ Property1 = 'Value1'; Property2 = 2; }

            $result = ConvertPSObjectToHashtable -InputObject $testObject;

            $result.Property1 -is [System.String] | Should Be $true;
            $result.Property2 -is [System.Int32] | Should Be $true;
        }

        It 'Ignores "$null" values when specified' {
            $testObject = [PSCustomObject] @{ Property1 = 'Value1'; Property2 = 2; Property3 = $null; }

            $result = ConvertPSObjectToHashtable -InputObject $testObject -IgnoreNullValues;

            $result.ContainsKey('Property3') | Should Be $false;
        }

        It 'Converts nested "PSCustomObject" types to a hashtable' {
            $testNestedObject = [PSCustomObject] @{ SubProperty1 = 1; SubProperty2 = '2'}
            $testObject = [PSCustomObject] @{ Property1 = '1'; Property2 = 2; Property3 = $testNestedObject; }

            $result = ConvertPSObjectToHashtable -InputObject $testObject -IgnoreNullValues;

            $result.Property3 -is [System.Collections.Hashtable] | Should Be $true;
        }

    } #end InModuleScope
} #end Describe
