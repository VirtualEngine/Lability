function Convert-PSObjectToHashtable {
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


                if ($IgnoreNullValues -and ($property.TypeNameOfValue -ne 'System.Object[]')) {
                    if ([System.String]::IsNullOrEmpty($property.Value)) {
                        ## Ignore empty strings
                        continue;
                    }
                }

                if ($property.TypeNameOfValue -eq 'System.Management.Automation.PSCustomObject') {

                    ## Convert nested custom objects to hashtables
                    $hashtable[$property.Name] = Convert-PSObjectToHashtable -InputObject $property.Value -IgnoreNullValues:$IgnoreNullValues;
                }
                elseif ($property.TypeNameOfValue -eq 'System.Object[]') {

                    ## Convert nested arrays of objects to an array of hashtables (#262)
                    $nestedCollection = @();
                    foreach ($object in $property.Value) {

                        $nestedCollection += Convert-PSObjectToHashtable -InputObject $object -IgnoreNullValues:$IgnoreNullValues;
                    }
                    $hashtable[$property.Name] = $nestedCollection;
                }
                else {

                    $hashtable[$property.Name] = $property.Value;
                }

            } #end foreach property
            Write-Output $hashtable;

        }
    } #end proicess
} #end function
