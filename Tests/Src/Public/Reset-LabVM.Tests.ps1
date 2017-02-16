#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Public\Reset-LabVM' {

    InModuleScope -ModuleName $moduleName {

        ## Guard mocks
        Mock RemoveLabVM -MockWith { }
        Mock NewLabVM -MockWith { }
        Mock Resolve-ConfigurationPath -MockWith { return (Get-Location -PSProvider Filesystem).Path; }

        $testPassword = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);

        It 'Removes existing virtual machine' {
            $testVMName = 'TestVM';
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = $testVMName; }
                )
            }

            Reset-LabVM -ConfigurationData $configurationData -Name $testVMName -Credential $testPassword;

            Assert-MockCalled RemoveLabVM -ParameterFilter { $Name -eq $testVMName } -Scope It;
        }

        It 'Creates a new virtual machine' {
            $testVMName = 'TestVM';
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = $testVMName; }
                )
            }

            Reset-LabVM -ConfigurationData $configurationData -Name $testVMName -Credential $testPassword;

            Assert-MockCalled NewLabVM -ParameterFilter { $NoSnapShot -eq $false } -Scope It;
        }

        It 'Creates a new virtual machine without a snapshot when "NoSnapshot" is specified' {
            $testVMName = 'TestVM';
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = $testVMName; }
                )
            }

            Reset-LabVM -ConfigurationData $configurationData -Name $testVMName -Credential $testPassword -NoSnapshot;

            Assert-MockCalled NewLabVM -ParameterFilter { $NoSnapShot -eq $true } -Scope It;
        }

    } #end InModuleScope

} #end describe
