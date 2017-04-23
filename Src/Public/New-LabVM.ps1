function New-LabVM {
<#
    .SYNOPSIS
        Creates a simple bare-metal virtual machine.
    .DESCRIPTION
        The New-LabVM cmdlet creates a bare virtual machine using the specified media. No bootstrap or DSC configuration is applied.

        NOTE: The mandatory -MediaId parameter is dynamic and is not displayed in the help syntax output.

        If optional values are not specified, the virtual machine default settings are applied. To list the current default settings run the `Get-LabVMDefault` command.

        NOTE: If a specified virtual switch cannot be found, an Internal virtual switch will automatically be created. To use any other virtual switch configuration, ensure the virtual switch is created in advance.
    .LINK
        Register-LabMedia
        Unregister-LabMedia
        Get-LabVMDefault
        Set-LabVMDefault
#>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'PSCredential')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingUserNameAndPassWordParams','')]
    param (
        ## Specifies the virtual machine name.
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Name,

        ## Default virtual machine startup memory (bytes).
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(536870912, 1099511627776)]
        [System.Int64] $StartupMemory,

        ## Default virtual machine miniumum dynamic memory allocation (bytes).
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(536870912, 1099511627776)]
        [System.Int64] $MinimumMemory,

        ## Default virtual machine maximum dynamic memory allocation (bytes).
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(536870912, 1099511627776)]
        [System.Int64] $MaximumMemory,

        ## Default virtual machine processor count.
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(1, 4)]
        [System.Int32] $ProcessorCount,

        # Input Locale
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidatePattern('^([a-z]{2,2}-[a-z]{2,2})|(\d{4,4}:\d{8,8})$')]
        [System.String] $InputLocale,

        # System Locale
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidatePattern('^[a-z]{2,2}-[a-z]{2,2}$')]
        [System.String] $SystemLocale,

        # User Locale
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidatePattern('^[a-z]{2,2}-[a-z]{2,2}$')]
        [System.String] $UserLocale,

        # UI Language
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidatePattern('^[a-z]{2,2}-[a-z]{2,2}$')]
        [System.String] $UILanguage,

        # Timezone
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Timezone,

        # Registered Owner
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $RegisteredOwner,

        # Registered Organization
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('RegisteredOrganisation')]
        [ValidateNotNullOrEmpty()]
        [System.String] $RegisteredOrganization,

        ## Local administrator password of the VM. The username is NOT used.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'PSCredential')]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential = (& $credentialCheckScriptBlock),

        ## Local administrator password of the VM.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Password')]
        [ValidateNotNullOrEmpty()]
        [System.Security.SecureString] $Password,

        ## Virtual machine switch name(s).
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $SwitchName,

        ## Virtual machine MAC address(es).
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $MACAddress,

        ## Enable Secure boot status
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Boolean] $SecureBoot,

        ## Enable Guest Integration Services
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Boolean] $GuestIntegrationServices,

        ## Custom data
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNull()]
        [System.Collections.Hashtable] $CustomData,

        ## Skip creating baseline snapshots
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $NoSnapshot
    )
    DynamicParam {

        ## Adds a dynamic -MediaId parameter that returns the available media Ids
        $parameterAttribute = New-Object -TypeName 'System.Management.Automation.ParameterAttribute';
        $parameterAttribute.ParameterSetName = '__AllParameterSets';
        $parameterAttribute.Mandatory = $true;
        $attributeCollection = New-Object -TypeName 'System.Collections.ObjectModel.Collection[System.Attribute]';
        $attributeCollection.Add($parameterAttribute);
        $mediaIds = (Get-LabMedia).Id;
        $validateSetAttribute = New-Object -TypeName 'System.Management.Automation.ValidateSetAttribute' -ArgumentList $mediaIds;
        $attributeCollection.Add($validateSetAttribute);
        $runtimeParameter = New-Object -TypeName 'System.Management.Automation.RuntimeDefinedParameter' -ArgumentList @('MediaId', [System.String], $attributeCollection);
        $runtimeParameterDictionary = New-Object -TypeName 'System.Management.Automation.RuntimeDefinedParameterDictionary';
        $runtimeParameterDictionary.Add('MediaId', $runtimeParameter);
        return $runtimeParameterDictionary;
    }
    begin {

        ## If we have only a secure string, create a PSCredential
        if ($PSCmdlet.ParameterSetName -eq 'Password') {
            $Credential = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList 'LocalAdministrator', $Password;
        }
        if (-not $Credential) { throw ($localized.CannotProcessCommandError -f 'Credential'); }
        elseif ($Credential.Password.Length -eq 0) { throw ($localized.CannotBindArgumentError -f 'Password'); }

    } #end begin
    process {

        ## Skeleton configuration node
        $configurationNode = @{ }

        if ($CustomData) {

            ## Add all -CustomData keys/values to the skeleton configuration
            foreach ($key in $CustomData.Keys) {

                $configurationNode[$key] = $CustomData.$key;
            }
        }

        ## Explicitly defined parameters override any -CustomData
        $parameterNames = @('StartupMemory','MinimumMemory','MaximumMemory','SwitchName','Timezone','UILanguage','MACAddress',
            'ProcessorCount','InputLocale','SystemLocale','UserLocale','RegisteredOwner','RegisteredOrganization','SecureBoot')
        foreach ($key in $parameterNames) {

            if ($PSBoundParameters.ContainsKey($key)) {

                $configurationNode[$key] = $PSBoundParameters.$key;
            }
        }

        ## Ensure the specified MediaId is applied after any CustomData media entry!
        $configurationNode['Media'] = $PSBoundParameters.MediaId;

        $currentNodeCount = 0;
        foreach ($vmName in $Name) {

            ## Update the node name before creating the VM
            $configurationNode['NodeName'] = $vmName;
            $shouldProcessMessage = $localized.PerformingOperationOnTarget -f 'New-LabVM', $vmName;
            $verboseProcessMessage = GetFormattedMessage -Message ($localized.CreatingQuickVM -f $vmName, $PSBoundParameters.MediaId);
            if ($PSCmdlet.ShouldProcess($verboseProcessMessage, $shouldProcessMessage, $localized.ShouldProcessWarning)) {

                $currentNodeCount++;
                [System.Int32] $percentComplete = (($currentNodeCount / $Name.Count) * 100) - 1;
                $activity = $localized.ConfiguringNode -f $vmName;
                Write-Progress -Id 42 -Activity $activity -PercentComplete $percentComplete;

                $configurationData = @{ AllNodes = @( $configurationNode ) };
                New-LabVirtualMachine -Name $vmName -ConfigurationData $configurationData -Credential $Credential -NoSnapshot:$NoSnapshot -IsQuickVM;
            }

        } #end foreach name

        if (-not [System.String]::IsNullOrEmpty($activity)) {

            Write-Progress -Id 42 -Activity $activity -PercentComplete $percentComplete;
        }

    } #end process
} #end function New-LabVM
