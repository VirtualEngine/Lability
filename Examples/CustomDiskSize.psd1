@{
    AllNodes = @(
        @{
            NodeName = '2016FIXED';
            Lability_ProcessorCount = 2;
            Lability_Media = '2016_x64_Standard_EN_Eval_Fixed';

            Lability_HardDiskDrive   = @(
                ## Lability can create one or more empty VHDs. You can pass any parameter
                ##   supported by the xVHD resource (https://github.com/PowerShell/xHyper-V#xvhd)
                @{
                    ## Specifies the type of virtual hard disk file. Supported values are 'VHD' or 'VHDX'
                    Generation = 'VHDX';
                    ## Type of VHD to create. Supported values are 'Dynamic' or 'Fixed'.
                    Type = 'Fixed';
                    ## Specifies the maximum size of the VHD (in bytes).
                    MaximumSizeBytes = 5GB;
                }
            )
        }
    );
    NonNodeData = @{
        Lability = @{
            Media = @(
                @{
                    Id = '2016_x64_Standard_EN_Eval_Fixed'
                    Filename = '2016_x64_EN_Eval.iso'
                    Description = 'Windows Server 2016 Standard 64bit English Evaluation Fixed'
                    Architecture = 'x64'
                    ImageName = '2'
                    MediaType = 'ISO'
                    OperatingSystem = 'Windows'
                    Uri = 'http://download.microsoft.com/download/1/4/9/149D5452-9B29-4274-B6B3-5361DBDA30BC/14393.0.161119-1705.RS1_REFRESH_SERVER_EVAL_X64FRE_EN-US.ISO'
                    Checksum = '18A4F00A675B0338F3C7C93C4F131BEB'
                    CustomData = @{
                        MinimumDismVersion =  '10.0.0.0'
                        DiskType = 'Fixed'
                        DiskSize = 20GB
                    }
                }
            );
        };
    };
};
