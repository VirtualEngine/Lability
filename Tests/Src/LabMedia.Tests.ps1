#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'VirtualEngineLab';
if (!$PSScriptRoot) { # $PSScriptRoot is not defined in 2.0
    $PSScriptRoot = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
}
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;

Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'LabMedia' {
    
    InModuleScope $moduleName {

        Context 'Validates "NewLabMedia" method' {
            
            $newLabMediaParams = @{
                Id = 'Test-Media';
                Filename = 'Test-Media.iso';
                Architecture = 'x86';
                MediaType = 'ISO';
                Uri = 'http://testmedia.com/test-media.iso';
                #CustomData = @{ };
            }
        
            It 'Does not throw with valid mandatory parameters' {
                { NewLabMedia @newLabMediaParams } | Should Not Throw;
            }
        
            It 'Throws with an invalid Uri' {
                $testLabMediaParams = $newLabMediaParams.Clone();
                $testLabMediaParams['Uri'] = 'about:blank';
                { NewLabMedia @testLabMediaParams } | Should Throw;
            }
        
            foreach ($parameter in @('Id','Filename','Architecture','MediaType','Uri')) {
                It "Throws when ""$parameter"" parameter is missing" {
                    $testLabMediaParams = $newLabMediaParams.Clone();
                    $testLabMediaParams.Remove($parameter);
                    { NewLabMedia @testLabMediaParams } | Should Throw;
                }
            }
        
            
        
            It 'Returns "System.Management.Automation.PSCustomObject" object type' {
                $labMedia = NewLabMedia @newLabMediaParams;
                $labMedia -is [System.Management.Automation.PSCustomObject] | Should Be $true;
            }
        
            It 'Creates ProductKey custom entry when "ProductKey" is specified' {
                $testProductKey = 'ABCDE-12345-FGHIJ-67890-KLMNO';
                $labMedia = NewLabMedia @newLabMediaParams -ProductKey $testProductKey;
                $labMedia.CustomData.ProductKey | Should Be $testProductKey;
            }
        
        } #end context Validates "NewLabMedia" method
        
        Context 'Validates "ResolveLabMedia" method' {
        
            It 'Throws if media Id cannot be resolved' {
                $testMediaId = '2012R2_x64_Standard_EN_Eval';
                $testMediaFilename = 'test-media.iso';
                $builtinMediaFilename = '2012R2_x64_EN_Eval.iso';
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
                Mock ConvertToConfigurationData -MockWith { return $configurationData; }
        
                { ResolveLabMedia -Id NonExistentMediaId -ConfigurationData $configurationData } | Should Throw;
            }
        
            It 'Returns configuration data media entry if it exists' {
                $testMediaId = '2012R2_x64_Standard_EN_Eval';
                $testMediaFilename = 'test-media.iso';
                $builtinMediaFilename = '2012R2_x64_EN_Eval.iso';
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
                Mock ConvertToConfigurationData -MockWith { return $configurationData; }
        
                $labMedia = ResolveLabMedia -Id $testMediaId -ConfigurationData $configurationData;
        
                $labMedia.Filename | Should Be $testMediaFilename;
            }
        
            It 'Returns default media if configuration data entry does not exist' {
                $testMediaId = '2012R2_x64_Standard_EN_Eval';
                $testMediaFilename = 'test-media.iso';
                $builtinMediaFilename = '2012R2_x64_EN_Eval.iso';
                $configurationData = @{
                    NonNodeData = @{
                        $labDefaults.ModuleName = @{ Media = @( ) } } }
                Mock ConvertToConfigurationData -MockWith { return $configurationData; }
        
                $labMedia = ResolveLabMedia -Id $testMediaId -ConfigurationData $configurationData;
        
                $labMedia.Filename | Should Be $builtinMediaFilename;
            }
        
        } #end context Validates "ResolveLabMedia" method
        
        Context 'Validates "Get-LabMedia" method' {
        
            It 'Returns all built-in media when no "Id" is specified' {
                $labMedia = Get-LabMedia;
        
                $labMedia.Count -gt 1 | Should Be $true;
            }
        
            It 'Returns a single matching built-in media when "Id" is specified' {
                $testMediaId = '2012R2_x64_Standard_EN_Eval';
                $labMedia = Get-LabMedia -Id $testMediaId;
        
                $labMedia | Should Not BeNullOrEmpty;
                $labMedia.Count | Should BeNullOrEmpty;
            }
        
            It 'Returns null if no built-in media is found when "Id" is specified' {
                $labMedia = Get-LabMedia -Id 'NonExistentMediaId';
        
                $labMedia | Should BeNullOrEmpty;
            }
        
        } #end context Validates "Get-LabMedia" method
        
        Context 'Validates "Test-LabMedia" method' {
        
            It 'Passes when media ISO has been downloaded' {
                $testMediaId = '2012R2_x64_Standard_EN_Eval';
                $testHostIsoPath = 'TestDrive:';
                $testMediaFilename = 'test-media.iso';
                $fakeLabMedia = @{ Filename = $testMediaFilename; Uri = 'http//testmedia.com/test-media.iso'; Checksum = ''; }
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] @{ IsoPath = $testHostIsoPath; } }
                New-Item -Path "$testHostIsoPath\$testMediaFilename" -ItemType File -Force -ErrorAction SilentlyContinue;
                Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith { return [PSCustomObject] $fakeLabMedia; }
        
                Test-LabMedia -Id $testMediaId | Should Be $true;
            }
        
            It 'Fails when media ISO has not been downloaded' {
                $testMediaId = '2012R2_x64_Standard_EN_Eval';
                $testHostIsoPath = 'TestDrive:';
                $testMediaFilename = 'test-media.iso';
                $fakeLabMedia = @{ Filename = $testMediaFilename; Uri = 'http//testmedia.com/test-media.iso'; Checksum = ''; }
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] @{ IsoPath = $testHostIsoPath; } }
                Remove-Item -Path "$testHostIsoPath\$testMediaFilename" -Force -ErrorAction SilentlyContinue;
                Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith { return [PSCustomObject] $fakeLabMedia; }
        
                Test-LabMedia -Id $testMediaId | Should Be $false;
            }
        
            It 'Fails when media Id is not found' {
                $testMediaId = 'NonExistentMediaId';
                $testHostIsoPath = 'TestDrive:';
                $testMediaFilename = 'test-media.iso';
                $fakeLabMedia = @{ Filename = $testMediaFilename; Uri = 'http//testmedia.com/test-media.iso'; Checksum = ''; }
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] @{ IsoPath = $testHostIsoPath; } }
                Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith { }
        
                Test-LabMedia -Id $testMediaId | Should Be $false;
            }
        
        } #end context Validates "Test-LabMedia" method
        
        Context 'Validates "InvokeLabMediaImageDownload" method' {
        
            It 'Returns a "System.IO.FileInfo" object type' {
                $testMediaId = 'NonExistentMediaId';
                $testMediaType = 'ISO';
                $testMediaFilename = "$testMediaId.$testMediaType";
                $testHostIsoPath = 'TestDrive:\ISOs';
                $fakeConfigurationData = [PSCustomObject] @{ IsoPath = $testHostIsoPath; ParentVhdPath = $testHostParentVhdPath; }
                $fakeLabMedia = [PSCustomObject] @{ Filename = $testMediaFilename; Uri = "http://testmedia.com/$testMediaFilename"; Checksum = ''; MediaType = $testMediaType; }
                New-Item -Path "$testHostIsoPath\$testMediaFilename" -ItemType File -Force -ErrorAction SilentlyContinue;
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return $fakeConfigurationData; }
                Mock InvokeResourceDownload -MockWith { }
        
                $fileInfo = InvokeLabMediaImageDownload -Media $fakeLabMedia;;
                $fileInfo -is [System.IO.FileInfo] | Should Be $true;
            }
        
            It 'Calls "InvokeResourceDownload" with "ParentVhdPath" if media type is "VHD"' {
                $testMediaId = '2012R2_x64_Standard_EN_Eval';
                $testMediaFilename = "$testMediaId.vhdx";
                $testHostIsoPath = 'TestDrive:\ISOs';
                $testHostParentVhdPath = 'TestDrive:\ParentDisks';
                $testImagePath = "$testHostParentVhdPath\$testMediaFilename";
                New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
                $fakeConfigurationData = @{ IsoPath = $testHostIsoPath; ParentVhdPath = $testHostParentVhdPath; }
                $fakeLabMedia = @{ Id = $testMediaId; Filename = $testMediaFilename; Uri = "http://testmedia.com/$testMediaFilename"; Checksum = ''; MediaType = 'VHD'; }
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
                Mock InvokeResourceDownload -ParameterFilter { $DestinationPath -like $testImagePath } -MockWith { }
                Mock InvokeResourceDownload { Write-Host $Destinationpath -ForegroundColor Yellow }
        
                InvokeLabMediaImageDownload -Media $fakeLabMedia;
        
                Assert-MockCalled InvokeResourceDownload -ParameterFilter { $DestinationPath -like $testImagePath } -Scope It;
            }
        
            It 'Calls "InvokeResourceDownload" with "IsoPath" if media type is "ISO"' {
                $testMediaId = '2012R2_x64_Standard_EN_Eval';
                $testMediaFilename = "$testMediaId.iso";
                $testHostIsoPath = 'TestDrive:\ISOs';
                $testImagePath = "$testHostIsoPath\$testMediaFilename";
                New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
                $fakeConfigurationData = @{ IsoPath = $testHostIsoPath; ParentVhdPath = $testHostParentVhdPath; }
                $fakeLabMedia = @{ Id = $testMediaId; Filename = $testMediaFilename; Uri = "http://testmedia.com/$testMediaFilename"; Checksum = ''; MediaType = 'ISO'; }
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
                Mock InvokeResourceDownload -ParameterFilter { $DestinationPath -like $testImagePath } -MockWith { }
        
                InvokeLabMediaImageDownload -Media $fakeLabMedia;
        
                Assert-MockCalled InvokeResourceDownload -ParameterFilter { $DestinationPath -like $testImagePath } -Scope It;
            }

            It 'Calls "InvokeResourceDownload" with "IsoPath" if media type is "WIM"' {
                $testMediaId = '2012R2_x64_Standard_EN_Eval';
                $testMediaFilename = "$testMediaId.wim";
                $testHostIsoPath = 'TestDrive:\ISOs';
                $testImagePath = "$testHostIsoPath\$testMediaFilename";
                New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
                $fakeConfigurationData = @{ IsoPath = $testHostIsoPath; ParentVhdPath = $testHostParentVhdPath; }
                $fakeLabMedia = @{ Id = $testMediaId; Filename = $testMediaFilename; Uri = "http://testmedia.com/$testMediaFilename"; Checksum = ''; MediaType = 'WIM'; }
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
                Mock InvokeResourceDownload -ParameterFilter { $DestinationPath -like $testImagePath } -MockWith { }
        
                InvokeLabMediaImageDownload -Media $fakeLabMedia;
        
                Assert-MockCalled InvokeResourceDownload -ParameterFilter { $DestinationPath -like $testImagePath } -Scope It;
            }
        
            It 'Calls "InvokeResourceDownload" with "Force" parameter when specified' {
                $testMediaId = '2012R2_x64_Standard_EN_Eval';
                $testMediaFilename = "$testMediaId.iso";
                $testHostIsoPath = 'TestDrive:\ISOs';
                $testImagePath = "$testHostIsoPath\$testMediaFilename";
                New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
                $fakeConfigurationData = @{ IsoPath = $testHostIsoPath; ParentVhdPath = $testHostParentVhdPath; }
                $fakeLabMedia = @{ Id = $testMediaId; Filename = $testMediaFilename; Uri = "http://testmedia.com/$testMediaFilename"; Checksum = ''; MediaType = 'ISO'; }
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
                Mock InvokeResourceDownload -ParameterFilter { $Force -eq $true } -MockWith { }
        
                InvokeLabMediaImageDownload -Media $fakeLabMedia -Force;
        
                Assert-MockCalled InvokeResourceDownload -ParameterFilter { $Force -eq $true } -Scope It;
            }
        
            It 'Calls "InvokeResourceDownload" with large "BufferSize" for file Uris' {
                $testMediaId = '2012R2_x64_Standard_EN_Eval';
                $testMediaFilename = "$testMediaId.wim";
                $testHostIsoPath = 'TestDrive:\ISOs';
                $testImagePath = "$testHostIsoPath\$testMediaFilename";
                New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
                $fakeConfigurationData = @{ IsoPath = $testHostIsoPath; ParentVhdPath = $testHostParentVhdPath; }
                $fakeLabMedia = @{ Id = $testMediaId; Filename = $testMediaFilename; Uri = "file://testmedia.com/$testMediaFilename"; Checksum = ''; MediaType = 'WIM'; }
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
                Mock InvokeResourceDownload -ParameterFilter { $BufferSize -gt 64KB } -MockWith { }
        
                InvokeLabMediaImageDownload -Media $fakeLabMedia;
        
                Assert-MockCalled InvokeResourceDownload -ParameterFilter { $BufferSize -gt 64KB } -Scope It;
            }

            It 'Does not call "InvokeResourceDownload" when "DisableLocalFileCaching" is enabled' {
                $testMediaId = '2012R2_x64_Standard_EN_Eval';
                $testMediaFilename = "$testMediaId.wim";
                $testHostIsoPath = 'TestDrive:\ISOs';
                $testImagePath = "$testHostIsoPath\$testMediaFilename";
                New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
                $fakeConfigurationData = @{ IsoPath = $testHostIsoPath; DisableLocalFileCaching = $true; }
                $fakeLabMedia = @{ Id = $testMediaId; Filename = $testMediaFilename; Uri = "file://testmedia.com/$testMediaFilename"; Checksum = ''; MediaType = 'WIM'; }
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
                Mock InvokeResourceDownload -MockWith { }
        
                InvokeLabMediaImageDownload -Media $fakeLabMedia;
        
                Assert-MockCalled InvokeResourceDownload -Scope It -Exactly 0;
            }
        
        } #end context Validates "InvokeLabMediaImageDownload" method
        
        Context 'Validates "InvokeLabMediaHotfixDownload" method' {
        
            It 'Returns a "System.IO.FileInfo" object type' {
                $testHotfixId = 'Windows11-KB1234567.msu';
                $testHotfixUri = "http://testhotfix.com/$testHotfixId";
                $testHotfixPath = 'TestDrive:\Hotfix';
                $testHotfixFilename = "$testHotfixPath\$testHotfixId";
                New-Item -Path $testHotfixFilename -ItemType File -Force -ErrorAction SilentlyContinue;
                $fakeConfigurationData = @{ HotfixPath = $testHotfixPath;}
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
                Mock InvokeResourceDownload -ParameterFilter { $DestinationPath -eq $testHotfixFilename } -MockWith { }
        
                $hotfix = InvokeLabMediaHotfixDownload -Id $testHotfixId -Uri $testHotfixUri;
                $hotfix -is [System.IO.FileInfo] | Should Be $true;
            }
        
            It 'Calls "InvokeResourceDownload" with "Checksum" parameter when specified' {
                $testHotfixId = 'Windows11-KB1234567.msu';
                $testHotfixUri = "http://testhotfix.com/$testHotfixId";
                $testHotfixChecksum = 'ABCDEF1234567890';
                $testHotfixPath = 'TestDrive:\Hotfix';
                $testHotfixFilename = "$testHotfixPath\$testHotfixId";
                New-Item -Path $testHotfixFilename -ItemType File -Force -ErrorAction SilentlyContinue;
                $fakeConfigurationData = @{ HotfixPath = $testHotfixPath;}
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
                Mock InvokeResourceDownload -ParameterFilter { $Checksum -eq $testHotfixChecksum } -MockWith { }
        
                InvokeLabMediaHotfixDownload -Id $testHotfixId -Uri $testHotfixUri -Checksum $testHotfixChecksum;
        
                Assert-MockCalled InvokeResourceDownload -ParameterFilter { $Checksum -eq $testHotfixChecksum } -Scope It;
            }
        
            It 'Calls "InvokeResourceDownload" with "Force" parameter when specified' {
                $testHotfixId = 'Windows11-KB1234567.msu';
                $testHotfixUri = "http://testhotfix.com/$testHotfixId";
                $testHotfixPath = 'TestDrive:\Hotfix';
                $testHotfixFilename = "$testHotfixPath\$testHotfixId";
                New-Item -Path $testHotfixFilename -ItemType File -Force -ErrorAction SilentlyContinue;
                $fakeConfigurationData = @{ HotfixPath = $testHotfixPath;}
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
                Mock InvokeResourceDownload -ParameterFilter { $Force -eq $true } -MockWith { }
        
                InvokeLabMediaHotfixDownload -Id $testHotfixId -Uri $testHotfixUri -Force;
        
                Assert-MockCalled InvokeResourceDownload -ParameterFilter { $Force -eq $true } -Scope It;
            }
        
        } #end context Validates "InvokeLabMediaHotfixDownload" method
        
        Context 'Validates "Register-LabMedia" method' {
        
            $testMediaParams = @{
                Id = 'TestId';
                Uri = 'http://contoso.com/testmedia';
                Architecture = 'x64';
            }
            $testCustomMedia = @(
                [PSObject] $testMediaParams,
                [PSObject] @{ Id = 'TestId2'; Uri = 'http://contoso.com/testmedia'; Architecture = 'x64'; }
            )
        
            It 'Throws when custom media type is "ISO" and "ImageName" is not specified' {
                { Register-LabMedia @testMediaParams -MediaType ISO } | Should Throw;
            }
            
            It 'Throws when custom media type is "WIM" and "ImageName" is not specified' {
                { Register-LabMedia @testMediaParams -MediaType WIM } | Should Throw;
            }
            
            It 'Throws when custom media already exists and "Force" is not specified' {
                Mock ResolveLabMedia { return $testCustomMedia[0]; }
                
                { Register-LabMedia @testMediaParams -MediaType VHD -WarningAction SilentlyContinue } | Should Throw;
            }
        
            It 'Does not throw when custom media type is "VHD" and "ImageName" is not specified' {
                Mock ResolveLabMedia { }
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'CustomMedia' } -MockWith { };
                Mock SetConfigurationData { }
                
                { Register-LabMedia @testMediaParams -MediaType VHD -WarningAction SilentlyContinue } | Should Not Throw;
            }
        
            It 'Does not throw when custom media already exists and "Force" is specified' {
                Mock ResolveLabMedia { return $testCustomMedia[0]; }
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'CustomMedia' } -MockWith { return $testCustomMedia; };
                Mock SetConfigurationData { }
                
                { Register-LabMedia @testMediaParams -MediaType VHD -Force -WarningAction SilentlyContinue } | Should Not Throw;
            }
        
        } #end context Validates "Register-LabMedia" method

        Context 'Validates "Unregister-LabMedia" method' {
            $testMediaId = 'TestId';
            $testCustomMedia = @(
                [PSObject] @{ Id = $testMediaId; Uri = 'http://contoso.com/testmedia'; Architecture = 'x64'; }
                [PSObject] @{ Id = 'TestId2'; Uri = 'http://contoso.com/testmedia'; Architecture = 'x64'; }
            )

            It "Removes existing custom media entry when 'Id' does exist" {
                
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'CustomMedia' } -MockWith { return $testCustomMedia; };
                Mock SetConfigurationData { }

                Unregister-LabMedia -Id $testMediaId -WarningAction SilentlyContinue;
                
                Assert-MockCalled SetConfigurationData -ParameterFilter { $InputObject.Count -eq ($testCustomMedia.Count -1) } -Scope It;

            }

            It "Does not remove any entries when custom media 'Id' doesn't exist" {
                
                Mock GetConfigurationData -ParameterFilter { $Configuration -eq 'CustomMedia' } -MockWith { return $testCustomMedia; };
                Mock SetConfigurationData { }

                Unregister-LabMedia -Id 'Non-existent' -WarningAction SilentlyContinue;
                
                Assert-MockCalled SetConfigurationData -Scope It -Exactly 0;
            }

        } #end context Validates "Unregister-LabMedia" method
            
    } #end InModuleScope

} #end describe LabMedia
