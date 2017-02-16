#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\LabVM' {

    InModuleScope $moduleName {

        Context 'Validates "NewLabVM" method' {

            $testPassword = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);

            It 'Throws when "ClientCertificatePath" cannot be found' {
                $testVMName = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; ClientCertificatePath = 'TestDrive:'; }
                    )
                }

                { NewLabVM -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword } | Should Throw;
            }

            It 'Does not throw when "ClientCertificatePath" cannot be found and "IsQuickVM" = "$true"' {
                $testVMName = 'TestVM';
                $testMedia = 'Test-Media';
                $testVMSwitch = 'Test Switch';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; Media = $testMedia; }
                    )
                }
                Mock ResolveLabMedia -MockWith { return $Id; }
                Mock SetLabSwitch -MockWith { }
                Mock ResetLabVMDisk -MockWith { }
                Mock SetLabVirtualMachine -MockWith { }
                Mock Set-LabVMDiskFile -MockWith { }
                Mock Checkpoint-VM -MockWith { }
                Mock Get-VM -MockWith { }
                Mock Test-LabImage -MockWith { return $false; }
                Mock New-LabImage -MockWith { }

                { NewLabVM -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword -IsQuickVM } | Should Not Throw;
            }

            It 'Throws when "RootCertificatePath" cannot be found' {
                $testVMName = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; RootCertificatePath = 'TestDrive:'; }
                    )
                }

                { NewLabVM -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword } | Should Throw;
            }

            It 'Does not throw when "RootCertificatePath" cannot be found and "IsQuickVM" = "$true"' {
                $testVMName = 'TestVM';
                $testMedia = 'Test-Media';
                $testVMSwitch = 'Test Switch';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; Media = $testMedia; }
                    )
                }
                Mock ResolveLabMedia -MockWith { return $Id; }
                Mock SetLabSwitch -MockWith { }
                Mock ResetLabVMDisk -MockWith { }
                Mock SetLabVirtualMachine -MockWith { }
                Mock Set-LabVMDiskFile -MockWith { }
                Mock Checkpoint-VM -MockWith { }
                Mock Get-VM -MockWith { }
                Mock Test-LabImage -MockWith { return $false; }
                Mock New-LabImage -MockWith { }

                { NewLabVM -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword -IsQuickVM } | Should Not Throw;
            }

            It 'Creates parent image if it is not already present' {
                $testVMName = 'TestVM';
                $testMedia = 'Test-Media';
                $testVMSwitch = 'Test Switch';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; Media = $testMedia; }
                    )
                }
                Mock ResolveLabMedia -MockWith { return $Id; }
                Mock SetLabSwitch -MockWith { }
                Mock ResetLabVMDisk -MockWith { }
                Mock SetLabVirtualMachine -MockWith { }
                Mock Set-LabVMDiskFile -MockWith { }
                Mock Checkpoint-VM -MockWith { }
                Mock Get-VM -MockWith { }
                Mock Test-LabImage -ParameterFilter { $Id -eq $testMedia } -MockWith { return $false; }
                Mock New-LabImage -ParameterFilter { $Id -eq $testMedia } -MockWith { }

                $labVM = NewLabVM -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

                Assert-MockCalled New-LabImage -ParameterFilter { $Id -eq $testMedia } -Scope It;
            }

            It 'Calls "SetLabSwitch" to configure VM switch' {
                $testVMName = 'TestVM';
                $testMedia = 'Test-Media';
                $testVMSwitch = 'Test Switch';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; Media = $testMedia; SwitchName = $testVMSwitch; }
                    )
                }
                Mock ResolveLabMedia -MockWith { return $Id; }
                Mock ResetLabVMDisk -MockWith { }
                Mock SetLabVirtualMachine -MockWith { }
                Mock Set-LabVMDiskFile -MockWith { }
                Mock Checkpoint-VM -MockWith { }
                Mock Get-VM -MockWith { }
                Mock Test-LabImage -MockWith { return $true; }
                Mock New-LabImage -MockWith { }
                Mock SetLabSwitch -ParameterFilter { $Name -eq $testVMSwitch } -MockWith { }

                $labVM = NewLabVM -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

                Assert-MockCalled SetLabSwitch -ParameterFilter { $Name -eq $testVMSwitch } -Scope It;
            }

            It 'Calls "SetLabSwitch" once per network switch' {
                $testVMName = 'TestVM';
                $testMedia = 'Test-Media';
                $testVMSwitch = 'Test Switch';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; Media = $testMedia; SwitchName = $testVMSwitch, $testVMSwitch; }
                    )
                }
                Mock ResolveLabMedia -MockWith { return $Id; }
                Mock ResetLabVMDisk -MockWith { }
                Mock SetLabVirtualMachine -MockWith { }
                Mock Set-LabVMDiskFile -MockWith { }
                Mock Checkpoint-VM -MockWith { }
                Mock Get-VM -MockWith { }
                Mock Test-LabImage -MockWith { return $true; }
                Mock New-LabImage -MockWith { }
                Mock SetLabSwitch -ParameterFilter { $Name -eq $testVMSwitch } -MockWith { }

                $labVM = NewLabVM -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

                Assert-MockCalled SetLabSwitch -ParameterFilter { $Name -eq $testVMSwitch } -Exactly 2 -Scope It;
            }

            It 'Calls "ResetLabVMDisk" to create VM disk' {
                $testVMName = 'TestVM';
                $testMedia = 'Test-Media';
                $testVMSwitch = 'Test Switch';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; Media = $testMedia; SwitchName = $testVMSwitch; }
                    )
                }
                Mock ResolveLabMedia -MockWith { return $Id; }
                Mock SetLabSwitch -MockWith { }
                Mock SetLabVirtualMachine -MockWith { }
                Mock Set-LabVMDiskFile -MockWith { }
                Mock Checkpoint-VM -MockWith { }
                Mock Get-VM -MockWith { }
                Mock Test-LabImage -MockWith { return $true; }
                Mock New-LabImage -MockWith { }
                Mock ResetLabVMDisk -ParameterFilter { $Name -eq $testVMName -and $Media -eq $testMedia } -MockWith { }

                $labVM = NewLabVM -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

                Assert-MockCalled ResetLabVMDisk -ParameterFilter { $Name -eq $testVMName -and $Media -eq $testMedia } -Scope It;
            }

            It 'Creates virtual machine' {
                $testVMName = 'TestVM';
                $testMedia = 'Test-Media';
                $testVMSwitch = 'Test Switch';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; Media = $testMedia; SwitchName = $testVMSwitch; }
                    )
                }
                Mock ResolveLabMedia -MockWith { return $Id; }
                Mock SetLabSwitch -MockWith { }
                Mock ResetLabVMDisk -MockWith { }
                Mock Set-LabVMDiskFile -MockWith { }
                Mock Checkpoint-VM -MockWith { }
                Mock Get-VM -MockWith { }
                Mock Test-LabImage -MockWith { return $true; }
                Mock New-LabImage -MockWith { }
                Mock SetLabVirtualMachine -ParameterFilter { $Name -eq $testVMName } -MockWith { }

                $labVM = NewLabVM -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

                Assert-MockCalled SetLabVirtualMachine -ParameterFilter { $Name -eq $testVMName } -Scope It;
            }

            It 'Creates virtual machine with "GuestIntegrationServices" when specified' {
                $testVMName = 'TestVM';
                $testMedia = 'Test-Media';
                $testVMSwitch = 'Test Switch';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; Media = $testMedia; SwitchName = $testVMSwitch; GuestIntegrationServices = $true; }
                    )
                }
                Mock ResolveLabMedia -MockWith { return $Id; }
                Mock SetLabSwitch -MockWith { }
                Mock ResetLabVMDisk -MockWith { }
                Mock Set-LabVMDiskFile -MockWith { }
                Mock Checkpoint-VM -MockWith { }
                Mock Get-VM -MockWith { }
                Mock Test-LabImage -MockWith { return $true; }
                Mock New-LabImage -MockWith { }
                Mock SetLabVirtualMachine -ParameterFilter { $GuestIntegrationServices -eq $true } -MockWith { }

                $labVM = NewLabVM -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

                Assert-MockCalled SetLabVirtualMachine -ParameterFilter { $GuestIntegrationServices -eq $true } -Scope It;
            }

            It 'Does not inject resources when "OperatingSystem" is "Linux"' {
                $testVMName = 'TestVM';
                $configurationData = @{ AllNodes = @( @{ NodeName = $testVMName; } ) }
                Mock Checkpoint-VM -MockWith { }
                Mock Get-VM -MockWith { }
                Mock Test-LabImage -MockWith { return $true; }
                Mock New-LabImage -MockWith { }
                Mock SetLabSwitch -MockWith { }
                Mock ResetLabVMDisk -MockWith { }
                Mock SetLabVirtualMachine -MockWith { }
                Mock ResolveLabMedia -MockWith { return @{ Id = $Id; OperatingSystem = 'Linux'; } }
                Mock Set-LabVMDiskFile -MockWith { }

                $labVM = NewLabVM -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

                Assert-MockCalled Set-LabVMDiskFile -Scope It -Exactly 0;
            }

            It 'Injects VM resources' {
                $testVMName = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; Resource = 'TestResource'; }
                    )
                }
                Mock ResolveLabMedia -MockWith { return $Id; }
                Mock SetLabSwitch -MockWith { }
                Mock ResetLabVMDisk -MockWith { }
                Mock SetLabVirtualMachine -MockWith { }
                Mock Checkpoint-VM -MockWith { }
                Mock Get-VM -MockWith { }
                Mock Test-LabImage -MockWith { return $true; }
                Mock New-LabImage -MockWith { }
                #Mock Set-LabVMDiskFile -ParameterFilter { $NodeName -eq $testVMName } -MockWith { }
                Mock Set-LabVMDiskFile -MockWith { }

                $labVM = NewLabVM -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

                Assert-MockCalled Set-LabVMDiskFile -ParameterFilter { $NodeName -eq $testVMName } -Scope It;
            }

            It 'Passes media "ProductKey" when specified (#134)' {
                $testVMName = 'TestVM';
                $testProductKey   = 'ABCDE-12345-EDCBA-54321-ABCDE';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; Resource = 'TestResource'; }
                    )
                }
                Mock ResolveLabMedia -MockWith { return @{ Id = $Id; CustomData = @{ ProductKey = $testProductKey } } }
                Mock SetLabSwitch -MockWith { }
                Mock ResetLabVMDisk -MockWith { }
                Mock SetLabVirtualMachine -MockWith { }
                Mock Checkpoint-VM -MockWith { }
                Mock Get-VM -MockWith { }
                Mock Test-LabImage -MockWith { return $true; }
                Mock New-LabImage -MockWith { }
                Mock Set-LabVMDiskFile -MockWith { }

                $labVM = NewLabVM -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

                Assert-MockCalled Set-LabVMDiskFile -ParameterFilter { $ProductKey -eq $testProductKey } -Scope It;
            }

            It 'Does not create a snapshot when "NoSnapshot" is specified' {
                $testVMName = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; }
                    )
                }
                Mock ResolveLabMedia -MockWith { return $Id; }
                Mock SetLabSwitch -MockWith { }
                Mock ResetLabVMDisk -MockWith { }
                Mock SetLabVirtualMachine -MockWith { }
                Mock Set-LabVMDiskFile -MockWith { }
                Mock Get-VM -MockWith { }
                Mock Test-LabImage -MockWith { return $true; }
                Mock New-LabImage -MockWith { }
                Mock Checkpoint-VM -MockWith { }

                $labVM = NewLabVM -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword -NoSnapshot;

                Assert-MockCalled Checkpoint-VM -Exactly 0 -Scope It;
            }

            It 'Writes warning when VM "WarningMessage" is defined' {
                $testVMName = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; WarningMessage = 'This is a test warning' }
                    )
                }
                Mock ResolveLabMedia -MockWith { return $Id; }
                Mock SetLabSwitch -MockWith { }
                Mock ResetLabVMDisk -MockWith { }
                Mock SetLabVirtualMachine -MockWith { }
                Mock Set-LabVMDiskFile -MockWith { }
                Mock Get-VM -MockWith { }
                Mock Test-LabImage -MockWith { return $true; }
                Mock New-LabImage -MockWith { }
                Mock Checkpoint-VM -MockWith { }

                { NewLabVM -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword -NoSnapshot -WarningAction Stop 3>&1 } | Should Throw;
            }

            It 'Calls "Test-LabImage" with "ConfigurationData" (#97)' {
                $testVMName = 'TestVM';
                $testMedia = 'Test-Media';
                $testVMSwitch = 'Test Switch';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; Media = $testMedia; }
                    )
                }
                Mock ResolveLabMedia -MockWith { return $Id; }
                Mock SetLabSwitch -MockWith { }
                Mock ResetLabVMDisk -MockWith { }
                Mock SetLabVirtualMachine -MockWith { }
                Mock Set-LabVMDiskFile -MockWith { }
                Mock Checkpoint-VM -MockWith { }
                Mock Get-VM -MockWith { }
                Mock New-LabImage -MockWith { }
                Mock Test-LabImage -ParameterFilter { $null -ne $ConfigurationData } -MockWith { return $false; }

                $labVM = NewLabVM -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

                Assert-MockCalled Test-LabImage -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
            }

            It 'Calls "ResetLabVMDisk" with "ConfigurationData" (#97)' {
                $testVMName = 'TestVM';
                $testMedia = 'Test-Media';
                $testVMSwitch = 'Test Switch';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; Media = $testMedia; }
                    )
                }
                Mock ResolveLabMedia -MockWith { return $Id; }
                Mock SetLabSwitch -MockWith { }
                Mock SetLabVirtualMachine -MockWith { }
                Mock Set-LabVMDiskFile -MockWith { }
                Mock Checkpoint-VM -MockWith { }
                Mock Get-VM -MockWith { }
                Mock New-LabImage -MockWith { }
                Mock Test-LabImage -MockWith { return $false; }
                Mock ResetLabVMDisk -ParameterFilter { $null -ne $ConfigurationData } -MockWith { }

                $labVM = NewLabVM -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

                Assert-MockCalled ResetLabVMDisk -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
            }

            It 'Calls "SetLabVirtualMachine" with "ConfigurationData" (#97)' {
                $testVMName = 'TestVM';
                $testMedia = 'Test-Media';
                $testVMSwitch = 'Test Switch';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; Media = $testMedia; }
                    )
                }
                Mock ResolveLabMedia -MockWith { return $Id; }
                Mock SetLabSwitch -MockWith { }
                Mock ResetLabVMDisk -MockWith { }
                Mock Set-LabVMDiskFile -MockWith { }
                Mock Checkpoint-VM -MockWith { }
                Mock Get-VM -MockWith { }
                Mock New-LabImage -MockWith { }
                Mock Test-LabImage -MockWith { return $false; }
                Mock SetLabVirtualMachine -ParameterFilter { $null -ne $ConfigurationData } -MockWith { }

                $labVM = NewLabVM -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

                Assert-MockCalled SetLabVirtualMachine -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
            }

            It 'Warns when no client or root certificate is used' {
                <# NOTE: Must come last in the test suite as once we mock ResolveLabVMProperties, we're in trouble! #>
                $testVMName = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; }
                    )
                }
                $fakeVMProperties = @{
                    NodeName = $testVMName;
                    #RootCertificatePath = $null;
                    #ClientCertificatePath = $null;
                    Media = 'Test-Media';
                    SwitchName = 'Test Switch';
                    SecureBoot = $false;
                }
                Mock Resolve-NodePropertyValue -MockWith { return $fakeVMProperties; }

                { NewLabVM -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword -WarningAction Stop 3>&1 } | Should Throw;
            }

        } #end context Validates "NewLabVM" method

        Context 'Validates "RemoveLabVM" method' {

            It 'Throws when VM cannot be found' {
                $testVMName = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = '*' }
                    )
                }
                { RemoveLabVM -ConfigurationData $configurationData -Name $testVMName } | Should Throw;
            }

            It 'Removes all snapshots' {
                $testVMName = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; }
                    )
                }
                Mock RemoveLabVirtualMachine -MockWith { }
                Mock RemoveLabVMDisk -MockWith { }
                Mock RemoveLabSwitch -MockWith { }
                Mock RemoveLabVMSnapshot -ParameterFilter { $Name -eq $testVMName } -MockWith { }

                RemoveLabVM -ConfigurationData $configurationData -Name $testVMName;

                Assert-MockCalled RemoveLabVMSnapshot -ParameterFilter { $Name -eq $testVMName } -Scope It;
            }

            It 'Removes the virtual machine' {
                $testVMName = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; }
                    )
                }
                Mock RemoveLabVMDisk -MockWith { }
                Mock RemoveLabSwitch -MockWith { }
                Mock RemoveLabVMSnapshot -MockWith { }
                Mock RemoveLabVirtualMachine -ParameterFilter { $Name -eq $testVMName } -MockWith { }

                RemoveLabVM -ConfigurationData $configurationData -Name $testVMName;

                Assert-MockCalled RemoveLabVirtualMachine -ParameterFilter { $Name -eq $testVMName } -Scope It;
            }

            It 'Removes the VHDX file' {
                $testVMName = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; }
                    )
                }
                Mock RemoveLabSwitch -MockWith { }
                Mock RemoveLabVMSnapshot -MockWith { }
                Mock RemoveLabVirtualMachine -MockWith { }
                Mock RemoveLabVMDisk -ParameterFilter { $Name -eq $testVMName } -MockWith { }

                RemoveLabVM -ConfigurationData $configurationData -Name $testVMName;

                Assert-MockCalled RemoveLabVMDisk -ParameterFilter { $Name -eq $testVMName } -Scope It;
            }

            It 'Does not remove the virtual switch by default' {
                $testVMName = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; }
                    )
                }
                Mock RemoveLabSwitch -MockWith { }
                Mock RemoveLabVMSnapshot -MockWith { }
                Mock RemoveLabVirtualMachine -MockWith { }
                Mock RemoveLabVMDisk -MockWith { }

                RemoveLabVM -ConfigurationData $configurationData -Name $testVMName;

                Assert-MockCalled RemoveLabSwitch -Exactly 0 -Scope It;
            }

            It 'Removes the virtual switch when "RemoveSwitch" is specified' {
                $testVMName = 'TestVM';
                $testVMSwitch = 'Test Switch';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; SwitchName = $testVMSwitch; }
                    )
                }
                Mock RemoveLabVMSnapshot -MockWith { }
                Mock RemoveLabVirtualMachine -MockWith { }
                Mock RemoveLabVMDisk -MockWith { }
                Mock RemoveLabSwitch -ParameterFilter { $Name -eq $testVMSwitch } -MockWith { }

                RemoveLabVM -ConfigurationData $configurationData -Name $testVMName -RemoveSwitch;

                Assert-MockCalled RemoveLabSwitch -ParameterFilter { $Name -eq $testVMSwitch } -Scope It;
            }

            It 'Calls "RemoveLabVirtualMachine" with "ConfigurationData" (#97)' {
                $testVMName = 'TestVM';
                $testVMSwitch = 'Test Switch';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; SwitchName = $testVMSwitch; }
                    )
                }
                Mock RemoveLabVMSnapshot -MockWith { }
                Mock RemoveLabVMDisk -MockWith { }
                Mock RemoveLabSwitch -MockWith { }
                Mock RemoveLabVirtualMachine -ParameterFilter { $null -ne $configurationData } -MockWith { }

                RemoveLabVM -ConfigurationData $configurationData -Name $testVMName -RemoveSwitch;

                Assert-MockCalled RemoveLabVirtualMachine -ParameterFilter { $null -ne $configurationData } -Scope It;
            }

            It 'Calls "RemoveLabVMDisk" with "ConfigurationData" (#97)' {
                $testVMName = 'TestVM';
                $testVMSwitch = 'Test Switch';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; SwitchName = $testVMSwitch; }
                    )
                }
                Mock RemoveLabVMSnapshot -MockWith { }
                Mock RemoveLabSwitch -MockWith { }
                Mock RemoveLabVirtualMachine -MockWith { }
                Mock RemoveLabVMDisk -ParameterFilter { $null -ne $configurationData } -MockWith { }

                RemoveLabVM -ConfigurationData $configurationData -Name $testVMName -RemoveSwitch;

                Assert-MockCalled RemoveLabVMDisk -ParameterFilter { $null -ne $configurationData } -Scope It;
            }

        } #end context Validates "RemoveLabVM" method

    } #end InModuleScope

} # end describe Src\LabVM
