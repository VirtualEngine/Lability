
function Export-LabImage {
<#
    .SYNOPSIS
        Exports a lab image (.vhdx file) and creates Lability custom media registration document (.json file).
#>
    [CmdletBinding()]
    param (
        ## Lab media Id
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Id,

        # Specifies the export path location.
        [Parameter(Mandatory, ParameterSetName = 'Path', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias("PSPath")]
        [System.String] $Path,

        # Specifies a literal export location path.
        [Parameter(Mandatory, ParameterSetName = 'LiteralPath', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.String] $LiteralPath,

        ## Force the re(creation) of the master/parent image
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force,

        ## Do not calculate media checksum.
        [Parameter()]
        [System.Management.Automation.SwitchParameter] $NoChecksum,

        ## Do not create Lability custom media regstration (json) file.
        [Parameter()]
        [System.Management.Automation.SwitchParameter] $NoRegistrationDocument
    )
    begin {

        try {

            if ($PSCmdlet.ParameterSetName -eq 'Path') {

                # Resolve any relative paths
                $Path = $PSCmdlet.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);
            }
            else {

                $Path = $PSCmdlet.SessionState.Path.GetUnresolvedProviderPathFromPSPath($LiteralPath);
            }

            $pathItem = Get-Item -Path $Path
            if ($pathItem -isnot [System.IO.DirectoryInfo]) {
                throw "not a directory path"
            }
        }
        catch {

            Write-Error -ErrorRecord $_
        }

    }
    process {

        foreach ($mediaId in $Id) {

            try {

                $media = Resolve-LabMedia -Id $mediaId -ErrorAction Stop
                $image = Get-LabImage -Id $mediaId -ErrorAction Stop

                ## Copy vhd/x file to destination path
                $imageItem = Get-Item -Path $image.ImagePath
                $destinationVhdxPath = Join-Path -Path $Path -ChildPath $imageItem.Name
                if (-not (Test-Path -Path $destinationVhdxPath -PathType Leaf) -or $Force) {

                    Write-Verbose -Message ($localized.ExportingImage -f $image.ImagePath, $destinationVhdxPath)
                    Copy-Item -Path $image.ImagePath -Destination $destinationVhdxPath -Force

                    if (-not $NoRegistrationDocument) {

                        ## Create media registration json
                        $registerLabMedia = [ordered] @{
                            Id              = $media.Id
                            Filename        = $imageItem.Name
                            Description     = $media.Description
                            OperatingSystem = $media.OperatingSystem
                            Architecture    = $media.Architecture
                            MediaType       = 'VHD'
                            Uri             = $destinationVhdxPath -as [System.Uri]
                            CustomData      = $media.CustomData
                        }

                        if (-not $NoChecksum) {
                            Write-Verbose ($localized.CalculatingResourceChecksum -f $image.ImagePath)
                            $checksum = (Get-FileHash -Path $image.ImagePath -Algorithm MD5).Hash
                            $registerLabMedia['Checksum'] = $checksum
                        }

                        $registerLabMediaFilename = '{0}.json' -f $media.Id
                        $registerLabMediaPath = Join-Path -Path $Path -ChildPath $registerLabMediaFilename
                        Write-Verbose -Message ($localized.ExportingImageRegistrationFile -f $registerLabMediaPath)
                        ConvertTo-Json -InputObject $registerLabMedia |
                            Out-File -FilePath $registerLabMediaPath -Encoding ASCII -Force
                    }
                }
                else {

                    $errorMessage = $localized.FileAlreadyExistsError -f $destinationVhdxPath;
                    $ex = New-Object -TypeName System.InvalidOperationException -ArgumentList $errorMessage;
                    $errorCategory = [System.Management.Automation.ErrorCategory]::ResourceExists;
                    $errorRecord = New-Object System.Management.Automation.ErrorRecord $ex, 'FileExists', $errorCategory, $destinationVhdxPath;
                    $PSCmdlet.WriteError($errorRecord);
                }
            }
            catch {

                Write-Error -ErrorRecord $_
            }
        }
    }
}
