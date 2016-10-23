#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psd1") -Force;

Describe 'Src\LabImage' {

    InModuleScope $moduleName {

        Context 'Validates "Get-LabImage" method' {

            It 'Returns null when there is no parent image when Id specified' {
                $fakeConfigurationData = @{ ParentVhdPath = ResolvePathEx -Path 'TestDrive:\'; }
                $fakeDiskImage = [PSCustomObject] @{ Attached = $true; BaseName = 'x'; ImagePath = $ImagePath; LogicalSectorSize = 42; BlockSize = 42; Size = 42; }
                $fakeLabMediaId1 = 'IMG1';
                $fakeLabMediaId2 = 'IMG2';
                $fakeLabMedia = @(
                    [PSCustomObject] @{ Id = $fakeLabMediaId1; Filename = "$fakeLabMediaId1.vhdx"; MediaType = 'VHD'; }
                    [PSCustomObject] @{ Id = $fakeLabMediaId2; Filename = "$fakeLabMediaId2.vhdx"; MediaType = 'VHD'; }
                )
                foreach ($media in $fakeLabMedia) {
                    New-Item -Path "TestDrive:\$($media.Id).vhdx" -ItemType File -Force -ErrorAction SilentlyContinue;
                }
                Mock GetConfigurationData -MockWith { return $fakeConfigurationData; }
                Mock Get-DiskImage -MockWith { return $fakeDiskImage; }

                $images = Get-LabImage -Id 'NonExistentId';

                $images | Should BeNullOrEmpty;
            }

            It 'Returns null when there is are no parent images' {
                $fakeConfigurationData = @{ ParentVhdPath = ResolvePathEx -Path 'TestDrive:\EmptyPath'; }
                New-Item -Path 'TestDrive:\EmptyPath' -ItemType Directory -Force -ErrorAction SilentlyContinue;
                Mock GetConfigurationData -MockWith { return $fakeConfigurationData; }
                Mock Get-LabMedia -MockWith { return $fakeLabMedia; }
                Mock Get-DiskImage -MockWith { }

                $images = Get-LabImage;

                $images | Should BeNullOrEmpty;
            }

            It 'Returns all available parent images when no Id is specified' {
                $fakeConfigurationData = @{ ParentVhdPath = ResolvePathEx -Path 'TestDrive:\'; }
                $fakeDiskImage = [PSCustomObject] @{ Attached = $true; BaseName = 'x'; ImagePath = $ImagePath; LogicalSectorSize = 42; BlockSize = 42; Size = 42; }
                $fakeLabMediaId1 = 'IMG1';
                $fakeLabMediaId2 = 'IMG2';
                $fakeLabMedia = @(
                    [PSCustomObject] @{ Id = $fakeLabMediaId1; Filename = "$fakeLabMediaId1.vhdx"; MediaType = 'VHD'; }
                    [PSCustomObject] @{ Id = $fakeLabMediaId2; Filename = "$fakeLabMediaId2.vhdx"; MediaType = 'VHD'; }
                )
                foreach ($media in $fakeLabMedia) {
                    New-Item -Path "TestDrive:\$($media.Id).vhdx" -ItemType File -Force -ErrorAction SilentlyContinue;
                }
                Mock GetConfigurationData -MockWith { return $fakeConfigurationData; }
                Mock Get-LabMedia -MockWith { return $fakeLabMedia; }
                Mock Get-DiskImage -MockWith { return $fakeDiskImage; }

                $images = Get-LabImage;

                $images.Count | Should Be $fakeLabMedia.Count;
            }

            It 'Returns a single parent image when Id specified' {
                $fakeConfigurationData = @{ ParentVhdPath = ResolvePathEx -Path 'TestDrive:\'; }
                $fakeDiskImage = [PSCustomObject] @{ Attached = $true; BaseName = 'x'; ImagePath = $ImagePath; LogicalSectorSize = 42; BlockSize = 42; Size = 42; }
                $fakeLabMediaId1 = 'IMG1';
                $fakeLabMediaId2 = 'IMG2';
                $fakeLabMedia = @(
                    [PSCustomObject] @{ Id = $fakeLabMediaId1; Filename = "$fakeLabMediaId1.vhdx"; MediaType = 'VHD'; }
                    [PSCustomObject] @{ Id = $fakeLabMediaId2; Filename = "$fakeLabMediaId2.vhdx"; MediaType = 'VHD'; }
                )
                foreach ($media in $fakeLabMedia) {
                    New-Item -Path "TestDrive:\$($media.Id).vhdx" -ItemType File -Force -ErrorAction SilentlyContinue;
                }
                Mock GetConfigurationData -MockWith { return $fakeConfigurationData; }
                Mock Get-LabMedia -ParameterFilter { $Id -eq $fakeLabMediaId1 } -MockWith { return $fakeLabMedia[0]; }
                Mock Get-DiskImage -MockWith { return $fakeDiskImage; }

                $image = Get-LabImage -Id $fakeLabMediaId1;

                $image | Should Not BeNullOrEmpty;
                $image.Count | Should BeNullOrEmpty;
            }

            foreach ($generation in 'VHD','VHDX') {
                It "Returns image generation '$generation' for $generation file" {
                    $testLabMediaId = 'IMG1';
                    $testImageGeneration = $generation;
                    $testDiskImageFileName = '{0}.{1}' -f $testLabMediaId, $testImageGeneration;
                    $testDiskImagePath = 'TestDrive:\{0}' -f $testDiskImageFileName;
                    $fakeConfigurationData = @{ ParentVhdPath = ResolvePathEx -Path 'TestDrive:\'; }
                    $fakeLabMedia = @(
                        [PSCustomObject] @{ Id = $testLabMediaId; Filename = $testDiskImageFileName; MediaType = $testImageGeneration; }
                    )
                    $fakeDiskImage = [PSCustomObject] @{ Attached = $true; BaseName = 'x'; ImagePath = $ImagePath; LogicalSectorSize = 42; BlockSize = 42; Size = 42; }
                    New-Item -Path $testDiskImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
                    Mock GetConfigurationData -MockWith { return $fakeConfigurationData; }
                    Mock Get-LabMedia -MockWith { return $fakeLabMedia; }
                    Mock Get-DiskImage -MockWith { return $fakeDiskImage; }

                    $image = Get-LabImage -Id $testLabMediaId;

                    $image.Generation | Should Be $testImageGeneration;
                }
            }

        } #end context Validates "Get-LabImage" method

        Context 'Validates "Test-LabImage" method' {

            It 'Passes when parent image is found' {
                $testImageId = '42';
                Mock Get-LabImage -ParameterFilter { $Id -eq $testImageId } -MockWith { return $true; }

                Test-LabImage -Id $testImageId | Should Be $true;
            }

            It 'Fails when parent image is not found' {
                $testImageId = '42';
                Mock Get-LabImage -ParameterFilter { $Id -eq $testImageId } -MockWith { return $false; }

                Test-LabImage -Id $testImageId | Should Be $false;
            }

            It 'Calls "Get-LabImage" with "ConfigurationData" when specified (#97)' {
                $testImageId = '42';
                Mock Get-LabImage -ParameterFilter { $null -ne $ConfigurationData } -MockWith { }

                Test-LabImage -Id $testImageId -ConfigurationData @{};

                Assert-MockCalled Get-LabImage -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
            }

        } #end context 'Validates "Test-LabImage" method

        Context 'Validates "New-LabImage" method' {

            It 'Throws if image already exists' {
                $testImageId = '42';

                Mock Test-LabImage -MockWith { return $true; }

                { New-LabImage -Id $testImageId } | Should Throw;
            }

            It 'Throws when no "ImageName" is defined (#148)' {

                $testImageId = '2012R2_x64_Datacenter_EN_VL';
                $testParentImagePath = 'TestDrive:'
                $testImagePath = ResolvePathEx -Path "$testParentImagePath\$testImageId.vhdx";
                $testArchitecture = 'x64';
                $testWimImageName = 'Fake windows image';
                $fakeISOFileInfo = [PSCustomObject] @{ FullName = 'TestDrive:\TestIso.iso'; }
                $testCustomWimPath = '\custom\install.wim';

                $testMedia = @{
                    Id = $testImageId;
                    Filename = '2012R2_x64_EN_VL.iso';
                    Architecture = 'x64';
                    Uri = 'file://C:\Users\Public\Documents\Downloads\en_windows_server_2012_R2_refresh_x64.ISO';
                    Checksum = '';
                    Description = 'Windows Server 2012 R2 Datacenter 64bit English Volume License';
                    MediaType = 'ISO';
                    OperatingSystem = 'Windows';
                }

                $fakeDiskImage = [PSCustomObject] @{ Attached = $true; BaseName = 'x'; ImagePath = $testImagePath; LogicalSectorSize = 42; BlockSize = 42; Size = 42; }
                $fakeVhdImage = [PSCustomObject] @{ Path = $testImagePath };
                $fakeConfigurationData = @{ ParentVhdPath = ResolvePathEx -Path $testParentImagePath; }
                New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
                Mock Test-LabImage -MockWith { return $false; }
                Mock Get-DiskImage -MockWith { return $fakeDiskImage; }
                Mock GetConfigurationData -MockWith { return $fakeConfigurationData; }
                Mock ResolveLabMedia -MockWith { return $testMedia; }
                Mock AddDiskImageHotfix -MockWith { }
                Mock SetDiskImageBootVolume -MockWith { }
                Mock Dismount-VHD -MockWith { }
                Mock InvokeLabMediaImageDownload -MockWith { return $fakeISOFileInfo; }
                Mock NewDiskImage -MockWith { return $fakeVhdImage; }
                Mock ExpandWindowsImage -ParameterFilter { $WimPath -eq $testCustomWimPath } -MockWith { }

                $customMediaConfigurationData = @{
                    NonNodeData = @{
                        Lability = @{
                            Media = @($testMedia)
                        }
                    }
                }

                $newLabImageParams = @{
                    Id = $testImageId;
                    ConfigurationData = $customMediaConfigurationData;
                    WarningAction = 'SilentlyContinue';
                }
                { New-LabImage @newLabImageParams } | Should Throw 'An image name is required for ISO and WIM media';

            }

            It 'Deletes parent VHDX when image creation fails' {
                $testImageId = 'NewLabImage';
                $testParentImagePath = 'TestDrive:'
                $testImagePath = ResolvePathEx -Path "$testParentImagePath\$testImageId.vhdx";
                $testArchitecture = 'x64';
                $testWimImageName = 'Fake windows image';
                $fakeISOFileInfo = [PSCustomObject] @{ FullName = 'TestDrive:\TestIso.iso'; }
                $fakeMedia = [PSCustomObject] @{ Id = $testImageId; Description = 'Fake media'; Architecture = $testArchitecture; ImageName = $testWimImageName; }
                $fakeDiskImage = [PSCustomObject] @{ Attached = $true; BaseName = 'x'; ImagePath = $testImagePath; LogicalSectorSize = 42; BlockSize = 42; Size = 42; }
                $fakeVhdImage = [PSCustomObject] @{ Path = $testImagePath };
                $fakeConfigurationData = @{ ParentVhdPath = ResolvePathEx -Path $testParentImagePath; }
                New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
                Mock Test-LabImage -MockWith { return $false; }
                Mock Get-DiskImage -MockWith { return $fakeDiskImage; }
                Mock GetConfigurationData -MockWith { return $fakeConfigurationData; }
                Mock ResolveLabMedia -MockWith { return $fakeMedia; }
                Mock NewDiskImage -MockWith { Write-Error 'DOH!'; }
                Mock ExpandWindowsImage -MockWith { }
                Mock AddDiskImageHotfix -MockWith { }
                Mock SetDiskImageBootVolume -MockWith { }
                Mock Dismount-VHD -MockWith { }
                Mock InvokeLabMediaImageDownload -MockWith { return $fakeISOFileInfo; }

                New-LabImage -Id $testImageId -ErrorAction SilentlyContinue -WarningAction SilentlyContinue;

                Test-Path -Path $testImagePath | Should Be $false;
            }

            It 'Deletes existing image if it already exists and -Force is specified' {
                $testImageId = 'NewLabImage';
                $testParentImagePath = 'TestDrive:'
                $testImagePath = ResolvePathEx -Path "$testParentImagePath\$testImageId.vhdx";
                $testArchitecture = 'x64';
                $testWimImageName = 'Fake windows image';
                $fakeISOFileInfo = [PSCustomObject] @{ FullName = 'TestDrive:\TestIso.iso'; }
                $fakeMedia = [PSCustomObject] @{ Id = $testImageId; Description = 'Fake media'; Architecture = $testArchitecture; ImageName = $testWimImageName; }
                $fakeDiskImage = [PSCustomObject] @{ Attached = $true; BaseName = 'x'; ImagePath = $testImagePath; LogicalSectorSize = 42; BlockSize = 42; Size = 42; }
                $fakeVhdImage = [PSCustomObject] @{ Path = $testImagePath };
                $fakeLabImage = [PSCustomObject] @{ Id = $testImageId; ImagePath = $testImagePath; }
                $fakeConfigurationData = @{ ParentVhdPath = ResolvePathEx -Path $testParentImagePath; }
                New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
                Mock Test-LabImage -MockWith { return $true; }
                Mock Get-LabImage -MockWith { return $fakeLabImage; }
                Mock GetConfigurationData -MockWith { return $fakeConfigurationData; }
                Mock ResolveLabMedia -MockWith { return $fakeMedia; }
                Mock NewDiskImage -MockWith { return $fakeVhdImage; }
                Mock ExpandWindowsImage -MockWith { }
                Mock AddDiskImageHotfix -MockWith { }
                Mock SetDiskImageBootVolume -MockWith { }
                Mock Dismount-VHD -MockWith { }
                Mock InvokeLabMediaImageDownload -MockWith { return $fakeISOFileInfo; }

                New-LabImage -Id $testImageId -Force;

                Test-Path -Path $testImagePath | Should Be $false;
            }

            It 'Calls "InvokeLabMediaImageDownload" to download ISO media (if not present)' {
                $testImageId = 'NewLabImage';
                $testParentImagePath = 'TestDrive:'
                $testImagePath = ResolvePathEx -Path "$testParentImagePath\$testImageId.vhdx";
                $testArchitecture = 'x64';
                $testWimImageName = 'Fake windows image';
                $fakeISOFileInfo = [PSCustomObject] @{ FullName = 'TestDrive:\TestIso.iso'; }
                $fakeMedia = [PSCustomObject] @{ Id = $testImageId; Description = 'Fake media'; Architecture = $testArchitecture; ImageName = $testWimImageName; }
                $fakeDiskImage = [PSCustomObject] @{ Attached = $true; BaseName = 'x'; ImagePath = $testImagePath; LogicalSectorSize = 42; BlockSize = 42; Size = 42; }
                $fakeVhdImage = [PSCustomObject] @{ Path = $testImagePath };
                $fakeConfigurationData = @{ ParentVhdPath = ResolvePathEx -Path $testParentImagePath; }
                New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
                Mock Test-LabImage -MockWith { return $false; }
                Mock Get-DiskImage -MockWith { return $fakeDiskImage; }
                Mock GetConfigurationData -MockWith { return $fakeConfigurationData; }
                Mock ResolveLabMedia -MockWith { return $fakeMedia; }
                Mock NewDiskImage -MockWith { return $fakeVhdImage; }
                Mock ExpandWindowsImage -MockWith { }
                Mock AddDiskImageHotfix -MockWith { }
                Mock SetDiskImageBootVolume -MockWith { }
                Mock Dismount-VHD -MockWith { }
                Mock InvokeLabMediaImageDownload -ParameterFilter { $Media.Id -eq $testImageId } -MockWith { return $fakeISOFileInfo; }

                New-LabImage -Id $testImageId

                Assert-MockCalled InvokeLabMediaImageDownload -ParameterFilter { $Media.Id -eq $testImageId } -Scope It;
            }

            It 'Calls "NewDiskImage" with -PassThru to leave VHDX mounted' {
                $testImageId = 'NewLabImage';
                $testParentImagePath = 'TestDrive:'
                $testImagePath = ResolvePathEx -Path "$testParentImagePath\$testImageId.vhdx";
                $testArchitecture = 'x64';
                $testWimImageName = 'Fake windows image';
                $fakeISOFileInfo = [PSCustomObject] @{ FullName = 'TestDrive:\TestIso.iso'; }
                $fakeMedia = [PSCustomObject] @{ Id = $testImageId; Description = 'Fake media'; Architecture = $testArchitecture; ImageName = $testWimImageName; }
                $fakeDiskImage = [PSCustomObject] @{ Attached = $true; BaseName = 'x'; ImagePath = $testImagePath; LogicalSectorSize = 42; BlockSize = 42; Size = 42; }
                $fakeVhdImage = [PSCustomObject] @{ Path = $testImagePath };
                $fakeConfigurationData = @{ ParentVhdPath = ResolvePathEx -Path $testParentImagePath; }
                $fakeConfigurationData = @{ ParentVhdPath = ResolvePathEx -Path $testImagePath; }
                New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
                Mock Test-LabImage -MockWith { return $false; }
                Mock Get-DiskImage -MockWith { return $fakeDiskImage; }
                Mock GetConfigurationData -MockWith { return $fakeConfigurationData; }
                Mock ResolveLabMedia -MockWith { return $fakeMedia; }
                Mock ExpandWindowsImage -MockWith { }
                Mock AddDiskImageHotfix -MockWith { }
                Mock SetDiskImageBootVolume -MockWith { }
                Mock Dismount-VHD -MockWith { }
                Mock InvokeLabMediaImageDownload -MockWith { return $fakeISOFileInfo; }
                Mock NewDiskImage -MockWith { return $fakeVhdImage; }

                New-LabImage -Id $testImageId

                Assert-MockCalled NewDiskImage -ParameterFilter { $PassThru -eq $true } -Scope It;
            }

            It 'Uses "GPT" partition style for x64 media' {
                $testImageId = 'NewLabImage';
                $testParentImagePath = 'TestDrive:'
                $testImagePath = ResolvePathEx -Path "$testParentImagePath\$testImageId.vhdx";
                $testArchitecture = 'x64';
                $testWimImageName = 'Fake windows image';
                $fakeISOFileInfo = [PSCustomObject] @{ FullName = 'TestDrive:\TestIso.iso'; }
                $fakeMedia = [PSCustomObject] @{ Id = $testImageId; Description = 'Fake media'; Architecture = $testArchitecture; ImageName = $testWimImageName; }
                $fakeDiskImage = [PSCustomObject] @{ Attached = $true; BaseName = 'x'; ImagePath = $testImagePath; LogicalSectorSize = 42; BlockSize = 42; Size = 42; }
                $fakeVhdImage = [PSCustomObject] @{ Path = $testImagePath };
                $fakeConfigurationData = @{ ParentVhdPath = ResolvePathEx -Path $testParentImagePath; }
                New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
                Mock Test-LabImage -MockWith { return $false; }
                Mock Get-DiskImage -MockWith { return $fakeDiskImage; }
                Mock GetConfigurationData -MockWith { return $fakeConfigurationData; }
                Mock ResolveLabMedia -MockWith { return $fakeMedia; }
                Mock ExpandWindowsImage -MockWith { }
                Mock AddDiskImageHotfix -MockWith { }
                Mock SetDiskImageBootVolume -MockWith { }
                Mock Dismount-VHD -MockWith { }
                Mock InvokeLabMediaImageDownload -MockWith { return $fakeISOFileInfo; }
                Mock NewDiskImage -MockWith { return $fakeVhdImage; }

                New-LabImage -Id $testImageId

                Assert-MockCalled NewDiskImage -ParameterFilter { $PartitionStyle -eq 'GPT' } -Scope It;
            }

            It 'Uses "MBR" partition style for x86 media' {
                $testImageId = 'NewLabImage';
                $testParentImagePath = 'TestDrive:'
                $testImagePath = ResolvePathEx -Path "$testParentImagePath\$testImageId.vhdx";
                $testArchitecture = 'x86';
                $testWimImageName = 'Fake windows image';
                $fakeISOFileInfo = [PSCustomObject] @{ FullName = 'TestDrive:\TestIso.iso'; }
                $fakeMedia = [PSCustomObject] @{ Id = $testImageId; Description = 'Fake media'; Architecture = $testArchitecture; ImageName = $testWimImageName; }
                $fakeDiskImage = [PSCustomObject] @{ Attached = $true; BaseName = 'x'; ImagePath = $testImagePath; LogicalSectorSize = 42; BlockSize = 42; Size = 42; }
                $fakeVhdImage = [PSCustomObject] @{ Path = $testImagePath };
                $fakeConfigurationData = @{ ParentVhdPath = ResolvePathEx -Path $testParentImagePath; }
                New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
                Mock Test-LabImage -MockWith { return $false; }
                Mock Get-DiskImage -MockWith { return $fakeDiskImage; }
                Mock GetConfigurationData -MockWith { return $fakeConfigurationData; }
                Mock ResolveLabMedia -MockWith { return $fakeMedia; }
                Mock ExpandWindowsImage -MockWith { }
                Mock AddDiskImageHotfix -MockWith { }
                Mock SetDiskImageBootVolume -MockWith { }
                Mock Dismount-VHD -MockWith { }
                Mock InvokeLabMediaImageDownload -MockWith { return $fakeISOFileInfo; }
                Mock NewDiskImage -MockWith { return $fakeVhdImage; }

                New-LabImage -Id $testImageId

                Assert-MockCalled NewDiskImage -ParameterFilter { $PartitionStyle -eq 'MBR' } -Scope It;
            }

            It 'Uses custom partition style when specified' {
                $testImageId = 'NewLabImage';
                $testParentImagePath = 'TestDrive:'
                $testImagePath = ResolvePathEx -Path "$testParentImagePath\$testImageId.vhdx";
                $testArchitecture = 'x86';
                $testWimImageName = 'Fake windows image';
                $fakeISOFileInfo = [PSCustomObject] @{ FullName = 'TestDrive:\TestIso.iso'; }
                $fakeMedia = [PSCustomObject] @{
                    Id = $testImageId;
                    Description = 'Fake media';
                    Architecture = $testArchitecture;
                    ImageName = $testWimImageName;
                    CustomData = @{ PartitionStyle = 'GPT' }
                }
                $fakeDiskImage = [PSCustomObject] @{ Attached = $true; BaseName = 'x'; ImagePath = $testImagePath; LogicalSectorSize = 42; BlockSize = 42; Size = 42; }
                $fakeVhdImage = [PSCustomObject] @{ Path = $testImagePath };
                $fakeConfigurationData = @{ ParentVhdPath = ResolvePathEx -Path $testParentImagePath; }
                New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
                Mock Test-LabImage -MockWith { return $false; }
                Mock Get-DiskImage -MockWith { return $fakeDiskImage; }
                Mock GetConfigurationData -MockWith { return $fakeConfigurationData; }
                Mock ResolveLabMedia -MockWith { return $fakeMedia; }
                Mock ExpandWindowsImage -MockWith { }
                Mock AddDiskImageHotfix -MockWith { }
                Mock SetDiskImageBootVolume -MockWith { }
                Mock Dismount-VHD -MockWith { }
                Mock InvokeLabMediaImageDownload -MockWith { return $fakeISOFileInfo; }
                Mock NewDiskImage -MockWith { return $fakeVhdImage; }

                New-LabImage -Id $testImageId

                Assert-MockCalled NewDiskImage -ParameterFilter { $PartitionStyle -eq 'GPT' } -Scope It;
            }

            It 'Calls "ExpandWindowsImage" with the media WIM image name' {
                $testImageId = 'NewLabImage';
                $testParentImagePath = 'TestDrive:'
                $testImagePath = ResolvePathEx -Path "$testParentImagePath\$testImageId.vhdx";
                $testArchitecture = 'x64';
                $testWimImageName = 'Fake windows image';
                $fakeISOFileInfo = [PSCustomObject] @{ FullName = 'TestDrive:\TestIso.iso'; }
                $fakeMedia = [PSCustomObject] @{ Id = $testImageId; Description = 'Fake media'; Architecture = $testArchitecture; ImageName = $testWimImageName; }
                $fakeDiskImage = [PSCustomObject] @{ Attached = $true; BaseName = 'x'; ImagePath = $testImagePath; LogicalSectorSize = 42; BlockSize = 42; Size = 42; }
                $fakeVhdImage = [PSCustomObject] @{ Path = $testImagePath };
                $fakeConfigurationData = @{ ParentVhdPath = ResolvePathEx -Path $testParentImagePath; }
                New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
                Mock Test-LabImage -MockWith { return $false; }
                Mock Get-DiskImage -MockWith { return $fakeDiskImage; }
                Mock GetConfigurationData -MockWith { return $fakeConfigurationData; }
                Mock ResolveLabMedia -MockWith { return $fakeMedia; }
                Mock AddDiskImageHotfix -MockWith { }
                Mock SetDiskImageBootVolume -MockWith { }
                Mock Dismount-VHD -MockWith { }
                Mock InvokeLabMediaImageDownload -MockWith { return $fakeISOFileInfo; }
                Mock NewDiskImage -MockWith { return $fakeVhdImage; }
                Mock ExpandWindowsImage -ParameterFilter { $WimImageName -eq $testWimImageName } -MockWith { }

                New-LabImage -Id $testImageId

                Assert-MockCalled ExpandWindowsImage -ParameterFilter { $WimImageName -eq $testWimImageName } -Scope It;
            }

            It 'Calls "ExpandWindowsImage" with the media WIM image index' {
                $testImageId = 'NewLabImage';
                $testParentImagePath = 'TestDrive:'
                $testImagePath = ResolvePathEx -Path "$testParentImagePath\$testImageId.vhdx";
                $testArchitecture = 'x64';
                $testWimImageName = '42';
                $testWimImageIndex = [System.Int32] $testWimImageName;
                $fakeISOFileInfo = [PSCustomObject] @{ FullName = 'TestDrive:\TestIso.iso'; }
                $fakeMedia = [PSCustomObject] @{ Id = $testImageId; Description = 'Fake media'; Architecture = $testArchitecture; ImageName = $testWimImageName; }
                $fakeDiskImage = [PSCustomObject] @{ Attached = $true; BaseName = 'x'; ImagePath = $testImagePath; LogicalSectorSize = 42; BlockSize = 42; Size = 42; }
                $fakeVhdImage = [PSCustomObject] @{ Path = $testImagePath };
                $fakeConfigurationData = @{ ParentVhdPath = ResolvePathEx -Path $testParentImagePath; }
                New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
                Mock Test-LabImage -MockWith { return $false; }
                Mock Get-DiskImage -MockWith { return $fakeDiskImage; }
                Mock GetConfigurationData -MockWith { return $fakeConfigurationData; }
                Mock ResolveLabMedia -MockWith { return $fakeMedia; }
                Mock AddDiskImageHotfix -MockWith { }
                Mock SetDiskImageBootVolume -MockWith { }
                Mock Dismount-VHD -MockWith { }
                Mock InvokeLabMediaImageDownload -MockWith { return $fakeISOFileInfo; }
                Mock NewDiskImage -MockWith { return $fakeVhdImage; }
                Mock ExpandWindowsImage -MockWith { }

                New-LabImage -Id $testImageId

                Assert-MockCalled ExpandWindowsImage -ParameterFilter { $WimImageIndex -eq $testWimImageIndex } -Scope It;
            }

            It 'Calls "ExpandWindowsImage" with "WindowsOptionalFeature"' {
                $testImageId = 'NewLabImage';
                $testParentImagePath = 'TestDrive:'
                $testImagePath = ResolvePathEx -Path "$testParentImagePath\$testImageId.vhdx";
                $testArchitecture = 'x64';
                $testWimImageName = 'Fake windows image';
                $fakeISOFileInfo = [PSCustomObject] @{ FullName = 'TestDrive:\TestIso.iso'; }
                $fakeMedia = [PSCustomObject] @{
                    Id = $testImageId;
                    Description = 'Fake media';
                    Architecture = $testArchitecture;
                    ImageName = $testWimImageName;
                    CustomData = @{ WindowsOptionalFeature = 'NetFx3' };
                }
                $fakeDiskImage = [PSCustomObject] @{ Attached = $true; BaseName = 'x'; ImagePath = $testImagePath; LogicalSectorSize = 42; BlockSize = 42; Size = 42; }
                $fakeVhdImage = [PSCustomObject] @{ Path = $testImagePath };
                $fakeConfigurationData = @{ ParentVhdPath = ResolvePathEx -Path $testParentImagePath; }
                New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
                Mock Test-LabImage -MockWith { return $false; }
                Mock Get-DiskImage -MockWith { return $fakeDiskImage; }
                Mock GetConfigurationData -MockWith { return $fakeConfigurationData; }
                Mock ResolveLabMedia -MockWith { return $fakeMedia; }
                Mock AddDiskImageHotfix -MockWith { }
                Mock SetDiskImageBootVolume -MockWith { }
                Mock Dismount-VHD -MockWith { }
                Mock InvokeLabMediaImageDownload -MockWith { return $fakeISOFileInfo; }
                Mock NewDiskImage -MockWith { return $fakeVhdImage; }
                Mock ExpandWindowsImage -MockWith { }

                New-LabImage -Id $testImageId

                Assert-MockCalled ExpandWindowsImage -ParameterFilter { $WindowsOptionalFeature -ne $null } -Scope It;
            }

            It 'Calls "ExpandWindowsImage" with "WimPath"' {
                $testImageId = 'NewLabImage';
                $testParentImagePath = 'TestDrive:'
                $testImagePath = ResolvePathEx -Path "$testParentImagePath\$testImageId.vhdx";
                $testArchitecture = 'x64';
                $testWimImageName = 'Fake windows image';
                $fakeISOFileInfo = [PSCustomObject] @{ FullName = 'TestDrive:\TestIso.iso'; }
                $testCustomWimPath = '\custom\install.wim';
                $fakeMedia = [PSCustomObject] @{
                    Id = $testImageId;
                    Description = 'Fake media';
                    Architecture = $testArchitecture;
                    ImageName = $testWimImageName;
                    CustomData = @{ WimPath = $testCustomWimPath };
                }
                $fakeDiskImage = [PSCustomObject] @{ Attached = $true; BaseName = 'x'; ImagePath = $testImagePath; LogicalSectorSize = 42; BlockSize = 42; Size = 42; }
                $fakeVhdImage = [PSCustomObject] @{ Path = $testImagePath };
                $fakeConfigurationData = @{ ParentVhdPath = ResolvePathEx -Path $testParentImagePath; }
                New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
                Mock Test-LabImage -MockWith { return $false; }
                Mock Get-DiskImage -MockWith { return $fakeDiskImage; }
                Mock GetConfigurationData -MockWith { return $fakeConfigurationData; }
                Mock ResolveLabMedia -MockWith { return $fakeMedia; }
                Mock AddDiskImageHotfix -MockWith { }
                Mock SetDiskImageBootVolume -MockWith { }
                Mock Dismount-VHD -MockWith { }
                Mock InvokeLabMediaImageDownload -MockWith { return $fakeISOFileInfo; }
                Mock NewDiskImage -MockWith { return $fakeVhdImage; }
                Mock ExpandWindowsImage -MockWith { }

                New-LabImage -Id $testImageId

                Assert-MockCalled ExpandWindowsImage -ParameterFilter { $WimPath -eq $testCustomWimPath } -Scope It;
            }

            It 'Calls "ExpandWindowsImage" with "SourcePath"' {
                $testImageId = 'NewLabImage';
                $testParentImagePath = 'TestDrive:'
                $testImagePath = ResolvePathEx -Path "$testParentImagePath\$testImageId.vhdx";
                $testArchitecture = 'x64';
                $testWimImageName = 'Fake windows image';
                $fakeISOFileInfo = [PSCustomObject] @{ FullName = 'TestDrive:\TestIso.iso'; }
                $testCustomSourcePath = '\custom\sxs';
                $fakeMedia = [PSCustomObject] @{
                    Id = $testImageId;
                    Description = 'Fake media';
                    Architecture = $testArchitecture;
                    ImageName = $testWimImageName;
                    CustomData = @{ SourcePath = $testCustomSourcePath };
                }
                $fakeDiskImage = [PSCustomObject] @{ Attached = $true; BaseName = 'x'; ImagePath = $testImagePath; LogicalSectorSize = 42; BlockSize = 42; Size = 42; }
                $fakeVhdImage = [PSCustomObject] @{ Path = $testImagePath };
                $fakeConfigurationData = @{ ParentVhdPath = ResolvePathEx -Path $testParentImagePath; }
                New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
                Mock Test-LabImage -MockWith { return $false; }
                Mock Get-DiskImage -MockWith { return $fakeDiskImage; }
                Mock GetConfigurationData -MockWith { return $fakeConfigurationData; }
                Mock ResolveLabMedia -MockWith { return $fakeMedia; }
                Mock AddDiskImageHotfix -MockWith { }
                Mock SetDiskImageBootVolume -MockWith { }
                Mock Dismount-VHD -MockWith { }
                Mock InvokeLabMediaImageDownload -MockWith { return $fakeISOFileInfo; }
                Mock NewDiskImage -MockWith { return $fakeVhdImage; }
                Mock ExpandWindowsImage -MockWith { }

                New-LabImage -Id $testImageId

                Assert-MockCalled ExpandWindowsImage -ParameterFilter { $SourcePath -eq $testCustomSourcePath } -Scope It;
            }

            It 'Calls "AddDiskImageHotfix" to inject hotfixes' {
                $testImageId = 'NewLabImage';
                $testParentImagePath = 'TestDrive:'
                $testImagePath = ResolvePathEx -Path "$testParentImagePath\$testImageId.vhdx";
                $testArchitecture = 'x64';
                $testWimImageName = 'Fake windows image';
                $fakeISOFileInfo = [PSCustomObject] @{ FullName = 'TestDrive:\TestIso.iso'; }
                $fakeMedia = [PSCustomObject] @{ Id = $testImageId; Description = 'Fake media'; Architecture = $testArchitecture; ImageName = $testWimImageName; }
                $fakeDiskImage = [PSCustomObject] @{ Attached = $true; BaseName = 'x'; ImagePath = $testImagePath; LogicalSectorSize = 42; BlockSize = 42; Size = 42; }
                $fakeVhdImage = [PSCustomObject] @{ Path = $testImagePath };
                $fakeConfigurationData = @{ ParentVhdPath = ResolvePathEx -Path $testParentImagePath; }
                New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
                Mock Test-LabImage -MockWith { return $false; }
                Mock Get-DiskImage -MockWith { return $fakeDiskImage; }
                Mock GetConfigurationData -MockWith { return $fakeConfigurationData; }
                Mock ResolveLabMedia -MockWith { return $fakeMedia; }
                Mock SetDiskImageBootVolume -MockWith { }
                Mock Dismount-VHD -MockWith { }
                Mock InvokeLabMediaImageDownload -MockWith { return $fakeISOFileInfo; }
                Mock NewDiskImage -MockWith { return $fakeVhdImage; }
                Mock ExpandWindowsImage -MockWith { }
                Mock AddDiskImageHotfix -MockWith { }

                New-LabImage -Id $testImageId

                Assert-MockCalled AddDiskImageHotfix -ParameterFilter { $Id -eq $testImageId } -Scope It;
            }

            It 'Calls "SetDiskImageBootVolume" to configure boot volume' {
                $testImageId = 'NewLabImage';
                $testParentImagePath = 'TestDrive:'
                $testImagePath = ResolvePathEx -Path "$testParentImagePath\$testImageId.vhdx";
                $testArchitecture = 'x64';
                $testWimImageName = 'Fake windows image';
                $fakeISOFileInfo = [PSCustomObject] @{ FullName = 'TestDrive:\TestIso.iso'; }
                $fakeMedia = [PSCustomObject] @{ Id = $testImageId; Description = 'Fake media'; Architecture = $testArchitecture; ImageName = $testWimImageName; }
                $fakeDiskImage = [PSCustomObject] @{ Attached = $true; BaseName = 'x'; ImagePath = $testImagePath; LogicalSectorSize = 42; BlockSize = 42; Size = 42; }
                $fakeVhdImage = [PSCustomObject] @{ Path = $testImagePath };
                $fakeConfigurationData = @{ ParentVhdPath = ResolvePathEx -Path $testParentImagePath; }
                New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
                Mock Test-LabImage -MockWith { return $false; }
                Mock Get-DiskImage -MockWith { return $fakeDiskImage; }
                Mock GetConfigurationData -MockWith { return $fakeConfigurationData; }
                Mock ResolveLabMedia -MockWith { return $fakeMedia; }
                Mock Dismount-VHD -MockWith { }
                Mock InvokeLabMediaImageDownload -MockWith { return $fakeISOFileInfo; }
                Mock NewDiskImage -MockWith { return $fakeVhdImage; }
                Mock ExpandWindowsImage -MockWith { }
                Mock AddDiskImageHotfix -MockWith { }
                Mock SetDiskImageBootVolume -MockWith { }

                New-LabImage -Id $testImageId

                Assert-MockCalled SetDiskImageBootVolume -Scope It;
            }

            It 'Dismounts image' {
                $testImageId = 'NewLabImage';
                $testParentImagePath = 'TestDrive:'
                $testImagePath = ResolvePathEx -Path "$testParentImagePath\$testImageId.vhdx";
                $testArchitecture = 'x64';
                $testWimImageName = 'Fake windows image';
                $fakeISOFileInfo = [PSCustomObject] @{ FullName = 'TestDrive:\TestIso.iso'; }
                $fakeMedia = [PSCustomObject] @{ Id = $testImageId; Description = 'Fake media'; Architecture = $testArchitecture; ImageName = $testWimImageName; }
                $fakeDiskImage = [PSCustomObject] @{ Attached = $true; BaseName = 'x'; ImagePath = $testImagePath; LogicalSectorSize = 42; BlockSize = 42; Size = 42; }
                $fakeVhdImage = [PSCustomObject] @{ Path = $testImagePath };
                $fakeConfigurationData = @{ ParentVhdPath = ResolvePathEx -Path $testParentImagePath; }
                New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
                Mock Test-LabImage -MockWith { return $false; }
                Mock Get-DiskImage -MockWith { return $fakeDiskImage; }
                Mock GetConfigurationData -MockWith { return $fakeConfigurationData; }
                Mock ResolveLabMedia -MockWith { return $fakeMedia; }
                Mock InvokeLabMediaImageDownload -MockWith { return $fakeISOFileInfo; }
                Mock NewDiskImage -MockWith { return $fakeVhdImage; }
                Mock ExpandWindowsImage -MockWith { }
                Mock AddDiskImageHotfix -MockWith { }
                Mock SetDiskImageBootVolume -MockWith { }
                Mock Dismount-VHD -MockWith { }

                New-LabImage -Id $testImageId

                Assert-MockCalled Dismount-VHD -ParameterFilter { $Path -eq $testImagePath } -Scope It;
            }

            It 'Calls "Test-LabImage" and "Get-LabImage" with "ConfigurationData" when specified (#97)' {
                $testImageId = 'NewLabImage';
                $testParentImagePath = 'TestDrive:'
                $testImagePath = ResolvePathEx -Path "$testParentImagePath\$testImageId.vhdx";
                $testArchitecture = 'x64';
                $testWimImageName = 'Fake windows image';
                $fakeISOFileInfo = [PSCustomObject] @{ FullName = 'TestDrive:\TestIso.iso'; }
                $fakeMedia = [PSCustomObject] @{ Id = $testImageId; Description = 'Fake media'; Architecture = $testArchitecture; ImageName = $testWimImageName; }
                $fakeLabImage = [PSCustomObject] @{ Id = $testImageId; ImagePath = $testImagePath; }
                $fakeDiskImage = [PSCustomObject] @{ Attached = $true; BaseName = 'x'; ImagePath = $testImagePath; LogicalSectorSize = 42; BlockSize = 42; Size = 42; }
                $fakeVhdImage = [PSCustomObject] @{ Path = $testImagePath };
                $fakeConfigurationData = @{ ParentVhdPath = ResolvePathEx -Path $testParentImagePath; }
                New-Item -Path $testImagePath -ItemType File -Force -ErrorAction SilentlyContinue;
                Mock Get-DiskImage -MockWith { return $fakeDiskImage; }
                Mock GetConfigurationData -MockWith { return $fakeConfigurationData; }
                Mock ResolveLabMedia -MockWith { return $fakeMedia; }
                Mock InvokeLabMediaImageDownload -MockWith { return $fakeISOFileInfo; }
                Mock NewDiskImage -MockWith { return $fakeVhdImage; }
                Mock ExpandWindowsImage -MockWith { }
                Mock AddDiskImageHotfix -MockWith { }
                Mock SetDiskImageBootVolume -MockWith { }
                Mock Dismount-VHD -MockWith { }
                Mock Test-LabImage -MockWith { return $true; }
                Mock Get-LabImage -MockWith { return $fakeLabImage; }

                New-LabImage -Id $testImageId -ConfigurationData @{} -Force;

                Assert-MockCalled Test-LabImage -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
                Assert-MockCalled Get-LabImage -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
            }



        } #end context Validates "New-LabImage" method

    } #end InModuleScope

} #end describe Src\LabImage
