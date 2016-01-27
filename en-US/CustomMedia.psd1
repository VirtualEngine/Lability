@{
    AllNodes = @(
        @{
            NodeName = '2008R2';
            Lability_ProcessorCount = 2;
            Lability_Media = '2008R2_x64_Standard_EN_Eval';
        }
    );
    NonNodeData = @{
        Lability = @{
            Media = @(
                @{
                    ## The image ID that is used by nodes when refencing the image.
                    Id = '2008R2_x64_Standard_EN_Eval';
                    
                    ## The target filename that the image is downloaded into the 'ParentVhdPath'. You can manually place
                    ## a vhdx here to avoid the download process.
                    Filename = '2008R2_x64_Standard_EN_Eval.vhdx';
                    
                    ## The architecture is not used for custom images as the disk partitioning is already complete,
                    ## but it is a required media property.
                    Architecture = 'x64';
                    
                    ## The source URI to download the file from. This is only used if the vhdx image is not present
                    ## in the 'ParentVhdPath' location. If you place the vhdx there, it's not (re)downloaded.
                    Uri = 'file://C:\Users\Public\Documents\Hyper-V\Virtual%20Hard%20Disks\2008R2_x64_Standard_EN_Eval.vhdx';
                    
                    ## If you want the module to check the file copy, you can specify a MD5 checksum. If you do specify a
                    ## checksum you HAVE to ensure it's correct otherwise it will continuously attempt to download the image!
                    Checksum = '';
                    
                    ## Media description.
                    Description = 'Custom SYSPREP''d Windows Server 2008 R2 Standard 64bit English Evaluation';
                    
                    ## You must specify 'VHD' type to ensure that WIM images are not attempted to be extracted.
                    MediaType = 'VHD';
                }
            );
            Network = @(
                ## If no network is specified, the virtual machine will be attached to a default internal virtual switch.
            );
        };
    };
};
