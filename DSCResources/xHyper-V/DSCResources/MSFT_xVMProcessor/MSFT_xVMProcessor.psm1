#region localizeddata
if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData -BindingVariable localizedData -Filename MSFT_xVMProcessor.psd1 `
                         -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
}
else
{
    #fallback to en-US
    Import-LocalizedData -BindingVariable localizedData -Filename MSFT_xVMProcessor.psd1 `
                         -BaseDirectory "${PSScriptRoot}\en-US"
}
#endregion


# Import the common HyperV functions
Import-Module -Name ( Join-Path `
    -Path (Split-Path -Path $PSScriptRoot -Parent) `
    -ChildPath '\HyperVCommon\HyperVCommon.psm1' )


<#
.SYNOPSIS
    Gets MSFT_xVMProcessor resource current state.

.PARAMETER VMName
    Specifies the name of the virtual machine on which the processor is to be configured.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory)]
        [System.String] $VMName
    )

    Assert-Module -Name 'Hyper-V'

    Write-Verbose -Message ($localizedData.QueryingVMProcessor -f $VMName)
    $vmProcessor = Get-VMProcessor -VMName $VMName -ErrorAction SilentlyContinue

    if ($null -eq $vmProcessor)
    {
        $vmNotFoundErrorMessage = $localizedData.VMNotFoundError -f $VMName
        New-InvalidArgumentError -ErrorId 'VMNotFound' -ErrorMessage $vmNotFoundErrorMessage
    }

    $configuration = @{
        VMName = $VMName
        EnableHostResourceProtection = $vmProcessor.EnableHostResourceProtection
        ExposeVirtualizationExtensions = $vmProcessor.ExposeVirtualizationExtensions
        HwThreadCountPerCore = $vmProcessor.HwThreadCountPerCore
        Maximum = $vmProcessor.Maximum
        MaximumCountPerNumaNode = $vmProcessor.MaximumCountPerNumaNode
        MaximumCountPerNumaSocket = $vmProcessor.MaximumCountPerNumaSocket
        RelativeWeight = $vmProcessor.RelativeWeight
        Reserve = $vmProcessor.Reserve
        ResourcePoolName = $vmProcessor.ResourcePoolName
        CompatibilityForMigrationEnabled = $vmProcessor.CompatibilityForMigrationEnabled
        CompatibilityForOlderOperatingSystemsEnabled = $vmProcessor.CompatibilityForOlderOperatingSystemsEnabled
    }

    return $configuration
}

<#
.SYNOPSIS
    Tests if MSFT_xVMProcessor resource state is in the desired state or not.

.PARAMETER VMName
    Specifies the name of the virtual machine on which the processor is to be configured.

.PARAMETER EnableHostResourceProtection
    Specifies whether to enable host resource protection.
    NOTE: Only supported on Windows 10 and Server 2016.

.PARAMETER ExposeVirtualizationExtensions
    Specifies whether nested virtualization is enabled.
    NOTE: Only supported on Windows 10 and Server 2016.

.PARAMETER HwThreadCountPerCore
    Specifies the maximum thread core per processor core.
    NOTE: Only supported on Windows 10 and Server 2016.

.PARAMETER Maximum
    Specifies the maximum percentage of resources available to the virtual machine
    processor to be configured. Allowed values range from 0 to 100.

.PARAMETER MaximumCountPerNumaNode
    Specifies the maximum number of processors per NUMA node to be configured for
    the virtual machine.

.PARAMETER MaximumCountPerNumaSocket
    Specifies the maximum number of sockets per NUMA node to be configured for
    the virtual machine.

.PARAMETER RelativeWeight
    Specifies the priority for allocating the physical computer's processing
    power to this virtual machine relative to others. Allowed values range
    from 1 to 10000.

.PARAMETER Reserve
    Specifies the percentage of processor resources to be reserved for this
    virtual machine. Allowed values range from 0 to 100.

.PARAMETER ResourcePoolName
    Specifies the name of the processor resource pool to be used.

.PARAMETER CompatibilityForMigrationEnabled
    Specifies whether the virtual processors features are to be limited
    for compatibility when migrating the virtual machine to another host.

.PARAMETER CompatibilityForOlderOperatingSystemsEnabled
    Specifies whether the virtual processor’s features are to be limited
    for compatibility with older operating systems.

.PARAMETER RestartIfNeeded
    If specified, shutdowns and restarts the VM if needed for property
    changes.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory)]
        [System.String] $VMName,

        [Parameter()]
        [System.Boolean] $EnableHostResourceProtection,

        [Parameter()]
        [System.Boolean] $ExposeVirtualizationExtensions,

        [Parameter()]
        [System.UInt64] $HwThreadCountPerCore,

        [Parameter()]
        [System.UInt64] $Maximum,

        [Parameter()]
        [System.UInt32] $MaximumCountPerNumaNode,

        [Parameter()]
        [System.UInt32] $MaximumCountPerNumaSocket,

        [Parameter()]
        [System.UInt32] $RelativeWeight,

        [Parameter()]
        [System.UInt64] $Reserve,

        [Parameter()]
        [System.String] $ResourcePoolName,

        [Parameter()]
        [System.Boolean] $CompatibilityForMigrationEnabled,

        [Parameter()]
        [System.Boolean] $CompatibilityForOlderOperatingSystemsEnabled,

        [Parameter()]
        [System.Boolean] $RestartIfNeeded
    )

    Assert-Module -Name 'Hyper-V'
    Assert-TargetResourceParameter @PSBoundParameters

    $targetResource = Get-TargetResource -VMName $VMName
    $isTargetResourceCompliant = $true

    foreach ($parameter in $PSBoundParameters.GetEnumerator())
    {
        if (($targetResource.ContainsKey($parameter.Key)) -and
            ($parameter.Value -ne $targetResource[$parameter.Key]))
        {
            $isTargetResourceCompliant = $false
            Write-Verbose -Message ($localizedData.PropertyMismatch -f $parameter.Key,
                                    $parameter.Value, $targetResource[$parameter.Key])
        }
    }

    if ($isTargetResourceCompliant)
    {
        Write-Verbose -Message ($localizedData.VMProcessorInDesiredState -f $VMName)
    }
    else
    {
        Write-Verbose -Message ($localizedData.VMProcessorNotInDesiredState -f $VMName)
    }

    return $isTargetResourceCompliant

} #end function

<#
.SYNOPSIS
    Configures MSFT_xVMProcessor resource state.

.PARAMETER VMName
    Specifies the name of the virtual machine on which the processor is to be configured.

.PARAMETER EnableHostResourceProtection
    Specifies whether to enable host resource protection.
    NOTE: Only supported on Windows 10 and Server 2016.

.PARAMETER ExposeVirtualizationExtensions
    Specifies whether nested virtualization is enabled.
    NOTE: Only supported on Windows 10 and Server 2016.

.PARAMETER HwThreadCountPerCore
    Specifies the maximum thread core per processor core
    NOTE: Only supported on Windows 10 and Server 2016.

.PARAMETER Maximum
    Specifies the maximum percentage of resources available to the virtual machine
    processor to be configured. Allowed values range from 0 to 100.

.PARAMETER MaximumCountPerNumaNode
    Specifies the maximum number of processors per NUMA node to be configured for
    the virtual machine.

.PARAMETER MaximumCountPerNumaSocket
    Specifies the maximum number of sockets per NUMA node to be configured for
    the virtual machine.

.PARAMETER RelativeWeight
    Specifies the priority for allocating the physical computer's processing
    power to this virtual machine relative to others. Allowed values range
    from 1 to 10000.

.PARAMETER Reserve
    Specifies the percentage of processor resources to be reserved for this
    virtual machine. Allowed values range from 0 to 100.

.PARAMETER ResourcePoolName
    Specifies the name of the processor resource pool to be used.

.PARAMETER CompatibilityForMigrationEnabled
    Specifies whether the virtual processors features are to be limited
    for compatibility when migrating the virtual machine to another host.

.PARAMETER CompatibilityForOlderOperatingSystemsEnabled
    Specifies whether the virtual processor’s features are to be limited
    for compatibility with older operating systems.

.PARAMETER RestartIfNeeded
    If specified, shutdowns and restarts the VM if needed for property
    changes.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.String] $VMName,

        [Parameter()]
        [System.Boolean] $EnableHostResourceProtection,

        [Parameter()]
        [System.Boolean] $ExposeVirtualizationExtensions,

         [Parameter()]
        [System.UInt64] $HwThreadCountPerCore,

        [Parameter()]
        [System.UInt64] $Maximum,

        [Parameter()]
        [System.UInt32] $MaximumCountPerNumaNode,

        [Parameter()]
        [System.UInt32] $MaximumCountPerNumaSocket,

        [Parameter()]
        [System.UInt32] $RelativeWeight,

        [Parameter()]
        [System.UInt64] $Reserve,

        [Parameter()]
        [System.String] $ResourcePoolName,

        [Parameter()]
        [System.Boolean] $CompatibilityForMigrationEnabled,

        [Parameter()]
        [System.Boolean] $CompatibilityForOlderOperatingSystemsEnabled,

        [Parameter()]
        [System.Boolean] $RestartIfNeeded
    )

    Assert-Module -Name 'Hyper-V'
    Assert-TargetResourceParameter @PSBoundParameters

    ## Parameters requiring shutdown.
    $restartRequiredParameterNames = @(
        'ExposeVirtualizationExtensions',
        'CompatibilityForMigrationEnabled',
        'CompatibilityForOlderOperatingSystemsEnabled',
        'HwThreadCountPerCore',
        'MaximumCountPerNumaNode',
        'MaximumCountPerNumaSocket',
        'ResourcePoolName'
    )
    $isRestartRequired = $false
    $vmObject = Get-VM -Name $VMName

    ## Only check for restart required parameters if VM is not off
    if ($vmObject.State -ne 'Off')
    {
        foreach ($parameterName in $restartRequiredParameterNames)
        {
            if ($PSBoundParameters.ContainsKey($parameterName))
            {
                if (-not $RestartIfNeeded)
                {
                    $errorMessage = $localized.CannotUpdateVmOnlineError -f $parameterName
                    New-InvalidOperationError -ErrorId InvalidState -ErrorMessage $errorMessage
                }
                else
                {
                    $isRestartRequired = $true
                }
            }
        } #end foreach parameter
    }

    $null = $PSBoundParameters.Remove('RestartIfNeeded')
    $null = $PSBoundParameters.Remove('VMName')

    if (-not $isRestartRequired)
    {
        ## No parameter specified that requires a restart, so disable the restart flag
        Write-Verbose -Message ($localizedData.UpdatingVMProperties -f $VMName)
        Set-VMProcessor -VMName $VMName @PSBoundParameters
        Write-Verbose -Message ($localizedData.VMPropertiesUpdated -f $VMName)
    }
    else
    {
        ## Restart is required and that requires turning VM off
        $setVMPropertyParameters = @{
            VMName = $VMName;
            VMCommand = 'Set-VMProcessor';
            ChangeProperty = $PSBoundParameters;
            RestartIfNeeded = $true;
            Verbose = $Verbose;
        }
        Set-VMProperty @setVMPropertyParameters
    }

} #end function

<#
.SYNOPSIS
    Ensures OS supports the supplied parameters.

.PARAMETER EnableHostResourceProtection
    Specifies whether to enable host resource protection.
    NOTE: Only supported on Windows 10, Server 2016 and Nano.

.PARAMETER ExposeVirtualizationExtensions
    Specifies whether nested virtualization is enabled.
    NOTE: Only supported on Windows 10, Server 2016 and Nano.

.PARAMETER HwThreadCountPerCore
    Specifies the maximum thread core per processor core
    NOTE: Only supported on Windows 10, Server 2016 and Nano.

.PARAMETER RemainingArgument
    Catch all to enable splatting of remaining parameters.
#>
function Assert-TargetResourceParameter
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.Boolean] $EnableHostResourceProtection,

        [Parameter()]
        [System.Boolean] $ExposeVirtualizationExtensions,

        [Parameter()]
        [System.UInt64] $HwThreadCountPerCore,

        [Parameter(ValueFromRemainingArguments)]
        [System.Object[]] $RemainingArguments

    )

    ## Get-CimInstance returns build number as a string
    $win32OperatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem -Verbose:$false
    $osBuildNumber = $win32OperatingSystem.BuildNumber -as [System.Int64]
    $build14393RequiredParameterNames = @(
        'EnableHostResourceProtection',
        'ExposeVirtualizationExtensions',
        'HwThreadCountPerCore'
    )

    foreach ($parameterName in $build14393RequiredParameterNames)
    {
        if (($PSBoundParameters.ContainsKey($parameterName)) -and ($osBuildNumber -lt 14393))
        {
            $errorMessage = $localizedData.UnsupportedSystemError -f $parameterName, 14393
            New-InvalidArgumentError -ErrorId SystemUnsupported -ErrorMessage $errorMessage
        }
    }

} #end function

Export-ModuleMember -Function *-TargetResource
