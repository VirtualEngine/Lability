# Description

Manages the SCSI controllers attached to a Hyper-V virtual machine.

When removing a controller, all the disks still connected to the controller
will be detached.

## Requirements

* The Hyper-V Role has to be installed on the machine.
* The Hyper-V PowerShell module has to be installed on the machine.
