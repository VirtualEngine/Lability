---
external help file: Lability-help.xml
online version: 
schema: 2.0.0
---

# New-LabVM
## SYNOPSIS
Creates a simple bare-metal virtual machine.

## SYNTAX

### PSCredential (Default)
```
New-LabVM -Name <String[]> [-StartupMemory <Int64>] [-MinimumMemory <Int64>] [-MaximumMemory <Int64>]
 [-ProcessorCount <Int32>] [-InputLocale <String>] [-SystemLocale <String>] [-UserLocale <String>]
 [-UILanguage <String>] [-Timezone <String>] [-RegisteredOwner <String>] [-RegisteredOrganization <String>]
 [-Credential <PSCredential>] [-SwitchName <String[]>] [-MACAddress <String[]>] [-SecureBoot <Boolean>]
 [-GuestIntegrationServices <Boolean>] [-CustomData <Hashtable>] [-NoSnapshot] [-WhatIf] [-Confirm]
 -MediaId <String>
```

### Password
```
New-LabVM -Name <String[]> [-StartupMemory <Int64>] [-MinimumMemory <Int64>] [-MaximumMemory <Int64>]
 [-ProcessorCount <Int32>] [-InputLocale <String>] [-SystemLocale <String>] [-UserLocale <String>]
 [-UILanguage <String>] [-Timezone <String>] [-RegisteredOwner <String>] [-RegisteredOrganization <String>]
 -Password <SecureString> [-SwitchName <String[]>] [-MACAddress <String[]>] [-SecureBoot <Boolean>]
 [-GuestIntegrationServices <Boolean>] [-CustomData <Hashtable>] [-NoSnapshot] [-WhatIf] [-Confirm]
 -MediaId <String>
```

## DESCRIPTION
The New-LabVM cmdlet creates a bare virtual machine using the specified media.
No bootstrap or DSC configuration is applied.

NOTE: The mandatory -MediaId parameter is dynamic and is not displayed in the help syntax output.

If optional values are not specified, the virtual machine default settings are applied.
To list the current default settings run the \`Get-LabVMDefault\` command.

NOTE: If a specified virtual switch cannot be found, an Internal virtual switch will automatically be created.
To use any other virtual switch configuration, ensure the virtual switch is created in advance.

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Name
Specifies the virtual machine name.

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

### -StartupMemory
Default virtual machine startup memory (bytes).

```yaml
Type: Int64
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -MinimumMemory
Default virtual machine miniumum dynamic memory allocation (bytes).

```yaml
Type: Int64
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -MaximumMemory
Default virtual machine maximum dynamic memory allocation (bytes).

```yaml
Type: Int64
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ProcessorCount
Default virtual machine processor count.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -InputLocale
Input Locale

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

### -SystemLocale
System Locale

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

### -UserLocale
User Locale

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

### -UILanguage
UI Language

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

### -Timezone
Timezone

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

### -RegisteredOwner
Registered Owner

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

### -RegisteredOrganization
Registered Organization

```yaml
Type: String
Parameter Sets: (All)
Aliases: RegisteredOrganisation

Required: False
Position: Named
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Credential
Local administrator password of the VM.
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
Local administrator password of the VM.

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

### -SwitchName
Virtual machine switch name(s).

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -MACAddress
Virtual machine MAC address(es).

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SecureBoot
Enable Secure boot status

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -GuestIntegrationServices
Enable Guest Integration Services

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -CustomData
Custom data

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -NoSnapshot
Skip creating baseline snapshots

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

### -MediaId
{{Fill MediaId Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[Register-LabMedia
Unregister-LabMedia
Get-LabVMDefault
Set-LabVMDefault]()

