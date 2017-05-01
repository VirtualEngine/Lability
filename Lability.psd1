@{
    RootModule = 'Lability.psm1';
    ModuleVersion = '0.11.0';
    GUID = '374126b4-f3d4-471d-b25e-767f69ee03d0';
    Author = 'Iain Brighton';
    CompanyName = 'Virtual Engine';
    Copyright = '(c) 2016 Virtual Engine Limited. All rights reserved.';
    Description = 'The Lability module contains cmdlets for provisioning Hyper-V test lab and development environments.';
    PowerShellVersion = '4.0';
    FormatsToProcess = @('Lability.Format.ps1xml');
    FunctionsToExport = @('Start-Lab', 'Stop-Lab', 'Reset-Lab', 'Checkpoint-Lab', 'Restore-Lab','Test-LabConfiguration',
        'Start-LabConfiguration', 'Remove-LabConfiguration', 'Get-LabHostConfiguration', 'Test-LabHostConfiguration', 'Start-LabHostConfiguration',
        'Reset-LabHostDefault', 'Get-LabHostDefault', 'Set-LabHostDefault', 'Get-LabImage', 'Test-LabImage', 'New-LabImage', 'Get-LabMedia',
        'Test-LabMedia', 'Register-LabMedia', 'Unregister-LabMedia', 'Reset-LabMedia', 'Test-LabResource', 'Invoke-LabResourceDownload',
        'Get-LabVM', 'Test-LabVM', 'Reset-LabVM', 'New-LabVM', 'Remove-LabVM', 'Reset-LabVMDefault', 'Set-LabVMDefault', 'Get-LabVMDefault',
        'Export-LabHostConfiguration','Import-LabHostConfiguration', 'Start-DscCompilation', 'Install-LabModule', 'Clear-ModulePath',
        'Clear-LabModuleCache', 'Get-LabStatus', 'Test-LabStatus', 'Wait-Lab',
        'Reset-LabVMDefaults', 'Set-LabVMDefaults', 'Get-LabVMDefaults', 'Reset-LabHostDefaults', 'Get-LabHostDefaults', 'Set-LabHostDefaults');
    CmdletsToExport = @(); # Suppresses exporting of imported the DISM cmdlets
    PrivateData = @{
        PSData = @{  # Private data to pass to the module specified in RootModule/ModuleToProcess
            Tags = @('VirtualEngine','Lability','Powershell','Development','HyperV','Hyper-V','Test','Lab','TestLab');
            LicenseUri = 'https://github.com/VirtualEngine/Lability/blob/master/LICENSE';
            ProjectUri = 'https://github.com/VirtualEngine/Lability';
            IconUri = 'https://raw.githubusercontent.com/VirtualEngine/Lability/master/Lability.png';
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
