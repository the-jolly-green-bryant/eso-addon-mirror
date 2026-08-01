#Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force

<#
.SYNOPSIS
This is a powershell script to export the output of the Elder Scrolls Online AddOn 'CraftBagger' to CSV files

.DESCRIPTION
This script parses the 'CraftBagger' saved variables file and exports the contents to account specific .CSV files.
If present, the CraftBagger add-on will use the LibPrice library to include 'suggested' prices for each item in the craftbag.
This should be useful for crafters in helping them use Excel to calculate the costs for building patterns, recipes, etc.

.EXAMPLE
./CraftBaggerCSVExport.ps1

.PARAMETER InputFile
Specifies the Elder Scrolls Online saved variable file to use.  This parameter should almost never be provided, but is included primarily for debugging and testing purposes.

.PARAMETER OutputFile
The base name of the CSV file that will be created.  Portions of this name may be modified based on other settings (like appending the date time string)
By default, -AccountName is appended to the filename portion of this file.  So for example, a given filename of 'CraftBagger.csv', and an account name of 'TooSlow001'
 will result in a filename of 'CraftBagger-TooSlow001.csv'

.PARAMETER AppendDateTime
This is a switch parameter, (default is false) which when provided will case the CSV file to be created with the current date time stamp. Note: This will be the 
date & time that the CSV file is created (by batch file or running the powershell script) and not the date/time that the saved variables .lua file was creaeted.

 .PARAMETER DateTimeFormatStr
 This is the powershell compatible date/time format string to use (if AppendDateTime is true) when creating the csv file.  See: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-date?view=powershell-7
 NOTE: No error checking is performed here - if you provide an invalid format string, the behavior is undefined.

.NOTES
Default values for InputFile and Output file should work in all cases, and for all accounts.  You may change these values 
on the command line, but changing the input file is really only useful for debugging or testing specific saved files.
#>


param (
    [Parameter(Mandatory=$False)]
    [string]$InputFile="$($home)\Documents\Elder Scrolls Online\live\SavedVariables\CraftBagger.lua",
    [Parameter(Mandatory=$False)]
    [string]$OutputFile="CraftBagger.csv",
    [Parameter(Mandatory=$False)]
    [string]$DateTimeFormatStr="yyyyMMdd-HHmmss",
    [Parameter(Mandatory=$False)]
    [switch]$AppendDateTime
)

Function Get-CraftBaggerData {
    Param (
        [Parameter(Mandatory=$True)]
        [string]$FileName
    )
 
    if (-Not (Test-Path $FileName -PathType leaf)) {
        Write-Error "$($FileName) does not exist! Run /savecraftbag from within Elder Scrolls Online and then logout or /reloadui"
    
        exit
    }

    Get-Content $FileName
}

Function Export-AccountCSV {
    Param (
        [Parameter(Mandatory=$False)]
        [string]$Account,
        [Parameter(Mandatory=$True)]
        [array]$Data,
        [Parameter(Mandatory=$True)]
        [string]$FileName
    )

    if ($Account)
    {
        $folder = [System.IO.Path]::GetDirectoryName($FileName)
        $prefix = [System.IO.Path]::GetFileNameWithoutExtension($FileName)
        $extension = [System.IO.Path]::GetExtension($FileName)
        $FileName = [System.IO.Path]::Combine($folder, "$($prefix)-$($Account)$($extension)")
    }

    if ($AppendDateTime) {
        $folder = [System.IO.Path]::GetDirectoryName($FileName)
        $prefix = [System.IO.Path]::GetFileNameWithoutExtension($FileName)
        $extension = [System.IO.Path]::GetExtension($FileName)
        $dateTime = (Get-Date).ToString($DateTimeFormatStr)
        $FileName = [System.IO.Path]::Combine($folder, "$($prefix)-$($dateTime)$($extension)")
    }

    $Data | Sort-Object -Property Name | export-csv -NoTypeInformation -path $FileName
}

Function Export-CraftBaggerCSV {
    Param (
        [Parameter(Mandatory=$False)]
        [string]$OutputFile = "CraftBagger.csv",
        [Parameter(Mandatory=$True)]
        [array]$Data
    )

    $currentQuantity = -1
    $currentPrice = -1
    $currentItem = ""
    $currentAccount = ""
    $items = @()

    $TextInfo = (Get-Culture).TextInfo

    foreach ($entry in $Data)  
    {
        if ($entry.Contains('@'))
        {
            $account = $entry.split('"')[1].SubString(1)

            if ($currentAccount -ne $account -AND $items.Count -ne 0)
            {
                Export-AccountCSV -Account $currentAccount -Data $items -FileName $OutputFile
                $items = @()
            }

            $currentAccount = $account
        }

        if (-Not $currentAccount)
        {
            continue;
        }

        if ( -Not $global:appendDateTimeIsBound -And $entry -like "*AppendDateTime*") {
            if ($entry -like "*true*") {
                $AppendDateTime = $True
            }
        }

        if ( -Not $global:dateFormatStringIsBound -And $entry -like "*DateTimeFormatStr*") {
            $DateTimeFormatStr = $entry.SubString($entry.IndexOf("=")).Split('"')[1]
        }

        if ($entry -like "*name*") {
            $itemName = $entry.SubString($entry.IndexOf("=")).Split('"')[1]
            $currentItem = $TextInfo.ToTitleCase($itemName.ToLower())
        }

        if ($entry -like "*quantity*") {
            $currentQuantity =  ($entry) -replace "[^0-9]", ''
        }

        if ($entry -like "*price*") {
            $currentPrice = ($entry) -replace "[^0-9.]", ''
        }

        # i dont know what order these fields will appear in the .lua file, so i'm just checking
        # to see if we have all three fields or not
        if ($currentItem -notlike "" -And $currentPrice -ne -1 -And $currentQuantity -ne -1) {
            $items += [pscustomobject]@{ 
                Name=$currentItem
                Quantity=$currentQuantity
                SuggestedPrice=$currentPrice 
            }

            $currentItem = ""
            $currentQuantity = -1
            $currentPrice = -1
        }
    }

    if ($items.Count -ne 0) {
        Export-AccountCSV -Account $currentAccount -Data $items -FileName $OutputFile
    }
}

$global:appendDateTimeIsBound = $PSBoundParameters.ContainsKey("AppendDateTime")
$global:dateFormatStringIsBound = $PSBoundParameters.ContainsKey("DateTimeFormatStr")

$data = Get-CraftBaggerData -FileName $InputFile
Export-CraftBaggerCSV -Data $data -OutputFile $OutputFile

