[CmdletBinding()]
Param (

)

if (!$PSScriptRoot) # $PSScriptRoot is not defined in 2.0
{
    $PSScriptRoot = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
}

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version latest

$RepoRoot = (Resolve-Path $PSScriptRoot\..\..).Path

$ModuleName = 'MSFT_xVMSwitch'
Import-Module (Join-Path $RepoRoot "DSCResources\$ModuleName\$ModuleName.psm1") -Force;

Describe 'xVMSwitch' {
    InModuleScope $ModuleName {

        # Defines a variable that contains all the possible Bandwidth Reservation Modes which will be used
        # for foreach loops later on
        New-Variable -Name 'BANDWIDTH_RESERVATION_MODES' -Option 'Constant' -Value @('Default','Weight','Absolute','None')

        # A helper function to mock a VMSwitch
        function New-MockedVMSwitch {
            Param (
                [Parameter(Mandatory=$true)]
                [string]$Name,
                [Parameter(Mandatory=$true)]
                [ValidateSet('Default','Weight','Absolute','None','NA')]
                [string]$BandwidthReservationMode,
                [bool]$AllowManagementOS = $false
            )

            $mockedVMSwitch = @{
                Name = $Name
                SwitchType = 'External'
                AllowManagementOS = $AllowManagementOS
                NetAdapterInterfaceDescription = 'Microsoft Network Adapter Multiplexor Driver'
            }

            if ($BandwidthReservationMode -ne 'NA') {
                $mockedVMSwitch['BandwidthReservationMode'] = $BandwidthReservationMode
            }

            return [PsObject]$mockedVMSwitch
        }

        # Create an empty function to be able to mock the missing Hyper-V cmdlet
        function Get-VMSwitch {
            [CmdletBinding()]
            Param(
                [string]$Name,
                [string]$SwitchType
            )
        }

        # Create an empty function to be able to mock the missing Hyper-V cmdlet
        function New-VMSwitch {
            [CmdletBinding()]
            Param(
                [string]$Name,
                [string]$MinimumBandwidthMode,
                [string]$NetAdapterName,
                [bool]$AllowManagementOS = $false
            )
        }

        # Create an empty function to be able to mock the missing Hyper-V cmdlet
        function Remove-VMSwitch {
        
        }

        # Create an empty function to be able to mock the missing Hyper-V cmdlet
        function Set-VMSwitch {
            [CmdletBinding()]
            Param (
                [bool]$AllowManagementOS
            )
        }



        # Mocks Get-VMSwitch and will return $global:mockedVMSwitch which is
        # a variable that is created during most It statements to mock a VMSwitch
        Mock -CommandName Get-VMSwitch -MockWith {
            Param (
                [string]$ErrorAction
            )

            if ($ErrorAction -eq 'Stop' -and $global:mockedVMSwitch -eq $null) {
                throw [System.Management.Automation.ActionPreferenceStopException]'No switch can be found by given criteria.'
            }

            return $global:mockedVMSwitch
        }

        # Mocks New-VMSwitch and will assign a mocked switch to $global:mockedVMSwitch. This returns $global:mockedVMSwitch
        # which is a variable that is created during most It statements to mock a VMSwitch
        Mock -CommandName New-VMSwitch -MockWith {
            Param (
                [string]$Name,
                [string]$NetAdapterName,
                [string]$MinimumBandwidthMode,
                [bool]$AllowManagementOS
            )
            
            $global:mockedVMSwitch = New-MockedVMSwitch -Name $Name -BandwidthReservationMode $MinimumBandwidthMode -AllowManagementOS $AllowManagementOS
            return $global:mockedVMSwitch
        }

        # Mocks Set-VMSwitch and will modify $global:mockedVMSwitch which is
        # a variable that is created during most It statements to mock a VMSwitch
        Mock -CommandName Set-VMSwitch -MockWith {
            Param (
                [bool]$AllowManagementOS
            )
            
            if ($AllowManagementOS) {
                $global:mockedVMSwitch['AllowManagementOS'] = $AllowManagementOS
            }
        }

        # Mocks Remove-VMSwitch and will remove the variable $global:mockedVMSwitch which is
        # a variable that is created during most It statements to mock a VMSwitch
        Mock -CommandName Remove-VMSwitch -MockWith {
            $global:mockedVMSwitch = $null
        }

        # Mocks Get-NetAdapter which returns a simplified network adapter
        Mock -CommandName Get-NetAdapter -MockWith {
            return [PSCustomObject]@{
                Name = 'SomeNIC'
                InterfaceDescription = 'Microsoft Network Adapter Multiplexor Driver'
            }
        }

        # Mocks "Get-Module -Name Hyper-V" so that the DSC resource thinks the Hyper-V module is on the test system
        Mock -CommandName Get-Module -ParameterFilter { ($Name -eq 'Hyper-V') -and ($ListAvailable -eq $true) } -MockWith {
            return $true
        }

        # Mock "Get-WmiObject -Class -eq 'Win32_OperatingSystem'" to output a valid Windows version that supports BandwidthReservationMode
        Mock -CommandName Get-WmiObject -ParameterFilter { $Class -eq 'Win32_OperatingSystem' } -MockWith {
            return [PSCustomObject]@{
                Version = '6.3.9600'
            }
        }



        # Create all the test cases for Get-TargetResource
        $getTestCases = @()
        foreach ($brmMode in $BANDWIDTH_RESERVATION_MODES) {
            $getTestCases += @{
                CurrentName = $brmMode + 'BRM'
                CurrentBandwidthReservationMode = $brmMode
            }
        }
        
        Context 'Validates Get-TargetResource Function' {

            # Test Get-TargetResource with the test cases created above 
            It 'Current switch''s BandwidthReservationMode is set to <CurrentBandwidthReservationMode>' -TestCases $getTestCases {
                Param (
                    [string]$CurrentName,
                    [string]$CurrentBandwidthReservationMode
                )

                # Set the mocked VMSwitch to be returned from Get-VMSwitch based on the input from $getTestCases
                $global:mockedVMSwitch = New-MockedVMSwitch -Name $CurrentName -BandwidthReservationMode $CurrentBandwidthReservationMode

                $targetResource = Get-TargetResource -Name $CurrentName -Type 'External'
                $targetResource -is [System.Collections.Hashtable] | Should Be $true
                $targetResource['BandwidthReservationMode'] | Should Be $CurrentBandwidthReservationMode

                Remove-Variable -Scope 'Global' -Name 'mockedVMSwitch' -ErrorAction 'SilentlyContinue'
            }

            # Test Get-TargetResource when the VMSwitch's BandwidthReservationMode member variable is not
            # set which simulates older versions of Windows that don't support it
            It 'BandwidthReservationMode is set to null' {

                # Set the mocked VMSwitch to be returned from Get-VMSwitch
                $global:mockedVMSwitch = New-MockedVMSwitch -Name 'NaBRM' -BandwidthReservationMode 'NA'

                $targetResource = Get-TargetResource -Name 'NaBRM' -Type 'External'
                $targetResource -is [System.Collections.Hashtable] | Should Be $true
                $targetResource['BandwidthReservationMode'] | Should Be $null

                Remove-Variable -Scope 'Global' -Name 'mockedVMSwitch' -ErrorAction 'SilentlyContinue'
            }
        }



        # Create all the test cases for Test-TargetResource and Set-TargetResource when the switch already exists
        $testSetTestCases = @()
        foreach ($currentBrmMode in $BANDWIDTH_RESERVATION_MODES) {

            foreach ($desiredBrmMode in $BANDWIDTH_RESERVATION_MODES) {

                foreach ($ensureOption in @('Present', 'Absent')) {
                    $case = @{
                        CurrentName = $currentBrmMode + 'BRM'
                        CurrentBandwidthReservationMode = $currentBrmMode
                        DesiredName = $desiredBrmMode + 'BRM'
                        DesiredBandwidthReservationMode = $desiredBrmMode
                        Ensure = $ensureOption
                        ExpectedResult = $ensureOption -eq 'Present' -and $currentBrmMode -eq $desiredBrmMode
                    }

                    $testSetTestCases += $case
                }
            }
        }

        # Create all the test cases for Test-TargetResource and Set-TargetResource when the switch does not exists
        foreach ($desiredBrmMode in $BANDWIDTH_RESERVATION_MODES) {

                foreach ($ensureOption in @('Present', 'Absent')) {
                    
                    $case = @{
                        CurrentName = $null
                        CurrentBandwidthReservationMode = $null
                        DesiredName = $desiredBrmMode + 'BRM'
                        DesiredBandwidthReservationMode = $desiredBrmMode
                        Ensure = $ensureOption
                        ExpectedResult = $ensureOption -eq 'Absent'
                    }

                    $testSetTestCases += $case
                }
        }

        Context 'Validates Test-TargetResource Function' {

            # Test Test-TargetResource with the test cases created above 
            It 'Current Name "<CurrentName>" | Current BandwidthReservationMode set to "<CurrentBandwidthReservationMode>" | Desired BandwidthReservationMode set to "<DesiredBandwidthReservationMode>" | Ensure "<Ensure>"' -TestCases $testSetTestCases {
                Param (
                    [string]$CurrentName,
                    [string]$CurrentBandwidthReservationMode,
                    [string]$DesiredName,
                    [string]$DesiredBandwidthReservationMode,
                    [string]$Ensure,
                    [bool]$ExpectedResult
                )

                # Set the mocked VMSwitch to be returned from Get-VMSwitch if the switch exists
                if ($CurrentName) {
                    $global:mockedVMSwitch = New-MockedVMSwitch -Name $CurrentName -BandwidthReservationMode $CurrentBandwidthReservationMode -AllowManagementOS $true
                }

                $targetResource = Test-TargetResource -Name $DesiredName -BandwidthReservationMode $DesiredBandwidthReservationMode -Type 'External' -NetAdapterName 'SomeNIC' -Ensure $Ensure -AllowManagementOS $true
                $targetResource | Should Be $ExpectedResult

                Remove-Variable -Scope 'Global' -Name 'mockedVMSwitch' -ErrorAction 'SilentlyContinue'
            }

            # Mock "Get-WmiObject -Class -eq 'Win32_OperatingSystem'" to output an Windows version that does not support BandwidthReservationMode
            Mock -CommandName Get-WmiObject -ParameterFilter { $Class -eq 'Win32_OperatingSystem' } -MockWith {
                return [PSCustomObject]@{
                    Version = '6.1.7601'
                }
            }

            # Test Test-TargetResource when the version of Windows doesn't support BandwidthReservationMode
            It 'Invalid Operating System Exception' {
                {Test-TargetResource -Name 'WeightBRM' -Type 'External' -NetAdapterName 'SomeNIC' -AllowManagementOS $true -BandwidthReservationMode 'Weight' -Ensure 'Present'} | Should Throw 'The BandwidthReservationMode cannot be set on a Hyper-V version lower than 2012'
            }

            # Test Test-TargetResource when the version of Windows doesn't support BandwidthReservationMode and specifies NA for BandwidthReservationMode
            It 'Simulates Windows Server 2008 R2 | Desired BandwidthReservationMode set to "NA" | Ensure Present | Expected Result is True'  {

                $global:mockedVMSwitch = New-MockedVMSwitch -Name 'SomeSwitch' -BandwidthReservationMode 'NA' -AllowManagementOS $true
                $targetResource = Test-TargetResource -Name 'SomeSwitch' -BandwidthReservationMode 'NA' -Type 'External' -NetAdapterName 'SomeNIC' -Ensure 'Present' -AllowManagementOS $true
                $targetResource | Should Be $true
            }
        }



        Context 'Validates Set-TargetResource Function' {

            It 'Current Name "<CurrentName>" | Current BandwidthReservationMode set to "<CurrentBandwidthReservationMode>" | Desired BandwidthReservationMode set to "<DesiredBandwidthReservationMode>" | Ensure "<Ensure>"' -TestCases $testSetTestCases {
                Param (
                    [string]$CurrentName,
                    [string]$CurrentBandwidthReservationMode,
                    [string]$DesiredName,
                    [string]$DesiredBandwidthReservationMode,
                    [string]$Ensure,
                    [bool]$ExpectedResult
                )

                # Set the mocked VMSwitch to be returned from Get-VMSwitch if the switch exists
                if ($CurrentName) {
                    $global:mockedVMSwitch = New-MockedVMSwitch -Name $CurrentName -BandwidthReservationMode $CurrentBandwidthReservationMode -AllowManagementOS $true
                }

                $targetResource = Set-TargetResource -Name $DesiredName -BandwidthReservationMode $DesiredBandwidthReservationMode -Type 'External' -NetAdapterName 'SomeNIC' -Ensure $Ensure -AllowManagementOS $true
                $targetResource | Should Be $null

                if ($CurrentName -and $Ensure -eq 'Present') {

                    if ($DesiredBandwidthReservationMode -ne $CurrentBandwidthReservationMode) {
                        Assert-MockCalled -CommandName Get-VMSwitch -Times 2 -Scope 'It'
                        Assert-MockCalled -CommandName Remove-VMSwitch -Times 1 -Scope 'It'
                        Assert-MockCalled -CommandName New-VMSwitch -Times 1 -Scope 'It'
                        Assert-MockCalled -CommandName Set-VMSwitch -Times 0 -Scope 'It'
                    }
                    else {
                        Assert-MockCalled -CommandName Get-VMSwitch -Times 1 -Scope 'It'
                    }
                }
                elseif ($Ensure -eq 'Present') {
                    Assert-MockCalled -CommandName Get-VMSwitch -Times 1 -Scope 'It'
                    Assert-MockCalled -CommandName New-VMSwitch -Times 1 -Scope 'It'

                }
                else {
                    Assert-MockCalled -CommandName Get-VMSwitch -Times 1 -Scope 'It'
                    Assert-MockCalled -CommandName Remove-VMSwitch -Times 1 -Scope 'It'
                }

                Remove-Variable -Scope 'Global' -Name 'mockedVMSwitch' -ErrorAction 'SilentlyContinue'
            }

            
            # Test Set-TargetResource when the version of Windows doesn't support BandwidthReservationMode
            It 'Invalid Operating System Exception' {

                Mock -CommandName Get-WmiObject -ParameterFilter { $Class -eq 'Win32_OperatingSystem' } -MockWith {
                    return [PSCustomObject]@{
                        Version = '6.1.7601'
                    }
                }

                {Set-TargetResource -Name 'WeightBRM' -Type 'External' -NetAdapterName 'SomeNIC' -AllowManagementOS $true -BandwidthReservationMode 'Weight' -Ensure 'Present'} | Should Throw 'The BandwidthReservationMode cannot be set on a Hyper-V version lower than 2012'
            }
        }
    }
}
