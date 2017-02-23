#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Get-WindowsImageByIndex' {

    InModuleScope $moduleName {

        It 'Returns a "System.Int32" type' {
            $testWimPath = 'TestDrive:\TestIsoImage.wim';
            [ref] $null = New-Item -Path $testWimPath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testImageName = 'Test Image';
            $testImageIndex = 42;
            $fakeWindowsImages = @(
                [PSCustomObject] @{ ImageName = $testImageName; ImageIndex = $testImageIndex; }
                [PSCustomObject] @{ ImageName = 'A random Image'; ImageIndex = $testImageIndex + 1; }
            )
            Mock Get-WindowsImage -MockWith { return $fakeWindowsImages; }

            $imageIndex = Get-WindowsImageByIndex -ImagePath $testWimPath -ImageName $testImageName;

            $imageIndex -is [System.Int32] | Should Be $true;
        }

        It 'Returns the matching image index if found' {
            $testWimPath = 'TestDrive:\TestIsoImage.wim';
            [ref] $null = New-Item -Path $testWimPath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testImageName = 'Test Image';
            $testImageIndex = 42;
            $fakeWindowsImages = @(
                [PSCustomObject] @{ ImageName = $testImageName; ImageIndex = $testImageIndex; }
                [PSCustomObject] @{ ImageName = 'A random Image'; ImageIndex = $testImageIndex + 1; }
            )
            Mock Get-WindowsImage -MockWith { return $fakeWindowsImages; }

            $imageIndex = Get-WindowsImageByIndex -ImagePath $testWimPath -ImageName $testImageName;

            $imageIndex | Should Be $testImageIndex;
        }

        It 'Returns nothing when image index is not found' {
            $testWimPath = 'TestDrive:\TestIsoImage.wim';
            [ref] $null = New-Item -Path $testWimPath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testImageName = 'Test Image';
            $testImageIndex = 42;
            $fakeWindowsImages = @(
                [PSCustomObject] @{ ImageName = $testImageName; ImageIndex = $testImageIndex; }
                [PSCustomObject] @{ ImageName = 'A random Image'; ImageIndex = $testImageIndex + 1; }
            )
            Mock Get-WindowsImage -MockWith { return $fakeWindowsImages; }

            $imageIndex = Get-WindowsImageByIndex -ImagePath $testWimPath -ImageName 'This should not exist';

            $imageIndex | Should BeNullOrEmpty;
        }

    } #end InModuleScope
} #end Describe
