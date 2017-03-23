---
external help file: Lability-help.xml
online version: 
schema: 2.0.0
---

# Reset-LabVM
## SYNOPSIS
Recreates a lab virtual machine.

## SYNTAX

### PSCredential (Default)
```
Reset-LabVM -Name <String[]> -ConfigurationData <Hashtable> [-Credential <PSCredential>] [-Path <String>]
 [-NoSnapshot] [-WhatIf] [-Confirm]
```

### Password
```
Reset-LabVM -Name <String[]> -ConfigurationData <Hashtable> -Password <SecureString> [-Path <String>]
 [-NoSnapshot] [-WhatIf] [-Confirm]
```

## DESCRIPTION
The Reset-LabVM cmdlet deletes and recreates a lab virtual machine, reapplying the MOF.

To revert a single VM to a previous state, use the Restore-VMSnapshot cmdlet.
To revert an entire lab environment, use the Restore-Lab cmdlet.

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Name
Specifies the lab virtual machine/node name.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: 
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ConfigurationData
Specifies a PowerShell DSC configuration document (.psd1) containing the lab configuration.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Credential
Local administrator password of the virtual machine.
The username is NOT used.

```yaml
Type: PSCredential
Parameter Sets: PSCredential
Aliases: 

Required: False
Position: Named
Default value: (& $credentialCheckScriptBlock)
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Password
Local administrator password of the virtual machine.

```yaml
Type: SecureString
Parameter Sets: Password
Aliases: 

Required: True
Position: Named
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Path
Directory path containing the virtual machines' .mof file(s).

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: (GetLabHostDSCConfigurationPath)
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -NoSnapshot
Skip creation of the initial baseline snapshot.

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

### -WhatIf
{{Fill WhatIf Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
{{Fill Confirm Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

