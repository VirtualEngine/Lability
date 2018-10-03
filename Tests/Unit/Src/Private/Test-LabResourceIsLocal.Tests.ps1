#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Invoke-LabResourceDownload' {

    InModuleScope $moduleName {

        $testResourceId = 'TestResource';

        It 'Returns "System.Boolean" object type' {
            $configurationData= @{
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Resource = @(
                            @{ Id = $testResourceId; }
                        )
                    }
                }
            }

            $result = Test-LabResourceIsLocal -ConfigurationData $configurationData -ResourceId $testResourceId -LocalResourcePath 'TestDrive:';

            $result -is [System.Boolean] | Should Be $true;
        }

        It 'Passes when local .EXE exists' {
            $testResourceFilename = "$testResourceId.exe";
            $configurationData= @{
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Resource = @(
                            @{ Id = $testResourceId; Filename = $testResourceFilename; }
                        )
                    }
                }
            }
            New-Item -Path "TestDrive:\$testResourceFilename" -ItemType File -Force;

            $result = Test-LabResourceIsLocal -ConfigurationData $configurationData -ResourceId $testResourceId -LocalResourcePath 'TestDrive:';

            $result | Should Be $true;
        }

        It 'Fails when local .EXE does not exist' {
            $testResourceFilename = "$testResourceId.exe";
            $configurationData= @{
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Resource = @(
                            @{ Id = $testResourceId; Filename = $testResourceFilename; }
                        )
                    }
                }
            }
            Remove-Item -Path "TestDrive:\$testResourceFilename" -Force -ErrorAction SilentlyContinue;

            $result = Test-LabResourceIsLocal -ConfigurationData $configurationData -ResourceId $testResourceId -LocalResourcePath 'TestDrive:';

            $result | Should Be $false;
        }

        foreach ($extension in @('iso','zip')) {
            It "Passes when local $($extension.ToUpper()) folder exists" {
                $testResourceFilename = "$testResourceId.$extension";
                $configurationData= @{
                    NonNodeData = @{
                        $labDefaults.ModuleName = @{
                            Resource = @(
                                @{ Id = $testResourceId; Filename = $testResourceFilename; Expand = $true; }
                            )
                        }
                    }
                }
                New-Item -Path "TestDrive:\$testResourceFilename" -ItemType File -Force;

                $result = Test-LabResourceIsLocal -ConfigurationData $configurationData -ResourceId $testResourceId -LocalResourcePath 'TestDrive:';

                $result | Should Be $false;
            }

            It "Fails when local $($extension.ToUpper()) folder does not exist" {
                $testResourceFilename = "$testResourceId.$extension";
                $configurationData= @{
                    NonNodeData = @{
                        $labDefaults.ModuleName = @{
                            Resource = @(
                                @{ Id = $testResourceId; Filename = $testResourceFilename; Expand = $true; }
                            )
                        }
                    }
                }
                Remove-Item -Path "TestDrive:\$testResourceFilename" -Force -ErrorAction SilentlyContinue;

                $result = Test-LabResourceIsLocal -ConfigurationData $configurationData -ResourceId $testResourceId -LocalResourcePath 'TestDrive:';

                $result | Should Be $false;
            }
        } #end foreach

        It 'Throws when local .EXE has "Expand" = "True"' {
            $testResourceFilename = "$testResourceId.exe";
            $configurationData= @{
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Resource = @(
                            @{ Id = $testResourceId; Filename = $testResourceFilename; Expand = $true; }
                        )
                    }
                }
            }

            { Test-LabResourceIsLocal -ConfigurationData $configurationData -ResourceId $testResourceId -LocalResourcePath 'TestDrive:' } | Should Throw;
        }

    } #end InModuleScope

} #end describe
