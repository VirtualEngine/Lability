#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Invoke-LabMediaImageDownload' {

    InModuleScope -ModuleName $moduleName {

        It 'Returns a "System.IO.FileInfo" object type' {
            $testMediaId = 'NonExistentMediaId';
            $testMediaType = 'ISO';
            $testMediaFilename = "$testMediaId.$testMediaType";
            $testHostIsoPath = 'TestDrive:\ISOs';
            $fakeConfigurationData = [PSCustomObject] @{ IsoPath = $testHostIsoPath; ParentVhdPath = $testHostParentVhdPath; }
            $fakeLabMedia = [PSCustomObject] @{ Filename = $testMediaFilename; Uri = "http://testmedia.com/$testMediaFilename"; Checksum = ''; MediaType = $testMediaType; }
            New-Item -Path "$testHostIsoPath\$testMediaFilename" -ItemType File -Force -ErrorAction SilentlyContinue;
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return $fakeConfigurationData; }
            Mock Invoke-ResourceDownload -MockWith { }

            $fileInfo = Invoke-LabMediaImageDownload -Media $fakeLabMedia;

            $fileInfo -is [System.IO.FileInfo] | Should Be $true;
        }

        It 'Calls "Invoke-ResourceDownload" with "ParentVhdPath" if media type is "VHD"' {
            $testMediaId = '2016_x64_Datacenter_EN_Eval';
            $testMediaFilename = "$testMediaId.vhdx";
            $testHostIsoPath = 'TestDrive:\ISOs';
            $testHostParentVhdPath = 'TestDrive:\ParentDisks';
            $testImagePath = "$testHostParentVhdPath\$testMediaFilename";
            New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
            $fakeConfigurationData = @{ IsoPath = $testHostIsoPath; ParentVhdPath = $testHostParentVhdPath; }
            $fakeLabMedia = @{ Id = $testMediaId; Filename = $testMediaFilename; Uri = "http://testmedia.com/$testMediaFilename"; Checksum = ''; MediaType = 'VHD'; }
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
            Mock Invoke-ResourceDownload -ParameterFilter { $DestinationPath -like $testImagePath } -MockWith { }
            Mock Invoke-ResourceDownload { }

            Invoke-LabMediaImageDownload -Media $fakeLabMedia;

            Assert-MockCalled Invoke-ResourceDownload -ParameterFilter { $DestinationPath -like $testImagePath } -Scope It;
        }

        It 'Calls "Invoke-ResourceDownload" with "IsoPath" if media type is "ISO"' {
            $testMediaId = '2016_x64_Datacenter_EN_Eval';
            $testMediaFilename = "$testMediaId.iso";
            $testHostIsoPath = 'TestDrive:\ISOs';
            $testImagePath = "$testHostIsoPath\$testMediaFilename";
            New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
            $fakeConfigurationData = @{ IsoPath = $testHostIsoPath; ParentVhdPath = $testHostParentVhdPath; }
            $fakeLabMedia = @{ Id = $testMediaId; Filename = $testMediaFilename; Uri = "http://testmedia.com/$testMediaFilename"; Checksum = ''; MediaType = 'ISO'; }
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
            Mock Invoke-ResourceDownload -ParameterFilter { $DestinationPath -like $testImagePath } -MockWith { }

            Invoke-LabMediaImageDownload -Media $fakeLabMedia;

            Assert-MockCalled Invoke-ResourceDownload -ParameterFilter { $DestinationPath -like $testImagePath } -Scope It;
        }

        It 'Calls "Invoke-ResourceDownload" with "IsoPath" if media type is "WIM"' {
            $testMediaId = '2016_x64_Datacenter_EN_Eval';
            $testMediaFilename = "$testMediaId.wim";
            $testHostIsoPath = 'TestDrive:\ISOs';
            $testImagePath = "$testHostIsoPath\$testMediaFilename";
            New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
            $fakeConfigurationData = @{ IsoPath = $testHostIsoPath; ParentVhdPath = $testHostParentVhdPath; }
            $fakeLabMedia = @{ Id = $testMediaId; Filename = $testMediaFilename; Uri = "http://testmedia.com/$testMediaFilename"; Checksum = ''; MediaType = 'WIM'; }
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
            Mock Invoke-ResourceDownload -ParameterFilter { $DestinationPath -like $testImagePath } -MockWith { }

            Invoke-LabMediaImageDownload -Media $fakeLabMedia;

            Assert-MockCalled Invoke-ResourceDownload -ParameterFilter { $DestinationPath -like $testImagePath } -Scope It;
        }

        It 'Calls "Invoke-ResourceDownload" with "Force" parameter when specified' {
            $testMediaId = '2016_x64_Datacenter_EN_Eval';
            $testMediaFilename = "$testMediaId.iso";
            $testHostIsoPath = 'TestDrive:\ISOs';
            $testImagePath = "$testHostIsoPath\$testMediaFilename";
            New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
            $fakeConfigurationData = @{ IsoPath = $testHostIsoPath; ParentVhdPath = $testHostParentVhdPath; }
            $fakeLabMedia = @{ Id = $testMediaId; Filename = $testMediaFilename; Uri = "http://testmedia.com/$testMediaFilename"; Checksum = ''; MediaType = 'ISO'; }
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
            Mock Invoke-ResourceDownload -ParameterFilter { $Force -eq $true } -MockWith { }

            Invoke-LabMediaImageDownload -Media $fakeLabMedia -Force;

            Assert-MockCalled Invoke-ResourceDownload -ParameterFilter { $Force -eq $true } -Scope It;
        }

        It 'Calls "Invoke-ResourceDownload" with large "BufferSize" for file Uris' {
            $testMediaId = '2016_x64_Datacenter_EN_Eval';
            $testMediaFilename = "$testMediaId.wim";
            $testHostIsoPath = 'TestDrive:\ISOs';
            $testImagePath = "$testHostIsoPath\$testMediaFilename";
            New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
            $fakeConfigurationData = @{ IsoPath = $testHostIsoPath; ParentVhdPath = $testHostParentVhdPath; }
            $fakeLabMedia = @{ Id = $testMediaId; Filename = $testMediaFilename; Uri = "file://testmedia.com/$testMediaFilename"; Checksum = ''; MediaType = 'WIM'; }
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
            Mock Invoke-ResourceDownload -ParameterFilter { $BufferSize -gt 64KB } -MockWith { }

            Invoke-LabMediaImageDownload -Media $fakeLabMedia;

            Assert-MockCalled Invoke-ResourceDownload -ParameterFilter { $BufferSize -gt 64KB } -Scope It;
        }

        It 'Does not call "Invoke-ResourceDownload" when "DisableLocalFileCaching" is enabled' {
            $testMediaId = '2016_x64_Datacenter_EN_Eval';
            $testMediaFilename = "$testMediaId.wim";
            $testHostIsoPath = '{0}\ISOs' -f (Get-PSDrive -Name TestDrive).Root
            $testImagePath = "$testHostIsoPath\$testMediaFilename";
            New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
            $fakeConfigurationData = @{ IsoPath = $testHostIsoPath; DisableLocalFileCaching = $true; }
            $fakeLabMedia = @{ Id = $testMediaId; Filename = $testMediaFilename; Uri = "file://$testImagePath"; Checksum = ''; MediaType = 'WIM'; }
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
            Mock Invoke-ResourceDownload -MockWith { }

            Invoke-LabMediaImageDownload -Media $fakeLabMedia;

            Assert-MockCalled Invoke-ResourceDownload -Scope It -Exactly 0;
        }

        It 'Returns source Uri when "DisableLocalFileCaching" is enabled' {
            $testMediaId = '2016_x64_Datacenter_EN_Eval';
            $testMediaFilename = "$testMediaId.wim";
            $testHostIsoPath = '{0}\ISOs' -f (Get-PSDrive -Name TestDrive).Root
            $testImagePath = "$testHostIsoPath\$testMediaFilename";
            New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
            $fakeConfigurationData = @{ IsoPath = $testHostIsoPath; DisableLocalFileCaching = $true; }
            $fakeLabMedia = @{ Id = $testMediaId; Filename = $testMediaFilename; Uri = "file://$testImagePath"; Checksum = ''; MediaType = 'WIM'; }
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }

            $media = Invoke-LabMediaImageDownload -Media $fakeLabMedia;

            $media.FullName | Should Be $testImagePath;
        }

    } #end InModuleScope

} #end describe
