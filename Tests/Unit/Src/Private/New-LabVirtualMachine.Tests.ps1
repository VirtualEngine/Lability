#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Unit\Src\Private\New-LabVirtualMachine' {

    InModuleScope -ModuleName $moduleName {

        $testPassword = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);

        It 'Throws when "ClientCertificatePath" cannot be found' {
            $testVMName = 'TestVM';
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = $testVMName; ClientCertificatePath = 'TestDrive:'; }
                )
            }

            { New-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword } | Should Throw;
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
            Mock Set-LabVirtualMachine -MockWith { }
            Mock Set-LabVMDiskFile -MockWith { }
            Mock Checkpoint-VM -MockWith { }
            Mock Get-VM -MockWith { }
            Mock Test-LabImage -MockWith { return $false; }
            Mock New-LabImage -MockWith { }

            { New-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword -IsQuickVM } | Should Not Throw;
        }

        It 'Throws when "RootCertificatePath" cannot be found' {
            $testVMName = 'TestVM';
            $configurationData = @{
                AllNodes = @(
                    @{ NodeName = $testVMName; RootCertificatePath = 'TestDrive:'; }
                )
            }

            { New-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword } | Should Throw;
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
            Mock Set-LabVirtualMachine -MockWith { }
            Mock Set-LabVMDiskFile -MockWith { }
            Mock Checkpoint-VM -MockWith { }
            Mock Get-VM -MockWith { }
            Mock Test-LabImage -MockWith { return $false; }
            Mock New-LabImage -MockWith { }

            { New-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword -IsQuickVM } | Should Not Throw;
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
            Mock Set-LabVirtualMachine -MockWith { }
            Mock Set-LabVMDiskFile -MockWith { }
            Mock Checkpoint-VM -MockWith { }
            Mock Get-VM -MockWith { }
            Mock Test-LabImage -ParameterFilter { $Id -eq $testMedia } -MockWith { return $false; }
            Mock New-LabImage -ParameterFilter { $Id -eq $testMedia } -MockWith { }

            $labVM = New-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

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
            Mock Set-LabVirtualMachine -MockWith { }
            Mock Set-LabVMDiskFile -MockWith { }
            Mock Checkpoint-VM -MockWith { }
            Mock Get-VM -MockWith { }
            Mock Test-LabImage -MockWith { return $true; }
            Mock New-LabImage -MockWith { }
            Mock SetLabSwitch -ParameterFilter { $Name -eq $testVMSwitch } -MockWith { }

            $labVM = New-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

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
            Mock Set-LabVirtualMachine -MockWith { }
            Mock Set-LabVMDiskFile -MockWith { }
            Mock Checkpoint-VM -MockWith { }
            Mock Get-VM -MockWith { }
            Mock Test-LabImage -MockWith { return $true; }
            Mock New-LabImage -MockWith { }
            Mock SetLabSwitch -ParameterFilter { $Name -eq $testVMSwitch } -MockWith { }

            $labVM = New-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

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
            Mock Set-LabVirtualMachine -MockWith { }
            Mock Set-LabVMDiskFile -MockWith { }
            Mock Checkpoint-VM -MockWith { }
            Mock Get-VM -MockWith { }
            Mock Test-LabImage -MockWith { return $true; }
            Mock New-LabImage -MockWith { }
            Mock ResetLabVMDisk -ParameterFilter { $Name -eq $testVMName -and $Media -eq $testMedia } -MockWith { }

            $labVM = New-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

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
            Mock Set-LabVirtualMachine -ParameterFilter { $Name -eq $testVMName } -MockWith { }

            $labVM = New-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

            Assert-MockCalled Set-LabVirtualMachine -ParameterFilter { $Name -eq $testVMName } -Scope It;
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
            Mock Set-LabVirtualMachine -ParameterFilter { $GuestIntegrationServices -eq $true } -MockWith { }

            $labVM = New-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

            Assert-MockCalled Set-LabVirtualMachine -ParameterFilter { $GuestIntegrationServices -eq $true } -Scope It;
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
            Mock Set-LabVirtualMachine -MockWith { }
            Mock ResolveLabMedia -MockWith { return @{ Id = $Id; OperatingSystem = 'Linux'; } }
            Mock Set-LabVMDiskFile -MockWith { }

            $labVM = New-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

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
            Mock Set-LabVirtualMachine -MockWith { }
            Mock Checkpoint-VM -MockWith { }
            Mock Get-VM -MockWith { }
            Mock Test-LabImage -MockWith { return $true; }
            Mock New-LabImage -MockWith { }
            #Mock Set-LabVMDiskFile -ParameterFilter { $NodeName -eq $testVMName } -MockWith { }
            Mock Set-LabVMDiskFile -MockWith { }

            $labVM = New-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

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
            Mock Set-LabVirtualMachine -MockWith { }
            Mock Checkpoint-VM -MockWith { }
            Mock Get-VM -MockWith { }
            Mock Test-LabImage -MockWith { return $true; }
            Mock New-LabImage -MockWith { }
            Mock Set-LabVMDiskFile -MockWith { }

            $labVM = New-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

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
            Mock Set-LabVirtualMachine -MockWith { }
            Mock Set-LabVMDiskFile -MockWith { }
            Mock Get-VM -MockWith { }
            Mock Test-LabImage -MockWith { return $true; }
            Mock New-LabImage -MockWith { }
            Mock Checkpoint-VM -MockWith { }

            $labVM = New-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword -NoSnapshot;

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
            Mock Set-LabVirtualMachine -MockWith { }
            Mock Set-LabVMDiskFile -MockWith { }
            Mock Get-VM -MockWith { }
            Mock Test-LabImage -MockWith { return $true; }
            Mock New-LabImage -MockWith { }
            Mock Checkpoint-VM -MockWith { }

            { New-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword -NoSnapshot -WarningAction Stop 3>&1 } | Should Throw;
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
            Mock Set-LabVirtualMachine -MockWith { }
            Mock Set-LabVMDiskFile -MockWith { }
            Mock Checkpoint-VM -MockWith { }
            Mock Get-VM -MockWith { }
            Mock New-LabImage -MockWith { }
            Mock Test-LabImage -ParameterFilter { $null -ne $ConfigurationData } -MockWith { return $false; }

            $labVM = New-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

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
            Mock Set-LabVirtualMachine -MockWith { }
            Mock Set-LabVMDiskFile -MockWith { }
            Mock Checkpoint-VM -MockWith { }
            Mock Get-VM -MockWith { }
            Mock New-LabImage -MockWith { }
            Mock Test-LabImage -MockWith { return $false; }
            Mock ResetLabVMDisk -ParameterFilter { $null -ne $ConfigurationData } -MockWith { }

            $labVM = New-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

            Assert-MockCalled ResetLabVMDisk -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
        }

        It 'Calls "Set-LabVirtualMachine" with "ConfigurationData" (#97)' {
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
            Mock Set-LabVirtualMachine -ParameterFilter { $null -ne $ConfigurationData } -MockWith { }

            $labVM = New-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

            Assert-MockCalled Set-LabVirtualMachine -ParameterFilter { $null -ne $ConfigurationData } -Scope It;
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

            { New-LabVirtualMachine -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword -WarningAction Stop 3>&1 } | Should Throw;
        }

    } #end InModuleScope

} #end describe
