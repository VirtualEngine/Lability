#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Public\Test-LabMedia' {

    InModuleScope -ModuleName $moduleName {

        It 'Passes when media ISO has been downloaded' {
            $testMediaId = '2016_x64_Datacenter_EN_Eval';
            $testHostIsoPath = 'TestDrive:';
            $testMediaFilename = 'test-media.iso';
            $fakeLabMedia = @{ Filename = $testMediaFilename; Uri = 'http//testmedia.com/test-media.iso'; Checksum = ''; }
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] @{ IsoPath = $testHostIsoPath; } }
            New-Item -Path "$testHostIsoPath\$testMediaFilename" -ItemType File -Force -ErrorAction SilentlyContinue;
            Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith { return [PSCustomObject] $fakeLabMedia; }

            Test-LabMedia -Id $testMediaId | Should Be $true;
        }

        It 'Fails when media ISO has not been downloaded' {
            $testMediaId = '2016_x64_Datacenter_EN_Eval';
            $testHostIsoPath = 'TestDrive:';
            $testMediaFilename = 'test-media.iso';
            $fakeLabMedia = @{ Filename = $testMediaFilename; Uri = 'http//testmedia.com/test-media.iso'; Checksum = ''; }
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] @{ IsoPath = $testHostIsoPath; } }
            Remove-Item -Path "$testHostIsoPath\$testMediaFilename" -Force -ErrorAction SilentlyContinue;
            Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith { return [PSCustomObject] $fakeLabMedia; }

            Test-LabMedia -Id $testMediaId | Should Be $false;
        }

        It 'Fails when media Id is not found' {
            $testMediaId = 'NonExistentMediaId';
            $testHostIsoPath = 'TestDrive:';
            $testMediaFilename = 'test-media.iso';
            $fakeLabMedia = @{ Filename = $testMediaFilename; Uri = 'http//testmedia.com/test-media.iso'; Checksum = ''; }
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] @{ IsoPath = $testHostIsoPath; } }
            Mock Get-LabMedia -ParameterFilter { $Id -eq $testMediaId } -MockWith { }

            Test-LabMedia -Id $testMediaId | Should Be $false;
        }

    } #end InModuleScope

} #end describe
