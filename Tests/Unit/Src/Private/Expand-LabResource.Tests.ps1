#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Expand-LabResource' {

    InModuleScope $moduleName {

        It 'Creates destination "Resources" directory if it does not exist on target file sytem' {
            $testVM = 'VM1';
            $configurationData= @{
                AllNodes = @(
                    @{ NodeName = $testVM; Resource = @(); }
                )
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Resource = @( )
                    }
                }
            }
            $testHostResourcePath = 'TestDrive:\Resources';
            $fakeConfigurationData = @{ ResourcePath = $testHostResourcePath;}
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
            Remove-Item -Path $testHostResourcePath -Force -ErrorAction SilentlyContinue;

            Expand-LabResource -ConfigurationData $configurationData -Name $testVM -DestinationPath $testHostResourcePath;
            Test-Path -Path $testHostResourcePath | Should Be $true;
        }

        It 'Invokes "Invoke-LabResourceDownload" with "ResourceId" if resource is not found' {
            $testVM = 'VM1';
            $testResourceId = 'Resource1.exe';
            $configurationData= @{
                AllNodes = @(
                    @{ NodeName = $testVM; Resource = $testResourceId; }
                )
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Resource = @(
                            @{ Id = $testResourceId; Uri = 'http://test-resource.com/resource1.exe'; }
                        )
                    }
                }
            }
            $testHostResourcePath = 'TestDrive:\Resources';
            $fakeConfigurationData = @{ ResourcePath = $testHostResourcePath;}
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
            Mock Copy-Item -MockWith { }
            Mock Invoke-LabResourceDownload -ParameterFilter { $ResourceId -eq $testResourceId } -MockWith {
                New-Item -Path "$testHostResourcePath\$testResourceId" -ItemType File -Force -ErrorAction SilentlyContinue;
            }

            Expand-LabResource -ConfigurationData $configurationData -Name $testVM -DestinationPath $testHostResourcePath;

            Assert-MockCalled Invoke-LabResourceDownload -ParameterFilter { $ResourceId -eq $testResourceId } -Scope It;
        }

        It 'Uses resource "Filename" property if specified' {
            $testVM = 'VM1';
            $testResourceId = 'Resource1.exe';
            $testResourceFilename = 'Resource Filename.test';
            $configurationData= @{
                AllNodes = @(
                    @{ NodeName = $testVM; Resource = $testResourceId; }
                )
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Resource = @(
                            @{ Id = $testResourceId; Uri = 'http://test-resource.com/resource1.exe'; Filename = $testResourceFilename; }
                        )
                    }
                }
            }
            $testHostResourcePath = 'TestDrive:\Resources';
            $fakeConfigurationData = @{ ResourcePath = $testHostResourcePath;}
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
            Mock Copy-Item -MockWith { }
            Mock Invoke-LabResourceDownload -ParameterFilter { $ResourceId -eq $testResourceId } -MockWith {
                New-Item -Path "$testHostResourcePath\$testResourceFilename" -ItemType File -Force -ErrorAction SilentlyContinue;
            }

            Expand-LabResource -ConfigurationData $configurationData -Name $testVM -DestinationPath $testHostResourcePath;

            Assert-MockCalled Invoke-LabResourceDownload -ParameterFilter { $ResourceId -eq $testResourceId } -Scope It;
        }

        It 'Copies resource by default' {
            $testVM = 'VM1';
            $testResourceId = 'Resource1.exe';
            $configurationData= @{
                AllNodes = @(
                    @{ NodeName = $testVM; Resource = $testResourceId; }
                )
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Resource = @(
                            @{ Id = $testResourceId; Uri = 'http://test-resource.com/resource1.exe'; }
                        )
                    }
                }
            }
            $testHostResourcePath = 'TestDrive:\Resources';
            $fakeConfigurationData = @{ ResourcePath = $testHostResourcePath;}
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
            New-Item -Path "$testHostResourcePath\$testResourceId" -ItemType File -Force -ErrorAction SilentlyContinue;
            Mock Copy-Item -ParameterFilter { $Destination -eq $testHostResourcePath -and $Force -eq $true } -MockWith { }

            Expand-LabResource -ConfigurationData $configurationData -Name $testVM -DestinationPath $testHostResourcePath;

            Assert-MockCalled Copy-Item -ParameterFilter { $Destination -eq $testHostResourcePath -and $Force -eq $true } -Scope It;
        }

        It 'Copies resource to explicit target destination path' {
            $testVM = 'VM1';
            $testResourceId = 'Resource1.exe';
            $defaultDestinationPath = 'Resources';
            $defaultHostResourcePath = "TestDrive:\$defaultDestinationPath";
            $testDestinationPath = 'MyResources';
            $testResourcePath = "TestDrive:\$testDestinationPath";
            $configurationData= @{
                AllNodes = @(
                    @{ NodeName = $testVM; Resource = $testResourceId; }
                )
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Resource = @(
                            @{ Id = $testResourceId; Uri = 'http://test-resource.com/resource1.exe'; DestinationPath = "\$testDestinationPath"; }
                        )
                    }
                }
            }
            $fakeConfigurationData = @{ ResourcePath = "TestDrive:\$defaultDestinationPath";}
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
            New-Item -Path "$testResourcePath\$testResourceId" -ItemType File -Force -ErrorAction SilentlyContinue;
            Mock Copy-Item -ParameterFilter { $Destination -eq $testResourcePath -and $Force -eq $true } -MockWith { }

            Expand-LabResource -ConfigurationData $configurationData -Name $testVM -DestinationPath $defaultHostResourcePath;

            Assert-MockCalled Copy-Item -ParameterFilter { $Destination -eq $testResourcePath -and $Force -eq $true } -Scope It;
        }

        It 'Calls "ExpandZipArchive" if "Expand" property is specified on a "ZIP" resource' {
            $testVM = 'VM1';
            $testResourceId = 'Resource1.zip';
            $configurationData= @{
                AllNodes = @(
                    @{ NodeName = $testVM; Resource = $testResourceId; }
                )
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Resource = @(
                            @{ Id = $testResourceId; Uri = 'http://test-resource.com/resource1.zip'; Expand = $true; }
                        )
                    }
                }
            }
            $testHostResourcePath = 'TestDrive:\Resources';
            $fakeConfigurationData = @{ ResourcePath = $testHostResourcePath;}
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
            New-Item -Path "$testHostResourcePath\$testResourceId" -ItemType File -Force -ErrorAction SilentlyContinue;
            Mock ExpandZipArchive -MockWith { }

            Expand-LabResource -ConfigurationData $configurationData -Name $testVM -DestinationPath $testHostResourcePath;

            Assert-MockCalled ExpandZipArchive -Scope It;
        }

        It 'Calls "ExpandZipArchive" to explicit target path when "Expand" is specified on a "ZIP" resource' {
            $testVM = 'VM1';
            $testResourceId = 'Resource1.zip';
            $testDestinationPath = 'MyResources';
            $testResourcePath = "TestDrive:\$testDestinationPath";
            $configurationData= @{
                AllNodes = @(
                    @{ NodeName = $testVM; Resource = $testResourceId; }
                )
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Resource = @(
                            @{ Id = $testResourceId; Uri = 'http://test-resource.com/resource1.zip'; Expand = $true; DestinationPath = "\$testDestinationPath" }
                        )
                    }
                }
            }
            $testHostResourcePath = 'TestDrive:\Resources';
            $fakeConfigurationData = @{ ResourcePath = $testHostResourcePath;}
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
            Mock ExpandZipArchive -ParameterFilter { $DestinationPath -eq $testResourcePath } -MockWith { }

            Expand-LabResource -ConfigurationData $configurationData -Name $testVM -DestinationPath $testHostResourcePath;

            Assert-MockCalled ExpandZipArchive -ParameterFilter { $DestinationPath -eq $testResourcePath } -Scope It;
        }

        It 'Calls "ExpandIso" if "Expand" property is specified on an "ISO" resource' {
            $testVM = 'VM1';
            $testResourceId = 'Resource1.iso';
            $configurationData= @{
                AllNodes = @(
                    @{ NodeName = $testVM; Resource = $testResourceId; }
                )
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Resource = @(
                            @{ Id = $testResourceId; Uri = 'http://test-resource.com/resource1.iso'; Expand = $true; }
                        )
                    }
                }
            }
            $testHostResourcePath = 'TestDrive:\Resources';
            $fakeConfigurationData = @{ ResourcePath = $testHostResourcePath;}
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
            New-Item -Path "$testHostResourcePath\$testResourceId" -ItemType File -Force -ErrorAction SilentlyContinue;
            Mock ExpandIso -MockWith { }

            Expand-LabResource -ConfigurationData $configurationData -Name $testVM -DestinationPath $testHostResourcePath;

            Assert-MockCalled ExpandIso -Scope It;
        }

        It 'Calls "ExpandIso" to explicit target path when "Expand" is specified on a "ISO" resource' {
            $testVM = 'VM1';
            $testResourceId = 'Resource1.iso';
            $testDestinationPath = 'MyResources';
            $testResourcePath = "TestDrive:\$testDestinationPath";
            $configurationData= @{
                AllNodes = @(
                    @{ NodeName = $testVM; Resource = $testResourceId; }
                )
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Resource = @(
                            @{ Id = $testResourceId; Uri = 'http://test-resource.com/resource1.iso'; Expand = $true; DestinationPath = "\$testDestinationPath" }
                        )
                    }
                }
            }
            $testHostResourcePath = 'TestDrive:\Resources';
            $fakeConfigurationData = @{ ResourcePath = $testHostResourcePath;}

            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
            Mock ExpandIso -ParameterFilter { $DestinationPath -eq $testResourcePath } -MockWith { }

            Expand-LabResource -ConfigurationData $configurationData -Name $testVM -DestinationPath $testHostResourcePath;

            Assert-MockCalled ExpandIso -ParameterFilter { $DestinationPath -eq $testResourcePath } -Scope It;
        }

        It 'Throws if "Expand" property is specified on an "EXE" resource' {
            $testVM = 'VM1';
            $testResourceId = 'Resource1.exe';
            $configurationData= @{
                AllNodes = @(
                    @{ NodeName = $testVM; Resource = $testResourceId; }
                )
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Resource = @(
                            @{ Id = $testResourceId; Uri = 'http://test-resource.com/resource1.exe'; Expand = $true; }
                        )
                    }
                }
            }
            $testHostResourcePath = 'TestDrive:\Resources';
            $fakeConfigurationData = @{ ResourcePath = $testHostResourcePath;}
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
            New-Item -Path "$testHostResourcePath\$testResourceId" -ItemType File -Force -ErrorAction SilentlyContinue;

            { Expand-LabResource -ConfigurationData $configurationData -Name $testVM -DestinationPath $testHostResourcePath } | Should Throw;
        }

    } #end InModuleScope

} #end describe
