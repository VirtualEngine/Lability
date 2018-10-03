<#
.SYNOPSIS
    Gets MSFT_xVHD resource current state.

.PARAMETER Name
    The desired VHD file name.

.PARAMETER Path
    The desired Path where the VHD will be created.

.PARAMETER Generation
    Virtual disk format.
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
        [String]
        $Path,

        [Parameter()]
        [ValidateSet("Vhd","Vhdx")]
        [String]
        $Generation = "Vhd"
    )

    # Check if Hyper-V module is present for Hyper-V cmdlets
    if (!(Get-Module -ListAvailable -Name Hyper-V))
    {
        Throw 'Please ensure that Hyper-V role is installed with its PowerShell module'
    }

    # Construct the full path for the vhdFile
    $vhdName = GetNameWithExtension -Name $Name -Generation $Generation
    $vhdFilePath = Join-Path -Path $Path -ChildPath $vhdName
    Write-Verbose -Message "Vhd full path is $vhdFilePath"

    $vhd = Get-VHD -Path $vhdFilePath -ErrorAction SilentlyContinue

    $ensure = 'Absent'
    if ($vhd)
    {
        $ensure = 'Present'
    }

    @{
        Name             = $Name
        Path             = $Path
        ParentPath       = $vhd.ParentPath
        Generation       = $vhd.VhdFormat
        Ensure           = $ensure
        ID               = $vhd.DiskIdentifier
        Type             = $vhd.VhdType
        FileSizeBytes    = $vhd.FileSize
        MaximumSizeBytes = $vhd.Size
        IsAttached       = $vhd.Attached
    }
}

<#
.SYNOPSIS
    Configures MSFT_xVHD resource state.

.PARAMETER Name
    The desired VHD file name.

.PARAMETER Path
    The desired Path where the VHD will be created.

.PARAMETER ParentPath
    Parent VHD file path, for differencing disk.

.PARAMETER MaximumSizeBytes
    Maximum size of VHD to be created.

.PARAMETER Type
    Virtual disk type.

.PARAMETER Generation
    Virtual disk format.

.PARAMETER Ensure
    Ensures that the VHD is Present or Absent.
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
        [String]
        $Path,

        [Parameter()]
        [String]
        $ParentPath,

        [Parameter()]
        [Uint64]
        $MaximumSizeBytes,

        [Parameter()]
        [ValidateSet('Dynamic', 'Fixed', 'Differencing')]
        [String]
        $Type = 'Dynamic',

        [Parameter()]
        [ValidateSet('Vhd', 'Vhdx')]
        [String]
        $Generation = 'Vhd',

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present'
    )

    # Construct the full path for the vhdFile
    $vhdName = GetNameWithExtension -Name $Name -Generation $Generation
    $vhdFilePath = Join-Path -Path $Path -ChildPath $vhdName
    Write-Verbose -Message "Vhd full path is $vhdFilePath"

    Write-Verbose -Message "Checking if $vhdFilePath is $Ensure ..."

    # If vhd should be absent, delete it
    if ($Ensure -eq 'Absent')
    {
        if (Test-Path -Path $vhdFilePath)
        {
            Write-Verbose -Message "$vhdFilePath is not $Ensure"
            Remove-Item -Path $vhdFilePath -Force -ErrorAction Stop
        }
        Write-Verbose -Message "$vhdFilePath is $Ensure"
    }

    else
    {
        # Check if the Vhd is present
        try
        {
            $vhd = Get-VHD -Path $vhdFilePath -ErrorAction Stop

            # If this is a differencing disk, check the parent path
            if ($ParentPath)
            {
                Write-Verbose -Message "Checking if $vhdFilePath parent path is $ParentPath ..."

                # If the parent path is not set correct, fix it
                if ($vhd.ParentPath -ne $ParentPath)
                {
                    Write-Verbose -Message "$vhdFilePath parent path is not $ParentPath."
                    Set-VHD -Path $vhdFilePath -ParentPath $ParentPath
                    Write-Verbose -Message "$vhdFilePath parent path is now $ParentPath."
                }
                else
                {
                    Write-Verbose -Message "$vhdFilePath is $Ensure and parent path is set to $ParentPath."
                }
            }

            # This is a fixed disk, check the size
            elseif ($PSBoundParameters.ContainsKey('MaximumSizeBytes'))
            {
                Write-Verbose -Message "Checking if $vhdFilePath size is $MaximumSizeBytes ..."

                # If the size is not correct, fix it
                if ($vhd.Size -ne $MaximumSizeBytes)
                {
                    Write-Verbose -Message "$vhdFilePath size is not $MaximumSizeBytes."
                    Resize-VHD -Path $vhdFilePath -SizeBytes $MaximumSizeBytes
                    Write-Verbose -Message "$vhdFilePath size is now $MaximumSizeBytes."
                }
                else
                {
                    Write-Verbose -Message "$vhdFilePath is $Ensure and size is $MaximumSizeBytes."
                }
            }

            if ($vhd.Type -ne $Type)
            {
                Write-Verbose -Message 'This module can''t convert disk types'
            }
        }

        # Vhd file is not present
        catch
        {
            Write-Verbose -Message "$vhdFilePath is not $Ensure"
            if ($ParentPath)
            {
                $null = New-VHD -Path $vhdFilePath -ParentPath $ParentPath
            }
            else
            {
                $params = @{
                    Path = $vhdFilePath
                    SizeBytes = $MaximumSizeBytes
                    $Type = $True
                }
                $null = New-VHD @params
            }

            Write-Verbose -Message "$vhdFilePath is now $Ensure"
        }
    }
}

<#
.SYNOPSIS
    Tests if MSFT_xVHD resource state is in the desired state or not.

.PARAMETER Name
    The desired VHD file name.

.PARAMETER Path
    The desired Path where the VHD will be created.

.PARAMETER ParentPath
    Parent VHD file path, for differencing disk.

.PARAMETER MaximumSizeBytes
    Maximum size of VHD to be created.

.PARAMETER Type
    Virtual disk type.

.PARAMETER Generation
    Virtual disk format.

.PARAMETER Ensure
    Ensures that the VHD is Present or Absent.
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
        [String]
        $Path,

        [Parameter()]
        [String]
        $ParentPath,

        [Parameter()]
        [Uint64]
        $MaximumSizeBytes,

        [Parameter()]
        [ValidateSet('Vhd', 'Vhdx')]
        [String]
        $Generation = 'Vhd',

        [Parameter()]
        [ValidateSet('Dynamic', 'Fixed', 'Differencing')]
        [String]
        $Type = 'Dynamic',

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present'
    )

    # Check if Hyper-V module is present for Hyper-V cmdlets
    if (!(Get-Module -ListAvailable -Name Hyper-V))
    {
        Throw "Please ensure that Hyper-V role is installed with its PowerShell module"
    }

    # input validation
    if ($Type -ne 'Differencing' -and -not $MaximumSizeBytes)
    {
       Throw 'Specify MaximumSizeBytes property for Fixed and Dynamic VHDs.'
    }

    if ($ParentPath -and $Type -ne 'Differencing')
    {
        Throw 'Parent path is only supported for Differencing disks'
    }

    if (-not $ParentPath -and $Type -eq 'Differencing')
    {
        Throw 'Differencing requires a parent path'
    }

    if ($ParentPath)
    {
        if (!(Test-Path -Path $ParentPath))
        {
            Throw "$ParentPath does not exists"
        }

        # Check if the generation matches parenting disk
        if ($Generation -and ($ParentPath.Split('.')[-1] -ne $Generation))
        {
            Throw "Generation $Generation should match ParentPath extension $($ParentPath.Split('.')[-1])"
        }
    }

    if (!(Test-Path -Path $Path))
    {
        Throw "$Path does not exists"
    }

    # Construct the full path for the vhdFile
    $vhdName = GetNameWithExtension -Name $Name -Generation $Generation
    $vhdFilePath = Join-Path -Path $Path -ChildPath $vhdName
    Write-Verbose -Message "Vhd full path is $vhdFilePath"

    # Add the logic here and at the end return either $true or $false.
    $result = Test-VHD -Path $vhdFilePath -ErrorAction SilentlyContinue
    Write-Verbose -Message "Vhd $vhdFilePath is present:$result and Ensure is $Ensure"
    return ($result -and ($Ensure -eq "Present"))
}

<#
.SYNOPSIS
    Appends generation appropriate file extension if not already specified.

.PARAMETER Name
    The desired VHD file name.

.PARAMETER Generation
    Virtual disk format.
#>
function GetNameWithExtension
{
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $Name,

        [Parameter(Mandatory = $true)]
        [String]
        $Generation = 'Vhd'
    )

     # If the name ends with vhd or vhdx don't append the generation to the vhdname.
    if ($Name -like '*.vhd' -or $Name -like '*.vhdx')
    {
        $extension = $Name.Split('.')[-1]
        if ($Generation -ne $extension)
        {
            throw "the extension $extension on the name does not match the generation $Generation"
        }
        else
        {
            Write-Verbose -Message "Vhd full name is $vhdName"
            $vhdName = $Name
        }
    }
    else
    {
        # Append generation to the name
        $vhdName = "$Name.$Generation"
        Write-Verbose -Message "Vhd full name is $vhdName"
    }

    $vhdName
}

Export-ModuleMember -Function *-TargetResource
