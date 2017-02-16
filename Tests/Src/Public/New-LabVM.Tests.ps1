#requires -RunAsAdministrator
#requires -Version 4

$moduleName = 'Lability';
$repoRoot = (Resolve-Path "$PSScriptRoot\..\..\..").Path;
Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe 'Src\Public\New-LabVM' {

    InModuleScope -ModuleName $moduleName {


        $MediaId = 'DummyMediaId'
        $testPassword = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);

        ## Guard mocks
        Mock NewLabVM -MockWith { }
        Mock Get-LabMedia -MockWith { New-Object -TypeName PSObject -Property @{ 'Id' = $MediaId } }

        It 'Creates a new virtual machine' {
            $testVMName = 'TestVM';

            New-LabVM -Name $testVMName -MediaId $MediaId -Credential $testPassword;

            Assert-MockCalled NewLabVM -ParameterFilter { $NoSnapShot -eq $false } -Scope It;
        }

        It 'Creates a new virtual machine without a snapshot when "NoSnapshot" is specified' {
            $testVMName = 'TestVM';

            New-LabVM -Name $testVMName -MediaId $MediaId  -Credential $testPassword -NoSnapshot;

            Assert-MockCalled NewLabVM -ParameterFilter { $NoSnapShot -eq $true } -Scope It;
        }

    } #end InModuleScope

} #end describe
