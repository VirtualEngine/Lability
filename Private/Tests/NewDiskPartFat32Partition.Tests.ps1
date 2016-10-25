Describe 'NewDiskPartFat32Partition Tests' {

   Context 'Parameters for NewDiskPartFat32Partition'{

        It 'Has a Parameter called DiskNumber' {
            $Function.Parameters.Keys.Contains('DiskNumber') | Should Be 'True'
            }
        It 'DiskNumber Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.DiskNumber.Attributes.Mandatory | Should be 'True'
            }
        It 'DiskNumber Parameter is of Int32 Type' {
            $Function.Parameters.DiskNumber.ParameterType.FullName | Should be 'System.Int32'
            }
        It 'DiskNumber Parameter is member of ParameterSets' {
            [String]$Function.Parameters.DiskNumber.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'DiskNumber Parameter Position is defined correctly' {
            [String]$Function.Parameters.DiskNumber.Attributes.Position | Should be '0'
            }
        It 'Does DiskNumber Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.DiskNumber.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does DiskNumber Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.DiskNumber.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does DiskNumber Parameter use advanced parameter Validation? ' {
            $Function.Parameters.DiskNumber.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.DiskNumber.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.DiskNumber.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.DiskNumber.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.DiskNumber.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for DiskNumber '{
            $function.Definition.Contains('.PARAMETER DiskNumber') | Should Be 'True'
            }
        It 'Has a Parameter called PartitionNumber' {
            $Function.Parameters.Keys.Contains('PartitionNumber') | Should Be 'True'
            }
        It 'PartitionNumber Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.PartitionNumber.Attributes.Mandatory | Should be 'True'
            }
        It 'PartitionNumber Parameter is of Int32 Type' {
            $Function.Parameters.PartitionNumber.ParameterType.FullName | Should be 'System.Int32'
            }
        It 'PartitionNumber Parameter is member of ParameterSets' {
            [String]$Function.Parameters.PartitionNumber.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'PartitionNumber Parameter Position is defined correctly' {
            [String]$Function.Parameters.PartitionNumber.Attributes.Position | Should be '1'
            }
        It 'Does PartitionNumber Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.PartitionNumber.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does PartitionNumber Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.PartitionNumber.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does PartitionNumber Parameter use advanced parameter Validation? ' {
            $Function.Parameters.PartitionNumber.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.PartitionNumber.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.PartitionNumber.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.PartitionNumber.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.PartitionNumber.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for PartitionNumber '{
            $function.Definition.Contains('.PARAMETER PartitionNumber') | Should Be 'True'
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


