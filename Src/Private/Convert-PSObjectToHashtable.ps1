function ConvertPSObjectToHashtable {
<#
    .SYNOPSIS
        Converts a PSCustomObject's properties to a hashtable.
#>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        ## Object to convert to a hashtable
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Management.Automation.PSObject[]] $InputObject,

        ## Do not add empty/null values to the generated hashtable
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $IgnoreNullValues
    )
    process {

        foreach ($object in $InputObject) {

            $hashtable = @{ }
            foreach ($property in $object.PSObject.Properties) {

                if ($IgnoreNullValues) {
                    if ([System.String]::IsNullOrEmpty($property.Value)) {
                        ## Ignore empty strings
                        continue;
                    }
                }

                if ($property.TypeNameOfValue -eq 'System.Management.Automation.PSCustomObject') {

                    ## Convert nested custom objects to hashtables
                    $hashtable[$property.Name] = ConvertPSObjectToHashtable -InputObject $property.Value -IgnoreNullValues:$IgnoreNullValues;
                }
                else {

                    $hashtable[$property.Name] = $property.Value;
                }

            } #end foreach property
            Write-Output $hashtable;

        }
    } #end proicess
} #end function

