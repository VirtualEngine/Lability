Describe 'Import-LabHostConfiguration Tests' {

   Context 'Parameters for Import-LabHostConfiguration'{

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
            [String]$Function.Parameters.Path.ParameterSets.Keys | Should Be 'Path'
            }
        It 'Path Parameter Position is defined correctly' {
            [String]$Function.Parameters.Path.Attributes.Position | Should be '-2147483648'
            }
        It 'Does Path Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Path.Attributes.ValueFromPipeline | Should be 'True'
            }
        It 'Does Path Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Path.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
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
        It 'Has a Parameter called LiteralPath' {
            $Function.Parameters.Keys.Contains('LiteralPath') | Should Be 'True'
            }
        It 'LiteralPath Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.LiteralPath.Attributes.Mandatory | Should be 'True'
            }
        It 'LiteralPath Parameter is of String Type' {
            $Function.Parameters.LiteralPath.ParameterType.FullName | Should be 'System.String'
            }
        It 'LiteralPath Parameter is member of ParameterSets' {
            [String]$Function.Parameters.LiteralPath.ParameterSets.Keys | Should Be 'LiteralPath'
            }
        It 'LiteralPath Parameter Position is defined correctly' {
            [String]$Function.Parameters.LiteralPath.Attributes.Position | Should be '-2147483648'
            }
        It 'Does LiteralPath Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.LiteralPath.Attributes.ValueFromPipeline | Should be 'True'
            }
        It 'Does LiteralPath Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.LiteralPath.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does LiteralPath Parameter use advanced parameter Validation? ' {
            $Function.Parameters.LiteralPath.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.LiteralPath.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.LiteralPath.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.LiteralPath.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.LiteralPath.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for LiteralPath '{
            $function.Definition.Contains('.PARAMETER LiteralPath') | Should Be 'True'
            }
        It 'Has a Parameter called Host' {
            $Function.Parameters.Keys.Contains('Host') | Should Be 'True'
            }
        It 'Host Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.Host.Attributes.Mandatory | Should be 'False'
            }
        It 'Host Parameter is of SwitchParameter Type' {
            $Function.Parameters.Host.ParameterType.FullName | Should be 'System.Management.Automation.SwitchParameter'
            }
        It 'Host Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Host.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Host Parameter Position is defined correctly' {
            [String]$Function.Parameters.Host.Attributes.Position | Should be '-2147483648'
            }
        It 'Does Host Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Host.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Host Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Host.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Host Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Host.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Host.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Host.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Host.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Host.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Host '{
            $function.Definition.Contains('.PARAMETER Host') | Should Be 'True'
            }
        It 'Has a Parameter called VM' {
            $Function.Parameters.Keys.Contains('VM') | Should Be 'True'
            }
        It 'VM Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.VM.Attributes.Mandatory | Should be 'False'
            }
        It 'VM Parameter is of SwitchParameter Type' {
            $Function.Parameters.VM.ParameterType.FullName | Should be 'System.Management.Automation.SwitchParameter'
            }
        It 'VM Parameter is member of ParameterSets' {
            [String]$Function.Parameters.VM.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'VM Parameter Position is defined correctly' {
            [String]$Function.Parameters.VM.Attributes.Position | Should be '-2147483648'
            }
        It 'Does VM Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.VM.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does VM Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.VM.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does VM Parameter use advanced parameter Validation? ' {
            $Function.Parameters.VM.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.VM.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.VM.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.VM.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.VM.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for VM '{
            $function.Definition.Contains('.PARAMETER VM') | Should Be 'True'
            }
        It 'Has a Parameter called Media' {
            $Function.Parameters.Keys.Contains('Media') | Should Be 'True'
            }
        It 'Media Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.Media.Attributes.Mandatory | Should be 'False'
            }
        It 'Media Parameter is of SwitchParameter Type' {
            $Function.Parameters.Media.ParameterType.FullName | Should be 'System.Management.Automation.SwitchParameter'
            }
        It 'Media Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Media.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Media Parameter Position is defined correctly' {
            [String]$Function.Parameters.Media.Attributes.Position | Should be '-2147483648'
            }
        It 'Does Media Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Media.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Media Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Media.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Media Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Media.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Media.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Media.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Media.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Media.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Media '{
            $function.Definition.Contains('.PARAMETER Media') | Should Be 'True'
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


