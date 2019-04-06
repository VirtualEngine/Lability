#requires -Version 4

$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;
Describe 'Linting\PSScriptAnalyzer' {

    Get-ChildItem -Path "$repoRoot\Src" -Recurse -File | ForEach-Object {
        It "File '$($_.Name)' passes PSScriptAnalyzer rules" {
            $result = Invoke-ScriptAnalyzer -Path $_.FullName -Severity Warning | Select-Object -ExpandProperty Message
            $result | Should BeNullOrEmpty
        }
    }
}
