Describe 'GetWindowsImageName Tests' {

   Context 'Parameters for GetWindowsImageName'{

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
        It 'Has a Parameter called ImageIndex' {
            $Function.Parameters.Keys.Contains('ImageIndex') | Should Be 'True'
            }
        It 'ImageIndex Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.ImageIndex.Attributes.Mandatory | Should be 'True'
            }
        It 'ImageIndex Parameter is of Int32 Type' {
            $Function.Parameters.ImageIndex.ParameterType.FullName | Should be 'System.Int32'
            }
        It 'ImageIndex Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ImageIndex.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'ImageIndex Parameter Position is defined correctly' {
            [String]$Function.Parameters.ImageIndex.Attributes.Position | Should be '1'
            }
        It 'Does ImageIndex Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.ImageIndex.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does ImageIndex Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.ImageIndex.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does ImageIndex Parameter use advanced parameter Validation? ' {
            $Function.Parameters.ImageIndex.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.ImageIndex.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.ImageIndex.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.ImageIndex.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.ImageIndex.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for ImageIndex '{
            $function.Definition.Contains('.PARAMETER ImageIndex') | Should Be 'True'
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


