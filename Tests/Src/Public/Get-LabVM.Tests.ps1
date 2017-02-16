#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Public\Reset-Lab' {

    InModuleScope -ModuleName $moduleName {

        ## Guard mocks
        Mock ImportDscResource -MockWith { }
        Mock GetDscResource -MockWith { return @{ Name = $Parameters.Name; } }

        It 'Returns a "System.Management.Automation.PSCustomObject" object type' {
            $testVM = 'VM2';
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = 'VM1'; }
                    @{ NodeName = $testVM; }
                )
            }

            $vm = Get-LabVM -ConfigurationData $configurationData -Name $testVM;

            $vm -is [System.Management.Automation.PSCustomObject] | Should Be $true;
        }

        It 'Returns specific node when "Name" is specified' {
            $testVM = 'VM2';
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = 'VM1'; }
                    @{ NodeName = $testVM; }
                )
            }

            $vm = Get-LabVM -ConfigurationData $configurationData -Name $testVM;

            $vm.Count | Should BeNullOrEmpty;
            $vm | Should Not BeNullOrEmpty;
        }

        It 'Returns all nodes when "Name" is not specified' {
            $testVM = 'VM2';
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = 'VM1'; }
                    @{ NodeName = $testVM; }
                )
            }

            $vms = Get-LabVM -ConfigurationData $configurationData;

            $vms.Count | Should Be $configurationData.AllNodes.Count;
        }

        It 'Errors when node cannot be found' {
            $testVM = 'VM2';
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = 'VM1'; }
                    @{ NodeName = $testVM; }
                )
            }
            Mock GetDscResource -MockWith { throw; }

            { Get-LabVM -ConfigurationData $configurationData -Name $testVM -ErrorAction Stop } | Should Throw;
        }

    } #end InModuleScope

} #end describe
