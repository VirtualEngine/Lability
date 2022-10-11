function Start-DscConfigurationCompilation {
<#
    .SYNOPSIS
        Compiles an individual DSC configuration as a job.
#>
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidMultipleTypeAttributes','')]
    [OutputType([System.IO.FileInfo])]
    param (
        ## DSC configuration file path, e.g. CONTROLLER.ps1
        [Parameter(Mandatory)]
        [System.String] $Configuration,

        ## Parameters to pass into the DSC configuration
        [Parameter(Mandatory)]
        [System.Collections.Hashtable] $ConfigurationParameters,

        [Parameter()]
        [System.Management.Automation.SwitchParameter] $AsJob
    )
    begin {

        ## Compilation scriptblock started as a job
        $compileConfigurationScriptBlock = {
            param (
                ## DSC configuration path, e.g. CONTROLLER.ps1
                [Parameter(Mandatory)]
                [System.String] $ConfigurationPath,

                ## Parameters to pass into the configuration
                [Parameter()]
                [System.Collections.Hashtable] [ref] $ConfigurationParameters,

                [Parameter()]
                [System.String] $VerbosePreference
            )
            process {

                $ConfigurationPath = Resolve-Path -Path $ConfigurationPath;
                ## TODO Configuration name must currently match configuration file name
                $configurationName = (Get-Item -Path $ConfigurationPath).BaseName;

                ## Internal functions and localization strings are in a different PowerShell.exe
                ## process so we have to resort to hard coding (for the time being) :(
                Write-Verbose -Message ("Loading configuration '{0}'." -f $ConfigurationPath);
                $existingVerbosePreference = $VerbosePreference;

                ## Hide verbose output
                $VerbosePreference = 'SilentlyContinue';

                ## Import the configuration
                . $ConfigurationPath;

                $VerbosePreference = $existingVerbosePreference;
                Write-Verbose -Message ("Compiling configuration '{0}'." -f $ConfigurationPath);
                $VerbosePreference = 'SilentlyContinue';

                if ($ConfigurationParameters) {

                    ## Call the configuration (complile it) with supplied parameters
                    & $configurationName @ConfigurationParameters;
                }
                else {

                    ## Just call the configuration (compile it)
                    & $configurationName;
                }

                ## Restore verbose preference
                $VerbosePreference = $existingVerbosePreference;

            } #end process
        } #end $compileConfigurationScriptBlock

    }
    process {

        $configurationPath = Resolve-Path -Path $Configuration;

        $startJobParams = @{
            Name = $configurationPath;
            ScriptBlock = $compileConfigurationScriptBlock;
        }

        if ($PSBoundParameters.ContainsKey('ConfigurationParameters')) {

            $startJobParams['ArgumentList'] = @($configurationPath, $ConfigurationParameters, $VerbosePreference);
        }

        $job = Start-Job @startJobParams;
        $activity = $localized.CompilingConfiguration;

        if (-not $AsJob) {

            while ($Job.HasMoreData -or $Job.State -eq 'Running') {

                $percentComplete++;
                if ($percentComplete -gt 100) {
                    $percentComplete = 0;
                }
                Write-Progress -Id $job.Id -Activity $activity -Status $configurationPath -PercentComplete $percentComplete;
                Receive-Job -Job $Job
                Start-Sleep -Milliseconds 500;
            }

            Write-Progress -Id $job.Id -Activity $activity -Completed;
            $job | Receive-Job;

        }
        else {

            return $job;
        }

    } #end process
} #end function
