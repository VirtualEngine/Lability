@{
    # Root module
    RootModule        = 'Modules\DscPullServerSetup\DscPullServerSetup.psm1'

    # Version number of this module.
    moduleVersion     = '9.1.0'

    # ID used to uniquely identify this module
    GUID              = 'cc8dc021-fa5f-4f96-8ecf-dfd68a6d9d48'

    # Author of this module
    Author            = 'DSC Community'

    # Company or vendor of this module
    CompanyName       = 'DSC Community'

    # Copyright statement for this module
    Copyright         = 'Copyright the DSC Community contributors. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'DSC resources for configuring common operating systems features, files and settings.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '4.0'

    # Minimum version of the common language runtime (CLR) required by this module
    CLRVersion        = '4.0'

    # Functions to export from this module
    FunctionsToExport = @(
        'Publish-DscModuleAndMof',
        'Publish-ModulesAndChecksum',
        'Publish-MofsInSource',
        'Publish-ModuleToPullServer',
        'Publish-MofToPullServer'
    )

    # Cmdlets to export from this module
    CmdletsToExport   = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport   = @()

    # DSC resources to export from this module
    DscResourcesToExport  = @(
        'xArchive', 'xDSCWebService', 'xEnvironment','xGroup','xMsiPackage',
        'xPackage','xPSEndpoint','xRegistry','xRemoteFile',
        'xScript','xService','xUser','xWindowsFeature','xWindowsOptionalFeature',
        'xWindowsPackageCab','xWindowsProcess'
    )

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{

        PSData = @{
            # Set to a prerelease string value if the release should be a prerelease.
            Prerelease   = ''

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @('DesiredStateConfiguration', 'DSC', 'DSCResourceKit', 'DSCResource')

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/dsccommunity/xPSDesiredStateConfiguration/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/dsccommunity/xPSDesiredStateConfiguration'

            # A URL to an icon representing this module.
            IconUri      = 'https://dsccommunity.org/images/DSC_Logo_300p.png'

            # ReleaseNotes of this module
            ReleaseNotes = '## [9.1.0] - 2020-02-19

### Changed

- Examples
  - Removed the version number of the xPSDesiredStateConfiguration module from the #Requires headers. -
    [issue #653](https://github.com/dsccommunity/xPSDesiredStateConfiguration/issues/653)

### Fixed

- xPSDesiredStateConfiguration
  - Export `Publish-*` functions in DscPullServerSetup module - Fixes
    [issue #673](https://github.com/PowerShell/PSDscResources/issues/673).

- DSC_xRegistryResource
  - Fixed an issue that failed to create a registry with ":" in the path.
    [issue #671](https://github.com/dsccommunity/xPSDesiredStateConfiguration/issues/671)

## [9.0.0] - 2020-01-15

### Added

- xPSDesiredStateConfiguration
  - Added support for Checksum on xRemoteFile - [issue #423](https://github.com/PowerShell/PSDscResources/issues/423)
  - Added `Test-DscParameterState` support function to `xPSDesiredStateConfiguration.Common.psm1`.
  - Added standard unit tests for `xPSDesiredStateConfiguration.Common.psm1`.
  - Added automatic release with a new CI pipeline.

### Changed

- xPSDesiredStateConfiguration
  - PublishModulesAndMofsToPullServer.psm1:
    - Fixes issue in Publish-MOFToPullServer that incorrectly tries to create a
      new MOF file instead of reading the existing one.
      [issue #575](https://github.com/PowerShell/xPSDesiredStateConfiguration/issues/575)
  - Fix minor style issues with missing spaces between `param` statements and ''(''.
  - MSFT_xDSCWebService:
    - Removal of commented out code.
    - Updated to meet HQRM style guidelines - Fixes [issue #623](https://github.com/PowerShell/xPSDesiredStateConfiguration/issues/623)
    - Added MOF descriptions.
  - Corrected minor style issues.
  - Fix minor style issues in hashtable layout.
  - Shared modules moved to `source/Module` folder and renamed:
    - `CommonResourceHelper.psm1` -> `xPSDesiredStateConfiguration.Common.psm1`
  - Moved functions from `ResourceSetHelper.psm1` into
    `xPSDesiredStateConfiguration.Common.psm1`.
  - BREAKING CHANGE: Changed resource prefix from MSFT to DSC.
  - Pinned `ModuleBuilder` to v1.0.0.
  - Updated build badges in README.MD.
  - Remove unused localization strings.
  - Adopt DSC Community Code of Conduct.
  - DSC_xPSSessionConfiguration:
    - Moved strings to localization file.
  - DSC_xScriptResource
    - Updated parameter descriptions to match MOF file.
  - Correct miscellaneous style issues.
  - DSC_xWindowsOptionalFeature
    - Fix localization strings.
  - DSC_xEnvironmentResource
    - Remove unused localization strings.
  - DSC_xRemoteFile
    - Updated end-to-end tests to use the same pattern as the other end-to-end
      tests in this module.
  - DSC_xDSCWebService
    - Moved `PSWSIISEndpoint.psm1` module into `xPSDesiredStateConfiguration.PSWSIIS`.
    - Moved `Firewall.psm1` module into `xPSDesiredStateConfiguration.Firewall`.
    - Moved `SecureTLSProtocols.psm1` and `UseSecurityBestPractices.psm1` module
      into `xPSDesiredStateConfiguration.Security`.
    - Fix issue with `Get-TargetResource` when a DSC Pull Server website is not
      installed.
  - DSC_xWindowsFeature
    - Changed tests to be able to run on machines without `*-WindowsFeature` cmdlets.
    - Changed `Assert-SingleInstanceOfFeature` to accept an array.
  - BREAKING CHANGE: Renamed `PublishModulesAndMofsToPullServer` module to
    `DscPullServerSetup` and moved to Modules folder.
  - Moved test helper modules into `tests\TestHelpers` folder.
- DSCPullServerSetup
  - Fixed markdown errors in README.MD.
  - Moved strings to Localization file.
  - Corrected style violations.
- Updated build badges to reflect correct Azure DevOps build Definition Id - fixes
  [issue #656](https://github.com/PowerShell/xPSDesiredStateConfiguration/issues/656).
- Set `testRunTitle` for PublishTestResults steps so that a helpful name is
  displayed in Azure DevOps for each test run.
- Set a display name on all the jobs and tasks in the CI
  pipeline - fixes [issue #663](https://github.com/PowerShell/xPSDesiredStateConfiguration/issues/663).

### Deprecated

- None

### Removed

- xPSDesiredStateConfiguration
  - Removed files no longer required by new CI process.

### Fixed

- MSFT_xRegistryResource
  - Fixes issue that the `Set-TargetResource` does not determine
    the type of registry value correctly.
    [issue #436](https://github.com/dsccommunity/xPSDesiredStateConfiguration/issues/436)
- Fixed Pull Server example links in `README.MD` - fixes
  [issue #659](https://github.com/PowerShell/xPSDesiredStateConfiguration/issues/659).
- Fixed `GitVersion.yml` feature and fix Regex - fixes
  [issue #660](https://github.com/PowerShell/xPSDesiredStateConfiguration/issues/660).
- Fix import statement in all tests, making sure it throws if module
  DscResource.Test cannot be imported - fixes
  [issue #666](https://github.com/PowerShell/xPSDesiredStateConfiguration/issues/666).
- Fix deploy stage in CI pipeline to prevent it executing against forks
  of the repository - fixes [issue #665](https://github.com/PowerShell/xPSDesiredStateConfiguration/issues/665).
- Fix deploy fork detection in CI pipeline - fixes [issue #668](https://github.com/PowerShell/xPSDesiredStateConfiguration/issues/668).

### Security

- None

'
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}





