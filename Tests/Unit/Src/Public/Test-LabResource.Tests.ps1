#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Public\Test-LabResource' {

    InModuleScope $moduleName {

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
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }

            Test-LabResource -ConfigurationData $emptyConfigurationData | Should Be $true;
        }

        It 'Passes when all defined resources are present and "Id" parameter is not specified' {
            $testResourcePath = 'TestDrive:\Resources';
            $fakeConfigurationData = @{ ResourcePath = $testResourcePath;}
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
            foreach ($resource in $configurationData.NonNodeData.$($labDefaults.ModuleName).Resource) {
                New-Item -Path "$testResourcePath\$($resource.Id)" -ItemType File -Force -ErrorAction SilentlyContinue;
            }

            Test-LabResource -ConfigurationData $configurationData | Should Be $true;
        }

        It 'Passes when defined resource is present and "Id" parameter is specified' {
            $testResourceId = 'Resource2.iso';
            $testHostResourcePath = 'TestDrive:\Resources';
            $fakeConfigurationData = @{ ResourcePath = $testHostResourcePath;}
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
            New-Item -Path "$testHostResourcePath\$testResourceId" -ItemType File -Force -ErrorAction SilentlyContinue;

            Test-LabResource -ConfigurationData $configurationData -ResourceId $testResourceId | Should Be $true;
        }

        It 'Fails when a resource is missing and "Id" parameter is not specified' {
            $testMissingResourceId = 'Resource2.iso';
            $testResourcePath = 'TestDrive:\Resources';
            $fakeConfigurationData = @{ ResourcePath = $testResourcePath;}
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
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
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
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
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
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
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
            Mock TestResourceDownload -ParameterFilter { $Checksum -eq $testResourceChecksum } -MockWith { return $true; }

            Test-LabResource -ConfigurationData $checksumConfigurationData;

            Assert-MockCalled TestResourceDownload -ParameterFilter { $Checksum -eq $testResourceChecksum } -Scope It;
        }

    } #end InModuleScope

} #end describe
