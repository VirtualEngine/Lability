@{
    AllNodes = @(
        @{
            NodeName            = 'DVDDRIVE';
            Lability_Media      = '2016_x64_Datacenter_Nano_EN_Eval';
            Lability_SwitchName = 'Internal';

            ## Attach an ISO file to the default controller in location #1
            ## Location #0 is taken by the first/default VHD/X file
            Lability_DvdDrive   = @{
                ## This will not create a IDE/SCSI controller. Therefore, you must enusre
                ## that the target controller already exists and does not already contain a disk
                ControllerNumber   = 0;
                ControllerLocation = 1;
                ## Lability can resolve the ISO path using the built-in environment variables
                ## NOTE: variable expansion is only available to Lability-specific node properties
                Path = '%LabilityConfigurationPath%\DvdDrive.iso';
            }
        }
    );
};
