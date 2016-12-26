#requires -version 2
<#
.SYNOPSIS
  Script to organize files in a directory.

.DESCRIPTION
  This script helps the user to better organize file or items in a directory.

.NOTES
  Copyright © Zealag 2016. All rights reserved.
#>

[CmdletBinding()]
Param
(
	[Parameter(Mandatory = $true, Position = 1)]
	[string]$Filter,

	[Parameter(Mandatory = $true, Position = 2)]
	[ValidateScript({Test-Path $_ -PathType "Container"})]
	[String]$Source,

	[Parameter(Mandatory = $true, Position = 3)]
	[ValidateScript({Test-Path $_ -PathType "Container"})]
	[String]$Destination
)

Write-Verbose -Message "Organizing the items matching string: $Filter; with criteria: $Criteria";  
Write-Verbose -Message "Destination path: $(Resolve-Path $Destination)";
Write-Verbose -Message "Source path: $(Resolve-Path $Source)";

$list = Get-ChildItem -Path $Source -Filter $Filter -File;
if ($list.Exists -ne $true)
{
	Write-Verbose -Message "No file found that match the specified filter.";
	Break;
}

$fileCount = ($list | Measure-Object ).Count;
$processed = 0;

Write-Progress -Activity "Organizing files" `
		-Status "$processed/$fileCount items complete:" `
		-PercentComplete $(($processed/$fileCount)*100);

ForEach ($file in $list)
{
	$workingDate = $file.CreationTime;
	$moveLocation = $(Resolve-Path $Destination).ToString() + $("\") + `
		$($workingDate.Year) + $("\") + `
		$($workingDate.Month.ToString("00")) + $("\") + `
		$($workingDate.Day.ToString("00"));	

	if ($(Test-Path -Path $moveLocation -PathType Container) -eq $false)
	{
		New-Item -ItemType "Directory" -Path $moveLocation | Out-Null;
	}

	Write-Verbose -Message "Moving item: $($file.FullName)";
	Move-Item -Path $file.FullName -Destination $moveLocation;
	$processed = $processed + 1;

	Write-Progress -Activity "Organizing files" `
		-Status "$processed/$fileCount items complete:" `
		-PercentComplete $(($processed/$fileCount)*100);

}

Write-Verbose -Message "Organizing files completed.";

