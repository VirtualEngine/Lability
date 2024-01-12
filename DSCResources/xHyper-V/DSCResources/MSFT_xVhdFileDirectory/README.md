# Description

Manages files or directories in a VHD.

You can use it to copy files/folders to the VHD, remove files/folders
from a VHD, and change attributes of a file in a VHD (e.g. change a
file attribute to 'ReadOnly' or 'Hidden'). This resource is particularly
useful when bootstrapping DSC Configurations into a VM.

## Requirements

* The Hyper-V Role has to be installed on the machine.
* The Hyper-V PowerShell module has to be installed on the machine.
