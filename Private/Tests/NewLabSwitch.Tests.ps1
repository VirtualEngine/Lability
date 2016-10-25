Describe 'NewLabSwitch Tests' {

   Context 'Parameters for NewLabSwitch'{

        It 'Has a Parameter called Name' {
            $Function.Parameters.Keys.Contains('Name') | Should Be 'True'
            }
        It 'Name Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.Name.Attributes.Mandatory | Should be 'True'
            }
        It 'Name Parameter is of String Type' {
            $Function.Parameters.Name.ParameterType.FullName | Should be 'System.String'
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
        It 'Has a Parameter called Type' {
            $Function.Parameters.Keys.Contains('Type') | Should Be 'True'
            }
        It 'Type Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.Type.Attributes.Mandatory | Should be 'True'
            }
        It 'Type Parameter is of String Type' {
            $Function.Parameters.Type.ParameterType.FullName | Should be 'System.String'
            }
        It 'Type Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Type.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Type Parameter Position is defined correctly' {
            [String]$Function.Parameters.Type.Attributes.Position | Should be '1'
            }
        It 'Does Type Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Type.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Type Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Type.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Type Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Type.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Type.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Type.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Type.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Type.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Type '{
            $function.Definition.Contains('.PARAMETER Type') | Should Be 'True'
            }
        It 'Has a Parameter called NetAdapterName' {
            $Function.Parameters.Keys.Contains('NetAdapterName') | Should Be 'True'
            }
        It 'NetAdapterName Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.NetAdapterName.Attributes.Mandatory | Should be 'False'
            }
        It 'NetAdapterName Parameter is of String Type' {
            $Function.Parameters.NetAdapterName.ParameterType.FullName | Should be 'System.String'
            }
        It 'NetAdapterName Parameter is member of ParameterSets' {
            [String]$Function.Parameters.NetAdapterName.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'NetAdapterName Parameter Position is defined correctly' {
            [String]$Function.Parameters.NetAdapterName.Attributes.Position | Should be '2'
            }
        It 'Does NetAdapterName Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.NetAdapterName.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does NetAdapterName Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.NetAdapterName.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does NetAdapterName Parameter use advanced parameter Validation? ' {
            $Function.Parameters.NetAdapterName.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.NetAdapterName.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'True'
            $Function.Parameters.NetAdapterName.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.NetAdapterName.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.NetAdapterName.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for NetAdapterName '{
            $function.Definition.Contains('.PARAMETER NetAdapterName') | Should Be 'True'
            }
        It 'Has a Parameter called AllowManagementOS' {
            $Function.Parameters.Keys.Contains('AllowManagementOS') | Should Be 'True'
            }
        It 'AllowManagementOS Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.AllowManagementOS.Attributes.Mandatory | Should be 'False'
            }
        It 'AllowManagementOS Parameter is of Boolean Type' {
            $Function.Parameters.AllowManagementOS.ParameterType.FullName | Should be 'System.Boolean'
            }
        It 'AllowManagementOS Parameter is member of ParameterSets' {
            [String]$Function.Parameters.AllowManagementOS.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'AllowManagementOS Parameter Position is defined correctly' {
            [String]$Function.Parameters.AllowManagementOS.Attributes.Position | Should be '3'
            }
        It 'Does AllowManagementOS Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.AllowManagementOS.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does AllowManagementOS Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.AllowManagementOS.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does AllowManagementOS Parameter use advanced parameter Validation? ' {
            $Function.Parameters.AllowManagementOS.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.AllowManagementOS.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'True'
            $Function.Parameters.AllowManagementOS.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.AllowManagementOS.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.AllowManagementOS.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for AllowManagementOS '{
            $function.Definition.Contains('.PARAMETER AllowManagementOS') | Should Be 'True'
            }
        It 'Has a Parameter called Ensure' {
            $Function.Parameters.Keys.Contains('Ensure') | Should Be 'True'
            }
        It 'Ensure Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.Ensure.Attributes.Mandatory | Should be 'False'
            }
        It 'Ensure Parameter is of String Type' {
            $Function.Parameters.Ensure.ParameterType.FullName | Should be 'System.String'
            }
        It 'Ensure Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Ensure.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Ensure Parameter Position is defined correctly' {
            [String]$Function.Parameters.Ensure.Attributes.Position | Should be '4'
            }
        It 'Does Ensure Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Ensure.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Ensure Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Ensure.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Ensure Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Ensure.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Ensure.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Ensure.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Ensure.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Ensure.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Ensure '{
            $function.Definition.Contains('.PARAMETER Ensure') | Should Be 'True'
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


