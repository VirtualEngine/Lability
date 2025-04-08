function New-LabImage {
<#
    .SYNOPSIS
        Creates a new master/parent lab image.
    .DESCRIPTION
        The New-LabImage cmdlet starts the creation of a lab VHD(X) master image from the specified media Id.

        Lability will automatically create lab images as required. If there is a need to manally recreate an image,
        then the New-LabImage cmdlet can be used.
    .PARAMETER Id
        Specifies the media Id of the image to create.
    .PARAMETER ConfigurationData
        Specifies a PowerShell DSC configuration data hashtable or a path to an existing PowerShell DSC .psd1
        configuration document that contains the required media definition.
    .PARAMETER Force
        Specifies that any existing image should be overwritten.
    .EXAMPLE
        New-LabImage -Id 2016_x64_Datacenter_EN_Eval

        Creates the VHD(X) image from the '2016_x64_Datacenter_EN_Eval' media Id.
    .EXAMPLE
        New-LabImage -Id 2016_x64_Datacenter_EN_Eval -Force

        Creates the VHD(X) image from the '2016_x64_Datacenter_EN_Eval' media Id, overwriting an existing image with the same name.
    .LINK
        Get-LabMedia
        Get-LabImage
#>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        ## Lab media Id
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Id,

        ## Lab DSC configuration data
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,

        ## Force the re(creation) of the master/parent image
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force
    )
    process
    {
        ## Download media if required..
        [ref] $null = $PSBoundParameters.Remove('Force')
        [ref] $null = $PSBoundParameters.Remove('WhatIf')
        [ref] $null = $PSBoundParameters.Remove('Confirm')

        $media = Resolve-LabMedia @PSBoundParameters
        ## Update media Id if alias was/is used
        $Id = $media.Id

        if ((Test-LabImage @PSBoundParameters) -and $Force)
        {
            $image = Get-LabImage @PSBoundParameters
            Write-Verbose -Message ($localized.RemovingDiskImage -f $image.ImagePath)
            [ref] $null = Remove-Item -Path $image.ImagePath -Force -ErrorAction Stop
        }
        elseif (Test-LabImage @PSBoundParameters)
        {
            throw ($localized.ImageAlreadyExistsError -f $Id)
        }

        ## Check Dism requirement (if present) #167
        if ($null -ne $media.CustomData.MinimumDismVersion)
        {
            $minimumDismVersion = $media.CustomData.MinimumDismVersion
            if ($labDefaults.DismVersion -lt $minimumDismVersion)
            {
                throw ($localized.DismVersionMismatchError -f $Id, $minimumDismVersion.ToString())
            }
        }

        $hostDefaults = Get-ConfigurationData -Configuration Host

        if ($media.MediaType -eq 'VHD')
        {
            $mediaFileInfo = Invoke-LabMediaImageDownload -Media $media
            Write-Verbose -Message ($localized.ImportingExistingDiskImage -f $media.Description)
            $imageName = $media.Filename
            $imagePath = Join-Path -Path $hostDefaults.ParentVhdPath -ChildPath $imageName
        } #end if VHD
        elseif ($media.MediaType -eq 'NULL')
        {
            Write-Verbose -Message ($localized.CreatingDiskImage -f $media.Description)
            $imageName = '{0}.vhdx' -f $Id
            $imagePath = Join-Path -Path $hostDefaults.ParentVhdPath -ChildPath $imageName

            ## Create disk image and refresh PSDrives
            $newEmptyDiskImageParams = @{
                Path = $imagePath
                Force = $true
                ErrorAction = 'Stop'
            }

            if ($media.CustomData.DiskType)
            {
                $newEmptyDiskImageParams['Type'] = $media.CustomData.DiskType
            }

            if ($media.CustomData.DiskSize)
            {
                $newEmptyDiskImageParams['Size'] = $media.CustomData.DiskSize
            }

            $image = New-EmptyDiskImage @newEmptyDiskImageParams
        }
        else
        {
            ## Create VHDX
            $mediaFileInfo = Invoke-LabMediaImageDownload -Media $media

            if ($media.CustomData.PartitionStyle)
            {
                ## Custom partition style has been defined so use that
                $partitionStyle = $media.CustomData.PartitionStyle
            }
            elseif ($media.Architecture -eq 'x86')
            {
                ## Otherwise default to MBR for x86 media
                $partitionStyle = 'MBR'
            }
            else
            {
                $partitionStyle = 'GPT'
            }

            Write-Verbose -Message ($localized.CreatingDiskImage -f $media.Description)

            $imageName = '{0}.vhdx' -f $Id
            $imagePath = Join-Path -Path $hostDefaults.ParentVhdPath -ChildPath $imageName

            ## Apply WIM (Expand-LabImage) and add specified features
            $expandLabImageParams = @{
                MediaPath = $mediaFileInfo.FullName
                PartitionStyle = $partitionStyle
            }

            ## Determine whether we're using the WIM image index or image name. This permits
            ## specifying an integer image index in a media's 'ImageName' property.
            [System.Int32] $wimImageIndex = $null
            if ([System.Int32]::TryParse($media.ImageName, [ref] $wimImageIndex))
            {
                $expandLabImageParams['WimImageIndex'] = $wimImageIndex
            }
            else
            {
                if ([System.String]::IsNullOrEmpty($media.ImageName))
                {
                    throw ($localized.ImageNameRequiredError -f 'ImageName')
                }

                $expandLabImageParams['WimImageName'] = $media.ImageName
            }

            $imageCreationFailed = $false

            try
            {
                ## Create disk image and refresh PSDrives
                $newDiskImageParams = @{
                    Path = $imagePath
                    PartitionStyle = $partitionStyle
                    Passthru = $true
                    Force = $true
                    ErrorAction = 'Stop'
                }

                if ($media.CustomData.DiskType)
                {
                    $newDiskImageParams['Type'] = $media.CustomData.DiskType
                }

                if ($media.CustomData.DiskSize)
                {
                    $newDiskImageParams['Size'] = $media.CustomData.DiskSize
                }

                $image = New-DiskImage @newDiskImageParams
                [ref] $null = Get-PSDrive

                $expandLabImageParams['Vhd'] = $image

                if ($media.CustomData.SourcePath)
                {
                    $expandLabImageParams['SourcePath'] = $media.CustomData.SourcePath
                }
                if ($media.CustomData.WimPath)
                {
                    $expandLabImageParams['WimPath'] = $media.CustomData.WimPath
                }
                if ($media.CustomData.WindowsOptionalFeature)
                {
                    $expandLabImageParams['WindowsOptionalFeature'] = $media.CustomData.WindowsOptionalFeature
                }
                if ($media.CustomData.PackagePath)
                {
                    $expandLabImageParams['PackagePath'] = $media.CustomData.PackagePath
                }
                if ($media.CustomData.Package)
                {
                    $expandLabImageParams['Package'] = $media.CustomData.Package
                }
                if ($media.CustomData.PackageLocale)
                {
                    $expandLabImageParams['PackageLocale'] = $media.CustomData.PackageLocale
                }

                Expand-LabImage @expandLabImageParams

                ## Apply hotfixes (Add-DiskImageHotfix)
                $addDiskImageHotfixParams = @{
                    Id = $Id
                    Vhd = $image
                    PartitionStyle = $partitionStyle
                }
                if ($PSBoundParameters.ContainsKey('ConfigurationData'))
                {
                    $addDiskImageHotfixParams['ConfigurationData'] = $ConfigurationData
                }
                Add-DiskImageHotfix @addDiskImageHotfixParams

                ## Configure boot volume (Set-DiskImageBootVolume)
                Set-DiskImageBootVolume -Vhd $image -PartitionStyle $partitionStyle
            }
            catch
            {
                ## Have to ensure VHDX is dismounted before we can delete!
                $imageCreationFailed = $true
                Write-Error -Message $_
            }
            finally
            {
                ## Dismount VHDX
                Hyper-V\Dismount-VHD -Path $imagePath
            }

            if ($imageCreationFailed -eq $true)
            {
                Write-Warning -Message ($localized.RemovingIncompleteImageWarning -f $imagePath)
                Remove-Item -Path $imagePath -Force
            }
        } #end if ISO/WIM

        return (Get-LabImage $PSBoundParameters)

    } #end process
} #end function New-LabImage
