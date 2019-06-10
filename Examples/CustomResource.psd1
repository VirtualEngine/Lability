@{
    AllNodes = @(
        @{
            NodeName = 'SQL2014';

            ## If no network is specified, the virtual machine will be attached to a default internal virtual switch.
            Lability_SwitchName = 'Corpnet';

            ## Specify the resource identifiers of the resources to be copied to the target node during VM creation.
            Lability_Resource = @('SQL2014Express');
        }
    );
    NonNodeData = @{
        Lability = @{
            Resource = @(
                @{
                    ## Resource identifier. If the resource is to be expanded (ZIP or ISO), it will also be expanded into
                    ## the \Resources\<ResourceID> folder on the target node.
                    Id = 'SQL2014Express';

                    ## When the file is downloaded, it will be placed in the host's Resources folder using this filename.
                    Filename = 'SQLEXPRWT_x64_ENU.zip';

                    ## The source URI to download the file from if it is not present in the host's Resources folder. This can
                    ## be a http, https or file URI. If the path includes spaces, they must be URL encoded.
                    Uri = 'file://\\FILESERVER\SHARE\Software\Microsoft\SQLEXPRWT_x64_ENU.zip';

                    ## If you want the module to check the downloaded file, you can specify a MD5 checksum. If you do specify a
                    ## checksum you HAVE to ensure it's correct otherwise it will continuously attempt to download the image!
                    Checksum = '';

                    ## If the resource is a .ZIP or .ISO file, it can be expanded/decompressed when copied into the node's
                    ## \Resources\<ResourceID> folder. If not specified, this value defaults to False.
                    Expand = $true;

                    ## The default target path can be overridden by specifying a destination path. This path is relative to
                    ## the root of the operating system drive. Resources will be placed inside this directory.
                    DestinationPath = '\Windows'
                }
            );
            Network = @(
                @{ Name = 'Corpnet'; Type = 'Internal'; }
            );
        };
    };
};
