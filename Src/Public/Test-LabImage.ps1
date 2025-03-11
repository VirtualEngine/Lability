function Test-LabImage {
<#
    .SYNOPSIS
        Tests whether a master/parent lab image is present.
    .DESCRIPTION
        The Test-LabImage cmdlet returns whether a specified disk image is present.
    .PARAMETER Id
        Specifies the media Id of the image to test.
    .PARAMETER ConfigurationData
        Specifies a PowerShell DSC configuration data hashtable or a path to an existing PowerShell DSC .psd1
        configuration document that contains the required media definition.
    .EXAMPLE
        Test-LabImage -Id 2016_x64_Datacenter_EN_Eval

        Tests whether the '-Id 2016_x64_Datacenter_EN_Eval' lab image is present.
    .LINK
        Get-LabImage
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Id,

        ## Lab DSC configuration data
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData
    )
    process {

        if (Get-LabImage @PSBoundParameters) {

            return $true;
        }
        else {

            return $false;
        }

    } #end process
} #end function Test-LabImage
