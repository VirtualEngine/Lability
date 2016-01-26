function Test-LabNodeConfiguration {
<#
    .SYNOPSIS
        Test a node's configuration for manual deployment.
#>
    [CmdletBinding(DefaultParameterSetName = 'All')]
    [OutputType([System.Boolean])]    
    param (
        ## Lab DSC configuration data
        [Parameter(Mandatory, ValueFromPipeline)]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [System.Object] $ConfigurationData,
        
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [System.String] $NodeName,
        
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath,
        
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SkipDscCheck')]
        [System.Management.Automation.SwitchParameter] $SkipDscCheck,
        
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SkipResourceCheck')]
        [System.Management.Automation.SwitchParameter] $SkipResourceCheck
    )
    process {
        $node = ResolveLabVMProperties -NodeName $NodeName -ConfigurationData $ConfigurationData -ErrorAction Stop;
        if ((-not $node) -or ($node.NodeName -eq '*') -or ([System.String]::IsNullOrEmpty($node.NodeName))) {
            throw ($localized.CannotLocateNodeError -f $NodeName);
        }
        if (-not $PSBoundParameters.ContainsKey('DestinationPath')) {
            $DestinationPath = '{0}\{1}' -f $env:SystemDrive, (GetConfigurationData -Configuration Host).ResourceShareName;
        }
        
        $inDesiredState = $true;
        
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
                $testLabLocalResourceParams = @{
                    ConfigurationData = $ConfigurationData;
                    ResourceId = $resourceId;
                    LocalResourcePath = $DestinationPath;
                }
                $isAvailableLocally = TestLabLocalResource @testLabLocalResourceParams;
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

function InstallNodeCertificates {
<#
    .SYNOPSIS
        Installs lab node certificates
    .NOTES
        Enables easier unit testing!
#>
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $RootCertificatePath,
        
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $ClientCertificatePath
    )
    process {
        ## Import certificates
        $resolvedRootCertificatePath = ResolvePathEx -Path $RootCertificatePath;
        WriteVerbose -Message ($localized.AddingCertificate -f 'Root', $resolvedRootCertificatePath);
        certutil.exe -addstore -f "Root" $resolvedRootCertificatePath | WriteVerbose;
        ## Import the .PFX certificate with a blank password
        $resolvedClientCertificatePath = ResolvePathEx -Path $ClientCertificatePath;
        WriteVerbose -Message ($localized.AddingCertificate -f 'Client', $resolvedClientCertificatePath);
        "" | certutil.exe -f -importpfx $resolvedClientCertificatePath | WriteVerbose;
    } #end process
} #end function InstallCertificates

function Invoke-LabNodeConfiguration {
<#
    .SYNOPSIS
        Configures a node for manual deployment.
#>
    [CmdletBinding()]
    param (
        ## Lab DSC configuration data
        [Parameter(Mandatory, ValueFromPipeline)]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        [System.Collections.Hashtable] $ConfigurationData,
        
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [System.String] $NodeName,
        
        ## File share/folder pointing to downloaded resources
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Path')] [System.String] $ResourcePath,
        
        ## Node's local target resource folder
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force
    )
    process {
        $node = ResolveLabVMProperties -NodeName $NodeName -ConfigurationData $ConfigurationData -ErrorAction Stop;
        if ((-not $node) -or ($node.NodeName -eq '*') -or ([System.String]::IsNullOrEmpty($node.NodeName))) {
            throw ($localized.CannotLocateNodeError -f $NodeName);
        }
        if (-not $PSBoundParameters.ContainsKey('DestinationPath')) {
            $DestinationPath = '{0}\{1}' -f $env:SystemDrive, (GetConfigurationData -Configuration Host).ResourceShareName;
        }
        
        ## Install lab root CA and client certificate
        InstallNodeCertificates -RootCertificatePath $node.RootCertificatePath -ClientCertificatePath $node.ClientCertificatePath;

        # Test DSC modules
        if ($ConfigurationData.NonNodeData.($labDefaults.ModuleName).DSCResource) {
            foreach ($module in $ConfigurationData.NonNodeData.($labDefaults.ModuleName).DSCResource) {
                if ((-not $module.MinimimVerions) -and (-not $module.RequiredVersion)) {
                    $module['MinimumVersion'] = '0.0';
                }
                if (-not (TestModule @module) -or $Force) {
                    InvokeDscResourceDownload -DSCResource $module -Force;
                }
            } #end foreach module
        }
        
        ## Test local resources
        if ($node.Resource) {
            foreach ($resourceId in $node.Resource) {
                ## Check resource is available locally
                WriteVerbose -Message ($localized.TestingNodeResource -f $resourceId);
                $testLabLocalResourceParams = @{
                    ConfigurationData = $ConfigurationData;
                    ResourceId = $resourceId;
                    LocalResourcePath = $DestinationPath;
                }
                $isAvailableLocally = TestLabLocalResource @testLabLocalResourceParams;
                if (-not $isAvailableLocally -or $Force) {
                    $expandLabResourceParams = @{
                        ConfigurationData = $ConfigurationData;
                        Name = $node.NodeName;
                        DestinationPath = $DestinationPath;
                        ResourcePath = $ResourcePath;
                    }
                    ExpandLabResource @expandLabResourceParams;
                }
            } #end foreach resource
        }
    } #end process
} #end function Invoke-LabNodeConfiguration
