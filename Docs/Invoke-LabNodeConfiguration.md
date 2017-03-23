---
external help file: Lability-help.xml
online version: 
schema: 2.0.0
---

# Invoke-LabNodeConfiguration
## SYNOPSIS
Configures a node for manual lab deployment.

## SYNTAX

```
Invoke-LabNodeConfiguration [-ConfigurationData] <Hashtable> [[-NodeName] <String>]
 [[-DestinationPath] <String>] [-Force]
```

## DESCRIPTION
The Invoke-LabNodeConfiguration installs the client certificates, downloads all required DSC
resources and checks whether all resources are present locally.
This is convenient when using
alternative hypervisors that cannot be auto-provisioned by Lability.
Examples include virtual
machines deployed on VMware Workstation or AmazonW Web Services.

NOTE: The Invoke-LabConfiguration will not download custom resources but will test for their presence.

WARNING: Only metadata defined in the Powershell DSC configuration document can be tested!

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ConfigurationData
Specifies a PowerShell DSC configuration data hashtable or a path to an existing PowerShell DSC .psd1
configuration document used to create the virtual machines.
Each node defined in the AllNodes array is
tested.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: 
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -NodeName
Specifies the node name in the PowerShell DSC configuration document to check.
If not specified, the
local hostname is used.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
Default value: ([System.Net.Dns]::GetHostName())
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -DestinationPath
Specifies the local directory path that resources are expected to be located in.
If not specified, it
defaults to the default ResourceShareName in the root of the system drive, i.e.
C:\Resources.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Force
Specifies that DSC resources should be re-downloaded, overwriting existing versions.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[Test-LabNodeConfiguration]()

