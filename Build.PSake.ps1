#requires -Version 5;
#requires -Modules VirtualEngine.Build;

$psake.use_exit_on_error = $true;

Properties {
    $moduleName = (Get-Item $PSScriptRoot\*.psd1)[0].BaseName;
    $basePath = $psake.build_script_dir;
    $buildDir = 'Release';
    $buildPath = (Join-Path -Path $basePath -ChildPath $buildDir);
    $releasePath = (Join-Path -Path $buildPath -ChildPath $moduleName);
    $thumbprint = '177FC8E667D4C022C7CD9CFDFEB66991890F4090';
    $timeStampServer = 'http://timestamp.digicert.com';
    $exclude = @(
                '.git*',
                '.vscode',
                'Release',
                'Tests',
                'Build.PSake.ps1',
                '*.png',
                '*.md',
                '*.enc',
                'TestResults.xml',
                'appveyor.yml',
                'appveyor-tools'
                );
    $signExclude = @('Examples','DSCResources');
}

# Synopsis: Initialises build variables
Task Init {

    # Properties are not available in the script scope.
    Set-Variable manifest -Value (Get-ModuleManifest) -Scope Script;
    Set-Variable version -Value $manifest.Version -Scope Script;
    Write-Host (" Building module '{0}'." -f $manifest.Name) -ForegroundColor Yellow;
    Write-Host (" Building version '{0}'." -f $version) -ForegroundColor Yellow;
} #end task Init

# Synopsis: Cleans the release directory
Task Clean -Depends Init {

    Write-Host (' Cleaning release directory "{0}".' -f $buildPath) -ForegroundColor Yellow;
    if (Test-Path -Path $buildPath) {
        Remove-Item -Path $buildPath -Include * -Recurse -Force;
    }
    [ref] $null = New-Item -Path $buildPath -ItemType Directory -Force;
    [ref] $null = New-Item -Path $releasePath -ItemType Directory -Force;
} #end task Clean

# Synopsis: Invokes Pester tests
Task Test -Depends Init {

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
}

# Synopsis: Copies release files to the release directory
Task Deploy -Depends Clean {

    Get-ChildItem -Path $basePath -Exclude $exclude | ForEach-Object {
        Write-Host (' Copying {0}' -f $PSItem.FullName) -ForegroundColor Yellow;
        Copy-Item -Path $PSItem -Destination $releasePath -Recurse;
    }
} #end

# Synopsis: Signs files in release directory
Task Sign -Depends Deploy {

    if (-not (Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object Thumbprint -eq $thumbprint)) {
        ## Decrypt and import code signing cert
        .\appveyor-tools\secure-file.exe -decrypt .\VE_Certificate_2023.pfx.enc -secret $env:certificate_secret -salt $env:certificate_salt
        $certificatePassword = ConvertTo-SecureString -String $env:certificate_secret -AsPlainText -Force
        Import-PfxCertificate -FilePath .\VE_Certificate_2023.pfx -CertStoreLocation 'Cert:\CurrentUser\My' -Password $certificatePassword
    }

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
}

Task Version -Depends Deploy {

    $nuSpecPath = Join-Path -Path $releasePath -ChildPath "$ModuleName.nuspec"
    $nuspec = [System.Xml.XmlDocument] (Get-Content -Path $nuSpecPath -Raw)
    $nuspec.Package.MetaData.Version = $version.ToString()
    $nuspec.Save($nuSpecPath)
}

# Synopsis: Publishes release module to PSGallery
Task Publish_PSGallery -Depends Version {

    Publish-Module -Path $releasePath -NuGetApiKey "$env:gallery_api_key" -Verbose
} #end task Publish

# Synopsis: Creates release module Nuget package
Task Package -Depends Build {

    $targetNuSpecPath = Join-Path -Path $releasePath -ChildPath "$ModuleName.nuspec"
    NuGet.exe pack "$targetNuSpecPath" -OutputDirectory "$env:TEMP"
}

# Synopsis: Publish release module to Dropbox repository
Task Publish_Dropbox -Depends Package {

    $targetNuPkgPath = Join-Path -Path "$env:TEMP" -ChildPath "$ModuleName.$version.nupkg"
    $destinationPath = "$env:USERPROFILE\Dropbox\PSRepository"
    Copy-Item -Path "$targetNuPkgPath"-Destination $destinationPath -Force
}

# Synopsis: Publish test results to AppVeyor
Task AppVeyor {

    Get-ChildItem -Path "$basePath\*Results*.xml" | Foreach-Object {
        $address = 'https://ci.appveyor.com/api/testresults/nunit/{0}' -f $env:APPVEYOR_JOB_ID
        $source = $_.FullName
        Write-Verbose "UPLOADING TEST FILE: $address $source" -Verbose
        (New-Object 'System.Net.WebClient').UploadFile( $address, $source )
    }
}

Task Default -Depends Init, Clean, Test
Task Build -Depends Default, Deploy, Version, Sign;
Task Publish -Depends Build, Package, Publish_PSGallery
Task Local -Depends Build, Package, Publish_Dropbox
