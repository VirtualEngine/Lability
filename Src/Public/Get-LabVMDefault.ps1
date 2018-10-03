function Get-LabVMDefault {
<#
    .SYNOPSIS
        Gets the current lab virtual machine default settings.
#>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param ( )
    process {

        $vmDefaults = Get-ConfigurationData -Configuration VM;

        ## BootOrder property should not be exposed via the Get-LabVMDefault/Set-LabVMDefault
        $vmDefaults.PSObject.Properties.Remove('BootOrder');
        return $vmDefaults;

    }
} #end function
