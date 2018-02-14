#region localizeddata
if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData `
        -BindingVariable LocalizedData `
        -Filename MSFT_xVMSwitch.strings.psd1 `
        -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
}
else
{
    #fallback to en-US
    Import-LocalizedData `
        -BindingVariable LocalizedData `
        -Filename MSFT_xVMSwitch.strings.psd1 `
        -BaseDirectory "${PSScriptRoot}\en-US"
}
#endregion

# Import the common HyperV functions
Import-Module -Name ( Join-Path `
    -Path (Split-Path -Path $PSScriptRoot -Parent) `
    -ChildPath '\HyperVCommon\HyperVCommon.psm1' )

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
        [String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet("External","Internal","Private")]
        [String]
        $Type
    )

    Write-Verbose -Message "Getting settings for VM Switch '$Name'"

    # Check if Hyper-V module is present for Hyper-V cmdlets
    if (!(Get-Module -ListAvailable -Name Hyper-V))
    {
        New-InvalidOperationError `
            -ErrorId 'HyperVNotInstalledError' `
            -ErrorMessage $LocalizedData.HyperVNotInstalledError
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
        Name                    = $switch.Name
        Type                    = $switch.SwitchType
        NetAdapterName          = [string[]]$netAdapterName
        AllowManagementOS       = $switch.AllowManagementOS
        EnableEmbeddedTeaming   = $switch.EmbeddedTeamingEnabled
        LoadBalancingAlgorithm  = $loadBalancingAlgorithm
        Ensure                  = $ensure
        Id                      = $switch.Id
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

.PARAMETER Ensure
    Whether switch should be present or absent.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet("External","Internal","Private")]
        [String]
        $Type,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $NetAdapterName,

        [Parameter()]
        [Boolean]
        $AllowManagementOS = $false,

        [Parameter()]
        [Boolean]
        $EnableEmbeddedTeaming = $false,

        [Parameter()]
        [ValidateSet("Default","Weight","Absolute","None","NA")]
        [String]
        $BandwidthReservationMode = "NA",

        [Parameter()]
        [ValidateSet('Dynamic','HyperVPort')]
        [String]
        $LoadBalancingAlgorithm,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [String]
        $Ensure = "Present"
    )

    # Check if Hyper-V module is present for Hyper-V cmdlets
    if (!(Get-Module -ListAvailable -Name Hyper-V))
    {
        New-InvalidOperationError `
            -ErrorId 'HyperVNotInstalledError' `
            -ErrorMessage $LocalizedData.HyperVNotInstalledError
    }

    # Check to see if the BandwidthReservationMode chosen is supported in the OS
    elseif (($BandwidthReservationMode -ne "NA") -and ((Get-OSVersion) -lt [version]'6.2.0'))
    {
        New-InvalidArgumentError `
            -ErrorId 'BandwidthReservationModeError' `
            -ErrorMessage $LocalizedData.BandwidthReservationModeError
    }

    if ($EnableEmbeddedTeaming -eq $true -and (Get-OSVersion).Major -lt 10)
    {
        New-InvalidArgumentError `
            -ErrorId 'SETServer2016Error' `
            -ErrorMessage $LocalizedData.SETServer2016Error
    }

    if ($Ensure -eq 'Present')
    {
        $switch = (Get-VMSwitch -Name $Name -SwitchType $Type -ErrorAction SilentlyContinue)

        # If switch is present and it is external type, that means it doesn't have right properties (TEST code ensures that)
        if ($switch -and ($switch.SwitchType -eq 'External'))
        {
            $removeReaddSwitch = $false

            Write-Verbose -Message ($LocalizedData.CheckingSwitchMessage -f $Name)
            if ($switch.EmbeddedTeamingEnabled -eq $false -or $null -eq $switch.EmbeddedTeamingEnabled)
            {
                if ((Get-NetAdapter -Name $NetAdapterName).InterfaceDescription -ne $switch.NetAdapterInterfaceDescription)
                {
                    Write-Verbose -Message ($LocalizedData.NetAdapterInterfaceIncorrectMessage -f $Name)
                    $removeReaddSwitch = $true
                }
            }
            else
            {
                $adapters = (Get-NetAdapter -InterfaceDescription $switch.NetAdapterInterfaceDescriptions -ErrorAction SilentlyContinue).Name
                if ($null -ne (Compare-Object -ReferenceObject $adapters -DifferenceObject $NetAdapterName))
                {
                    Write-Verbose -Message ($LocalizedData.SwitchIncorrectNetworkAdapters -f $Name)
                    $removeReaddSwitch = $true
                }
            }

            if (($BandwidthReservationMode -ne "NA") -and ($switch.BandwidthReservationMode -ne $BandwidthReservationMode))
            {
                Write-Verbose -Message ($LocalizedData.BandwidthReservationModeIncorrect -f $Name)
                $removeReaddSwitch = $true
            }

            if ($null -ne $switch.EmbeddedTeamingEnabled -and
                $switch.EmbeddedTeamingEnabled -ne $EnableEmbeddedTeaming)
            {
                Write-Verbose -Message ($LocalizedData.EnableEmbeddedTeamingIncorrect -f $Name)
                $removeReaddSwitch = $true
            }

            if ($removeReaddSwitch)
            {
                Write-Verbose -Message ($LocalizedData.RemoveAndReaddSwitchMessage -f $Name)
                $switch | Remove-VMSwitch -Force
                $parameters = @{}
                $parameters["Name"] = $Name
                $parameters["NetAdapterName"] = $NetAdapterName

                if ($BandwidthReservationMode -ne "NA")
                {
                    $parameters["MinimumBandwidthMode"] = $BandwidthReservationMode
                }

                if ($PSBoundParameters.ContainsKey("AllowManagementOS"))
                {
                    $parameters["AllowManagementOS"] = $AllowManagementOS
                }

                if ($PSBoundParameters.ContainsKey("EnableEmbeddedTeaming"))
                {
                    $parameters["EnableEmbeddedTeaming"] = $EnableEmbeddedTeaming
                }

                $null = New-VMSwitch @parameters
                Write-Verbose -Message "Switch $Name has right netadapter $NetAdapterName"
                # Since the switch is recreated, the $switch variable is stale and needs to be reassigned
                $switch = (Get-VMSwitch -Name $Name -SwitchType $Type -ErrorAction SilentlyContinue)
            }
            else
            {
                Write-Verbose -Message ($LocalizedData.SwitchCorrectNetAdapterAndBandwidthMode -f $Name, $NetAdapterName, $BandwidthReservationMode)
            }

            Write-Verbose -Message ($LocalizedData.CheckAllowManagementOS -f $Name)
            if ($PSBoundParameters.ContainsKey("AllowManagementOS") -and ($switch.AllowManagementOS -ne $AllowManagementOS))
            {
                Write-Verbose -Message ($LocalizedData.AllowManagementOSIncorrect -f $Name)
                $switch | Set-VMSwitch -AllowManagementOS $AllowManagementOS
                Write-Verbose -Message ($LocalizedData.AllowManagementOSUpdated -f $Name, $AllowManagementOS)
            }
            else
            {
                Write-Verbose -Message ($LocalizedData.AllowManagementOSCorrect -f $Name)
            }
        }

        # If the switch is not present, create one
        else
        {
            Write-Verbose -Message ($LocalizedData.PresentNotCorrect -f $Name, $Ensure)
            Write-Verbose -Message $LocalizedData.CreatingSwitch
            $parameters = @{}
            $parameters["Name"] = $Name

            if ($BandwidthReservationMode -ne "NA")
            {
                $parameters["MinimumBandwidthMode"] = $BandwidthReservationMode
            }

            if ($NetAdapterName)
            {
                $parameters["NetAdapterName"] = $NetAdapterName
                if ($PSBoundParameters.ContainsKey("AllowManagementOS"))
                {
                    $parameters["AllowManagementOS"] = $AllowManagementOS
                }
            }
            else
            {
                $parameters["SwitchType"] = $Type
            }

            if ($PSBoundParameters.ContainsKey("EnableEmbeddedTeaming"))
            {
                $parameters["EnableEmbeddedTeaming"] = $EnableEmbeddedTeaming
            }

            $switch = New-VMSwitch @parameters
            Write-Verbose -Message ($LocalizedData.PresentCorrect -f $Name, $Ensure)
        }

        # Set the load balancing algorithm if it's a SET Switch and the paramter is specified
        if($EnableEmbeddedTeaming -eq $true -and $PSBoundParameters.ContainsKey('LoadBalancingAlgorithm'))
        {
            Write-Verbose -Message ($LocalizedData.SetLoadBalancingAlgorithmMessage -f $Name, $LoadBalancingAlgorithm)
            Set-VMSwitchTeam -Name $switch.Name -LoadBalancingAlgorithm $LoadBalancingAlgorithm -Verbose
        }
    }
    # Ensure is set to "Absent", remove the switch
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
        [String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet("External","Internal","Private")]
        [String]
        $Type,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $NetAdapterName,

        [Parameter()]
        [Boolean]
        $AllowManagementOS = $false,

        [Parameter()]
        [Boolean]
        $EnableEmbeddedTeaming = $false,

        [Parameter()]
        [ValidateSet("Default","Weight","Absolute","None","NA")]
        [String]
        $BandwidthReservationMode = "NA",

        [Parameter()]
        [ValidateSet('Dynamic','HyperVPort')]
        [String]
        $LoadBalancingAlgorithm,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [String]
        $Ensure = "Present"
    )

    # Check if Hyper-V module is present for Hyper-V cmdlets
    if (!(Get-Module -ListAvailable -Name Hyper-V))
    {
        New-InvalidOperationError `
            -ErrorId 'HyperVNotInstalledError' `
            -ErrorMessage $LocalizedData.HyperVNotInstalledError
    }

    #region input validation
    if ($Type -eq 'External' -and !($NetAdapterName))
    {
        New-InvalidArgumentError `
            -ErrorId 'NetAdapterNameRequiredError' `
            -ErrorMessage $LocalizedData.NetAdapterNameRequiredError
    }

    if ($Type -ne 'External' -and $NetAdapterName)
    {
        New-InvalidArgumentError `
            -ErrorId 'NetAdapterNameNotRequiredError' `
            -ErrorMessage $LocalizedData.NetAdapterNameNotRequiredError
    }

    if (($BandwidthReservationMode -ne "NA") -and ((Get-OSVersion) -lt [version]'6.2.0'))
    {
        New-InvalidArgumentError `
            -ErrorId 'BandwidthReservationModeError' `
            -ErrorMessage $LocalizedData.BandwidthReservationModeError
    }

    if ($EnableEmbeddedTeaming -eq $true -and (Get-OSVersion).Major -lt 10)
    {
        New-InvalidArgumentError `
            -ErrorId 'SETServer2016Error' `
            -ErrorMessage $LocalizedData.SETServer2016Error
    }
    #endregion

    try
    {
        # Check if switch exists
        Write-Verbose -Message ($LocalizedData.PresentChecking -f $Name, $Ensure)
        $switch = Get-VMSwitch -Name $Name -SwitchType $Type -ErrorAction Stop

        # If switch exists
        if ($null -ne $switch)
        {
            Write-Verbose -Message ($LocalizedData.SwitchPresent -f $Name)
            # If switch should be present, check the switch type
            if ($Ensure -eq 'Present')
            {
                ## Only check the BandwidthReservationMode if specified
                if ($PSBoundParameters.ContainsKey('BandwidthReservationMode'))
                {
                    # If the BandwidthReservationMode is correct, or if $switch.BandwidthReservationMode is $null which means it isn't supported on the OS
                    Write-Verbose -Message ($LocalizedData.CheckingBandwidthReservationMode -f $Name)
                    if ($switch.BandwidthReservationMode -eq $BandwidthReservationMode -or $null -eq $switch.BandwidthReservationMode)
                    {
                        Write-Verbose -Message ($LocalizedData.BandwidthReservationModeCorrect -f $Name)
                    }
                    else
                    {
                        Write-Verbose -Message ($LocalizedData.BandwidthReservationModeIncorrect -f $Name)
                        return $false
                    }
                }

                # If switch is the external type, check additional propeties
                if ($Type -eq 'External')
                {
                    if ($EnableEmbeddedTeaming -eq $false)
                    {
                        Write-Verbose -Message ($LocalizedData.CheckingNetAdapterInterface -f $Name)
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
                            Write-Verbose -Message $LocalizedData.NetAdapterNotFound
                        }

                        if ($adapter.InterfaceDescription -ne $switch.NetAdapterInterfaceDescription)
                        {
                            return $false
                        }
                        else
                        {
                            Write-Verbose -Message ($LocalizedData.NetAdapterInterfaceCorrect -f $Name)
                        }
                    }
                    else
                    {
                        Write-Verbose -Message ($LocalizedData.CheckingNetAdapterInterfaces -f $Name)
                        if ($null -ne $switch.NetAdapterInterfaceDescriptions)
                        {
                            $adapters = (Get-NetAdapter -InterfaceDescription $switch.NetAdapterInterfaceDescriptions -ErrorAction SilentlyContinue).Name
                            if ($null -ne (Compare-Object -ReferenceObject $adapters -DifferenceObject $NetAdapterName))
                            {
                                Write-Verbose -Message ($LocalizedData.IncorrectNetAdapterInterfaces -f $Name)
                                return $false
                            }
                            else
                            {
                                Write-Verbose -Message ($LocalizedData.CorrectNetAdapterInterfaces -f $Name)
                            }
                        }
                        else
                        {
                            Write-Verbose -Message ($LocalizedData.IncorrectNetAdapterInterfaces -f $Name)
                            return $false
                        }
                    }

                    if ($PSBoundParameters.ContainsKey("AllowManagementOS"))
                    {
                        Write-Verbose -Message ($LocalizedData.CheckAllowManagementOS -f $Name)
                        if (($switch.AllowManagementOS -ne $AllowManagementOS))
                        {
                            return $false
                        }
                        else
                        {
                            Write-Verbose -Message ($LocalizedData.AllowManagementOSCorrect -f $Name)
                        }
                    }

                    if($PSBoundParameters.ContainsKey('LoadBalancingAlgorithm'))
                    {
                        Write-Verbose -Message ($LocalizedData.CheckingLoadBalancingAlgorithm -f $Name)
                        $loadBalancingAlgorithm = ($switch | Get-VMSwitchTeam).LoadBalancingAlgorithm.toString()
                        if($loadBalancingAlgorithm -ne $LoadBalancingAlgorithm)
                        {
                            return $false
                        }
                        else
                        {
                            Write-Verbose -Message ($LocalizedData.LoadBalancingAlgorithmCorrect -f $Name)
                        }
                    }
                }

                # Only check embedded teaming if specified
                if ($PSBoundParameters.ContainsKey("EnableEmbeddedTeaming") -eq $true)
                {
                    Write-Verbose -Message ($LocalizedData.CheckEnableEmbeddedTeaming -f $Name)
                    if ($switch.EmbeddedTeamingEnabled -eq $EnableEmbeddedTeaming -or $null -eq $switch.EmbeddedTeamingEnabled)
                    {
                        Write-Verbose -Message ($LocalizedData.EnableEmbeddedTeamingCorrect -f $Name)
                    }
                    else
                    {
                        Write-Verbose -Message ($LocalizedData.EnableEmbeddedTeamingIncorrect -f $Name)
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
    }

    # If no switch was present
    catch [System.Management.Automation.ActionPreferenceStopException]
    {
        Write-Verbose -Message ($LocalizedData.SwitchNotPresent -f $Name)
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
