function Install-LabModule {
<#
    .SYNOPSIS
        Installs Lability PowerShell and DSC resource modules.
    .DESCRIPTION
        The Install-LabModule cmdlet installs PowerShell modules and/or DSC resource modules from Lability's
        module cache in to the local system. The DSC resources and/or PowerShell module can be installed into
        either the current user's or the local machine's module path.
    .PARAMETER ConfigurationData
        Specifies a PowerShell DSC configuration data hashtable or a path to an existing PowerShell DSC .psd1
        configuration document that contains ability'srequired media definition.
    .PARAMETER ModuleType
        Specifies the module type(s) defined in a PowerShell DSC configuration (.psd1) document to install.
    .PARAMETER NodeName
        Specifies only modules that target the node(s) specified are installed.
    .PARAMETER Scope
        Specifies the scope to install module(s) in to. The default value is 'CurrentUser'.
    .EXAMPLE
        Install-LabModule -ConfigurationData .\Config.psd1 -ModuleType -DscResource

        Installs all DSC resource modules defined in the 'Config.psd1' document into the user's module scope.
    .EXAMPLE
        Install-LabModule -ConfigurationData .\Config.psd1 -ModuleType -Module -Scope AllUsers

        Installs all PowerShell modules defined in the 'Config.psd1' document into the local machine's module scope.
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess','')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.String] $ConfigurationData,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateSet('Module','DscResource')]
        [System.String[]] $ModuleType,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $NodeName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('AllUsers','CurrentUser')]
        [System.String] $Scope = 'CurrentUser'
    )
    process {

        $moduleRelativePath = 'WindowsPowerShell\Modules';

        if ($Scope -eq 'AllUsers') {

            $systemDrive = (Resolve-Path -Path $env:SystemDrive).Drive;
            $localizedProgramFiles = Resolve-ProgramFilesFolder -Drive $systemDrive;
            $DestinationPath = Join-Path -Path $localizedProgramFiles.FullName -ChildPath $moduleRelativePath;
        }
        elseif ($Scope -eq 'CurrentUser') {

            $userDocuments = [System.Environment]::GetFolderPath('MyDocuments');
            $DestinationPath = Join-Path -Path $userDocuments -ChildPath $moduleRelativePath;
        }

        $copyLabModuleParams = @{
            ConfigurationData = $ConfigurationData;
            ModuleType = $ModuleType;
            DestinationPath = $DestinationPath;
        }
        Copy-LabModule @copyLabModuleParams;

    } #end process
} #end function
