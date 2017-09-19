function Start-DscCompilation {
<#
    .SYNOPSIS
        Starts compilation of one or more DSC configurations.
    .DESCRIPTION
        The Start-DscCompilation cmdlet can compile multiple PowerShell DSC configurations (.ps1 files), in parallel
        using jobs. Each PowerShell DSC configuration (.ps1) is loaded into a separate PowerShell.exe process, and
        called using the supplied configuration parameter hashtable to each each instance.
    .NOTES
        The Start-DscCompilation cmdlet assumes/requires that each node has its own PowerShell DSC configuration
        (.psd1) document.
    .PARAMETER Configuration
        Specifies the file path(s) to PowerShell DSC configuration (.ps1) files to compile.
    .PARAMETER InoutObject
        Specifies the file references to PowerShell DSC configuration (.ps1) files to complile.
    .PARAMETER ConfigurationData
        Specifies a PowerShell DSC configuration data hashtable or a path to an existing PowerShell DSC .psd1
        configuration document used to create the virtual machines. One virtual machine is created per node defined
        in the AllNodes array.
    .PARAMETER Path
        Specifies the directory path containing the PowerShell DSC configuration files. If this parameter is not
        specified, it defaults to the current working directory.
    .PARAMETER NodeName
        Specifies one or more node names contained in the PowerShell DSC configuration (.psd1) document to compile.
        If no node names are specified, all nodes defined within the configuration are compiled.
    .PARAMETER OutputPath
        Specifies the output path of the compiled DSC .mof file(s). If this parameter is not specified, it defaults
        to the current working directory.
    .PARAMETER AsJob
        Specifies that the cmdlet return a PowerShell job for each PowerShell DSC compilation instance. By default,
        the cmdlet will block the console until it finishes all comilation tasks.
    .EXAMPLE
        Start-DscCompilation -ConfigurationData .\config.psd1 -ConfigurationParameters @{ Credential = $credential; }

        Initiates compilation of all nodes defined in the .\config.psd1 file. For each node, the matching
        <NodeName.ps1> PowerShell DSC configuration file is loaded in to a separate PowerShell.exe process, and is
        subsequently called.

        The 'Credential' parameter is passed to each PowerShell.exe instance. The resulting PowerShell DSC .mof files
        are written out to the current working directory.
#>
    [CmdletBinding(DefaultParameterSetName = 'Configuration')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions','')]
    [OutputType([System.IO.FileInfo], [System.Management.Automation.Job])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Configuration')]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Configuration,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'InputObject')]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo[]] $InputObject,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'ConfigurationData')]
        [ValidateNotNullOrEmpty()]
        [System.String] $ConfigurationData,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ConfigurationData')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path = (Get-Location -PSProvider Filesystem).Path,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ConfigurationData')]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $NodeName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable] $ConfigurationParameters,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $OutputPath = (Get-Location -PSProvider Filesystem).Path,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $AsJob
    )
    begin {

        if ($PSBoundParameters.ContainsKey('ConfigurationData')) {

            $ConfigurationData = Resolve-Path -Path $ConfigurationData -ErrorAction Stop;
        }

        if (-not ($PSBoundParameters.ContainsKey('ConfigurationParameters'))) {

            ## Set the output path
            $ConfigurationParameters = @{ OutputPath = $OutputPath };

            if ($PSBoundParameters.ContainsKey('ConfigurationData')) {

                $ConfigurationParameters['ConfigurationData'] = $ConfigurationData;
            }

        }
        else {

            if (($PSBoundParameters.ContainsKey('OutputPath')) -and
                ($ConfigurationParameters.ContainsKey('OutputPath'))) {

                ## OutputPath was explicitly passed and is also defined in ConfigurationParameters
                Write-Warning -Message ($localized.ExplicitOutputPathWarning -f $OutputPath);
                $ConfigurationParameters['OutputPath'] = $OutputPath;
            }
            elseif (-not ($ConfigurationParameters.ContainsKey('OutputPath'))) {

                $ConfigurationParameters['OutputPath'] = $OutputPath;
            }

            if (($ConfigurationParameters.ContainsKey('ConfigurationData')) -and
                ($PSBoundParameters.ContainsKey('ConfigurationData'))) {

                ## ConfigurationData was explicitly passed and is also defined in ConfigurationParameters
                Write-Warning -Message ($localized.ExplicitConfigurationDataWarning -f $ConfigurationData);
                $ConfigurationParameters['ConfigurationData'] = $ConfigurationData;
            }
            elseif (-not ($ConfigurationParameters.ContainsKey('ConfigurationData')) -and
                         ($PSBoundParameters.ContainsKey('ConfigurationData'))) {

                $ConfigurationParameters['ConfigurationData'] = $ConfigurationData;
            }

        }

        $filePaths = @();

    } #end begin

    process {

        if ($PSCmdlet.ParameterSetName -eq 'InputObject') {

            foreach ($object in $InputObject) {

                Write-Verbose -Message ($localized.AddingConfiguration -f $object.FullName);
                if (Test-Path -Path $object.FullName) {

                    $filePaths += $object.FullName;
                }
                else {

                    Write-Error -Message ($localized.InvalidPathError -f 'File', $nodePath);
                }
            } #end foreach configuration fileinfo

        }
        elseif ($PSCmdlet.ParameterSetName -eq 'ConfigurationData') {

            <# Can't pass a hashtable to Start-Job due to Array/ArrayList serialization/deserialization issue. Need
               to pass -ConfigurationData by file path.

                ConfigurationData parameter property AllNodes needs to be a collection.
                    + CategoryInfo          : InvalidOperation: (:) [Write-Error], InvalidOperationException
                    + FullyQualifiedErrorId : ConfiguratonDataAllNodesNeedHashtable,ValidateUpdate-ConfigurationData
                    + PSComputerName        : localhost
            #>
            $configData = ConvertTo-ConfigurationData -ConfigurationData $ConfigurationData;

            if (-not ($PSBoundParameters.ContainsKey('NodeName'))) {

                $nodeName = $configData.AllNodes | Where-Object { $_.NodeName -ne '*' } | ForEach-Object { $_.NodeName };
            }

            foreach ($node in $nodeName) {

                $nodePath = Join-Path -Path $Path -ChildPath "$node.ps1";
                Write-Verbose -Message ($localized.AddingConfiguration -f $nodePath);
                if (Test-Path -Path $nodePath) {

                    $filePaths += $nodePath;
                }
                else {

                    Write-Error -Message ($localized.InvalidPathError -f 'File', $nodePath);
                }
            } #end foreach node in configuration data

        }
        elseif ($PSCmdlet.ParameterSetName -eq 'Configuration') {

            foreach ($filePath in $Configuration) {

                try {
                    $resolvedFilePath = Resolve-Path -Path $filePath -ErrorAction Stop;
                    if (Test-Path -Path $resolvedFilePath) {

                        Write-Verbose -Message ($localized.AddingConfiguration -f $resolvedFilePath);
                        $filePaths += $resolvedFilePath;
                    }
                    else {

                        Write-Error -Message ($localized.InvalidPathError -f 'File', $resolvedFilePath);
                    }

                }
                catch {

                    Write-Error -Message ($localized.InvalidPathError -f 'File', $filePath);
                }

            } #end foreach configuration file path
        }

    } #end process

    end {

        if ($filePaths.Count -eq 0) {

            throw ($localized.NoConfigurationToCompileError);
        }

        $jobs = @();

        ## Start the jobs
        foreach ($filePath in $filePaths) {

            $invokeDscConfigurationCompilationParams = @{
                Configuration = $filePath;
                AsJob = $true;
            }
            if ($ConfigurationParameters.Keys.Count -gt 0) {

                $invokeDscConfigurationCompilationParams['ConfigurationParameters'] = $ConfigurationParameters;
            }
            Write-Verbose -Message ($localized.AddingCompilationJob -f $filePath);
            $jobs += Start-DscConfigurationCompilation @invokeDscConfigurationCompilationParams;

        }

        if ($AsJob) {

            return $jobs;
        }
        else {

            ## Wait for compilation to finish
            $isJobsComplete = $false;
            $completedJobs = @();

            $activity = $localized.CompilingConfigurationActivity;
            $totalPercentComplete = 0;
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew();

            while ($isJobsComplete -eq $false) {

                $isJobsComplete = $true;
                $jobPercentComplete++;

                if ($jobPercentComplete -gt 100) {

                    ## Loop progress
                    $jobPercentComplete = 1;
                }

                if ($jobPercentComplete % 2 -eq 0) {

                    ## Ensure total progresses at a different speed
                    $totalPercentComplete++;
                    if ($totalPercentComplete -gt 100) {

                        $totalPercentComplete = 1;
                    }
                }

                $elapsedTime =  $stopwatch.Elapsed.ToString('hh\:mm\:ss\.ff');
                Write-Progress -Id $pid -Activity $activity -Status $elapsedTime -PercentComplete $totalPercentComplete;

                foreach ($job in $jobs) {

                    if ($job.HasMoreData -or $job.State -eq 'Running') {

                        Write-Progress -Id $job.Id -ParentId $pid -Activity $job.Name -PercentComplete $jobPercentComplete;
                        $isJobsComplete = $false;
                        $job | Receive-Job;
                    }
                    elseif ($job.State -ne 'NotStarted') {

                        if ($job -notin $completedJobs) {

                            $elapsedTime = $stopwatch.Elapsed.ToString('hh\:mm\:ss\.ff');
                            $compilationStatus = $localized.ProcessedComilationStatus;
                            Write-Verbose -Message ("{0} '{1}' in '{2}'." -f $compilationStatus, $job.Name, $elapsedTime);
                            Write-Progress -Id $job.Id -ParentId $pid -Activity $job.Name -Completed;
                            $completedJobs += $job;
                        }
                    }

                } #end foreach job

                Start-Sleep -Milliseconds 750;

            } #end while active job(s)

            $elapsedTime = $stopwatch.Elapsed.ToString('hh\:mm\:ss\.ff');
            Write-Verbose -Message ($localized.CompletedCompilationProcessing -f $elapsedTime);
            Write-Progress -Id $pid -Activity $activity -Completed;
            $stopwatch = $null;

        } #end not job

    } #end end

} #end function
