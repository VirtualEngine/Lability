Describe 'AddWindowsPackage Tests' {

   Context 'Parameters for AddWindowsPackage'{

        It 'Has a Parameter called Package' {
            $Function.Parameters.Keys.Contains('Package') | Should Be 'True'
            }
        It 'Package Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.Package.Attributes.Mandatory | Should be 'True'
            }
        It 'Package Parameter is of String[] Type' {
            $Function.Parameters.Package.ParameterType.FullName | Should be 'System.String[]'
            }
        It 'Package Parameter is member of ParameterSets' {
            [String]$Function.Parameters.Package.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'Package Parameter Position is defined correctly' {
            [String]$Function.Parameters.Package.Attributes.Position | Should be '0'
            }
        It 'Does Package Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.Package.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does Package Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.Package.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does Package Parameter use advanced parameter Validation? ' {
            $Function.Parameters.Package.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'False'
            $Function.Parameters.Package.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'True'
            $Function.Parameters.Package.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.Package.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.Package.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for Package '{
            $function.Definition.Contains('.PARAMETER Package') | Should Be 'True'
            }
        It 'Has a Parameter called PackagePath' {
            $Function.Parameters.Keys.Contains('PackagePath') | Should Be 'True'
            }
        It 'PackagePath Parameter is Identified as Mandatory being True' {
            [String]$Function.Parameters.PackagePath.Attributes.Mandatory | Should be 'True'
            }
        It 'PackagePath Parameter is of String Type' {
            $Function.Parameters.PackagePath.ParameterType.FullName | Should be 'System.String'
            }
        It 'PackagePath Parameter is member of ParameterSets' {
            [String]$Function.Parameters.PackagePath.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'PackagePath Parameter Position is defined correctly' {
            [String]$Function.Parameters.PackagePath.Attributes.Position | Should be '1'
            }
        It 'Does PackagePath Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.PackagePath.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does PackagePath Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.PackagePath.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does PackagePath Parameter use advanced parameter Validation? ' {
            $Function.Parameters.PackagePath.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.PackagePath.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.PackagePath.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.PackagePath.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.PackagePath.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for PackagePath '{
            $function.Definition.Contains('.PARAMETER PackagePath') | Should Be 'True'
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
            [String]$Function.Parameters.DestinationPath.Attributes.Position | Should be '2'
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
        It 'Has a Parameter called PackageLocale' {
            $Function.Parameters.Keys.Contains('PackageLocale') | Should Be 'True'
            }
        It 'PackageLocale Parameter is Identified as Mandatory being False' {
            [String]$Function.Parameters.PackageLocale.Attributes.Mandatory | Should be 'False'
            }
        It 'PackageLocale Parameter is of String Type' {
            $Function.Parameters.PackageLocale.ParameterType.FullName | Should be 'System.String'
            }
        It 'PackageLocale Parameter is member of ParameterSets' {
            [String]$Function.Parameters.PackageLocale.ParameterSets.Keys | Should Be '__AllParameterSets'
            }
        It 'PackageLocale Parameter Position is defined correctly' {
            [String]$Function.Parameters.PackageLocale.Attributes.Position | Should be '3'
            }
        It 'Does PackageLocale Parameter Accept Pipeline Input?' {
            [String]$Function.Parameters.PackageLocale.Attributes.ValueFromPipeline | Should be 'False'
            }
        It 'Does PackageLocale Parameter Accept Pipeline Input by PropertyName?' {
            [String]$Function.Parameters.PackageLocale.Attributes.ValueFromPipelineByPropertyName | Should be 'True'
            }
        It 'Does PackageLocale Parameter use advanced parameter Validation? ' {
            $Function.Parameters.PackageLocale.Attributes.TypeID.Name -contains 'ValidateNotNullOrEmptyAttribute' | Should Be 'True'
            $Function.Parameters.PackageLocale.Attributes.TypeID.Name -contains 'ValidateNotNullAttribute' | Should Be 'False'
            $Function.Parameters.PackageLocale.Attributes.TypeID.Name -contains 'ValidateScript' | Should Be 'False'
            $Function.Parameters.PackageLocale.Attributes.TypeID.Name -contains 'ValidateRangeAttribute' | Should Be 'False'
            $Function.Parameters.PackageLocale.Attributes.TypeID.Name -contains 'ValidatePatternAttribute' | Should Be 'False'
            }
        It 'Has Parameter Help Text for PackageLocale '{
            $function.Definition.Contains('.PARAMETER PackageLocale') | Should Be 'True'
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
            [String]$Function.Parameters.LogPath.Attributes.Position | Should be '4'
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


