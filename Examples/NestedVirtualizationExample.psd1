@{
    AllNodes = @(
        @{
            NodeName                 = 'NESTEDHYPERV';
            Lability_StartupMemory   = 4GB;
            Lability_ProcessorCount  = 2;
            Lability_Media           = 'WIN10_x64_Enterprise_EN_Eval';
            Lability_ProcessorOption = @{
                ## Enable nested virtualization feature using xVMProcessor
                ExposeVirtualizationExtensions = $true;
            }
        }
    );
};
