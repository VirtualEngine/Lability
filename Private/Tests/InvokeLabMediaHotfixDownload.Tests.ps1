Describe 'InvokeLabMediaHotfixDownload Tests' {

   Context 'Parameters for InvokeLabMediaHotfixDownload'{

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
            [String]$Function.Parameters.Id.Attributes.ValueFromPipelineByPropertyName | Should be 'False'
            }
        It 'Does Id Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Id.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.Id.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Id.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Id.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Id.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Id '{
            $function.Definition.Contains('.PARAMETER Id') | Should Be 'True'
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
            $Function.Parameters.Checksum.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.Checksum.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.Checksum.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Checksum.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Checksum.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Checksum '{
            $function.Definition.Contains('.PARAMETER Checksum') | Should Be 'True'
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


