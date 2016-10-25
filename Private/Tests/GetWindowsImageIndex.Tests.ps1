Describe 'GetWindowsImageIndex Tests' {

   Context 'Parameters for GetWindowsImageIndex'{

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
        It 'Has a Parameter called ImageName' {
            $Function.Parameters.Keys.Contains('ImageName') | Should Be 'True'
            }
        It 'ImageName Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.ImageName.Attributes.Mandatory | Should be 'True'
            }
        It 'ImageName Parameter is of String Type' {
            $Function.Parameters.ImageName.ParameterType.FullName | Should be 'System.String'
            }
        It 'ImageName Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ImageName.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'ImageName Parameter Position is defined correctly' {
            [String]$Function.Parameters.ImageName.Attributes.Position | Should be '1'
            }
        It 'Does ImageName Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ImageName.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does ImageName Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ImageName.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does ImageName Parameter use advanced parameter Validation? ' {
            $Function.Parameters.ImageName.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.ImageName.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.ImageName.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.ImageName.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.ImageName.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for ImageName '{
            $function.Definition.Contains('.PARAMETER ImageName') | Should Be 'True'
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


