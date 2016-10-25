    $Here = Split-Path -Parent $MyInvocation.MyCommand.Path

    
    $invokePesterParams = @{
        Path = "$here\Min.Tests.ps1";
        OutputFile = "$here\TestResult.xml";
        OutputFormat = 'NUnitXml';
        Strict = $true;
        PassThru = $true;
        Verbose = $false;
    }

    $testResult = Invoke-Pester @invokePesterParams;
    if ($testResult.FailedCount -gt 0) {
        Write-Error ('Failed "{0}" unit tests.' -f $testResult.FailedCount);
    }
