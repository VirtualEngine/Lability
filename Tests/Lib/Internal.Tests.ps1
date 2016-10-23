#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psd1") -Force;

Describe 'Lib\Internal' {

    InModuleScope $moduleName {

        Context 'Validates "ResolvePathEx" method' {

            It 'Resolves existing home path' {
                (Get-PSProvider -PSProvider 'FileSystem').Home = (Get-PSDrive -Name TestDrive).Root;
                $fileSystemPath = (Get-PSProvider -PSProvider 'FileSystem').Home;
                $psPath = '~';

                ResolvePathEx -Path $psPath | Should Be $fileSystemPath;
            }

            It 'Resolves non-existent home path' {
                (Get-PSProvider -PSProvider 'FileSystem').Home = (Get-PSDrive -Name TestDrive).Root;
                $fileSystemPath = '{0}\HopefullyThisPathDoesNotExist' -f (Get-PSProvider -PSProvider 'FileSystem').Home;
                $psPath = '~\HopefullyThisPathDoesNotExist';

                ResolvePathEx -Path $psPath | Should Be $fileSystemPath;
            }

        } #end context Validates "ResolvePathEx" method

        Context 'Validates "InvokeExecutable" method' {

            It 'Calls "Start-Process" with correct process path' {
                $testProcess = 'Test.exe';
                $testArguments = @('/Arg1','-Arg2');
                $testExitCode = 0;
                Mock Start-Process -ParameterFilter { $FilePath -eq $testProcess } -MockWith { return [PSCustomObject] @{ ExitCode = $testExitCode; } }

                InvokeExecutable -Path 'Test.exe' -Arguments $testArguments;
                Assert-MockCalled Start-Process -ParameterFilter { $FilePath -eq $testProcess } -Scope It;
            }

            It 'Calls "Start-Process" with correct arguments' {
                $testProcess = 'Test.exe';
                $testArguments = @('/Arg1','-Arg2');
                $testExitCode = 0;
                Mock Start-Process -ParameterFilter { $ArgumentList.Count -eq 2 } -MockWith { return [PSCustomObject] @{ ExitCode = $testExitCode; } }

                InvokeExecutable -Path 'Test.exe' -Arguments $testArguments;
                Assert-MockCalled Start-Process -ParameterFilter { $ArgumentList.Count -eq 2 } -Scope It;
            }

            It 'Waits for "Start-Process" to exit' {
                $testProcess = 'Test.exe';
                $testArguments = @('/Arg1','-Arg2');
                $testExitCode = 0;
                Mock Start-Process -ParameterFilter { $Wait -eq $true } -MockWith { return [PSCustomObject] @{ ExitCode = $testExitCode; } }

                InvokeExecutable -Path 'Test.exe' -Arguments $testArguments;
                Assert-MockCalled Start-Process -ParameterFilter { $Wait -eq $true } -Scope It;
            }

            It 'Warns when process exits with non-zero exit code' {
                $testProcess = 'Test.exe';
                $testArguments = @('/Arg1','-Arg2');
                $testExitCode = 1;
                Mock Start-Process -ParameterFilter { $Path -eq $testProcess } -MockWith { return [PSCustomObject] @{ ExitCode = $testExitCode; } }

                { InvokeExecutable -Path 'Test.exe' -Arguments $testArguments -WarningAction Stop 3>&1 } | Should Throw;
            }

        } #end context Validates "InvokeExecutable" method

        Context 'Validates "GetFormattedMessage" method' {

            It 'Does not return call stack information when "$labDefaults.CallStackLogging" = "$null"' {
                $labDefaults = @{ }
                $testMessage = 'This is a test message';

                $message = GetFormattedMessage -Message $testMessage;

                $message -match '\] \[' | Should Be $false;
            }

            It 'Does not return call stack information when "$labDefaults.CallStackLogging" = "$false"' {
                $labDefaults = @{ CallStackLogging = $false; }
                $testMessage = 'This is a test message';

                $message = GetFormattedMessage -Message $testMessage;

                $message -match '\] \[' | Should Be $false;
            }

            It 'Returns call stack information when "$labDefaults.CallStackLogging" = "$true"' {
                $labDefaults = @{ CallStackLogging = $true; }
                $testMessage = 'This is a test message';

                $message = GetFormattedMessage -Message $testMessage;

                $message -match '\] \[' | Should Be $true;
            }

        } #end context Validates "GetFormattedMessage" method

        Context 'Validates "WriteVerbose" method' {

            It 'Calls "GetFormattedMessage" method' {
                $testMessage = 'This is a test message';
                Mock GetFormattedMessage -ParameterFilter { $Message -match $testMessage } -MockWith { return $testMessage; }

                WriteVerbose -Message $testMessage;

                Assert-MockCalled GetFormattedMessage -ParameterFilter { $Message -match $testMessage } -Scope It;
            }

            It 'Calls "Write-Verbose" method with test message' {
                $testMessage = 'This is a test message';
                Mock Write-Verbose -ParameterFilter { $Message -match "$testMessage`$" } -MockWith { }

                WriteVerbose -Message $testMessage;

                Assert-MockCalled Write-Verbose -ParameterFilter { $Message -match $testMessage } -Scope It;
            }

        } #end context Validates "WriteVerbose" method

        Context 'Validates "WriteWarning" method' {

            It 'Calls "GetFormattedMessage" method' {
                $testMessage = 'This is a test message';
                Mock GetFormattedMessage -ParameterFilter { $Message -match $testMessage } -MockWith { return $testMessage; }

                WriteVerbose -Message $testMessage;

                Assert-MockCalled GetFormattedMessage -ParameterFilter { $Message -match $testMessage } -Scope It;
            }

            It 'Calls "Write-Warning" method with test message' {
                $testMessage = 'This is a test message';
                Mock Write-Warning -ParameterFilter { $Message -match "$testMessage`$" } -MockWith { }
                WriteWarning -Message $testMessage;
                Assert-MockCalled Write-Warning -ParameterFilter { $Message -match $testMessage } -Scope It;
            }

        } #end context Validates "WriteVerbose" method

        Context 'Validates "ConvertPSObjectToHashtable" method' {

            It 'Returns a "System.Collections.Hashtable" object' {
                $testObject = [PSCustomObject] @{ Property1 = 'Value1'; Property2 = 2; }

                $result = ConvertPSObjectToHashtable -InputObject $testObject;

                $result -is [System.Collections.Hashtable] | Should Be $true;
            }

            It 'Converts property value types correctly' {
                $testObject = [PSCustomObject] @{ Property1 = 'Value1'; Property2 = 2; }

                $result = ConvertPSObjectToHashtable -InputObject $testObject;

                $result.Property1 -is [System.String] | Should Be $true;
                $result.Property2 -is [System.Int32] | Should Be $true;
            }

            It 'Ignores "$null" values when specified' {
                $testObject = [PSCustomObject] @{ Property1 = 'Value1'; Property2 = 2; Property3 = $null; }

                $result = ConvertPSObjectToHashtable -InputObject $testObject -IgnoreNullValues;

                $result.ContainsKey('Property3') | Should Be $false;
            }

            It 'Converts nested "PSCustomObject" types to a hashtable' {
                $testNestedObject = [PSCustomObject] @{ SubProperty1 = 1; SubProperty2 = '2'}
                $testObject = [PSCustomObject] @{ Property1 = '1'; Property2 = 2; Property3 = $testNestedObject; }

                $result = ConvertPSObjectToHashtable -InputObject $testObject -IgnoreNullValues;

                $result.Property3 -is [System.Collections.Hashtable] | Should Be $true;
            }

        }  #end context Validates "ConvertPSObjectToHashtable" method

        Context 'Validates "TestComputerName" method' {
            $baseComputerName = 'TestComputer-1';

            It "Passes when computer name does not contain invalid characters" {
                TestComputerName -ComputerName $baseComputerName | Should Be $true;
            }

            $invalidChars = @('~','!','@','#','$','%','^','&','*','(',')','=','+','_','[',']',
                                '{','}','\','|',';',':','.',"'",'"',',','<','>','/','?',' ');
            foreach ($invalidChar in $invalidChars) {
                It "Fails when computer name contains invalid '$invalidChar' character" {
                    $testComputerName = '{0}{1}' -f $baseComputerName, $invalidChar;
                    TestComputerName -ComputerName $testComputerName | Should Be $false;
                }
            } #end foreach invalid character
        } #end context Validate "TestComputerName" method

    } #end InModuleScope

} #end describe Lib\Internal
