#requires -Version 5;
#requires -Modules VirtualEngine.Build;

$psake.use_exit_on_error = $true;

Properties {
    $moduleName = (Get-Item $PSScriptRoot\*.psd1)[0].BaseName
    $basePath = $psake.build_script_dir
    $buildDir = 'Release'
    $buildPath = (Join-Path -Path $basePath -ChildPath $buildDir)
    $releasePath = (Join-Path -Path $buildPath -ChildPath $moduleName)
    $combine = @(
        'Src\Private',
        'Src\Public'
    )
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
        'appveyor-tools',
        'Src' # Fo;es are combined and then signed
    )
    $signExclude = @('Examples','DSCResources')
}

#region functions

function Set-FileSignatureKeyVault
{
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
    param
    (
        ## File to sign
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Path,

        ## Code-signing timestamp server
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $TimestampServer = 'http://timestamp.digicert.com',

        ## Code-signing certificate thumbprint
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $HashAlgorithm = 'SHA256'
    )
    process
    {
        $azureSignToolArguments = @('sign', '-kvu', $env:kv_uri, '-kvc', $env:kv_certificate_name)
        $azureSignToolArguments += @('-kvi', $env:kv_client_id)
        $azureSignToolArguments += @('-kvs', $env:kv_client_secret)
        $azureSignToolArguments += @('-kvt', $env:kv_tenant_id)
        $azureSignToolArguments += @('-tr', $TimestampServer)

        if ($PSBoundParameters.ContainsKey('HashAlgorithm'))
        {
            $azureSignToolArguments += @('-fd', $HashAlgorithm)
        }

        $azureSignToolArguments += '"{0}"' -f $Path

        $azureSignToolPath = Resolve-Path -Path (Join-Path -Path '~\.dotnet\tools' -ChildPath 'AzureSignTool.exe')
        if (-not (Test-Path -Path $azureSignToolPath -PathType Leaf))
        {
            throw ("Cannot find file '{0}'." -f $azureSignToolPath)
        }

        & $azureSignToolPath $azureSignToolArguments | Write-Verbose -Verbose
        if ($LASTEXITCODE -ne 0)
        {
            throw ("Error '{0}' signing file '{1}'." -f $LASTEXITCODE, $Path)
        }
    }
}

#endregion functions

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
Task Stage -Depends Clean {

    Get-ChildItem -Path $basePath -Exclude $exclude | ForEach-Object {
        Write-Host (' Copying {0}' -f $PSItem.FullName) -ForegroundColor Yellow;
        Copy-Item -Path $PSItem -Destination $releasePath -Recurse;
    }

    foreach ($combinePath in $combine)
    {
        $combinePathItem = Get-Item -Path (Join-Path -Path $basePath -ChildPath $combinePath)
        $targetCombinedFilePath = Join-Path -Path $releasePath -ChildPath $combinePath
        $null = New-Item -Path (Split-Path -Path $targetCombinedFilePath -Parent) -Name (Split-Path -Path $targetCombinedFilePath -Leaf) -ItemType Directory -Force
        $combinedFilePath = Join-Path -Path $targetCombinedFilePath -ChildPath ('{0}.ps1' -f (Split-Path -Path $targetCombinedFilePath -Leaf))
        Get-ChildItem -Path $combinePathItem |
            ForEach-Object {
                Write-Host (' Combining {0}' -f $PSItem.FullName) -ForegroundColor Yellow;
                (Get-Content -Path $PSItem.FullName -Raw) | Add-Content -Path $combinedFilePath
                Start-Sleep -Milliseconds 30
            }
    }
} #end

# Synopsis: Signs files in release directory
Task Sign -Depends Stage {

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    Get-ChildItem -Path $releasePath -Include *.ps* -Recurse | ForEach-Object {
        $isExcluded = $false
        foreach ($excludedPath in $SignExclude)
        {
            if ($PSItem.FullName -match $excludedPath)
            {
                $isExcluded = $true
            }
        }

        if (-not $isExcluded)
        {
            Write-Host (' Signing file "{0}"' -f $PSItem.FullName) -ForegroundColor Yellow
            Set-FileSignatureKeyVault -Path $PSItem.FullName
        }
    }
}

Task Version -Depends Stage {

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
Task Local -Depends Build, Package
