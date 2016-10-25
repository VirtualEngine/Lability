function SetLabVMDiskFileMof {

<#
    .SYNOPSIS
        Copies a node's mof files to a VHD(X) file.
#>
    [CmdletBinding()]
    param (
        ## Lab VM/Node name
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $NodeName,

        ## Lab VM/Node DSC .mof and .meta.mof configuration files
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $Path,

        ## Mounted VHD path
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $VhdDriveLetter,

        ## Catch all to enable splatting @PSBoundParameters
        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments
    )
    process {

        $bootStrapPath = '{0}:\BootStrap' -f $VhdDriveLetter;
        $mofPath = Join-Path -Path $Path -ChildPath ('{0}.mof' -f $NodeName);

        if (-not (Test-Path -Path $mofPath)) {

            WriteWarning -Message ($localized.CannotLocateMofFileError -f $mofPath);
        }
        else {

            $destinationMofPath = Join-Path -Path $bootStrapPath -ChildPath 'localhost.mof';
            WriteVerbose -Message ($localized.AddingDscConfiguration -f $destinationMofPath);
            Copy-Item -Path $mofPath -Destination $destinationMofPath -Force -ErrorAction Stop;
        }

        $metaMofPath = Join-Path -Path $Path -ChildPath ('{0}.meta.mof' -f $NodeName);
        if (Test-Path -Path $metaMofPath -PathType Leaf) {

            $destinationMetaMofPath = Join-Path -Path $bootStrapPath -ChildPath 'localhost.meta.mof';
            WriteVerbose -Message ($localized.AddingDscConfiguration -f $destinationMetaMofPath);
            Copy-Item -Path $metaMofPath -Destination $destinationMetaMofPath -Force;
        }

    } #end process

}

