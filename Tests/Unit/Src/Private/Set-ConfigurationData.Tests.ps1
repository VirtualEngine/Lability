#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Set-ConfigurationData' {

    InModuleScope $moduleName {

        It 'Resolves environment variables in path' {
        ##        $testConfigurationFilename = 'TestConfiguration.json';
        ##        $fakeConfiguration = '{ "ConfigurationPath": "%SYSTEMDRIVE%\\TestLab\\Configurations" }' | ConvertFrom-Json;
        ##        Mock Resolve-ConfigurationDataPath -MockWith { return ('%SYSTEMROOT%\{0}' -f $testConfigurationFilename); }
        ##        Mock NewDirectory -MockWith { }
        ##        Mock Set-Content -ParameterFilter { $Path -eq "$env:SystemRoot\$testConfigurationFilename" } -MockWith { return $fakeConfiguration; }
        ##
        ##        Set-ConfigurationData -Configuration Host -InputObject $fakeConfiguration;
        ##
        ##        Assert-MockCalled Set-Content -ParameterFilter { $Path -eq "$env:SystemRoot\$testConfigurationFilename" } -Scope It;
            }

    } #end InModuleScope

} #end Describe
