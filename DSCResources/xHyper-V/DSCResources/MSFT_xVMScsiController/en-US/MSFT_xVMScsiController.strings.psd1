ConvertFrom-StringData @'
    ControllerFound                 = Found controller '{0}' attached to VM '{1}'.
    ControllerNotFound              = Controller '{0}' missing from VM '{1}'
    ComparingParameter              = Comparing '{0}'. Expected '{1}', actual '{2}'.
    AddingController                = Adding controller number '{0}'.
    CheckingExistingDisks           = Checking for existing disks on controller '{0}'.
    RemovingController              = Removing controller '{0}' from VM '{1}'.

    RemovingDiskWarning             = Removing disk '{0}' from the controller '{1}'.

    CannotUpdateVmOnlineError       = Cannot update a running VM unless 'RestartIfNeeded' is set to true.
    CannotAddScsiControllerError    = Cannot add controller number '{0}'. Ensure that all intermediate controllers are present on the system.
    CannotRemoveScsiControllerError = Cannot remove controller number '{0}'. Ensure that you are removing the last controller to ensure that controller numbers are not reordered.
'@
