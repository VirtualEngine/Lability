function New-LabSwitch {
<#
    .SYNOPSIS
        Creates a new Lability network switch object.
    .DESCRIPTION
        Permits validation of custom NonNodeData\Lability\Network entries.
#>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        ## Virtual switch name
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Name,

        ## Virtual switch type
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateSet('Internal','External','Private')]
        [System.String] $Type,

        ## Physical network adapter name (for external switches)
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNull()]
        [System.String] $NetAdapterName,

        ## Share host access (for external virtual switches)
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNull()]
        [System.Boolean] $AllowManagementOS = $false,

        ## Virtual switch availability
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    begin {

        if (($Type -eq 'External') -and (-not $NetAdapterName)) {

            throw ($localized.MissingParameterError -f 'NetAdapterName');
        }

    } #end begin
    process {

        $newLabSwitch = @{
            Name = $Name;
            Type = $Type;
            NetAdapterName = $NetAdapterName;
            AllowManagementOS = $AllowManagementOS;
            Ensure = $Ensure;
        }
        if ($Type -ne 'External') {

            [ref] $null = $newLabSwitch.Remove('NetAdapterName');
            [ref] $null = $newLabSwitch.Remove('AllowManagementOS');
        }
        return $newLabSwitch;

    } #end process
} #end function
