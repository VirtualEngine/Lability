#requires -Version 5;
#requires -Modules VirtualEngine.Build;
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

Task Default -Depends Build;

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
        OutputFile = "$releasePath\TestResult.xml";
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
    $psGalleryApiKey = Get-Content -Path "$env:UserProfile\PSGallery.apitoken" | ConvertTo-SecureString;
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($psGalleryApiKey);
    $nuGetApiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr);
    Publish-Module -Path $releasePath -NuGetApiKey $nuGetApiKey;
} #end task Publish
