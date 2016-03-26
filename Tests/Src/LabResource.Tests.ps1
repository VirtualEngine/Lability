#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
if (!$PSScriptRoot) { # $PSScriptRoot is not defined in 2.0
    $PSScriptRoot = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
}
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;

Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'LabResource' {

    InModuleScope $moduleName {

        Context 'Validates "Get-LabHostDefault" method' {

            $configurationData = @{
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Resource = @(
                            @{ Id = 'Resource1.exe'; Uri = 'http://test-resource.com/resource1.exe'; }
                            @{ Id = 'Resource2.iso'; Uri = 'http://test-resource.com/resource2.iso'; }
                            @{ Id = 'Resource3.zip'; Uri = 'http://test-resource.com/resource1.zip'; }
                        ) } } }

            It 'Passes when no resources are defined in the configuration data' {
                $emptyConfigurationData = @{ NonNodeData = @{ $labDefaults.ModuleName = @{ Resource = @( ) } } }
                $fakeConfigurationData = @{ ResourcePath = $testResourcePath;}
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
                Mock ConvertToConfigurationData -MockWith { return $emptyConfigurationData; }

                Test-LabResource -ConfigurationData $configurationData | Should Be $true;
            }

            It 'Passes when all defined resources are present and "Id" parameter is not specified' {
                $testResourcePath = 'TestDrive:\Resources';
                $fakeConfigurationData = @{ ResourcePath = $testResourcePath;}
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
                Mock ConvertToConfigurationData -MockWith { return $configurationData; }
                foreach ($resource in $configurationData.NonNodeData.$($labDefaults.ModuleName).Resource) {
                    New-Item -Path "$testResourcePath\$($resource.Id)" -ItemType File -Force -ErrorAction SilentlyContinue;
                }

                Test-LabResource -ConfigurationData $configurationData | Should Be $true;
            }

            It 'Passes when defined resource is present and "Id" parameter is specified' {
                $testResourceId = 'Resource2.iso';
                $testHostResourcePath = 'TestDrive:\Resources';
                $fakeConfigurationData = @{ ResourcePath = $testHostResourcePath;}
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
                Mock ConvertToConfigurationData -MockWith { return $configurationData; }
                New-Item -Path "$testHostResourcePath\$testResourceId" -ItemType File -Force -ErrorAction SilentlyContinue;

                Test-LabResource -ConfigurationData $configurationData -ResourceId $testResourceId | Should Be $true;
            }

            It 'Fails when a resource is missing and "Id" parameter is not specified' {
                $testMissingResourceId = 'Resource2.iso';
                $testResourcePath = 'TestDrive:\Resources';
                $fakeConfigurationData = @{ ResourcePath = $testResourcePath;}
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
                Mock ConvertToConfigurationData -MockWith { return $configurationData; }
                foreach ($resource in $configurationData.NonNodeData.$($labDefaults.ModuleName).Resource) {
                    New-Item -Path "$testResourcePath\$($resource.Id)" -ItemType File -Force -ErrorAction SilentlyContinue;
                }
                Remove-Item -Path "$testResourcePath\$testMissingResourceId" -Force -ErrorAction SilentlyContinue;

                Test-LabResource -ConfigurationData $configurationData | Should Be $false;
            }

            It 'Fails when a resource is missing and "Id" parameter is specified' {
                $testMissingResourceId = 'Resource2.iso';
                $testResourcePath = 'TestDrive:\Resources';
                $fakeConfigurationData = @{ ResourcePath = $testResourcePath;}
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
                Mock ConvertToConfigurationData -MockWith { return $configurationData; }
                foreach ($resource in $configurationData.NonNodeData.$($labDefaults.ModuleName).Resource) {
                    New-Item -Path "$testResourcePath\$($resource.Id)" -ItemType File -Force -ErrorAction SilentlyContinue;
                }
                Remove-Item -Path "$testResourcePath\$testMissingResourceId" -Force -ErrorAction SilentlyContinue;

                Test-LabResource -ConfigurationData $configurationData -ResourceId $testMissingResourceId | Should Be $false;
            }

            It 'Uses resource "Filename" property if specified' {
                $testResourceId = 'Resource4.iso';
                $testResourceFilename = 'Custom Resource Filename.test'
                $filenameConfigurationData = @{
                    NonNodeData = @{
                        $labDefaults.ModuleName = @{
                            Resource = @(
                                @{ Id = $testResourceId; Filename = $testResourceFilename; Uri = "http://test-resource.com/$testResourceId"; }
                            )
                } } }
                $testHostResourcePath = 'TestDrive:\Resources';
                $fakeConfigurationData = @{ ResourcePath = $testHostResourcePath;}
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
                Mock ConvertToConfigurationData -MockWith { return $configurationData; }
                New-Item -Path "$testHostResourcePath\$testResourceFilename" -ItemType File -Force -ErrorAction SilentlyContinue;

                Test-LabResource -ConfigurationData $filenameConfigurationData -ResourceId $testResourceId | Should Be $true;
            }

            It 'Calls "TestResourceDownload" with "Checksum" parameter when defined' {
                $testResourceId = 'Resource4.iso';
                $testResourceChecksum = 'ABCDEF1234567890';
                $checksumConfigurationData = @{
                    NonNodeData = @{
                        $labDefaults.ModuleName = @{
                            Resource = @(
                                @{ Id = $testResourceId; Checksum = $testResourceChecksum; Uri = "http://test-resource.com/$testResourceId"; }
                            )
                } } }
                $testHostResourcePath = 'TestDrive:\Resources';
                $fakeConfigurationData = @{ ResourcePath = $testHostResourcePath;}
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
                Mock ConvertToConfigurationData -MockWith { return $configurationData; }
                Mock TestResourceDownload -ParameterFilter { $Checksum -eq $testResourceChecksum } -MockWith { return $true; }

                Test-LabResource -ConfigurationData $checksumConfigurationData;

                Assert-MockCalled TestResourceDownload -ParameterFilter { $Checksum -eq $testResourceChecksum } -Scope It;
            }

        } #end context Validates "Get-LabHostDefault" method

        Context 'Validates "Invoke-LabResourceDownload" method' {

            It 'Downloads all media when "MediaId" parameter is not specified' {
                $configurationData= @{
                    AllNodes = @(
                        @{ NodeName = 'VM1'; Media = '2012R2_x64_Standard_Core_EN_Eval' }
                        @{ NodeName = 'VM2'; Media = '2012R2_x64_Standard_Core_EN_Eval' }
                        @{ NodeName = 'VM3'; Media = 'WIN81_x64_Enterprise_EN_Eval' }
                    )
                }
                Mock InvokeLabMediaImageDownload -MockWith { }
                Mock InvokeLabMediaHotfixDownload -MockWith { }

                Invoke-LabResourceDownload -ConfigurationData $configurationData;

                Assert-MockCalled InvokeLabMediaImageDownload -Exactly 2 -Scope It;
            }

            It 'Downloads only unique media when "MediaId" parameter is not specified' {
                $configurationData= @{
                    AllNodes = @(
                        @{ NodeName = 'VM1'; Media = '2012R2_x64_Standard_Core_EN_Eval' }
                        @{ NodeName = 'VM2'; Media = '2012R2_x64_Standard_Core_EN_Eval' }
                        @{ NodeName = 'VM3'; Media = '2012R2_x64_Standard_Core_EN_Eval' }
                    )
                }
                Mock InvokeLabMediaImageDownload -MockWith { }
                Mock InvokeLabMediaHotfixDownload -MockWith { }

                Invoke-LabResourceDownload -ConfigurationData $configurationData;

                Assert-MockCalled InvokeLabMediaImageDownload -Exactly 1 -Scope It;
            }

            It 'Downloads single media when "MediaId" parameter is specified' {
                $configurationData= @{
                    AllNodes = @(
                        @{ NodeName = 'VM1'; Media = '2012R2_x64_Standard_Core_EN_Eval' }
                        @{ NodeName = 'VM2'; Media = '2012R2_x64_Standard_Core_EN_Eval' }
                        @{ NodeName = 'VM3'; Media = 'WIN81_x64_Enterprise_EN_Eval' }
                    )
                }
                Mock InvokeLabMediaImageDownload -MockWith { }
                Mock InvokeLabMediaHotfixDownload -MockWith { }

                Invoke-LabResourceDownload -ConfigurationData $configurationData -MediaId 'WIN81_x64_Enterprise_EN_Eval';

                Assert-MockCalled InvokeLabMediaImageDownload -Exactly 1 -Scope It;
            }

            It 'Downloads all required hotfixes' {
                $testMediaId = 'TestMedia';
                $configurationData = @{
                    NonNodeData = @{
                        $labDefaults.ModuleName = @{
                            Media = @(
                                @{  Id = $testMediaId;
                                    Uri = 'http://test-resource.com/resource1.exe';
                                    Filename = 'TestMedia.iso';
                                    Architecture = 'x86';
                                    MediaType = 'ISO';
                                    Hotfixes = @(
                                        @{  Id = 'Windows8.1-KB2883200-x86.msu';
			                                Uri = 'http://download.microsoft.com/download/6/F/C/6FC4B3F3-1103-452F-929D-A9FCABF1AD2B/Windows8.1-KB2883200-x86.msu';
		                                },
		                                @{  Id = 'Windows8.1-KB2894029-x86.msu';
			                                Uri = 'http://download.microsoft.com/download/6/F/C/6FC4B3F3-1103-452F-929D-A9FCABF1AD2B/Windows8.1-KB2894029-x86.msu';
		                                } ) }
                            ) } } }
                Mock InvokeLabMediaImageDownload -MockWith { }
                Mock InvokeLabMediaHotfixDownload -MockWith { }
                Mock InvokeResourceDownload -MockWith { }

                Invoke-LabResourceDownload -ConfigurationData $configurationData -MediaId $testMediaId;

                Assert-MockCalled InvokeLabMediaHotfixDownload -Exactly 2 -Scope It;
            }

            It 'Downloads all resources when "ResourceId" parameter is not specified' {
                $configurationData = @{
                    NonNodeData = @{
                        $labDefaults.ModuleName = @{
                            Resource = @(
                                @{ Id = 'Resource1.exe'; Uri = 'http://test-resource.com/resource1.exe'; }
                                @{ Id = 'Resource2.iso'; Uri = 'http://test-resource.com/resource2.iso'; }
                                @{ Id = 'Resource3.zip'; Uri = 'http://test-resource.com/resource1.zip'; }
                            ) } } }
                Mock InvokeLabMediaImageDownload -MockWith { }
                Mock InvokeLabMediaHotfixDownload -MockWith { }
                Mock InvokeResourceDownload -MockWith { }
                Mock Get-Item -ParameterFilter { $Path -match 'Resource\d\.' } -MockWith { }

                Invoke-LabResourceDownload -ConfigurationData $configurationData;

                Assert-MockCalled InvokeResourceDownload -Exactly 3 -Scope It;
            }

            It 'Downloads single resource when "ResourceId" parameter is specified' {
                $configurationData = @{
                    NonNodeData = @{
                        $labDefaults.ModuleName = @{
                            Resource = @(
                                @{ Id = 'Resource1.exe'; Uri = 'http://test-resource.com/resource1.exe'; }
                                @{ Id = 'Resource2.iso'; Uri = 'http://test-resource.com/resource2.iso'; }
                                @{ Id = 'Resource3.zip'; Uri = 'http://test-resource.com/resource1.zip'; }
                            ) } } }
                Mock InvokeLabMediaImageDownload -MockWith { }
                Mock InvokeLabMediaHotfixDownload -MockWith { }
                Mock InvokeResourceDownload -MockWith { }

                Invoke-LabResourceDownload -ConfigurationData $configurationData -ResourceId 'Resource1.exe';

                Assert-MockCalled InvokeResourceDownload -Exactly 1 -Scope It;
            }

            It 'Downloads a single DSC resource' {
                $configurationData = @{
                    NonNodeData = @{
                        $labDefaults.ModuleName = @{
                            DSCResource = @(
                                @{ Name = 'TestResource'; }
                            ) } } }
                Mock InvokeLabMediaImageDownload -MockWith { }
                Mock InvokeLabMediaHotfixDownload -MockWith { }
                Mock InvokeDscResourceDownload -MockWith { }
                Mock InvokeResourceDownload -MockWith { }

                Invoke-LabResourceDownload -ConfigurationData $configurationData;

                Assert-MockCalled InvokeDscResourceDownload -Scope It;
            }

            It 'Downloads multiple DSC resources' {
                $configurationData = @{
                    NonNodeData = @{
                        $labDefaults.ModuleName = @{
                            DSCResource = @(
                                @{ Name = 'TestResource1'; }
                                @{ Name = 'TestResource2'; }
                                @{ Name = 'TestResource3'; }
                            ) } } }
                Mock InvokeLabMediaImageDownload -MockWith { }
                Mock InvokeLabMediaHotfixDownload -MockWith { }
                Mock InvokeDscResourceDownload -MockWith { }
                Mock InvokeResourceDownload -MockWith { }

                Invoke-LabResourceDownload -ConfigurationData $configurationData;

                Assert-MockCalled InvokeDscResourceDownload -Exactly 1 -Scope It;
            }

            It 'Uses resource "Filename" property if specified' {
                $testResourceId = 'Resource4.iso';
                $testResourceFilename = 'Custom Resource Filename.test';

                $filenameConfigurationData = @{
                    NonNodeData = @{
                        $labDefaults.ModuleName = @{
                            Resource = @(
                                @{ Id = $testResourceId; Filename = $testResourceFilename; Uri = "http://test-resource.com/$testResourceId"; }
                            )
                } } }
                $testHostResourcePath = 'TestDrive:\Resources';
                $testResourceDestinationFilename = "$testHostResourcePath\$testResourceFilename";
                $fakeConfigurationData = @{ ResourcePath = $testHostResourcePath;}
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
                Mock InvokeLabMediaImageDownload -MockWith { }
                Mock InvokeLabMediaHotfixDownload -MockWith { }
                Mock InvokeResourceDownload -ParameterFilter { $DestinationPath -eq $testResourceDestinationFilename } -MockWith { }
                Mock Get-Item -ParameterFilter { $Path -match 'Custom Resource Filename.test' } -MockWith { }

                Invoke-LabResourceDownload -ConfigurationData $filenameConfigurationData -ResourceId $testResourceId;

                Assert-MockCalled InvokeResourceDownload -ParameterFilter { $DestinationPath -eq $testResourceDestinationFilename } -Scope It
            }

        } #end context Validates "Invoke-LabResourceDownload" method

        Context 'Validates "ResolveLabResource" method' {

            It 'Returns resource record if "ResourceId" is found' {
                $configurationData = @{
                    NonNodeData = @{
                        $labDefaults.ModuleName = @{
                            Resource = @(
                                @{ Id = 'Resource1.exe'; Uri = 'http://test-resource.com/resource1.exe'; }
                            ) } } }
                $resource = ResolveLabResource -ConfigurationData $configurationData -ResourceId 'Resource1.exe';
                $resource | Should Not BeNullOrEmpty;
            }

            It 'Throws if "ResourceId" is not found' {
                $configurationData = @{
                    NonNodeData = @{
                        $labDefaults.ModuleName = @{
                            Resource = @(
                                @{ Id = 'Resource1.exe'; Uri = 'http://test-resource.com/resource1.exe'; }
                            ) } } }
                { ResolveLabResource -ConfigurationData $configurationData -ResourceId 'Resource2.iso' } | Should Throw;
            }

        } #end context Validates "ResolveLabResource" method

        Context 'Validates "ExpandIsoResource" method' {

            It 'Mounts ISO image read-only' {
                $testIsoPath = 'TestDrive:\TestIsoImage.iso';
                $testDestinationPath = 'Y:\';
                $testIsoMountDrive = 'Z';
                $fakeDiskImage = [PSCustomObject] @{ DriveLetter = $testIsoMountDrive; ImagePath = $testIsoPath };
                Mock Get-Volume -MockWith { return [PSCustomObject] @{ DriveLetter = $testIsoMountDrive } }
                Mock CopyDirectory -MockWith { }
                Mock Dismount-DiskImage -MockWith { }
                Mock Mount-DiskImage -ParameterFilter { $ImagePath -eq $testIsoPath -and $Access -eq 'ReadOnly' } -MockWith { return $fakeDiskImage; }

                ExpandIsoResource -Path $testIsoPath -DestinationPath $testDestinationPath;

                Assert-MockCalled Mount-DiskImage -ParameterFilter { $ImagePath -eq $testIsoPath -and $Access -eq 'ReadOnly' } -Scope It;
            }

            It 'Copies ISO image contents to destination path recursively' {
                $testIsoPath = 'TestDrive:\TestIsoImage.iso';
                $testDestinationPath = 'Y:\';
                $testIsoMountDrive = 'Z';
                $fakeDiskImage = [PSCustomObject] @{ DriveLetter = $testIsoMountDrive; ImagePath = $testIsoPath };
                Mock Mount-DiskImage -MockWith { return $fakeDiskImage; }
                Mock Get-Volume -MockWith { return [PSCustomObject] @{ DriveLetter = $testIsoMountDrive } }
                Mock Dismount-DiskImage -MockWith { }
                Mock CopyDirectory -ParameterFilter { $DestinationPath.FullName -eq $testDestinationPath } -MockWith { }

                ExpandIsoResource -Path $testIsoPath -DestinationPath $testDestinationPath;

                Assert-MockCalled CopyDirectory -ParameterFilter { $DestinationPath.FullName -eq $testDestinationPath } -Scope It;
            }

            It 'Disounts ISO image' {
                $testIsoPath = 'TestDrive:\TestIsoImage.iso';
                $testDestinationPath = 'Y:\';
                $testIsoMountDrive = 'Z';
                $fakeDiskImage = [PSCustomObject] @{ DriveLetter = $testIsoMountDrive; ImagePath = $testIsoPath };
                Mock Mount-DiskImage -MockWith { return $fakeDiskImage; }
                Mock Get-Volume -MockWith { return [PSCustomObject] @{ DriveLetter = $testIsoMountDrive } }
                Mock CopyDirectory -MockWith { }
                Mock Dismount-DiskImage -ParameterFilter { $ImagePath -eq $testIsoPath } -MockWith { }

                ExpandIsoResource -Path $testIsoPath -DestinationPath $testDestinationPath;

                Assert-MockCalled Dismount-DiskImage -ParameterFilter { $ImagePath -eq $testIsoPath } -Scope It;
            }

        } #end context Validates "ExpandIsoResource" method

        Context 'Validates "ExpandLabResource" method' {

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
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
                Mock ConvertToConfigurationData -MockWith { return $configurationData; }
                Remove-Item -Path $testHostResourcePath -Force -ErrorAction SilentlyContinue;

                ExpandLabResource -ConfigurationData $configurationData -Name $testVM -DestinationPath $testHostResourcePath;
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
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
                Mock ConvertToConfigurationData -MockWith { return $configurationData; }
                Mock Copy-Item -MockWith { }
                Mock Invoke-LabResourceDownload -ParameterFilter { $ResourceId -eq $testResourceId } -MockWith {
                   New-Item -Path "$testHostResourcePath\$testResourceId" -ItemType File -Force -ErrorAction SilentlyContinue;
                }

                ExpandLabResource -ConfigurationData $configurationData -Name $testVM -DestinationPath $testHostResourcePath;

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
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
                Mock ConvertToConfigurationData -MockWith { return $configurationData; }
                Mock Copy-Item -MockWith { }
                Mock Invoke-LabResourceDownload -ParameterFilter { $ResourceId -eq $testResourceId } -MockWith {
                   New-Item -Path "$testHostResourcePath\$testResourceFilename" -ItemType File -Force -ErrorAction SilentlyContinue;
                }

                ExpandLabResource -ConfigurationData $configurationData -Name $testVM -DestinationPath $testHostResourcePath;

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
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
                Mock ConvertToConfigurationData -MockWith { return $configurationData; }
                New-Item -Path "$testHostResourcePath\$testResourceId" -ItemType File -Force -ErrorAction SilentlyContinue;
                Mock Copy-Item -ParameterFilter { $Destination -eq $testHostResourcePath -and $Force -eq $true } -MockWith { }

                ExpandLabResource -ConfigurationData $configurationData -Name $testVM -DestinationPath $testHostResourcePath;

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
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
                Mock ConvertToConfigurationData -MockWith { return $configurationData; }
                New-Item -Path "$testResourcePath\$testResourceId" -ItemType File -Force -ErrorAction SilentlyContinue;
                Mock Copy-Item -ParameterFilter { $Destination -eq $testResourcePath -and $Force -eq $true } -MockWith { }

                ExpandLabResource -ConfigurationData $configurationData -Name $testVM -DestinationPath $defaultHostResourcePath;

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
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
                Mock ConvertToConfigurationData -MockWith { return $configurationData; }
                New-Item -Path "$testHostResourcePath\$testResourceId" -ItemType File -Force -ErrorAction SilentlyContinue;
                Mock ExpandZipArchive -MockWith { }

                ExpandLabResource -ConfigurationData $configurationData -Name $testVM -DestinationPath $testHostResourcePath;

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
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
                Mock ConvertToConfigurationData -MockWith { return $configurationData; }
                Mock ExpandZipArchive -ParameterFilter { $DestinationPath -eq $testResourcePath } -MockWith { }

                ExpandLabResource -ConfigurationData $configurationData -Name $testVM -DestinationPath $testHostResourcePath;

                Assert-MockCalled ExpandZipArchive -ParameterFilter { $DestinationPath -eq $testResourcePath } -Scope It;
            }

            It 'Calls "ExpandIsoResource" if "Expand" property is specified on an "ISO" resource' {
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
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
                Mock ConvertToConfigurationData -MockWith { return $configurationData; }
                New-Item -Path "$testHostResourcePath\$testResourceId" -ItemType File -Force -ErrorAction SilentlyContinue;
                Mock ExpandIsoResource -MockWith { }

                ExpandLabResource -ConfigurationData $configurationData -Name $testVM -DestinationPath $testHostResourcePath;

                Assert-MockCalled ExpandIsoResource -Scope It;
            }

            It 'Calls "ExpandIsoResource" to explicit target path when "Expand" is specified on a "ISO" resource' {
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

                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
                Mock ConvertToConfigurationData -MockWith { return $configurationData; }
                Mock ExpandIsoResource -ParameterFilter { $DestinationPath -eq $testResourcePath } -MockWith { }

                ExpandLabResource -ConfigurationData $configurationData -Name $testVM -DestinationPath $testHostResourcePath;

                Assert-MockCalled ExpandIsoResource -ParameterFilter { $DestinationPath -eq $testResourcePath } -Scope It;
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
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
                Mock ConvertToConfigurationData -MockWith { return $configurationData; }
                New-Item -Path "$testHostResourcePath\$testResourceId" -ItemType File -Force -ErrorAction SilentlyContinue;

                { ExpandLabResource -ConfigurationData $configurationData -Name $testVM -DestinationPath $testHostResourcePath } | Should Throw;
            }

        } #end context Validates "ExpandLabResource" method

        Context 'Validates "TestLabLocalResource" method' {

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

                $result = TestLabLocalResource -ConfigurationData $configurationData -ResourceId $testResourceId -LocalResourcePath 'TestDrive:';

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

                $result = TestLabLocalResource -ConfigurationData $configurationData -ResourceId $testResourceId -LocalResourcePath 'TestDrive:';

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

                $result = TestLabLocalResource -ConfigurationData $configurationData -ResourceId $testResourceId -LocalResourcePath 'TestDrive:';

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

                    $result = TestLabLocalResource -ConfigurationData $configurationData -ResourceId $testResourceId -LocalResourcePath 'TestDrive:';

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

                    $result = TestLabLocalResource -ConfigurationData $configurationData -ResourceId $testResourceId -LocalResourcePath 'TestDrive:';

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

                { TestLabLocalResource -ConfigurationData $configurationData -ResourceId $testResourceId -LocalResourcePath 'TestDrive:' } | Should Throw;
            }

        } #end context Validates "TestLabLocalResource" method

    } #end InModuleScope

} #end describe LabResource
