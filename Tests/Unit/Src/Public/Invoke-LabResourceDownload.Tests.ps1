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

        It 'Downloads a single DSC resource module' {
            $configurationData = @{
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        DSCResource = @(
                            @{ Name = 'TestResource'; }
                        ) } } }
            Mock InvokeLabMediaImageDownload;
            Mock InvokeLabMediaHotfixDownload;
            Mock InvokeModuleCacheDownload;
            Mock InvokeResourceDownload;

            Invoke-LabResourceDownload -ConfigurationData $configurationData;

            Assert-MockCalled InvokeModuleCacheDownload -ParameterFilter { $Module.Count -eq 1 } -Scope It;
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
            Mock InvokeLabMediaImageDownload;
            Mock InvokeLabMediaHotfixDownload;
            Mock InvokeModuleCacheDownload;
            Mock InvokeResourceDownload;

            Invoke-LabResourceDownload -ConfigurationData $configurationData;

            Assert-MockCalled InvokeModuleCacheDownload -ParameterFilter { $Module.Count -eq 3 } -Scope It;
        }

        It 'Downloads a single PowerShell module' {
            $configurationData = @{
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Module = @(
                            @{ Name = 'TestModule'; }
                        ) } } }
            Mock InvokeLabMediaImageDownload;
            Mock InvokeLabMediaHotfixDownload;
            Mock InvokeModuleCacheDownload;
            Mock InvokeResourceDownload;

            Invoke-LabResourceDownload -ConfigurationData $configurationData;

            Assert-MockCalled InvokeModuleCacheDownload -Scope It;
        }

        It 'Downloads multiple PowerShell modules' {
            $configurationData = @{
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Module = @(
                            @{ Name = 'TestModule1'; }
                            @{ Name = 'TestModule3'; }
                        ) } } }
            Mock InvokeLabMediaImageDownload;
            Mock InvokeLabMediaHotfixDownload;
            Mock InvokeModuleCacheDownload;
            Mock InvokeResourceDownload;

            Invoke-LabResourceDownload -ConfigurationData $configurationData;

            Assert-MockCalled InvokeModuleCacheDownload -ParameterFilter { $Module.Count -eq 2 } -Scope It;
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
            Mock InvokeLabMediaImageDownload -MockWith { }
            Mock InvokeLabMediaHotfixDownload -MockWith { }
            Mock InvokeResourceDownload -ParameterFilter { $DestinationPath -eq $testResourceDestinationFilename } -MockWith { }
            Mock Get-Item -ParameterFilter { $Path -match 'Custom Resource Filename.test' } -MockWith { }

            Invoke-LabResourceDownload -ConfigurationData $filenameConfigurationData -ResourceId $testResourceId;

            Assert-MockCalled InvokeResourceDownload -ParameterFilter { $DestinationPath -eq $testResourceDestinationFilename } -Scope It
        }

    } #end InModuleScope

} #end describe
