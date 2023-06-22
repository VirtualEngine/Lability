function Test-LabModuleCache {
<#
    .SYNOPSIS
            Tests whether the requested PowerShell module is cached.
#>
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    [OutputType([System.Boolean])]
    param (
        ## PowerShell module/DSC resource module name
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameMinimum')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameRequired')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        ## The minimum version of the module required
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'NameMinimum')]
        [ValidateNotNullOrEmpty()]
        [System.Version] $MinimumVersion,

        ## The exact version of the module required
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'NameRequired')]
        [ValidateNotNullOrEmpty()]
        [System.Version] $RequiredVersion,

        ## GitHub repository owner
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameMinimum')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameRequired')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Owner,

        ## GitHub repository branch
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameMinimum')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameRequired')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Branch,

        ## Source Filesystem module path
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameMinimum')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameRequired')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## Provider used to download the module
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameMinimum')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NameRequired')]
        [ValidateSet('PSGallery','GitHub','AzDo', 'FileSystem')]
        [System.String] $Provider,

        ## Lability PowerShell module info hashtable
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Module')]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Hashtable] $Module,

        ## Catch all to be able to pass parameter via $PSBoundParameters
        [Parameter(ValueFromRemainingArguments)] $RemainingArguments
    )
    begin {

        ## Remove -RemainingArguments to stop it being passed on.
        [ref] $null = $PSBoundParameters.Remove('RemainingArguments');

    }
    process {

        $moduleFileInfo = Get-LabModuleCache @PSBoundParameters;
        return ($null -ne $moduleFileInfo);

    } #end process
} #end function
