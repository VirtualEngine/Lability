<#
    .SYNOPSIS
        Tests if the current machine is a Nano server.
#>
function Test-IsNanoServer
{
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param ()

    $isNanoServer = $false

    if (Test-CommandExists -Name 'Get-ComputerInfo')
    {
        $computerInfo = Get-ComputerInfo

        $computerIsServer = 'Server' -ieq $computerInfo.OsProductType

        if ($computerIsServer)
        {
            $isNanoServer = 'NanoServer' -ieq $computerInfo.OsServerLevel
        }
    }

    return $isNanoServer
}

<#
    .SYNOPSIS
        Tests whether or not the command with the specified name exists.
    .PARAMETER Name
        The name of the command to test for.
#>
function Test-CommandExists
{
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name
    )

    $command = Get-Command -Name $Name -ErrorAction 'SilentlyContinue'
    return ($null -ne $command)
}

<#
    .SYNOPSIS
        This method is used to compare current and desired values for any DSC resource.

    .PARAMETER CurrentValues
        This is hash table of the current values that are applied to the resource.

    .PARAMETER DesiredValues
        This is a PSBoundParametersDictionary of the desired values for the resource.

    .PARAMETER ValuesToCheck
        This is a list of which properties in the desired values list should be checked.
        If this is empty then all values in DesiredValues are checked.
#>
function Test-DscParameterState
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $CurrentValues,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $DesiredValues,

        [Parameter()]
        [System.Array]
        $ValuesToCheck
    )

    $returnValue = $true

    if (($DesiredValues.GetType().Name -ne 'HashTable') `
        -and ($DesiredValues.GetType().Name -ne 'CimInstance') `
        -and ($DesiredValues.GetType().Name -ne 'PSBoundParametersDictionary'))
    {
        $errorMessage = $script:localizedData.PropertyTypeInvalidForDesiredValues -f $($DesiredValues.GetType().Name)
        New-InvalidArgumentException -ArgumentName 'DesiredValues' -Message $errorMessage
    }

    if (($DesiredValues.GetType().Name -eq 'CimInstance') -and ($null -eq $ValuesToCheck))
    {
        $errorMessage = $script:localizedData.PropertyTypeInvalidForValuesToCheck
        New-InvalidArgumentException -ArgumentName 'ValuesToCheck' -Message $errorMessage
    }

    if (($null -eq $ValuesToCheck) -or ($ValuesToCheck.Count -lt 1))
    {
        $keyList = $DesiredValues.Keys
    }
    else
    {
        $keyList = $ValuesToCheck
    }

    $keyList | ForEach-Object -Process {
        if (($_ -ne 'Verbose'))
        {
            if (($CurrentValues.ContainsKey($_) -eq $false) `
            -or ($CurrentValues.$_ -ne $DesiredValues.$_) `
            -or (($DesiredValues.GetType().Name -ne 'CimInstance' -and $DesiredValues.ContainsKey($_) -eq $true) -and ($null -ne $DesiredValues.$_ -and $DesiredValues.$_.GetType().IsArray)))
            {
                if ($DesiredValues.GetType().Name -eq 'HashTable' -or `
                    $DesiredValues.GetType().Name -eq 'PSBoundParametersDictionary')
                {
                    $checkDesiredValue = $DesiredValues.ContainsKey($_)
                }
                else
                {
                    # If DesiredValue is a CimInstance.
                    $checkDesiredValue = $false
                    if (([System.Boolean]($DesiredValues.PSObject.Properties.Name -contains $_)) -eq $true)
                    {
                        if ($null -ne $DesiredValues.$_)
                        {
                            $checkDesiredValue = $true
                        }
                    }
                }

                if ($checkDesiredValue)
                {
                    $desiredType = $DesiredValues.$_.GetType()
                    $fieldName = $_
                    if ($desiredType.IsArray -eq $true)
                    {
                        if (($CurrentValues.ContainsKey($fieldName) -eq $false) `
                        -or ($null -eq $CurrentValues.$fieldName))
                        {
                            Write-Verbose -Message ($script:localizedData.PropertyValidationError -f $fieldName) -Verbose

                            $returnValue = $false
                        }
                        else
                        {
                            $arrayCompare = Compare-Object -ReferenceObject $CurrentValues.$fieldName `
                                                           -DifferenceObject $DesiredValues.$fieldName
                            if ($null -ne $arrayCompare)
                            {
                                Write-Verbose -Message ($script:localizedData.PropertiesDoesNotMatch -f $fieldName) -Verbose

                                $arrayCompare | ForEach-Object -Process {
                                    Write-Verbose -Message ($script:localizedData.PropertyThatDoesNotMatch -f $_.InputObject, $_.SideIndicator) -Verbose
                                }

                                $returnValue = $false
                            }
                        }
                    }
                    else
                    {
                        switch ($desiredType.Name)
                        {
                            'String'
                            {
                                if (-not [System.String]::IsNullOrEmpty($CurrentValues.$fieldName) -or `
                                    -not [System.String]::IsNullOrEmpty($DesiredValues.$fieldName))
                                {
                                    Write-Verbose -Message ($script:localizedData.ValueOfTypeDoesNotMatch `
                                        -f $desiredType.Name, $fieldName, $($CurrentValues.$fieldName), $($DesiredValues.$fieldName)) -Verbose

                                    $returnValue = $false
                                }
                            }

                            'Int32'
                            {
                                if (-not ($DesiredValues.$fieldName -eq 0) -or `
                                    -not ($null -eq $CurrentValues.$fieldName))
                                {
                                    Write-Verbose -Message ($script:localizedData.ValueOfTypeDoesNotMatch `
                                        -f $desiredType.Name, $fieldName, $($CurrentValues.$fieldName), $($DesiredValues.$fieldName)) -Verbose

                                    $returnValue = $false
                                }
                            }

                            { $_ -eq 'Int16' -or $_ -eq 'UInt16' -or $_ -eq 'Single' }
                            {
                                if (-not ($DesiredValues.$fieldName -eq 0) -or `
                                    -not ($null -eq $CurrentValues.$fieldName))
                                {
                                    Write-Verbose -Message ($script:localizedData.ValueOfTypeDoesNotMatch `
                                        -f $desiredType.Name, $fieldName, $($CurrentValues.$fieldName), $($DesiredValues.$fieldName)) -Verbose

                                    $returnValue = $false
                                }
                            }

                            'Boolean'
                            {
                                if ($CurrentValues.$fieldName -ne $DesiredValues.$fieldName)
                                {
                                    Write-Verbose -Message ($script:localizedData.ValueOfTypeDoesNotMatch `
                                        -f $desiredType.Name, $fieldName, $($CurrentValues.$fieldName), $($DesiredValues.$fieldName)) -Verbose

                                    $returnValue = $false
                                }
                            }

                            default
                            {
                                Write-Warning -Message ($script:localizedData.UnableToCompareProperty `
                                    -f $fieldName, $desiredType.Name)

                                $returnValue = $false
                            }
                        }
                    }
                }
            }
        }
    }

    return $returnValue
}

<#
    .SYNOPSIS
        Retrieves the localized string data based on the machine's culture.
        Falls back to en-US strings if the machine's culture is not supported.

    .PARAMETER ResourceName
        The name of the resource as it appears before '.strings.psd1' of the localized string file.
        For example:
            For WindowsOptionalFeature: MSFT_WindowsOptionalFeature
            For Service: MSFT_ServiceResource
            For Registry: MSFT_RegistryResource
            For Helper: SqlServerDscHelper

    .PARAMETER ScriptRoot
        Optional. The root path where to expect to find the culture folder. This is only needed
        for localization in helper modules. This should not normally be used for resources.

    .NOTES
        To be able to use localization in the helper function, this function must
        be first in the file, before Get-LocalizedData is used by itself to load
        localized data for this helper module (see directly after this function).
#>
function Get-LocalizedData
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ResourceName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ScriptRoot
    )

    if (-not $ScriptRoot)
    {
        $dscResourcesFolder = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'DSCResources'
        $resourceDirectory = Join-Path -Path $dscResourcesFolder -ChildPath $ResourceName
    }
    else
    {
        $resourceDirectory = $ScriptRoot
    }

    $localizedStringFileLocation = Join-Path -Path $resourceDirectory -ChildPath $PSUICulture

    if (-not (Test-Path -Path $localizedStringFileLocation))
    {
        # Fallback to en-US
        $localizedStringFileLocation = Join-Path -Path $resourceDirectory -ChildPath 'en-US'
    }

    Import-LocalizedData `
        -BindingVariable 'localizedData' `
        -FileName "$ResourceName.strings.psd1" `
        -BaseDirectory $localizedStringFileLocation

    return $localizedData
}

<#
    .SYNOPSIS
        Creates and throws an invalid argument exception.

    .PARAMETER Message
        The message explaining why this error is being thrown.

    .PARAMETER ArgumentName
        The name of the invalid argument that is causing this error to be thrown.
#>
function New-InvalidArgumentException
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Message,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ArgumentName
    )

    $argumentException = New-Object -TypeName 'ArgumentException' `
        -ArgumentList @($Message, $ArgumentName)

    $newObjectParameters = @{
        TypeName     = 'System.Management.Automation.ErrorRecord'
        ArgumentList = @($argumentException, $ArgumentName, 'InvalidArgument', $null)
    }

    $errorRecord = New-Object @newObjectParameters

    throw $errorRecord
}

<#
    .SYNOPSIS
        Creates and throws an invalid data exception.

    .PARAMETER ErrorId
        The error Id to assign to the exception.

    .PARAMETER ErrorMessage
        The error message to assign to the exception.
#>
function New-InvalidDataException
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ErrorId,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ErrorMessage
    )

    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidData
    $exception = New-Object `
        -TypeName System.InvalidOperationException `
        -ArgumentList $ErrorMessage
    $errorRecord = New-Object `
        -TypeName System.Management.Automation.ErrorRecord `
        -ArgumentList $exception, $ErrorId, $errorCategory, $null

    throw $errorRecord
}

<#
    .SYNOPSIS
        Creates and throws an invalid operation exception.

    .PARAMETER Message
        The message explaining why this error is being thrown.

    .PARAMETER ErrorRecord
        The error record containing the exception that is causing this terminating error.
#>
function New-InvalidOperationException
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Message,

        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.ErrorRecord]
        $ErrorRecord
    )

    if ($null -eq $ErrorRecord)
    {
        $invalidOperationException = New-Object -TypeName 'InvalidOperationException' `
            -ArgumentList @($Message)
    }
    else
    {
        $invalidOperationException = New-Object -TypeName 'InvalidOperationException' `
            -ArgumentList @($Message, $ErrorRecord.Exception)
    }

    $newObjectParameters = @{
        TypeName     = 'System.Management.Automation.ErrorRecord'
        ArgumentList = @(
            $invalidOperationException.ToString(),
            'MachineStateIncorrect',
            'InvalidOperation',
            $null
        )
    }

    $errorRecordToThrow = New-Object @newObjectParameters

    throw $errorRecordToThrow
}

<#
    .SYNOPSIS
        Creates and throws an object not found exception.

    .PARAMETER Message
        The message explaining why this error is being thrown.

    .PARAMETER ErrorRecord
        The error record containing the exception that is causing this terminating error.
#>
function New-ObjectNotFoundException
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Message,

        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.ErrorRecord]
        $ErrorRecord
    )

    if ($null -eq $ErrorRecord)
    {
        $exception = New-Object -TypeName 'System.Exception' `
            -ArgumentList @($Message)
    }
    else
    {
        $exception = New-Object -TypeName 'System.Exception' `
            -ArgumentList @($Message, $ErrorRecord.Exception)
    }

    $newObjectParameters = @{
        TypeName     = 'System.Management.Automation.ErrorRecord'
        ArgumentList = @(
            $exception.ToString(),
            'MachineStateIncorrect',
            'ObjectNotFound',
            $null
        )
    }

    $errorRecordToThrow = New-Object @newObjectParameters

    throw $errorRecordToThrow
}

<#
    .SYNOPSIS
        Creates and throws an invalid result exception.

    .PARAMETER Message
        The message explaining why this error is being thrown.

    .PARAMETER ErrorRecord
        The error record containing the exception that is causing this terminating error.
#>
function New-InvalidResultException
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Message,

        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.ErrorRecord]
        $ErrorRecord
    )

    if ($null -eq $ErrorRecord)
    {
        $exception = New-Object -TypeName 'System.Exception' `
            -ArgumentList @($Message)
    }
    else
    {
        $exception = New-Object -TypeName 'System.Exception' `
            -ArgumentList @($Message, $ErrorRecord.Exception)
    }

    $newObjectParameters = @{
        TypeName     = 'System.Management.Automation.ErrorRecord'
        ArgumentList = @(
            $exception.ToString(),
            'MachineStateIncorrect',
            'InvalidResult',
            $null
        )
    }

    $errorRecordToThrow = New-Object @newObjectParameters

    throw $errorRecordToThrow
}

function New-NotImplementedException
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Message,

        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.ErrorRecord]
        $ErrorRecord
    )

    if ($null -eq $ErrorRecord)
    {
        $invalidOperationException = New-Object -TypeName 'NotImplementedException' `
            -ArgumentList @($Message)
    }
    else
    {
        $invalidOperationException = New-Object -TypeName 'NotImplementedException' `
            -ArgumentList @($Message, $ErrorRecord.Exception)
    }

    $newObjectParameters = @{
        TypeName     = 'System.Management.Automation.ErrorRecord'
        ArgumentList = @(
            $invalidOperationException.ToString(),
            'MachineStateIncorrect',
            'NotImplemented',
            $null
        )
    }

    $errorRecordToThrow = New-Object @newObjectParameters

    throw $errorRecordToThrow
}

<#
    .SYNOPSIS
        Sets the Global DSCMachineStatus variable to a value of 1.
#>
function Set-DscMachineRebootRequired
{
    # Suppressing this rule because $global:DSCMachineStatus is used to trigger a reboot.
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    <#
        Suppressing this rule because $global:DSCMachineStatus is only set,
        never used (by design of Desired State Configuration).
    #>
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [CmdletBinding()]
    param
    (
    )

    $global:DSCMachineStatus = 1
}

<#
    .SYNOPSIS
        Builds a string of the common parameters shared across all resources in a set.

    .PARAMETER KeyParameterName
        The name of the key parameter for the resource.

    .PARAMETER Parameters
        The hashtable of all parameters to the resource set (PSBoundParameters).

    .EXAMPLE
        $parameters = @{
            KeyParameter = @( 'MyKeyParameter1', 'MyKeyParameter2' )
            CommonParameter1 = 'CommonValue1'
            CommonParameter2 = 2
        }

        New-ResourceSetCommonParameterString -KeyParameterName 'KeyParameter' -Parameters $parameters

        OUTPUT (as string):
        CommonParameter1 = "CommonValue1"`r`nCommonParameter2 = $CommonParameter2
#>
function New-ResourceSetCommonParameterString
{
    [OutputType([System.String])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $KeyParameterName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Hashtable]
        $Parameters
    )

    $stringBuilder = New-Object -TypeName 'System.Text.StringBuilder'

    foreach ($parameterName in $Parameters.Keys)
    {
        # All composite resources have an extra parameter 'InstanceName'
        if ($parameterName -ine $KeyParameterName -and $parameterName -ine 'InstanceName')
        {
            $parameterValue = $Parameters[$parameterName]

            if ($null -ne $parameterValue)
            {
                if ($parameterValue -is [System.String])
                {
                    $null = $stringBuilder.AppendFormat('{0} = "{1}"', $parameterName, $parameterValue)
                }
                else
                {
                    $null = $stringBuilder.Append($parameterName + ' = $' + $parameterName)
                }

                $null = $stringBuilder.AppendLine()
            }
        }
    }

    return $stringBuilder.ToString()
}

<#
    .SYNOPSIS
        Creates a string representing a configuration script for a set of resources.

    .PARAMETER ResourceName
        The name of the resource to create a set of.

    .PARAMETER ModuleName
        The name of the module to import the resource from.

    .PARAMETER KeyParameterName
        The name of the key parameter that will differentiate each resource.

    .PARAMETER KeyParameterValues
        An array of the values of the key parameter that will differentiate each resource.

    .PARAMETER CommonParameterString
        A string representing the common parameters for each resource.
        Can be retrieved from New-ResourceSetCommonParameterString.

    .EXAMPLE
        New-ResourceSetConfigurationString `
            -ResourceName 'xWindowsFeature' `
            -ModuleName 'xPSDesiredStateConfiguration' `
            -KeyParameterName 'Name' `
            -KeyParameterValues @( 'Telnet-Client', 'Web-Server' ) `
            -CommonParameterString 'Ensure = "Present"`r`nIncludeAllSubFeature = $true'

        OUTPUT (as a String):
            Import-Module -Name xWindowsFeature -ModuleName xPSDesiredStateConfiguration

            xWindowsFeature Resource0
            {
                Name = "Telnet-Client"
                Ensure = "Present"
                IncludeAllSubFeature = $true
            }

            xWindowsFeature Resource1
            {
                Name = "Web-Server"
                Ensure = "Present"
                IncludeAllSubFeature = $true
            }
#>
function New-ResourceSetConfigurationString
{
    [OutputType([System.String])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ResourceName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ModuleName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $KeyParameterName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $KeyParameterValues,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $CommonParameterString
    )

    $stringBuilder = New-Object -TypeName 'System.Text.StringBuilder'

    $null = $stringBuilder.AppendFormat('Import-DscResource -Name {0} -ModuleName {1}', $ResourceName, $ModuleName)
    $null = $stringBuilder.AppendLine()

    $resourceCount = 0
    foreach ($keyParameterValue in $KeyParameterValues)
    {
        $null = $stringBuilder.AppendFormat('{0} Resource{1}', $ResourceName, $resourceCount)
        $null = $stringBuilder.AppendLine()
        $null = $stringBuilder.AppendLine('{')
        $null = $stringBuilder.AppendFormat($KeyParameterName + ' = "{0}"', $keyParameterValue)
        $null = $stringBuilder.AppendLine()
        $null = $stringBuilder.Append($CommonParameterString)
        $null = $stringBuilder.AppendLine('}')

        $resourceCount++
    }

    return $stringBuilder.ToString()
}

<#
    .SYNOPSIS
        Creates a configuration script block for a set of resources.

    .PARAMETER ResourceName
        The name of the resource to create a set of.

    .PARAMETER ModuleName
        The name of the module to import the resource from.

    .PARAMETER KeyParameterName
        The name of the key parameter that will differentiate each resource.

    .PARAMETER Parameters
        The hashtable of all parameters to the resource set (PSBoundParameters).

    .EXAMPLE
        # From the xGroupSet composite resource

        $newResourceSetConfigurationParams = @{
            ResourceName = 'xGroup'
            ModuleName = 'xPSDesiredStateConfiguration'
            KeyParameterName = 'GroupName'
            CommonParameterNames = @( 'Ensure', 'MembersToInclude', 'MembersToExclude', 'Credential' )
            Parameters = $PSBoundParameters
        }

        $configurationScriptBlock = New-ResourceSetConfigurationScriptBlock @newResourceSetConfigurationParams

    .NOTES
        Only allows one key parameter to be defined for each node.
        For resources with multiple key parameters, only one key can be different for each resource.
        See xProcessSet for an example of a resource set with two key parameters.
#>
function New-ResourceSetConfigurationScriptBlock
{
    [OutputType([System.Management.Automation.ScriptBlock])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ResourceName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ModuleName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $KeyParameterName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Hashtable]
        $Parameters
    )

    $commonParameterString = New-ResourceSetCommonParameterString -KeyParameterName $KeyParameterName -Parameters $Parameters

    $newResourceSetConfigurationStringParams = @{
        ResourceName = $ResourceName
        ModuleName = $ModuleName
        KeyParameterName = $KeyParameterName
        KeyParameterValues = $Parameters[$KeyParameterName]
        CommonParameterString = $commonParameterString
    }

    $resourceString = New-ResourceSetConfigurationString @newResourceSetConfigurationStringParams

    return [System.Management.Automation.ScriptBlock]::Create($resourceString)
}

$script:localizedData = Get-LocalizedData -ResourceName 'xPSDesiredStateConfiguration.Common' -ScriptRoot $PSScriptRoot
