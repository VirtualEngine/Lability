#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Public\Remove-LabConfiguration' {

    InModuleScope -ModuleName $moduleName {

        ## Guard mocks
        Mock Remove-LabVirtualMachine -MockWith { }

        It 'Calls "Remove-LabVirtualMachine" for each node' {
            $configurationData = @{ AllNodes = @( @{ NodeName = 'VM1'; }, @{ NodeName = 'VM2'; } ) }

            Remove-LabConfiguration -ConfigurationData $configurationData -Confirm:$false;

            Assert-MockCalled Remove-LabVirtualMachine -Exactly $configurationData.AllNodes.Count -Scope It;
        }

    } #end InModuleScope

} #end describe

