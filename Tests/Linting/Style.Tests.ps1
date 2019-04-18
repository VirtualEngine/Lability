$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;

#Style rules based on Pester v. 4.0.2-rc2
Describe 'Linting\Style' -Tags "Style" {

    $excludedPaths = @(
                        '.git*',
                        '.vscode',
                        'DSCResources', # We'll take the public DSC resources as-is
                        'Release',
                        '*.png',
                        '*.jpg',
                        '*.docx',
                        '*.enc',
                        '*.dll',
                        '*.pfx',
                        '*.cer',
                        'appveyor-tools',
                        'TestResults.xml',
                        'Tests',
                        'Docs',
                        'PScriboExample.txt'
                    );

    function TestStylePath {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory, ValueFromPipeline)]
            [System.String] $Path,

            [System.String[]] $Exclude
        )
        process
        {
            Get-ChildItem -Path $Path -Exclude $Exclude |
                ForEach-Object {
                    if ($_ -is [System.IO.FileInfo])
                    {
                        It "File '$($_.FullName.Replace($repoRoot,''))' contains no trailing whitespace" {
                            $badLines = @(
                                $lines = [System.IO.File]::ReadAllLines($_.FullName)
                                $lineCount = $lines.Count

                                for ($i = 0; $i -lt $lineCount; $i++) {
                                    if ($lines[$i] -match '\s+$') {
                                        'File: {0}, Line: {1}' -f $_.FullName, ($i + 1)
                                    }
                                }
                            )

                            @($badLines).Count | Should Be 0
                        }

                        It "File '$($_.FullName.Replace($repoRoot,''))' ends with a newline" {

                            $string = [System.IO.File]::ReadAllText($_.FullName)
                            ($string.Length -gt 0 -and $string[-1] -ne "`n") | Should Be $false
                        }
                    }
                    elseif ($_ -is [System.IO.DirectoryInfo])
                    {
                        TestStylePath -Path $_.FullName -Exclude $Exclude
                    }
                }
        } #end process
    } #end function

    Get-ChildItem -Path $repoRoot -Exclude $excludedPaths |
        ForEach-Object {
            TestStylePath -Path $_.FullName -Exclude $excludedPaths
        }

}
