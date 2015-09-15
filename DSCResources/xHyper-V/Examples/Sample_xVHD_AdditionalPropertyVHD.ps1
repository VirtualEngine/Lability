configuration Sample_xVHD_AdditionalPropertyVHD
{
    param
    (
        [Parameter(Mandatory)]
        [string]$Name,
        
        [Parameter(Mandatory)]
        [string]$Path,
        
        [Parameter(Mandatory)]
        [string]$ParentPath,

        [Parameter(Mandatory)]
        [string]$MaximumSizeBytes,
        
        [ValidateSet("Vhd","Vhdx")]
        [string]$Generation = "Vhd",

        [ValidateSet("Present","Absent")]
        [string]$Ensure = "Present"    
    )

    Import-DscResource -Module xHyper-V

    Node localhost
    {
        xVHD WrongVHD
        {
            Ensure           = $Ensure
            Name             = $Name
            Path             = $Path
            ParentPath       = $ParentPath
            MaximumSizeBytes = $MaximumSizeBytes
            Generation       = $Generation
        }
    }
}
