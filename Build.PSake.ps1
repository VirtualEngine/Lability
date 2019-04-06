#requires -Version 5;
$psake.use_exit_on_error = $true;

Properties {
    $moduleName = (Get-Item $PSScriptRoot\*.psd1)[0].BaseName;
    $basePath = $psake.build_script_dir;
    $buildDir = 'Release';
    $buildPath = (Join-Path -Path $basePath -ChildPath $buildDir);
    $releasePath = (Join-Path -Path $buildPath -ChildPath $moduleName);
    $thumbprint = '3DACD0F2D1E60EB33EC774B9CFC89A4BEE9037AF';
    $timeStampServer = 'http://timestamp.verisign.com/scripts/timestamp.dll';
    $exclude = @('.git*', '.vscode', 'Release', 'Tests', 'Build.PSake.ps1', '*.png','readme.md');
    $signExclude = @('Examples','DSCResources');
}

function Set-ScriptSignature {
    <#
        .SYNOPSIS
            Signs a script file.
        .DESCRIPTION
            The Set-ScriptSignature cmdlet signs a PowerShell script file using the specified certificate thumbprint.
        .EXAMPLE
            Set-ScriptSignature -Path .\Example.psm1 -Thumbprint D10BB31E5CE3048A7D4DA0A4DD681F05A85504D3

            This example signs the 'Example.psm1' file in the current path using the certificate.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType([System.Management.Automation.Signature])]
    param (
        # One or more files/paths of the files to sign.
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()] [Alias('PSPath','FullName')]
        [System.String[]] $Path = (Get-Location -PSProvider FileSystem),

        # One or more literal files/paths of the files to sign.
        [Parameter(Position = 0, ValueFromPipelineByPropertyName, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $LiteralPath,

        # Thumbprint of the certificate to use.
        [Parameter(Position = 1, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Thumbprint,

        # Signing timestamp server URI
        [Parameter(Position = 2, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $TimeStampServer = 'http://timestamp.verisign.com/scripts/timestamp.dll'
    )
    begin
    {
        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            for ($i = 0; $i -lt $Path.Length; $i++) {
                $Path[$i] = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);
            }
        }
        else {
            $Path = $LiteralPath;
        } # end if
        $codeSigningCert = Get-ChildItem -Path Cert:\ -CodeSigningCert -Recurse | Where-Object Thumbprint -eq $Thumbprint;
        if (!$codeSigningCert) {
            throw ("Invalid certificate thumbprint '{0}." -f $Thumbprint);
        }
    } #begin
    process
    {
        foreach ($resolvedPath in $Path) {
            if (Test-Path -Path $resolvedPath -PathType Leaf) {
                $signResult = Set-AuthenticodeSignature -Certificate $codeSigningCert -TimestampServer $TimeStampServer -FilePath $Path;
                if ($signResult.Status -ne 'Valid') {
                    Write-Error ("Error signing file '{0}'." -f $Path);
                }
                Write-Output $signResult;
            }
            else {
                Write-Warning ("File path '{0}' was not found or was a directory." -f $resolvedPath);
            }
        } #foreach
    } #process
} #function

function Get-ModuleVersionNumber {
    [CmdletBinding()]
    param ()
    process
    {
        $sourceModuleManifestPath = Join-Path -Path $BuildRoot -ChildPath "$ModuleName.psd1"
        $sourceModuleManifest = Test-ModuleManifest -Path $sourceModuleManifestPath
        $commitCount = git.exe rev-list HEAD --count
        $currentVersion = $sourceModuleManifest.Version
        return New-Object -TypeName System.Version -ArgumentList ($currentVersion.Major, $currentVersion.Minor, $commitCount)
    }
}

Task Default -Depends Test;

Task Build -Depends Init, Clean, Test, Deploy, Sign;

Task Init {

} #end task Init

## Remove release directory
Task Clean -Depends Init {
    Write-Host (' Cleaning release directory "{0}".' -f $buildPath) -ForegroundColor Yellow;
    if (Test-Path -Path $buildPath) {
        Remove-Item -Path $buildPath -Include * -Recurse -Force;
    }
    [ref] $null = New-Item -Path $buildPath -ItemType Directory -Force;
    [ref] $null = New-Item -Path $releasePath -ItemType Directory -Force;
} #end task Clean

Task Test {
    $invokePesterParams = @{
        Path = "$basePath\Tests";
        OutputFile = "$basePath\TestResults.xml";
        OutputFormat = 'NUnitXml';
        Strict = $true;
        PassThru = $true;
        Verbose = $false;
    }
    $testResult = Invoke-Pester @invokePesterParams;
    if ($testResult.FailedCount -gt 0) {
        Write-Error ('Failed "{0}" unit tests.' -f $testResult.FailedCount);
    }

} #end task Test

Task Appveyor -Depends Test {

    #Upload test results
    Get-ChildItem -Path "$basePath\*Results*.xml" | Foreach-Object {
        $address = "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)"
        $source = $_.FullName
        Write-Verbose "UPLOADING TEST FILE: $address $source" -Verbose
        (New-Object 'System.Net.WebClient').UploadFile( $address, $source )
    }
}

Task Deploy -Depends Clean {
    Get-ChildItem -Path $basePath -Exclude $exclude | ForEach-Object {
        Write-Host (' Copying {0}' -f $PSItem.FullName) -ForegroundColor Yellow;
        Copy-Item -Path $PSItem -Destination $releasePath -Recurse;
    }
} #end task Deploy

Task Sign -Depends Deploy {
    Get-ChildItem -Path $releasePath -Exclude $signExclude | ForEach-Object {
        if ($PSItem -is [System.IO.DirectoryInfo]) {
            Get-ChildItem -Path $PSItem.FullName -Include *.ps* -Recurse | ForEach-Object {
                Write-Host (' Signing {0}' -f $PSItem.FullName) -ForegroundColor Yellow -NoNewline;
                $signResult = Set-ScriptSignature -Path $PSItem.FullName -Thumbprint $thumbprint -TimeStampServer $timeStampServer -ErrorAction Stop;
                Write-Host (' {0}.' -f $signResult.Status) -ForegroundColor Green;
            }

        }
        elseif ($PSItem.Name -like '*.ps*') {
            Write-Host (' Signing {0}' -f $PSItem.FullName) -ForegroundColor Yellow -NoNewline;
            $signResult = Set-ScriptSignature -Path $PSItem.FullName -Thumbprint $thumbprint -TimeStampServer $timeStampServer -ErrorAction Stop;
            Write-Host (' {0}.' -f $signResult.Status) -ForegroundColor Green;
        }
    }
} #end task Sign

Task Publish -Depends Build {
    Publish-Module -Path $releasePath -NuGetApiKey "$env:gallery_api_key";
} #end task Publish
