function Set-LabVirtualMachineNetworkAdapter {
    <#
        .SYNOPSIS
            Sets a virtual machine's additional hard disk drive(s).
        .DESCRIPTION
            Adds one or more additional hard disks to a VM.
    #>
        [CmdletBinding()]
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
        param (
            ## Lab VM/Node name
            [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
            [System.String] $NodeName,
    
            ## Collection of network adapter configurations
            [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
            [System.Collections.Hashtable[]]
            $NetAdapterConfiguration,

            ## Specifies a PowerShell DSC configuration document (.psd1) containing the lab configuration.
            [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
            [System.Collections.Hashtable]
            [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
            $ConfigurationData

        )
        process {
    
            foreach( $netAdapterConf in $NetAdapterConfiguration  ){

                <#
                        [Parameter(Mandatory = $true)]
                        [System.String]
                        $Id,

                        [Parameter(Mandatory = $true)]
                        [System.String]
                        $Name,

                        [Parameter(Mandatory = $true)]
                        [System.String]
                        $SwitchName,

                        [Parameter(Mandatory = $true)]
                        [System.String]
                        $VMName,
                #>

                Write-Debug "Getting adapters for VM $($NodeName)"

                $resolveLabSwitchParams = @{
                    Name = $netAdapterConf.SwitchName;
                    ConfigurationData = $ConfigurationData;
                    WarningAction = 'SilentlyContinue';
                }
                $networkSwitch = Resolve-LabSwitch @resolveLabSwitchParams;

                $adapter = Get-VMNetworkAdapter -VMName $NodeName | Where-Object{ $_.Switchname -eq $networkSwitch.Name }

                if( $null -eq $adapter ){
                    throw "Cannot locate any adapter on VM $($Nodename) that is connected to switch $($networkSwitch.Name)"
                }
                else{
                    $netAdapterConfigurationParams = @{
                        Id = $adapter.Id
                        VMName = $NodeName
                        SwitchName = $networkSwitch.Name
                        Name = $adapter.Name
                    }

                    # Check parameters are defined in ConfigurationData or if we keep the values from object creation
                    if( $null -ne $netAdapterConf.Name){
                        $netAdapterConfigurationParams["Name"] = $netAdapterConf.Name
                    }

                    if($null -ne $netAdapterConf.MacAddress){
                        $netAdapterConfigurationParams["MacAddress"] = $netAdapterConf.MacAddress
                    }

                    if( $null -ne $netAdapterConf.VlanId ){
                        $netAdapterConfigurationParams["VlanId"] = $netAdapterConf.VlanId
                    }

                    Write-Verbose -Message ($localized.ConfiguringNetworkAdapter -f $netAdapterConfigurationParams.Id, $NodeName);

                    foreach( $key in $netAdapterConfigurationParams.Keys ){
                        Write-Verbose "$($key) = $($netAdapterConfigurationParams.$key)"
                    }

                    Import-LabDscResource -ModuleName xHyper-V -ResourceName MSFT_xVMNetworkAdapter -Prefix VMNetworkAdapter;
                    Invoke-LabDscResource -ResourceName VMNetworkAdapter -Parameters $netAdapterConfigurationParams;

                }
            }

        } #end process
    } #end function
    