@{
    AllNodes = @(
        @{
            NodeName = '2012R2';

            ## Array (list) of modules to inject into the VHD(X). If left empty,
            ## all modules defined in the NonNodeData\Lability\Module node will be copied.
            Lability_Module = 'PScribo';
        }
    );
    NonNodeData = @{
        Lability = @{
            ## The Module node follows the same schema as the DSCResource node (essentially they're the same!)
            Module = @(
                ## Downloads the latest published module version from the PowerShell Gallery
                @{ Name = 'PScribo' }
                ## Downloads the development branch of the Lability module directly from Github
                @{ Name = 'Lability'; Provider = 'GitHub'; Owner = 'VirtualEngine'; Branch = 'dev'; }
            )
        };
    };
};
