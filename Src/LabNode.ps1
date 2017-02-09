<# DEPRECATED
function TestLabNodeCertificate {
#
    .SYNOPSIS
        Tests whether the certificate is installed.
#
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $CertificatePath,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateSet('My','Root')]
        [System.String] $Store
    )
    process {

        $CertificatePath = ResolvePathEx -Path $CertificatePath;
        if (-not (Test-Path -Path $CertificatePath)) {
            return $false;
        }

        $certificate = [System.Security.Cryptography.X509Certificates.X509Certificate]::CreateFromCertFile($CertificatePath);

        $localCertificate = Get-ChildItem -Path "Cert:\LocalMachine\$Store" |
            Where-Object { $_.Subject -eq $certificate.Subject }

        return ($null -ne $localCertificate);

    } #end process
} #end function TestLabNodeCertificate
#>

<# DEPRECATED
function InstallLabNodeCertificates {
#
    .SYNOPSIS
        Installs lab node certificates
    .NOTES
        Enables easier unit testing!
#
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $RootCertificatePath,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $ClientCertificatePath,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force
    )
    process {

        ## Import certificates
        $resolvedRootCertificatePath = ResolvePathEx -Path $RootCertificatePath;
        if ($Force -or (-not (TestLabNodeCertificate -CertificatePath $resolvedRootCertificatePath -Store 'Root'))) {
            WriteVerbose -Message ($localized.AddingCertificate -f 'Root', $resolvedRootCertificatePath);
            certutil.exe -addstore -f "Root" $resolvedRootCertificatePath | WriteVerbose;
        }

        ## Import the .PFX certificate with a blank password
        $resolvedClientCertificatePath = ResolvePathEx -Path $ClientCertificatePath;
        if ($Force -or (-not (TestLabNodeCertificate -CertificatePath $resolvedClientCertificatePath -Store 'My'))) {
            WriteVerbose -Message ($localized.AddingCertificate -f 'Client', $resolvedClientCertificatePath);
            "" | certutil.exe -f -importpfx $resolvedClientCertificatePath | WriteVerbose;
        }

    } #end process
} #end function InstallLabNodeCertificates
#>

<# DEPRECATED
function Test-LabNodeConfiguration {
#
    .SYNOPSIS
        Test a node's configuration for manual deployment.
    .DESCRIPTION
        The Test-LabNodeConfiguration determines whether the local node has all the required defined prerequisites
        available locally. When invoked, defined custom resources, certificates and DSC resources are checked.

        WARNING: Only metadata defined in the Powershell DSC configuration document can be tested!
    .PARAMETER ConfigurationData
        Specifies a PowerShell DSC configuration data hashtable or a path to an existing PowerShell DSC .psd1
        configuration document used to create the virtual machines. Each node defined in the AllNodes array is
        tested.
    .PARAMETER NodeName
        Specifies the node name in the PowerShell DSC configuration document to check. If not specified, the
        local hostname is used.
    .PARAMETER DestinationPath
        Specifies the local directory path that resources are expected to be located in. If not specified, it
        defaults to the default ResourceShareName in the root of the system drive, i.e. C:\Resources.
    .PARAMETER SkipDscCheck
        Specifies that checking of the local DSC resource availability is skipped.
    .PARAMETER SkipResourceCheck
        Specifies that checking of the local custom resource availability is skipped.
    .PARAMETER SkipCertificateCheck
        Specifies that checking of the local certificates is skipped.
    .LINK
        Invoke-LabNodeConfiguration
#
    [CmdletBinding(DefaultParameterSetName = 'All')]
    [OutputType([System.Boolean])]
    param (
        ## Lab DSC configuration data
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $NodeName = ([System.Net.Dns]::GetHostName()),

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SkipDscCheck')]
        [System.Management.Automation.SwitchParameter] $SkipDscCheck,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SkipResourceCheck')]
        [System.Management.Automation.SwitchParameter] $SkipResourceCheck,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SkipResourceCheck')]
        [System.Management.Automation.SwitchParameter] $SkipCertificateCheck
    )
    process {

        $node = Resolve-NodePropertyValue -NodeName $NodeName -ConfigurationData $ConfigurationData -ErrorAction Stop;
        if ((-not $node) -or ($node.NodeName -eq '*') -or ([System.String]::IsNullOrEmpty($node.NodeName))) {
            throw ($localized.CannotLocateNodeError -f $NodeName);
        }
        if (-not $PSBoundParameters.ContainsKey('DestinationPath')) {
            $DestinationPath = '{0}\{1}' -f $env:SystemDrive, (GetConfigurationData -Configuration Host).ResourceShareName;
        }

        $inDesiredState = $true;

        if (-not $SkipCertificateCheck) {
            ## Test node certificates
            $clientCertificatePath = ResolvePathEx -Path $node.ClientCertificatePath;
            WriteVerbose -Message ($localized.TestingNodeCertificate -f $clientCertificatePath);
            if (-not (TestLabNodeCertificate -CertificatePath $clientCertificatePath -Store 'My')) {
                WriteWarning -Message ($localized.MissingRequiredCertWarning -f $clientCertificatePath);
                $inDesiredState = $false;
            }
            $rootCertificatePath = ResolvePathEx -Path $node.RootCertificatePath;
            WriteVerbose -Message ($localized.TestingNodeCertificate -f $rootCertificatePath);
            if (-not (TestLabNodeCertificate -CertificatePath $rootCertificatePath -Store 'Root')) {
                WriteWarning -Message ($localized.MissingRequiredCertWarning -f $rootCertificatePath);
                $inDesiredState = $false;
            }
        } #end if not skip certificates

        # Test DSC modules
        if (-not $SkipDscCheck -and $ConfigurationData.NonNodeData.($labDefaults.ModuleName).DSCResource) {
            foreach ($module in $ConfigurationData.NonNodeData.($labDefaults.ModuleName).DSCResource) {
                WriteVerbose -Message ($localized.TestingNodeDscModule -f $module.Name);
                if ((-not $module.MinimimVerions) -and (-not $module.RequiredVersion)) {
                    $module['MinimumVersion'] = '0.0';
                }
                if (-not (TestModule @module)) {
                    WriteWarning -Message ($localized.MissingRequiredModuleWarning -f $module.Name);
                    $inDesiredState = $false;
                }
            } #end foreach module
        }

        ### Test resource master availability
        if (-not $SkipResourceCheck -and $node.Resource) {
            foreach ($resourceId in $node.Resource) {
                ## Check resource is available locally
                WriteVerbose -Message ($localized.TestingNodeResource -f $resourceId);
                $testLabResourceIsLocalParams = @{
                    ConfigurationData = $ConfigurationData;
                    ResourceId = $resourceId;
                    LocalResourcePath = $DestinationPath;
                }
                $isAvailableLocally = TestLabResourceIsLocal @testLabResourceIsLocalParams;
                if (-not $isAvailableLocally) {
                    $resourceFilename = Join-Path -Path $DestinationPath -ChildPath $resourceId;
                    WriteWarning -Message ($localized.MissingRequiredResourceWarning -f $resourceFilename);
                    $inDesiredState = $false;
                }
            } #end foreach resource
        }

        return $inDesiredState;

    } #end process
} #end function Test-LabNodeConfiguration
#>

<# DEPRECATED
function Invoke-LabNodeConfiguration {
#
    .SYNOPSIS
        Configures a node for manual lab deployment.
    .DESCRIPTION
        The Invoke-LabNodeConfiguration installs the client certificates, downloads all required DSC
        resources and checks whether all resources are present locally. This is convenient when using
        alternative hypervisors that cannot be auto-provisioned by Lability. Examples include virtual
        machines deployed on VMware Workstation or AmazonW Web Services.

        NOTE: The Invoke-LabConfiguration will not download custom resources but will test for their presence.

        WARNING: Only metadata defined in the Powershell DSC configuration document can be tested!
    .PARAMETER ConfigurationData
        Specifies a PowerShell DSC configuration data hashtable or a path to an existing PowerShell DSC .psd1
        configuration document used to create the virtual machines. Each node defined in the AllNodes array is
        tested.
    .PARAMETER NodeName
        Specifies the node name in the PowerShell DSC configuration document to check. If not specified, the
        local hostname is used.
    .PARAMETER DestinationPath
        Specifies the local directory path that resources are expected to be located in. If not specified, it
        defaults to the default ResourceShareName in the root of the system drive, i.e. C:\Resources.
    .PARAMETER Force
        Specifies that DSC resources should be re-downloaded, overwriting existing versions.
    .NOTES
        Deprecated functionality. This will move into the LabilityBootstrap module.
    .LINK
        Test-LabNodeConfiguration
#
    [CmdletBinding()]
    param (
        ## Lab DSC configuration data
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $NodeName = ([System.Net.Dns]::GetHostName()),

        ## Node's local target resource folder
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force
    )
    process {

        $node = Resolve-NodePropertyValue -NodeName $NodeName -ConfigurationData $ConfigurationData -ErrorAction Stop;
        if ((-not $node) -or ($node.NodeName -eq '*') -or ([System.String]::IsNullOrEmpty($node.NodeName))) {
            throw ($localized.CannotLocateNodeError -f $NodeName);
        }
        if (-not $PSBoundParameters.ContainsKey('DestinationPath')) {
            $DestinationPath = '{0}\{1}' -f $env:SystemDrive, (GetConfigurationData -Configuration Host).ResourceShareName;
        }

        ## Install lab root CA and client certificate
        $installLabNodeCertificatesParams = @{
            RootCertificatePath = $node.RootCertificatePath;
            ClientCertificatePath = $node.ClientCertificatePath;
            Force = $Force;
        }
        InstallLabNodeCertificates @installLabNodeCertificatesParams;

        # Test DSC modules
        if ($ConfigurationData.NonNodeData.($labDefaults.ModuleName).DSCResource) {
            foreach ($module in $ConfigurationData.NonNodeData.($labDefaults.ModuleName).DSCResource) {
                if ((-not $module.MinimimVerions) -and (-not $module.RequiredVersion)) {
                    $module['MinimumVersion'] = '0.0';
                }
                if (-not (TestModule @module) -or $Force) {
                    #InvokeModuleCacheDownload
                    #ExpandModuleCache
                    # InvokeDscResourceDownload -DSCResource $module -Force;
                }
            } #end foreach module
        }

        ## Call Test-LabNodeConfiguration to display any remaining warnings
        [ref] $null = Test-LabNodeConfiguration -ConfigurationData $ConfigurationData -DestinationPath $DestinationPath -NodeName $NodeName -SkipDscCheck;

    } #end process
} #end function Invoke-LabNodeConfiguration
#>

<# DEPRECATED
function Get-LabNodeResourceList {
#
    .SYNOPSIS
        Generates a list of required resources for each node.
    .DESCRIPTION
        Outputs a hashtable of each selected node containing all required custom resources. This is handy to create
        a list of resources when manually configuring nodes is required, e.g. locally on VMware Workstation or in
        Microsoft Azure etc.
#
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Name
    )
    process {

        $requiredResources = @{ };
        if (-not $PSBoundParameters.ContainsKey('Name')) {
            $Name = $ConfigurationData.AllNodes |
                Where-Object { $_.NodeName -ne '*' } |
                    ForEach-Object { $_.NodeName }
        }

        foreach ($nodeName in $Name) {

            $node = Resolve-NodePropertyValue -NodeName $nodeName -ConfigurationData $ConfigurationData -NoEnumerateWildcardNode -ErrorAction Stop;
            if ([System.String]::IsNullOrEmpty($node.NodeName)) {
                throw ($localized.CannotLocateNodeError -f $nodeName);
            }

            $requiredResources[$node.NodeName] = @();
            foreach ($resourceId in $node.Resource) {

                $resource = [PSCustomObject] (ResolveLabResource -ConfigurationData $ConfigurationData -ResourceId $resourceId);
                if ($resource) {
                    if (-not $resource.DestinationPath) {
                        $resourcePath = '\Resources\{0}' -f $resource.Filename;
                    }

                    if (($resource.Expand -eq $true) -and ($resource.DestinationPath)) {
                        # if expand and destinationpath = extract into destinationpath
                        $resourcePath = $resource.DestinationPath;
                    }
                    elseif ($resource.Expand -eq $true) {
                        # elseif expand = extract into resources\resourceid
                        $resourcePath = '\Resources\{0}' -f $resource.Id;
                    }
                    elseif ($resource.DestinationPath) {
                        # elseif not expand and destinationpath = download/copy into destinationpath
                        $resourcePath = '{0}\{1}' -f $resource.DestinationPath, $resource.Filename;
                    }
                    else {
                        # else download/copy into resource\resourcefilename
                        $resourcePath = '\Resources\{0}' -f $resource.Filename;
                    }
                    [ref] $null = Add-Member -InputObject $resource -MemberType NoteProperty -Name ResourcePath -Value $resourcePath;

                    $requiredResources[$node.NodeName] += $resource;
                }
                else {
                    WriteWarning -Message ($localized.ResourceNotFound -f $resourceId);
                }

            } #end foreach resource id

        } #end foreach node

        Write-Output -InputObject $requiredResources;

    } #end process
} #end function Get-LabNodeResource
#>


<# DEPRECATED
function Show-LabNodeResourceList {
#
    .SYNOPSIS
        Generates a display-friendly list of required custom resources for each node.
    .DESCRIPTION
        Outputs string of each selected node containing all required custom resources. This is handy to create a
        list of resources when manually configuring nodes is required, e.g. locally on VMware Workstation or in
        Microsoft Azure etc.
#
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Name
    )
    process {

        $requiredResources = Get-LabNodeResourceList @PSBoundParameters;
        $stringBuilder = New-Object -TypeName System.Text.StringBuilder;
        $now = Get-Date;
        [ref] $null = $stringBuilder.AppendFormat('Resource checklist generated {0} {1}.', $now.ToShortDateString(), $now.ToShortTimeString());
        [ref] $null = $stringBuilder.AppendLine().AppendLine();

        foreach ($node in $requiredResources.Keys) {

            [ref] $null = $stringBuilder.AppendFormat('{0}', $node.ToUpper()).AppendLine();
            [ref] $null = $stringBuilder.AppendFormat('{0}', ('=' * $node.Length)).AppendLine();

            $requiredResources[$node] | Sort-Object ResourcePath | ForEach-Object {
                $resource = $PSItem;
                [ref] $null = $stringBuilder.AppendLine();
                [ref] $null = $stringBuilder.AppendFormat(' {0}', $resource.Id).AppendLine();
                [ref] $null = $stringBuilder.AppendFormat(' {0}', ('-' * $resource.Id.Length)).AppendLine();
                [ref] $null = $stringBuilder.AppendFormat('  Download: {0}', $resource.Uri).AppendLine();
                if ($resource.Expand -eq $true) {
                    [ref] $null = $stringBuilder.AppendFormat('  Extract/expand into: {0}', $resource.ResourcePath).AppendLine();
                }
                else {
                    [ref] $null = $stringBuilder.AppendFormat('  Save as: {0}', $resource.ResourcePath).AppendLine();
                }
                if ($resource.Checksum) {
                    [ref] $null = $stringBuilder.AppendFormat('  MD5 Checksum: {0}', $resource.Checksum).AppendLine();
                }
            }
            [ref] $null = $stringBuilder.AppendLine();
        }

        Write-Output $stringBuilder.ToString();

    } #end process
} #end function Show-LabNodeResourceList
#>
