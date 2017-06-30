<#
.SYNOPSIS
  Script to organize files in a directory.

.DESCRIPTION
  This script helps the user to better organize files in a directory.

.INPUTS
  None. You cannot pipe objects to this command.

.OUTPUTS
  None. This command does not output any objects to be piped.

.PARAMETER Filter
  Specifies a filter in the provider's format or language. The value of this parameter qualifies the Path parameter.

.PARAMETER Source
  Specifies a path to source locations. Wildcards are permitted. The default location is the current directory (.).

.PARAMETER Destination
  Specifies a path to destination location. Wildcards are permitted. The default location is the current directory (.).

.PARAMETER Level
  Specifies the level to organize files, the parameter can take only these values - Day, Month and Year.

.LINK
  https://github.com/lokeshkumarbalu

.NOTES
  Author: Lokesh Kumar Balu
  Date: December 06, 2016
  Copyright © Zealag 2016. All rights reserved.
#>

#Requires -Version 2.0

[CmdletBinding()]
Param
(
	[Parameter(
		Mandatory = $true, 
		Position = 1,  
		HelpMessage = "The files to organize.")]
	[string]$Filter,

	[Parameter(
		Position = 2, 
		HelpMessage = "Source path where the files to be organized is found.")]
	[ValidateScript({Test-Path $PSItem -PathType "Container"})]
	[String]$Source = "./",

	[Parameter(
		Position = 3, 
		HelpMessage = "Destination path where the files will be organized.")]
	[ValidateScript({Test-Path $PSItem -PathType "Container"})]
	[String]$Destination = "./",

	[Parameter( 
		Position = 4, 
		HelpMessage = "Specifies level at which the files must be organized.")]
	[ValidateSet("Year", "Month", "Day")]
	[String]$Level = "Day"
)

Write-Verbose -Message "Organizing the items matching string: '$Filter'";  
Write-Verbose -Message "Destination path: $(Resolve-Path $Destination)";
Write-Verbose -Message "Source path: $(Resolve-Path $Source)";

$list = Get-ChildItem -Path $Source -Filter $Filter -File;
if ($list.Exists -ne $true)
{
	Write-Verbose -Message "No file found that match the specified filter.";
	Break;
}

$temp = "";
$processed = 0;

$fileCount = ($list | Measure-Object ).Count;
Write-Progress -Activity "Organizing files" `
		-Status "$processed/$fileCount items complete:" `
		-PercentComplete $(($processed/$fileCount)*100);

ForEach ($file in $list)
{
	$workingDate = $file.CreationTime;
	$moveLocation = $(Resolve-Path $Destination).ToString();

	$temp = $("\") + `
		$($workingDate.Year) + $("\") + `
		$($workingDate.Month.ToString("00")) + $("\") +`
		$($workingDate.Day.ToString("00"));

	$moveLocation = $moveLocation.Replace($temp, "");

	$temp = Split-Path $temp;
	$moveLocation = $moveLocation.Replace($temp, "");

	$temp = Split-Path $temp;
	$moveLocation = $moveLocation.Replace($temp, "");

	if ($Level -eq "Year")
	{
		$moveLocation = $moveLocation + $("\") + $($workingDate.Year);
	}
	elseif ($Level -eq "Month")
	{
		$moveLocation = $moveLocation + $("\") + `
			$($workingDate.Year) + $("\") + `
			$($workingDate.Month.ToString("00"));
	}
	else
	{
		$moveLocation = $moveLocation + $("\") +`
			$($workingDate.Year) + $("\") + `
			$($workingDate.Month.ToString("00")) + $("\") + `
			$($workingDate.Day.ToString("00"));	
	}
	 
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
