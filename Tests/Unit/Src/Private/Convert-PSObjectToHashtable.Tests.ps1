#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Convert-PSObjectToHashtable' {

    InModuleScope $moduleName {

        It 'Returns a "System.Collections.Hashtable" object' {
            $testObject = [PSCustomObject] @{ Property1 = 'Value1'; Property2 = 2; }

            $result = Convert-PSObjectToHashtable -InputObject $testObject;

            $result -is [System.Collections.Hashtable] | Should Be $true;
        }

        It 'Converts property value types correctly' {
            $testObject = [PSCustomObject] @{ Property1 = 'Value1'; Property2 = 2; }

            $result = Convert-PSObjectToHashtable -InputObject $testObject;

            $result.Property1 -is [System.String] | Should Be $true;
            $result.Property2 -is [System.Int32] | Should Be $true;
        }

        It 'Ignores "$null" values when specified' {
            $testObject = [PSCustomObject] @{ Property1 = 'Value1'; Property2 = 2; Property3 = $null; }

            $result = Convert-PSObjectToHashtable -InputObject $testObject -IgnoreNullValues;

            $result.ContainsKey('Property3') | Should Be $false;
        }

        It 'Converts nested "PSCustomObject" types to a hashtable' {
            $testNestedObject = [PSCustomObject] @{ SubProperty1 = 1; SubProperty2 = '2'}
            $testObject = [PSCustomObject] @{ Property1 = '1'; Property2 = 2; Property3 = $testNestedObject; }

            $result = Convert-PSObjectToHashtable -InputObject $testObject -IgnoreNullValues;

            $result.Property3 -is [System.Collections.Hashtable] | Should Be $true;
        }

        It 'Converts nested array "PSCustomObject" types to hashtables (#262)' {
            $testObject = [PSCustomObject] @{
                Hotfixes = @(
                    [PSCustomObject] @{ Id = 'Id1'; Uri = 'Uri1'; }
                    [PSCustomObject] @{ Id = 'Id2'; Uri = 'Uri2'; }
                )
            }

            $result = Convert-PSObjectToHashtable -InputObject $testObject -IgnoreNullValues -Verbose;

            $result.Hotfixes[-1] -is [System.Collections.Hashtable] | Should Be $true;
        }

        It 'Converts nested array of "String" types to an array' {
            $testObject = [PSCustomObject] @{
                WindowsOptionalFeature = @('NetFx3');
            }

            $result = Convert-PSObjectToHashtable -InputObject $testObject -IgnoreNullValues -Verbose;

            $result.WindowsOptionalFeature[-1] -is [System.String] | Should Be $true;
        }

    } #end InModuleScope
} #end Describe
