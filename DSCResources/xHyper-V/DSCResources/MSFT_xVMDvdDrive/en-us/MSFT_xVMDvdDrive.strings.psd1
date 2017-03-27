ConvertFrom-StringData @'
    GettingVMDVDDriveMessage = Getting VM DVD Drive for VM '{0}' controller number {1} location {2}.

    SettingVMDVDDriveMessage = Setting VM DVD Drive for VM '{0}' controller number {1} location {2}.
    VMDVDDriveChangePathMessage = VM '{0}' DVD Drive on controller number {1} location {2} already exists, changing the Path to '{3}'.
    VMDVDDriveAddMessage = Adding VM '{0}' DVD Drive on controller number {1} location {2} with path '{3}'.
    VMDVDDriveRemoveMessage = Removing VM '{0}' DVD Drive on controller number {1} location {2}.

    TestingVMDVDDriveMessage = Testing VM DVD Drive for VM '{0}' controller number {1} location {2}.
    VMDVDDriveExistsAndShouldPathMismatchMessage = VM '{0}' DVD Drive on controller number {1} location {2} exists and should but the desired path '{3}' does not match '{4}'. Change required.
    VMDVDDriveExistsAndShouldMessage = VM '{0}' DVD Drive on controller number {1} location {2} exists and should and the path '{3}' matches. Change not required.
    VMDVDDriveDoesNotExistButShouldMessage = VM '{0}' DVD Drive on controller number {1} location {2} does not exist but should. Change required.
    VMDVDDriveDoesExistButShouldNotMessage = VM '{0}' DVD Drive on controller number {1} location {2} exists but should not. Change required.
    VMDVDDriveDoesNotExistAndShouldNotMessage = VM '{0}' DVD Drive on controller number {1} location {2} does not exist and should not. Change not required.

    RoleMissingError = Please ensure that '{0}' role is installed with its PowerShell module.
    VMControllerDoesNotExistError = The controller number {1} does not exist on VM '{0}'.
    PathDoesNotExistError = The path '{0}' does not exist.
    ControllerConflictError = The Controller number {1} location {2} already has a hard drive attached on VM '{0}'.
'@
