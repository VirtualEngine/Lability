Describe 'GetDiskImageDriveLetter Tests' {

   Context 'Parameters for GetDiskImageDriveLetter'{

        It 'Has a Parameter called DiskImage' {
            $Function.Parameters.Keys.Contains('DiskImage') | Should Be 'True'
            }
        It 'DiskImage Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.DiskImage.Attributes.Mandatory | Should be 'True'
            }
        It 'DiskImage Parameter is of Object Type' {
            $Function.Parameters.DiskImage.ParameterType.FullName | Should be 'System.Object'
            }
        It 'DiskImage Parameter is member of ParameterSets' {
            [String]$Function.Parameters.DiskImage.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'DiskImage Parameter Position is defined correctly' {
            [String]$Function.Parameters.DiskImage.Attributes.Position | Should be '0'
            }
        It 'Does DiskImage Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.DiskImage.Attributes.ValueFromPipeline | Should be 'True'
            }
        It 'Does DiskImage Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.DiskImage.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does DiskImage Parameter use advanced parameter Validation? ' {
            $Function.Parameters.DiskImage.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.DiskImage.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.DiskImage.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.DiskImage.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.DiskImage.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for DiskImage '{
            $function.Definition.Contains('.PARAMETER DiskImage') | Should Be 'True'
            }
        It 'Has a Parameter called PartitionType' {
            $Function.Parameters.Keys.Contains('PartitionType') | Should Be 'True'
            }
        It 'PartitionType Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.PartitionType.Attributes.Mandatory | Should be 'True'
            }
        It 'PartitionType Parameter is of String Type' {
            $Function.Parameters.PartitionType.ParameterType.FullName | Should be 'System.String'
            }
        It 'PartitionType Parameter is member of ParameterSets' {
            [String]$Function.Parameters.PartitionType.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'PartitionType Parameter Position is defined correctly' {
            [String]$Function.Parameters.PartitionType.Attributes.Position | Should be '1'
            }
        It 'Does PartitionType Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.PartitionType.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does PartitionType Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.PartitionType.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does PartitionType Parameter use advanced parameter Validation? ' {
            $Function.Parameters.PartitionType.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.PartitionType.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.PartitionType.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.PartitionType.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.PartitionType.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for PartitionType '{
            $function.Definition.Contains('.PARAMETER PartitionType') | Should Be 'True'
            }
    }
    Context "Function $($function.Name) - Help Section" {

            It "Function $($function.Name) Has show-help comment block" {

                $function.Definition.Contains('<#') | should be 'True'
                $function.Definition.Contains('#>') | should be 'True'
            }

            It "Function $($function.Name) Has show-help comment block has a.SYNOPSIS" {

                $function.Definition.Contains('.SYNOPSIS') -or $function.Definition.Contains('.Synopsis') | should be 'True'

            }

            It "Function $($function.Name) Has show-help comment block has an example" {

                $function.Definition.Contains('.EXAMPLE') | should be 'True'
            }

            It "Function $($function.Name) Is an advanced function" {

                $function.CmdletBinding | should be 'True'
                $function.Definition.Contains('param') -or  $function.Definition.Contains('Param') | should be 'True'
            }
    
    }

 }


