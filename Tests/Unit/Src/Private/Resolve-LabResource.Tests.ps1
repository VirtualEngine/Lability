#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Resolve-LabResource' {

    InModuleScope $moduleName {

        It 'Returns resource record if "ResourceId" is found' {
            $configurationData = @{
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Resource = @(
                            @{ Id = 'Resource1.exe'; Uri = 'http://test-resource.com/resource1.exe'; }
                        ) } } }
            $resource = Resolve-LabResource -ConfigurationData $configurationData -ResourceId 'Resource1.exe';
            $resource | Should Not BeNullOrEmpty;
        }

        It 'Throws if "ResourceId" is not found' {
            $configurationData = @{
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Resource = @(
                            @{ Id = 'Resource1.exe'; Uri = 'http://test-resource.com/resource1.exe'; }
                        ) } } }
            { Resolve-LabResource -ConfigurationData $configurationData -ResourceId 'Resource2.iso' } | Should Throw;
        }

    } #end InModuleScope

} #end describe
