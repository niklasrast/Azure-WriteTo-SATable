#Requires -Version 3.0
<#
    .SYNOPSIS 
    Windows 10 Software packaging wrapper

    .DESCRIPTION
    Install:   PowerShell.exe -ExecutionPolicy Bypass -Command .\WriteTo-AzureTable.ps1

    .ENVIRONMENT
    PowerShell 5.0

    .AUTHOR
    Niklas Rast
#>

$AzureEndpoint = 'https://<STORAGEACCOUNTNAME>.table.core.windows.net'
$AzureSharedAccessSignature  = '<SASTOKEN>'
$AzureTable = "<TABLENAME>"

Function Test-InternetConnection
{
    [CmdletBinding()]
    Param
    (
        [parameter(Mandatory=$true)][string]$Target
    )

    $Result = Test-NetConnection -ComputerName ($Target -replace "https://","") -Port 443 -WarningAction SilentlyContinue;
    Return $Result;
}

Function Add-AzureTableData
{
    [CmdletBinding()]
    Param
    (
        [parameter(Mandatory=$true)][string]$Endpoint,
        [parameter(Mandatory=$true)][string]$SharedAccessSignature,
        [parameter(Mandatory=$true)][string]$Table,
        [parameter(Mandatory=$true)][hashtable]$TableData
    )

    $Headers = @{
        "x-ms-date"=(Get-Date -Format r);
        "x-ms-version"="2016-05-31";
        "Accept-Charset"="UTF-8";
        "DataServiceVersion"="3.0;NetFx";
        "MaxDataServiceVersion"="3.0;NetFx";
        "Accept"="application/json;odata=nometadata"
    };

    $URI
    $URI = ($Endpoint + "/" + $Table + "/" + $SharedAccessSignature);

    #Convert table data to JSON and encode to UTF8.
    $Body = [System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json -InputObject $TableData));

    #Insert data to Azure storage table.
    Invoke-WebRequest -Method Post -Uri $URI -Headers $Headers -Body $Body -ContentType "application/json" -UseBasicParsing | Out-Null;
}

Function ConvertTo-HashTable
{
    [cmdletbinding()]
    Param
    (
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$True)]
        [object]$InputObject,
        [switch]$NoEmpty
    )
     
    Process
    {
        #Get propery names.
        $Names = $InputObject | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name;

        #Define an empty hash table.
        $Hash = @{};

        #Go through the list of names and add each property and value to the hash table.
        $Names | ForEach-Object {$Hash.Add($_,$InputObject.$_)};

        #If NoEmpty is set.
        If ($NoEmpty)
        {
            #Define a new hash.
            $Defined = @{};

            #Get items from $hash that have values and add to $Defined.
            $Hash.Keys | ForEach-Object {
                #If hash item is not empty.
                If ($Hash.item($_))
                {
                    #Add to hashtable.
                    $Defined.Add(($_,$Hash.Item($_)));
                }
            }       
            #Return hashtable.
            Return $Defined;
        }
        #Return hashtable.
        Return $Hash;
    }
}

If(!((Test-InternetConnection -Target $AzureEndpoint).TcpTestSucceeded -eq "true"))
{
    Write-Host "Cannot access the storage account through network problems."
    Exit 1;
}

#Create a new object.
$TableObject = New-Object -TypeName PSObject;
Add-Member -InputObject $TableObject -Membertype NoteProperty -Name "PartitionKey" -Value ((Get-Random -Minimum 000000 -Maximum 999999)).ToString();
Add-Member -InputObject $TableObject -Membertype NoteProperty -Name "RowKey" -Value ($ENV:COMPUTERNAME).ToString();

###Add values to the object here
Add-Member -InputObject $TableObject -Membertype NoteProperty -Name "SerialNumber" -Value ((Get-WmiObject win32_bios).SerialNumber).ToString();

#Insert data to the Azure table.
Add-AzureTableData -Endpoint $AzureEndpoint -SharedAccessSignature $AzureSharedAccessSignature -Table $AzureTable -TableData (ConvertTo-HashTable -InputObject $TableObject);