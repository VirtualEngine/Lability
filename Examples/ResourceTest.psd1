@{
    AllNodes = @(
        @{
            NodeName = 'RESOURCETEST';
            Resource = 'MSAzureBackup';
        }
    );
    NonNodeData = @{
        Lability = @{
            Resource = @(
                @{
                    Id = 'MSAzureBackup';
                    Filename = 'MSAzureBackup.zip';
                    Checksum = '';
                    Expand = $true;
                    DestinationPath = '\Resources'
                }
            )
        };
    };
};
