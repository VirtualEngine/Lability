@{
    AllNodes = @(
        @{
            NodeName = '2012R2GEN1';
            Lability_ProcessorCount = 2;
            Lability_Media = '2016_x64_Standard_EN_Eval_Gen1';
        }
    );
    NonNodeData = @{
        Lability = @{
            Media = @(
                @{
                    Id = '2016_x64_Standard_EN_Eval_Gen1';
                    Filename = '2016_x64_EN_Eval.iso';
                    Description = 'Windows Server 2016 Standard 64bit English Evaluation MBR';
                    Architecture = 'x64';
                    ImageName = 'Windows Server 2016 SERVERSTANDARD';
	                MediaType = 'ISO';
                    OperatingSystem = 'Windows';
                    Uri = 'http://download.microsoft.com/download/1/6/F/16FA20E6-4662-482A-920B-1A45CF5AAE3C/14393.0.160715-1616.RS1_RELEASE_SERVER_EVAL_X64FRE_EN-US.ISO';
	                Checksum = '18A4F00A675B0338F3C7C93C4F131BEB';
                    CustomData = @{
		                ## Ensure the disk is partitioned with a master boot record
                        PartitionStyle = 'MBR';
		                WindowsOptionalFeature = 'NetFx3';
                        ## Override the VM generation
		                VmGeneration = 1;
                    }
                }
            );
        };
    };
};
