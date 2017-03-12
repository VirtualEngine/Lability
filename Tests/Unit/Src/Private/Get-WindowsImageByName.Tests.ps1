#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Get-WindowsImageByName' {

    InModuleScope $moduleName {

        It 'Returns a "System.String" type' {
            $testWimPath = 'TestDrive:\TestIsoImage.wim';
            [ref] $null = New-Item -Path $testWimPath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testImageName = 'Test Image';
            $testImageIndex = 42;
            $fakeWindowsImages = @(
                [PSCustomObject] @{ ImageName = $testImageName; ImageIndex = $testImageIndex; }
                [PSCustomObject] @{ ImageName = 'A random Image'; ImageIndex = $testImageIndex + 1; }
            )
            Mock Get-WindowsImage -ParameterFilter { $ImagePath -eq $testWimPath } -MockWith { return $fakeWindowsImages; }

            $imageName = Get-WindowsImageByName -ImagePath $testWimPath -ImageIndex $testImageIndex;

            $imageName -is [System.String] | Should Be $true;
        }

        It 'Returns the matching image name' {
            $testWimPath = 'TestDrive:\TestIsoImage.wim';
            [ref] $null = New-Item -Path $testWimPath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testImageName = 'Test Image';
            $testImageIndex = 42;
            $fakeWindowsImages = @(
                [PSCustomObject] @{ ImageName = $testImageName; ImageIndex = $testImageIndex; }
                [PSCustomObject] @{ ImageName = 'A random Image'; ImageIndex = $testImageIndex + 1; }
            )
            Mock Get-WindowsImage -ParameterFilter { $ImagePath -eq $testWimPath } -MockWith { return $fakeWindowsImages; }

            $imageName = Get-WindowsImageByName -ImagePath $testWimPath -ImageIndex $testImageIndex;

            $imageName | Should Be $testImageName;
        }

        It 'Returns nothing when image name is not found' {
            $testWimPath = 'TestDrive:\TestIsoImage.wim';
            [ref] $null = New-Item -Path $testWimPath -ItemType File -Force -ErrorAction SilentlyContinue;
            $testImageName = 'Test Image';
            $testImageIndex = 42;
            $fakeWindowsImages = @(
                [PSCustomObject] @{ ImageName = $testImageName; ImageIndex = $testImageIndex; }
                [PSCustomObject] @{ ImageName = 'A random Image'; ImageIndex = $testImageIndex + 1; }
            )
            Mock Get-WindowsImage -ParameterFilter { $ImagePath -eq $testWimPath } -MockWith { return $fakeWindowsImages; }

            $imageName = Get-WindowsImageByName -ImagePath $testWimPath -ImageIndex 99;

            $imageName | Should BeNullOrEmpty;
        }

    } #end InModuleScope
} #end Describe
