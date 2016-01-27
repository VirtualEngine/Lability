#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
if (!$PSScriptRoot) { # $PSScriptRoot is not defined in 2.0
    $PSScriptRoot = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
}
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;

Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'LabVM' {

    InModuleScope $moduleName {

        Context 'Validates "ResolveLabVMProperties" method' {

            It 'Returns a "System.Collections.Hashtable" object type' {
                $testVMName = 'TestVM';
                $testVMProcessorCount = 42;
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = '*'; ProcessorCount = 8; }
                        @{ NodeName = $testVMName; ProcessorCount = $testVMProcessorCount; }
                    )
                }
                
                $vmProperties = ResolveLabVMProperties -ConfigurationData $configurationData -NodeName $testVMName;
                
                $vmProperties -is [System.Collections.Hashtable] | Should Be $true;
            }

            It 'Returns node-specific configuration data when present' {
                $testVMName = 'TestVM';
                $testVMProcessorCount = 42;
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = '*'; ProcessorCount = 8; }
                        @{ NodeName = $testVMName; ProcessorCount = $testVMProcessorCount; }
                    )
                }
                
                $vmProperties = ResolveLabVMProperties -ConfigurationData $configurationData -NodeName $testVMName;

                $vmProperties.ProcessorCount | Should Be $testVMProcessorCount;
            }

            It 'Returns node-specific configuration data when present and "NoEnumerateWildcardNode" is specified' {
                $testVMName = 'TestVM';
                $testVMProcessorCount = 42;
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = '*'; ProcessorCount = 8; }
                        @{ NodeName = $testVMName; ProcessorCount = $testVMProcessorCount; }
                    )
                }
                
                $vmProperties = ResolveLabVMProperties -ConfigurationData $configurationData -NodeName $testVMName -NoEnumerateWildcardNode;

                $vmProperties.ProcessorCount | Should Be $testVMProcessorCount;
            }

            It 'Returns wildcard node when node-specific data is not defined' {
                $testVMName = 'TestVM';
                $testAllNodesProcessorCount = 42;
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = '*'; ProcessorCount = $testAllNodesProcessorCount; }
                        @{ NodeName = $testVMName; }
                    )
                }
                
                $vmProperties = ResolveLabVMProperties -ConfigurationData $configurationData -NodeName $testVMName;

                $vmProperties.ProcessorCount | Should Be $testAllNodesProcessorCount;
            }

            It 'Returns default when "NoEnumerateWildcardNode" is specified and node-specific data is not defined' {
                $testVMName = 'TestVM';
                $testAllNodesProcessorCount = 42;
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = '*'; ProcessorCount = $testAllNodesProcessorCount; }
                        @{ NodeName = $testVMName; }
                    )
                }

                $hostDefaultProperties = Get-LabVMDefault;
                $vmProperties = ResolveLabVMProperties -ConfigurationData $configurationData -NodeName $testVMName -NoEnumerateWildcardNode;

                $vmProperties.ProcessorCount | Should Be $hostDefaultProperties.ProcessorCount;
            }
            
            It 'Returns default if wildcard and node-specific data is not present' {
                $testVMName = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; }
                    )
                }

                $hostDefaultProperties = Get-LabVMDefault;
                $vmProperties = ResolveLabVMProperties -ConfigurationData $configurationData -NodeName $testVMName;

                $vmProperties.ProcessorCount | Should Be $hostDefaultProperties.ProcessorCount;
            }

            It "Returns ""$($labDefaults.moduleName)_"" specific properties over generic properties" {
                $testVMName = 'TestVM';
                $testVMProcessorCount = 42;
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; ProcessorCount = 99; "$($labDefaults.ModuleName)_ProcessorCount" = $testVMProcessorCount; }
                    )
                }
                
                $vmProperties = ResolveLabVMProperties -ConfigurationData $configurationData -NodeName $testVMName;
                
                $vmProperties.ProcessorCount | Should Be $testVMProcessorCount;
            }

        } #end context Validates "ResolveLabVMProperties" method

        Context 'Validates "Get-LabVM" method' {
            
            It 'Returns a "System.Management.Automation.PSCustomObject" object type' {
                $testVM = 'VM2';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = 'VM1'; }
                        @{ NodeName = $testVM; }
                    )
                }
                Mock ImportDscResource -MockWith { }
                Mock GetDscResource -MockWith { return @{ Name = $Parameters.Name; } }

                $vm = Get-LabVM -ConfigurationData $configurationData -Name $testVM;
                
                $vm -is [System.Management.Automation.PSCustomObject] | Should Be $true;
            }

            It 'Returns specific node when "Name" is specified' {
                $testVM = 'VM2';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = 'VM1'; }
                        @{ NodeName = $testVM; }
                    )
                }
                Mock ImportDscResource -MockWith { }
                Mock GetDscResource -MockWith { return @{ Name = $Parameters.Name; } }

                $vm = Get-LabVM -ConfigurationData $configurationData -Name $testVM;

                $vm.Count | Should BeNullOrEmpty;
                $vm | Should Not BeNullOrEmpty;
            }

            It 'Returns all nodes when "Name" is not specified' {
                $testVM = 'VM2';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = 'VM1'; }
                        @{ NodeName = $testVM; }
                    )
                }
                Mock ImportDscResource -MockWith { }
                Mock GetDscResource -MockWith { return @{ Name = $Parameters.Name; } }
                
                $vms = Get-LabVM -ConfigurationData $configurationData;

                $vms.Count | Should Be $configurationData.AllNodes.Count;
            }

            It 'Errors when node cannot be found' {
                $testVM = 'VM2';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = 'VM1'; }
                        @{ NodeName = $testVM; }
                    )
                }
                Mock ImportDscResource -MockWith { }
                Mock GetDscResource -MockWith { throw; }
                
                { Get-LabVM -ConfigurationData $configurationData -Name $testVM -ErrorAction Stop } | Should Throw;
            }

        } #end context Validates "Get-LabVM" method

        Context 'Validates "Test-LabVM" method' {
            
            It 'Returns a "System.Boolean" object type' {
                $testVM = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVM; }
                    )
                }
                Mock Test-LabImage -MockWith { return $true; }
                Mock TestLabSwitch -MockWith { return $true; }
                Mock TestLabVMDisk -MockWith { return $true; }
                Mock TestLabVirtualMachine -MockWith { return $true; }

                $vm = Test-LabVM -ConfigurationData $configurationData -Name $testVM;

                $vm -is [System.Boolean] | Should Be $true;
            }

            It 'Returns a result for each VM when "Name" is not specified' {
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = 'VM1'; }
                        @{ NodeName = 'VM2'; }
                    )
                }
                Mock Test-LabImage -MockWith { return $true; }
                Mock TestLabSwitch -MockWith { return $true; }
                Mock TestLabVMDisk -MockWith { return $true; }
                Mock TestLabVirtualMachine -MockWith { return $false; }

                $vms = Test-LabVM -ConfigurationData $configurationData;
                $vms.Count | Should Be $configurationData.AllNodes.Count;
            }
            
            It 'Passes when VM is configured correctly' {
                $testVM = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVM; }
                    )
                }
                Mock Test-LabImage -MockWith { return $true; }
                Mock TestLabSwitch -MockWith { return $true; }
                Mock TestLabVMDisk -MockWith { return $true; }
                Mock TestLabVirtualMachine -MockWith { return $true; }

                Test-LabVM -ConfigurationData $configurationData -Name $testVM | Should Be $true;
            }

            It 'Fails when image is invalid' {
                $testVM = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVM; }
                    )
                }
                Mock Test-LabImage -MockWith { return $false; }
                Mock TestLabSwitch -MockWith { return $true; }
                Mock TestLabVMDisk -MockWith { return $true; }
                Mock TestLabVirtualMachine -MockWith { return $true; }

                Test-LabVM -ConfigurationData $configurationData -Name $testVM | Should Be $false;
            }

            It 'Fails when switch configuration is incorrect' {
                $testVM = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVM; }
                    )
                }
                Mock Test-LabImage -MockWith { return $true; }
                Mock TestLabSwitch -MockWith { return $false; }
                Mock TestLabVMDisk -MockWith { return $true; }
                Mock TestLabVirtualMachine -MockWith { return $true; }

                Test-LabVM -ConfigurationData $configurationData -Name $testVM | Should Be $false;
            }

            It 'Fails when VM disk configuration is invalid' {
                $testVM = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVM; }
                    )
                }
                Mock Test-LabImage -MockWith { return $true; }
                Mock TestLabSwitch -MockWith { return $true; }
                Mock TestLabVMDisk -MockWith { return $false; }
                Mock TestLabVirtualMachine -MockWith { return $true; }

                Test-LabVM -ConfigurationData $configurationData -Name $testVM | Should Be $false;
            }

            It 'Fails when VM configuration is incorrect' {
                $testVM = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVM; }
                    )
                }
                Mock Test-LabImage -MockWith { return $true; }
                Mock TestLabSwitch -MockWith { return $true; }
                Mock TestLabVMDisk -MockWith { return $true; }
                Mock TestLabVirtualMachine -MockWith { return $false; }

                Test-LabVM -ConfigurationData $configurationData -Name $testVM | Should Be $false;
            }

        } #end context Validates "Test-LabVM" method

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
                Mock SetLabVMDiskResource -MockWith { }
                Mock SetLabVMDiskFile -MockWith { }
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
                Mock SetLabVMDiskResource -MockWith { }
                Mock SetLabVMDiskFile -MockWith { }
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
                Mock SetLabVMDiskResource -MockWith { }
                Mock SetLabVMDiskFile -MockWith { }
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
                Mock SetLabVMDiskResource -MockWith { }
                Mock SetLabVMDiskFile -MockWith { }
                Mock Checkpoint-VM -MockWith { }
                Mock Get-VM -MockWith { }
                Mock Test-LabImage -MockWith { return $true; }
                Mock New-LabImage -MockWith { }
                Mock SetLabSwitch -ParameterFilter { $Name -eq $testVMSwitch } -MockWith { }

                $labVM = NewLabVM -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

                Assert-MockCalled SetLabSwitch -ParameterFilter { $Name -eq $testVMSwitch } -Scope It;
            }

            It 'Does not call "SetLabSwitch" when "IsQuickVM" = "$true"' {
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
                Mock SetLabVMDiskResource -MockWith { }
                Mock SetLabVMDiskFile -MockWith { }
                Mock Checkpoint-VM -MockWith { }
                Mock Get-VM -MockWith { }
                Mock Test-LabImage -MockWith { return $true; }
                Mock New-LabImage -MockWith { }
                Mock SetLabSwitch -MockWith { }

                $labVM = NewLabVM -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword -IsQuickVM;

                Assert-MockCalled SetLabSwitch -Scope It -Exactly 0;
            
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
                Mock SetLabVirtualMachine -MockWith { }
                Mock SetLabVMDiskResource -MockWith { }
                Mock SetLabVMDiskFile -MockWith { }
                Mock Checkpoint-VM -MockWith { }
                Mock Get-VM -MockWith { }
                Mock Test-LabImage -MockWith { return $true; }
                Mock New-LabImage -MockWith { }
                Mock SetLabSwitch -MockWith { }
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
                Mock SetLabVMDiskResource -MockWith { }
                Mock SetLabVMDiskFile -MockWith { }
                Mock Checkpoint-VM -MockWith { }
                Mock Get-VM -MockWith { }
                Mock Test-LabImage -MockWith { return $true; }
                Mock New-LabImage -MockWith { }
                Mock SetLabSwitch -MockWith { }
                Mock ResetLabVMDisk -MockWith { }
                Mock SetLabVirtualMachine -ParameterFilter { $Name -eq $testVMName } -MockWith { }

                $labVM = NewLabVM -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

                Assert-MockCalled SetLabVirtualMachine -ParameterFilter { $Name -eq $testVMName } -Scope It;
            }

            It 'Injects VM DSC custom resources' {
                $testVMName = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; Resource = 'TestResource'; }
                    )
                }
                Mock ResolveLabMedia -MockWith { return $Id; }
                Mock SetLabVMDiskFile -MockWith { }
                Mock Checkpoint-VM -MockWith { }
                Mock Get-VM -MockWith { }
                Mock Test-LabImage -MockWith { return $true; }
                Mock New-LabImage -MockWith { }
                Mock SetLabSwitch -MockWith { }
                Mock ResetLabVMDisk -MockWith { }
                Mock SetLabVirtualMachine -MockWith { }
                Mock SetLabVMDiskResource -ParameterFilter { $Name -eq $testVMName } -MockWith { }

                $labVM = NewLabVM -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

                Assert-MockCalled SetLabVMDiskResource -ParameterFilter { $Name -eq $testVMName } -Scope It;
            }

            It 'Injects VM DSC resources and certificates' {
                $testVMName = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; }
                    )
                }
                Mock ResolveLabMedia -MockWith { return $Id; }
                Mock Checkpoint-VM -MockWith { }
                Mock Get-VM -MockWith { }
                Mock Test-LabImage -MockWith { return $true; }
                Mock New-LabImage -MockWith { }
                Mock SetLabSwitch -MockWith { }
                Mock ResetLabVMDisk -MockWith { }
                Mock SetLabVirtualMachine -MockWith { }
                Mock SetLabVMDiskResource -MockWith { }
                Mock SetLabVMDiskFile -ParameterFilter { $Name -eq $testVMName } -MockWith { }

                $labVM = NewLabVM -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

                Assert-MockCalled SetLabVMDiskFile -ParameterFilter { $Name -eq $testVMName } -Scope It;
            }

            It 'Uses CoreCLR bootstrap when "SetupComplete" is specified' {
                $testVMName = 'TestVM';
                $testCustomBootStrap = 'Write-Host "CustomBootstrap";';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; }
                    )
                }
                Mock ResolveLabMedia -MockWith { return [PSCustomObject] @{ Id = $Id; CustomData = @{ SetupComplete = 'CoreCLR'; }; }; }
                Mock Checkpoint-VM -MockWith { }
                Mock Get-VM -MockWith { }
                Mock Test-LabImage -MockWith { return $true; }
                Mock New-LabImage -MockWith { }
                Mock SetLabSwitch -MockWith { }
                Mock ResetLabVMDisk -MockWith { }
                Mock SetLabVirtualMachine -MockWith { }
                Mock SetLabVMDiskResource -MockWith { }
                Mock SetLabVMDiskFile -ParameterFilter { $CoreCLR -eq $true } -MockWith { }

                $labVM = NewLabVM -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

                Assert-MockCalled SetLabVMDiskFile -ParameterFilter { $CoreCLR -eq $true } -Scope It;
            }

            It 'Injects a custom bootstrap when "CustomBootStrap" is specified' {
                $testVMName = 'TestVM';
                $testCustomBootStrap = 'Write-Host "CustomBootstrap";';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; CustomBootStrap = $testCustomBootStrap; }
                    )
                }
                Mock ResolveLabMedia -MockWith { return $Id; }
                Mock Checkpoint-VM -MockWith { }
                Mock Get-VM -MockWith { }
                Mock Test-LabImage -MockWith { return $true; }
                Mock New-LabImage -MockWith { }
                Mock SetLabSwitch -MockWith { }
                Mock ResetLabVMDisk -MockWith { }
                Mock SetLabVirtualMachine -MockWith { }
                Mock SetLabVMDiskResource -MockWith { }
                Mock SetLabVMDiskFile -ParameterFilter { $CustomBootStrap -ne $null } -MockWith { }

                $labVM = NewLabVM -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

                Assert-MockCalled SetLabVMDiskFile -ParameterFilter { $CustomBootStrap -ne $null } -Scope It;
            }

            It 'Creates a VM snapshot by default' {
                $testVMName = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; }
                    )
                }
                Mock ResolveLabMedia -MockWith { return $Id; }
                Mock Get-VM -MockWith { }
                Mock Test-LabImage -MockWith { return $true; }
                Mock New-LabImage -MockWith { }
                Mock SetLabSwitch -MockWith { }
                Mock ResetLabVMDisk -MockWith { }
                Mock SetLabVirtualMachine -MockWith { }
                Mock SetLabVMDiskResource -MockWith { }
                Mock SetLabVMDiskFile -MockWith { }
                Mock Checkpoint-VM -ParameterFilter { $Name -eq $testVMName } -MockWith { }

                $labVM = NewLabVM -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword;

                Assert-MockCalled Checkpoint-VM -ParameterFilter { $Name -eq $testVMName } -Scope It;
            }

            It 'Does not create a snapshot when "NoSnapshot" is specified' {
                $testVMName = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; }
                    )
                }
                Mock ResolveLabMedia -MockWith { return $Id; }
                Mock Get-VM -MockWith { }
                Mock Test-LabImage -MockWith { return $true; }
                Mock New-LabImage -MockWith { }
                Mock SetLabSwitch -MockWith { }
                Mock ResetLabVMDisk -MockWith { }
                Mock SetLabVirtualMachine -MockWith { }
                Mock SetLabVMDiskResource -MockWith { }
                Mock SetLabVMDiskFile -MockWith { }
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
                Mock Get-VM -MockWith { }
                Mock Test-LabImage -MockWith { return $true; }
                Mock New-LabImage -MockWith { }
                Mock SetLabSwitch -MockWith { }
                Mock ResetLabVMDisk -MockWith { }
                Mock SetLabVirtualMachine -MockWith { }
                Mock SetLabVMDiskResource -MockWith { }
                Mock SetLabVMDiskFile -MockWith { }
                Mock Checkpoint-VM -MockWith { }

                { NewLabVM -ConfigurationData $configurationData -Name $testVMName -Path 'TestDrive:\' -Credential $testPassword -NoSnapshot -WarningAction Stop 3>&1 } | Should Throw;
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
                Mock ResolveLabVMProperties -MockWith { return $fakeVMProperties; }
                
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

        } #end context Validates "RemoveLabVM" method

        Context 'Validates "Reset-LabVM" method' {

            $testPassword = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);

            It 'Removes existing virtual machine' {
                $testVMName = 'TestVM';
                $configurationData = @{
                    AllNodes = @(
                        @{ NodeName = $testVMName; }
                    )
                }
                Mock NewLabVM -ParameterFilter { $NoSnapShot -eq $false } -MockWith { }
                Mock RemoveLabVM -ParameterFilter { $Name -eq $testVMName } -MockWith { }

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
                Mock RemoveLabVM -ParameterFilter { $Name -eq $testVMName } -MockWith { }
                Mock NewLabVM -ParameterFilter { $NoSnapShot -eq $false } -MockWith { }

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
                Mock RemoveLabVM -ParameterFilter { $Name -eq $testVMName } -MockWith { }
                Mock NewLabVM -ParameterFilter { $NoSnapShot -eq $true } -MockWith { }

                Reset-LabVM -ConfigurationData $configurationData -Name $testVMName -Credential $testPassword -NoSnapshot;

                Assert-MockCalled NewLabVM -ParameterFilter { $NoSnapShot -eq $true } -Scope It;
            }

        } #end context Validates "Reset-LabVM" method

    } #end InModuleScope

} # end describe LabVM
