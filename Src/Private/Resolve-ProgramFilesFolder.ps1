function Resolve-ProgramFilesFolder {
<#
    .SYNOPSIS
        Resolves known localized %ProgramFiles% directories.
    .LINK
        https://en.wikipedia.org/wiki/Program_Files
#>
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType([System.IO.DirectoryInfo])]
    param (
        ## Root path to check
        [Parameter(Mandatory, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## Drive letter
        [Parameter(Mandatory, ParameterSetName = 'Drive')]
        [ValidateLength(1,1)]
        [System.String] $Drive
    )
    begin {

        if ($PSCmdlet.ParameterSetName -eq 'Drive') {

            $Path = '{0}:\' -f $Drive;
        }

    }
    process {

        $knownFolderNames = @(
            "Program Files",
            "Programmes",
            "Archivos de programa",
            "Programme",
            "Programfájlok",
            "Programmi",
            "Programmer",
            "Program",
            "Programfiler",
            "Arquivos de Programas",
            "Programas"
            "Αρχεία Εφαρμογών"
        )

        Get-ChildItem -Path $Path -Directory |
            Where-Object Name -in $knownFolderNames |
                Select-Object -First 1;

    } #end process
} #end function
