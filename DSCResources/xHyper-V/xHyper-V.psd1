@{
    # Version number of this module.
    moduleVersion     = '3.18.0'

    # ID used to uniquely identify this module
    GUID              = 'f5a5f169-7026-4053-932a-19a7c37b1ca5'

    # Author of this module
    Author            = 'DSC Community'

    # Company or vendor of this module
    CompanyName       = 'DSC Community'

    # Copyright statement for this module
    Copyright         = 'Copyright the DSC Community contributors. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'This module contains DSC resources for deployment and configuration of Microsoft Hyper-V.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '4.0'

    # Minimum version of the common language runtime (CLR) required by this module
    CLRVersion        = '4.0'

    # Functions to export from this module
    FunctionsToExport = @()

    # Cmdlets to export from this module
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport = @()

    DscResourcesToExport = @('xVHD','xVhdFile','xVMDvdDrive','xVMHardDiskDrive','xVMHost','xVMHyperV','xVMNetworkAdapter','xVMProcessor','xVMScsiController','xVMSwitch')

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{
        PSData = @{
            # Set to a prerelease string value if the release should be a prerelease.
            Prerelease   = ''

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @('DesiredStateConfiguration', 'DSC', 'DSCResourceKit', 'DSCResource')

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/dsccommunity/xHyper-V/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/dsccommunity/xHyper-V'

            # A URL to an icon representing this module.
            IconUri = 'https://dsccommunity.org/images/DSC_Logo_300p.png'

            # ReleaseNotes of this module
            ReleaseNotes = '## [3.18.0] - 2022-06-04

### Added

- xHyper-V
  - Added automatic release with a new CI pipeline.
  - Added stubs for the powershell module Hyper-V that are used for
    all unit tests.
- xVhdFileDirectory
  - Added initial set of unit tests

### Deprecated

- **The module _xHyper-V_ will be renamed to _HyperVDsc_
  ([issue #62](https://github.com/dsccommunity/xHyper-V/issues/62)).
  The version `v3.18.0` will be the the last release of _xHyper-V_.
  Version `v4.0.0` will be released as _HyperVDsc_, it will be
  released shortly after the `v3.18.0` release to be able to start transition
  to the new module. The prefix ''x'' will be removed from all resources in
  _HyperVDsc_.**
- xHyper-V
  - The resource will not be tested for Windows Server 2008 R2 since
    that operating system has reach end-of-life.

### Removed

- xVMSwitch
  - Removed the unit test that simulated functionality on Windows Server 2008 R2
    since that operating system has reach end-of-life. No functionality was
    removed from the resource, but in a future release the resource might stop
    working for Windows Server 2008 R2.

### Changed

- Update the pipeline files to the lates from Sampler.

### Fixed

- xVMDvdDrive
  - Fixed VMName property in example.
- xVMNetworkAdapter
  - Fixed MacAddress sample data.
- xVMSwitch
  - Correctly return the state as `$true` or `$false` depending on the
    `Ensure` property when the switch does not exist.
'
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
