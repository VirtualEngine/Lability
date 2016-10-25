Describe 'Register-LabMedia Tests' {

   Context 'Parameters for Register-LabMedia'{

        It 'Has a Parameter called Id' {
            $Function.Parameters.Keys.Contains('Id') | Should Be 'True'
            }
        It 'Id Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.Id.Attributes.Mandatory | Should be 'True'
            }
        It 'Id Parameter is of String Type' {
            $Function.Parameters.Id.ParameterType.FullName | Should be 'System.String'
            }
        It 'Id Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Id.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Id Parameter Position is defined correctly' {
            [String]$Function.Parameters.Id.Attributes.Position | Should be '0'
            }
        It 'Does Id Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Id.Attributes.ValueFromPipeline | Should be 'True'
            }
        It 'Does Id Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Id.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Id Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Id.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Id.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Id.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Id.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Id.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Id '{
            $function.Definition.Contains('.PARAMETER Id') | Should Be 'True'
            }
        It 'Has a Parameter called MediaType' {
            $Function.Parameters.Keys.Contains('MediaType') | Should Be 'True'
            }
        It 'MediaType Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.MediaType.Attributes.Mandatory | Should be 'True'
            }
        It 'MediaType Parameter is of String Type' {
            $Function.Parameters.MediaType.ParameterType.FullName | Should be 'System.String'
            }
        It 'MediaType Parameter is member of ParameterSets' {
            [String]$Function.Parameters.MediaType.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'MediaType Parameter Position is defined correctly' {
            [String]$Function.Parameters.MediaType.Attributes.Position | Should be '1'
            }
        It 'Does MediaType Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.MediaType.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does MediaType Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.MediaType.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does MediaType Parameter use advanced parameter Validation? ' {
            $Function.Parameters.MediaType.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.MediaType.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.MediaType.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.MediaType.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.MediaType.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for MediaType '{
            $function.Definition.Contains('.PARAMETER MediaType') | Should Be 'True'
            }
        It 'Has a Parameter called Uri' {
            $Function.Parameters.Keys.Contains('Uri') | Should Be 'True'
            }
        It 'Uri Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.Uri.Attributes.Mandatory | Should be 'True'
            }
        It 'Uri Parameter is of Uri Type' {
            $Function.Parameters.Uri.ParameterType.FullName | Should be 'System.Uri'
            }
        It 'Uri Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Uri.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Uri Parameter Position is defined correctly' {
            [String]$Function.Parameters.Uri.Attributes.Position | Should be '2'
            }
        It 'Does Uri Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Uri.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Uri Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Uri.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Uri Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Uri.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Uri.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Uri.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Uri.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Uri.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Uri '{
            $function.Definition.Contains('.PARAMETER Uri') | Should Be 'True'
            }
        It 'Has a Parameter called Architecture' {
            $Function.Parameters.Keys.Contains('Architecture') | Should Be 'True'
            }
        It 'Architecture Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.Architecture.Attributes.Mandatory | Should be 'True'
            }
        It 'Architecture Parameter is of String Type' {
            $Function.Parameters.Architecture.ParameterType.FullName | Should be 'System.String'
            }
        It 'Architecture Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Architecture.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Architecture Parameter Position is defined correctly' {
            [String]$Function.Parameters.Architecture.Attributes.Position | Should be '3'
            }
        It 'Does Architecture Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Architecture.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Architecture Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Architecture.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Architecture Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Architecture.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Architecture.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Architecture.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Architecture.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Architecture.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Architecture '{
            $function.Definition.Contains('.PARAMETER Architecture') | Should Be 'True'
            }
        It 'Has a Parameter called Description' {
            $Function.Parameters.Keys.Contains('Description') | Should Be 'True'
            }
        It 'Description Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.Description.Attributes.Mandatory | Should be 'False'
            }
        It 'Description Parameter is of String Type' {
            $Function.Parameters.Description.ParameterType.FullName | Should be 'System.String'
            }
        It 'Description Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Description.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Description Parameter Position is defined correctly' {
            [String]$Function.Parameters.Description.Attributes.Position | Should be '4'
            }
        It 'Does Description Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Description.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Description Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Description.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Description Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Description.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.Description.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Description.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Description.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Description.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Description '{
            $function.Definition.Contains('.PARAMETER Description') | Should Be 'True'
            }
        It 'Has a Parameter called ImageName' {
            $Function.Parameters.Keys.Contains('ImageName') | Should Be 'True'
            }
        It 'ImageName Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.ImageName.Attributes.Mandatory | Should be 'False'
            }
        It 'ImageName Parameter is of String Type' {
            $Function.Parameters.ImageName.ParameterType.FullName | Should be 'System.String'
            }
        It 'ImageName Parameter is member of ParameterSets' {
            [String]$Function.Parameters.ImageName.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'ImageName Parameter Position is defined correctly' {
            [String]$Function.Parameters.ImageName.Attributes.Position | Should be '5'
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
        It 'Has a Parameter called Filename' {
            $Function.Parameters.Keys.Contains('Filename') | Should Be 'True'
            }
        It 'Filename Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.Filename.Attributes.Mandatory | Should be 'False'
            }
        It 'Filename Parameter is of String Type' {
            $Function.Parameters.Filename.ParameterType.FullName | Should be 'System.String'
            }
        It 'Filename Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Filename.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Filename Parameter Position is defined correctly' {
            [String]$Function.Parameters.Filename.Attributes.Position | Should be '6'
            }
        It 'Does Filename Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Filename.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Filename Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Filename.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Filename Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Filename.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.Filename.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Filename.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Filename.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Filename.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Filename '{
            $function.Definition.Contains('.PARAMETER Filename') | Should Be 'True'
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
            [String]$Function.Parameters.Checksum.Attributes.Position | Should be '7'
            }
        It 'Does Checksum Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Checksum.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Checksum Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Checksum.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Checksum Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Checksum.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.Checksum.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Checksum.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Checksum.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Checksum.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Checksum '{
            $function.Definition.Contains('.PARAMETER Checksum') | Should Be 'True'
            }
        It 'Has a Parameter called CustomData' {
            $Function.Parameters.Keys.Contains('CustomData') | Should Be 'True'
            }
        It 'CustomData Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.CustomData.Attributes.Mandatory | Should be 'False'
            }
        It 'CustomData Parameter is of Hashtable Type' {
            $Function.Parameters.CustomData.ParameterType.FullName | Should be 'System.Collections.Hashtable'
            }
        It 'CustomData Parameter is member of ParameterSets' {
            [String]$Function.Parameters.CustomData.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'CustomData Parameter Position is defined correctly' {
            [String]$Function.Parameters.CustomData.Attributes.Position | Should be '8'
            }
        It 'Does CustomData Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.CustomData.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does CustomData Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.CustomData.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does CustomData Parameter use advanced parameter Validation? ' {
            $Function.Parameters.CustomData.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.CustomData.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'True'
            $Function.Parameters.CustomData.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.CustomData.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.CustomData.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for CustomData '{
            $function.Definition.Contains('.PARAMETER CustomData') | Should Be 'True'
            }
        It 'Has a Parameter called Hotfixes' {
            $Function.Parameters.Keys.Contains('Hotfixes') | Should Be 'True'
            }
        It 'Hotfixes Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.Hotfixes.Attributes.Mandatory | Should be 'False'
            }
        It 'Hotfixes Parameter is of Hashtable[] Type' {
            $Function.Parameters.Hotfixes.ParameterType.FullName | Should be 'System.Collections.Hashtable[]'
            }
        It 'Hotfixes Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Hotfixes.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Hotfixes Parameter Position is defined correctly' {
            [String]$Function.Parameters.Hotfixes.Attributes.Position | Should be '9'
            }
        It 'Does Hotfixes Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Hotfixes.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Hotfixes Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Hotfixes.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Hotfixes Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Hotfixes.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Hotfixes.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'True'
            $Function.Parameters.Hotfixes.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Hotfixes.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Hotfixes.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Hotfixes '{
            $function.Definition.Contains('.PARAMETER Hotfixes') | Should Be 'True'
            }
        It 'Has a Parameter called OperatingSystem' {
            $Function.Parameters.Keys.Contains('OperatingSystem') | Should Be 'True'
            }
        It 'OperatingSystem Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.OperatingSystem.Attributes.Mandatory | Should be 'False'
            }
        It 'OperatingSystem Parameter is of String Type' {
            $Function.Parameters.OperatingSystem.ParameterType.FullName | Should be 'System.String'
            }
        It 'OperatingSystem Parameter is member of ParameterSets' {
            [String]$Function.Parameters.OperatingSystem.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'OperatingSystem Parameter Position is defined correctly' {
            [String]$Function.Parameters.OperatingSystem.Attributes.Position | Should be '10'
            }
        It 'Does OperatingSystem Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.OperatingSystem.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does OperatingSystem Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.OperatingSystem.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does OperatingSystem Parameter use advanced parameter Validation? ' {
            $Function.Parameters.OperatingSystem.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.OperatingSystem.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.OperatingSystem.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.OperatingSystem.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.OperatingSystem.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for OperatingSystem '{
            $function.Definition.Contains('.PARAMETER OperatingSystem') | Should Be 'True'
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
            [String]$Function.Parameters.Force.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
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


