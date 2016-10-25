Describe 'Checkpoint-Lab Tests' {

   Context 'Parameters for Checkpoint-Lab'{

        It 'Has a Parameter called ConfigurationData' {
            $Function.Parameters.Keys.Contains('ConfigurationData') | Should Be 'True'
            }
        It 'ConfigurationData Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.ConfigurationData.Attributes.Mandatory | Should be 'True'
            }
        It 'ConfigurationData Parameter is of Hashtable Type' {
            $Function.Parameters.ConfigurationData.ParameterType.FullName | Should be 'System.Collections.Hashtable'
            }
        It 'ConfigurationData Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ConfigurationData.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'ConfigurationData Parameter Position is defined correctly' {
            [String]$Function.Parameters.ConfigurationData.Attributes.Position | Should be '0'
            }
        It 'Does ConfigurationData Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ConfigurationData.Attributes.ValueFromPipeline | Should be 'True'
            }
        It 'Does ConfigurationData Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ConfigurationData.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does ConfigurationData Parameter use advanced parameter Validation? ' {
            $Function.Parameters.ConfigurationData.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.ConfigurationData.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.ConfigurationData.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.ConfigurationData.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.ConfigurationData.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for ConfigurationData '{
            $function.Definition.Contains('.PARAMETER ConfigurationData') | Should Be 'True'
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
            [String]$Function.Parameters.SnapshotName.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does SnapshotName Parameter use advanced parameter Validation? ' {
            $Function.Parameters.SnapshotName.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.SnapshotName.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.SnapshotName.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.SnapshotName.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.SnapshotName.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for SnapshotName '{
            $function.Definition.Contains('.PARAMETER SnapshotName') | Should Be 'True'
            }
        It 'Has a Parameter called Force' {
            $Function.Parameters.Keys.Contains('Force') | Should Be 'True'
            }
        It 'Force Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.Force.Attributes.Mandatory | Should be 'False'
            }
        It 'Force Parameter is of SwitchParameter Type' {
            $Function.Parameters.Force.ParameterType.FullName | Should be 'System.Management.Automation.SwitchParameter'
            }
        It 'Force Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Force.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Force Parameter Position is defined correctly' {
            [String]$Function.Parameters.Force.Attributes.Position | Should be '-2147483648'
            }
        It 'Does Force Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Force.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Force Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Force.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does Force Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Force.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Force.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Force.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Force.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Force.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Force '{
            $function.Definition.Contains('.PARAMETER Force') | Should Be 'True'
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


