#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\Invoke-LabMediaDownload' {

    InModuleScope -ModuleName $moduleName {

        It 'Returns a "System.IO.FileInfo" object type' {
            $testHotfixId = 'Windows11-KB1234567.msu';
            $testHotfixUri = "http://testhotfix.com/$testHotfixId";
            $testHotfixPath = 'TestDrive:\Hotfix';
            $testHotfixFilename = "$testHotfixPath\$testHotfixId";
            New-Item -Path $testHotfixFilename -ItemType File -Force -ErrorAction SilentlyContinue;
            $fakeConfigurationData = @{ HotfixPath = $testHotfixPath;}
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
            Mock InvokeResourceDownload -ParameterFilter { $DestinationPath -eq $testHotfixFilename } -MockWith { }

            $hotfix = Invoke-LabMediaDownload -Id $testHotfixId -Uri $testHotfixUri;
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
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
            Mock InvokeResourceDownload -ParameterFilter { $Checksum -eq $testHotfixChecksum } -MockWith { }

            Invoke-LabMediaDownload -Id $testHotfixId -Uri $testHotfixUri -Checksum $testHotfixChecksum;

            Assert-MockCalled InvokeResourceDownload -ParameterFilter { $Checksum -eq $testHotfixChecksum } -Scope It;
        }

        It 'Calls "InvokeResourceDownload" with "Force" parameter when specified' {
            $testHotfixId = 'Windows11-KB1234567.msu';
            $testHotfixUri = "http://testhotfix.com/$testHotfixId";
            $testHotfixPath = 'TestDrive:\Hotfix';
            $testHotfixFilename = "$testHotfixPath\$testHotfixId";
            New-Item -Path $testHotfixFilename -ItemType File -Force -ErrorAction SilentlyContinue;
            $fakeConfigurationData = @{ HotfixPath = $testHotfixPath;}
            Mock Get-ConfigurationData -ParameterFilter { $Configuration -eq 'Host' } -MockWith { return [PSCustomObject] $fakeConfigurationData; }
            Mock InvokeResourceDownload -ParameterFilter { $Force -eq $true } -MockWith { }

            Invoke-LabMediaDownload -Id $testHotfixId -Uri $testHotfixUri -Force;

            Assert-MockCalled InvokeResourceDownload -ParameterFilter { $Force -eq $true } -Scope It;
        }

    } #end InModuleScope

} #end describe
