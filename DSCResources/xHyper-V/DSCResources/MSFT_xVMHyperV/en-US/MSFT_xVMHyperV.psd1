ConvertFrom-StringData @'
    RoleMissingError                  = Please ensure that '{0}' role is installed with its PowerShell module.
    MoreThanOneVMExistsError          = More than one VM with the name '{0}' exists.
    PathDoesNotExistError             = Path '{0}' does not exist.
    VhdPathDoesNotExistError          = Vhd '{0}' does not exist.
    MinMemGreaterThanStartupMemError  = MinimumMemory '{0}' should not be greater than StartupMemory '{1}'
    MinMemGreaterThanMaxMemError      = MinimumMemory '{0}' should not be greater than MaximumMemory '{1}'
    StartUpMemGreaterThanMaxMemError  = StartupMemory '{0}' should not be greater than MaximumMemory '{1}'.
    VhdUnsupportedOnGen2VMError       = Generation 2 virtual machines do not support the .VHD virtual disk extension.
    CannotUpdatePropertiesOnlineError = Can not change properties for VM '{0}' in '{1}' state unless 'RestartIfNeeded' is set to true.
    AutomaticCheckpointsUnsupported   = AutomaticCheckpoints are not supported on this host.

    AdjustingGreaterThanMemoryWarning = VM {0} '{1}' is greater than {2} '{3}'. Adjusting {0} to be '{3}'.
    AdjustingLessThanMemoryWarning    = VM {0} '{1}' is less than {2} '{3}'. Adjusting {0} to be '{3}'.
    VMStateWillBeOffWarning           = VM '{0}' state will be 'OFF' and not 'Paused'.

    CheckingVMExists                  = Checking if VM '{0}' exists ...
    VMExists                          = VM '{0}' exists.
    VMDoesNotExist                    = VM '{0}' does not exist.
    CreatingVM                        = Creating VM '{0}' ...
    VMCreated                         = VM '{0}' created.
    VMPropertyShouldBe                = VM property '{0}' should be '{1}', actual '{2}'.
    VMPropertySet                     = VM property '{0}' is '{1}'.
    VMPropertiesUpdated               = VM '{0}' properties have been updated.
    WaitingForVMIPAddress             = Waiting for IP Address for VM '{0}' ...

    QueryingVM                        = Querying VM '{0}'.
'@
