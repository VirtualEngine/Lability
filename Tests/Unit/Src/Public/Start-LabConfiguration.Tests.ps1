#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Public\Start-LabConfiguration' {

    InModuleScope -ModuleName $moduleName {

        function New-MofFiles {
            param (
                ## VM Name
                [System.String] $Name,
                ## Configuration path
                [System.String] $Path
            )
            New-Item -Path "$Path\$Name.mof" -ItemType File -Force;
            New-Item -Path "$Path\$Name.meta.mof" -ItemType File -Force;
        }

        ## Guard mocks
        #Mock Test-LabConfigurationMof -MockWith { }
        Mock NewLabVM -MockWith { }

        $testPassword = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);

        It 'Throws is "Test-LabHostConfiguration" fails' {
            $testVM = 'VM1';
            $configurationData = @{ AllNodes = @( @{ NodeName = $testVM; } ) }
            Mock Test-LabHostConfiguration -MockWith { return $false; }

            { Start-LabConfiguration -ConfigurationData $configurationData -Credential $testPassword } | Should Throw;
        }

        It 'Throws if path is invalid' {
            $testVM = 'VM1';
            $configurationData = @{ AllNodes = @( @{ NodeName = $testVM; } ) }
            Mock Test-LabHostConfiguration -MockWith { return $true; }

            { Start-LabConfiguration -ConfigurationData $configurationData -Path 'TestDrive:\InvalidPath'  -Credential $testPassword } | Should Throw;
        }

        It 'Calls "NewLabVM" if node is not configured' {
            $testPath = 'TestDrive:\';
            $testVM = 'VM1';
            New-MofFiles -Name $testVM -Path $testPath;
            $configurationData = @{ AllNodes = @( @{ NodeName = $testVM; } ) }
            Mock Test-LabHostConfiguration -MockWith { return $true; }
            Mock Test-LabConfiguration -MockWith { return @{ Name = $testVM; IsConfigured = $false; } }

            Start-LabConfiguration -ConfigurationData $configurationData -Path $testPath -Credential $testPassword;

            Assert-MockCalled NewLabVM -ParameterFilter { $Name -eq $testVM } -Scope It;
        }

        It 'Does not call "NewLabVM" if node is configured' {
            $testPath = 'TestDrive:';
            $testVM = 'VM1';
            New-MofFiles -Name $testVM -Path $testPath;
            $configurationData = @{ AllNodes = @( @{ NodeName = $testVM; } ) }
            Mock Test-LabHostConfiguration -MockWith { return $true; }
            Mock Test-LabConfiguration -MockWith { return @{ Name = $testVM; IsConfigured = $true; } }

            Start-LabConfiguration -ConfigurationData $configurationData -Path $testPath -Credential $testPassword;

            Assert-MockCalled NewLabVM -ParameterFilter { $Name -eq $testVM } -Exactly 0 -Scope It;
        }

        It 'Calls "NewLabVM" if node is configured but -Force is specified' {
            $testPath = 'TestDrive:';
            $testVM = 'VM1';
            New-MofFiles -Name $testVM -Path $testPath;
            $configurationData = @{ AllNodes = @( @{ NodeName = $testVM; } ) }
            Mock Test-LabHostConfiguration -MockWith { return $true; }
            Mock Test-LabConfiguration -MockWith { return @{ Name = $testVM; IsConfigured = $true; } }

            Start-LabConfiguration -ConfigurationData $configurationData -Path $testPath -Credential $testPassword -Force;

            Assert-MockCalled NewLabVM -ParameterFilter { $Name -eq $testVM } -Scope It;
        }

    } #end InModuleScope

} #end describe
