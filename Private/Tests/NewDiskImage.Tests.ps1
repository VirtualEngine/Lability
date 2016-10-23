Describe 'NewDiskImage Tests' {

   Context 'Parameters for NewDiskImage'{

        It 'Has a Parameter called Path' {
            $Function.Parameters.Keys.Contains('Path') | Should Be 'True'
            }
        It 'Path Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.Path.Attributes.Mandatory | Should be 'True'
            }
        It 'Path Parameter is of String Type' {
            $Function.Parameters.Path.ParameterType.FullName | Should be 'System.String'
            }
        It 'Path Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Path.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Path Parameter Position is defined correctly' {
            [String]$Function.Parameters.Path.Attributes.Position | Should be '0'
            }
        It 'Does Path Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Path.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Path Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Path.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does Path Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Path.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.Path.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Path.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Path.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Path.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Path '{
            $function.Definition.Contains('.PARAMETER Path') | Should Be 'True'
            }
        It 'Has a Parameter called PartitionStyle' {
            $Function.Parameters.Keys.Contains('PartitionStyle') | Should Be 'True'
            }
        It 'PartitionStyle Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.PartitionStyle.Attributes.Mandatory | Should be 'True'
            }
        It 'PartitionStyle Parameter is of String Type' {
            $Function.Parameters.PartitionStyle.ParameterType.FullName | Should be 'System.String'
            }
        It 'PartitionStyle Parameter is member of ParameterSets' {
            [String]$Function.Parameters.PartitionStyle.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'PartitionStyle Parameter Position is defined correctly' {
            [String]$Function.Parameters.PartitionStyle.Attributes.Position | Should be '1'
            }
        It 'Does PartitionStyle Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.PartitionStyle.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does PartitionStyle Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.PartitionStyle.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does PartitionStyle Parameter use advanced parameter Validation? ' {
            $Function.Parameters.PartitionStyle.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.PartitionStyle.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.PartitionStyle.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.PartitionStyle.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.PartitionStyle.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for PartitionStyle '{
            $function.Definition.Contains('.PARAMETER PartitionStyle') | Should Be 'True'
            }
        It 'Has a Parameter called Size' {
            $Function.Parameters.Keys.Contains('Size') | Should Be 'True'
            }
        It 'Size Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.Size.Attributes.Mandatory | Should be 'False'
            }
        It 'Size Parameter is of UInt64 Type' {
            $Function.Parameters.Size.ParameterType.FullName | Should be 'System.UInt64'
            }
        It 'Size Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Size.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Size Parameter Position is defined correctly' {
            [String]$Function.Parameters.Size.Attributes.Position | Should be '2'
            }
        It 'Does Size Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Size.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Size Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Size.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does Size Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Size.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Size.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Size.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Size.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Size.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Size '{
            $function.Definition.Contains('.PARAMETER Size') | Should Be 'True'
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
        It 'Has a Parameter called Passthru' {
            $Function.Parameters.Keys.Contains('Passthru') | Should Be 'True'
            }
        It 'Passthru Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.Passthru.Attributes.Mandatory | Should be 'False'
            }
        It 'Passthru Parameter is of SwitchParameter Type' {
            $Function.Parameters.Passthru.ParameterType.FullName | Should be 'System.Management.Automation.SwitchParameter'
            }
        It 'Passthru Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Passthru.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Passthru Parameter Position is defined correctly' {
            [String]$Function.Parameters.Passthru.Attributes.Position | Should be '-2147483648'
            }
        It 'Does Passthru Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Passthru.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Passthru Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Passthru.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does Passthru Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Passthru.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Passthru.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Passthru.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Passthru.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Passthru.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Passthru '{
            $function.Definition.Contains('.PARAMETER Passthru') | Should Be 'True'
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


