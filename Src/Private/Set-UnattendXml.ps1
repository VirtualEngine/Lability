function Set-UnattendXml {
    <#
        .SYNOPSIS
           Creates a Windows unattended installation file and saves to disk.
    #>
        [CmdletBinding()]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
        [OutputType([System.Xml.XmlDocument])]
        param (
            # Filename/path to save the unattend file as
            [Parameter(Mandatory, ValueFromPipeline)]
            [System.String] $Path,

            # Local Administrator Password
            [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
            [System.Management.Automation.PSCredential]
            [System.Management.Automation.CredentialAttribute()]
            $Credential,

            # Computer name
            [Parameter(ValueFromPipelineByPropertyName)]
            [System.String] $ComputerName,

            # Product Key
            [Parameter(ValueFromPipelineByPropertyName)]
            [ValidatePattern('^[A-Z0-9]{5,5}-[A-Z0-9]{5,5}-[A-Z0-9]{5,5}-[A-Z0-9]{5,5}-[A-Z0-9]{5,5}$')]
            [System.String] $ProductKey,

            # Input Locale
            [Parameter(ValueFromPipelineByPropertyName)]
            [System.String] $InputLocale = 'en-US',

            # System Locale
            [Parameter(ValueFromPipelineByPropertyName)]
            [System.String] $SystemLocale = 'en-US',

            # User Locale
            [Parameter(ValueFromPipelineByPropertyName)]
            [System.String] $UserLocale = 'en-US',

            # UI Language
            [Parameter(ValueFromPipelineByPropertyName)]
            [System.String] $UILanguage = 'en-US',

            # Timezone
            [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
            [System.String] $Timezone, ##TODO: Validate timezones?

            # Registered Owner
            [Parameter(ValueFromPipelineByPropertyName)]
            [ValidateNotNull()]
            [System.String] $RegisteredOwner = 'Virtual Engine',

            # Registered Organization
            [Parameter(ValueFromPipelineByPropertyName)]
            [ValidateNotNull()]
            [System.String] $RegisteredOrganization = 'Virtual Engine',

            # TODO: Execute synchronous commands during OOBE pass as they only currently run during the Specialize pass
            ## Array of hashtables with Description, Order and Path keys
            [Parameter(ValueFromPipelineByPropertyName)]
            [System.Collections.Hashtable[]] $ExecuteCommand
        )
        process {

            [ref] $null = $PSBoundParameters.Remove('Path');
            $unattendXml = New-UnattendXml @PSBoundParameters;
            ## Ensure the parent Sysprep directory exists (#232)
            [ref] $null = New-Directory -Path (Split-Path -Path $Path -Parent);
            $resolvedPath = Resolve-PathEx -Path $Path;
            return $unattendXml.Save($resolvedPath);

        } #end process
    } #end function
