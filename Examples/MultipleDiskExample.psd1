@{
    AllNodes = @(
        @{
            NodeName            = 'MULTIDISK';
            Lability_Media      = '2016_x64_Datacenter_Nano_EN_Eval';
            Lability_SwitchName = 'Internal';

            ## Specify additional disks as an array of hashtables.
            ## Controller location is inferred by the position in the array - the first array element is
            ##   attached to the controller location #1.
            ## Only the default controller - controller number 0 is supported. The default controller type of
            ##   a generation 1 VM is IDE; generation 2 defaults to a SCSI controller.
            ## The drive(s) are not partitioned or formatted in any way.
            ## Currently only dynamic VHDs can be created - you can create a fix VHD prior to running
            ##   Lability to attach it.
            Lability_HardDiskDrive   = @(
                ## You can get Lability to create an empty VHD by specifying the VHD type and size.
                ## NOTE: only dynamic VHDs can be created in this manner.
                @{
                    ## Specifies the type of virtual hard disk file. Supported values are 'VHD' or 'VHDX'
                    Type = 'VHDX';
                    ## Specifies the maximum size of the VHD. Only dynamic VHD(X)s are supported by xVHD
                    MaximumSizeBytes = 127GB;
                }
                ## You can also attach an existing VHD/X file by specifying the path.
                @{
                    ## Use the specified VHD(X). VHD(X) files created outside of Lability are not removed.
                    VhdPath = 'C:\Users\Public\Documents\Hyper-V\Virtual Hard Disks\Example.vhd';
                }
            )
        }
    );
};
