Describe 'NewLabVMSnapshot Tests' {

   Context 'Parameters for NewLabVMSnapshot'{

        It 'Has a Parameter called Name' {
            $Function.Parameters.Keys.Contains('Name') | Should Be 'True'
            }
        It 'Name Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.Name.Attributes.Mandatory | Should be 'True'
            }
        It 'Name Parameter is of String[] Type' {
            $Function.Parameters.Name.ParameterType.FullName | Should be 'System.String[]'
            }
        It 'Name Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Name.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Name Parameter Position is defined correctly' {
            [String]$Function.Parameters.Name.Attributes.Position | Should be '0'
            }
        It 'Does Name Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Name.Attributes.ValueFromPipeline | Should be 'True'
            }
        It 'Does Name Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Name.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does Name Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Name.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.Name.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Name.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Name.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Name.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Name '{
            $function.Definition.Contains('.PARAMETER Name') | Should Be 'True'
            }
        It 'Has a Parameter called SnapshotName' {
            $Function.Parameters.Keys.Contains('SnapshotName') | Should Be 'True'
            }
        It 'SnapshotName Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.SnapshotName.Attributes.Mandatory | Should be 'True'
            }
        It 'SnapshotName Parameter is of String Type' {
            $Function.Parameters.SnapshotName.ParameterType.FullName | Should be 'System.String'
            }
        It 'SnapshotName Parameter is member of ParameterSets' {
            [String]$Function.Parameters.SnapshotName.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'SnapshotName Parameter Position is defined correctly' {
            [String]$Function.Parameters.SnapshotName.Attributes.Position | Should be '1'
            }
        It 'Does SnapshotName Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.SnapshotName.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does SnapshotName Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.SnapshotName.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does SnapshotName Parameter use advanced parameter Validation? ' {
            $Function.Parameters.SnapshotName.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.SnapshotName.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.SnapshotName.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.SnapshotName.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.SnapshotName.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for SnapshotName '{
            $function.Definition.Contains('.PARAMETER SnapshotName') | Should Be 'True'
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


