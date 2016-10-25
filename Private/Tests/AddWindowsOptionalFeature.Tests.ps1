Describe 'AddWindowsOptionalFeature Tests' {

   Context 'Parameters for AddWindowsOptionalFeature'{

        It 'Has a Parameter called ImagePath' {
            $Function.Parameters.Keys.Contains('ImagePath') | Should Be 'True'
            }
        It 'ImagePath Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.ImagePath.Attributes.Mandatory | Should be 'True'
            }
        It 'ImagePath Parameter is of String Type' {
            $Function.Parameters.ImagePath.ParameterType.FullName | Should be 'System.String'
            }
        It 'ImagePath Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ImagePath.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'ImagePath Parameter Position is defined correctly' {
            [String]$Function.Parameters.ImagePath.Attributes.Position | Should be '0'
            }
        It 'Does ImagePath Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ImagePath.Attributes.ValueFromPipeline | Should be 'True'
            }
        It 'Does ImagePath Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ImagePath.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does ImagePath Parameter use advanced parameter Validation? ' {
            $Function.Parameters.ImagePath.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.ImagePath.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.ImagePath.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.ImagePath.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.ImagePath.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for ImagePath '{
            $function.Definition.Contains('.PARAMETER ImagePath') | Should Be 'True'
            }
        It 'Has a Parameter called DestinationPath' {
            $Function.Parameters.Keys.Contains('DestinationPath') | Should Be 'True'
            }
        It 'DestinationPath Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.DestinationPath.Attributes.Mandatory | Should be 'True'
            }
        It 'DestinationPath Parameter is of String Type' {
            $Function.Parameters.DestinationPath.ParameterType.FullName | Should be 'System.String'
            }
        It 'DestinationPath Parameter is member of ParameterSets' {
            [String]$Function.Parameters.DestinationPath.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'DestinationPath Parameter Position is defined correctly' {
            [String]$Function.Parameters.DestinationPath.Attributes.Position | Should be '1'
            }
        It 'Does DestinationPath Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.DestinationPath.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does DestinationPath Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.DestinationPath.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does DestinationPath Parameter use advanced parameter Validation? ' {
            $Function.Parameters.DestinationPath.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.DestinationPath.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.DestinationPath.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.DestinationPath.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.DestinationPath.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for DestinationPath '{
            $function.Definition.Contains('.PARAMETER DestinationPath') | Should Be 'True'
            }
        It 'Has a Parameter called WindowsOptionalFeature' {
            $Function.Parameters.Keys.Contains('WindowsOptionalFeature') | Should Be 'True'
            }
        It 'WindowsOptionalFeature Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.WindowsOptionalFeature.Attributes.Mandatory | Should be 'True'
            }
        It 'WindowsOptionalFeature Parameter is of String[] Type' {
            $Function.Parameters.WindowsOptionalFeature.ParameterType.FullName | Should be 'System.String[]'
            }
        It 'WindowsOptionalFeature Parameter is member of ParameterSets' {
            [String]$Function.Parameters.WindowsOptionalFeature.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'WindowsOptionalFeature Parameter Position is defined correctly' {
            [String]$Function.Parameters.WindowsOptionalFeature.Attributes.Position | Should be '2'
            }
        It 'Does WindowsOptionalFeature Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.WindowsOptionalFeature.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does WindowsOptionalFeature Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.WindowsOptionalFeature.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does WindowsOptionalFeature Parameter use advanced parameter Validation? ' {
            $Function.Parameters.WindowsOptionalFeature.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.WindowsOptionalFeature.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'True'
            $Function.Parameters.WindowsOptionalFeature.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.WindowsOptionalFeature.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.WindowsOptionalFeature.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for WindowsOptionalFeature '{
            $function.Definition.Contains('.PARAMETER WindowsOptionalFeature') | Should Be 'True'
            }
        It 'Has a Parameter called LogPath' {
            $Function.Parameters.Keys.Contains('LogPath') | Should Be 'True'
            }
        It 'LogPath Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.LogPath.Attributes.Mandatory | Should be 'False'
            }
        It 'LogPath Parameter is of String Type' {
            $Function.Parameters.LogPath.ParameterType.FullName | Should be 'System.String'
            }
        It 'LogPath Parameter is member of ParameterSets' {
            [String]$Function.Parameters.LogPath.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'LogPath Parameter Position is defined correctly' {
            [String]$Function.Parameters.LogPath.Attributes.Position | Should be '3'
            }
        It 'Does LogPath Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.LogPath.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does LogPath Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.LogPath.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does LogPath Parameter use advanced parameter Validation? ' {
            $Function.Parameters.LogPath.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.LogPath.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.LogPath.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.LogPath.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.LogPath.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for LogPath '{
            $function.Definition.Contains('.PARAMETER LogPath') | Should Be 'True'
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


