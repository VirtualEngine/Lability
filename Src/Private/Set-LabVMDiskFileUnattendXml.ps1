function Set-LabVMDiskFileUnattendXml {
<#
    .SYNOPSIS
        Copies a node's unattent.xml to a VHD(X) file.
#>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
    param (
        ## Lab VM/Node name
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $NodeName,

        ## Lab DSC configuration data
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,

        ## Mounted VHD path
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $VhdDriveLetter,

        ## Local administrator password of the VM
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        ## Media-defined product key
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ProductKey,

        ## Catch all to enable splatting @PSBoundParameters
        [Parameter(ValueFromRemainingArguments)]
        $RemainingArguments
    )
    process {

        $node = Resolve-NodePropertyValue -NodeName $NodeName -ConfigurationData $ConfigurationData -ErrorAction Stop;

        ## Create Unattend.xml
        $newUnattendXmlParams = @{
            ComputerName = $node.NodeName.Split('.')[0]; # Convert any FQDN to NetBIOS (#335)
            Credential = $Credential;
            InputLocale = $node.InputLocale;
            SystemLocale = $node.SystemLocale;
            UserLocale = $node.UserLocale;
            UILanguage = 'en-US';
            Timezone = $node.Timezone;
            RegisteredOwner = $node.RegisteredOwner;
            RegisteredOrganization = $node.RegisteredOrganization;
        }
        Write-Verbose -Message $localized.SettingAdministratorPassword;

        ## Node defined Product Key takes preference over key defined in the media definition
        if ($node.CustomData.ProductKey) {

            $newUnattendXmlParams['ProductKey'] = $node.CustomData.ProductKey;
        }
        elseif ($PSBoundParameters.ContainsKey('ProductKey')) {

            $newUnattendXmlParams['ProductKey'] = $ProductKey;
        }

        ## TODO: We probably need to be localise the \Windows\ (%ProgramFiles% has been done) directory?
        $unattendXmlPath = '{0}:\Windows\System32\Sysprep\Unattend.xml' -f $VhdDriveLetter;
        Write-Verbose -Message ($localized.AddingUnattendXmlFile -f $unattendXmlPath);
        [ref] $null = Set-UnattendXml @newUnattendXmlParams -Path $unattendXmlPath;

    } #end process
} #end function
