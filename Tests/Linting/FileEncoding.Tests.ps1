$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;
Describe 'Linting\FileEncoding' {

    $excludedPaths = @(
                        '.git*',
                        '.vscode',
                        'DSCResources', # We'll take the public DSC resources as-is
                        'Release',
                        '*.png',
                        'TestResults.xml'
                    );

    Get-ChildItem -Path $repoRoot -Exclude $excludedPaths |
        ForEach-Object {
            Get-ChildItem -Path $_.FullName -Recurse |
                ForEach-Object {

                    ## Resolve-ProgramFilesFolder.ps1 contains Unicode characters
                    if (($_ -is [System.IO.FileInfo]) -and ($_.Name -ne 'Resolve-ProgramFilesFolder.ps1'))
                    {
                        It "File '$($_.FullName.Replace($repoRoot,''))' uses UTF-8 (no BOM) encoding" {
                            $encoding = (Get-FileEncoding -Path $_.FullName -WarningAction SilentlyContinue).HeaderName
                            $encoding | Should Be 'us-ascii'
                        }
                    }
                }
        }
}
