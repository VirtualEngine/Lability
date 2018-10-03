ConvertFrom-StringData @'
    DiskFound                    = Found hard disk '{0}' attached to VM '{1}'.
    DiskNotFound                 = Hard disk '{0}' missing from VM '{1}'
    CheckingDiskIsAttached       = Checking if the disk is already attached to the VM.
    CheckingExistingDiskLocation = Checking if there is an existing disk in the specified location.
    AddingDisk                   = Adding the disk '{0}' to VM '{1}'.
    RemovingDisk                 = Removing disk '{0}' from VM '{1}'.
    ComparingParameter           = Comparing '{0}'; expected '{1}', actual '{2}'.

    DiskPresentError             = There is already a disk present in controller '{0}', location '{1}'.
    IdeLocationError             = ControllerNumber '{0}' or ControllerLocation '{1}' are not valid for IDE controller.
'@
