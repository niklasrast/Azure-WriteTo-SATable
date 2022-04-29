# Azure-WriteTo-SATable

![GitHub repo size](https://img.shields.io/github/repo-size/niklasrast/Azure-WriteTo-SATable)

![GitHub issues](https://img.shields.io/github/issues-raw/niklasrast/Azure-WriteTo-SATable)

![GitHub last commit](https://img.shields.io/github/last-commit/niklasrast/Azure-WriteTo-SATable)

This repo contains an powershell scripts to write values from PowerShell to an Azure Storage Account Table.
The Storage Account that you will use must be accessible from your network or the internet.

## Install:
```powershell
C:\Windows\SysNative\WindowsPowershell\v1.0\PowerShell.exe -ExecutionPolicy Bypass -Command .\Azure-WriteTo-SATable.ps1
```

## Script Parameter definitions:
```powershell
$AzureEndpoint = 'https://<STORAGEACCOUNTNAME>.table.core.windows.net'
$AzureSharedAccessSignature  = '<SASTOKEN>'
$AzureTable = "<TABLENAME>"
```
Replace <STORAGEACCOUNTNAME>, <SASTOKEN> and <TABLENAME> to your informations.

## Script Value definitions:
```powershell
Add-Member -InputObject $TableObject -Membertype NoteProperty -Name "<KEYNAME>" -Value (<VALUE>).ToString();
```
Replace <KEYNAME> and <VALUE> to your values. You can duplicate this line as much as you need to upload all your Key/Value pairs.


## Requirements:
- PowerShell 5.0
- Windows 10 or later

# Feature requests
If you have an idea for a new feature in this repo, send me an issue with the subject Feature request and write your suggestion in the text. I will then check the feature and implement it if necessary.

Created by @niklasrast 
