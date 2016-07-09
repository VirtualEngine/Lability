---
external help file: Lability-help.xml
online version: 
schema: 2.0.0
---

# Test-LabNodeConfiguration
## SYNOPSIS
Test a node's configuration for manual deployment.

## SYNTAX

### All (Default)
```
Test-LabNodeConfiguration -ConfigurationData <Hashtable> [-NodeName <String>] [-DestinationPath <String>]
```

### SkipDscCheck
```
Test-LabNodeConfiguration -ConfigurationData <Hashtable> [-NodeName <String>] [-DestinationPath <String>]
 [-SkipDscCheck]
```

### SkipResourceCheck
```
Test-LabNodeConfiguration -ConfigurationData <Hashtable> [-NodeName <String>] [-DestinationPath <String>]
 [-SkipResourceCheck] [-SkipCertificateCheck]
```

## DESCRIPTION
The Test-LabNodeConfiguration determines whether the local node has all the required defined prerequisites
available locally.
When invoked, defined custom resources, certificates and DSC resources are checked.

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
Position: Named
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
Position: Named
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
Position: Named
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SkipDscCheck
Specifies that checking of the local DSC resource availability is skipped.

```yaml
Type: SwitchParameter
Parameter Sets: SkipDscCheck
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SkipResourceCheck
Specifies that checking of the local custom resource availability is skipped.

```yaml
Type: SwitchParameter
Parameter Sets: SkipResourceCheck
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SkipCertificateCheck
Specifies that checking of the local certificates is skipped.

```yaml
Type: SwitchParameter
Parameter Sets: SkipResourceCheck
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

### System.Boolean

## NOTES

## RELATED LINKS

[Invoke-LabNodeConfiguration]()

