$script:dscResourceCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath '../../Modules/DscResource.Common'
$script:hyperVDscCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath '../../Modules/HyperVDsc.Common'

Import-Module -Name $script:dscResourceCommonModulePath
Import-Module -Name $script:hyperVDscCommonModulePath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

<#
.SYNOPSIS
    Gets MSFT_xVMSwitch resource current state.

.PARAMETER Name
    Name of the VM Switch.

.PARAMETER Type
    Type of switch.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet('External', 'Internal', 'Private')]
        [System.String]
        $Type
    )

    Write-Verbose -Message "Getting settings for VM Switch '$Name'"

    # Check if Hyper-V module is present for Hyper-V cmdlets
    if (!(Get-Module -ListAvailable -Name Hyper-V))
    {
        $errorMessage = $script:localizedData.HyperVNotInstalledError

        New-ObjectNotFoundException -Message $errorMessage
    }

    $switch = Get-VMSwitch -Name $Name -SwitchType $Type -ErrorAction SilentlyContinue

    if ($null -ne $switch)
    {
        $ensure = 'Present'
        if ($switch.SwitchType -eq 'External')
        {
            if ($switch.EmbeddedTeamingEnabled -ne $true)
            {
                $netAdapterName = (Get-NetAdapter -InterfaceDescription $switch.NetAdapterInterfaceDescription -ErrorAction SilentlyContinue).Name
                $description = $switch.NetAdapterInterfaceDescription

                $loadBalancingAlgorithm = 'NA'
            }
            else
            {
                $netAdapterName = (Get-NetAdapter -InterfaceDescription $switch.NetAdapterInterfaceDescriptions).Name
                $description = $switch.NetAdapterInterfaceDescriptions

                $loadBalancingAlgorithm = ($switch | Get-VMSwitchTeam).LoadBalancingAlgorithm.toString()
            }
        }
        else
        {
            $netAdapterName = $null
            $description = $null
        }
    }
    else
    {
        $ensure = 'Absent'
    }

    $returnValue = @{
        Name                           = $switch.Name
        Type                           = $switch.SwitchType
        NetAdapterName                 = [System.String[]] $netAdapterName
        AllowManagementOS              = $switch.AllowManagementOS
        EnableEmbeddedTeaming          = $switch.EmbeddedTeamingEnabled
        LoadBalancingAlgorithm         = $loadBalancingAlgorithm
        Ensure                         = $ensure
        Id                             = $switch.Id
        NetAdapterInterfaceDescription = $description
    }

    if ($null -ne $switch.BandwidthReservationMode)
    {
        $returnValue['BandwidthReservationMode'] = $switch.BandwidthReservationMode
    }
    else
    {
        $returnValue['BandwidthReservationMode'] = 'NA'
    }

    return $returnValue
}

<#
.SYNOPSIS
    Configures MSFT_xVMSwitch resource state.

.PARAMETER Name
    Name of the VM Switch.

.PARAMETER Type
    Type of switch.

.PARAMETER NetAdapterName
    Network adapter name(s) for external switch type.

.PARAMETER AllowManagementOS
    Specify if the VM host has access to the physical NIC.

.PARAMETER EnableEmbeddedTeaming
    Should embedded NIC teaming be used (Windows Server 2016 only).

.PARAMETER BandwidthReservationMode
    Type of Bandwidth Reservation Mode to use for the switch.

.PARAMETER LoadBalancingAlgorithm
    The load balancing algorithm that this switch team use.

.PARAMETER Id
    Desired unique ID of the Hyper-V Switch (Windows Server 2016 only).

.PARAMETER Ensure
    Whether switch should be present or absent.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet('External', 'Internal', 'Private')]
        [System.String]
        $Type,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $NetAdapterName,

        [Parameter()]
        [System.Boolean]
        $AllowManagementOS = $false,

        [Parameter()]
        [System.Boolean]
        $EnableEmbeddedTeaming = $false,

        [Parameter()]
        [ValidateSet('Default', 'Weight', 'Absolute', 'None', 'NA')]
        [System.String]
        $BandwidthReservationMode = 'NA',

        [Parameter()]
        [ValidateSet('Dynamic', 'HyperVPort')]
        [System.String]
        $LoadBalancingAlgorithm,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript(
            {
                $testGuid = New-Guid
                if ([guid]::TryParse($_, [ref]$testGuid))
                {
                    return $true
                }
                else
                {
                    throw 'The VMSwitch Id must be in GUID format!'
                }
            }
        )]
        [System.String]
        $Id,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    # Check if Hyper-V module is present for Hyper-V cmdlets
    if (!(Get-Module -ListAvailable -Name Hyper-V))
    {
        $errorMessage = $script:localizedData.HyperVNotInstalledError

        New-ObjectNotFoundException -Message $errorMessage
    }

    # Check to see if the BandwidthReservationMode chosen is supported in the OS
    elseif (($BandwidthReservationMode -ne 'NA') -and ((Get-OSVersion) -lt [version]'6.2.0'))
    {
        $errorMessage = $script:localizedData.BandwidthReservationModeError

        New-InvalidOperationException -Message $errorMessage
    }

    if ($EnableEmbeddedTeaming -eq $true -and (Get-OSVersion).Major -lt 10)
    {
        $errorMessage = $script:localizedData.SETServer2016Error

        New-InvalidOperationException -Message $errorMessage
    }

    if (($PSBoundParameters.ContainsKey('Id')) -and (Get-OSVersion).Major -lt 10)
    {
        $errorMessage = $script:localizedData.VMSwitchIDServer2016Error

        New-InvalidOperationException -Message $errorMessage
    }

    if ($Ensure -eq 'Present')
    {
        $switch = (Get-VMSwitch -Name $Name -SwitchType $Type -ErrorAction SilentlyContinue)

        # If switch is present and it is external type, that means it doesn't have right properties (TEST code ensures that)
        if ($switch -and ($switch.SwitchType -eq 'External'))
        {
            $removeReaddSwitch = $false

            Write-Verbose -Message ($script:localizedData.CheckingSwitchMessage -f $Name)
            if ($switch.EmbeddedTeamingEnabled -eq $false -or $null -eq $switch.EmbeddedTeamingEnabled)
            {
                if ((Get-NetAdapter -Name $NetAdapterName).InterfaceDescription -ne $switch.NetAdapterInterfaceDescription)
                {
                    Write-Verbose -Message ($script:localizedData.NetAdapterInterfaceIncorrectMessage -f $Name)
                    $removeReaddSwitch = $true
                }
            }
            else
            {
                $adapters = (Get-NetAdapter -InterfaceDescription $switch.NetAdapterInterfaceDescriptions -ErrorAction SilentlyContinue).Name
                if ($null -ne (Compare-Object -ReferenceObject $adapters -DifferenceObject $NetAdapterName))
                {
                    Write-Verbose -Message ($script:localizedData.SwitchIncorrectNetworkAdapters -f $Name)
                    $removeReaddSwitch = $true
                }
            }

            if (($BandwidthReservationMode -ne 'NA') -and ($switch.BandwidthReservationMode -ne $BandwidthReservationMode))
            {
                Write-Verbose -Message ($script:localizedData.BandwidthReservationModeIncorrect -f $Name)
                $removeReaddSwitch = $true
            }

            if ($null -ne $switch.EmbeddedTeamingEnabled -and
                $switch.EmbeddedTeamingEnabled -ne $EnableEmbeddedTeaming)
            {
                Write-Verbose -Message ($script:localizedData.EnableEmbeddedTeamingIncorrect -f $Name)
                $removeReaddSwitch = $true
            }

            if ($null -ne $switch.EmbeddedTeamingEnabled -and
                $switch.EmbeddedTeamingEnabled -ne $EnableEmbeddedTeaming)
            {
                Write-Verbose -Message ($script:localizedData.EnableEmbeddedTeamingIncorrect -f $Name)
                $removeReaddSwitch = $true
            }

            if ($PSBoundParameters.ContainsKey('Id') -and $switch.Id -ne $Id)
            {
                Write-Verbose -Message ($script:localizedData.IdIncorrect -f $Name)
                $removeReaddSwitch = $true
            }

            if ($removeReaddSwitch)
            {
                Write-Verbose -Message ($script:localizedData.RemoveAndReaddSwitchMessage -f $Name)
                $switch | Remove-VMSwitch -Force
                $parameters = @{ }
                $parameters['Name'] = $Name
                $parameters['NetAdapterName'] = $NetAdapterName

                if ($BandwidthReservationMode -ne 'NA')
                {
                    $parameters['MinimumBandwidthMode'] = $BandwidthReservationMode
                }

                if ($PSBoundParameters.ContainsKey('AllowManagementOS'))
                {
                    $parameters['AllowManagementOS'] = $AllowManagementOS
                }

                if ($PSBoundParameters.ContainsKey('EnableEmbeddedTeaming'))
                {
                    $parameters['EnableEmbeddedTeaming'] = $EnableEmbeddedTeaming
                }

                if ($PSBoundParameters.ContainsKey('Id'))
                {
                    $parameters['Id'] = $Id.ToString()
                }

                $null = New-VMSwitch @parameters
                # Since the switch is recreated, the $switch variable is stale and needs to be reassigned
                $switch = (Get-VMSwitch -Name $Name -SwitchType $Type -ErrorAction SilentlyContinue)
            }
            else
            {
                Write-Verbose -Message ($script:localizedData.SwitchCorrectNetAdapterAndBandwidthMode -f $Name, ($NetAdapterName -join ','), $BandwidthReservationMode)
            }

            Write-Verbose -Message ($script:localizedData.CheckAllowManagementOS -f $Name)
            if ($PSBoundParameters.ContainsKey('AllowManagementOS') -and ($switch.AllowManagementOS -ne $AllowManagementOS))
            {
                Write-Verbose -Message ($script:localizedData.AllowManagementOSIncorrect -f $Name)
                $switch | Set-VMSwitch -AllowManagementOS $AllowManagementOS
                Write-Verbose -Message ($script:localizedData.AllowManagementOSUpdated -f $Name, $AllowManagementOS)
            }
            else
            {
                Write-Verbose -Message ($script:localizedData.AllowManagementOSCorrect -f $Name)
            }
        }

        # If the switch is not present, create one
        else
        {
            Write-Verbose -Message ($script:localizedData.PresentNotCorrect -f $Name, $Ensure)
            Write-Verbose -Message $script:localizedData.CreatingSwitch
            $parameters = @{ }
            $parameters['Name'] = $Name

            if ($BandwidthReservationMode -ne 'NA')
            {
                $parameters['MinimumBandwidthMode'] = $BandwidthReservationMode
            }

            if ($NetAdapterName)
            {
                $parameters['NetAdapterName'] = $NetAdapterName
                if ($PSBoundParameters.ContainsKey('AllowManagementOS'))
                {
                    $parameters['AllowManagementOS'] = $AllowManagementOS
                }
            }
            else
            {
                $parameters['SwitchType'] = $Type
            }

            if ($PSBoundParameters.ContainsKey('EnableEmbeddedTeaming'))
            {
                $parameters['EnableEmbeddedTeaming'] = $EnableEmbeddedTeaming
            }

            if ($PSBoundParameters.ContainsKey('Id'))
            {
                $parameters['Id'] = $Id
            }

            $switch = New-VMSwitch @parameters
            Write-Verbose -Message ($script:localizedData.PresentCorrect -f $Name, $Ensure)
        }

        # Set the load balancing algorithm if it's a SET Switch and the parameter is specified
        if ($EnableEmbeddedTeaming -eq $true -and $PSBoundParameters.ContainsKey('LoadBalancingAlgorithm'))
        {
            Write-Verbose -Message ($script:localizedData.SetLoadBalancingAlgorithmMessage -f $Name, $LoadBalancingAlgorithm)
            Set-VMSwitchTeam -Name $switch.Name -LoadBalancingAlgorithm $LoadBalancingAlgorithm -Verbose
        }
    }
    # Ensure is set to 'Absent', remove the switch
    else
    {
        Get-VMSwitch $Name -ErrorAction SilentlyContinue | Remove-VMSwitch -Force
    }
}

<#
.SYNOPSIS
    Tests if MSFT_xVMSwitch resource state is in the desired state or not.

.PARAMETER Name
    Name of the VM Switch.

.PARAMETER Type
    Type of switch.

.PARAMETER NetAdapterName
    Network adapter name(s) for external switch type.

.PARAMETER AllowManagementOS
    Specify if the VM host has access to the physical NIC.

.PARAMETER EnableEmbeddedTeaming
    Should embedded NIC teaming be used (Windows Server 2016 only).

.PARAMETER BandwidthReservationMode
    Type of Bandwidth Reservation Mode to use for the switch.

.PARAMETER LoadBalancingAlgorithm
    The load balancing algorithm that this switch team use.

.PARAMETER Id
    Desired unique ID of the Hyper-V Switch (Windows Server 2016 only).

.PARAMETER Ensure
    Whether switch should be present or absent.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet('External', 'Internal', 'Private')]
        [System.String]
        $Type,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $NetAdapterName,

        [Parameter()]
        [System.Boolean]
        $AllowManagementOS = $false,

        [Parameter()]
        [System.Boolean]
        $EnableEmbeddedTeaming = $false,

        [Parameter()]
        [ValidateSet('Default', 'Weight', 'Absolute', 'None', 'NA')]
        [System.String]
        $BandwidthReservationMode = 'NA',

        [Parameter()]
        [ValidateSet('Dynamic', 'HyperVPort')]
        [System.String]
        $LoadBalancingAlgorithm,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript(
            {
                $testGuid = New-Guid

                if ([guid]::TryParse($_, [ref]$testGuid))
                {
                    return $true
                }
                else
                {
                    throw 'The VMSwitch Id must be in GUID format!'
                }
            }
        )]
        [System.String]
        $Id,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    # Check if Hyper-V module is present for Hyper-V cmdlets
    if (!(Get-Module -ListAvailable -Name Hyper-V))
    {
        $errorMessage = $script:localizedData.HyperVNotInstalledError
        New-ObjectNotFoundException -Message $errorMessage
    }

    #region input validation
    if ($Type -eq 'External' -and !($NetAdapterName))
    {
        $errorMessage = $script:localizedData.NetAdapterNameRequiredError

        New-InvalidArgumentException -ArgumentName 'Type' -Message $errorMessage
    }

    if ($Type -ne 'External' -and $NetAdapterName)
    {
        $errorMessage = $script:localizedData.NetAdapterNameNotRequiredError

        New-InvalidArgumentException -ArgumentName 'Type' -Message $errorMessage
    }

    if (($BandwidthReservationMode -ne 'NA') -and ((Get-OSVersion) -lt [version]'6.2.0'))
    {
        $errorMessage = $script:localizedData.BandwidthReservationModeError

        New-InvalidArgumentException -ArgumentName 'BandwidthReservationMode' -Message $errorMessage
    }

    if ($EnableEmbeddedTeaming -eq $true -and (Get-OSVersion).Major -lt 10)
    {
        $errorMessage = $script:localizedData.SETServer2016Error

        New-InvalidArgumentException -ArgumentName 'EnableEmbeddedTeaming' -Message $errorMessage
    }

    if (($PSBoundParameters.ContainsKey('Id')) -and (Get-OSVersion).Major -lt 10)
    {
        $errorMessage = $script:localizedData.VMSwitchIDServer2016Error

        New-InvalidOperationException -Message $errorMessage
    }
    #endregion

    try
    {
        # Check if switch exists
        Write-Verbose -Message ($script:localizedData.PresentChecking -f $Name, $Ensure)
        $switch = Get-VMSwitch -Name $Name -SwitchType $Type -ErrorAction Stop

        # If switch exists
        if ($null -ne $switch)
        {
            Write-Verbose -Message ($script:localizedData.SwitchPresent -f $Name)
            # If switch should be present, check the switch type
            if ($Ensure -eq 'Present')
            {
                ## Only check the BandwidthReservationMode if specified
                if ($PSBoundParameters.ContainsKey('BandwidthReservationMode'))
                {
                    # If the BandwidthReservationMode is correct, or if $switch.BandwidthReservationMode is $null which means it isn't supported on the OS
                    Write-Verbose -Message ($script:localizedData.CheckingBandwidthReservationMode -f $Name)
                    if ($switch.BandwidthReservationMode -eq $BandwidthReservationMode -or $null -eq $switch.BandwidthReservationMode)
                    {
                        Write-Verbose -Message ($script:localizedData.BandwidthReservationModeCorrect -f $Name)
                    }
                    else
                    {
                        Write-Verbose -Message ($script:localizedData.BandwidthReservationModeIncorrect -f $Name)
                        return $false
                    }
                }

                # If switch is the external type, check additional properties
                if ($Type -eq 'External')
                {
                    if ($EnableEmbeddedTeaming -eq $false)
                    {
                        Write-Verbose -Message ($script:localizedData.CheckingNetAdapterInterface -f $Name)
                        $adapter = $null
                        try
                        {
                            $adapter = Get-NetAdapter -Name $NetAdapterName -ErrorAction SilentlyContinue
                        }
                        catch
                        {
                            # There are scenarios where the SilentlyContinue error action is not honoured,
                            # so this block serves to handle those and the write-verbose message is here
                            # to ensure that script analyser doesn't see an empty catch block to throw an
                            # error
                            Write-Verbose -Message $script:localizedData.NetAdapterNotFound
                        }

                        if ($adapter.InterfaceDescription -ne $switch.NetAdapterInterfaceDescription)
                        {
                            return $false
                        }
                        else
                        {
                            Write-Verbose -Message ($script:localizedData.NetAdapterInterfaceCorrect -f $Name)
                        }
                    }
                    else
                    {
                        Write-Verbose -Message ($script:localizedData.CheckingNetAdapterInterfaces -f $Name)
                        if ($null -ne $switch.NetAdapterInterfaceDescriptions)
                        {
                            $adapters = (Get-NetAdapter -InterfaceDescription $switch.NetAdapterInterfaceDescriptions -ErrorAction SilentlyContinue).Name
                            if ($null -ne (Compare-Object -ReferenceObject $adapters -DifferenceObject $NetAdapterName))
                            {
                                Write-Verbose -Message ($script:localizedData.IncorrectNetAdapterInterfaces -f $Name)
                                return $false
                            }
                            else
                            {
                                Write-Verbose -Message ($script:localizedData.CorrectNetAdapterInterfaces -f $Name)
                            }
                        }
                        else
                        {
                            Write-Verbose -Message ($script:localizedData.IncorrectNetAdapterInterfaces -f $Name)
                            return $false
                        }
                    }

                    if ($PSBoundParameters.ContainsKey('AllowManagementOS'))
                    {
                        Write-Verbose -Message ($script:localizedData.CheckAllowManagementOS -f $Name)
                        if (($switch.AllowManagementOS -ne $AllowManagementOS))
                        {
                            return $false
                        }
                        else
                        {
                            Write-Verbose -Message ($script:localizedData.AllowManagementOSCorrect -f $Name)
                        }
                    }

                    if ($PSBoundParameters.ContainsKey('LoadBalancingAlgorithm'))
                    {
                        Write-Verbose -Message ($script:localizedData.CheckingLoadBalancingAlgorithm -f $Name)
                        $loadBalancingAlgorithm = ($switch | Get-VMSwitchTeam).LoadBalancingAlgorithm.toString()
                        if ($loadBalancingAlgorithm -ne $LoadBalancingAlgorithm)
                        {
                            return $false
                        }
                        else
                        {
                            Write-Verbose -Message ($script:localizedData.LoadBalancingAlgorithmCorrect -f $Name)
                        }
                    }
                }

                # Only check embedded teaming if specified
                if ($PSBoundParameters.ContainsKey('EnableEmbeddedTeaming') -eq $true)
                {
                    Write-Verbose -Message ($script:localizedData.CheckEnableEmbeddedTeaming -f $Name)
                    if ($switch.EmbeddedTeamingEnabled -eq $EnableEmbeddedTeaming -or $null -eq $switch.EmbeddedTeamingEnabled)
                    {
                        Write-Verbose -Message ($script:localizedData.EnableEmbeddedTeamingCorrect -f $Name)
                    }
                    else
                    {
                        Write-Verbose -Message ($script:localizedData.EnableEmbeddedTeamingIncorrect -f $Name)
                        return $false
                    }
                }

                # Check if the Switch has the desired ID
                if ($PSBoundParameters.ContainsKey('Id') -eq $true)
                {
                    Write-Verbose -Message ($script:localizedData.CheckID -f $Name)
                    if ($switch.Id.Guid -eq $Id)
                    {
                        Write-Verbose -Message ($script:localizedData.IdCorrect -f $Name)
                    }
                    else
                    {
                        Write-Verbose -Message ($script:localizedData.IdIncorrect -f $Name)
                        return $false
                    }
                }

                return $true
            }
            # If switch should be absent, but is there, return $false
            else
            {
                return $false
            }
        }
        else
        {
            if ($Ensure -eq 'Present')
            {
                return $false
            }
            else
            {
                return $true
            }
        }
    }

    # If no switch was present
    catch [System.Management.Automation.ActionPreferenceStopException]
    {
        Write-Verbose -Message ($script:localizedData.SwitchNotPresent -f $Name)
        return ($Ensure -eq 'Absent')
    }
}

<#
.SYNOPSIS
Returns the OS version
#>
function Get-OSVersion
{
    [Environment]::OSVersion.Version
}

Export-ModuleMember -Function *-TargetResource
