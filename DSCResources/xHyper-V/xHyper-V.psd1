@{
# Version number of this module.
moduleVersion = '3.16.0.0'

# ID used to uniquely identify this module
GUID = 'f5a5f169-7026-4053-932a-19a7c37b1ca5'

# Author of this module
Author = 'Microsoft Corporation'

# Company or vendor of this module
CompanyName = 'Microsoft Corporation'

# Copyright statement for this module
Copyright = '(c) 2017 Microsoft Corporation. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Module with DSC Resources for Hyper-V area'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '4.0'

# Minimum version of the common language runtime (CLR) required by this module
CLRVersion = '4.0'

# Functions to export from this module
FunctionsToExport = '*'

# Cmdlets to export from this module
CmdletsToExport = '*'

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('DesiredStateConfiguration', 'DSC', 'DSCResourceKit', 'DSCResource')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/PowerShell/xHyper-V/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/PowerShell/xHyper-V'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = '* MSFT_xVMHyperV:
  * Moved localization string data to own file.
  * Fixed code styling issues.
  * Fixed bug where StartupMemory was not evaluated in Test-TargetResource.
  * Redo of abandoned PRs:
    * [PR 148](https://github.com/PowerShell/xHyper-V/pull/148), Fixes [Issue 149](https://github.com/PowerShell/xHyper-V/issues/149).
    * [PR 67](https://github.com/PowerShell/xHyper-V/pull/67), Fixes [Issue 145](https://github.com/PowerShell/xHyper-V/issues/145).
  * Fixed Get throws error when NetworkAdapters are not attached or missing properties.

'

    } # End of PSData hashtable

} # End of PrivateData hashtable
}















