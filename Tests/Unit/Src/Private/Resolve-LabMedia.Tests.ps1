#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Resolve-LabMedia' {

    InModuleScope -ModuleName $moduleName {

        It 'Throws if media Id cannot be resolved' {
            $testMediaId = '2016_x64_Datacenter_EN_Eval';
            $testMediaFilename = 'test-media.iso';
            $configurationData = @{
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Media = @(
                            @{  Id = $testMediaId;
                                Filename = $testMediaFilename;
                                Architecture = 'x64';
                                MediaType = 'ISO';
                                Uri = 'http://testmedia.com/test-media.iso';
                                CustomData = @{ }; } ) } } }

            { Resolve-LabMedia -Id NonExistentMediaId -ConfigurationData $configurationData } | Should Throw;
        }

        It 'Returns configuration data media entry if it exists' {
            $testMediaId = '2016_x64_Datacenter_EN_Eval';
            $testMediaFilename = 'test-media.iso';
            $configurationData = @{
                NonNodeData = @{
                    $labDefaults.ModuleName = @{
                        Media = @(
                            @{  Id = $testMediaId;
                                Filename = $testMediaFilename;
                                Architecture = 'x64';
                                MediaType = 'ISO';
                                Uri = 'http://testmedia.com/test-media.iso';
                                CustomData = @{ }; } ) } } }

            $labMedia = Resolve-LabMedia -Id $testMediaId -ConfigurationData $configurationData;

            $labMedia.Filename | Should Be $testMediaFilename;
        }

        It 'Returns default media if configuration data entry does not exist' {
            $testMediaId = '2016_x64_Datacenter_EN_Eval';
            $configurationData = @{
                NonNodeData = @{
                    $labDefaults.ModuleName = @{ } } }

            $labMedia = Resolve-LabMedia -Id $testMediaId -ConfigurationData $configurationData;

            $labMedia.Id | Should Be $testMediaId
            $labMedia.Filename | Should Not BeNullOrEmpty;
        }

    } #end InModuleScope

} #end describe
