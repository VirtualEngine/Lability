function ResolveCustomBootStrap {

<#
    .SYNOPSIS
        Resolves the media and node custom bootstrap, using the specified CustomBootstrapOrder
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        ## Custom bootstrap order
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateSet('ConfigurationFirst','ConfigurationOnly','Disabled','MediaFirst','MediaOnly')]
        [System.String] $CustomBootstrapOrder,

        ## Node/configuration custom bootstrap script
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [System.String] $ConfigurationCustomBootStrap,

        ## Media custom bootstrap script
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [System.String[]] $MediaCustomBootStrap
    )
    begin {

        if ([System.String]::IsNullOrWhiteSpace($ConfigurationCustomBootStrap)) {

            $ConfigurationCustomBootStrap = "";
        }
        ## Convert the string[] into a multi-line string
        if ($MediaCustomBootstrap) {

            $mediaBootstrap = [System.String]::Join("`r`n", $MediaCustomBootStrap);
        }
        else {

            $mediaBootstrap = "";
        }
    } #end begin
    process {

        switch ($CustomBootstrapOrder) {

            'ConfigurationFirst' {
                $bootStrap = "{0}`r`n{1}" -f $ConfigurationCustomBootStrap, $mediaBootstrap;
            }
            'ConfigurationOnly' {
                $bootStrap = $ConfigurationCustomBootStrap;
            }
            'MediaFirst' {
                $bootStrap = "{0}`r`n{1}" -f $mediaBootstrap, $ConfigurationCustomBootStrap;
            }
            'MediaOnly' {
                $bootStrap = $mediaBootstrap;
            }
            Default {
                #Disabled
            }
        } #end switch

        return $bootStrap;

    } #end process

}

