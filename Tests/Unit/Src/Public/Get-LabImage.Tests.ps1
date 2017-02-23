#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Public\Get-LabImage' {

    InModuleScope -ModuleName $moduleName {

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
            Mock Get-ConfigurationData -MockWith { return $fakeConfigurationData; }
            Mock Get-DiskImage -MockWith { return $fakeDiskImage; }

            $images = Get-LabImage -Id 'NonExistentId';

            $images | Should BeNullOrEmpty;
        }

        It 'Returns null when there is are no parent images' {
            $fakeConfigurationData = @{ ParentVhdPath = ResolvePathEx -Path 'TestDrive:\EmptyPath'; }
            New-Item -Path 'TestDrive:\EmptyPath' -ItemType Directory -Force -ErrorAction SilentlyContinue;
            Mock Get-ConfigurationData -MockWith { return $fakeConfigurationData; }
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
            Mock Get-ConfigurationData -MockWith { return $fakeConfigurationData; }
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
            Mock Get-ConfigurationData -MockWith { return $fakeConfigurationData; }
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
                Mock Get-ConfigurationData -MockWith { return $fakeConfigurationData; }
                Mock Get-LabMedia -MockWith { return $fakeLabMedia; }
                Mock Get-DiskImage -MockWith { return $fakeDiskImage; }

                $image = Get-LabImage -Id $testLabMediaId;

                $image.Generation | Should Be $testImageGeneration;
            }
        }

    } #end InModuleScope

} #end describe
