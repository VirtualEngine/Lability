#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Private\Add-DiskImageHotfix' {

    InModuleScope $moduleName {

        $fakeMediaSuite = @(
            @{  Id = 'NoHotfixes';
                TestName = 'Does not call "Add-WindowsPackage" for no hotfixes';
                Hotfixes = @();
            }
            @{  Id = 'OneHotfix';
                TestName = 'Calls "Add-WindowsPackage" for a single hotfix';
                Hotfixes = @(
                    @{ Id = 'Window0.0-KB1234567.msu'; Uri = 'NonNullValue'; }
                );
            }
            @{  Id = 'MultipleHotfixes';
                TestName = 'Calls "Add-WindowsPackage" for each hotfix with multiple hotfixes';
                Hotfixes = @(
                    @{ Id = 'Window0.0-KB1234567.msu'; Uri = 'NonNullValue'; }
                    @{ Id = 'Window0.0-KB1234568.msu'; Uri = 'NonNullValue'; }
                    @{ Id = 'Window0.0-KB1234569.msu'; Uri = 'NonNullValue'; }
                );
            }
        )

        foreach ($fakeMedia in $fakeMediaSuite) {
            foreach ($partitionStyle in @('MBR','GPT')) {

                It $fakeMedia.TestName {
                    $vhdImage = [PSCustomObject] @{ DiskNumber = 10 };
                    Mock Get-DiskImageDriveLetter -MockWith { return 'Z'; }
                    Mock Get-LabMedia -MockWith { return [PSCustomObject] $fakeMedia; }
                    Mock Invoke-LabMediaDownload -MockWith { return New-Item -Path "TestDrive:\$Id" -Force -ItemType File }
                    Mock New-Directory -MockWith { }
                    Mock Add-WindowsPackage -MockWith { }

                    Add-DiskImageHotfix $fakeMedia.Id -Vhd $vhdImage -PartitionStyle $partitionStyle;

                    Assert-MockCalled Add-WindowsPackage -Scope It -Exactly $fakeMedia.Hotfixes.Count;
                }

            } #end foreach partition style
        } #end foreach fake media suite

    } #end InModuleScope
} #end Describe
