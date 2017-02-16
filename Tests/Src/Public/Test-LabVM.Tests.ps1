#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Public\Reset-Lab' {

    InModuleScope -ModuleName $moduleName {

        ## Guard mocks
        Mock Test-LabImage -MockWith { }
        Mock TestLabSwitch -MockWith { }
        Mock TestLabVMDisk -MockWith { }
        Mock TestLabVirtualMachine -MockWith { }

        It 'Returns a "System.Boolean" object type' {
                $testVM = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVM; }
                    )
                }
                Mock Test-LabImage -MockWith { return $true; }
                Mock TestLabSwitch -MockWith { return $true; }
                Mock TestLabVMDisk -MockWith { return $true; }
                Mock TestLabVirtualMachine -MockWith { return $true; }

                $vm = Test-LabVM -ConfigurationData $configurationData -Name $testVM;

                $vm -is [System.Boolean] | Should Be $true;
            }

            It 'Returns a result for each VM when "Name" is not specified' {
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = 'VM1'; }
                        @{ NodeName = 'VM2'; }
                    )
                }
                Mock Test-LabImage -MockWith { return $true; }
                Mock TestLabSwitch -MockWith { return $true; }
                Mock TestLabVMDisk -MockWith { return $true; }
                Mock TestLabVirtualMachine -MockWith { return $false; }

                $vms = Test-LabVM -ConfigurationData $configurationData;
                $vms.Count | Should Be $configurationData.AllNodes.Count;
            }

            It 'Passes when VM is configured correctly' {
                $testVM = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVM; }
                    )
                }
                Mock TestLabVirtualMachine -MockWith { return $true; }

                Test-LabVM -ConfigurationData $configurationData -Name $testVM | Should Be $true;
            }

            It 'Fails when image is invalid' {
                $testVM = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVM; }
                    )
                }
                Mock Test-LabImage -MockWith { return $false; }
                Mock TestLabSwitch -MockWith { return $true; }
                Mock TestLabVMDisk -MockWith { return $true; }
                Mock TestLabVirtualMachine -MockWith { return $true; }

                Test-LabVM -ConfigurationData $configurationData -Name $testVM | Should Be $false;
            }

            It 'Fails when switch configuration is incorrect' {
                $testVM = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVM; }
                    )
                }
                Mock Test-LabImage -MockWith { return $true; }
                Mock TestLabSwitch -MockWith { return $false; }
                Mock TestLabVMDisk -MockWith { return $true; }
                Mock TestLabVirtualMachine -MockWith { return $true; }

                Test-LabVM -ConfigurationData $configurationData -Name $testVM | Should Be $false;
            }

            It 'Fails when VM disk configuration is invalid' {
                $testVM = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVM; }
                    )
                }
                Mock Test-LabImage -MockWith { return $true; }
                Mock TestLabSwitch -MockWith { return $true; }
                Mock TestLabVMDisk -MockWith { return $false; }
                Mock TestLabVirtualMachine -MockWith { return $true; }

                Test-LabVM -ConfigurationData $configurationData -Name $testVM | Should Be $false;
            }

            It 'Fails when VM configuration is incorrect' {
                $testVM = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVM; }
                    )
                }
                Mock Test-LabImage -MockWith { return $true; }
                Mock TestLabSwitch -MockWith { return $true; }
                Mock TestLabVMDisk -MockWith { return $true; }
                Mock TestLabVirtualMachine -MockWith { return $false; }

                Test-LabVM -ConfigurationData $configurationData -Name $testVM | Should Be $false;
            }

            It 'Calls "Test-LabImage" and "TestLabVMDisk" with "ConfigurationData" (#97)' {
                $testVM = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVM; }
                    )
                }
                Mock TestLabSwitch -MockWith { return $true; }
                Mock TestLabVMDisk -ParameterFilter { $null -ne $ConfigurationData } -MockWith { return $true; }
                Mock TestLabVirtualMachine -MockWith { return $true; }
                Mock Test-LabImage -ParameterFilter { $null -ne $ConfigurationData } -MockWith { return $true; }

                $vm = Test-LabVM -ConfigurationData $configurationData -Name $testVM;

                Assert-MockCalled Test-LabImage -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
                Assert-MockCalled TestLabVMDisk -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
            }

    } #end InModuleScope

} #end describe
