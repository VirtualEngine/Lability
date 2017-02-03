#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Resolve-LabImage' {

    InModuleScope $moduleName {

        It 'resolves VHD/X path to the associated Lability image.' {

            $labVMSnapshotPath = 'C:\Child\Snapshot.avhd';
            $labVMBasePath = 'C:\Child\VMImage.vhdx';
            $labImageId = 'TestLabImage'
            $labImagePath = 'C:\Parent\Image.vhdx';
            Mock Resolve-VhdHierarchy { return @($labVMSnapshotPath, $labVMBasePath, $labImagePath); }
            Mock Get-LabImage { return [PSCustomObject] @{ Id = $labImageId; ImagePath = $labImagePath; } }

            $labImage = Resolve-LabImage -Path $labVMSnapshotPath;

            $labImage.Id | Should Be $labImageId;
        }

    } #end InModuleScope

} #end describe Src\Lab
