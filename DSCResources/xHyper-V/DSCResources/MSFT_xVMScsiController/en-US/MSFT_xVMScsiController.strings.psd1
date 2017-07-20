ConvertFrom-StringData @'
    CheckingIfVmIsRunning = Checking if the VM is running, so that we can restore it's state after adding/removing controllers.
    StoppingTheVM = Stopping the VM so that we can manipulate the controller(s).
    ControllerNumberWasProvided = A controller number was provided. Looking if intermediate controllers must also be created.
    AddingAdditionalController = Adding controller number {0}.
    CheckingIfDrivesRemainOnController = Checking if there are still drives connected to controller {0}.
    RemovingDriveFromController = Removing drive {0} from the controller.
    RemovingController = Removing the controller {0} from the VM.
    RestartingVM = Restarting the VM as it was shutdown to manipulate the controller.
    ComparingDesiredActual = Comparing the actual to the desired value for {0}: {1} vs {2}
'@
