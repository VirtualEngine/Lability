function Set-LabVMDiskModule {
<#
    .SYNOPSIS
        Downloads (if required) PowerShell/DSC modules and expands
        them to the destination path specified.
#>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
    param (
        ## Lability PowerShell modules/DSC resource hashtable
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable[]] $Module,

        ## The target VHDX modules path
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $DestinationPath,

        ## Force a download of the module(s) even if they already exist in the cache.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force,

        ## Removes existing target module directory (if present)
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Clean,

        ## Credentials to access the a private feed
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $FeedCredential
    )
    process {

        ## Invokes the module download if not cached, and returns the source
        [ref] $null = Invoke-LabModuleCacheDownload -Module $Module -Force:$Force -FeedCredential $FeedCredential;
        ## Expand the modules into the VHDX file
        [ref] $null = Expand-LabModuleCache -Module $Module -DestinationPath $DestinationPath -Clean:$Clean;

    } #end process
} #end function
