@{
    AllNodes = @(
        @{
            NodeName = 'BLANKDISK';
            Lability_ProcessorCount = 2;
            Lability_Media = 'BlankMedia';
        }
    );
    NonNodeData = @{
        Lability = @{
            Media = @(
                @{
                    Id = 'BlankMedia'
                    Filename = '<NotUsedButCannotBeEmpty>'
                    Description = 'Empty VHD for Linux (or manual Windows) installation'
                    Architecture = 'x64'
                    MediaType = 'NULL'
                    Uri = '<NotUsedButCannotBeEmpty>'
                    CustomData = @{
                        DiskType = 'Fixed'
                        DiskSize = 10GB
                    }
                }
            );
        };
    };
};
