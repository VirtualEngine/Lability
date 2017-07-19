#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Set-LabVMDiskFileResource' {

    InModuleScope $moduleName {

        It 'Calls "Expand-LabResource" using "ResourceShare" path' {
            $testNode = 'TestNode';
            $testConfigurationData = @{}
            $testDriveLetter = 'Z';
            $testResourceShare = 'TestResourceShare';
            $testHostConfiguration = [PSCustomObject] @{
                ResourceShareName = $testResourceShare;
            }
            Mock Get-ConfigurationData -MockWith { return $testHostConfiguration; }
            Mock Expand-LabResource -MockWith { }

            $testParams = @{
                ConfigurationData = $testConfigurationData;
                NodeName = $testNode;
                VhdDriveLetter = $testDriveLetter;
            }
            Set-LabVMDiskFileResource @testParams;

            $expectedDestinationPath = '{0}:\{1}' -f $testDriveLetter, $testResourceShare;
            Assert-MockCalled Expand-LabResource -ParameterFilter { $DestinationPath -eq $expectedDestinationPath } -Scope It
        }

    } #end InModuleScope

} #end describe
