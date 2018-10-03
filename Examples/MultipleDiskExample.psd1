@{
    AllNodes = @(
        @{
            NodeName            = 'MULTIDISK';
            Lability_Media      = '2016_x64_Datacenter_Nano_EN_Eval';

            ## Specify additional disks as an array of hashtables.
            ## Controller location is inferred by the position in the array - the first array element is
            ##   attached to the controller location #1.
            ## Only the default controller - controller number 0 is supported. The default controller type of
            ##   a generation 1 VM is IDE; generation 2 defaults to a SCSI controller.
            ## The drive(s) are not partitioned or formatted in any way.
            ## Currently only dynamic VHDs can be created - you can create a fix VHD prior to running
            ##   Lability to attach it.
            Lability_HardDiskDrive   = @(
                ## Lability can create one or more empty VHDs. You can pass any parameter
                ##   supported by the xVHD resource (https://github.com/PowerShell/xHyper-V#xvhd)
                @{
                    ## Specifies the type of virtual hard disk file. Supported values are 'VHD' or 'VHDX'
                    Generation = 'VHDX';
                    ## Specifies the maximum size of the VHD.
                    MaximumSizeBytes = 127GB;
                }
                ## You can also attach an existing VHD/X file by specifying the path.
                @{
                    ## Use the specified VHD(X).
                    ## NOTE: VHD(X) files created outside of Lability are not removed when VMs are removed.
                    VhdPath = 'C:\Users\Public\Documents\Hyper-V\Virtual Hard Disks\Example.vhd';
                }
            )
        }
    );
};
