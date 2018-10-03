function ConvertTo-ConfigurationData {
<#
     .SYNOPSIS
         Converts a file path string to a hashtable. This mimics the -ConfigurationData parameter of the
         Start-DscConfiguration cmdlet.
 #>
     [CmdletBinding()]
     [OutputType([System.Collections.Hashtable])]
     param (
         [Parameter(Mandatory, ValueFromPipeline)]
         [System.String] $ConfigurationData
     )
     process {

        $configurationDataPath = Resolve-Path -Path $ConfigurationData -ErrorAction Stop;
        if (-not (Test-Path -Path $configurationDataPath -PathType Leaf)) {

            throw ($localized.InvalidConfigurationDataFileError -f $ConfigurationData);
        }
        elseif ([System.IO.Path]::GetExtension($configurationDataPath) -ne '.psd1') {

            throw ($localized.InvalidConfigurationDataFileError -f $ConfigurationData);
        }
        $configurationDataContent = Get-Content -Path $configurationDataPath -Raw;
        $configData = Invoke-Command -ScriptBlock ([System.Management.Automation.ScriptBlock]::Create($configurationDataContent));
        if ($configData -isnot [System.Collections.Hashtable]) {

            throw ($localized.InvalidConfigurationDataType -f $configData.GetType());
        }
        return $configData;

    } #end process
} #end function ConvertTo-ConfigurationData
