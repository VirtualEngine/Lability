Describe 'TestResourceDownload Tests' {

   Context 'Parameters for TestResourceDownload'{

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
            [String]$Function.Parameters.DestinationPath.Attributes.Position | Should be '0'
            }
        It 'Does DestinationPath Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.DestinationPath.Attributes.ValueFromPipeline | Should be 'True'
            }
        It 'Does DestinationPath Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.DestinationPath.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
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
        It 'Has a Parameter called Uri' {
            $Function.Parameters.Keys.Contains('Uri') | Should Be 'True'
            }
        It 'Uri Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.Uri.Attributes.Mandatory | Should be 'True'
            }
        It 'Uri Parameter is of String Type' {
            $Function.Parameters.Uri.ParameterType.FullName | Should be 'System.String'
            }
        It 'Uri Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Uri.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Uri Parameter Position is defined correctly' {
            [String]$Function.Parameters.Uri.Attributes.Position | Should be '1'
            }
        It 'Does Uri Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Uri.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Uri Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Uri.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Uri Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Uri.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.Uri.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Uri.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Uri.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Uri.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Uri '{
            $function.Definition.Contains('.PARAMETER Uri') | Should Be 'True'
            }
        It 'Has a Parameter called Checksum' {
            $Function.Parameters.Keys.Contains('Checksum') | Should Be 'True'
            }
        It 'Checksum Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.Checksum.Attributes.Mandatory | Should be 'False'
            }
        It 'Checksum Parameter is of String Type' {
            $Function.Parameters.Checksum.ParameterType.FullName | Should be 'System.String'
            }
        It 'Checksum Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Checksum.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Checksum Parameter Position is defined correctly' {
            [String]$Function.Parameters.Checksum.Attributes.Position | Should be '2'
            }
        It 'Does Checksum Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Checksum.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Checksum Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Checksum.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Checksum Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Checksum.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Checksum.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Checksum.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Checksum.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Checksum.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Checksum '{
            $function.Definition.Contains('.PARAMETER Checksum') | Should Be 'True'
            }
        It 'Has a Parameter called BufferSize' {
            $Function.Parameters.Keys.Contains('BufferSize') | Should Be 'True'
            }
        It 'BufferSize Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.BufferSize.Attributes.Mandatory | Should be 'False'
            }
        It 'BufferSize Parameter is of UInt32 Type' {
            $Function.Parameters.BufferSize.ParameterType.FullName | Should be 'System.UInt32'
            }
        It 'BufferSize Parameter is member of ParameterSets' {
            [String]$Function.Parameters.BufferSize.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'BufferSize Parameter Position is defined correctly' {
            [String]$Function.Parameters.BufferSize.Attributes.Position | Should be '3'
            }
        It 'Does BufferSize Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.BufferSize.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does BufferSize Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.BufferSize.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does BufferSize Parameter use advanced parameter Validation? ' {
            $Function.Parameters.BufferSize.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.BufferSize.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.BufferSize.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.BufferSize.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.BufferSize.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for BufferSize '{
            $function.Definition.Contains('.PARAMETER BufferSize') | Should Be 'True'
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


