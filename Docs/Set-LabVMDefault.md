---
external help file: Lability-help.xml
online version: 
schema: 2.0.0
---

# Set-LabVMDefault
## SYNOPSIS
Sets the lab virtual machine default settings.

## SYNTAX

```
Set-LabVMDefault [[-StartupMemory] <Int64>] [[-MinimumMemory] <Int64>] [[-MaximumMemory] <Int64>]
 [[-ProcessorCount] <Int32>] [[-Media] <String>] [[-SwitchName] <String>] [[-InputLocale] <String>]
 [[-SystemLocale] <String>] [[-UserLocale] <String>] [[-UILanguage] <String>] [[-Timezone] <String>]
 [[-RegisteredOwner] <String>] [[-RegisteredOrganization] <String>] [[-ClientCertificatePath] <String>]
 [[-RootCertificatePath] <String>] [[-BootDelay] <UInt16>] [[-SecureBoot] <Boolean>]
 [[-CustomBootstrapOrder] <String>] [[-GuestIntegrationServices] <Boolean>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
{{Fill in the Description}}

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -StartupMemory
Default virtual machine startup memory (bytes).

```yaml
Type: Int64
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
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
Position: 2
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
Position: 3
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
Position: 4
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Media
Default virtual machine media Id.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 5
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SwitchName
Lab host internal switch name.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 6
Default value: 
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
Position: 7
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
Position: 8
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
Position: 9
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
Position: 10
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
Position: 11
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
Position: 12
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
Position: 13
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ClientCertificatePath
Client PFX certificate bundle used to encrypt DSC credentials

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 14
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RootCertificatePath
Client certificate's issuing Root Certificate Authority (CA) certificate

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 15
Default value: 
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -BootDelay
Boot delay/pause between VM operations

```yaml
Type: UInt16
Parameter Sets: (All)
Aliases: 

Required: False
Position: 16
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SecureBoot
Secure boot status.
Could be a SwitchParameter but boolean is more explicit?

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: 

Required: False
Position: 17
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -CustomBootstrapOrder
Custom bootstrap order

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 18
Default value: MediaFirst
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
Position: 19
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

### System.Management.Automation.PSCustomObject

## NOTES

## RELATED LINKS

