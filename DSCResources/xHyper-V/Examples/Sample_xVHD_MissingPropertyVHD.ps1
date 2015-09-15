configuration Sample_xVHD_MissingPropertyVHD
{
    param
    (
        [Parameter(Mandatory)]
        [string]$Name,
        
        [Parameter(Mandatory)]
        [string]$Path,
                
        [ValidateSet("Vhd","Vhdx")]
        [string]$Generation = "Vhd",

        [ValidateSet("Present","Absent")]
        [string]$Ensure = "Present"    
    )

    Import-DscResource -module xHyper-V

    Node localhost
    {
        xVHD WrongVHD
        {
            Ensure     = $Ensure
            Name       = $Name
            Path       = $Path
            Generation = $Generation
        }
    }
}
