Describe 'ResolveLabVMProperties Tests' {

   Context 'Parameters for ResolveLabVMProperties'{

        It 'Has a Parameter called NodeName' {
            $Function.Parameters.Keys.Contains('NodeName') | Should Be 'True'
            }
        It 'NodeName Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.NodeName.Attributes.Mandatory | Should be 'True'
            }
        It 'NodeName Parameter is of String Type' {
            $Function.Parameters.NodeName.ParameterType.FullName | Should be 'System.String'
            }
        It 'NodeName Parameter is member of ParameterSets' {
            [String]$Function.Parameters.NodeName.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'NodeName Parameter Position is defined correctly' {
            [String]$Function.Parameters.NodeName.Attributes.Position | Should be '0'
            }
        It 'Does NodeName Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.NodeName.Attributes.ValueFromPipeline | Should be 'True'
            }
        It 'Does NodeName Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.NodeName.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does NodeName Parameter use advanced parameter Validation? ' {
            $Function.Parameters.NodeName.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.NodeName.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.NodeName.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.NodeName.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.NodeName.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for NodeName '{
            $function.Definition.Contains('.PARAMETER NodeName') | Should Be 'True'
            }
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
            [String]$Function.Parameters.ConfigurationData.Attributes.Position | Should be '1'
            }
        It 'Does ConfigurationData Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ConfigurationData.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does ConfigurationData Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ConfigurationData.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
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
        It 'Has a Parameter called NoEnumerateWildcardNode' {
            $Function.Parameters.Keys.Contains('NoEnumerateWildcardNode') | Should Be 'True'
            }
        It 'NoEnumerateWildcardNode Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.NoEnumerateWildcardNode.Attributes.Mandatory | Should be 'False'
            }
        It 'NoEnumerateWildcardNode Parameter is of SwitchParameter Type' {
            $Function.Parameters.NoEnumerateWildcardNode.ParameterType.FullName | Should be 'System.Management.Automation.SwitchParameter'
            }
        It 'NoEnumerateWildcardNode Parameter is member of ParameterSets' {
            [String]$Function.Parameters.NoEnumerateWildcardNode.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'NoEnumerateWildcardNode Parameter Position is defined correctly' {
            [String]$Function.Parameters.NoEnumerateWildcardNode.Attributes.Position | Should be '-2147483648'
            }
        It 'Does NoEnumerateWildcardNode Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.NoEnumerateWildcardNode.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does NoEnumerateWildcardNode Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.NoEnumerateWildcardNode.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does NoEnumerateWildcardNode Parameter use advanced parameter Validation? ' {
            $Function.Parameters.NoEnumerateWildcardNode.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.NoEnumerateWildcardNode.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.NoEnumerateWildcardNode.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.NoEnumerateWildcardNode.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.NoEnumerateWildcardNode.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for NoEnumerateWildcardNode '{
            $function.Definition.Contains('.PARAMETER NoEnumerateWildcardNode') | Should Be 'True'
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


