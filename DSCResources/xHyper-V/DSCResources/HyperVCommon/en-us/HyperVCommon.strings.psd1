ConvertFrom-StringData @'
    UpdatingVMProperties              = Updating VM '{0}' properties.
    VMPropertiesUpdated               = VM '{0}' properties have been updated.
    WaitingForVMIPAddress             = Waiting for IP Address for VM '{0}' ...
    StoppingVM                        = Stopping VM '{0}'.
    SuspendingVM                      = Suspending VM '{0}'.
    StartingVM                        = Starting VM '{0}'.
    ResumingVM                        = Resuming VM '{0}'.

    VMStateWillBeOffWarning           = VM '{0}' state will be 'OFF' and not 'Paused'.

    CannotUpdatePropertiesOnlineError = Can not change properties for VM '{0}' in '{1}' state unless 'RestartIfNeeded' is set to true.
    WaitForVMIPAddressTimeoutError    = Waiting for VM '{0}' IP address timed out after {1} seconds.
    RoleMissingError                  = Please ensure that '{0}' role is installed with its PowerShell module.
    MoreThanOneVMExistsError          = More than one VM with the name '{0}' exists.
'@
