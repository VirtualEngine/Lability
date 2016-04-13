function Reset-LabVMDefault {
<#
    .SYNOPSIS
        Reset the current lab virtual machine default settings back to defaults.
#>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param ( )
    process {
        RemoveConfigurationData -Configuration VM;
        Get-LabVMDefault;
    }
} #end function Reset-LabVMDefault
New-Alias -Name Reset-LabVMDefaults -Value Reset-LabVMDefault

function Get-LabVMDefault {
<#
    .SYNOPSIS
        Gets the current lab virtual machine default settings.
#>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param ( )
    process {
        $vmDefaults = GetConfigurationData -Configuration VM;

        ## BootOrder property should not be exposed via the Get-LabVMDefault/Set-LabVMDefault
        $vmDefaults.PSObject.Properties.Remove('BootOrder');
        return $vmDefaults;
    }
} #end function Get-LabVMDefault
New-Alias -Name Get-LabVMDefaults -Value Get-LabVMDefault

function Set-LabVMDefault {
<#
    .SYNOPSIS
        Sets the lab virtual machine default settings.
#>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        ## Default virtual machine startup memory (bytes).
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateRange(536870912, 1099511627776)]
        [System.Int64] $StartupMemory,

        ## Default virtual machine miniumum dynamic memory allocation (bytes).
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateRange(536870912, 1099511627776)]
        [System.Int64] $MinimumMemory,

        ## Default virtual machine maximum dynamic memory allocation (bytes).
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateRange(536870912, 1099511627776)]
        [System.Int64] $MaximumMemory,

        ## Default virtual machine processor count.
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateRange(1, 4)]
        [System.Int32] $ProcessorCount,

        ## Default virtual machine media Id.
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Media,

        ## Lab host internal switch name.
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $SwitchName,

        # Input Locale
        [Parameter(ValueFromPipelineByPropertyName)] [ValidatePattern('^([a-z]{2,2}-[a-z]{2,2})|(\d{4,4}:\d{8,8})$')]
        [System.String] $InputLocale,

        # System Locale
        [Parameter(ValueFromPipelineByPropertyName)] [ValidatePattern('^[a-z]{2,2}-[a-z]{2,2}$')]
        [System.String] $SystemLocale,

        # User Locale
        [Parameter(ValueFromPipelineByPropertyName)] [ValidatePattern('^[a-z]{2,2}-[a-z]{2,2}$')]
        [System.String] $UserLocale,

        # UI Language
        [Parameter(ValueFromPipelineByPropertyName)] [ValidatePattern('^[a-z]{2,2}-[a-z]{2,2}$')]
        [System.String] $UILanguage,

        # Timezone
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Timezone,

        # Registered Owner
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $RegisteredOwner,

        # Registered Organization
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] [Alias('RegisteredOrganisation')] $RegisteredOrganization,

        ## Client PFX certificate bundle used to encrypt DSC credentials
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNull()]
        [System.String] $ClientCertificatePath,

        ## Client certificate's issuing Root Certificate Authority (CA) certificate
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNull()]
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
        $vmDefaults = GetConfigurationData -Configuration VM;

        if ($PSBoundParameters.ContainsKey('StartupMemory')) {
            $vmDefaults.StartupMemory = $StartupMemory;
        }
        if ($PSBoundParameters.ContainsKey('MinimumMemory')) {
            $vmDefaults.MinimumMemory = $MinimumMemory;
        }
        if ($PSBoundParameters.ContainsKey('MaximumMemory')) {
            $vmDefaults.MaximumMemory = $MaximumMemory;
        }
        if ($PSBoundParameters.ContainsKey('ProcessorCount')) {
            $vmDefaults.ProcessorCount = $ProcessorCount;
        }
        if ($PSBoundParameters.ContainsKey('Media')) {
            ## ResolveLabMedia will throw if media cannot be resolved
            $labMedia = ResolveLabMedia -Id $Media;
            $vmDefaults.Media = $labMedia.Id;
        }
        if ($PSBoundParameters.ContainsKey('SwitchName')) {
            $vmDefaults.SwitchName = $SwitchName;
        }
        if ($PSBoundParameters.ContainsKey('Timezone')) {
            $vmDefaults.Timezone = ValidateTimeZone -TimeZone $Timezone;
        }
        if ($PSBoundParameters.ContainsKey('UILanguage')) {
            $vmDefaults.UILanguage = $UILanguage;
        }
        if ($PSBoundParameters.ContainsKey('InputLocale')) {
            $vmDefaults.InputLocale = $InputLocale;
        }
        if ($PSBoundParameters.ContainsKey('SystemLocale')) {
            $vmDefaults.SystemLocale = $SystemLocale;
        }
        if ($PSBoundParameters.ContainsKey('UserLocale')) {
            $vmDefaults.UserLocale = $UserLocale;
        }
        if ($PSBoundParameters.ContainsKey('RegisteredOwner')) {
            $vmDefaults.RegisteredOwner = $RegisteredOwner;
        }
        if ($PSBoundParameters.ContainsKey('RegisteredOrganization')) {
            $vmDefaults.RegisteredOrganization = $RegisteredOrganization;
        }
        if ($PSBoundParameters.ContainsKey('ClientCertificatePath')) {
            if (-not [System.String]::IsNullOrWhitespace($ClientCertificatePath)) {
                $ClientCertificatePath = [System.Environment]::ExpandEnvironmentVariables($ClientCertificatePath);
                if (-not (Test-Path -Path $ClientCertificatePath -Type Leaf)) {
                    throw ($localized.CannotFindCertificateError -f 'Client', $ClientCertificatePath);
                }
            }
            $vmDefaults.ClientCertificatePath = $ClientCertificatePath;
        }
        if ($PSBoundParameters.ContainsKey('RootCertificatePath')) {
            if (-not [System.String]::IsNullOrWhitespace($RootCertificatePath)) {
                $RootCertificatePath = [System.Environment]::ExpandEnvironmentVariables($RootCertificatePath);
                if (-not (Test-Path -Path $RootCertificatePath -Type Leaf)) {
                    throw ($localized.CannotFindCertificateError -f 'Root', $RootCertificatePath);
                }
            }
            $vmDefaults.RootCertificatePath = $RootCertificatePath;
        }
        if ($PSBoundParameters.ContainsKey('BootDelay')) {
            $vmDefaults.BootDelay = $BootDelay;
        }
        if ($PSBoundParameters.ContainsKey('CustomBootstrapOrder')) {
            $vmDefaults.CustomBootstrapOrder = $CustomBootstrapOrder;
        }
        if ($PSBoundParameters.ContainsKey('SecureBoot')) {
            $vmDefaults.SecureBoot = $SecureBoot;
        }
        if ($PSBoundParameters.ContainsKey('GuestIntegrationServices')) {
            $vmDefaults.GuestIntegrationServices = $GuestIntegrationServices;
        }

        if ($vmDefaults.StartupMemory -lt $vmDefaults.MinimumMemory) {
            throw ($localized.StartMemLessThanMinMemError -f $vmDefaults.StartupMemory, $vmDefaults.MinimumMemory);
        }
        elseif ($vmDefaults.StartupMemory -gt $vmDefaults.MaximumMemory) {
            throw ($localized.StartMemGreaterThanMaxMemError -f $vmDefaults.StartupMemory, $vmDefaults.MaximumMemory);
        }

        $shouldProcessMessage = $localized.PerformingOperationOnTarget -f 'Set-LabVMDefault', $vmName;
        $verboseProcessMessage = $localized.SettingVMDefaults;
        if ($PSCmdlet.ShouldProcess($verboseProcessMessage, $shouldProcessMessage, $localized.ShouldProcessWarning)) {
            SetConfigurationData -Configuration VM -InputObject $vmDefaults;
        }

        ## BootOrder property should not be exposed via the Get-LabVMDefault/Set-LabVMDefault
        $vmDefaults.PSObject.Properties.Remove('BootOrder');
        return $vmDefaults;
    }
} #end function Set-LabVMDefault
New-Alias -Name Set-LabVMDefaults -Value Set-LabVMDefault

function ValidateTimeZone {
<#
    .SYNOPSIS
        Validates a timezone string.
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $TimeZone
    )
    process {
        try {
            $TZ = [TimeZoneInfo]::FindSystemTimeZoneById($TimeZone)
            return $TZ.StandardName;
        }
        catch [System.TimeZoneNotFoundException] {
            throw $_;
        }
    } #end process
} #end function ValidateTimeZone
