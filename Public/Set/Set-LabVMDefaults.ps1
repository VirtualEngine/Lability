function Set-LabVMDefaults {

<#
    .SYNOPSIS
        Sets the lab virtual machine default settings.
    .NOTES
        Proxy function replacing alias to enable warning output.
#>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Management.Automation.PSCustomObject])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns','')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess','')]
    param (
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

        ## Default virtual machine media Id.
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Media,

        ## Lab host internal switch name.
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $SwitchName,

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
        [ValidateNotNullOrEmpty()]
        [System.String] [Alias('RegisteredOrganisation')] $RegisteredOrganization,

        ## Client PFX certificate bundle used to encrypt DSC credentials
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNull()]
        [System.String] $ClientCertificatePath,

        ## Client certificate's issuing Root Certificate Authority (CA) certificate
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNull()]
        [System.String] $RootCertificatePath,

        ## Boot delay/pause between VM operations
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.UInt16] $BootDelay,

        ## Secure boot status. Could be a SwitchParameter but boolean is more explicit?
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Boolean] $SecureBoot,

        ## Custom bootstrap order
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('ConfigurationFirst','ConfigurationOnly','Disabled','MediaFirst','MediaOnly')]
        [System.String] $CustomBootstrapOrder = 'MediaFirst',

        ## Enable Guest Integration Services
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Boolean] $GuestIntegrationServices
    )
    process {

        Write-Warning -Message ($localized.DeprecatedCommandWarning -f 'Set-LabVMDefaults','Set-LabVMDefault');
        Set-LabVMDefault @PSBoundParameters;

    }

}

