#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Public\Invoke-LabResourceDownload' {

    InModuleScope $moduleName {

        It 'Downloads all media when "MediaId" parameter is not specified' {
            $configurationData= @{
                AllNodes = @(
                    @{ NodeName = 'VM1'; Media = '2022_x64_Standard_EN_Eval' }
                    @{ NodeName = 'VM2'; Media = '2022_x64_Standard_EN_Eval' }
                    @{ NodeName = 'VM3'; Media = 'WIN10_x64_Enterprise_EN_Eval' }
                )
            }
            Mock Invoke-LabMediaImageDownload -MockWith { }
            Mock Invoke-LabMediaDownload -MockWith { }

            Invoke-LabResourceDownload -ConfigurationData $configurationData;

            Assert-MockCalled Invoke-LabMediaImageDownload -Exactly 2 -Scope It;
        }

        It 'Downloads only unique media when "MediaId" parameter is not specified' {
            $configurationData= @{
                AllNodes = @(
                    @{ NodeName = 'VM1'; Media = '2022_x64_Standard_EN_Eval' }
                    @{ NodeName = 'VM2'; Media = '2022_x64_Standard_EN_Eval' }
                    @{ NodeName = 'VM3'; Media = '2022_x64_Standard_EN_Eval' }
                )
            }
            Mock Invoke-LabMediaImageDownload -MockWith { }
            Mock Invoke-LabMediaDownload -MockWith { }

            Invoke-LabResourceDownload -ConfigurationData $configurationData;

            Assert-MockCalled Invoke-LabMediaImageDownload -Exactly 1 -Scope It;
        }

        It 'Downloads single media when "MediaId" parameter is specified' {
            $configurationData= @{
                AllNodes = @(
                    @{ NodeName = 'VM1'; Media = '2022_x64_Standard_EN_Eval' }
                    @{ NodeName = 'VM2'; Media = '2022_x64_Standard_EN_Eval' }
                    @{ NodeName = 'VM3'; Media = 'WIN10_x64_Enterprise_EN_Eval' }
                )
            }
            Mock Invoke-LabMediaImageDownload -MockWith { }
            Mock Invoke-LabMediaDownload -MockWith { }

            Invoke-LabResourceDownload -ConfigurationData $configurationData -MediaId 'WIN10_x64_Enterprise_EN_Eval';

            Assert-MockCalled Invoke-LabMediaImageDownload -Exactly 1 -Scope It;
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
            Mock Invoke-LabMediaImageDownload -MockWith { }
            Mock Invoke-LabMediaDownload -MockWith { }
            Mock Invoke-ResourceDownload -MockWith { }

            Invoke-LabResourceDownload -ConfigurationData $configurationData -MediaId $testMediaId;

            Assert-MockCalled Invoke-LabMediaDownload -Exactly 2 -Scope It;
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
            Mock Invoke-LabMediaImageDownload -MockWith { }
            Mock Invoke-LabMediaDownload -MockWith { }
            Mock Invoke-ResourceDownload -MockWith { }
            Mock Get-Item -ParameterFilter { $Path -match 'Resource\d\.' } -MockWith { }

            Invoke-LabResourceDownload -ConfigurationData $configurationData;

            Assert-MockCalled Invoke-ResourceDownload -Exactly 3 -Scope It;
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
            Mock Invoke-LabMediaImageDownload -MockWith { }
            Mock Invoke-LabMediaDownload -MockWith { }
            Mock Invoke-ResourceDownload -MockWith { }

            Invoke-LabResourceDownload -ConfigurationData $configurationData -ResourceId 'Resource1.exe';

            Assert-MockCalled Invoke-ResourceDownload -Exactly 1 -Scope It;
        }

        It 'Downloads a single DSC resource module' {
            $configurationData = @{
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        DSCResource = @(
                            @{ Name = 'TestResource'; }
                        ) } } }
            Mock Invoke-LabMediaImageDownload;
            Mock Invoke-LabMediaDownload;
            Mock Invoke-LabModuleCacheDownload;
            Mock Invoke-ResourceDownload;

            Invoke-LabResourceDownload -ConfigurationData $configurationData;

            Assert-MockCalled Invoke-LabModuleCacheDownload -ParameterFilter { $Module.Count -eq 1 } -Scope It;
        }

        It 'Downloads multiple DSC resource modules' {
            $configurationData = @{
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        DSCResource = @(
                            @{ Name = 'TestResource1'; }
                            @{ Name = 'TestResource2'; }
                            @{ Name = 'TestResource3'; }
                        ) } } }
            Mock Invoke-LabMediaImageDownload;
            Mock Invoke-LabMediaDownload;
            Mock Invoke-LabModuleCacheDownload;
            Mock Invoke-ResourceDownload;

            Invoke-LabResourceDownload -ConfigurationData $configurationData;

            Assert-MockCalled Invoke-LabModuleCacheDownload -ParameterFilter { $Module.Count -eq 3 } -Scope It;
        }

        It 'Downloads a single PowerShell module' {
            $configurationData = @{
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Module = @(
                            @{ Name = 'TestModule'; }
                        ) } } }
            Mock Invoke-LabMediaImageDownload;
            Mock Invoke-LabMediaDownload;
            Mock Invoke-LabModuleCacheDownload;
            Mock Invoke-ResourceDownload;

            Invoke-LabResourceDownload -ConfigurationData $configurationData;

            Assert-MockCalled Invoke-LabModuleCacheDownload -Scope It;
        }

        It 'Downloads multiple PowerShell modules' {
            $configurationData = @{
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Module = @(
                            @{ Name = 'TestModule1'; }
                            @{ Name = 'TestModule3'; }
                        ) } } }
            Mock Invoke-LabMediaImageDownload;
            Mock Invoke-LabMediaDownload;
            Mock Invoke-LabModuleCacheDownload;
            Mock Invoke-ResourceDownload;

            Invoke-LabResourceDownload -ConfigurationData $configurationData;

            Assert-MockCalled Invoke-LabModuleCacheDownload -ParameterFilter { $Module.Count -eq 2 } -Scope It;
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
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
            Mock Invoke-LabMediaImageDownload -MockWith { }
            Mock Invoke-LabMediaDownload -MockWith { }
            Mock Invoke-ResourceDownload -ParameterFilter { $DestinationPath -eq $testResourceDestinationFilename } -MockWith { }
            Mock Get-Item -ParameterFilter { $Path -match 'Custom Resource Filename.test' } -MockWith { }

            Invoke-LabResourceDownload -ConfigurationData $filenameConfigurationData -ResourceId $testResourceId;

            Assert-MockCalled Invoke-ResourceDownload -ParameterFilter { $DestinationPath -eq $testResourceDestinationFilename } -Scope It
        }

    } #end InModuleScope

} #end describe
